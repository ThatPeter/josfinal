
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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
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
  800042:	68 80 22 80 00       	push   $0x802280
  800047:	e8 7a 01 00 00       	call   8001c6 <cprintf>
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
  800068:	68 84 22 80 00       	push   $0x802284
  80006d:	e8 54 01 00 00       	call   8001c6 <cprintf>


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
  800082:	53                   	push   %ebx
  800083:	83 ec 10             	sub    $0x10,%esp
	envid_t id = thread_create(func);
  800086:	68 33 00 80 00       	push   $0x800033
  80008b:	e8 c2 0f 00 00       	call   801052 <thread_create>
  800090:	89 c3                	mov    %eax,%ebx
	thread_join(id);
  800092:	89 04 24             	mov    %eax,(%esp)
  800095:	e8 0c 10 00 00       	call   8010a6 <thread_join>
cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id);
  80009a:	83 c4 08             	add    $0x8,%esp
  80009d:	53                   	push   %ebx
  80009e:	68 89 22 80 00       	push   $0x802289
  8000a3:	e8 1e 01 00 00       	call   8001c6 <cprintf>
	/*envid_t id2 = thread_create(test);
	thread_create(func);
	thread_create(test);
	
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id2);*/
}
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000bb:	e8 50 0a 00 00       	call   800b10 <sys_getenvid>
  8000c0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c5:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8000cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d0:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d5:	85 db                	test   %ebx,%ebx
  8000d7:	7e 07                	jle    8000e0 <libmain+0x30>
		binaryname = argv[0];
  8000d9:	8b 06                	mov    (%esi),%eax
  8000db:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	e8 95 ff ff ff       	call   80007f <umain>

	// exit gracefully
	exit();
  8000ea:	e8 2a 00 00 00       	call   800119 <exit>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000ff:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800104:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800106:	e8 05 0a 00 00       	call   800b10 <sys_getenvid>
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	e8 4b 0c 00 00       	call   800d5f <sys_thread_free>
}
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80011f:	e8 63 11 00 00       	call   801287 <close_all>
	sys_env_destroy(0);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	6a 00                	push   $0x0
  800129:	e8 a1 09 00 00       	call   800acf <sys_env_destroy>
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	53                   	push   %ebx
  800137:	83 ec 04             	sub    $0x4,%esp
  80013a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013d:	8b 13                	mov    (%ebx),%edx
  80013f:	8d 42 01             	lea    0x1(%edx),%eax
  800142:	89 03                	mov    %eax,(%ebx)
  800144:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800147:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80014b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800150:	75 1a                	jne    80016c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800152:	83 ec 08             	sub    $0x8,%esp
  800155:	68 ff 00 00 00       	push   $0xff
  80015a:	8d 43 08             	lea    0x8(%ebx),%eax
  80015d:	50                   	push   %eax
  80015e:	e8 2f 09 00 00       	call   800a92 <sys_cputs>
		b->idx = 0;
  800163:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800169:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80016c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800170:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80017e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800185:	00 00 00 
	b.cnt = 0;
  800188:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800192:	ff 75 0c             	pushl  0xc(%ebp)
  800195:	ff 75 08             	pushl  0x8(%ebp)
  800198:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	68 33 01 80 00       	push   $0x800133
  8001a4:	e8 54 01 00 00       	call   8002fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a9:	83 c4 08             	add    $0x8,%esp
  8001ac:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b8:	50                   	push   %eax
  8001b9:	e8 d4 08 00 00       	call   800a92 <sys_cputs>

	return b.cnt;
}
  8001be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cf:	50                   	push   %eax
  8001d0:	ff 75 08             	pushl  0x8(%ebp)
  8001d3:	e8 9d ff ff ff       	call   800175 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    

008001da <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 1c             	sub    $0x1c,%esp
  8001e3:	89 c7                	mov    %eax,%edi
  8001e5:	89 d6                	mov    %edx,%esi
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001fe:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800201:	39 d3                	cmp    %edx,%ebx
  800203:	72 05                	jb     80020a <printnum+0x30>
  800205:	39 45 10             	cmp    %eax,0x10(%ebp)
  800208:	77 45                	ja     80024f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	ff 75 18             	pushl  0x18(%ebp)
  800210:	8b 45 14             	mov    0x14(%ebp),%eax
  800213:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800216:	53                   	push   %ebx
  800217:	ff 75 10             	pushl  0x10(%ebp)
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800220:	ff 75 e0             	pushl  -0x20(%ebp)
  800223:	ff 75 dc             	pushl  -0x24(%ebp)
  800226:	ff 75 d8             	pushl  -0x28(%ebp)
  800229:	e8 c2 1d 00 00       	call   801ff0 <__udivdi3>
  80022e:	83 c4 18             	add    $0x18,%esp
  800231:	52                   	push   %edx
  800232:	50                   	push   %eax
  800233:	89 f2                	mov    %esi,%edx
  800235:	89 f8                	mov    %edi,%eax
  800237:	e8 9e ff ff ff       	call   8001da <printnum>
  80023c:	83 c4 20             	add    $0x20,%esp
  80023f:	eb 18                	jmp    800259 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	56                   	push   %esi
  800245:	ff 75 18             	pushl  0x18(%ebp)
  800248:	ff d7                	call   *%edi
  80024a:	83 c4 10             	add    $0x10,%esp
  80024d:	eb 03                	jmp    800252 <printnum+0x78>
  80024f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800252:	83 eb 01             	sub    $0x1,%ebx
  800255:	85 db                	test   %ebx,%ebx
  800257:	7f e8                	jg     800241 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	56                   	push   %esi
  80025d:	83 ec 04             	sub    $0x4,%esp
  800260:	ff 75 e4             	pushl  -0x1c(%ebp)
  800263:	ff 75 e0             	pushl  -0x20(%ebp)
  800266:	ff 75 dc             	pushl  -0x24(%ebp)
  800269:	ff 75 d8             	pushl  -0x28(%ebp)
  80026c:	e8 af 1e 00 00       	call   802120 <__umoddi3>
  800271:	83 c4 14             	add    $0x14,%esp
  800274:	0f be 80 b1 22 80 00 	movsbl 0x8022b1(%eax),%eax
  80027b:	50                   	push   %eax
  80027c:	ff d7                	call   *%edi
}
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028c:	83 fa 01             	cmp    $0x1,%edx
  80028f:	7e 0e                	jle    80029f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 08             	lea    0x8(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	8b 52 04             	mov    0x4(%edx),%edx
  80029d:	eb 22                	jmp    8002c1 <getuint+0x38>
	else if (lflag)
  80029f:	85 d2                	test   %edx,%edx
  8002a1:	74 10                	je     8002b3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 02                	mov    (%edx),%eax
  8002ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b1:	eb 0e                	jmp    8002c1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b8:	89 08                	mov    %ecx,(%eax)
  8002ba:	8b 02                	mov    (%edx),%eax
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d2:	73 0a                	jae    8002de <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	88 02                	mov    %al,(%edx)
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e9:	50                   	push   %eax
  8002ea:	ff 75 10             	pushl  0x10(%ebp)
  8002ed:	ff 75 0c             	pushl  0xc(%ebp)
  8002f0:	ff 75 08             	pushl  0x8(%ebp)
  8002f3:	e8 05 00 00 00       	call   8002fd <vprintfmt>
	va_end(ap);
}
  8002f8:	83 c4 10             	add    $0x10,%esp
  8002fb:	c9                   	leave  
  8002fc:	c3                   	ret    

008002fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 2c             	sub    $0x2c,%esp
  800306:	8b 75 08             	mov    0x8(%ebp),%esi
  800309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030f:	eb 12                	jmp    800323 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800311:	85 c0                	test   %eax,%eax
  800313:	0f 84 89 03 00 00    	je     8006a2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800319:	83 ec 08             	sub    $0x8,%esp
  80031c:	53                   	push   %ebx
  80031d:	50                   	push   %eax
  80031e:	ff d6                	call   *%esi
  800320:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800323:	83 c7 01             	add    $0x1,%edi
  800326:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032a:	83 f8 25             	cmp    $0x25,%eax
  80032d:	75 e2                	jne    800311 <vprintfmt+0x14>
  80032f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800333:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800341:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
  80034d:	eb 07                	jmp    800356 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800352:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8d 47 01             	lea    0x1(%edi),%eax
  800359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035c:	0f b6 07             	movzbl (%edi),%eax
  80035f:	0f b6 c8             	movzbl %al,%ecx
  800362:	83 e8 23             	sub    $0x23,%eax
  800365:	3c 55                	cmp    $0x55,%al
  800367:	0f 87 1a 03 00 00    	ja     800687 <vprintfmt+0x38a>
  80036d:	0f b6 c0             	movzbl %al,%eax
  800370:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80037e:	eb d6                	jmp    800356 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800392:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800395:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800398:	83 fa 09             	cmp    $0x9,%edx
  80039b:	77 39                	ja     8003d6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a0:	eb e9                	jmp    80038b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b3:	eb 27                	jmp    8003dc <vprintfmt+0xdf>
  8003b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bf:	0f 49 c8             	cmovns %eax,%ecx
  8003c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c8:	eb 8c                	jmp    800356 <vprintfmt+0x59>
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003cd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d4:	eb 80                	jmp    800356 <vprintfmt+0x59>
  8003d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003d9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e0:	0f 89 70 ff ff ff    	jns    800356 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ec:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f3:	e9 5e ff ff ff       	jmp    800356 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fe:	e9 53 ff ff ff       	jmp    800356 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 50 04             	lea    0x4(%eax),%edx
  800409:	89 55 14             	mov    %edx,0x14(%ebp)
  80040c:	83 ec 08             	sub    $0x8,%esp
  80040f:	53                   	push   %ebx
  800410:	ff 30                	pushl  (%eax)
  800412:	ff d6                	call   *%esi
			break;
  800414:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041a:	e9 04 ff ff ff       	jmp    800323 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 50 04             	lea    0x4(%eax),%edx
  800425:	89 55 14             	mov    %edx,0x14(%ebp)
  800428:	8b 00                	mov    (%eax),%eax
  80042a:	99                   	cltd   
  80042b:	31 d0                	xor    %edx,%eax
  80042d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042f:	83 f8 0f             	cmp    $0xf,%eax
  800432:	7f 0b                	jg     80043f <vprintfmt+0x142>
  800434:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  80043b:	85 d2                	test   %edx,%edx
  80043d:	75 18                	jne    800457 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80043f:	50                   	push   %eax
  800440:	68 c9 22 80 00       	push   $0x8022c9
  800445:	53                   	push   %ebx
  800446:	56                   	push   %esi
  800447:	e8 94 fe ff ff       	call   8002e0 <printfmt>
  80044c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800452:	e9 cc fe ff ff       	jmp    800323 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800457:	52                   	push   %edx
  800458:	68 0d 27 80 00       	push   $0x80270d
  80045d:	53                   	push   %ebx
  80045e:	56                   	push   %esi
  80045f:	e8 7c fe ff ff       	call   8002e0 <printfmt>
  800464:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046a:	e9 b4 fe ff ff       	jmp    800323 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80047a:	85 ff                	test   %edi,%edi
  80047c:	b8 c2 22 80 00       	mov    $0x8022c2,%eax
  800481:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800484:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800488:	0f 8e 94 00 00 00    	jle    800522 <vprintfmt+0x225>
  80048e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800492:	0f 84 98 00 00 00    	je     800530 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	ff 75 d0             	pushl  -0x30(%ebp)
  80049e:	57                   	push   %edi
  80049f:	e8 86 02 00 00       	call   80072a <strnlen>
  8004a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a7:	29 c1                	sub    %eax,%ecx
  8004a9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ac:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004af:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	eb 0f                	jmp    8004cc <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	53                   	push   %ebx
  8004c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c6:	83 ef 01             	sub    $0x1,%edi
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	85 ff                	test   %edi,%edi
  8004ce:	7f ed                	jg     8004bd <vprintfmt+0x1c0>
  8004d0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d6:	85 c9                	test   %ecx,%ecx
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	0f 49 c1             	cmovns %ecx,%eax
  8004e0:	29 c1                	sub    %eax,%ecx
  8004e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004eb:	89 cb                	mov    %ecx,%ebx
  8004ed:	eb 4d                	jmp    80053c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f3:	74 1b                	je     800510 <vprintfmt+0x213>
  8004f5:	0f be c0             	movsbl %al,%eax
  8004f8:	83 e8 20             	sub    $0x20,%eax
  8004fb:	83 f8 5e             	cmp    $0x5e,%eax
  8004fe:	76 10                	jbe    800510 <vprintfmt+0x213>
					putch('?', putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	ff 75 0c             	pushl  0xc(%ebp)
  800506:	6a 3f                	push   $0x3f
  800508:	ff 55 08             	call   *0x8(%ebp)
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	eb 0d                	jmp    80051d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	ff 75 0c             	pushl  0xc(%ebp)
  800516:	52                   	push   %edx
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051d:	83 eb 01             	sub    $0x1,%ebx
  800520:	eb 1a                	jmp    80053c <vprintfmt+0x23f>
  800522:	89 75 08             	mov    %esi,0x8(%ebp)
  800525:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800528:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052e:	eb 0c                	jmp    80053c <vprintfmt+0x23f>
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053c:	83 c7 01             	add    $0x1,%edi
  80053f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800543:	0f be d0             	movsbl %al,%edx
  800546:	85 d2                	test   %edx,%edx
  800548:	74 23                	je     80056d <vprintfmt+0x270>
  80054a:	85 f6                	test   %esi,%esi
  80054c:	78 a1                	js     8004ef <vprintfmt+0x1f2>
  80054e:	83 ee 01             	sub    $0x1,%esi
  800551:	79 9c                	jns    8004ef <vprintfmt+0x1f2>
  800553:	89 df                	mov    %ebx,%edi
  800555:	8b 75 08             	mov    0x8(%ebp),%esi
  800558:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055b:	eb 18                	jmp    800575 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	53                   	push   %ebx
  800561:	6a 20                	push   $0x20
  800563:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800565:	83 ef 01             	sub    $0x1,%edi
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	eb 08                	jmp    800575 <vprintfmt+0x278>
  80056d:	89 df                	mov    %ebx,%edi
  80056f:	8b 75 08             	mov    0x8(%ebp),%esi
  800572:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800575:	85 ff                	test   %edi,%edi
  800577:	7f e4                	jg     80055d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057c:	e9 a2 fd ff ff       	jmp    800323 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800581:	83 fa 01             	cmp    $0x1,%edx
  800584:	7e 16                	jle    80059c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 08             	lea    0x8(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 50 04             	mov    0x4(%eax),%edx
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	eb 32                	jmp    8005ce <vprintfmt+0x2d1>
	else if (lflag)
  80059c:	85 d2                	test   %edx,%edx
  80059e:	74 18                	je     8005b8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 04             	lea    0x4(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 c1                	mov    %eax,%ecx
  8005b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b6:	eb 16                	jmp    8005ce <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	89 c1                	mov    %eax,%ecx
  8005c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005d9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005dd:	79 74                	jns    800653 <vprintfmt+0x356>
				putch('-', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	6a 2d                	push   $0x2d
  8005e5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ed:	f7 d8                	neg    %eax
  8005ef:	83 d2 00             	adc    $0x0,%edx
  8005f2:	f7 da                	neg    %edx
  8005f4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005fc:	eb 55                	jmp    800653 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 83 fc ff ff       	call   800289 <getuint>
			base = 10;
  800606:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80060b:	eb 46                	jmp    800653 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
  800610:	e8 74 fc ff ff       	call   800289 <getuint>
			base = 8;
  800615:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80061a:	eb 37                	jmp    800653 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 30                	push   $0x30
  800622:	ff d6                	call   *%esi
			putch('x', putdat);
  800624:	83 c4 08             	add    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 78                	push   $0x78
  80062a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800635:	8b 00                	mov    (%eax),%eax
  800637:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80063c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80063f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800644:	eb 0d                	jmp    800653 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 3b fc ff ff       	call   800289 <getuint>
			base = 16;
  80064e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80065a:	57                   	push   %edi
  80065b:	ff 75 e0             	pushl  -0x20(%ebp)
  80065e:	51                   	push   %ecx
  80065f:	52                   	push   %edx
  800660:	50                   	push   %eax
  800661:	89 da                	mov    %ebx,%edx
  800663:	89 f0                	mov    %esi,%eax
  800665:	e8 70 fb ff ff       	call   8001da <printnum>
			break;
  80066a:	83 c4 20             	add    $0x20,%esp
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800670:	e9 ae fc ff ff       	jmp    800323 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	51                   	push   %ecx
  80067a:	ff d6                	call   *%esi
			break;
  80067c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800682:	e9 9c fc ff ff       	jmp    800323 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 25                	push   $0x25
  80068d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	eb 03                	jmp    800697 <vprintfmt+0x39a>
  800694:	83 ef 01             	sub    $0x1,%edi
  800697:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80069b:	75 f7                	jne    800694 <vprintfmt+0x397>
  80069d:	e9 81 fc ff ff       	jmp    800323 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a5:	5b                   	pop    %ebx
  8006a6:	5e                   	pop    %esi
  8006a7:	5f                   	pop    %edi
  8006a8:	5d                   	pop    %ebp
  8006a9:	c3                   	ret    

008006aa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	83 ec 18             	sub    $0x18,%esp
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	74 26                	je     8006f1 <vsnprintf+0x47>
  8006cb:	85 d2                	test   %edx,%edx
  8006cd:	7e 22                	jle    8006f1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006cf:	ff 75 14             	pushl  0x14(%ebp)
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d8:	50                   	push   %eax
  8006d9:	68 c3 02 80 00       	push   $0x8002c3
  8006de:	e8 1a fc ff ff       	call   8002fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 05                	jmp    8006f6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    

008006f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800701:	50                   	push   %eax
  800702:	ff 75 10             	pushl  0x10(%ebp)
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	ff 75 08             	pushl  0x8(%ebp)
  80070b:	e8 9a ff ff ff       	call   8006aa <vsnprintf>
	va_end(ap);

	return rc;
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
  80071d:	eb 03                	jmp    800722 <strlen+0x10>
		n++;
  80071f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800726:	75 f7                	jne    80071f <strlen+0xd>
		n++;
	return n;
}
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800730:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800733:	ba 00 00 00 00       	mov    $0x0,%edx
  800738:	eb 03                	jmp    80073d <strnlen+0x13>
		n++;
  80073a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073d:	39 c2                	cmp    %eax,%edx
  80073f:	74 08                	je     800749 <strnlen+0x1f>
  800741:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800745:	75 f3                	jne    80073a <strnlen+0x10>
  800747:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	53                   	push   %ebx
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800755:	89 c2                	mov    %eax,%edx
  800757:	83 c2 01             	add    $0x1,%edx
  80075a:	83 c1 01             	add    $0x1,%ecx
  80075d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800761:	88 5a ff             	mov    %bl,-0x1(%edx)
  800764:	84 db                	test   %bl,%bl
  800766:	75 ef                	jne    800757 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800768:	5b                   	pop    %ebx
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800772:	53                   	push   %ebx
  800773:	e8 9a ff ff ff       	call   800712 <strlen>
  800778:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80077b:	ff 75 0c             	pushl  0xc(%ebp)
  80077e:	01 d8                	add    %ebx,%eax
  800780:	50                   	push   %eax
  800781:	e8 c5 ff ff ff       	call   80074b <strcpy>
	return dst;
}
  800786:	89 d8                	mov    %ebx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	56                   	push   %esi
  800791:	53                   	push   %ebx
  800792:	8b 75 08             	mov    0x8(%ebp),%esi
  800795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800798:	89 f3                	mov    %esi,%ebx
  80079a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079d:	89 f2                	mov    %esi,%edx
  80079f:	eb 0f                	jmp    8007b0 <strncpy+0x23>
		*dst++ = *src;
  8007a1:	83 c2 01             	add    $0x1,%edx
  8007a4:	0f b6 01             	movzbl (%ecx),%eax
  8007a7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007aa:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ad:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b0:	39 da                	cmp    %ebx,%edx
  8007b2:	75 ed                	jne    8007a1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b4:	89 f0                	mov    %esi,%eax
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ca:	85 d2                	test   %edx,%edx
  8007cc:	74 21                	je     8007ef <strlcpy+0x35>
  8007ce:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	eb 09                	jmp    8007df <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	83 c1 01             	add    $0x1,%ecx
  8007dc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007df:	39 c2                	cmp    %eax,%edx
  8007e1:	74 09                	je     8007ec <strlcpy+0x32>
  8007e3:	0f b6 19             	movzbl (%ecx),%ebx
  8007e6:	84 db                	test   %bl,%bl
  8007e8:	75 ec                	jne    8007d6 <strlcpy+0x1c>
  8007ea:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ec:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ef:	29 f0                	sub    %esi,%eax
}
  8007f1:	5b                   	pop    %ebx
  8007f2:	5e                   	pop    %esi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007fe:	eb 06                	jmp    800806 <strcmp+0x11>
		p++, q++;
  800800:	83 c1 01             	add    $0x1,%ecx
  800803:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800806:	0f b6 01             	movzbl (%ecx),%eax
  800809:	84 c0                	test   %al,%al
  80080b:	74 04                	je     800811 <strcmp+0x1c>
  80080d:	3a 02                	cmp    (%edx),%al
  80080f:	74 ef                	je     800800 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800811:	0f b6 c0             	movzbl %al,%eax
  800814:	0f b6 12             	movzbl (%edx),%edx
  800817:	29 d0                	sub    %edx,%eax
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	89 c3                	mov    %eax,%ebx
  800827:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80082a:	eb 06                	jmp    800832 <strncmp+0x17>
		n--, p++, q++;
  80082c:	83 c0 01             	add    $0x1,%eax
  80082f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800832:	39 d8                	cmp    %ebx,%eax
  800834:	74 15                	je     80084b <strncmp+0x30>
  800836:	0f b6 08             	movzbl (%eax),%ecx
  800839:	84 c9                	test   %cl,%cl
  80083b:	74 04                	je     800841 <strncmp+0x26>
  80083d:	3a 0a                	cmp    (%edx),%cl
  80083f:	74 eb                	je     80082c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800841:	0f b6 00             	movzbl (%eax),%eax
  800844:	0f b6 12             	movzbl (%edx),%edx
  800847:	29 d0                	sub    %edx,%eax
  800849:	eb 05                	jmp    800850 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800850:	5b                   	pop    %ebx
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085d:	eb 07                	jmp    800866 <strchr+0x13>
		if (*s == c)
  80085f:	38 ca                	cmp    %cl,%dl
  800861:	74 0f                	je     800872 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	0f b6 10             	movzbl (%eax),%edx
  800869:	84 d2                	test   %dl,%dl
  80086b:	75 f2                	jne    80085f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087e:	eb 03                	jmp    800883 <strfind+0xf>
  800880:	83 c0 01             	add    $0x1,%eax
  800883:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800886:	38 ca                	cmp    %cl,%dl
  800888:	74 04                	je     80088e <strfind+0x1a>
  80088a:	84 d2                	test   %dl,%dl
  80088c:	75 f2                	jne    800880 <strfind+0xc>
			break;
	return (char *) s;
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	57                   	push   %edi
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
  800896:	8b 7d 08             	mov    0x8(%ebp),%edi
  800899:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80089c:	85 c9                	test   %ecx,%ecx
  80089e:	74 36                	je     8008d6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a6:	75 28                	jne    8008d0 <memset+0x40>
  8008a8:	f6 c1 03             	test   $0x3,%cl
  8008ab:	75 23                	jne    8008d0 <memset+0x40>
		c &= 0xFF;
  8008ad:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b1:	89 d3                	mov    %edx,%ebx
  8008b3:	c1 e3 08             	shl    $0x8,%ebx
  8008b6:	89 d6                	mov    %edx,%esi
  8008b8:	c1 e6 18             	shl    $0x18,%esi
  8008bb:	89 d0                	mov    %edx,%eax
  8008bd:	c1 e0 10             	shl    $0x10,%eax
  8008c0:	09 f0                	or     %esi,%eax
  8008c2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008c4:	89 d8                	mov    %ebx,%eax
  8008c6:	09 d0                	or     %edx,%eax
  8008c8:	c1 e9 02             	shr    $0x2,%ecx
  8008cb:	fc                   	cld    
  8008cc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ce:	eb 06                	jmp    8008d6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d3:	fc                   	cld    
  8008d4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d6:	89 f8                	mov    %edi,%eax
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5f                   	pop    %edi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008eb:	39 c6                	cmp    %eax,%esi
  8008ed:	73 35                	jae    800924 <memmove+0x47>
  8008ef:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f2:	39 d0                	cmp    %edx,%eax
  8008f4:	73 2e                	jae    800924 <memmove+0x47>
		s += n;
		d += n;
  8008f6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f9:	89 d6                	mov    %edx,%esi
  8008fb:	09 fe                	or     %edi,%esi
  8008fd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800903:	75 13                	jne    800918 <memmove+0x3b>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 0e                	jne    800918 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80090a:	83 ef 04             	sub    $0x4,%edi
  80090d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800910:	c1 e9 02             	shr    $0x2,%ecx
  800913:	fd                   	std    
  800914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800916:	eb 09                	jmp    800921 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800918:	83 ef 01             	sub    $0x1,%edi
  80091b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80091e:	fd                   	std    
  80091f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800921:	fc                   	cld    
  800922:	eb 1d                	jmp    800941 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	89 f2                	mov    %esi,%edx
  800926:	09 c2                	or     %eax,%edx
  800928:	f6 c2 03             	test   $0x3,%dl
  80092b:	75 0f                	jne    80093c <memmove+0x5f>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0a                	jne    80093c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800932:	c1 e9 02             	shr    $0x2,%ecx
  800935:	89 c7                	mov    %eax,%edi
  800937:	fc                   	cld    
  800938:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093a:	eb 05                	jmp    800941 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80093c:	89 c7                	mov    %eax,%edi
  80093e:	fc                   	cld    
  80093f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800941:	5e                   	pop    %esi
  800942:	5f                   	pop    %edi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800948:	ff 75 10             	pushl  0x10(%ebp)
  80094b:	ff 75 0c             	pushl  0xc(%ebp)
  80094e:	ff 75 08             	pushl  0x8(%ebp)
  800951:	e8 87 ff ff ff       	call   8008dd <memmove>
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
  800963:	89 c6                	mov    %eax,%esi
  800965:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800968:	eb 1a                	jmp    800984 <memcmp+0x2c>
		if (*s1 != *s2)
  80096a:	0f b6 08             	movzbl (%eax),%ecx
  80096d:	0f b6 1a             	movzbl (%edx),%ebx
  800970:	38 d9                	cmp    %bl,%cl
  800972:	74 0a                	je     80097e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800974:	0f b6 c1             	movzbl %cl,%eax
  800977:	0f b6 db             	movzbl %bl,%ebx
  80097a:	29 d8                	sub    %ebx,%eax
  80097c:	eb 0f                	jmp    80098d <memcmp+0x35>
		s1++, s2++;
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800984:	39 f0                	cmp    %esi,%eax
  800986:	75 e2                	jne    80096a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800998:	89 c1                	mov    %eax,%ecx
  80099a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80099d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a1:	eb 0a                	jmp    8009ad <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a3:	0f b6 10             	movzbl (%eax),%edx
  8009a6:	39 da                	cmp    %ebx,%edx
  8009a8:	74 07                	je     8009b1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	39 c8                	cmp    %ecx,%eax
  8009af:	72 f2                	jb     8009a3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c0:	eb 03                	jmp    8009c5 <strtol+0x11>
		s++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c5:	0f b6 01             	movzbl (%ecx),%eax
  8009c8:	3c 20                	cmp    $0x20,%al
  8009ca:	74 f6                	je     8009c2 <strtol+0xe>
  8009cc:	3c 09                	cmp    $0x9,%al
  8009ce:	74 f2                	je     8009c2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d0:	3c 2b                	cmp    $0x2b,%al
  8009d2:	75 0a                	jne    8009de <strtol+0x2a>
		s++;
  8009d4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8009dc:	eb 11                	jmp    8009ef <strtol+0x3b>
  8009de:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e3:	3c 2d                	cmp    $0x2d,%al
  8009e5:	75 08                	jne    8009ef <strtol+0x3b>
		s++, neg = 1;
  8009e7:	83 c1 01             	add    $0x1,%ecx
  8009ea:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ef:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f5:	75 15                	jne    800a0c <strtol+0x58>
  8009f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fa:	75 10                	jne    800a0c <strtol+0x58>
  8009fc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a00:	75 7c                	jne    800a7e <strtol+0xca>
		s += 2, base = 16;
  800a02:	83 c1 02             	add    $0x2,%ecx
  800a05:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0a:	eb 16                	jmp    800a22 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a0c:	85 db                	test   %ebx,%ebx
  800a0e:	75 12                	jne    800a22 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a10:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a15:	80 39 30             	cmpb   $0x30,(%ecx)
  800a18:	75 08                	jne    800a22 <strtol+0x6e>
		s++, base = 8;
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2a:	0f b6 11             	movzbl (%ecx),%edx
  800a2d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	80 fb 09             	cmp    $0x9,%bl
  800a35:	77 08                	ja     800a3f <strtol+0x8b>
			dig = *s - '0';
  800a37:	0f be d2             	movsbl %dl,%edx
  800a3a:	83 ea 30             	sub    $0x30,%edx
  800a3d:	eb 22                	jmp    800a61 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a3f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 19             	cmp    $0x19,%bl
  800a47:	77 08                	ja     800a51 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 57             	sub    $0x57,%edx
  800a4f:	eb 10                	jmp    800a61 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a51:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 19             	cmp    $0x19,%bl
  800a59:	77 16                	ja     800a71 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a5b:	0f be d2             	movsbl %dl,%edx
  800a5e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a61:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a64:	7d 0b                	jge    800a71 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a6f:	eb b9                	jmp    800a2a <strtol+0x76>

	if (endptr)
  800a71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a75:	74 0d                	je     800a84 <strtol+0xd0>
		*endptr = (char *) s;
  800a77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7a:	89 0e                	mov    %ecx,(%esi)
  800a7c:	eb 06                	jmp    800a84 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7e:	85 db                	test   %ebx,%ebx
  800a80:	74 98                	je     800a1a <strtol+0x66>
  800a82:	eb 9e                	jmp    800a22 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a84:	89 c2                	mov    %eax,%edx
  800a86:	f7 da                	neg    %edx
  800a88:	85 ff                	test   %edi,%edi
  800a8a:	0f 45 c2             	cmovne %edx,%eax
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa3:	89 c3                	mov    %eax,%ebx
  800aa5:	89 c7                	mov    %eax,%edi
  800aa7:	89 c6                	mov    %eax,%esi
  800aa9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab6:	ba 00 00 00 00       	mov    $0x0,%edx
  800abb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac0:	89 d1                	mov    %edx,%ecx
  800ac2:	89 d3                	mov    %edx,%ebx
  800ac4:	89 d7                	mov    %edx,%edi
  800ac6:	89 d6                	mov    %edx,%esi
  800ac8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800add:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	89 cb                	mov    %ecx,%ebx
  800ae7:	89 cf                	mov    %ecx,%edi
  800ae9:	89 ce                	mov    %ecx,%esi
  800aeb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aed:	85 c0                	test   %eax,%eax
  800aef:	7e 17                	jle    800b08 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af1:	83 ec 0c             	sub    $0xc,%esp
  800af4:	50                   	push   %eax
  800af5:	6a 03                	push   $0x3
  800af7:	68 bf 25 80 00       	push   $0x8025bf
  800afc:	6a 23                	push   $0x23
  800afe:	68 dc 25 80 00       	push   $0x8025dc
  800b03:	e8 b0 12 00 00       	call   801db8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_yield>:

void
sys_yield(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b57:	be 00 00 00 00       	mov    $0x0,%esi
  800b5c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6a:	89 f7                	mov    %esi,%edi
  800b6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	7e 17                	jle    800b89 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	50                   	push   %eax
  800b76:	6a 04                	push   $0x4
  800b78:	68 bf 25 80 00       	push   $0x8025bf
  800b7d:	6a 23                	push   $0x23
  800b7f:	68 dc 25 80 00       	push   $0x8025dc
  800b84:	e8 2f 12 00 00       	call   801db8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bab:	8b 75 18             	mov    0x18(%ebp),%esi
  800bae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	7e 17                	jle    800bcb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 05                	push   $0x5
  800bba:	68 bf 25 80 00       	push   $0x8025bf
  800bbf:	6a 23                	push   $0x23
  800bc1:	68 dc 25 80 00       	push   $0x8025dc
  800bc6:	e8 ed 11 00 00       	call   801db8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be1:	b8 06 00 00 00       	mov    $0x6,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 df                	mov    %ebx,%edi
  800bee:	89 de                	mov    %ebx,%esi
  800bf0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	7e 17                	jle    800c0d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 06                	push   $0x6
  800bfc:	68 bf 25 80 00       	push   $0x8025bf
  800c01:	6a 23                	push   $0x23
  800c03:	68 dc 25 80 00       	push   $0x8025dc
  800c08:	e8 ab 11 00 00       	call   801db8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c23:	b8 08 00 00 00       	mov    $0x8,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 df                	mov    %ebx,%edi
  800c30:	89 de                	mov    %ebx,%esi
  800c32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 08                	push   $0x8
  800c3e:	68 bf 25 80 00       	push   $0x8025bf
  800c43:	6a 23                	push   $0x23
  800c45:	68 dc 25 80 00       	push   $0x8025dc
  800c4a:	e8 69 11 00 00       	call   801db8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 09                	push   $0x9
  800c80:	68 bf 25 80 00       	push   $0x8025bf
  800c85:	6a 23                	push   $0x23
  800c87:	68 dc 25 80 00       	push   $0x8025dc
  800c8c:	e8 27 11 00 00       	call   801db8 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 0a                	push   $0xa
  800cc2:	68 bf 25 80 00       	push   $0x8025bf
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 dc 25 80 00       	push   $0x8025dc
  800cce:	e8 e5 10 00 00       	call   801db8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	be 00 00 00 00       	mov    $0x0,%esi
  800ce6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 cb                	mov    %ecx,%ebx
  800d16:	89 cf                	mov    %ecx,%edi
  800d18:	89 ce                	mov    %ecx,%esi
  800d1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 17                	jle    800d37 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 0d                	push   $0xd
  800d26:	68 bf 25 80 00       	push   $0x8025bf
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 dc 25 80 00       	push   $0x8025dc
  800d32:	e8 81 10 00 00       	call   801db8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	89 cb                	mov    %ecx,%ebx
  800d54:	89 cf                	mov    %ecx,%edi
  800d56:	89 ce                	mov    %ecx,%esi
  800d58:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	89 cb                	mov    %ecx,%ebx
  800d74:	89 cf                	mov    %ecx,%edi
  800d76:	89 ce                	mov    %ecx,%esi
  800d78:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8a:	b8 10 00 00 00       	mov    $0x10,%eax
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 cb                	mov    %ecx,%ebx
  800d94:	89 cf                	mov    %ecx,%edi
  800d96:	89 ce                	mov    %ecx,%esi
  800d98:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	53                   	push   %ebx
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800da9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dab:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800daf:	74 11                	je     800dc2 <pgfault+0x23>
  800db1:	89 d8                	mov    %ebx,%eax
  800db3:	c1 e8 0c             	shr    $0xc,%eax
  800db6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dbd:	f6 c4 08             	test   $0x8,%ah
  800dc0:	75 14                	jne    800dd6 <pgfault+0x37>
		panic("faulting access");
  800dc2:	83 ec 04             	sub    $0x4,%esp
  800dc5:	68 ea 25 80 00       	push   $0x8025ea
  800dca:	6a 1e                	push   $0x1e
  800dcc:	68 fa 25 80 00       	push   $0x8025fa
  800dd1:	e8 e2 0f 00 00       	call   801db8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	6a 07                	push   $0x7
  800ddb:	68 00 f0 7f 00       	push   $0x7ff000
  800de0:	6a 00                	push   $0x0
  800de2:	e8 67 fd ff ff       	call   800b4e <sys_page_alloc>
	if (r < 0) {
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	79 12                	jns    800e00 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dee:	50                   	push   %eax
  800def:	68 05 26 80 00       	push   $0x802605
  800df4:	6a 2c                	push   $0x2c
  800df6:	68 fa 25 80 00       	push   $0x8025fa
  800dfb:	e8 b8 0f 00 00       	call   801db8 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e00:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	68 00 10 00 00       	push   $0x1000
  800e0e:	53                   	push   %ebx
  800e0f:	68 00 f0 7f 00       	push   $0x7ff000
  800e14:	e8 2c fb ff ff       	call   800945 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e19:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e20:	53                   	push   %ebx
  800e21:	6a 00                	push   $0x0
  800e23:	68 00 f0 7f 00       	push   $0x7ff000
  800e28:	6a 00                	push   $0x0
  800e2a:	e8 62 fd ff ff       	call   800b91 <sys_page_map>
	if (r < 0) {
  800e2f:	83 c4 20             	add    $0x20,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	79 12                	jns    800e48 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e36:	50                   	push   %eax
  800e37:	68 05 26 80 00       	push   $0x802605
  800e3c:	6a 33                	push   $0x33
  800e3e:	68 fa 25 80 00       	push   $0x8025fa
  800e43:	e8 70 0f 00 00       	call   801db8 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	68 00 f0 7f 00       	push   $0x7ff000
  800e50:	6a 00                	push   $0x0
  800e52:	e8 7c fd ff ff       	call   800bd3 <sys_page_unmap>
	if (r < 0) {
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	79 12                	jns    800e70 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e5e:	50                   	push   %eax
  800e5f:	68 05 26 80 00       	push   $0x802605
  800e64:	6a 37                	push   $0x37
  800e66:	68 fa 25 80 00       	push   $0x8025fa
  800e6b:	e8 48 0f 00 00       	call   801db8 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    

00800e75 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
  800e7b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e7e:	68 9f 0d 80 00       	push   $0x800d9f
  800e83:	e8 76 0f 00 00       	call   801dfe <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e88:	b8 07 00 00 00       	mov    $0x7,%eax
  800e8d:	cd 30                	int    $0x30
  800e8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	79 17                	jns    800eb0 <fork+0x3b>
		panic("fork fault %e");
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	68 1e 26 80 00       	push   $0x80261e
  800ea1:	68 84 00 00 00       	push   $0x84
  800ea6:	68 fa 25 80 00       	push   $0x8025fa
  800eab:	e8 08 0f 00 00       	call   801db8 <_panic>
  800eb0:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800eb2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eb6:	75 24                	jne    800edc <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eb8:	e8 53 fc ff ff       	call   800b10 <sys_getenvid>
  800ebd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ec2:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800ec8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ecd:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed7:	e9 64 01 00 00       	jmp    801040 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800edc:	83 ec 04             	sub    $0x4,%esp
  800edf:	6a 07                	push   $0x7
  800ee1:	68 00 f0 bf ee       	push   $0xeebff000
  800ee6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ee9:	e8 60 fc ff ff       	call   800b4e <sys_page_alloc>
  800eee:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ef1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ef6:	89 d8                	mov    %ebx,%eax
  800ef8:	c1 e8 16             	shr    $0x16,%eax
  800efb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f02:	a8 01                	test   $0x1,%al
  800f04:	0f 84 fc 00 00 00    	je     801006 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f0a:	89 d8                	mov    %ebx,%eax
  800f0c:	c1 e8 0c             	shr    $0xc,%eax
  800f0f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f16:	f6 c2 01             	test   $0x1,%dl
  800f19:	0f 84 e7 00 00 00    	je     801006 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f24:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f2b:	f6 c6 04             	test   $0x4,%dh
  800f2e:	74 39                	je     800f69 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f30:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f37:	83 ec 0c             	sub    $0xc,%esp
  800f3a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f3f:	50                   	push   %eax
  800f40:	56                   	push   %esi
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	6a 00                	push   $0x0
  800f45:	e8 47 fc ff ff       	call   800b91 <sys_page_map>
		if (r < 0) {
  800f4a:	83 c4 20             	add    $0x20,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	0f 89 b1 00 00 00    	jns    801006 <fork+0x191>
		    	panic("sys page map fault %e");
  800f55:	83 ec 04             	sub    $0x4,%esp
  800f58:	68 2c 26 80 00       	push   $0x80262c
  800f5d:	6a 54                	push   $0x54
  800f5f:	68 fa 25 80 00       	push   $0x8025fa
  800f64:	e8 4f 0e 00 00       	call   801db8 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f69:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f70:	f6 c2 02             	test   $0x2,%dl
  800f73:	75 0c                	jne    800f81 <fork+0x10c>
  800f75:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7c:	f6 c4 08             	test   $0x8,%ah
  800f7f:	74 5b                	je     800fdc <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	68 05 08 00 00       	push   $0x805
  800f89:	56                   	push   %esi
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 fe fb ff ff       	call   800b91 <sys_page_map>
		if (r < 0) {
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 14                	jns    800fae <fork+0x139>
		    	panic("sys page map fault %e");
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	68 2c 26 80 00       	push   $0x80262c
  800fa2:	6a 5b                	push   $0x5b
  800fa4:	68 fa 25 80 00       	push   $0x8025fa
  800fa9:	e8 0a 0e 00 00       	call   801db8 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	68 05 08 00 00       	push   $0x805
  800fb6:	56                   	push   %esi
  800fb7:	6a 00                	push   $0x0
  800fb9:	56                   	push   %esi
  800fba:	6a 00                	push   $0x0
  800fbc:	e8 d0 fb ff ff       	call   800b91 <sys_page_map>
		if (r < 0) {
  800fc1:	83 c4 20             	add    $0x20,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	79 3e                	jns    801006 <fork+0x191>
		    	panic("sys page map fault %e");
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	68 2c 26 80 00       	push   $0x80262c
  800fd0:	6a 5f                	push   $0x5f
  800fd2:	68 fa 25 80 00       	push   $0x8025fa
  800fd7:	e8 dc 0d 00 00       	call   801db8 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	6a 05                	push   $0x5
  800fe1:	56                   	push   %esi
  800fe2:	57                   	push   %edi
  800fe3:	56                   	push   %esi
  800fe4:	6a 00                	push   $0x0
  800fe6:	e8 a6 fb ff ff       	call   800b91 <sys_page_map>
		if (r < 0) {
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	79 14                	jns    801006 <fork+0x191>
		    	panic("sys page map fault %e");
  800ff2:	83 ec 04             	sub    $0x4,%esp
  800ff5:	68 2c 26 80 00       	push   $0x80262c
  800ffa:	6a 64                	push   $0x64
  800ffc:	68 fa 25 80 00       	push   $0x8025fa
  801001:	e8 b2 0d 00 00       	call   801db8 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801006:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80100c:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801012:	0f 85 de fe ff ff    	jne    800ef6 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801018:	a1 04 40 80 00       	mov    0x804004,%eax
  80101d:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  801023:	83 ec 08             	sub    $0x8,%esp
  801026:	50                   	push   %eax
  801027:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80102a:	57                   	push   %edi
  80102b:	e8 69 fc ff ff       	call   800c99 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801030:	83 c4 08             	add    $0x8,%esp
  801033:	6a 02                	push   $0x2
  801035:	57                   	push   %edi
  801036:	e8 da fb ff ff       	call   800c15 <sys_env_set_status>
	
	return envid;
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801040:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <sfork>:

envid_t
sfork(void)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80104b:	b8 00 00 00 00       	mov    $0x0,%eax
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
  801057:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80105a:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	53                   	push   %ebx
  801064:	68 44 26 80 00       	push   $0x802644
  801069:	e8 58 f1 ff ff       	call   8001c6 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80106e:	c7 04 24 f9 00 80 00 	movl   $0x8000f9,(%esp)
  801075:	e8 c5 fc ff ff       	call   800d3f <sys_thread_create>
  80107a:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80107c:	83 c4 08             	add    $0x8,%esp
  80107f:	53                   	push   %ebx
  801080:	68 44 26 80 00       	push   $0x802644
  801085:	e8 3c f1 ff ff       	call   8001c6 <cprintf>
	return id;
}
  80108a:	89 f0                	mov    %esi,%eax
  80108c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801099:	ff 75 08             	pushl  0x8(%ebp)
  80109c:	e8 be fc ff ff       	call   800d5f <sys_thread_free>
}
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8010ac:	ff 75 08             	pushl  0x8(%ebp)
  8010af:	e8 cb fc ff ff       	call   800d7f <sys_thread_join>
}
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bf:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c4:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	c1 ea 16             	shr    $0x16,%edx
  8010f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f7:	f6 c2 01             	test   $0x1,%dl
  8010fa:	74 11                	je     80110d <fd_alloc+0x2d>
  8010fc:	89 c2                	mov    %eax,%edx
  8010fe:	c1 ea 0c             	shr    $0xc,%edx
  801101:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801108:	f6 c2 01             	test   $0x1,%dl
  80110b:	75 09                	jne    801116 <fd_alloc+0x36>
			*fd_store = fd;
  80110d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110f:	b8 00 00 00 00       	mov    $0x0,%eax
  801114:	eb 17                	jmp    80112d <fd_alloc+0x4d>
  801116:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80111b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801120:	75 c9                	jne    8010eb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801122:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801128:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801135:	83 f8 1f             	cmp    $0x1f,%eax
  801138:	77 36                	ja     801170 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80113a:	c1 e0 0c             	shl    $0xc,%eax
  80113d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801142:	89 c2                	mov    %eax,%edx
  801144:	c1 ea 16             	shr    $0x16,%edx
  801147:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114e:	f6 c2 01             	test   $0x1,%dl
  801151:	74 24                	je     801177 <fd_lookup+0x48>
  801153:	89 c2                	mov    %eax,%edx
  801155:	c1 ea 0c             	shr    $0xc,%edx
  801158:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115f:	f6 c2 01             	test   $0x1,%dl
  801162:	74 1a                	je     80117e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801164:	8b 55 0c             	mov    0xc(%ebp),%edx
  801167:	89 02                	mov    %eax,(%edx)
	return 0;
  801169:	b8 00 00 00 00       	mov    $0x0,%eax
  80116e:	eb 13                	jmp    801183 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801170:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801175:	eb 0c                	jmp    801183 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801177:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117c:	eb 05                	jmp    801183 <fd_lookup+0x54>
  80117e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118e:	ba e4 26 80 00       	mov    $0x8026e4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801193:	eb 13                	jmp    8011a8 <dev_lookup+0x23>
  801195:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801198:	39 08                	cmp    %ecx,(%eax)
  80119a:	75 0c                	jne    8011a8 <dev_lookup+0x23>
			*dev = devtab[i];
  80119c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a6:	eb 31                	jmp    8011d9 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a8:	8b 02                	mov    (%edx),%eax
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	75 e7                	jne    801195 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8011b9:	83 ec 04             	sub    $0x4,%esp
  8011bc:	51                   	push   %ecx
  8011bd:	50                   	push   %eax
  8011be:	68 68 26 80 00       	push   $0x802668
  8011c3:	e8 fe ef ff ff       	call   8001c6 <cprintf>
	*dev = 0;
  8011c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 10             	sub    $0x10,%esp
  8011e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ec:	50                   	push   %eax
  8011ed:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011f3:	c1 e8 0c             	shr    $0xc,%eax
  8011f6:	50                   	push   %eax
  8011f7:	e8 33 ff ff ff       	call   80112f <fd_lookup>
  8011fc:	83 c4 08             	add    $0x8,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 05                	js     801208 <fd_close+0x2d>
	    || fd != fd2)
  801203:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801206:	74 0c                	je     801214 <fd_close+0x39>
		return (must_exist ? r : 0);
  801208:	84 db                	test   %bl,%bl
  80120a:	ba 00 00 00 00       	mov    $0x0,%edx
  80120f:	0f 44 c2             	cmove  %edx,%eax
  801212:	eb 41                	jmp    801255 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	ff 36                	pushl  (%esi)
  80121d:	e8 63 ff ff ff       	call   801185 <dev_lookup>
  801222:	89 c3                	mov    %eax,%ebx
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 1a                	js     801245 <fd_close+0x6a>
		if (dev->dev_close)
  80122b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801231:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801236:	85 c0                	test   %eax,%eax
  801238:	74 0b                	je     801245 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80123a:	83 ec 0c             	sub    $0xc,%esp
  80123d:	56                   	push   %esi
  80123e:	ff d0                	call   *%eax
  801240:	89 c3                	mov    %eax,%ebx
  801242:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801245:	83 ec 08             	sub    $0x8,%esp
  801248:	56                   	push   %esi
  801249:	6a 00                	push   $0x0
  80124b:	e8 83 f9 ff ff       	call   800bd3 <sys_page_unmap>
	return r;
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	89 d8                	mov    %ebx,%eax
}
  801255:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801258:	5b                   	pop    %ebx
  801259:	5e                   	pop    %esi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801262:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	ff 75 08             	pushl  0x8(%ebp)
  801269:	e8 c1 fe ff ff       	call   80112f <fd_lookup>
  80126e:	83 c4 08             	add    $0x8,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	78 10                	js     801285 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801275:	83 ec 08             	sub    $0x8,%esp
  801278:	6a 01                	push   $0x1
  80127a:	ff 75 f4             	pushl  -0xc(%ebp)
  80127d:	e8 59 ff ff ff       	call   8011db <fd_close>
  801282:	83 c4 10             	add    $0x10,%esp
}
  801285:	c9                   	leave  
  801286:	c3                   	ret    

00801287 <close_all>:

void
close_all(void)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	53                   	push   %ebx
  80128b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80128e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801293:	83 ec 0c             	sub    $0xc,%esp
  801296:	53                   	push   %ebx
  801297:	e8 c0 ff ff ff       	call   80125c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80129c:	83 c3 01             	add    $0x1,%ebx
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	83 fb 20             	cmp    $0x20,%ebx
  8012a5:	75 ec                	jne    801293 <close_all+0xc>
		close(i);
}
  8012a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012aa:	c9                   	leave  
  8012ab:	c3                   	ret    

008012ac <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 2c             	sub    $0x2c,%esp
  8012b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	ff 75 08             	pushl  0x8(%ebp)
  8012bf:	e8 6b fe ff ff       	call   80112f <fd_lookup>
  8012c4:	83 c4 08             	add    $0x8,%esp
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	0f 88 c1 00 00 00    	js     801390 <dup+0xe4>
		return r;
	close(newfdnum);
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	56                   	push   %esi
  8012d3:	e8 84 ff ff ff       	call   80125c <close>

	newfd = INDEX2FD(newfdnum);
  8012d8:	89 f3                	mov    %esi,%ebx
  8012da:	c1 e3 0c             	shl    $0xc,%ebx
  8012dd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012e3:	83 c4 04             	add    $0x4,%esp
  8012e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012e9:	e8 db fd ff ff       	call   8010c9 <fd2data>
  8012ee:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012f0:	89 1c 24             	mov    %ebx,(%esp)
  8012f3:	e8 d1 fd ff ff       	call   8010c9 <fd2data>
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012fe:	89 f8                	mov    %edi,%eax
  801300:	c1 e8 16             	shr    $0x16,%eax
  801303:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80130a:	a8 01                	test   $0x1,%al
  80130c:	74 37                	je     801345 <dup+0x99>
  80130e:	89 f8                	mov    %edi,%eax
  801310:	c1 e8 0c             	shr    $0xc,%eax
  801313:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80131a:	f6 c2 01             	test   $0x1,%dl
  80131d:	74 26                	je     801345 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80131f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	25 07 0e 00 00       	and    $0xe07,%eax
  80132e:	50                   	push   %eax
  80132f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801332:	6a 00                	push   $0x0
  801334:	57                   	push   %edi
  801335:	6a 00                	push   $0x0
  801337:	e8 55 f8 ff ff       	call   800b91 <sys_page_map>
  80133c:	89 c7                	mov    %eax,%edi
  80133e:	83 c4 20             	add    $0x20,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	78 2e                	js     801373 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801345:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801348:	89 d0                	mov    %edx,%eax
  80134a:	c1 e8 0c             	shr    $0xc,%eax
  80134d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	25 07 0e 00 00       	and    $0xe07,%eax
  80135c:	50                   	push   %eax
  80135d:	53                   	push   %ebx
  80135e:	6a 00                	push   $0x0
  801360:	52                   	push   %edx
  801361:	6a 00                	push   $0x0
  801363:	e8 29 f8 ff ff       	call   800b91 <sys_page_map>
  801368:	89 c7                	mov    %eax,%edi
  80136a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80136d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80136f:	85 ff                	test   %edi,%edi
  801371:	79 1d                	jns    801390 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	53                   	push   %ebx
  801377:	6a 00                	push   $0x0
  801379:	e8 55 f8 ff ff       	call   800bd3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137e:	83 c4 08             	add    $0x8,%esp
  801381:	ff 75 d4             	pushl  -0x2c(%ebp)
  801384:	6a 00                	push   $0x0
  801386:	e8 48 f8 ff ff       	call   800bd3 <sys_page_unmap>
	return r;
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	89 f8                	mov    %edi,%eax
}
  801390:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 14             	sub    $0x14,%esp
  80139f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	53                   	push   %ebx
  8013a7:	e8 83 fd ff ff       	call   80112f <fd_lookup>
  8013ac:	83 c4 08             	add    $0x8,%esp
  8013af:	89 c2                	mov    %eax,%edx
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 70                	js     801425 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bf:	ff 30                	pushl  (%eax)
  8013c1:	e8 bf fd ff ff       	call   801185 <dev_lookup>
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 4f                	js     80141c <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d0:	8b 42 08             	mov    0x8(%edx),%eax
  8013d3:	83 e0 03             	and    $0x3,%eax
  8013d6:	83 f8 01             	cmp    $0x1,%eax
  8013d9:	75 24                	jne    8013ff <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013db:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8013e6:	83 ec 04             	sub    $0x4,%esp
  8013e9:	53                   	push   %ebx
  8013ea:	50                   	push   %eax
  8013eb:	68 a9 26 80 00       	push   $0x8026a9
  8013f0:	e8 d1 ed ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013fd:	eb 26                	jmp    801425 <read+0x8d>
	}
	if (!dev->dev_read)
  8013ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801402:	8b 40 08             	mov    0x8(%eax),%eax
  801405:	85 c0                	test   %eax,%eax
  801407:	74 17                	je     801420 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801409:	83 ec 04             	sub    $0x4,%esp
  80140c:	ff 75 10             	pushl  0x10(%ebp)
  80140f:	ff 75 0c             	pushl  0xc(%ebp)
  801412:	52                   	push   %edx
  801413:	ff d0                	call   *%eax
  801415:	89 c2                	mov    %eax,%edx
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	eb 09                	jmp    801425 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141c:	89 c2                	mov    %eax,%edx
  80141e:	eb 05                	jmp    801425 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801420:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801425:	89 d0                	mov    %edx,%eax
  801427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	57                   	push   %edi
  801430:	56                   	push   %esi
  801431:	53                   	push   %ebx
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	8b 7d 08             	mov    0x8(%ebp),%edi
  801438:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80143b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801440:	eb 21                	jmp    801463 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801442:	83 ec 04             	sub    $0x4,%esp
  801445:	89 f0                	mov    %esi,%eax
  801447:	29 d8                	sub    %ebx,%eax
  801449:	50                   	push   %eax
  80144a:	89 d8                	mov    %ebx,%eax
  80144c:	03 45 0c             	add    0xc(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	57                   	push   %edi
  801451:	e8 42 ff ff ff       	call   801398 <read>
		if (m < 0)
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 10                	js     80146d <readn+0x41>
			return m;
		if (m == 0)
  80145d:	85 c0                	test   %eax,%eax
  80145f:	74 0a                	je     80146b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801461:	01 c3                	add    %eax,%ebx
  801463:	39 f3                	cmp    %esi,%ebx
  801465:	72 db                	jb     801442 <readn+0x16>
  801467:	89 d8                	mov    %ebx,%eax
  801469:	eb 02                	jmp    80146d <readn+0x41>
  80146b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80146d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801470:	5b                   	pop    %ebx
  801471:	5e                   	pop    %esi
  801472:	5f                   	pop    %edi
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    

00801475 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	53                   	push   %ebx
  801479:	83 ec 14             	sub    $0x14,%esp
  80147c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	53                   	push   %ebx
  801484:	e8 a6 fc ff ff       	call   80112f <fd_lookup>
  801489:	83 c4 08             	add    $0x8,%esp
  80148c:	89 c2                	mov    %eax,%edx
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 6b                	js     8014fd <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149c:	ff 30                	pushl  (%eax)
  80149e:	e8 e2 fc ff ff       	call   801185 <dev_lookup>
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 4a                	js     8014f4 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014b1:	75 24                	jne    8014d7 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8014be:	83 ec 04             	sub    $0x4,%esp
  8014c1:	53                   	push   %ebx
  8014c2:	50                   	push   %eax
  8014c3:	68 c5 26 80 00       	push   $0x8026c5
  8014c8:	e8 f9 ec ff ff       	call   8001c6 <cprintf>
		return -E_INVAL;
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d5:	eb 26                	jmp    8014fd <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014da:	8b 52 0c             	mov    0xc(%edx),%edx
  8014dd:	85 d2                	test   %edx,%edx
  8014df:	74 17                	je     8014f8 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014e1:	83 ec 04             	sub    $0x4,%esp
  8014e4:	ff 75 10             	pushl  0x10(%ebp)
  8014e7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ea:	50                   	push   %eax
  8014eb:	ff d2                	call   *%edx
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	eb 09                	jmp    8014fd <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f4:	89 c2                	mov    %eax,%edx
  8014f6:	eb 05                	jmp    8014fd <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014fd:	89 d0                	mov    %edx,%eax
  8014ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <seek>:

int
seek(int fdnum, off_t offset)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80150a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	ff 75 08             	pushl  0x8(%ebp)
  801511:	e8 19 fc ff ff       	call   80112f <fd_lookup>
  801516:	83 c4 08             	add    $0x8,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 0e                	js     80152b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80151d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801520:	8b 55 0c             	mov    0xc(%ebp),%edx
  801523:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152b:	c9                   	leave  
  80152c:	c3                   	ret    

0080152d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 14             	sub    $0x14,%esp
  801534:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801537:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	53                   	push   %ebx
  80153c:	e8 ee fb ff ff       	call   80112f <fd_lookup>
  801541:	83 c4 08             	add    $0x8,%esp
  801544:	89 c2                	mov    %eax,%edx
  801546:	85 c0                	test   %eax,%eax
  801548:	78 68                	js     8015b2 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801554:	ff 30                	pushl  (%eax)
  801556:	e8 2a fc ff ff       	call   801185 <dev_lookup>
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 47                	js     8015a9 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801562:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801565:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801569:	75 24                	jne    80158f <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80156b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801570:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801576:	83 ec 04             	sub    $0x4,%esp
  801579:	53                   	push   %ebx
  80157a:	50                   	push   %eax
  80157b:	68 88 26 80 00       	push   $0x802688
  801580:	e8 41 ec ff ff       	call   8001c6 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80158d:	eb 23                	jmp    8015b2 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  80158f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801592:	8b 52 18             	mov    0x18(%edx),%edx
  801595:	85 d2                	test   %edx,%edx
  801597:	74 14                	je     8015ad <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	ff 75 0c             	pushl  0xc(%ebp)
  80159f:	50                   	push   %eax
  8015a0:	ff d2                	call   *%edx
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	eb 09                	jmp    8015b2 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	eb 05                	jmp    8015b2 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015b2:	89 d0                	mov    %edx,%eax
  8015b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 14             	sub    $0x14,%esp
  8015c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	ff 75 08             	pushl  0x8(%ebp)
  8015ca:	e8 60 fb ff ff       	call   80112f <fd_lookup>
  8015cf:	83 c4 08             	add    $0x8,%esp
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 58                	js     801630 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e2:	ff 30                	pushl  (%eax)
  8015e4:	e8 9c fb ff ff       	call   801185 <dev_lookup>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 37                	js     801627 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015f7:	74 32                	je     80162b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015f9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015fc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801603:	00 00 00 
	stat->st_isdir = 0;
  801606:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80160d:	00 00 00 
	stat->st_dev = dev;
  801610:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	53                   	push   %ebx
  80161a:	ff 75 f0             	pushl  -0x10(%ebp)
  80161d:	ff 50 14             	call   *0x14(%eax)
  801620:	89 c2                	mov    %eax,%edx
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	eb 09                	jmp    801630 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801627:	89 c2                	mov    %eax,%edx
  801629:	eb 05                	jmp    801630 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80162b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801630:	89 d0                	mov    %edx,%eax
  801632:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	56                   	push   %esi
  80163b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	6a 00                	push   $0x0
  801641:	ff 75 08             	pushl  0x8(%ebp)
  801644:	e8 e3 01 00 00       	call   80182c <open>
  801649:	89 c3                	mov    %eax,%ebx
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 1b                	js     80166d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	ff 75 0c             	pushl  0xc(%ebp)
  801658:	50                   	push   %eax
  801659:	e8 5b ff ff ff       	call   8015b9 <fstat>
  80165e:	89 c6                	mov    %eax,%esi
	close(fd);
  801660:	89 1c 24             	mov    %ebx,(%esp)
  801663:	e8 f4 fb ff ff       	call   80125c <close>
	return r;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	89 f0                	mov    %esi,%eax
}
  80166d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801670:	5b                   	pop    %ebx
  801671:	5e                   	pop    %esi
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    

00801674 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	89 c6                	mov    %eax,%esi
  80167b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801684:	75 12                	jne    801698 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	6a 01                	push   $0x1
  80168b:	e8 da 08 00 00       	call   801f6a <ipc_find_env>
  801690:	a3 00 40 80 00       	mov    %eax,0x804000
  801695:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801698:	6a 07                	push   $0x7
  80169a:	68 00 50 80 00       	push   $0x805000
  80169f:	56                   	push   %esi
  8016a0:	ff 35 00 40 80 00    	pushl  0x804000
  8016a6:	e8 5d 08 00 00       	call   801f08 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ab:	83 c4 0c             	add    $0xc,%esp
  8016ae:	6a 00                	push   $0x0
  8016b0:	53                   	push   %ebx
  8016b1:	6a 00                	push   $0x0
  8016b3:	e8 d5 07 00 00       	call   801e8d <ipc_recv>
}
  8016b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dd:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e2:	e8 8d ff ff ff       	call   801674 <fsipc>
}
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ff:	b8 06 00 00 00       	mov    $0x6,%eax
  801704:	e8 6b ff ff ff       	call   801674 <fsipc>
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	53                   	push   %ebx
  80170f:	83 ec 04             	sub    $0x4,%esp
  801712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801715:	8b 45 08             	mov    0x8(%ebp),%eax
  801718:	8b 40 0c             	mov    0xc(%eax),%eax
  80171b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801720:	ba 00 00 00 00       	mov    $0x0,%edx
  801725:	b8 05 00 00 00       	mov    $0x5,%eax
  80172a:	e8 45 ff ff ff       	call   801674 <fsipc>
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 2c                	js     80175f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801733:	83 ec 08             	sub    $0x8,%esp
  801736:	68 00 50 80 00       	push   $0x805000
  80173b:	53                   	push   %ebx
  80173c:	e8 0a f0 ff ff       	call   80074b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801741:	a1 80 50 80 00       	mov    0x805080,%eax
  801746:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80174c:	a1 84 50 80 00       	mov    0x805084,%eax
  801751:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801762:	c9                   	leave  
  801763:	c3                   	ret    

00801764 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	83 ec 0c             	sub    $0xc,%esp
  80176a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80176d:	8b 55 08             	mov    0x8(%ebp),%edx
  801770:	8b 52 0c             	mov    0xc(%edx),%edx
  801773:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801779:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80177e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801783:	0f 47 c2             	cmova  %edx,%eax
  801786:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80178b:	50                   	push   %eax
  80178c:	ff 75 0c             	pushl  0xc(%ebp)
  80178f:	68 08 50 80 00       	push   $0x805008
  801794:	e8 44 f1 ff ff       	call   8008dd <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	b8 04 00 00 00       	mov    $0x4,%eax
  8017a3:	e8 cc fe ff ff       	call   801674 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
  8017af:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017bd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8017cd:	e8 a2 fe ff ff       	call   801674 <fsipc>
  8017d2:	89 c3                	mov    %eax,%ebx
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 4b                	js     801823 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017d8:	39 c6                	cmp    %eax,%esi
  8017da:	73 16                	jae    8017f2 <devfile_read+0x48>
  8017dc:	68 f4 26 80 00       	push   $0x8026f4
  8017e1:	68 fb 26 80 00       	push   $0x8026fb
  8017e6:	6a 7c                	push   $0x7c
  8017e8:	68 10 27 80 00       	push   $0x802710
  8017ed:	e8 c6 05 00 00       	call   801db8 <_panic>
	assert(r <= PGSIZE);
  8017f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017f7:	7e 16                	jle    80180f <devfile_read+0x65>
  8017f9:	68 1b 27 80 00       	push   $0x80271b
  8017fe:	68 fb 26 80 00       	push   $0x8026fb
  801803:	6a 7d                	push   $0x7d
  801805:	68 10 27 80 00       	push   $0x802710
  80180a:	e8 a9 05 00 00       	call   801db8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	50                   	push   %eax
  801813:	68 00 50 80 00       	push   $0x805000
  801818:	ff 75 0c             	pushl  0xc(%ebp)
  80181b:	e8 bd f0 ff ff       	call   8008dd <memmove>
	return r;
  801820:	83 c4 10             	add    $0x10,%esp
}
  801823:	89 d8                	mov    %ebx,%eax
  801825:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801828:	5b                   	pop    %ebx
  801829:	5e                   	pop    %esi
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	53                   	push   %ebx
  801830:	83 ec 20             	sub    $0x20,%esp
  801833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801836:	53                   	push   %ebx
  801837:	e8 d6 ee ff ff       	call   800712 <strlen>
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801844:	7f 67                	jg     8018ad <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801846:	83 ec 0c             	sub    $0xc,%esp
  801849:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184c:	50                   	push   %eax
  80184d:	e8 8e f8 ff ff       	call   8010e0 <fd_alloc>
  801852:	83 c4 10             	add    $0x10,%esp
		return r;
  801855:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801857:	85 c0                	test   %eax,%eax
  801859:	78 57                	js     8018b2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	53                   	push   %ebx
  80185f:	68 00 50 80 00       	push   $0x805000
  801864:	e8 e2 ee ff ff       	call   80074b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801871:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801874:	b8 01 00 00 00       	mov    $0x1,%eax
  801879:	e8 f6 fd ff ff       	call   801674 <fsipc>
  80187e:	89 c3                	mov    %eax,%ebx
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	85 c0                	test   %eax,%eax
  801885:	79 14                	jns    80189b <open+0x6f>
		fd_close(fd, 0);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	6a 00                	push   $0x0
  80188c:	ff 75 f4             	pushl  -0xc(%ebp)
  80188f:	e8 47 f9 ff ff       	call   8011db <fd_close>
		return r;
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	89 da                	mov    %ebx,%edx
  801899:	eb 17                	jmp    8018b2 <open+0x86>
	}

	return fd2num(fd);
  80189b:	83 ec 0c             	sub    $0xc,%esp
  80189e:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a1:	e8 13 f8 ff ff       	call   8010b9 <fd2num>
  8018a6:	89 c2                	mov    %eax,%edx
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	eb 05                	jmp    8018b2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ad:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018b2:	89 d0                	mov    %edx,%eax
  8018b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8018c9:	e8 a6 fd ff ff       	call   801674 <fsipc>
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	56                   	push   %esi
  8018d4:	53                   	push   %ebx
  8018d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018d8:	83 ec 0c             	sub    $0xc,%esp
  8018db:	ff 75 08             	pushl  0x8(%ebp)
  8018de:	e8 e6 f7 ff ff       	call   8010c9 <fd2data>
  8018e3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018e5:	83 c4 08             	add    $0x8,%esp
  8018e8:	68 27 27 80 00       	push   $0x802727
  8018ed:	53                   	push   %ebx
  8018ee:	e8 58 ee ff ff       	call   80074b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018f3:	8b 46 04             	mov    0x4(%esi),%eax
  8018f6:	2b 06                	sub    (%esi),%eax
  8018f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801905:	00 00 00 
	stat->st_dev = &devpipe;
  801908:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80190f:	30 80 00 
	return 0;
}
  801912:	b8 00 00 00 00       	mov    $0x0,%eax
  801917:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801928:	53                   	push   %ebx
  801929:	6a 00                	push   $0x0
  80192b:	e8 a3 f2 ff ff       	call   800bd3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801930:	89 1c 24             	mov    %ebx,(%esp)
  801933:	e8 91 f7 ff ff       	call   8010c9 <fd2data>
  801938:	83 c4 08             	add    $0x8,%esp
  80193b:	50                   	push   %eax
  80193c:	6a 00                	push   $0x0
  80193e:	e8 90 f2 ff ff       	call   800bd3 <sys_page_unmap>
}
  801943:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	57                   	push   %edi
  80194c:	56                   	push   %esi
  80194d:	53                   	push   %ebx
  80194e:	83 ec 1c             	sub    $0x1c,%esp
  801951:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801954:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801956:	a1 04 40 80 00       	mov    0x804004,%eax
  80195b:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801961:	83 ec 0c             	sub    $0xc,%esp
  801964:	ff 75 e0             	pushl  -0x20(%ebp)
  801967:	e8 43 06 00 00       	call   801faf <pageref>
  80196c:	89 c3                	mov    %eax,%ebx
  80196e:	89 3c 24             	mov    %edi,(%esp)
  801971:	e8 39 06 00 00       	call   801faf <pageref>
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	39 c3                	cmp    %eax,%ebx
  80197b:	0f 94 c1             	sete   %cl
  80197e:	0f b6 c9             	movzbl %cl,%ecx
  801981:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801984:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80198a:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801990:	39 ce                	cmp    %ecx,%esi
  801992:	74 1e                	je     8019b2 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801994:	39 c3                	cmp    %eax,%ebx
  801996:	75 be                	jne    801956 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801998:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80199e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a1:	50                   	push   %eax
  8019a2:	56                   	push   %esi
  8019a3:	68 2e 27 80 00       	push   $0x80272e
  8019a8:	e8 19 e8 ff ff       	call   8001c6 <cprintf>
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	eb a4                	jmp    801956 <_pipeisclosed+0xe>
	}
}
  8019b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5f                   	pop    %edi
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    

008019bd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	57                   	push   %edi
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 28             	sub    $0x28,%esp
  8019c6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019c9:	56                   	push   %esi
  8019ca:	e8 fa f6 ff ff       	call   8010c9 <fd2data>
  8019cf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d9:	eb 4b                	jmp    801a26 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019db:	89 da                	mov    %ebx,%edx
  8019dd:	89 f0                	mov    %esi,%eax
  8019df:	e8 64 ff ff ff       	call   801948 <_pipeisclosed>
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	75 48                	jne    801a30 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019e8:	e8 42 f1 ff ff       	call   800b2f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019ed:	8b 43 04             	mov    0x4(%ebx),%eax
  8019f0:	8b 0b                	mov    (%ebx),%ecx
  8019f2:	8d 51 20             	lea    0x20(%ecx),%edx
  8019f5:	39 d0                	cmp    %edx,%eax
  8019f7:	73 e2                	jae    8019db <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a00:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a03:	89 c2                	mov    %eax,%edx
  801a05:	c1 fa 1f             	sar    $0x1f,%edx
  801a08:	89 d1                	mov    %edx,%ecx
  801a0a:	c1 e9 1b             	shr    $0x1b,%ecx
  801a0d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a10:	83 e2 1f             	and    $0x1f,%edx
  801a13:	29 ca                	sub    %ecx,%edx
  801a15:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a19:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a1d:	83 c0 01             	add    $0x1,%eax
  801a20:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a23:	83 c7 01             	add    $0x1,%edi
  801a26:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a29:	75 c2                	jne    8019ed <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2e:	eb 05                	jmp    801a35 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a30:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a38:	5b                   	pop    %ebx
  801a39:	5e                   	pop    %esi
  801a3a:	5f                   	pop    %edi
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    

00801a3d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	57                   	push   %edi
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	83 ec 18             	sub    $0x18,%esp
  801a46:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a49:	57                   	push   %edi
  801a4a:	e8 7a f6 ff ff       	call   8010c9 <fd2data>
  801a4f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a59:	eb 3d                	jmp    801a98 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a5b:	85 db                	test   %ebx,%ebx
  801a5d:	74 04                	je     801a63 <devpipe_read+0x26>
				return i;
  801a5f:	89 d8                	mov    %ebx,%eax
  801a61:	eb 44                	jmp    801aa7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a63:	89 f2                	mov    %esi,%edx
  801a65:	89 f8                	mov    %edi,%eax
  801a67:	e8 dc fe ff ff       	call   801948 <_pipeisclosed>
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	75 32                	jne    801aa2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a70:	e8 ba f0 ff ff       	call   800b2f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a75:	8b 06                	mov    (%esi),%eax
  801a77:	3b 46 04             	cmp    0x4(%esi),%eax
  801a7a:	74 df                	je     801a5b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a7c:	99                   	cltd   
  801a7d:	c1 ea 1b             	shr    $0x1b,%edx
  801a80:	01 d0                	add    %edx,%eax
  801a82:	83 e0 1f             	and    $0x1f,%eax
  801a85:	29 d0                	sub    %edx,%eax
  801a87:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a92:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a95:	83 c3 01             	add    $0x1,%ebx
  801a98:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a9b:	75 d8                	jne    801a75 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa0:	eb 05                	jmp    801aa7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801aa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5f                   	pop    %edi
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ab7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aba:	50                   	push   %eax
  801abb:	e8 20 f6 ff ff       	call   8010e0 <fd_alloc>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	89 c2                	mov    %eax,%edx
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	0f 88 2c 01 00 00    	js     801bf9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	68 07 04 00 00       	push   $0x407
  801ad5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 6f f0 ff ff       	call   800b4e <sys_page_alloc>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	89 c2                	mov    %eax,%edx
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	0f 88 0d 01 00 00    	js     801bf9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aec:	83 ec 0c             	sub    $0xc,%esp
  801aef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af2:	50                   	push   %eax
  801af3:	e8 e8 f5 ff ff       	call   8010e0 <fd_alloc>
  801af8:	89 c3                	mov    %eax,%ebx
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	85 c0                	test   %eax,%eax
  801aff:	0f 88 e2 00 00 00    	js     801be7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b05:	83 ec 04             	sub    $0x4,%esp
  801b08:	68 07 04 00 00       	push   $0x407
  801b0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801b10:	6a 00                	push   $0x0
  801b12:	e8 37 f0 ff ff       	call   800b4e <sys_page_alloc>
  801b17:	89 c3                	mov    %eax,%ebx
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	0f 88 c3 00 00 00    	js     801be7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2a:	e8 9a f5 ff ff       	call   8010c9 <fd2data>
  801b2f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b31:	83 c4 0c             	add    $0xc,%esp
  801b34:	68 07 04 00 00       	push   $0x407
  801b39:	50                   	push   %eax
  801b3a:	6a 00                	push   $0x0
  801b3c:	e8 0d f0 ff ff       	call   800b4e <sys_page_alloc>
  801b41:	89 c3                	mov    %eax,%ebx
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	85 c0                	test   %eax,%eax
  801b48:	0f 88 89 00 00 00    	js     801bd7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4e:	83 ec 0c             	sub    $0xc,%esp
  801b51:	ff 75 f0             	pushl  -0x10(%ebp)
  801b54:	e8 70 f5 ff ff       	call   8010c9 <fd2data>
  801b59:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b60:	50                   	push   %eax
  801b61:	6a 00                	push   $0x0
  801b63:	56                   	push   %esi
  801b64:	6a 00                	push   $0x0
  801b66:	e8 26 f0 ff ff       	call   800b91 <sys_page_map>
  801b6b:	89 c3                	mov    %eax,%ebx
  801b6d:	83 c4 20             	add    $0x20,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 55                	js     801bc9 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b74:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b82:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b89:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b92:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b97:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b9e:	83 ec 0c             	sub    $0xc,%esp
  801ba1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba4:	e8 10 f5 ff ff       	call   8010b9 <fd2num>
  801ba9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bac:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bae:	83 c4 04             	add    $0x4,%esp
  801bb1:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb4:	e8 00 f5 ff ff       	call   8010b9 <fd2num>
  801bb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbc:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc7:	eb 30                	jmp    801bf9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bc9:	83 ec 08             	sub    $0x8,%esp
  801bcc:	56                   	push   %esi
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 ff ef ff ff       	call   800bd3 <sys_page_unmap>
  801bd4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bd7:	83 ec 08             	sub    $0x8,%esp
  801bda:	ff 75 f0             	pushl  -0x10(%ebp)
  801bdd:	6a 00                	push   $0x0
  801bdf:	e8 ef ef ff ff       	call   800bd3 <sys_page_unmap>
  801be4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801be7:	83 ec 08             	sub    $0x8,%esp
  801bea:	ff 75 f4             	pushl  -0xc(%ebp)
  801bed:	6a 00                	push   $0x0
  801bef:	e8 df ef ff ff       	call   800bd3 <sys_page_unmap>
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bf9:	89 d0                	mov    %edx,%eax
  801bfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	ff 75 08             	pushl  0x8(%ebp)
  801c0f:	e8 1b f5 ff ff       	call   80112f <fd_lookup>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	85 c0                	test   %eax,%eax
  801c19:	78 18                	js     801c33 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c21:	e8 a3 f4 ff ff       	call   8010c9 <fd2data>
	return _pipeisclosed(fd, p);
  801c26:	89 c2                	mov    %eax,%edx
  801c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2b:	e8 18 fd ff ff       	call   801948 <_pipeisclosed>
  801c30:	83 c4 10             	add    $0x10,%esp
}
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c45:	68 46 27 80 00       	push   $0x802746
  801c4a:	ff 75 0c             	pushl  0xc(%ebp)
  801c4d:	e8 f9 ea ff ff       	call   80074b <strcpy>
	return 0;
}
  801c52:	b8 00 00 00 00       	mov    $0x0,%eax
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    

00801c59 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	57                   	push   %edi
  801c5d:	56                   	push   %esi
  801c5e:	53                   	push   %ebx
  801c5f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c65:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c6a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c70:	eb 2d                	jmp    801c9f <devcons_write+0x46>
		m = n - tot;
  801c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c75:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c77:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c7a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c7f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c82:	83 ec 04             	sub    $0x4,%esp
  801c85:	53                   	push   %ebx
  801c86:	03 45 0c             	add    0xc(%ebp),%eax
  801c89:	50                   	push   %eax
  801c8a:	57                   	push   %edi
  801c8b:	e8 4d ec ff ff       	call   8008dd <memmove>
		sys_cputs(buf, m);
  801c90:	83 c4 08             	add    $0x8,%esp
  801c93:	53                   	push   %ebx
  801c94:	57                   	push   %edi
  801c95:	e8 f8 ed ff ff       	call   800a92 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c9a:	01 de                	add    %ebx,%esi
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	89 f0                	mov    %esi,%eax
  801ca1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ca4:	72 cc                	jb     801c72 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca9:	5b                   	pop    %ebx
  801caa:	5e                   	pop    %esi
  801cab:	5f                   	pop    %edi
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	83 ec 08             	sub    $0x8,%esp
  801cb4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cb9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cbd:	74 2a                	je     801ce9 <devcons_read+0x3b>
  801cbf:	eb 05                	jmp    801cc6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cc1:	e8 69 ee ff ff       	call   800b2f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cc6:	e8 e5 ed ff ff       	call   800ab0 <sys_cgetc>
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	74 f2                	je     801cc1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 16                	js     801ce9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cd3:	83 f8 04             	cmp    $0x4,%eax
  801cd6:	74 0c                	je     801ce4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdb:	88 02                	mov    %al,(%edx)
	return 1;
  801cdd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce2:	eb 05                	jmp    801ce9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ce4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cf7:	6a 01                	push   $0x1
  801cf9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cfc:	50                   	push   %eax
  801cfd:	e8 90 ed ff ff       	call   800a92 <sys_cputs>
}
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    

00801d07 <getchar>:

int
getchar(void)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d0d:	6a 01                	push   $0x1
  801d0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d12:	50                   	push   %eax
  801d13:	6a 00                	push   $0x0
  801d15:	e8 7e f6 ff ff       	call   801398 <read>
	if (r < 0)
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 0f                	js     801d30 <getchar+0x29>
		return r;
	if (r < 1)
  801d21:	85 c0                	test   %eax,%eax
  801d23:	7e 06                	jle    801d2b <getchar+0x24>
		return -E_EOF;
	return c;
  801d25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d29:	eb 05                	jmp    801d30 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d2b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3b:	50                   	push   %eax
  801d3c:	ff 75 08             	pushl  0x8(%ebp)
  801d3f:	e8 eb f3 ff ff       	call   80112f <fd_lookup>
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 11                	js     801d5c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d54:	39 10                	cmp    %edx,(%eax)
  801d56:	0f 94 c0             	sete   %al
  801d59:	0f b6 c0             	movzbl %al,%eax
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <opencons>:

int
opencons(void)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d67:	50                   	push   %eax
  801d68:	e8 73 f3 ff ff       	call   8010e0 <fd_alloc>
  801d6d:	83 c4 10             	add    $0x10,%esp
		return r;
  801d70:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d72:	85 c0                	test   %eax,%eax
  801d74:	78 3e                	js     801db4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d76:	83 ec 04             	sub    $0x4,%esp
  801d79:	68 07 04 00 00       	push   $0x407
  801d7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d81:	6a 00                	push   $0x0
  801d83:	e8 c6 ed ff ff       	call   800b4e <sys_page_alloc>
  801d88:	83 c4 10             	add    $0x10,%esp
		return r;
  801d8b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 23                	js     801db4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d91:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da6:	83 ec 0c             	sub    $0xc,%esp
  801da9:	50                   	push   %eax
  801daa:	e8 0a f3 ff ff       	call   8010b9 <fd2num>
  801daf:	89 c2                	mov    %eax,%edx
  801db1:	83 c4 10             	add    $0x10,%esp
}
  801db4:	89 d0                	mov    %edx,%eax
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dbd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dc0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dc6:	e8 45 ed ff ff       	call   800b10 <sys_getenvid>
  801dcb:	83 ec 0c             	sub    $0xc,%esp
  801dce:	ff 75 0c             	pushl  0xc(%ebp)
  801dd1:	ff 75 08             	pushl  0x8(%ebp)
  801dd4:	56                   	push   %esi
  801dd5:	50                   	push   %eax
  801dd6:	68 54 27 80 00       	push   $0x802754
  801ddb:	e8 e6 e3 ff ff       	call   8001c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801de0:	83 c4 18             	add    $0x18,%esp
  801de3:	53                   	push   %ebx
  801de4:	ff 75 10             	pushl  0x10(%ebp)
  801de7:	e8 89 e3 ff ff       	call   800175 <vcprintf>
	cprintf("\n");
  801dec:	c7 04 24 a5 22 80 00 	movl   $0x8022a5,(%esp)
  801df3:	e8 ce e3 ff ff       	call   8001c6 <cprintf>
  801df8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dfb:	cc                   	int3   
  801dfc:	eb fd                	jmp    801dfb <_panic+0x43>

00801dfe <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e04:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e0b:	75 2a                	jne    801e37 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801e0d:	83 ec 04             	sub    $0x4,%esp
  801e10:	6a 07                	push   $0x7
  801e12:	68 00 f0 bf ee       	push   $0xeebff000
  801e17:	6a 00                	push   $0x0
  801e19:	e8 30 ed ff ff       	call   800b4e <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	85 c0                	test   %eax,%eax
  801e23:	79 12                	jns    801e37 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e25:	50                   	push   %eax
  801e26:	68 78 27 80 00       	push   $0x802778
  801e2b:	6a 23                	push   $0x23
  801e2d:	68 7c 27 80 00       	push   $0x80277c
  801e32:	e8 81 ff ff ff       	call   801db8 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e3f:	83 ec 08             	sub    $0x8,%esp
  801e42:	68 69 1e 80 00       	push   $0x801e69
  801e47:	6a 00                	push   $0x0
  801e49:	e8 4b ee ff ff       	call   800c99 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	85 c0                	test   %eax,%eax
  801e53:	79 12                	jns    801e67 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e55:	50                   	push   %eax
  801e56:	68 78 27 80 00       	push   $0x802778
  801e5b:	6a 2c                	push   $0x2c
  801e5d:	68 7c 27 80 00       	push   $0x80277c
  801e62:	e8 51 ff ff ff       	call   801db8 <_panic>
	}
}
  801e67:	c9                   	leave  
  801e68:	c3                   	ret    

00801e69 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e69:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e6a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e6f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e71:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e74:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e78:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e7d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e81:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e83:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e86:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e87:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e8a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e8b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e8c:	c3                   	ret    

00801e8d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	8b 75 08             	mov    0x8(%ebp),%esi
  801e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	75 12                	jne    801eb1 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	68 00 00 c0 ee       	push   $0xeec00000
  801ea7:	e8 52 ee ff ff       	call   800cfe <sys_ipc_recv>
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	eb 0c                	jmp    801ebd <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801eb1:	83 ec 0c             	sub    $0xc,%esp
  801eb4:	50                   	push   %eax
  801eb5:	e8 44 ee ff ff       	call   800cfe <sys_ipc_recv>
  801eba:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ebd:	85 f6                	test   %esi,%esi
  801ebf:	0f 95 c1             	setne  %cl
  801ec2:	85 db                	test   %ebx,%ebx
  801ec4:	0f 95 c2             	setne  %dl
  801ec7:	84 d1                	test   %dl,%cl
  801ec9:	74 09                	je     801ed4 <ipc_recv+0x47>
  801ecb:	89 c2                	mov    %eax,%edx
  801ecd:	c1 ea 1f             	shr    $0x1f,%edx
  801ed0:	84 d2                	test   %dl,%dl
  801ed2:	75 2d                	jne    801f01 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ed4:	85 f6                	test   %esi,%esi
  801ed6:	74 0d                	je     801ee5 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801ed8:	a1 04 40 80 00       	mov    0x804004,%eax
  801edd:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801ee3:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ee5:	85 db                	test   %ebx,%ebx
  801ee7:	74 0d                	je     801ef6 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ee9:	a1 04 40 80 00       	mov    0x804004,%eax
  801eee:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801ef4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ef6:	a1 04 40 80 00       	mov    0x804004,%eax
  801efb:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801f01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f04:	5b                   	pop    %ebx
  801f05:	5e                   	pop    %esi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	57                   	push   %edi
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
  801f0e:	83 ec 0c             	sub    $0xc,%esp
  801f11:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f14:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801f1a:	85 db                	test   %ebx,%ebx
  801f1c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f21:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f24:	ff 75 14             	pushl  0x14(%ebp)
  801f27:	53                   	push   %ebx
  801f28:	56                   	push   %esi
  801f29:	57                   	push   %edi
  801f2a:	e8 ac ed ff ff       	call   800cdb <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f2f:	89 c2                	mov    %eax,%edx
  801f31:	c1 ea 1f             	shr    $0x1f,%edx
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	84 d2                	test   %dl,%dl
  801f39:	74 17                	je     801f52 <ipc_send+0x4a>
  801f3b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f3e:	74 12                	je     801f52 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f40:	50                   	push   %eax
  801f41:	68 8a 27 80 00       	push   $0x80278a
  801f46:	6a 47                	push   $0x47
  801f48:	68 98 27 80 00       	push   $0x802798
  801f4d:	e8 66 fe ff ff       	call   801db8 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f52:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f55:	75 07                	jne    801f5e <ipc_send+0x56>
			sys_yield();
  801f57:	e8 d3 eb ff ff       	call   800b2f <sys_yield>
  801f5c:	eb c6                	jmp    801f24 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	75 c2                	jne    801f24 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f65:	5b                   	pop    %ebx
  801f66:	5e                   	pop    %esi
  801f67:	5f                   	pop    %edi
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f70:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f75:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f7b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f81:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f87:	39 ca                	cmp    %ecx,%edx
  801f89:	75 13                	jne    801f9e <ipc_find_env+0x34>
			return envs[i].env_id;
  801f8b:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f91:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f96:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f9c:	eb 0f                	jmp    801fad <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f9e:	83 c0 01             	add    $0x1,%eax
  801fa1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa6:	75 cd                	jne    801f75 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    

00801faf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb5:	89 d0                	mov    %edx,%eax
  801fb7:	c1 e8 16             	shr    $0x16,%eax
  801fba:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc6:	f6 c1 01             	test   $0x1,%cl
  801fc9:	74 1d                	je     801fe8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fcb:	c1 ea 0c             	shr    $0xc,%edx
  801fce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd5:	f6 c2 01             	test   $0x1,%dl
  801fd8:	74 0e                	je     801fe8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fda:	c1 ea 0c             	shr    $0xc,%edx
  801fdd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe4:	ef 
  801fe5:	0f b7 c0             	movzwl %ax,%eax
}
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
