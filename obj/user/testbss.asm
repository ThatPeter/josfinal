
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 20 25 80 00       	push   $0x802520
  80003e:	e8 f5 01 00 00       	call   800238 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 9b 25 80 00       	push   $0x80259b
  80005b:	6a 11                	push   $0x11
  80005d:	68 b8 25 80 00       	push   $0x8025b8
  800062:	e8 f8 00 00 00       	call   80015f <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 40 25 80 00       	push   $0x802540
  80009b:	6a 16                	push   $0x16
  80009d:	68 b8 25 80 00       	push   $0x8025b8
  8000a2:	e8 b8 00 00 00       	call   80015f <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 68 25 80 00       	push   $0x802568
  8000b9:	e8 7a 01 00 00       	call   800238 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 c7 25 80 00       	push   $0x8025c7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 b8 25 80 00       	push   $0x8025b8
  8000d7:	e8 83 00 00 00       	call   80015f <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e7:	e8 96 0a 00 00       	call   800b82 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8000f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fc:	a3 20 40 c0 00       	mov    %eax,0xc04020
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800101:	85 db                	test   %ebx,%ebx
  800103:	7e 07                	jle    80010c <libmain+0x30>
		binaryname = argv[0];
  800105:	8b 06                	mov    (%esi),%eax
  800107:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	e8 1d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800116:	e8 2a 00 00 00       	call   800145 <exit>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80012b:	a1 24 40 c0 00       	mov    0xc04024,%eax
	func();
  800130:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800132:	e8 4b 0a 00 00       	call   800b82 <sys_getenvid>
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	50                   	push   %eax
  80013b:	e8 91 0c 00 00       	call   800dd1 <sys_thread_free>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014b:	e8 0b 14 00 00       	call   80155b <close_all>
	sys_env_destroy(0);
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	6a 00                	push   $0x0
  800155:	e8 e7 09 00 00       	call   800b41 <sys_env_destroy>
}
  80015a:	83 c4 10             	add    $0x10,%esp
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800164:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800167:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80016d:	e8 10 0a 00 00       	call   800b82 <sys_getenvid>
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	56                   	push   %esi
  80017c:	50                   	push   %eax
  80017d:	68 e8 25 80 00       	push   $0x8025e8
  800182:	e8 b1 00 00 00       	call   800238 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800187:	83 c4 18             	add    $0x18,%esp
  80018a:	53                   	push   %ebx
  80018b:	ff 75 10             	pushl  0x10(%ebp)
  80018e:	e8 54 00 00 00       	call   8001e7 <vcprintf>
	cprintf("\n");
  800193:	c7 04 24 b6 25 80 00 	movl   $0x8025b6,(%esp)
  80019a:	e8 99 00 00 00       	call   800238 <cprintf>
  80019f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a2:	cc                   	int3   
  8001a3:	eb fd                	jmp    8001a2 <_panic+0x43>

008001a5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001af:	8b 13                	mov    (%ebx),%edx
  8001b1:	8d 42 01             	lea    0x1(%edx),%eax
  8001b4:	89 03                	mov    %eax,(%ebx)
  8001b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c2:	75 1a                	jne    8001de <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c4:	83 ec 08             	sub    $0x8,%esp
  8001c7:	68 ff 00 00 00       	push   $0xff
  8001cc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cf:	50                   	push   %eax
  8001d0:	e8 2f 09 00 00       	call   800b04 <sys_cputs>
		b->idx = 0;
  8001d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001db:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001de:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f7:	00 00 00 
	b.cnt = 0;
  8001fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800201:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800204:	ff 75 0c             	pushl  0xc(%ebp)
  800207:	ff 75 08             	pushl  0x8(%ebp)
  80020a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	68 a5 01 80 00       	push   $0x8001a5
  800216:	e8 54 01 00 00       	call   80036f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021b:	83 c4 08             	add    $0x8,%esp
  80021e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800224:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022a:	50                   	push   %eax
  80022b:	e8 d4 08 00 00       	call   800b04 <sys_cputs>

	return b.cnt;
}
  800230:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800241:	50                   	push   %eax
  800242:	ff 75 08             	pushl  0x8(%ebp)
  800245:	e8 9d ff ff ff       	call   8001e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 1c             	sub    $0x1c,%esp
  800255:	89 c7                	mov    %eax,%edi
  800257:	89 d6                	mov    %edx,%esi
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800262:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800265:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800270:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800273:	39 d3                	cmp    %edx,%ebx
  800275:	72 05                	jb     80027c <printnum+0x30>
  800277:	39 45 10             	cmp    %eax,0x10(%ebp)
  80027a:	77 45                	ja     8002c1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027c:	83 ec 0c             	sub    $0xc,%esp
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	8b 45 14             	mov    0x14(%ebp),%eax
  800285:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800288:	53                   	push   %ebx
  800289:	ff 75 10             	pushl  0x10(%ebp)
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800292:	ff 75 e0             	pushl  -0x20(%ebp)
  800295:	ff 75 dc             	pushl  -0x24(%ebp)
  800298:	ff 75 d8             	pushl  -0x28(%ebp)
  80029b:	e8 e0 1f 00 00       	call   802280 <__udivdi3>
  8002a0:	83 c4 18             	add    $0x18,%esp
  8002a3:	52                   	push   %edx
  8002a4:	50                   	push   %eax
  8002a5:	89 f2                	mov    %esi,%edx
  8002a7:	89 f8                	mov    %edi,%eax
  8002a9:	e8 9e ff ff ff       	call   80024c <printnum>
  8002ae:	83 c4 20             	add    $0x20,%esp
  8002b1:	eb 18                	jmp    8002cb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	56                   	push   %esi
  8002b7:	ff 75 18             	pushl  0x18(%ebp)
  8002ba:	ff d7                	call   *%edi
  8002bc:	83 c4 10             	add    $0x10,%esp
  8002bf:	eb 03                	jmp    8002c4 <printnum+0x78>
  8002c1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c4:	83 eb 01             	sub    $0x1,%ebx
  8002c7:	85 db                	test   %ebx,%ebx
  8002c9:	7f e8                	jg     8002b3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cb:	83 ec 08             	sub    $0x8,%esp
  8002ce:	56                   	push   %esi
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002db:	ff 75 d8             	pushl  -0x28(%ebp)
  8002de:	e8 cd 20 00 00       	call   8023b0 <__umoddi3>
  8002e3:	83 c4 14             	add    $0x14,%esp
  8002e6:	0f be 80 0b 26 80 00 	movsbl 0x80260b(%eax),%eax
  8002ed:	50                   	push   %eax
  8002ee:	ff d7                	call   *%edi
}
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fe:	83 fa 01             	cmp    $0x1,%edx
  800301:	7e 0e                	jle    800311 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 08             	lea    0x8(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	8b 52 04             	mov    0x4(%edx),%edx
  80030f:	eb 22                	jmp    800333 <getuint+0x38>
	else if (lflag)
  800311:	85 d2                	test   %edx,%edx
  800313:	74 10                	je     800325 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800315:	8b 10                	mov    (%eax),%edx
  800317:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031a:	89 08                	mov    %ecx,(%eax)
  80031c:	8b 02                	mov    (%edx),%eax
  80031e:	ba 00 00 00 00       	mov    $0x0,%edx
  800323:	eb 0e                	jmp    800333 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800325:	8b 10                	mov    (%eax),%edx
  800327:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032a:	89 08                	mov    %ecx,(%eax)
  80032c:	8b 02                	mov    (%edx),%eax
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	3b 50 04             	cmp    0x4(%eax),%edx
  800344:	73 0a                	jae    800350 <sprintputch+0x1b>
		*b->buf++ = ch;
  800346:	8d 4a 01             	lea    0x1(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 45 08             	mov    0x8(%ebp),%eax
  80034e:	88 02                	mov    %al,(%edx)
}
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800358:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035b:	50                   	push   %eax
  80035c:	ff 75 10             	pushl  0x10(%ebp)
  80035f:	ff 75 0c             	pushl  0xc(%ebp)
  800362:	ff 75 08             	pushl  0x8(%ebp)
  800365:	e8 05 00 00 00       	call   80036f <vprintfmt>
	va_end(ap);
}
  80036a:	83 c4 10             	add    $0x10,%esp
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	57                   	push   %edi
  800373:	56                   	push   %esi
  800374:	53                   	push   %ebx
  800375:	83 ec 2c             	sub    $0x2c,%esp
  800378:	8b 75 08             	mov    0x8(%ebp),%esi
  80037b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800381:	eb 12                	jmp    800395 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800383:	85 c0                	test   %eax,%eax
  800385:	0f 84 89 03 00 00    	je     800714 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80038b:	83 ec 08             	sub    $0x8,%esp
  80038e:	53                   	push   %ebx
  80038f:	50                   	push   %eax
  800390:	ff d6                	call   *%esi
  800392:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800395:	83 c7 01             	add    $0x1,%edi
  800398:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039c:	83 f8 25             	cmp    $0x25,%eax
  80039f:	75 e2                	jne    800383 <vprintfmt+0x14>
  8003a1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bf:	eb 07                	jmp    8003c8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8d 47 01             	lea    0x1(%edi),%eax
  8003cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ce:	0f b6 07             	movzbl (%edi),%eax
  8003d1:	0f b6 c8             	movzbl %al,%ecx
  8003d4:	83 e8 23             	sub    $0x23,%eax
  8003d7:	3c 55                	cmp    $0x55,%al
  8003d9:	0f 87 1a 03 00 00    	ja     8006f9 <vprintfmt+0x38a>
  8003df:	0f b6 c0             	movzbl %al,%eax
  8003e2:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ec:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f0:	eb d6                	jmp    8003c8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800400:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800404:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800407:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040a:	83 fa 09             	cmp    $0x9,%edx
  80040d:	77 39                	ja     800448 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800412:	eb e9                	jmp    8003fd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 48 04             	lea    0x4(%eax),%ecx
  80041a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800425:	eb 27                	jmp    80044e <vprintfmt+0xdf>
  800427:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042a:	85 c0                	test   %eax,%eax
  80042c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800431:	0f 49 c8             	cmovns %eax,%ecx
  800434:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043a:	eb 8c                	jmp    8003c8 <vprintfmt+0x59>
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800446:	eb 80                	jmp    8003c8 <vprintfmt+0x59>
  800448:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800452:	0f 89 70 ff ff ff    	jns    8003c8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800458:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800465:	e9 5e ff ff ff       	jmp    8003c8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800470:	e9 53 ff ff ff       	jmp    8003c8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 50 04             	lea    0x4(%eax),%edx
  80047b:	89 55 14             	mov    %edx,0x14(%ebp)
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	53                   	push   %ebx
  800482:	ff 30                	pushl  (%eax)
  800484:	ff d6                	call   *%esi
			break;
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048c:	e9 04 ff ff ff       	jmp    800395 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	99                   	cltd   
  80049d:	31 d0                	xor    %edx,%eax
  80049f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a1:	83 f8 0f             	cmp    $0xf,%eax
  8004a4:	7f 0b                	jg     8004b1 <vprintfmt+0x142>
  8004a6:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  8004ad:	85 d2                	test   %edx,%edx
  8004af:	75 18                	jne    8004c9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004b1:	50                   	push   %eax
  8004b2:	68 23 26 80 00       	push   $0x802623
  8004b7:	53                   	push   %ebx
  8004b8:	56                   	push   %esi
  8004b9:	e8 94 fe ff ff       	call   800352 <printfmt>
  8004be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c4:	e9 cc fe ff ff       	jmp    800395 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c9:	52                   	push   %edx
  8004ca:	68 31 2b 80 00       	push   $0x802b31
  8004cf:	53                   	push   %ebx
  8004d0:	56                   	push   %esi
  8004d1:	e8 7c fe ff ff       	call   800352 <printfmt>
  8004d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004dc:	e9 b4 fe ff ff       	jmp    800395 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	b8 1c 26 80 00       	mov    $0x80261c,%eax
  8004f3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fa:	0f 8e 94 00 00 00    	jle    800594 <vprintfmt+0x225>
  800500:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800504:	0f 84 98 00 00 00    	je     8005a2 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 d0             	pushl  -0x30(%ebp)
  800510:	57                   	push   %edi
  800511:	e8 86 02 00 00       	call   80079c <strnlen>
  800516:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800519:	29 c1                	sub    %eax,%ecx
  80051b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80051e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800521:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800525:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800528:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052d:	eb 0f                	jmp    80053e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	53                   	push   %ebx
  800533:	ff 75 e0             	pushl  -0x20(%ebp)
  800536:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	83 ef 01             	sub    $0x1,%edi
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	85 ff                	test   %edi,%edi
  800540:	7f ed                	jg     80052f <vprintfmt+0x1c0>
  800542:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800545:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800548:	85 c9                	test   %ecx,%ecx
  80054a:	b8 00 00 00 00       	mov    $0x0,%eax
  80054f:	0f 49 c1             	cmovns %ecx,%eax
  800552:	29 c1                	sub    %eax,%ecx
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	89 cb                	mov    %ecx,%ebx
  80055f:	eb 4d                	jmp    8005ae <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800561:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800565:	74 1b                	je     800582 <vprintfmt+0x213>
  800567:	0f be c0             	movsbl %al,%eax
  80056a:	83 e8 20             	sub    $0x20,%eax
  80056d:	83 f8 5e             	cmp    $0x5e,%eax
  800570:	76 10                	jbe    800582 <vprintfmt+0x213>
					putch('?', putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	ff 75 0c             	pushl  0xc(%ebp)
  800578:	6a 3f                	push   $0x3f
  80057a:	ff 55 08             	call   *0x8(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	eb 0d                	jmp    80058f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	ff 75 0c             	pushl  0xc(%ebp)
  800588:	52                   	push   %edx
  800589:	ff 55 08             	call   *0x8(%ebp)
  80058c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058f:	83 eb 01             	sub    $0x1,%ebx
  800592:	eb 1a                	jmp    8005ae <vprintfmt+0x23f>
  800594:	89 75 08             	mov    %esi,0x8(%ebp)
  800597:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a0:	eb 0c                	jmp    8005ae <vprintfmt+0x23f>
  8005a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ae:	83 c7 01             	add    $0x1,%edi
  8005b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b5:	0f be d0             	movsbl %al,%edx
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	74 23                	je     8005df <vprintfmt+0x270>
  8005bc:	85 f6                	test   %esi,%esi
  8005be:	78 a1                	js     800561 <vprintfmt+0x1f2>
  8005c0:	83 ee 01             	sub    $0x1,%esi
  8005c3:	79 9c                	jns    800561 <vprintfmt+0x1f2>
  8005c5:	89 df                	mov    %ebx,%edi
  8005c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cd:	eb 18                	jmp    8005e7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 20                	push   $0x20
  8005d5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d7:	83 ef 01             	sub    $0x1,%edi
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	eb 08                	jmp    8005e7 <vprintfmt+0x278>
  8005df:	89 df                	mov    %ebx,%edi
  8005e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e7:	85 ff                	test   %edi,%edi
  8005e9:	7f e4                	jg     8005cf <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ee:	e9 a2 fd ff ff       	jmp    800395 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f3:	83 fa 01             	cmp    $0x1,%edx
  8005f6:	7e 16                	jle    80060e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 08             	lea    0x8(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 50 04             	mov    0x4(%eax),%edx
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060c:	eb 32                	jmp    800640 <vprintfmt+0x2d1>
	else if (lflag)
  80060e:	85 d2                	test   %edx,%edx
  800610:	74 18                	je     80062a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800620:	89 c1                	mov    %eax,%ecx
  800622:	c1 f9 1f             	sar    $0x1f,%ecx
  800625:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800628:	eb 16                	jmp    800640 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	8b 00                	mov    (%eax),%eax
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	89 c1                	mov    %eax,%ecx
  80063a:	c1 f9 1f             	sar    $0x1f,%ecx
  80063d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800640:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800643:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800646:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064f:	79 74                	jns    8006c5 <vprintfmt+0x356>
				putch('-', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 2d                	push   $0x2d
  800657:	ff d6                	call   *%esi
				num = -(long long) num;
  800659:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065f:	f7 d8                	neg    %eax
  800661:	83 d2 00             	adc    $0x0,%edx
  800664:	f7 da                	neg    %edx
  800666:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800669:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066e:	eb 55                	jmp    8006c5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800670:	8d 45 14             	lea    0x14(%ebp),%eax
  800673:	e8 83 fc ff ff       	call   8002fb <getuint>
			base = 10;
  800678:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067d:	eb 46                	jmp    8006c5 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 74 fc ff ff       	call   8002fb <getuint>
			base = 8;
  800687:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80068c:	eb 37                	jmp    8006c5 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 30                	push   $0x30
  800694:	ff d6                	call   *%esi
			putch('x', putdat);
  800696:	83 c4 08             	add    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 78                	push   $0x78
  80069c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ae:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b6:	eb 0d                	jmp    8006c5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bb:	e8 3b fc ff ff       	call   8002fb <getuint>
			base = 16;
  8006c0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c5:	83 ec 0c             	sub    $0xc,%esp
  8006c8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cc:	57                   	push   %edi
  8006cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d0:	51                   	push   %ecx
  8006d1:	52                   	push   %edx
  8006d2:	50                   	push   %eax
  8006d3:	89 da                	mov    %ebx,%edx
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	e8 70 fb ff ff       	call   80024c <printnum>
			break;
  8006dc:	83 c4 20             	add    $0x20,%esp
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e2:	e9 ae fc ff ff       	jmp    800395 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	51                   	push   %ecx
  8006ec:	ff d6                	call   *%esi
			break;
  8006ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f4:	e9 9c fc ff ff       	jmp    800395 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	6a 25                	push   $0x25
  8006ff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb 03                	jmp    800709 <vprintfmt+0x39a>
  800706:	83 ef 01             	sub    $0x1,%edi
  800709:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070d:	75 f7                	jne    800706 <vprintfmt+0x397>
  80070f:	e9 81 fc ff ff       	jmp    800395 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800714:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800717:	5b                   	pop    %ebx
  800718:	5e                   	pop    %esi
  800719:	5f                   	pop    %edi
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 18             	sub    $0x18,%esp
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800728:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800732:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800739:	85 c0                	test   %eax,%eax
  80073b:	74 26                	je     800763 <vsnprintf+0x47>
  80073d:	85 d2                	test   %edx,%edx
  80073f:	7e 22                	jle    800763 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800741:	ff 75 14             	pushl  0x14(%ebp)
  800744:	ff 75 10             	pushl  0x10(%ebp)
  800747:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074a:	50                   	push   %eax
  80074b:	68 35 03 80 00       	push   $0x800335
  800750:	e8 1a fc ff ff       	call   80036f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800755:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800758:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	eb 05                	jmp    800768 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800763:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800770:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800773:	50                   	push   %eax
  800774:	ff 75 10             	pushl  0x10(%ebp)
  800777:	ff 75 0c             	pushl  0xc(%ebp)
  80077a:	ff 75 08             	pushl  0x8(%ebp)
  80077d:	e8 9a ff ff ff       	call   80071c <vsnprintf>
	va_end(ap);

	return rc;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
  80078f:	eb 03                	jmp    800794 <strlen+0x10>
		n++;
  800791:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800794:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800798:	75 f7                	jne    800791 <strlen+0xd>
		n++;
	return n;
}
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007aa:	eb 03                	jmp    8007af <strnlen+0x13>
		n++;
  8007ac:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007af:	39 c2                	cmp    %eax,%edx
  8007b1:	74 08                	je     8007bb <strnlen+0x1f>
  8007b3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b7:	75 f3                	jne    8007ac <strnlen+0x10>
  8007b9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	53                   	push   %ebx
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	83 c2 01             	add    $0x1,%edx
  8007cc:	83 c1 01             	add    $0x1,%ecx
  8007cf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d6:	84 db                	test   %bl,%bl
  8007d8:	75 ef                	jne    8007c9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007da:	5b                   	pop    %ebx
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e4:	53                   	push   %ebx
  8007e5:	e8 9a ff ff ff       	call   800784 <strlen>
  8007ea:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ed:	ff 75 0c             	pushl  0xc(%ebp)
  8007f0:	01 d8                	add    %ebx,%eax
  8007f2:	50                   	push   %eax
  8007f3:	e8 c5 ff ff ff       	call   8007bd <strcpy>
	return dst;
}
  8007f8:	89 d8                	mov    %ebx,%eax
  8007fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	8b 75 08             	mov    0x8(%ebp),%esi
  800807:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080a:	89 f3                	mov    %esi,%ebx
  80080c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080f:	89 f2                	mov    %esi,%edx
  800811:	eb 0f                	jmp    800822 <strncpy+0x23>
		*dst++ = *src;
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	0f b6 01             	movzbl (%ecx),%eax
  800819:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081c:	80 39 01             	cmpb   $0x1,(%ecx)
  80081f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800822:	39 da                	cmp    %ebx,%edx
  800824:	75 ed                	jne    800813 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800826:	89 f0                	mov    %esi,%eax
  800828:	5b                   	pop    %ebx
  800829:	5e                   	pop    %esi
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 75 08             	mov    0x8(%ebp),%esi
  800834:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800837:	8b 55 10             	mov    0x10(%ebp),%edx
  80083a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083c:	85 d2                	test   %edx,%edx
  80083e:	74 21                	je     800861 <strlcpy+0x35>
  800840:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800844:	89 f2                	mov    %esi,%edx
  800846:	eb 09                	jmp    800851 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	83 c1 01             	add    $0x1,%ecx
  80084e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800851:	39 c2                	cmp    %eax,%edx
  800853:	74 09                	je     80085e <strlcpy+0x32>
  800855:	0f b6 19             	movzbl (%ecx),%ebx
  800858:	84 db                	test   %bl,%bl
  80085a:	75 ec                	jne    800848 <strlcpy+0x1c>
  80085c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800861:	29 f0                	sub    %esi,%eax
}
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800870:	eb 06                	jmp    800878 <strcmp+0x11>
		p++, q++;
  800872:	83 c1 01             	add    $0x1,%ecx
  800875:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800878:	0f b6 01             	movzbl (%ecx),%eax
  80087b:	84 c0                	test   %al,%al
  80087d:	74 04                	je     800883 <strcmp+0x1c>
  80087f:	3a 02                	cmp    (%edx),%al
  800881:	74 ef                	je     800872 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800883:	0f b6 c0             	movzbl %al,%eax
  800886:	0f b6 12             	movzbl (%edx),%edx
  800889:	29 d0                	sub    %edx,%eax
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	53                   	push   %ebx
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	89 c3                	mov    %eax,%ebx
  800899:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089c:	eb 06                	jmp    8008a4 <strncmp+0x17>
		n--, p++, q++;
  80089e:	83 c0 01             	add    $0x1,%eax
  8008a1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a4:	39 d8                	cmp    %ebx,%eax
  8008a6:	74 15                	je     8008bd <strncmp+0x30>
  8008a8:	0f b6 08             	movzbl (%eax),%ecx
  8008ab:	84 c9                	test   %cl,%cl
  8008ad:	74 04                	je     8008b3 <strncmp+0x26>
  8008af:	3a 0a                	cmp    (%edx),%cl
  8008b1:	74 eb                	je     80089e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 00             	movzbl (%eax),%eax
  8008b6:	0f b6 12             	movzbl (%edx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
  8008bb:	eb 05                	jmp    8008c2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c2:	5b                   	pop    %ebx
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cf:	eb 07                	jmp    8008d8 <strchr+0x13>
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 0f                	je     8008e4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d5:	83 c0 01             	add    $0x1,%eax
  8008d8:	0f b6 10             	movzbl (%eax),%edx
  8008db:	84 d2                	test   %dl,%dl
  8008dd:	75 f2                	jne    8008d1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f0:	eb 03                	jmp    8008f5 <strfind+0xf>
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	74 04                	je     800900 <strfind+0x1a>
  8008fc:	84 d2                	test   %dl,%dl
  8008fe:	75 f2                	jne    8008f2 <strfind+0xc>
			break;
	return (char *) s;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090e:	85 c9                	test   %ecx,%ecx
  800910:	74 36                	je     800948 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800912:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800918:	75 28                	jne    800942 <memset+0x40>
  80091a:	f6 c1 03             	test   $0x3,%cl
  80091d:	75 23                	jne    800942 <memset+0x40>
		c &= 0xFF;
  80091f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800923:	89 d3                	mov    %edx,%ebx
  800925:	c1 e3 08             	shl    $0x8,%ebx
  800928:	89 d6                	mov    %edx,%esi
  80092a:	c1 e6 18             	shl    $0x18,%esi
  80092d:	89 d0                	mov    %edx,%eax
  80092f:	c1 e0 10             	shl    $0x10,%eax
  800932:	09 f0                	or     %esi,%eax
  800934:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800936:	89 d8                	mov    %ebx,%eax
  800938:	09 d0                	or     %edx,%eax
  80093a:	c1 e9 02             	shr    $0x2,%ecx
  80093d:	fc                   	cld    
  80093e:	f3 ab                	rep stos %eax,%es:(%edi)
  800940:	eb 06                	jmp    800948 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800942:	8b 45 0c             	mov    0xc(%ebp),%eax
  800945:	fc                   	cld    
  800946:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800948:	89 f8                	mov    %edi,%eax
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5f                   	pop    %edi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	57                   	push   %edi
  800953:	56                   	push   %esi
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095d:	39 c6                	cmp    %eax,%esi
  80095f:	73 35                	jae    800996 <memmove+0x47>
  800961:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800964:	39 d0                	cmp    %edx,%eax
  800966:	73 2e                	jae    800996 <memmove+0x47>
		s += n;
		d += n;
  800968:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096b:	89 d6                	mov    %edx,%esi
  80096d:	09 fe                	or     %edi,%esi
  80096f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800975:	75 13                	jne    80098a <memmove+0x3b>
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 0e                	jne    80098a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097c:	83 ef 04             	sub    $0x4,%edi
  80097f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800982:	c1 e9 02             	shr    $0x2,%ecx
  800985:	fd                   	std    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 09                	jmp    800993 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098a:	83 ef 01             	sub    $0x1,%edi
  80098d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800990:	fd                   	std    
  800991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800993:	fc                   	cld    
  800994:	eb 1d                	jmp    8009b3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	89 f2                	mov    %esi,%edx
  800998:	09 c2                	or     %eax,%edx
  80099a:	f6 c2 03             	test   $0x3,%dl
  80099d:	75 0f                	jne    8009ae <memmove+0x5f>
  80099f:	f6 c1 03             	test   $0x3,%cl
  8009a2:	75 0a                	jne    8009ae <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a4:	c1 e9 02             	shr    $0x2,%ecx
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ac:	eb 05                	jmp    8009b3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ae:	89 c7                	mov    %eax,%edi
  8009b0:	fc                   	cld    
  8009b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b3:	5e                   	pop    %esi
  8009b4:	5f                   	pop    %edi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ba:	ff 75 10             	pushl  0x10(%ebp)
  8009bd:	ff 75 0c             	pushl  0xc(%ebp)
  8009c0:	ff 75 08             	pushl  0x8(%ebp)
  8009c3:	e8 87 ff ff ff       	call   80094f <memmove>
}
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    

008009ca <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d5:	89 c6                	mov    %eax,%esi
  8009d7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009da:	eb 1a                	jmp    8009f6 <memcmp+0x2c>
		if (*s1 != *s2)
  8009dc:	0f b6 08             	movzbl (%eax),%ecx
  8009df:	0f b6 1a             	movzbl (%edx),%ebx
  8009e2:	38 d9                	cmp    %bl,%cl
  8009e4:	74 0a                	je     8009f0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e6:	0f b6 c1             	movzbl %cl,%eax
  8009e9:	0f b6 db             	movzbl %bl,%ebx
  8009ec:	29 d8                	sub    %ebx,%eax
  8009ee:	eb 0f                	jmp    8009ff <memcmp+0x35>
		s1++, s2++;
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f6:	39 f0                	cmp    %esi,%eax
  8009f8:	75 e2                	jne    8009dc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0a:	89 c1                	mov    %eax,%ecx
  800a0c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a13:	eb 0a                	jmp    800a1f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a15:	0f b6 10             	movzbl (%eax),%edx
  800a18:	39 da                	cmp    %ebx,%edx
  800a1a:	74 07                	je     800a23 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	39 c8                	cmp    %ecx,%eax
  800a21:	72 f2                	jb     800a15 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a23:	5b                   	pop    %ebx
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	eb 03                	jmp    800a37 <strtol+0x11>
		s++;
  800a34:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a37:	0f b6 01             	movzbl (%ecx),%eax
  800a3a:	3c 20                	cmp    $0x20,%al
  800a3c:	74 f6                	je     800a34 <strtol+0xe>
  800a3e:	3c 09                	cmp    $0x9,%al
  800a40:	74 f2                	je     800a34 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a42:	3c 2b                	cmp    $0x2b,%al
  800a44:	75 0a                	jne    800a50 <strtol+0x2a>
		s++;
  800a46:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4e:	eb 11                	jmp    800a61 <strtol+0x3b>
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a55:	3c 2d                	cmp    $0x2d,%al
  800a57:	75 08                	jne    800a61 <strtol+0x3b>
		s++, neg = 1;
  800a59:	83 c1 01             	add    $0x1,%ecx
  800a5c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a61:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a67:	75 15                	jne    800a7e <strtol+0x58>
  800a69:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6c:	75 10                	jne    800a7e <strtol+0x58>
  800a6e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a72:	75 7c                	jne    800af0 <strtol+0xca>
		s += 2, base = 16;
  800a74:	83 c1 02             	add    $0x2,%ecx
  800a77:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7c:	eb 16                	jmp    800a94 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7e:	85 db                	test   %ebx,%ebx
  800a80:	75 12                	jne    800a94 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a82:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a87:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8a:	75 08                	jne    800a94 <strtol+0x6e>
		s++, base = 8;
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
  800a99:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9c:	0f b6 11             	movzbl (%ecx),%edx
  800a9f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 09             	cmp    $0x9,%bl
  800aa7:	77 08                	ja     800ab1 <strtol+0x8b>
			dig = *s - '0';
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 30             	sub    $0x30,%edx
  800aaf:	eb 22                	jmp    800ad3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 57             	sub    $0x57,%edx
  800ac1:	eb 10                	jmp    800ad3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 16                	ja     800ae3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad6:	7d 0b                	jge    800ae3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae1:	eb b9                	jmp    800a9c <strtol+0x76>

	if (endptr)
  800ae3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae7:	74 0d                	je     800af6 <strtol+0xd0>
		*endptr = (char *) s;
  800ae9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aec:	89 0e                	mov    %ecx,(%esi)
  800aee:	eb 06                	jmp    800af6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af0:	85 db                	test   %ebx,%ebx
  800af2:	74 98                	je     800a8c <strtol+0x66>
  800af4:	eb 9e                	jmp    800a94 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af6:	89 c2                	mov    %eax,%edx
  800af8:	f7 da                	neg    %edx
  800afa:	85 ff                	test   %edi,%edi
  800afc:	0f 45 c2             	cmovne %edx,%eax
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	89 c3                	mov    %eax,%ebx
  800b17:	89 c7                	mov    %eax,%edi
  800b19:	89 c6                	mov    %eax,%esi
  800b1b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b32:	89 d1                	mov    %edx,%ecx
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	89 cb                	mov    %ecx,%ebx
  800b59:	89 cf                	mov    %ecx,%edi
  800b5b:	89 ce                	mov    %ecx,%esi
  800b5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 17                	jle    800b7a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	50                   	push   %eax
  800b67:	6a 03                	push   $0x3
  800b69:	68 ff 28 80 00       	push   $0x8028ff
  800b6e:	6a 23                	push   $0x23
  800b70:	68 1c 29 80 00       	push   $0x80291c
  800b75:	e8 e5 f5 ff ff       	call   80015f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_yield>:

void
sys_yield(void)
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
  800bac:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb1:	89 d1                	mov    %edx,%ecx
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	89 d6                	mov    %edx,%esi
  800bb9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bc9:	be 00 00 00 00       	mov    $0x0,%esi
  800bce:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdc:	89 f7                	mov    %esi,%edi
  800bde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 04                	push   $0x4
  800bea:	68 ff 28 80 00       	push   $0x8028ff
  800bef:	6a 23                	push   $0x23
  800bf1:	68 1c 29 80 00       	push   $0x80291c
  800bf6:	e8 64 f5 ff ff       	call   80015f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c0c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 05                	push   $0x5
  800c2c:	68 ff 28 80 00       	push   $0x8028ff
  800c31:	6a 23                	push   $0x23
  800c33:	68 1c 29 80 00       	push   $0x80291c
  800c38:	e8 22 f5 ff ff       	call   80015f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c53:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c66:	7e 17                	jle    800c7f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 06                	push   $0x6
  800c6e:	68 ff 28 80 00       	push   $0x8028ff
  800c73:	6a 23                	push   $0x23
  800c75:	68 1c 29 80 00       	push   $0x80291c
  800c7a:	e8 e0 f4 ff ff       	call   80015f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c95:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 08                	push   $0x8
  800cb0:	68 ff 28 80 00       	push   $0x8028ff
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 1c 29 80 00       	push   $0x80291c
  800cbc:	e8 9e f4 ff ff       	call   80015f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800cd7:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800cea:	7e 17                	jle    800d03 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 09                	push   $0x9
  800cf2:	68 ff 28 80 00       	push   $0x8028ff
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 1c 29 80 00       	push   $0x80291c
  800cfe:	e8 5c f4 ff ff       	call   80015f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 df                	mov    %ebx,%edi
  800d26:	89 de                	mov    %ebx,%esi
  800d28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 0a                	push   $0xa
  800d34:	68 ff 28 80 00       	push   $0x8028ff
  800d39:	6a 23                	push   $0x23
  800d3b:	68 1c 29 80 00       	push   $0x80291c
  800d40:	e8 1a f4 ff ff       	call   80015f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	be 00 00 00 00       	mov    $0x0,%esi
  800d58:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d69:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 cb                	mov    %ecx,%ebx
  800d88:	89 cf                	mov    %ecx,%edi
  800d8a:	89 ce                	mov    %ecx,%esi
  800d8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	7e 17                	jle    800da9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	50                   	push   %eax
  800d96:	6a 0d                	push   $0xd
  800d98:	68 ff 28 80 00       	push   $0x8028ff
  800d9d:	6a 23                	push   $0x23
  800d9f:	68 1c 29 80 00       	push   $0x80291c
  800da4:	e8 b6 f3 ff ff       	call   80015f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	89 cb                	mov    %ecx,%ebx
  800dc6:	89 cf                	mov    %ecx,%edi
  800dc8:	89 ce                	mov    %ecx,%esi
  800dca:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddc:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	89 cb                	mov    %ecx,%ebx
  800de6:	89 cf                	mov    %ecx,%edi
  800de8:	89 ce                	mov    %ecx,%esi
  800dea:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfc:	b8 10 00 00 00       	mov    $0x10,%eax
  800e01:	8b 55 08             	mov    0x8(%ebp),%edx
  800e04:	89 cb                	mov    %ecx,%ebx
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	89 ce                	mov    %ecx,%esi
  800e0a:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	53                   	push   %ebx
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e1b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e1d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e21:	74 11                	je     800e34 <pgfault+0x23>
  800e23:	89 d8                	mov    %ebx,%eax
  800e25:	c1 e8 0c             	shr    $0xc,%eax
  800e28:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e2f:	f6 c4 08             	test   $0x8,%ah
  800e32:	75 14                	jne    800e48 <pgfault+0x37>
		panic("faulting access");
  800e34:	83 ec 04             	sub    $0x4,%esp
  800e37:	68 2a 29 80 00       	push   $0x80292a
  800e3c:	6a 1f                	push   $0x1f
  800e3e:	68 3a 29 80 00       	push   $0x80293a
  800e43:	e8 17 f3 ff ff       	call   80015f <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	6a 07                	push   $0x7
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	6a 00                	push   $0x0
  800e54:	e8 67 fd ff ff       	call   800bc0 <sys_page_alloc>
	if (r < 0) {
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	79 12                	jns    800e72 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e60:	50                   	push   %eax
  800e61:	68 45 29 80 00       	push   $0x802945
  800e66:	6a 2d                	push   $0x2d
  800e68:	68 3a 29 80 00       	push   $0x80293a
  800e6d:	e8 ed f2 ff ff       	call   80015f <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e72:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	68 00 10 00 00       	push   $0x1000
  800e80:	53                   	push   %ebx
  800e81:	68 00 f0 7f 00       	push   $0x7ff000
  800e86:	e8 2c fb ff ff       	call   8009b7 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e8b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e92:	53                   	push   %ebx
  800e93:	6a 00                	push   $0x0
  800e95:	68 00 f0 7f 00       	push   $0x7ff000
  800e9a:	6a 00                	push   $0x0
  800e9c:	e8 62 fd ff ff       	call   800c03 <sys_page_map>
	if (r < 0) {
  800ea1:	83 c4 20             	add    $0x20,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	79 12                	jns    800eba <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800ea8:	50                   	push   %eax
  800ea9:	68 45 29 80 00       	push   $0x802945
  800eae:	6a 34                	push   $0x34
  800eb0:	68 3a 29 80 00       	push   $0x80293a
  800eb5:	e8 a5 f2 ff ff       	call   80015f <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800eba:	83 ec 08             	sub    $0x8,%esp
  800ebd:	68 00 f0 7f 00       	push   $0x7ff000
  800ec2:	6a 00                	push   $0x0
  800ec4:	e8 7c fd ff ff       	call   800c45 <sys_page_unmap>
	if (r < 0) {
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	79 12                	jns    800ee2 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800ed0:	50                   	push   %eax
  800ed1:	68 45 29 80 00       	push   $0x802945
  800ed6:	6a 38                	push   $0x38
  800ed8:	68 3a 29 80 00       	push   $0x80293a
  800edd:	e8 7d f2 ff ff       	call   80015f <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ee2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ef0:	68 11 0e 80 00       	push   $0x800e11
  800ef5:	e8 92 11 00 00       	call   80208c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800efa:	b8 07 00 00 00       	mov    $0x7,%eax
  800eff:	cd 30                	int    $0x30
  800f01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f04:	83 c4 10             	add    $0x10,%esp
  800f07:	85 c0                	test   %eax,%eax
  800f09:	79 17                	jns    800f22 <fork+0x3b>
		panic("fork fault %e");
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	68 5e 29 80 00       	push   $0x80295e
  800f13:	68 85 00 00 00       	push   $0x85
  800f18:	68 3a 29 80 00       	push   $0x80293a
  800f1d:	e8 3d f2 ff ff       	call   80015f <_panic>
  800f22:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f24:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f28:	75 24                	jne    800f4e <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2a:	e8 53 fc ff ff       	call   800b82 <sys_getenvid>
  800f2f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f34:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800f3a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f3f:	a3 20 40 c0 00       	mov    %eax,0xc04020
		return 0;
  800f44:	b8 00 00 00 00       	mov    $0x0,%eax
  800f49:	e9 64 01 00 00       	jmp    8010b2 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	6a 07                	push   $0x7
  800f53:	68 00 f0 bf ee       	push   $0xeebff000
  800f58:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5b:	e8 60 fc ff ff       	call   800bc0 <sys_page_alloc>
  800f60:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f63:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f68:	89 d8                	mov    %ebx,%eax
  800f6a:	c1 e8 16             	shr    $0x16,%eax
  800f6d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f74:	a8 01                	test   $0x1,%al
  800f76:	0f 84 fc 00 00 00    	je     801078 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	c1 e8 0c             	shr    $0xc,%eax
  800f81:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f88:	f6 c2 01             	test   $0x1,%dl
  800f8b:	0f 84 e7 00 00 00    	je     801078 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f91:	89 c6                	mov    %eax,%esi
  800f93:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f96:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9d:	f6 c6 04             	test   $0x4,%dh
  800fa0:	74 39                	je     800fdb <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fa2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb1:	50                   	push   %eax
  800fb2:	56                   	push   %esi
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 47 fc ff ff       	call   800c03 <sys_page_map>
		if (r < 0) {
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	0f 89 b1 00 00 00    	jns    801078 <fork+0x191>
		    	panic("sys page map fault %e");
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	68 6c 29 80 00       	push   $0x80296c
  800fcf:	6a 55                	push   $0x55
  800fd1:	68 3a 29 80 00       	push   $0x80293a
  800fd6:	e8 84 f1 ff ff       	call   80015f <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fdb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe2:	f6 c2 02             	test   $0x2,%dl
  800fe5:	75 0c                	jne    800ff3 <fork+0x10c>
  800fe7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fee:	f6 c4 08             	test   $0x8,%ah
  800ff1:	74 5b                	je     80104e <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	68 05 08 00 00       	push   $0x805
  800ffb:	56                   	push   %esi
  800ffc:	57                   	push   %edi
  800ffd:	56                   	push   %esi
  800ffe:	6a 00                	push   $0x0
  801000:	e8 fe fb ff ff       	call   800c03 <sys_page_map>
		if (r < 0) {
  801005:	83 c4 20             	add    $0x20,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	79 14                	jns    801020 <fork+0x139>
		    	panic("sys page map fault %e");
  80100c:	83 ec 04             	sub    $0x4,%esp
  80100f:	68 6c 29 80 00       	push   $0x80296c
  801014:	6a 5c                	push   $0x5c
  801016:	68 3a 29 80 00       	push   $0x80293a
  80101b:	e8 3f f1 ff ff       	call   80015f <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	68 05 08 00 00       	push   $0x805
  801028:	56                   	push   %esi
  801029:	6a 00                	push   $0x0
  80102b:	56                   	push   %esi
  80102c:	6a 00                	push   $0x0
  80102e:	e8 d0 fb ff ff       	call   800c03 <sys_page_map>
		if (r < 0) {
  801033:	83 c4 20             	add    $0x20,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	79 3e                	jns    801078 <fork+0x191>
		    	panic("sys page map fault %e");
  80103a:	83 ec 04             	sub    $0x4,%esp
  80103d:	68 6c 29 80 00       	push   $0x80296c
  801042:	6a 60                	push   $0x60
  801044:	68 3a 29 80 00       	push   $0x80293a
  801049:	e8 11 f1 ff ff       	call   80015f <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	6a 05                	push   $0x5
  801053:	56                   	push   %esi
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	6a 00                	push   $0x0
  801058:	e8 a6 fb ff ff       	call   800c03 <sys_page_map>
		if (r < 0) {
  80105d:	83 c4 20             	add    $0x20,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	79 14                	jns    801078 <fork+0x191>
		    	panic("sys page map fault %e");
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	68 6c 29 80 00       	push   $0x80296c
  80106c:	6a 65                	push   $0x65
  80106e:	68 3a 29 80 00       	push   $0x80293a
  801073:	e8 e7 f0 ff ff       	call   80015f <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801078:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80107e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801084:	0f 85 de fe ff ff    	jne    800f68 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80108a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80108f:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	50                   	push   %eax
  801099:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80109c:	57                   	push   %edi
  80109d:	e8 69 fc ff ff       	call   800d0b <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010a2:	83 c4 08             	add    $0x8,%esp
  8010a5:	6a 02                	push   $0x2
  8010a7:	57                   	push   %edi
  8010a8:	e8 da fb ff ff       	call   800c87 <sys_env_set_status>
	
	return envid;
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8010b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <sfork>:

envid_t
sfork(void)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8010bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	56                   	push   %esi
  8010c8:	53                   	push   %ebx
  8010c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010cc:	89 1d 24 40 c0 00    	mov    %ebx,0xc04024
	cprintf("in fork.c thread create. func: %x\n", func);
  8010d2:	83 ec 08             	sub    $0x8,%esp
  8010d5:	53                   	push   %ebx
  8010d6:	68 fc 29 80 00       	push   $0x8029fc
  8010db:	e8 58 f1 ff ff       	call   800238 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010e0:	c7 04 24 25 01 80 00 	movl   $0x800125,(%esp)
  8010e7:	e8 c5 fc ff ff       	call   800db1 <sys_thread_create>
  8010ec:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010ee:	83 c4 08             	add    $0x8,%esp
  8010f1:	53                   	push   %ebx
  8010f2:	68 fc 29 80 00       	push   $0x8029fc
  8010f7:	e8 3c f1 ff ff       	call   800238 <cprintf>
	return id;
}
  8010fc:	89 f0                	mov    %esi,%eax
  8010fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801101:	5b                   	pop    %ebx
  801102:	5e                   	pop    %esi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  80110b:	ff 75 08             	pushl  0x8(%ebp)
  80110e:	e8 be fc ff ff       	call   800dd1 <sys_thread_free>
}
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80111e:	ff 75 08             	pushl  0x8(%ebp)
  801121:	e8 cb fc ff ff       	call   800df1 <sys_thread_join>
}
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
  801130:	8b 75 08             	mov    0x8(%ebp),%esi
  801133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801136:	83 ec 04             	sub    $0x4,%esp
  801139:	6a 07                	push   $0x7
  80113b:	6a 00                	push   $0x0
  80113d:	56                   	push   %esi
  80113e:	e8 7d fa ff ff       	call   800bc0 <sys_page_alloc>
	if (r < 0) {
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	79 15                	jns    80115f <queue_append+0x34>
		panic("%e\n", r);
  80114a:	50                   	push   %eax
  80114b:	68 f8 29 80 00       	push   $0x8029f8
  801150:	68 c4 00 00 00       	push   $0xc4
  801155:	68 3a 29 80 00       	push   $0x80293a
  80115a:	e8 00 f0 ff ff       	call   80015f <_panic>
	}	
	wt->envid = envid;
  80115f:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	ff 33                	pushl  (%ebx)
  80116a:	56                   	push   %esi
  80116b:	68 20 2a 80 00       	push   $0x802a20
  801170:	e8 c3 f0 ff ff       	call   800238 <cprintf>
	if (queue->first == NULL) {
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	83 3b 00             	cmpl   $0x0,(%ebx)
  80117b:	75 29                	jne    8011a6 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	68 82 29 80 00       	push   $0x802982
  801185:	e8 ae f0 ff ff       	call   800238 <cprintf>
		queue->first = wt;
  80118a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  801190:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801197:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80119e:	00 00 00 
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	eb 2b                	jmp    8011d1 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8011a6:	83 ec 0c             	sub    $0xc,%esp
  8011a9:	68 9c 29 80 00       	push   $0x80299c
  8011ae:	e8 85 f0 ff ff       	call   800238 <cprintf>
		queue->last->next = wt;
  8011b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8011b6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8011bd:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8011c4:	00 00 00 
		queue->last = wt;
  8011c7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8011ce:	83 c4 10             	add    $0x10,%esp
	}
}
  8011d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 04             	sub    $0x4,%esp
  8011df:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8011e2:	8b 02                	mov    (%edx),%eax
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	75 17                	jne    8011ff <queue_pop+0x27>
		panic("queue empty!\n");
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	68 ba 29 80 00       	push   $0x8029ba
  8011f0:	68 d8 00 00 00       	push   $0xd8
  8011f5:	68 3a 29 80 00       	push   $0x80293a
  8011fa:	e8 60 ef ff ff       	call   80015f <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8011ff:	8b 48 04             	mov    0x4(%eax),%ecx
  801202:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801204:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	53                   	push   %ebx
  80120a:	68 c8 29 80 00       	push   $0x8029c8
  80120f:	e8 24 f0 ff ff       	call   800238 <cprintf>
	return envid;
}
  801214:	89 d8                	mov    %ebx,%eax
  801216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	53                   	push   %ebx
  80121f:	83 ec 04             	sub    $0x4,%esp
  801222:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801225:	b8 01 00 00 00       	mov    $0x1,%eax
  80122a:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80122d:	85 c0                	test   %eax,%eax
  80122f:	74 5a                	je     80128b <mutex_lock+0x70>
  801231:	8b 43 04             	mov    0x4(%ebx),%eax
  801234:	83 38 00             	cmpl   $0x0,(%eax)
  801237:	75 52                	jne    80128b <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801239:	83 ec 0c             	sub    $0xc,%esp
  80123c:	68 48 2a 80 00       	push   $0x802a48
  801241:	e8 f2 ef ff ff       	call   800238 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801246:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801249:	e8 34 f9 ff ff       	call   800b82 <sys_getenvid>
  80124e:	83 c4 08             	add    $0x8,%esp
  801251:	53                   	push   %ebx
  801252:	50                   	push   %eax
  801253:	e8 d3 fe ff ff       	call   80112b <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801258:	e8 25 f9 ff ff       	call   800b82 <sys_getenvid>
  80125d:	83 c4 08             	add    $0x8,%esp
  801260:	6a 04                	push   $0x4
  801262:	50                   	push   %eax
  801263:	e8 1f fa ff ff       	call   800c87 <sys_env_set_status>
		if (r < 0) {
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	85 c0                	test   %eax,%eax
  80126d:	79 15                	jns    801284 <mutex_lock+0x69>
			panic("%e\n", r);
  80126f:	50                   	push   %eax
  801270:	68 f8 29 80 00       	push   $0x8029f8
  801275:	68 eb 00 00 00       	push   $0xeb
  80127a:	68 3a 29 80 00       	push   $0x80293a
  80127f:	e8 db ee ff ff       	call   80015f <_panic>
		}
		sys_yield();
  801284:	e8 18 f9 ff ff       	call   800ba1 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801289:	eb 18                	jmp    8012a3 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	68 68 2a 80 00       	push   $0x802a68
  801293:	e8 a0 ef ff ff       	call   800238 <cprintf>
	mtx->owner = sys_getenvid();}
  801298:	e8 e5 f8 ff ff       	call   800b82 <sys_getenvid>
  80129d:	89 43 08             	mov    %eax,0x8(%ebx)
  8012a0:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b7:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8012ba:	8b 43 04             	mov    0x4(%ebx),%eax
  8012bd:	83 38 00             	cmpl   $0x0,(%eax)
  8012c0:	74 33                	je     8012f5 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	50                   	push   %eax
  8012c6:	e8 0d ff ff ff       	call   8011d8 <queue_pop>
  8012cb:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8012ce:	83 c4 08             	add    $0x8,%esp
  8012d1:	6a 02                	push   $0x2
  8012d3:	50                   	push   %eax
  8012d4:	e8 ae f9 ff ff       	call   800c87 <sys_env_set_status>
		if (r < 0) {
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	79 15                	jns    8012f5 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8012e0:	50                   	push   %eax
  8012e1:	68 f8 29 80 00       	push   $0x8029f8
  8012e6:	68 00 01 00 00       	push   $0x100
  8012eb:	68 3a 29 80 00       	push   $0x80293a
  8012f0:	e8 6a ee ff ff       	call   80015f <_panic>
		}
	}

	asm volatile("pause");
  8012f5:	f3 90                	pause  
	//sys_yield();
}
  8012f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	53                   	push   %ebx
  801300:	83 ec 04             	sub    $0x4,%esp
  801303:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801306:	e8 77 f8 ff ff       	call   800b82 <sys_getenvid>
  80130b:	83 ec 04             	sub    $0x4,%esp
  80130e:	6a 07                	push   $0x7
  801310:	53                   	push   %ebx
  801311:	50                   	push   %eax
  801312:	e8 a9 f8 ff ff       	call   800bc0 <sys_page_alloc>
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	85 c0                	test   %eax,%eax
  80131c:	79 15                	jns    801333 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80131e:	50                   	push   %eax
  80131f:	68 e3 29 80 00       	push   $0x8029e3
  801324:	68 0d 01 00 00       	push   $0x10d
  801329:	68 3a 29 80 00       	push   $0x80293a
  80132e:	e8 2c ee ff ff       	call   80015f <_panic>
	}	
	mtx->locked = 0;
  801333:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801339:	8b 43 04             	mov    0x4(%ebx),%eax
  80133c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801342:	8b 43 04             	mov    0x4(%ebx),%eax
  801345:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80134c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801353:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80135e:	e8 1f f8 ff ff       	call   800b82 <sys_getenvid>
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	ff 75 08             	pushl  0x8(%ebp)
  801369:	50                   	push   %eax
  80136a:	e8 d6 f8 ff ff       	call   800c45 <sys_page_unmap>
	if (r < 0) {
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	79 15                	jns    80138b <mutex_destroy+0x33>
		panic("%e\n", r);
  801376:	50                   	push   %eax
  801377:	68 f8 29 80 00       	push   $0x8029f8
  80137c:	68 1a 01 00 00       	push   $0x11a
  801381:	68 3a 29 80 00       	push   $0x80293a
  801386:	e8 d4 ed ff ff       	call   80015f <_panic>
	}
}
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801390:	8b 45 08             	mov    0x8(%ebp),%eax
  801393:	05 00 00 00 30       	add    $0x30000000,%eax
  801398:	c1 e8 0c             	shr    $0xc,%eax
}
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a3:	05 00 00 00 30       	add    $0x30000000,%eax
  8013a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013ad:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013bf:	89 c2                	mov    %eax,%edx
  8013c1:	c1 ea 16             	shr    $0x16,%edx
  8013c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013cb:	f6 c2 01             	test   $0x1,%dl
  8013ce:	74 11                	je     8013e1 <fd_alloc+0x2d>
  8013d0:	89 c2                	mov    %eax,%edx
  8013d2:	c1 ea 0c             	shr    $0xc,%edx
  8013d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013dc:	f6 c2 01             	test   $0x1,%dl
  8013df:	75 09                	jne    8013ea <fd_alloc+0x36>
			*fd_store = fd;
  8013e1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e8:	eb 17                	jmp    801401 <fd_alloc+0x4d>
  8013ea:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013ef:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013f4:	75 c9                	jne    8013bf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013f6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013fc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801401:	5d                   	pop    %ebp
  801402:	c3                   	ret    

00801403 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801409:	83 f8 1f             	cmp    $0x1f,%eax
  80140c:	77 36                	ja     801444 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80140e:	c1 e0 0c             	shl    $0xc,%eax
  801411:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801416:	89 c2                	mov    %eax,%edx
  801418:	c1 ea 16             	shr    $0x16,%edx
  80141b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801422:	f6 c2 01             	test   $0x1,%dl
  801425:	74 24                	je     80144b <fd_lookup+0x48>
  801427:	89 c2                	mov    %eax,%edx
  801429:	c1 ea 0c             	shr    $0xc,%edx
  80142c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801433:	f6 c2 01             	test   $0x1,%dl
  801436:	74 1a                	je     801452 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801438:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143b:	89 02                	mov    %eax,(%edx)
	return 0;
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
  801442:	eb 13                	jmp    801457 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801444:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801449:	eb 0c                	jmp    801457 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80144b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801450:	eb 05                	jmp    801457 <fd_lookup+0x54>
  801452:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    

00801459 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801462:	ba 08 2b 80 00       	mov    $0x802b08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801467:	eb 13                	jmp    80147c <dev_lookup+0x23>
  801469:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80146c:	39 08                	cmp    %ecx,(%eax)
  80146e:	75 0c                	jne    80147c <dev_lookup+0x23>
			*dev = devtab[i];
  801470:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801473:	89 01                	mov    %eax,(%ecx)
			return 0;
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
  80147a:	eb 31                	jmp    8014ad <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80147c:	8b 02                	mov    (%edx),%eax
  80147e:	85 c0                	test   %eax,%eax
  801480:	75 e7                	jne    801469 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801482:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801487:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80148d:	83 ec 04             	sub    $0x4,%esp
  801490:	51                   	push   %ecx
  801491:	50                   	push   %eax
  801492:	68 88 2a 80 00       	push   $0x802a88
  801497:	e8 9c ed ff ff       	call   800238 <cprintf>
	*dev = 0;
  80149c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 10             	sub    $0x10,%esp
  8014b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014c7:	c1 e8 0c             	shr    $0xc,%eax
  8014ca:	50                   	push   %eax
  8014cb:	e8 33 ff ff ff       	call   801403 <fd_lookup>
  8014d0:	83 c4 08             	add    $0x8,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 05                	js     8014dc <fd_close+0x2d>
	    || fd != fd2)
  8014d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014da:	74 0c                	je     8014e8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014dc:	84 db                	test   %bl,%bl
  8014de:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e3:	0f 44 c2             	cmove  %edx,%eax
  8014e6:	eb 41                	jmp    801529 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	ff 36                	pushl  (%esi)
  8014f1:	e8 63 ff ff ff       	call   801459 <dev_lookup>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 1a                	js     801519 <fd_close+0x6a>
		if (dev->dev_close)
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801505:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80150a:	85 c0                	test   %eax,%eax
  80150c:	74 0b                	je     801519 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	56                   	push   %esi
  801512:	ff d0                	call   *%eax
  801514:	89 c3                	mov    %eax,%ebx
  801516:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	56                   	push   %esi
  80151d:	6a 00                	push   $0x0
  80151f:	e8 21 f7 ff ff       	call   800c45 <sys_page_unmap>
	return r;
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	89 d8                	mov    %ebx,%eax
}
  801529:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	ff 75 08             	pushl  0x8(%ebp)
  80153d:	e8 c1 fe ff ff       	call   801403 <fd_lookup>
  801542:	83 c4 08             	add    $0x8,%esp
  801545:	85 c0                	test   %eax,%eax
  801547:	78 10                	js     801559 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	6a 01                	push   $0x1
  80154e:	ff 75 f4             	pushl  -0xc(%ebp)
  801551:	e8 59 ff ff ff       	call   8014af <fd_close>
  801556:	83 c4 10             	add    $0x10,%esp
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <close_all>:

void
close_all(void)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801562:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801567:	83 ec 0c             	sub    $0xc,%esp
  80156a:	53                   	push   %ebx
  80156b:	e8 c0 ff ff ff       	call   801530 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801570:	83 c3 01             	add    $0x1,%ebx
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	83 fb 20             	cmp    $0x20,%ebx
  801579:	75 ec                	jne    801567 <close_all+0xc>
		close(i);
}
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	57                   	push   %edi
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	83 ec 2c             	sub    $0x2c,%esp
  801589:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80158c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	ff 75 08             	pushl  0x8(%ebp)
  801593:	e8 6b fe ff ff       	call   801403 <fd_lookup>
  801598:	83 c4 08             	add    $0x8,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	0f 88 c1 00 00 00    	js     801664 <dup+0xe4>
		return r;
	close(newfdnum);
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	56                   	push   %esi
  8015a7:	e8 84 ff ff ff       	call   801530 <close>

	newfd = INDEX2FD(newfdnum);
  8015ac:	89 f3                	mov    %esi,%ebx
  8015ae:	c1 e3 0c             	shl    $0xc,%ebx
  8015b1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015b7:	83 c4 04             	add    $0x4,%esp
  8015ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015bd:	e8 db fd ff ff       	call   80139d <fd2data>
  8015c2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015c4:	89 1c 24             	mov    %ebx,(%esp)
  8015c7:	e8 d1 fd ff ff       	call   80139d <fd2data>
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015d2:	89 f8                	mov    %edi,%eax
  8015d4:	c1 e8 16             	shr    $0x16,%eax
  8015d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015de:	a8 01                	test   $0x1,%al
  8015e0:	74 37                	je     801619 <dup+0x99>
  8015e2:	89 f8                	mov    %edi,%eax
  8015e4:	c1 e8 0c             	shr    $0xc,%eax
  8015e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015ee:	f6 c2 01             	test   $0x1,%dl
  8015f1:	74 26                	je     801619 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801602:	50                   	push   %eax
  801603:	ff 75 d4             	pushl  -0x2c(%ebp)
  801606:	6a 00                	push   $0x0
  801608:	57                   	push   %edi
  801609:	6a 00                	push   $0x0
  80160b:	e8 f3 f5 ff ff       	call   800c03 <sys_page_map>
  801610:	89 c7                	mov    %eax,%edi
  801612:	83 c4 20             	add    $0x20,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 2e                	js     801647 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801619:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	c1 e8 0c             	shr    $0xc,%eax
  801621:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801628:	83 ec 0c             	sub    $0xc,%esp
  80162b:	25 07 0e 00 00       	and    $0xe07,%eax
  801630:	50                   	push   %eax
  801631:	53                   	push   %ebx
  801632:	6a 00                	push   $0x0
  801634:	52                   	push   %edx
  801635:	6a 00                	push   $0x0
  801637:	e8 c7 f5 ff ff       	call   800c03 <sys_page_map>
  80163c:	89 c7                	mov    %eax,%edi
  80163e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801641:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801643:	85 ff                	test   %edi,%edi
  801645:	79 1d                	jns    801664 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	53                   	push   %ebx
  80164b:	6a 00                	push   $0x0
  80164d:	e8 f3 f5 ff ff       	call   800c45 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801652:	83 c4 08             	add    $0x8,%esp
  801655:	ff 75 d4             	pushl  -0x2c(%ebp)
  801658:	6a 00                	push   $0x0
  80165a:	e8 e6 f5 ff ff       	call   800c45 <sys_page_unmap>
	return r;
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	89 f8                	mov    %edi,%eax
}
  801664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5f                   	pop    %edi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	53                   	push   %ebx
  801670:	83 ec 14             	sub    $0x14,%esp
  801673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	53                   	push   %ebx
  80167b:	e8 83 fd ff ff       	call   801403 <fd_lookup>
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	89 c2                	mov    %eax,%edx
  801685:	85 c0                	test   %eax,%eax
  801687:	78 70                	js     8016f9 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801693:	ff 30                	pushl  (%eax)
  801695:	e8 bf fd ff ff       	call   801459 <dev_lookup>
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 4f                	js     8016f0 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016a4:	8b 42 08             	mov    0x8(%edx),%eax
  8016a7:	83 e0 03             	and    $0x3,%eax
  8016aa:	83 f8 01             	cmp    $0x1,%eax
  8016ad:	75 24                	jne    8016d3 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016af:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8016b4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016ba:	83 ec 04             	sub    $0x4,%esp
  8016bd:	53                   	push   %ebx
  8016be:	50                   	push   %eax
  8016bf:	68 cc 2a 80 00       	push   $0x802acc
  8016c4:	e8 6f eb ff ff       	call   800238 <cprintf>
		return -E_INVAL;
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016d1:	eb 26                	jmp    8016f9 <read+0x8d>
	}
	if (!dev->dev_read)
  8016d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d6:	8b 40 08             	mov    0x8(%eax),%eax
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	74 17                	je     8016f4 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016dd:	83 ec 04             	sub    $0x4,%esp
  8016e0:	ff 75 10             	pushl  0x10(%ebp)
  8016e3:	ff 75 0c             	pushl  0xc(%ebp)
  8016e6:	52                   	push   %edx
  8016e7:	ff d0                	call   *%eax
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	eb 09                	jmp    8016f9 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	eb 05                	jmp    8016f9 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016f9:	89 d0                	mov    %edx,%eax
  8016fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
  801706:	83 ec 0c             	sub    $0xc,%esp
  801709:	8b 7d 08             	mov    0x8(%ebp),%edi
  80170c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80170f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801714:	eb 21                	jmp    801737 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801716:	83 ec 04             	sub    $0x4,%esp
  801719:	89 f0                	mov    %esi,%eax
  80171b:	29 d8                	sub    %ebx,%eax
  80171d:	50                   	push   %eax
  80171e:	89 d8                	mov    %ebx,%eax
  801720:	03 45 0c             	add    0xc(%ebp),%eax
  801723:	50                   	push   %eax
  801724:	57                   	push   %edi
  801725:	e8 42 ff ff ff       	call   80166c <read>
		if (m < 0)
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 10                	js     801741 <readn+0x41>
			return m;
		if (m == 0)
  801731:	85 c0                	test   %eax,%eax
  801733:	74 0a                	je     80173f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801735:	01 c3                	add    %eax,%ebx
  801737:	39 f3                	cmp    %esi,%ebx
  801739:	72 db                	jb     801716 <readn+0x16>
  80173b:	89 d8                	mov    %ebx,%eax
  80173d:	eb 02                	jmp    801741 <readn+0x41>
  80173f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801744:	5b                   	pop    %ebx
  801745:	5e                   	pop    %esi
  801746:	5f                   	pop    %edi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	83 ec 14             	sub    $0x14,%esp
  801750:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801753:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	53                   	push   %ebx
  801758:	e8 a6 fc ff ff       	call   801403 <fd_lookup>
  80175d:	83 c4 08             	add    $0x8,%esp
  801760:	89 c2                	mov    %eax,%edx
  801762:	85 c0                	test   %eax,%eax
  801764:	78 6b                	js     8017d1 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176c:	50                   	push   %eax
  80176d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801770:	ff 30                	pushl  (%eax)
  801772:	e8 e2 fc ff ff       	call   801459 <dev_lookup>
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 4a                	js     8017c8 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801781:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801785:	75 24                	jne    8017ab <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801787:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80178c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801792:	83 ec 04             	sub    $0x4,%esp
  801795:	53                   	push   %ebx
  801796:	50                   	push   %eax
  801797:	68 e8 2a 80 00       	push   $0x802ae8
  80179c:	e8 97 ea ff ff       	call   800238 <cprintf>
		return -E_INVAL;
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a9:	eb 26                	jmp    8017d1 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b1:	85 d2                	test   %edx,%edx
  8017b3:	74 17                	je     8017cc <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017b5:	83 ec 04             	sub    $0x4,%esp
  8017b8:	ff 75 10             	pushl  0x10(%ebp)
  8017bb:	ff 75 0c             	pushl  0xc(%ebp)
  8017be:	50                   	push   %eax
  8017bf:	ff d2                	call   *%edx
  8017c1:	89 c2                	mov    %eax,%edx
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	eb 09                	jmp    8017d1 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c8:	89 c2                	mov    %eax,%edx
  8017ca:	eb 05                	jmp    8017d1 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017d1:	89 d0                	mov    %edx,%eax
  8017d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d6:	c9                   	leave  
  8017d7:	c3                   	ret    

008017d8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017de:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	ff 75 08             	pushl  0x8(%ebp)
  8017e5:	e8 19 fc ff ff       	call   801403 <fd_lookup>
  8017ea:	83 c4 08             	add    $0x8,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 0e                	js     8017ff <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    

00801801 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	53                   	push   %ebx
  801805:	83 ec 14             	sub    $0x14,%esp
  801808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80180e:	50                   	push   %eax
  80180f:	53                   	push   %ebx
  801810:	e8 ee fb ff ff       	call   801403 <fd_lookup>
  801815:	83 c4 08             	add    $0x8,%esp
  801818:	89 c2                	mov    %eax,%edx
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 68                	js     801886 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801824:	50                   	push   %eax
  801825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801828:	ff 30                	pushl  (%eax)
  80182a:	e8 2a fc ff ff       	call   801459 <dev_lookup>
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	85 c0                	test   %eax,%eax
  801834:	78 47                	js     80187d <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80183d:	75 24                	jne    801863 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80183f:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801844:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80184a:	83 ec 04             	sub    $0x4,%esp
  80184d:	53                   	push   %ebx
  80184e:	50                   	push   %eax
  80184f:	68 a8 2a 80 00       	push   $0x802aa8
  801854:	e8 df e9 ff ff       	call   800238 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801861:	eb 23                	jmp    801886 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801863:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801866:	8b 52 18             	mov    0x18(%edx),%edx
  801869:	85 d2                	test   %edx,%edx
  80186b:	74 14                	je     801881 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	ff 75 0c             	pushl  0xc(%ebp)
  801873:	50                   	push   %eax
  801874:	ff d2                	call   *%edx
  801876:	89 c2                	mov    %eax,%edx
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	eb 09                	jmp    801886 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187d:	89 c2                	mov    %eax,%edx
  80187f:	eb 05                	jmp    801886 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801881:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801886:	89 d0                	mov    %edx,%eax
  801888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	53                   	push   %ebx
  801891:	83 ec 14             	sub    $0x14,%esp
  801894:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801897:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189a:	50                   	push   %eax
  80189b:	ff 75 08             	pushl  0x8(%ebp)
  80189e:	e8 60 fb ff ff       	call   801403 <fd_lookup>
  8018a3:	83 c4 08             	add    $0x8,%esp
  8018a6:	89 c2                	mov    %eax,%edx
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 58                	js     801904 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ac:	83 ec 08             	sub    $0x8,%esp
  8018af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b2:	50                   	push   %eax
  8018b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b6:	ff 30                	pushl  (%eax)
  8018b8:	e8 9c fb ff ff       	call   801459 <dev_lookup>
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 37                	js     8018fb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018cb:	74 32                	je     8018ff <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018cd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018d0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018d7:	00 00 00 
	stat->st_isdir = 0;
  8018da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e1:	00 00 00 
	stat->st_dev = dev;
  8018e4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	53                   	push   %ebx
  8018ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f1:	ff 50 14             	call   *0x14(%eax)
  8018f4:	89 c2                	mov    %eax,%edx
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	eb 09                	jmp    801904 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fb:	89 c2                	mov    %eax,%edx
  8018fd:	eb 05                	jmp    801904 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801904:	89 d0                	mov    %edx,%eax
  801906:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	6a 00                	push   $0x0
  801915:	ff 75 08             	pushl  0x8(%ebp)
  801918:	e8 e3 01 00 00       	call   801b00 <open>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	85 c0                	test   %eax,%eax
  801924:	78 1b                	js     801941 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	ff 75 0c             	pushl  0xc(%ebp)
  80192c:	50                   	push   %eax
  80192d:	e8 5b ff ff ff       	call   80188d <fstat>
  801932:	89 c6                	mov    %eax,%esi
	close(fd);
  801934:	89 1c 24             	mov    %ebx,(%esp)
  801937:	e8 f4 fb ff ff       	call   801530 <close>
	return r;
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	89 f0                	mov    %esi,%eax
}
  801941:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801944:	5b                   	pop    %ebx
  801945:	5e                   	pop    %esi
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
  80194d:	89 c6                	mov    %eax,%esi
  80194f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801951:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801958:	75 12                	jne    80196c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80195a:	83 ec 0c             	sub    $0xc,%esp
  80195d:	6a 01                	push   $0x1
  80195f:	e8 94 08 00 00       	call   8021f8 <ipc_find_env>
  801964:	a3 00 40 80 00       	mov    %eax,0x804000
  801969:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80196c:	6a 07                	push   $0x7
  80196e:	68 00 50 c0 00       	push   $0xc05000
  801973:	56                   	push   %esi
  801974:	ff 35 00 40 80 00    	pushl  0x804000
  80197a:	e8 17 08 00 00       	call   802196 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80197f:	83 c4 0c             	add    $0xc,%esp
  801982:	6a 00                	push   $0x0
  801984:	53                   	push   %ebx
  801985:	6a 00                	push   $0x0
  801987:	e8 8f 07 00 00       	call   80211b <ipc_recv>
}
  80198c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    

00801993 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	8b 40 0c             	mov    0xc(%eax),%eax
  80199f:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8019a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a7:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b1:	b8 02 00 00 00       	mov    $0x2,%eax
  8019b6:	e8 8d ff ff ff       	call   801948 <fsipc>
}
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c9:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8019ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d3:	b8 06 00 00 00       	mov    $0x6,%eax
  8019d8:	e8 6b ff ff ff       	call   801948 <fsipc>
}
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    

008019df <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	53                   	push   %ebx
  8019e3:	83 ec 04             	sub    $0x4,%esp
  8019e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ef:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8019fe:	e8 45 ff ff ff       	call   801948 <fsipc>
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 2c                	js     801a33 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	68 00 50 c0 00       	push   $0xc05000
  801a0f:	53                   	push   %ebx
  801a10:	e8 a8 ed ff ff       	call   8007bd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a15:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801a1a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a20:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801a25:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a41:	8b 55 08             	mov    0x8(%ebp),%edx
  801a44:	8b 52 0c             	mov    0xc(%edx),%edx
  801a47:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a4d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a52:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a57:	0f 47 c2             	cmova  %edx,%eax
  801a5a:	a3 04 50 c0 00       	mov    %eax,0xc05004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a5f:	50                   	push   %eax
  801a60:	ff 75 0c             	pushl  0xc(%ebp)
  801a63:	68 08 50 c0 00       	push   $0xc05008
  801a68:	e8 e2 ee ff ff       	call   80094f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a72:	b8 04 00 00 00       	mov    $0x4,%eax
  801a77:	e8 cc fe ff ff       	call   801948 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	56                   	push   %esi
  801a82:	53                   	push   %ebx
  801a83:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	8b 40 0c             	mov    0xc(%eax),%eax
  801a8c:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801a91:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a97:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9c:	b8 03 00 00 00       	mov    $0x3,%eax
  801aa1:	e8 a2 fe ff ff       	call   801948 <fsipc>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	78 4b                	js     801af7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801aac:	39 c6                	cmp    %eax,%esi
  801aae:	73 16                	jae    801ac6 <devfile_read+0x48>
  801ab0:	68 18 2b 80 00       	push   $0x802b18
  801ab5:	68 1f 2b 80 00       	push   $0x802b1f
  801aba:	6a 7c                	push   $0x7c
  801abc:	68 34 2b 80 00       	push   $0x802b34
  801ac1:	e8 99 e6 ff ff       	call   80015f <_panic>
	assert(r <= PGSIZE);
  801ac6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801acb:	7e 16                	jle    801ae3 <devfile_read+0x65>
  801acd:	68 3f 2b 80 00       	push   $0x802b3f
  801ad2:	68 1f 2b 80 00       	push   $0x802b1f
  801ad7:	6a 7d                	push   $0x7d
  801ad9:	68 34 2b 80 00       	push   $0x802b34
  801ade:	e8 7c e6 ff ff       	call   80015f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ae3:	83 ec 04             	sub    $0x4,%esp
  801ae6:	50                   	push   %eax
  801ae7:	68 00 50 c0 00       	push   $0xc05000
  801aec:	ff 75 0c             	pushl  0xc(%ebp)
  801aef:	e8 5b ee ff ff       	call   80094f <memmove>
	return r;
  801af4:	83 c4 10             	add    $0x10,%esp
}
  801af7:	89 d8                	mov    %ebx,%eax
  801af9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afc:	5b                   	pop    %ebx
  801afd:	5e                   	pop    %esi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    

00801b00 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	53                   	push   %ebx
  801b04:	83 ec 20             	sub    $0x20,%esp
  801b07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b0a:	53                   	push   %ebx
  801b0b:	e8 74 ec ff ff       	call   800784 <strlen>
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b18:	7f 67                	jg     801b81 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b1a:	83 ec 0c             	sub    $0xc,%esp
  801b1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b20:	50                   	push   %eax
  801b21:	e8 8e f8 ff ff       	call   8013b4 <fd_alloc>
  801b26:	83 c4 10             	add    $0x10,%esp
		return r;
  801b29:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	78 57                	js     801b86 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b2f:	83 ec 08             	sub    $0x8,%esp
  801b32:	53                   	push   %ebx
  801b33:	68 00 50 c0 00       	push   $0xc05000
  801b38:	e8 80 ec ff ff       	call   8007bd <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b40:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b48:	b8 01 00 00 00       	mov    $0x1,%eax
  801b4d:	e8 f6 fd ff ff       	call   801948 <fsipc>
  801b52:	89 c3                	mov    %eax,%ebx
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	79 14                	jns    801b6f <open+0x6f>
		fd_close(fd, 0);
  801b5b:	83 ec 08             	sub    $0x8,%esp
  801b5e:	6a 00                	push   $0x0
  801b60:	ff 75 f4             	pushl  -0xc(%ebp)
  801b63:	e8 47 f9 ff ff       	call   8014af <fd_close>
		return r;
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	89 da                	mov    %ebx,%edx
  801b6d:	eb 17                	jmp    801b86 <open+0x86>
	}

	return fd2num(fd);
  801b6f:	83 ec 0c             	sub    $0xc,%esp
  801b72:	ff 75 f4             	pushl  -0xc(%ebp)
  801b75:	e8 13 f8 ff ff       	call   80138d <fd2num>
  801b7a:	89 c2                	mov    %eax,%edx
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	eb 05                	jmp    801b86 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b81:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b86:	89 d0                	mov    %edx,%eax
  801b88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b93:	ba 00 00 00 00       	mov    $0x0,%edx
  801b98:	b8 08 00 00 00       	mov    $0x8,%eax
  801b9d:	e8 a6 fd ff ff       	call   801948 <fsipc>
}
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bac:	83 ec 0c             	sub    $0xc,%esp
  801baf:	ff 75 08             	pushl  0x8(%ebp)
  801bb2:	e8 e6 f7 ff ff       	call   80139d <fd2data>
  801bb7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bb9:	83 c4 08             	add    $0x8,%esp
  801bbc:	68 4b 2b 80 00       	push   $0x802b4b
  801bc1:	53                   	push   %ebx
  801bc2:	e8 f6 eb ff ff       	call   8007bd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bc7:	8b 46 04             	mov    0x4(%esi),%eax
  801bca:	2b 06                	sub    (%esi),%eax
  801bcc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bd2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bd9:	00 00 00 
	stat->st_dev = &devpipe;
  801bdc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801be3:	30 80 00 
	return 0;
}
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
  801beb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	53                   	push   %ebx
  801bf6:	83 ec 0c             	sub    $0xc,%esp
  801bf9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bfc:	53                   	push   %ebx
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 41 f0 ff ff       	call   800c45 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c04:	89 1c 24             	mov    %ebx,(%esp)
  801c07:	e8 91 f7 ff ff       	call   80139d <fd2data>
  801c0c:	83 c4 08             	add    $0x8,%esp
  801c0f:	50                   	push   %eax
  801c10:	6a 00                	push   $0x0
  801c12:	e8 2e f0 ff ff       	call   800c45 <sys_page_unmap>
}
  801c17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    

00801c1c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	57                   	push   %edi
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	83 ec 1c             	sub    $0x1c,%esp
  801c25:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c28:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c2a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801c2f:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	ff 75 e0             	pushl  -0x20(%ebp)
  801c3b:	e8 fd 05 00 00       	call   80223d <pageref>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	89 3c 24             	mov    %edi,(%esp)
  801c45:	e8 f3 05 00 00       	call   80223d <pageref>
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	39 c3                	cmp    %eax,%ebx
  801c4f:	0f 94 c1             	sete   %cl
  801c52:	0f b6 c9             	movzbl %cl,%ecx
  801c55:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c58:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801c5e:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801c64:	39 ce                	cmp    %ecx,%esi
  801c66:	74 1e                	je     801c86 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c68:	39 c3                	cmp    %eax,%ebx
  801c6a:	75 be                	jne    801c2a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c6c:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801c72:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c75:	50                   	push   %eax
  801c76:	56                   	push   %esi
  801c77:	68 52 2b 80 00       	push   $0x802b52
  801c7c:	e8 b7 e5 ff ff       	call   800238 <cprintf>
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	eb a4                	jmp    801c2a <_pipeisclosed+0xe>
	}
}
  801c86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5f                   	pop    %edi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	57                   	push   %edi
  801c95:	56                   	push   %esi
  801c96:	53                   	push   %ebx
  801c97:	83 ec 28             	sub    $0x28,%esp
  801c9a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c9d:	56                   	push   %esi
  801c9e:	e8 fa f6 ff ff       	call   80139d <fd2data>
  801ca3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	bf 00 00 00 00       	mov    $0x0,%edi
  801cad:	eb 4b                	jmp    801cfa <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801caf:	89 da                	mov    %ebx,%edx
  801cb1:	89 f0                	mov    %esi,%eax
  801cb3:	e8 64 ff ff ff       	call   801c1c <_pipeisclosed>
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	75 48                	jne    801d04 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cbc:	e8 e0 ee ff ff       	call   800ba1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cc1:	8b 43 04             	mov    0x4(%ebx),%eax
  801cc4:	8b 0b                	mov    (%ebx),%ecx
  801cc6:	8d 51 20             	lea    0x20(%ecx),%edx
  801cc9:	39 d0                	cmp    %edx,%eax
  801ccb:	73 e2                	jae    801caf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cd4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cd7:	89 c2                	mov    %eax,%edx
  801cd9:	c1 fa 1f             	sar    $0x1f,%edx
  801cdc:	89 d1                	mov    %edx,%ecx
  801cde:	c1 e9 1b             	shr    $0x1b,%ecx
  801ce1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ce4:	83 e2 1f             	and    $0x1f,%edx
  801ce7:	29 ca                	sub    %ecx,%edx
  801ce9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ced:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf1:	83 c0 01             	add    $0x1,%eax
  801cf4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf7:	83 c7 01             	add    $0x1,%edi
  801cfa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cfd:	75 c2                	jne    801cc1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cff:	8b 45 10             	mov    0x10(%ebp),%eax
  801d02:	eb 05                	jmp    801d09 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5e                   	pop    %esi
  801d0e:	5f                   	pop    %edi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	57                   	push   %edi
  801d15:	56                   	push   %esi
  801d16:	53                   	push   %ebx
  801d17:	83 ec 18             	sub    $0x18,%esp
  801d1a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d1d:	57                   	push   %edi
  801d1e:	e8 7a f6 ff ff       	call   80139d <fd2data>
  801d23:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d2d:	eb 3d                	jmp    801d6c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d2f:	85 db                	test   %ebx,%ebx
  801d31:	74 04                	je     801d37 <devpipe_read+0x26>
				return i;
  801d33:	89 d8                	mov    %ebx,%eax
  801d35:	eb 44                	jmp    801d7b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d37:	89 f2                	mov    %esi,%edx
  801d39:	89 f8                	mov    %edi,%eax
  801d3b:	e8 dc fe ff ff       	call   801c1c <_pipeisclosed>
  801d40:	85 c0                	test   %eax,%eax
  801d42:	75 32                	jne    801d76 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d44:	e8 58 ee ff ff       	call   800ba1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d49:	8b 06                	mov    (%esi),%eax
  801d4b:	3b 46 04             	cmp    0x4(%esi),%eax
  801d4e:	74 df                	je     801d2f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d50:	99                   	cltd   
  801d51:	c1 ea 1b             	shr    $0x1b,%edx
  801d54:	01 d0                	add    %edx,%eax
  801d56:	83 e0 1f             	and    $0x1f,%eax
  801d59:	29 d0                	sub    %edx,%eax
  801d5b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d63:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d66:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d69:	83 c3 01             	add    $0x1,%ebx
  801d6c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d6f:	75 d8                	jne    801d49 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d71:	8b 45 10             	mov    0x10(%ebp),%eax
  801d74:	eb 05                	jmp    801d7b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8e:	50                   	push   %eax
  801d8f:	e8 20 f6 ff ff       	call   8013b4 <fd_alloc>
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	89 c2                	mov    %eax,%edx
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	0f 88 2c 01 00 00    	js     801ecd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da1:	83 ec 04             	sub    $0x4,%esp
  801da4:	68 07 04 00 00       	push   $0x407
  801da9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dac:	6a 00                	push   $0x0
  801dae:	e8 0d ee ff ff       	call   800bc0 <sys_page_alloc>
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	89 c2                	mov    %eax,%edx
  801db8:	85 c0                	test   %eax,%eax
  801dba:	0f 88 0d 01 00 00    	js     801ecd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dc0:	83 ec 0c             	sub    $0xc,%esp
  801dc3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc6:	50                   	push   %eax
  801dc7:	e8 e8 f5 ff ff       	call   8013b4 <fd_alloc>
  801dcc:	89 c3                	mov    %eax,%ebx
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	0f 88 e2 00 00 00    	js     801ebb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	68 07 04 00 00       	push   $0x407
  801de1:	ff 75 f0             	pushl  -0x10(%ebp)
  801de4:	6a 00                	push   $0x0
  801de6:	e8 d5 ed ff ff       	call   800bc0 <sys_page_alloc>
  801deb:	89 c3                	mov    %eax,%ebx
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	85 c0                	test   %eax,%eax
  801df2:	0f 88 c3 00 00 00    	js     801ebb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801df8:	83 ec 0c             	sub    $0xc,%esp
  801dfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfe:	e8 9a f5 ff ff       	call   80139d <fd2data>
  801e03:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e05:	83 c4 0c             	add    $0xc,%esp
  801e08:	68 07 04 00 00       	push   $0x407
  801e0d:	50                   	push   %eax
  801e0e:	6a 00                	push   $0x0
  801e10:	e8 ab ed ff ff       	call   800bc0 <sys_page_alloc>
  801e15:	89 c3                	mov    %eax,%ebx
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	0f 88 89 00 00 00    	js     801eab <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e22:	83 ec 0c             	sub    $0xc,%esp
  801e25:	ff 75 f0             	pushl  -0x10(%ebp)
  801e28:	e8 70 f5 ff ff       	call   80139d <fd2data>
  801e2d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e34:	50                   	push   %eax
  801e35:	6a 00                	push   $0x0
  801e37:	56                   	push   %esi
  801e38:	6a 00                	push   $0x0
  801e3a:	e8 c4 ed ff ff       	call   800c03 <sys_page_map>
  801e3f:	89 c3                	mov    %eax,%ebx
  801e41:	83 c4 20             	add    $0x20,%esp
  801e44:	85 c0                	test   %eax,%eax
  801e46:	78 55                	js     801e9d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e51:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e5d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e66:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e72:	83 ec 0c             	sub    $0xc,%esp
  801e75:	ff 75 f4             	pushl  -0xc(%ebp)
  801e78:	e8 10 f5 ff ff       	call   80138d <fd2num>
  801e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e80:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e82:	83 c4 04             	add    $0x4,%esp
  801e85:	ff 75 f0             	pushl  -0x10(%ebp)
  801e88:	e8 00 f5 ff ff       	call   80138d <fd2num>
  801e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e90:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	ba 00 00 00 00       	mov    $0x0,%edx
  801e9b:	eb 30                	jmp    801ecd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e9d:	83 ec 08             	sub    $0x8,%esp
  801ea0:	56                   	push   %esi
  801ea1:	6a 00                	push   $0x0
  801ea3:	e8 9d ed ff ff       	call   800c45 <sys_page_unmap>
  801ea8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801eab:	83 ec 08             	sub    $0x8,%esp
  801eae:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb1:	6a 00                	push   $0x0
  801eb3:	e8 8d ed ff ff       	call   800c45 <sys_page_unmap>
  801eb8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ebb:	83 ec 08             	sub    $0x8,%esp
  801ebe:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 7d ed ff ff       	call   800c45 <sys_page_unmap>
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ecd:	89 d0                	mov    %edx,%eax
  801ecf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed2:	5b                   	pop    %ebx
  801ed3:	5e                   	pop    %esi
  801ed4:	5d                   	pop    %ebp
  801ed5:	c3                   	ret    

00801ed6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801edc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edf:	50                   	push   %eax
  801ee0:	ff 75 08             	pushl  0x8(%ebp)
  801ee3:	e8 1b f5 ff ff       	call   801403 <fd_lookup>
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 18                	js     801f07 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eef:	83 ec 0c             	sub    $0xc,%esp
  801ef2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef5:	e8 a3 f4 ff ff       	call   80139d <fd2data>
	return _pipeisclosed(fd, p);
  801efa:	89 c2                	mov    %eax,%edx
  801efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eff:	e8 18 fd ff ff       	call   801c1c <_pipeisclosed>
  801f04:	83 c4 10             	add    $0x10,%esp
}
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    

00801f13 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f19:	68 6a 2b 80 00       	push   $0x802b6a
  801f1e:	ff 75 0c             	pushl  0xc(%ebp)
  801f21:	e8 97 e8 ff ff       	call   8007bd <strcpy>
	return 0;
}
  801f26:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	57                   	push   %edi
  801f31:	56                   	push   %esi
  801f32:	53                   	push   %ebx
  801f33:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f39:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f3e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f44:	eb 2d                	jmp    801f73 <devcons_write+0x46>
		m = n - tot;
  801f46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f49:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f4b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f4e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f53:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f56:	83 ec 04             	sub    $0x4,%esp
  801f59:	53                   	push   %ebx
  801f5a:	03 45 0c             	add    0xc(%ebp),%eax
  801f5d:	50                   	push   %eax
  801f5e:	57                   	push   %edi
  801f5f:	e8 eb e9 ff ff       	call   80094f <memmove>
		sys_cputs(buf, m);
  801f64:	83 c4 08             	add    $0x8,%esp
  801f67:	53                   	push   %ebx
  801f68:	57                   	push   %edi
  801f69:	e8 96 eb ff ff       	call   800b04 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f6e:	01 de                	add    %ebx,%esi
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	89 f0                	mov    %esi,%eax
  801f75:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f78:	72 cc                	jb     801f46 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    

00801f82 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	83 ec 08             	sub    $0x8,%esp
  801f88:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f8d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f91:	74 2a                	je     801fbd <devcons_read+0x3b>
  801f93:	eb 05                	jmp    801f9a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f95:	e8 07 ec ff ff       	call   800ba1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f9a:	e8 83 eb ff ff       	call   800b22 <sys_cgetc>
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	74 f2                	je     801f95 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	78 16                	js     801fbd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fa7:	83 f8 04             	cmp    $0x4,%eax
  801faa:	74 0c                	je     801fb8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fac:	8b 55 0c             	mov    0xc(%ebp),%edx
  801faf:	88 02                	mov    %al,(%edx)
	return 1;
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	eb 05                	jmp    801fbd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fbd:	c9                   	leave  
  801fbe:	c3                   	ret    

00801fbf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fcb:	6a 01                	push   $0x1
  801fcd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd0:	50                   	push   %eax
  801fd1:	e8 2e eb ff ff       	call   800b04 <sys_cputs>
}
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    

00801fdb <getchar>:

int
getchar(void)
{
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fe1:	6a 01                	push   $0x1
  801fe3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fe6:	50                   	push   %eax
  801fe7:	6a 00                	push   $0x0
  801fe9:	e8 7e f6 ff ff       	call   80166c <read>
	if (r < 0)
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	78 0f                	js     802004 <getchar+0x29>
		return r;
	if (r < 1)
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	7e 06                	jle    801fff <getchar+0x24>
		return -E_EOF;
	return c;
  801ff9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ffd:	eb 05                	jmp    802004 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fff:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80200c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200f:	50                   	push   %eax
  802010:	ff 75 08             	pushl  0x8(%ebp)
  802013:	e8 eb f3 ff ff       	call   801403 <fd_lookup>
  802018:	83 c4 10             	add    $0x10,%esp
  80201b:	85 c0                	test   %eax,%eax
  80201d:	78 11                	js     802030 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80201f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802022:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802028:	39 10                	cmp    %edx,(%eax)
  80202a:	0f 94 c0             	sete   %al
  80202d:	0f b6 c0             	movzbl %al,%eax
}
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <opencons>:

int
opencons(void)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802038:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203b:	50                   	push   %eax
  80203c:	e8 73 f3 ff ff       	call   8013b4 <fd_alloc>
  802041:	83 c4 10             	add    $0x10,%esp
		return r;
  802044:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802046:	85 c0                	test   %eax,%eax
  802048:	78 3e                	js     802088 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80204a:	83 ec 04             	sub    $0x4,%esp
  80204d:	68 07 04 00 00       	push   $0x407
  802052:	ff 75 f4             	pushl  -0xc(%ebp)
  802055:	6a 00                	push   $0x0
  802057:	e8 64 eb ff ff       	call   800bc0 <sys_page_alloc>
  80205c:	83 c4 10             	add    $0x10,%esp
		return r;
  80205f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802061:	85 c0                	test   %eax,%eax
  802063:	78 23                	js     802088 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802065:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80206b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802070:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802073:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80207a:	83 ec 0c             	sub    $0xc,%esp
  80207d:	50                   	push   %eax
  80207e:	e8 0a f3 ff ff       	call   80138d <fd2num>
  802083:	89 c2                	mov    %eax,%edx
  802085:	83 c4 10             	add    $0x10,%esp
}
  802088:	89 d0                	mov    %edx,%eax
  80208a:	c9                   	leave  
  80208b:	c3                   	ret    

0080208c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802092:	83 3d 00 60 c0 00 00 	cmpl   $0x0,0xc06000
  802099:	75 2a                	jne    8020c5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80209b:	83 ec 04             	sub    $0x4,%esp
  80209e:	6a 07                	push   $0x7
  8020a0:	68 00 f0 bf ee       	push   $0xeebff000
  8020a5:	6a 00                	push   $0x0
  8020a7:	e8 14 eb ff ff       	call   800bc0 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8020ac:	83 c4 10             	add    $0x10,%esp
  8020af:	85 c0                	test   %eax,%eax
  8020b1:	79 12                	jns    8020c5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8020b3:	50                   	push   %eax
  8020b4:	68 f8 29 80 00       	push   $0x8029f8
  8020b9:	6a 23                	push   $0x23
  8020bb:	68 76 2b 80 00       	push   $0x802b76
  8020c0:	e8 9a e0 ff ff       	call   80015f <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c8:	a3 00 60 c0 00       	mov    %eax,0xc06000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8020cd:	83 ec 08             	sub    $0x8,%esp
  8020d0:	68 f7 20 80 00       	push   $0x8020f7
  8020d5:	6a 00                	push   $0x0
  8020d7:	e8 2f ec ff ff       	call   800d0b <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	79 12                	jns    8020f5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8020e3:	50                   	push   %eax
  8020e4:	68 f8 29 80 00       	push   $0x8029f8
  8020e9:	6a 2c                	push   $0x2c
  8020eb:	68 76 2b 80 00       	push   $0x802b76
  8020f0:	e8 6a e0 ff ff       	call   80015f <_panic>
	}
}
  8020f5:	c9                   	leave  
  8020f6:	c3                   	ret    

008020f7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020f7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020f8:	a1 00 60 c0 00       	mov    0xc06000,%eax
	call *%eax
  8020fd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020ff:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802102:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802106:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80210b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80210f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802111:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802114:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802115:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802118:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802119:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80211a:	c3                   	ret    

0080211b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	56                   	push   %esi
  80211f:	53                   	push   %ebx
  802120:	8b 75 08             	mov    0x8(%ebp),%esi
  802123:	8b 45 0c             	mov    0xc(%ebp),%eax
  802126:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802129:	85 c0                	test   %eax,%eax
  80212b:	75 12                	jne    80213f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80212d:	83 ec 0c             	sub    $0xc,%esp
  802130:	68 00 00 c0 ee       	push   $0xeec00000
  802135:	e8 36 ec ff ff       	call   800d70 <sys_ipc_recv>
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	eb 0c                	jmp    80214b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80213f:	83 ec 0c             	sub    $0xc,%esp
  802142:	50                   	push   %eax
  802143:	e8 28 ec ff ff       	call   800d70 <sys_ipc_recv>
  802148:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80214b:	85 f6                	test   %esi,%esi
  80214d:	0f 95 c1             	setne  %cl
  802150:	85 db                	test   %ebx,%ebx
  802152:	0f 95 c2             	setne  %dl
  802155:	84 d1                	test   %dl,%cl
  802157:	74 09                	je     802162 <ipc_recv+0x47>
  802159:	89 c2                	mov    %eax,%edx
  80215b:	c1 ea 1f             	shr    $0x1f,%edx
  80215e:	84 d2                	test   %dl,%dl
  802160:	75 2d                	jne    80218f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802162:	85 f6                	test   %esi,%esi
  802164:	74 0d                	je     802173 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802166:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80216b:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802171:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802173:	85 db                	test   %ebx,%ebx
  802175:	74 0d                	je     802184 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802177:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80217c:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802182:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802184:	a1 20 40 c0 00       	mov    0xc04020,%eax
  802189:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80218f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802192:	5b                   	pop    %ebx
  802193:	5e                   	pop    %esi
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    

00802196 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802196:	55                   	push   %ebp
  802197:	89 e5                	mov    %esp,%ebp
  802199:	57                   	push   %edi
  80219a:	56                   	push   %esi
  80219b:	53                   	push   %ebx
  80219c:	83 ec 0c             	sub    $0xc,%esp
  80219f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8021a8:	85 db                	test   %ebx,%ebx
  8021aa:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021af:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021b2:	ff 75 14             	pushl  0x14(%ebp)
  8021b5:	53                   	push   %ebx
  8021b6:	56                   	push   %esi
  8021b7:	57                   	push   %edi
  8021b8:	e8 90 eb ff ff       	call   800d4d <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8021bd:	89 c2                	mov    %eax,%edx
  8021bf:	c1 ea 1f             	shr    $0x1f,%edx
  8021c2:	83 c4 10             	add    $0x10,%esp
  8021c5:	84 d2                	test   %dl,%dl
  8021c7:	74 17                	je     8021e0 <ipc_send+0x4a>
  8021c9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021cc:	74 12                	je     8021e0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021ce:	50                   	push   %eax
  8021cf:	68 84 2b 80 00       	push   $0x802b84
  8021d4:	6a 47                	push   $0x47
  8021d6:	68 92 2b 80 00       	push   $0x802b92
  8021db:	e8 7f df ff ff       	call   80015f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021e0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021e3:	75 07                	jne    8021ec <ipc_send+0x56>
			sys_yield();
  8021e5:	e8 b7 e9 ff ff       	call   800ba1 <sys_yield>
  8021ea:	eb c6                	jmp    8021b2 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	75 c2                	jne    8021b2 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    

008021f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021fe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802203:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802209:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80220f:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802215:	39 ca                	cmp    %ecx,%edx
  802217:	75 13                	jne    80222c <ipc_find_env+0x34>
			return envs[i].env_id;
  802219:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80221f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802224:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80222a:	eb 0f                	jmp    80223b <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80222c:	83 c0 01             	add    $0x1,%eax
  80222f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802234:	75 cd                	jne    802203 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802236:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    

0080223d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80223d:	55                   	push   %ebp
  80223e:	89 e5                	mov    %esp,%ebp
  802240:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802243:	89 d0                	mov    %edx,%eax
  802245:	c1 e8 16             	shr    $0x16,%eax
  802248:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80224f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802254:	f6 c1 01             	test   $0x1,%cl
  802257:	74 1d                	je     802276 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802259:	c1 ea 0c             	shr    $0xc,%edx
  80225c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802263:	f6 c2 01             	test   $0x1,%dl
  802266:	74 0e                	je     802276 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802268:	c1 ea 0c             	shr    $0xc,%edx
  80226b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802272:	ef 
  802273:	0f b7 c0             	movzwl %ax,%eax
}
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	66 90                	xchg   %ax,%ax
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	66 90                	xchg   %ax,%ax
  80227e:	66 90                	xchg   %ax,%ax

00802280 <__udivdi3>:
  802280:	55                   	push   %ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	53                   	push   %ebx
  802284:	83 ec 1c             	sub    $0x1c,%esp
  802287:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80228b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80228f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802297:	85 f6                	test   %esi,%esi
  802299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80229d:	89 ca                	mov    %ecx,%edx
  80229f:	89 f8                	mov    %edi,%eax
  8022a1:	75 3d                	jne    8022e0 <__udivdi3+0x60>
  8022a3:	39 cf                	cmp    %ecx,%edi
  8022a5:	0f 87 c5 00 00 00    	ja     802370 <__udivdi3+0xf0>
  8022ab:	85 ff                	test   %edi,%edi
  8022ad:	89 fd                	mov    %edi,%ebp
  8022af:	75 0b                	jne    8022bc <__udivdi3+0x3c>
  8022b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b6:	31 d2                	xor    %edx,%edx
  8022b8:	f7 f7                	div    %edi
  8022ba:	89 c5                	mov    %eax,%ebp
  8022bc:	89 c8                	mov    %ecx,%eax
  8022be:	31 d2                	xor    %edx,%edx
  8022c0:	f7 f5                	div    %ebp
  8022c2:	89 c1                	mov    %eax,%ecx
  8022c4:	89 d8                	mov    %ebx,%eax
  8022c6:	89 cf                	mov    %ecx,%edi
  8022c8:	f7 f5                	div    %ebp
  8022ca:	89 c3                	mov    %eax,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	39 ce                	cmp    %ecx,%esi
  8022e2:	77 74                	ja     802358 <__udivdi3+0xd8>
  8022e4:	0f bd fe             	bsr    %esi,%edi
  8022e7:	83 f7 1f             	xor    $0x1f,%edi
  8022ea:	0f 84 98 00 00 00    	je     802388 <__udivdi3+0x108>
  8022f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	89 c5                	mov    %eax,%ebp
  8022f9:	29 fb                	sub    %edi,%ebx
  8022fb:	d3 e6                	shl    %cl,%esi
  8022fd:	89 d9                	mov    %ebx,%ecx
  8022ff:	d3 ed                	shr    %cl,%ebp
  802301:	89 f9                	mov    %edi,%ecx
  802303:	d3 e0                	shl    %cl,%eax
  802305:	09 ee                	or     %ebp,%esi
  802307:	89 d9                	mov    %ebx,%ecx
  802309:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80230d:	89 d5                	mov    %edx,%ebp
  80230f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802313:	d3 ed                	shr    %cl,%ebp
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e2                	shl    %cl,%edx
  802319:	89 d9                	mov    %ebx,%ecx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	09 c2                	or     %eax,%edx
  80231f:	89 d0                	mov    %edx,%eax
  802321:	89 ea                	mov    %ebp,%edx
  802323:	f7 f6                	div    %esi
  802325:	89 d5                	mov    %edx,%ebp
  802327:	89 c3                	mov    %eax,%ebx
  802329:	f7 64 24 0c          	mull   0xc(%esp)
  80232d:	39 d5                	cmp    %edx,%ebp
  80232f:	72 10                	jb     802341 <__udivdi3+0xc1>
  802331:	8b 74 24 08          	mov    0x8(%esp),%esi
  802335:	89 f9                	mov    %edi,%ecx
  802337:	d3 e6                	shl    %cl,%esi
  802339:	39 c6                	cmp    %eax,%esi
  80233b:	73 07                	jae    802344 <__udivdi3+0xc4>
  80233d:	39 d5                	cmp    %edx,%ebp
  80233f:	75 03                	jne    802344 <__udivdi3+0xc4>
  802341:	83 eb 01             	sub    $0x1,%ebx
  802344:	31 ff                	xor    %edi,%edi
  802346:	89 d8                	mov    %ebx,%eax
  802348:	89 fa                	mov    %edi,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	31 ff                	xor    %edi,%edi
  80235a:	31 db                	xor    %ebx,%ebx
  80235c:	89 d8                	mov    %ebx,%eax
  80235e:	89 fa                	mov    %edi,%edx
  802360:	83 c4 1c             	add    $0x1c,%esp
  802363:	5b                   	pop    %ebx
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    
  802368:	90                   	nop
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	89 d8                	mov    %ebx,%eax
  802372:	f7 f7                	div    %edi
  802374:	31 ff                	xor    %edi,%edi
  802376:	89 c3                	mov    %eax,%ebx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 fa                	mov    %edi,%edx
  80237c:	83 c4 1c             	add    $0x1c,%esp
  80237f:	5b                   	pop    %ebx
  802380:	5e                   	pop    %esi
  802381:	5f                   	pop    %edi
  802382:	5d                   	pop    %ebp
  802383:	c3                   	ret    
  802384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802388:	39 ce                	cmp    %ecx,%esi
  80238a:	72 0c                	jb     802398 <__udivdi3+0x118>
  80238c:	31 db                	xor    %ebx,%ebx
  80238e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802392:	0f 87 34 ff ff ff    	ja     8022cc <__udivdi3+0x4c>
  802398:	bb 01 00 00 00       	mov    $0x1,%ebx
  80239d:	e9 2a ff ff ff       	jmp    8022cc <__udivdi3+0x4c>
  8023a2:	66 90                	xchg   %ax,%ax
  8023a4:	66 90                	xchg   %ax,%ax
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	66 90                	xchg   %ax,%ax
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__umoddi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 1c             	sub    $0x1c,%esp
  8023b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023c7:	85 d2                	test   %edx,%edx
  8023c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023d1:	89 f3                	mov    %esi,%ebx
  8023d3:	89 3c 24             	mov    %edi,(%esp)
  8023d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023da:	75 1c                	jne    8023f8 <__umoddi3+0x48>
  8023dc:	39 f7                	cmp    %esi,%edi
  8023de:	76 50                	jbe    802430 <__umoddi3+0x80>
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	f7 f7                	div    %edi
  8023e6:	89 d0                	mov    %edx,%eax
  8023e8:	31 d2                	xor    %edx,%edx
  8023ea:	83 c4 1c             	add    $0x1c,%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    
  8023f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f8:	39 f2                	cmp    %esi,%edx
  8023fa:	89 d0                	mov    %edx,%eax
  8023fc:	77 52                	ja     802450 <__umoddi3+0xa0>
  8023fe:	0f bd ea             	bsr    %edx,%ebp
  802401:	83 f5 1f             	xor    $0x1f,%ebp
  802404:	75 5a                	jne    802460 <__umoddi3+0xb0>
  802406:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80240a:	0f 82 e0 00 00 00    	jb     8024f0 <__umoddi3+0x140>
  802410:	39 0c 24             	cmp    %ecx,(%esp)
  802413:	0f 86 d7 00 00 00    	jbe    8024f0 <__umoddi3+0x140>
  802419:	8b 44 24 08          	mov    0x8(%esp),%eax
  80241d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	85 ff                	test   %edi,%edi
  802432:	89 fd                	mov    %edi,%ebp
  802434:	75 0b                	jne    802441 <__umoddi3+0x91>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f7                	div    %edi
  80243f:	89 c5                	mov    %eax,%ebp
  802441:	89 f0                	mov    %esi,%eax
  802443:	31 d2                	xor    %edx,%edx
  802445:	f7 f5                	div    %ebp
  802447:	89 c8                	mov    %ecx,%eax
  802449:	f7 f5                	div    %ebp
  80244b:	89 d0                	mov    %edx,%eax
  80244d:	eb 99                	jmp    8023e8 <__umoddi3+0x38>
  80244f:	90                   	nop
  802450:	89 c8                	mov    %ecx,%eax
  802452:	89 f2                	mov    %esi,%edx
  802454:	83 c4 1c             	add    $0x1c,%esp
  802457:	5b                   	pop    %ebx
  802458:	5e                   	pop    %esi
  802459:	5f                   	pop    %edi
  80245a:	5d                   	pop    %ebp
  80245b:	c3                   	ret    
  80245c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802460:	8b 34 24             	mov    (%esp),%esi
  802463:	bf 20 00 00 00       	mov    $0x20,%edi
  802468:	89 e9                	mov    %ebp,%ecx
  80246a:	29 ef                	sub    %ebp,%edi
  80246c:	d3 e0                	shl    %cl,%eax
  80246e:	89 f9                	mov    %edi,%ecx
  802470:	89 f2                	mov    %esi,%edx
  802472:	d3 ea                	shr    %cl,%edx
  802474:	89 e9                	mov    %ebp,%ecx
  802476:	09 c2                	or     %eax,%edx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 14 24             	mov    %edx,(%esp)
  80247d:	89 f2                	mov    %esi,%edx
  80247f:	d3 e2                	shl    %cl,%edx
  802481:	89 f9                	mov    %edi,%ecx
  802483:	89 54 24 04          	mov    %edx,0x4(%esp)
  802487:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80248b:	d3 e8                	shr    %cl,%eax
  80248d:	89 e9                	mov    %ebp,%ecx
  80248f:	89 c6                	mov    %eax,%esi
  802491:	d3 e3                	shl    %cl,%ebx
  802493:	89 f9                	mov    %edi,%ecx
  802495:	89 d0                	mov    %edx,%eax
  802497:	d3 e8                	shr    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	09 d8                	or     %ebx,%eax
  80249d:	89 d3                	mov    %edx,%ebx
  80249f:	89 f2                	mov    %esi,%edx
  8024a1:	f7 34 24             	divl   (%esp)
  8024a4:	89 d6                	mov    %edx,%esi
  8024a6:	d3 e3                	shl    %cl,%ebx
  8024a8:	f7 64 24 04          	mull   0x4(%esp)
  8024ac:	39 d6                	cmp    %edx,%esi
  8024ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024b2:	89 d1                	mov    %edx,%ecx
  8024b4:	89 c3                	mov    %eax,%ebx
  8024b6:	72 08                	jb     8024c0 <__umoddi3+0x110>
  8024b8:	75 11                	jne    8024cb <__umoddi3+0x11b>
  8024ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024be:	73 0b                	jae    8024cb <__umoddi3+0x11b>
  8024c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024c4:	1b 14 24             	sbb    (%esp),%edx
  8024c7:	89 d1                	mov    %edx,%ecx
  8024c9:	89 c3                	mov    %eax,%ebx
  8024cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024cf:	29 da                	sub    %ebx,%edx
  8024d1:	19 ce                	sbb    %ecx,%esi
  8024d3:	89 f9                	mov    %edi,%ecx
  8024d5:	89 f0                	mov    %esi,%eax
  8024d7:	d3 e0                	shl    %cl,%eax
  8024d9:	89 e9                	mov    %ebp,%ecx
  8024db:	d3 ea                	shr    %cl,%edx
  8024dd:	89 e9                	mov    %ebp,%ecx
  8024df:	d3 ee                	shr    %cl,%esi
  8024e1:	09 d0                	or     %edx,%eax
  8024e3:	89 f2                	mov    %esi,%edx
  8024e5:	83 c4 1c             	add    $0x1c,%esp
  8024e8:	5b                   	pop    %ebx
  8024e9:	5e                   	pop    %esi
  8024ea:	5f                   	pop    %edi
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    
  8024ed:	8d 76 00             	lea    0x0(%esi),%esi
  8024f0:	29 f9                	sub    %edi,%ecx
  8024f2:	19 d6                	sbb    %edx,%esi
  8024f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024fc:	e9 18 ff ff ff       	jmp    802419 <__umoddi3+0x69>
