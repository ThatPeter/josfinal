
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
  800039:	68 a0 24 80 00       	push   $0x8024a0
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
  800056:	68 1b 25 80 00       	push   $0x80251b
  80005b:	6a 11                	push   $0x11
  80005d:	68 38 25 80 00       	push   $0x802538
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
  800096:	68 c0 24 80 00       	push   $0x8024c0
  80009b:	6a 16                	push   $0x16
  80009d:	68 38 25 80 00       	push   $0x802538
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
  8000b4:	68 e8 24 80 00       	push   $0x8024e8
  8000b9:	e8 7a 01 00 00       	call   800238 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 47 25 80 00       	push   $0x802547
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 38 25 80 00       	push   $0x802538
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
  8000f1:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8000f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fc:	a3 20 40 c0 00       	mov    %eax,0xc04020

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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 08             	sub    $0x8,%esp
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
  80014b:	e8 8d 13 00 00       	call   8014dd <close_all>
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
  80017d:	68 68 25 80 00       	push   $0x802568
  800182:	e8 b1 00 00 00       	call   800238 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800187:	83 c4 18             	add    $0x18,%esp
  80018a:	53                   	push   %ebx
  80018b:	ff 75 10             	pushl  0x10(%ebp)
  80018e:	e8 54 00 00 00       	call   8001e7 <vcprintf>
	cprintf("\n");
  800193:	c7 04 24 36 25 80 00 	movl   $0x802536,(%esp)
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
  80029b:	e8 60 1f 00 00       	call   802200 <__udivdi3>
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
  8002de:	e8 4d 20 00 00       	call   802330 <__umoddi3>
  8002e3:	83 c4 14             	add    $0x14,%esp
  8002e6:	0f be 80 8b 25 80 00 	movsbl 0x80258b(%eax),%eax
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
  8003e2:	ff 24 85 c0 26 80 00 	jmp    *0x8026c0(,%eax,4)
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
  8004a6:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  8004ad:	85 d2                	test   %edx,%edx
  8004af:	75 18                	jne    8004c9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004b1:	50                   	push   %eax
  8004b2:	68 a3 25 80 00       	push   $0x8025a3
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
  8004ca:	68 e1 29 80 00       	push   $0x8029e1
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
  8004ee:	b8 9c 25 80 00       	mov    $0x80259c,%eax
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
  800b69:	68 7f 28 80 00       	push   $0x80287f
  800b6e:	6a 23                	push   $0x23
  800b70:	68 9c 28 80 00       	push   $0x80289c
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
  800bea:	68 7f 28 80 00       	push   $0x80287f
  800bef:	6a 23                	push   $0x23
  800bf1:	68 9c 28 80 00       	push   $0x80289c
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
  800c2c:	68 7f 28 80 00       	push   $0x80287f
  800c31:	6a 23                	push   $0x23
  800c33:	68 9c 28 80 00       	push   $0x80289c
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
  800c6e:	68 7f 28 80 00       	push   $0x80287f
  800c73:	6a 23                	push   $0x23
  800c75:	68 9c 28 80 00       	push   $0x80289c
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
  800cb0:	68 7f 28 80 00       	push   $0x80287f
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 9c 28 80 00       	push   $0x80289c
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
  800cf2:	68 7f 28 80 00       	push   $0x80287f
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 9c 28 80 00       	push   $0x80289c
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
  800d34:	68 7f 28 80 00       	push   $0x80287f
  800d39:	6a 23                	push   $0x23
  800d3b:	68 9c 28 80 00       	push   $0x80289c
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
  800d98:	68 7f 28 80 00       	push   $0x80287f
  800d9d:	6a 23                	push   $0x23
  800d9f:	68 9c 28 80 00       	push   $0x80289c
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
  800e37:	68 aa 28 80 00       	push   $0x8028aa
  800e3c:	6a 1f                	push   $0x1f
  800e3e:	68 ba 28 80 00       	push   $0x8028ba
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
  800e61:	68 c5 28 80 00       	push   $0x8028c5
  800e66:	6a 2d                	push   $0x2d
  800e68:	68 ba 28 80 00       	push   $0x8028ba
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
  800ea9:	68 c5 28 80 00       	push   $0x8028c5
  800eae:	6a 34                	push   $0x34
  800eb0:	68 ba 28 80 00       	push   $0x8028ba
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
  800ed1:	68 c5 28 80 00       	push   $0x8028c5
  800ed6:	6a 38                	push   $0x38
  800ed8:	68 ba 28 80 00       	push   $0x8028ba
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
  800ef5:	e8 14 11 00 00       	call   80200e <set_pgfault_handler>
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
  800f0e:	68 de 28 80 00       	push   $0x8028de
  800f13:	68 85 00 00 00       	push   $0x85
  800f18:	68 ba 28 80 00       	push   $0x8028ba
  800f1d:	e8 3d f2 ff ff       	call   80015f <_panic>
  800f22:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f24:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f28:	75 24                	jne    800f4e <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2a:	e8 53 fc ff ff       	call   800b82 <sys_getenvid>
  800f2f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f34:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
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
  800fca:	68 ec 28 80 00       	push   $0x8028ec
  800fcf:	6a 55                	push   $0x55
  800fd1:	68 ba 28 80 00       	push   $0x8028ba
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
  80100f:	68 ec 28 80 00       	push   $0x8028ec
  801014:	6a 5c                	push   $0x5c
  801016:	68 ba 28 80 00       	push   $0x8028ba
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
  80103d:	68 ec 28 80 00       	push   $0x8028ec
  801042:	6a 60                	push   $0x60
  801044:	68 ba 28 80 00       	push   $0x8028ba
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
  801067:	68 ec 28 80 00       	push   $0x8028ec
  80106c:	6a 65                	push   $0x65
  80106e:	68 ba 28 80 00       	push   $0x8028ba
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
  80108f:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
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

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8010ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cd:	a3 24 40 c0 00       	mov    %eax,0xc04024
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010d2:	68 25 01 80 00       	push   $0x800125
  8010d7:	e8 d5 fc ff ff       	call   800db1 <sys_thread_create>

	return id;
}
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8010e4:	ff 75 08             	pushl  0x8(%ebp)
  8010e7:	e8 e5 fc ff ff       	call   800dd1 <sys_thread_free>
}
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8010f7:	ff 75 08             	pushl  0x8(%ebp)
  8010fa:	e8 f2 fc ff ff       	call   800df1 <sys_thread_join>
}
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	8b 75 08             	mov    0x8(%ebp),%esi
  80110c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80110f:	83 ec 04             	sub    $0x4,%esp
  801112:	6a 07                	push   $0x7
  801114:	6a 00                	push   $0x0
  801116:	56                   	push   %esi
  801117:	e8 a4 fa ff ff       	call   800bc0 <sys_page_alloc>
	if (r < 0) {
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	79 15                	jns    801138 <queue_append+0x34>
		panic("%e\n", r);
  801123:	50                   	push   %eax
  801124:	68 32 29 80 00       	push   $0x802932
  801129:	68 d5 00 00 00       	push   $0xd5
  80112e:	68 ba 28 80 00       	push   $0x8028ba
  801133:	e8 27 f0 ff ff       	call   80015f <_panic>
	}	

	wt->envid = envid;
  801138:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  80113e:	83 3b 00             	cmpl   $0x0,(%ebx)
  801141:	75 13                	jne    801156 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801143:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80114a:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801151:	00 00 00 
  801154:	eb 1b                	jmp    801171 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801156:	8b 43 04             	mov    0x4(%ebx),%eax
  801159:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801160:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801167:	00 00 00 
		queue->last = wt;
  80116a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801181:	8b 02                	mov    (%edx),%eax
  801183:	85 c0                	test   %eax,%eax
  801185:	75 17                	jne    80119e <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801187:	83 ec 04             	sub    $0x4,%esp
  80118a:	68 02 29 80 00       	push   $0x802902
  80118f:	68 ec 00 00 00       	push   $0xec
  801194:	68 ba 28 80 00       	push   $0x8028ba
  801199:	e8 c1 ef ff ff       	call   80015f <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80119e:	8b 48 04             	mov    0x4(%eax),%ecx
  8011a1:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  8011a3:	8b 00                	mov    (%eax),%eax
}
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    

008011a7 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	56                   	push   %esi
  8011ab:	53                   	push   %ebx
  8011ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8011af:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b4:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	74 4a                	je     801205 <mutex_lock+0x5e>
  8011bb:	8b 73 04             	mov    0x4(%ebx),%esi
  8011be:	83 3e 00             	cmpl   $0x0,(%esi)
  8011c1:	75 42                	jne    801205 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  8011c3:	e8 ba f9 ff ff       	call   800b82 <sys_getenvid>
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	56                   	push   %esi
  8011cc:	50                   	push   %eax
  8011cd:	e8 32 ff ff ff       	call   801104 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8011d2:	e8 ab f9 ff ff       	call   800b82 <sys_getenvid>
  8011d7:	83 c4 08             	add    $0x8,%esp
  8011da:	6a 04                	push   $0x4
  8011dc:	50                   	push   %eax
  8011dd:	e8 a5 fa ff ff       	call   800c87 <sys_env_set_status>

		if (r < 0) {
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	79 15                	jns    8011fe <mutex_lock+0x57>
			panic("%e\n", r);
  8011e9:	50                   	push   %eax
  8011ea:	68 32 29 80 00       	push   $0x802932
  8011ef:	68 02 01 00 00       	push   $0x102
  8011f4:	68 ba 28 80 00       	push   $0x8028ba
  8011f9:	e8 61 ef ff ff       	call   80015f <_panic>
		}
		sys_yield();
  8011fe:	e8 9e f9 ff ff       	call   800ba1 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801203:	eb 08                	jmp    80120d <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  801205:	e8 78 f9 ff ff       	call   800b82 <sys_getenvid>
  80120a:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  80120d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	53                   	push   %ebx
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
  801223:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801226:	8b 43 04             	mov    0x4(%ebx),%eax
  801229:	83 38 00             	cmpl   $0x0,(%eax)
  80122c:	74 33                	je     801261 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80122e:	83 ec 0c             	sub    $0xc,%esp
  801231:	50                   	push   %eax
  801232:	e8 41 ff ff ff       	call   801178 <queue_pop>
  801237:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80123a:	83 c4 08             	add    $0x8,%esp
  80123d:	6a 02                	push   $0x2
  80123f:	50                   	push   %eax
  801240:	e8 42 fa ff ff       	call   800c87 <sys_env_set_status>
		if (r < 0) {
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	79 15                	jns    801261 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80124c:	50                   	push   %eax
  80124d:	68 32 29 80 00       	push   $0x802932
  801252:	68 16 01 00 00       	push   $0x116
  801257:	68 ba 28 80 00       	push   $0x8028ba
  80125c:	e8 fe ee ff ff       	call   80015f <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  801261:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	53                   	push   %ebx
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801270:	e8 0d f9 ff ff       	call   800b82 <sys_getenvid>
  801275:	83 ec 04             	sub    $0x4,%esp
  801278:	6a 07                	push   $0x7
  80127a:	53                   	push   %ebx
  80127b:	50                   	push   %eax
  80127c:	e8 3f f9 ff ff       	call   800bc0 <sys_page_alloc>
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	79 15                	jns    80129d <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801288:	50                   	push   %eax
  801289:	68 1d 29 80 00       	push   $0x80291d
  80128e:	68 22 01 00 00       	push   $0x122
  801293:	68 ba 28 80 00       	push   $0x8028ba
  801298:	e8 c2 ee ff ff       	call   80015f <_panic>
	}	
	mtx->locked = 0;
  80129d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8012a3:	8b 43 04             	mov    0x4(%ebx),%eax
  8012a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8012ac:	8b 43 04             	mov    0x4(%ebx),%eax
  8012af:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8012b6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8012bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 04             	sub    $0x4,%esp
  8012c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  8012cc:	eb 21                	jmp    8012ef <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	50                   	push   %eax
  8012d2:	e8 a1 fe ff ff       	call   801178 <queue_pop>
  8012d7:	83 c4 08             	add    $0x8,%esp
  8012da:	6a 02                	push   $0x2
  8012dc:	50                   	push   %eax
  8012dd:	e8 a5 f9 ff ff       	call   800c87 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8012e2:	8b 43 04             	mov    0x4(%ebx),%eax
  8012e5:	8b 10                	mov    (%eax),%edx
  8012e7:	8b 52 04             	mov    0x4(%edx),%edx
  8012ea:	89 10                	mov    %edx,(%eax)
  8012ec:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8012ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8012f2:	83 38 00             	cmpl   $0x0,(%eax)
  8012f5:	75 d7                	jne    8012ce <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	68 00 10 00 00       	push   $0x1000
  8012ff:	6a 00                	push   $0x0
  801301:	53                   	push   %ebx
  801302:	e8 fb f5 ff ff       	call   800902 <memset>
	mtx = NULL;
}
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	05 00 00 00 30       	add    $0x30000000,%eax
  80131a:	c1 e8 0c             	shr    $0xc,%eax
}
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    

0080131f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801322:	8b 45 08             	mov    0x8(%ebp),%eax
  801325:	05 00 00 00 30       	add    $0x30000000,%eax
  80132a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80132f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801341:	89 c2                	mov    %eax,%edx
  801343:	c1 ea 16             	shr    $0x16,%edx
  801346:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134d:	f6 c2 01             	test   $0x1,%dl
  801350:	74 11                	je     801363 <fd_alloc+0x2d>
  801352:	89 c2                	mov    %eax,%edx
  801354:	c1 ea 0c             	shr    $0xc,%edx
  801357:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135e:	f6 c2 01             	test   $0x1,%dl
  801361:	75 09                	jne    80136c <fd_alloc+0x36>
			*fd_store = fd;
  801363:	89 01                	mov    %eax,(%ecx)
			return 0;
  801365:	b8 00 00 00 00       	mov    $0x0,%eax
  80136a:	eb 17                	jmp    801383 <fd_alloc+0x4d>
  80136c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801371:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801376:	75 c9                	jne    801341 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801378:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80137e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80138b:	83 f8 1f             	cmp    $0x1f,%eax
  80138e:	77 36                	ja     8013c6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801390:	c1 e0 0c             	shl    $0xc,%eax
  801393:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801398:	89 c2                	mov    %eax,%edx
  80139a:	c1 ea 16             	shr    $0x16,%edx
  80139d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a4:	f6 c2 01             	test   $0x1,%dl
  8013a7:	74 24                	je     8013cd <fd_lookup+0x48>
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	c1 ea 0c             	shr    $0xc,%edx
  8013ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b5:	f6 c2 01             	test   $0x1,%dl
  8013b8:	74 1a                	je     8013d4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013bd:	89 02                	mov    %eax,(%edx)
	return 0;
  8013bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c4:	eb 13                	jmp    8013d9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013cb:	eb 0c                	jmp    8013d9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d2:	eb 05                	jmp    8013d9 <fd_lookup+0x54>
  8013d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e4:	ba b8 29 80 00       	mov    $0x8029b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013e9:	eb 13                	jmp    8013fe <dev_lookup+0x23>
  8013eb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ee:	39 08                	cmp    %ecx,(%eax)
  8013f0:	75 0c                	jne    8013fe <dev_lookup+0x23>
			*dev = devtab[i];
  8013f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fc:	eb 31                	jmp    80142f <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013fe:	8b 02                	mov    (%edx),%eax
  801400:	85 c0                	test   %eax,%eax
  801402:	75 e7                	jne    8013eb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801404:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801409:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80140f:	83 ec 04             	sub    $0x4,%esp
  801412:	51                   	push   %ecx
  801413:	50                   	push   %eax
  801414:	68 38 29 80 00       	push   $0x802938
  801419:	e8 1a ee ff ff       	call   800238 <cprintf>
	*dev = 0;
  80141e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801421:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	83 ec 10             	sub    $0x10,%esp
  801439:	8b 75 08             	mov    0x8(%ebp),%esi
  80143c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80143f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801449:	c1 e8 0c             	shr    $0xc,%eax
  80144c:	50                   	push   %eax
  80144d:	e8 33 ff ff ff       	call   801385 <fd_lookup>
  801452:	83 c4 08             	add    $0x8,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 05                	js     80145e <fd_close+0x2d>
	    || fd != fd2)
  801459:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80145c:	74 0c                	je     80146a <fd_close+0x39>
		return (must_exist ? r : 0);
  80145e:	84 db                	test   %bl,%bl
  801460:	ba 00 00 00 00       	mov    $0x0,%edx
  801465:	0f 44 c2             	cmove  %edx,%eax
  801468:	eb 41                	jmp    8014ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801470:	50                   	push   %eax
  801471:	ff 36                	pushl  (%esi)
  801473:	e8 63 ff ff ff       	call   8013db <dev_lookup>
  801478:	89 c3                	mov    %eax,%ebx
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 1a                	js     80149b <fd_close+0x6a>
		if (dev->dev_close)
  801481:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801484:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801487:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80148c:	85 c0                	test   %eax,%eax
  80148e:	74 0b                	je     80149b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801490:	83 ec 0c             	sub    $0xc,%esp
  801493:	56                   	push   %esi
  801494:	ff d0                	call   *%eax
  801496:	89 c3                	mov    %eax,%ebx
  801498:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	56                   	push   %esi
  80149f:	6a 00                	push   $0x0
  8014a1:	e8 9f f7 ff ff       	call   800c45 <sys_page_unmap>
	return r;
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	89 d8                	mov    %ebx,%eax
}
  8014ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5d                   	pop    %ebp
  8014b1:	c3                   	ret    

008014b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	ff 75 08             	pushl  0x8(%ebp)
  8014bf:	e8 c1 fe ff ff       	call   801385 <fd_lookup>
  8014c4:	83 c4 08             	add    $0x8,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 10                	js     8014db <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	6a 01                	push   $0x1
  8014d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d3:	e8 59 ff ff ff       	call   801431 <fd_close>
  8014d8:	83 c4 10             	add    $0x10,%esp
}
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <close_all>:

void
close_all(void)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014e9:	83 ec 0c             	sub    $0xc,%esp
  8014ec:	53                   	push   %ebx
  8014ed:	e8 c0 ff ff ff       	call   8014b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f2:	83 c3 01             	add    $0x1,%ebx
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	83 fb 20             	cmp    $0x20,%ebx
  8014fb:	75 ec                	jne    8014e9 <close_all+0xc>
		close(i);
}
  8014fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801500:	c9                   	leave  
  801501:	c3                   	ret    

00801502 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	57                   	push   %edi
  801506:	56                   	push   %esi
  801507:	53                   	push   %ebx
  801508:	83 ec 2c             	sub    $0x2c,%esp
  80150b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80150e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801511:	50                   	push   %eax
  801512:	ff 75 08             	pushl  0x8(%ebp)
  801515:	e8 6b fe ff ff       	call   801385 <fd_lookup>
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	0f 88 c1 00 00 00    	js     8015e6 <dup+0xe4>
		return r;
	close(newfdnum);
  801525:	83 ec 0c             	sub    $0xc,%esp
  801528:	56                   	push   %esi
  801529:	e8 84 ff ff ff       	call   8014b2 <close>

	newfd = INDEX2FD(newfdnum);
  80152e:	89 f3                	mov    %esi,%ebx
  801530:	c1 e3 0c             	shl    $0xc,%ebx
  801533:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801539:	83 c4 04             	add    $0x4,%esp
  80153c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153f:	e8 db fd ff ff       	call   80131f <fd2data>
  801544:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801546:	89 1c 24             	mov    %ebx,(%esp)
  801549:	e8 d1 fd ff ff       	call   80131f <fd2data>
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801554:	89 f8                	mov    %edi,%eax
  801556:	c1 e8 16             	shr    $0x16,%eax
  801559:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801560:	a8 01                	test   $0x1,%al
  801562:	74 37                	je     80159b <dup+0x99>
  801564:	89 f8                	mov    %edi,%eax
  801566:	c1 e8 0c             	shr    $0xc,%eax
  801569:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801570:	f6 c2 01             	test   $0x1,%dl
  801573:	74 26                	je     80159b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801575:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	25 07 0e 00 00       	and    $0xe07,%eax
  801584:	50                   	push   %eax
  801585:	ff 75 d4             	pushl  -0x2c(%ebp)
  801588:	6a 00                	push   $0x0
  80158a:	57                   	push   %edi
  80158b:	6a 00                	push   $0x0
  80158d:	e8 71 f6 ff ff       	call   800c03 <sys_page_map>
  801592:	89 c7                	mov    %eax,%edi
  801594:	83 c4 20             	add    $0x20,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 2e                	js     8015c9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80159b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80159e:	89 d0                	mov    %edx,%eax
  8015a0:	c1 e8 0c             	shr    $0xc,%eax
  8015a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b2:	50                   	push   %eax
  8015b3:	53                   	push   %ebx
  8015b4:	6a 00                	push   $0x0
  8015b6:	52                   	push   %edx
  8015b7:	6a 00                	push   $0x0
  8015b9:	e8 45 f6 ff ff       	call   800c03 <sys_page_map>
  8015be:	89 c7                	mov    %eax,%edi
  8015c0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015c3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015c5:	85 ff                	test   %edi,%edi
  8015c7:	79 1d                	jns    8015e6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	53                   	push   %ebx
  8015cd:	6a 00                	push   $0x0
  8015cf:	e8 71 f6 ff ff       	call   800c45 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015da:	6a 00                	push   $0x0
  8015dc:	e8 64 f6 ff ff       	call   800c45 <sys_page_unmap>
	return r;
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	89 f8                	mov    %edi,%eax
}
  8015e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5f                   	pop    %edi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 14             	sub    $0x14,%esp
  8015f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	53                   	push   %ebx
  8015fd:	e8 83 fd ff ff       	call   801385 <fd_lookup>
  801602:	83 c4 08             	add    $0x8,%esp
  801605:	89 c2                	mov    %eax,%edx
  801607:	85 c0                	test   %eax,%eax
  801609:	78 70                	js     80167b <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801615:	ff 30                	pushl  (%eax)
  801617:	e8 bf fd ff ff       	call   8013db <dev_lookup>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 4f                	js     801672 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801623:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801626:	8b 42 08             	mov    0x8(%edx),%eax
  801629:	83 e0 03             	and    $0x3,%eax
  80162c:	83 f8 01             	cmp    $0x1,%eax
  80162f:	75 24                	jne    801655 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801631:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801636:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	53                   	push   %ebx
  801640:	50                   	push   %eax
  801641:	68 7c 29 80 00       	push   $0x80297c
  801646:	e8 ed eb ff ff       	call   800238 <cprintf>
		return -E_INVAL;
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801653:	eb 26                	jmp    80167b <read+0x8d>
	}
	if (!dev->dev_read)
  801655:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801658:	8b 40 08             	mov    0x8(%eax),%eax
  80165b:	85 c0                	test   %eax,%eax
  80165d:	74 17                	je     801676 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	ff 75 10             	pushl  0x10(%ebp)
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	52                   	push   %edx
  801669:	ff d0                	call   *%eax
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	eb 09                	jmp    80167b <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801672:	89 c2                	mov    %eax,%edx
  801674:	eb 05                	jmp    80167b <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801676:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80167b:	89 d0                	mov    %edx,%eax
  80167d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	57                   	push   %edi
  801686:	56                   	push   %esi
  801687:	53                   	push   %ebx
  801688:	83 ec 0c             	sub    $0xc,%esp
  80168b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801691:	bb 00 00 00 00       	mov    $0x0,%ebx
  801696:	eb 21                	jmp    8016b9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801698:	83 ec 04             	sub    $0x4,%esp
  80169b:	89 f0                	mov    %esi,%eax
  80169d:	29 d8                	sub    %ebx,%eax
  80169f:	50                   	push   %eax
  8016a0:	89 d8                	mov    %ebx,%eax
  8016a2:	03 45 0c             	add    0xc(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	57                   	push   %edi
  8016a7:	e8 42 ff ff ff       	call   8015ee <read>
		if (m < 0)
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 10                	js     8016c3 <readn+0x41>
			return m;
		if (m == 0)
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	74 0a                	je     8016c1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b7:	01 c3                	add    %eax,%ebx
  8016b9:	39 f3                	cmp    %esi,%ebx
  8016bb:	72 db                	jb     801698 <readn+0x16>
  8016bd:	89 d8                	mov    %ebx,%eax
  8016bf:	eb 02                	jmp    8016c3 <readn+0x41>
  8016c1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5f                   	pop    %edi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    

008016cb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	53                   	push   %ebx
  8016cf:	83 ec 14             	sub    $0x14,%esp
  8016d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d8:	50                   	push   %eax
  8016d9:	53                   	push   %ebx
  8016da:	e8 a6 fc ff ff       	call   801385 <fd_lookup>
  8016df:	83 c4 08             	add    $0x8,%esp
  8016e2:	89 c2                	mov    %eax,%edx
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 6b                	js     801753 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ee:	50                   	push   %eax
  8016ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f2:	ff 30                	pushl  (%eax)
  8016f4:	e8 e2 fc ff ff       	call   8013db <dev_lookup>
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 4a                	js     80174a <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801700:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801703:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801707:	75 24                	jne    80172d <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801709:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80170e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	53                   	push   %ebx
  801718:	50                   	push   %eax
  801719:	68 98 29 80 00       	push   $0x802998
  80171e:	e8 15 eb ff ff       	call   800238 <cprintf>
		return -E_INVAL;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172b:	eb 26                	jmp    801753 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801730:	8b 52 0c             	mov    0xc(%edx),%edx
  801733:	85 d2                	test   %edx,%edx
  801735:	74 17                	je     80174e <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	ff 75 10             	pushl  0x10(%ebp)
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	50                   	push   %eax
  801741:	ff d2                	call   *%edx
  801743:	89 c2                	mov    %eax,%edx
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	eb 09                	jmp    801753 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	eb 05                	jmp    801753 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80174e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801753:	89 d0                	mov    %edx,%eax
  801755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <seek>:

int
seek(int fdnum, off_t offset)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801760:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	ff 75 08             	pushl  0x8(%ebp)
  801767:	e8 19 fc ff ff       	call   801385 <fd_lookup>
  80176c:	83 c4 08             	add    $0x8,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 0e                	js     801781 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801773:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801776:	8b 55 0c             	mov    0xc(%ebp),%edx
  801779:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	53                   	push   %ebx
  801787:	83 ec 14             	sub    $0x14,%esp
  80178a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801790:	50                   	push   %eax
  801791:	53                   	push   %ebx
  801792:	e8 ee fb ff ff       	call   801385 <fd_lookup>
  801797:	83 c4 08             	add    $0x8,%esp
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 68                	js     801808 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017aa:	ff 30                	pushl  (%eax)
  8017ac:	e8 2a fc ff ff       	call   8013db <dev_lookup>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 47                	js     8017ff <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bf:	75 24                	jne    8017e5 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c1:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8017cc:	83 ec 04             	sub    $0x4,%esp
  8017cf:	53                   	push   %ebx
  8017d0:	50                   	push   %eax
  8017d1:	68 58 29 80 00       	push   $0x802958
  8017d6:	e8 5d ea ff ff       	call   800238 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e3:	eb 23                	jmp    801808 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e8:	8b 52 18             	mov    0x18(%edx),%edx
  8017eb:	85 d2                	test   %edx,%edx
  8017ed:	74 14                	je     801803 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	ff 75 0c             	pushl  0xc(%ebp)
  8017f5:	50                   	push   %eax
  8017f6:	ff d2                	call   *%edx
  8017f8:	89 c2                	mov    %eax,%edx
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	eb 09                	jmp    801808 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ff:	89 c2                	mov    %eax,%edx
  801801:	eb 05                	jmp    801808 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801803:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801808:	89 d0                	mov    %edx,%eax
  80180a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	53                   	push   %ebx
  801813:	83 ec 14             	sub    $0x14,%esp
  801816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801819:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181c:	50                   	push   %eax
  80181d:	ff 75 08             	pushl  0x8(%ebp)
  801820:	e8 60 fb ff ff       	call   801385 <fd_lookup>
  801825:	83 c4 08             	add    $0x8,%esp
  801828:	89 c2                	mov    %eax,%edx
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 58                	js     801886 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801834:	50                   	push   %eax
  801835:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801838:	ff 30                	pushl  (%eax)
  80183a:	e8 9c fb ff ff       	call   8013db <dev_lookup>
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	78 37                	js     80187d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801846:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801849:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80184d:	74 32                	je     801881 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80184f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801852:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801859:	00 00 00 
	stat->st_isdir = 0;
  80185c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801863:	00 00 00 
	stat->st_dev = dev;
  801866:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80186c:	83 ec 08             	sub    $0x8,%esp
  80186f:	53                   	push   %ebx
  801870:	ff 75 f0             	pushl  -0x10(%ebp)
  801873:	ff 50 14             	call   *0x14(%eax)
  801876:	89 c2                	mov    %eax,%edx
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	eb 09                	jmp    801886 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187d:	89 c2                	mov    %eax,%edx
  80187f:	eb 05                	jmp    801886 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801881:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801886:	89 d0                	mov    %edx,%eax
  801888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    

0080188d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	56                   	push   %esi
  801891:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	6a 00                	push   $0x0
  801897:	ff 75 08             	pushl  0x8(%ebp)
  80189a:	e8 e3 01 00 00       	call   801a82 <open>
  80189f:	89 c3                	mov    %eax,%ebx
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 1b                	js     8018c3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	ff 75 0c             	pushl  0xc(%ebp)
  8018ae:	50                   	push   %eax
  8018af:	e8 5b ff ff ff       	call   80180f <fstat>
  8018b4:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b6:	89 1c 24             	mov    %ebx,(%esp)
  8018b9:	e8 f4 fb ff ff       	call   8014b2 <close>
	return r;
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	89 f0                	mov    %esi,%eax
}
  8018c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	56                   	push   %esi
  8018ce:	53                   	push   %ebx
  8018cf:	89 c6                	mov    %eax,%esi
  8018d1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018da:	75 12                	jne    8018ee <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018dc:	83 ec 0c             	sub    $0xc,%esp
  8018df:	6a 01                	push   $0x1
  8018e1:	e8 94 08 00 00       	call   80217a <ipc_find_env>
  8018e6:	a3 00 40 80 00       	mov    %eax,0x804000
  8018eb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ee:	6a 07                	push   $0x7
  8018f0:	68 00 50 c0 00       	push   $0xc05000
  8018f5:	56                   	push   %esi
  8018f6:	ff 35 00 40 80 00    	pushl  0x804000
  8018fc:	e8 17 08 00 00       	call   802118 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801901:	83 c4 0c             	add    $0xc,%esp
  801904:	6a 00                	push   $0x0
  801906:	53                   	push   %ebx
  801907:	6a 00                	push   $0x0
  801909:	e8 8f 07 00 00       	call   80209d <ipc_recv>
}
  80190e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801911:	5b                   	pop    %ebx
  801912:	5e                   	pop    %esi
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80191b:	8b 45 08             	mov    0x8(%ebp),%eax
  80191e:	8b 40 0c             	mov    0xc(%eax),%eax
  801921:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801926:	8b 45 0c             	mov    0xc(%ebp),%eax
  801929:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80192e:	ba 00 00 00 00       	mov    $0x0,%edx
  801933:	b8 02 00 00 00       	mov    $0x2,%eax
  801938:	e8 8d ff ff ff       	call   8018ca <fsipc>
}
  80193d:	c9                   	leave  
  80193e:	c3                   	ret    

0080193f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801945:	8b 45 08             	mov    0x8(%ebp),%eax
  801948:	8b 40 0c             	mov    0xc(%eax),%eax
  80194b:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801950:	ba 00 00 00 00       	mov    $0x0,%edx
  801955:	b8 06 00 00 00       	mov    $0x6,%eax
  80195a:	e8 6b ff ff ff       	call   8018ca <fsipc>
}
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	53                   	push   %ebx
  801965:	83 ec 04             	sub    $0x4,%esp
  801968:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80196b:	8b 45 08             	mov    0x8(%ebp),%eax
  80196e:	8b 40 0c             	mov    0xc(%eax),%eax
  801971:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801976:	ba 00 00 00 00       	mov    $0x0,%edx
  80197b:	b8 05 00 00 00       	mov    $0x5,%eax
  801980:	e8 45 ff ff ff       	call   8018ca <fsipc>
  801985:	85 c0                	test   %eax,%eax
  801987:	78 2c                	js     8019b5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801989:	83 ec 08             	sub    $0x8,%esp
  80198c:	68 00 50 c0 00       	push   $0xc05000
  801991:	53                   	push   %ebx
  801992:	e8 26 ee ff ff       	call   8007bd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801997:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80199c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a2:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8019a7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8019c6:	8b 52 0c             	mov    0xc(%edx),%edx
  8019c9:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019cf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019d9:	0f 47 c2             	cmova  %edx,%eax
  8019dc:	a3 04 50 c0 00       	mov    %eax,0xc05004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019e1:	50                   	push   %eax
  8019e2:	ff 75 0c             	pushl  0xc(%ebp)
  8019e5:	68 08 50 c0 00       	push   $0xc05008
  8019ea:	e8 60 ef ff ff       	call   80094f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f4:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f9:	e8 cc fe ff ff       	call   8018ca <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a08:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801a13:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a19:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a23:	e8 a2 fe ff ff       	call   8018ca <fsipc>
  801a28:	89 c3                	mov    %eax,%ebx
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 4b                	js     801a79 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a2e:	39 c6                	cmp    %eax,%esi
  801a30:	73 16                	jae    801a48 <devfile_read+0x48>
  801a32:	68 c8 29 80 00       	push   $0x8029c8
  801a37:	68 cf 29 80 00       	push   $0x8029cf
  801a3c:	6a 7c                	push   $0x7c
  801a3e:	68 e4 29 80 00       	push   $0x8029e4
  801a43:	e8 17 e7 ff ff       	call   80015f <_panic>
	assert(r <= PGSIZE);
  801a48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a4d:	7e 16                	jle    801a65 <devfile_read+0x65>
  801a4f:	68 ef 29 80 00       	push   $0x8029ef
  801a54:	68 cf 29 80 00       	push   $0x8029cf
  801a59:	6a 7d                	push   $0x7d
  801a5b:	68 e4 29 80 00       	push   $0x8029e4
  801a60:	e8 fa e6 ff ff       	call   80015f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a65:	83 ec 04             	sub    $0x4,%esp
  801a68:	50                   	push   %eax
  801a69:	68 00 50 c0 00       	push   $0xc05000
  801a6e:	ff 75 0c             	pushl  0xc(%ebp)
  801a71:	e8 d9 ee ff ff       	call   80094f <memmove>
	return r;
  801a76:	83 c4 10             	add    $0x10,%esp
}
  801a79:	89 d8                	mov    %ebx,%eax
  801a7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	53                   	push   %ebx
  801a86:	83 ec 20             	sub    $0x20,%esp
  801a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a8c:	53                   	push   %ebx
  801a8d:	e8 f2 ec ff ff       	call   800784 <strlen>
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a9a:	7f 67                	jg     801b03 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa2:	50                   	push   %eax
  801aa3:	e8 8e f8 ff ff       	call   801336 <fd_alloc>
  801aa8:	83 c4 10             	add    $0x10,%esp
		return r;
  801aab:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 57                	js     801b08 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ab1:	83 ec 08             	sub    $0x8,%esp
  801ab4:	53                   	push   %ebx
  801ab5:	68 00 50 c0 00       	push   $0xc05000
  801aba:	e8 fe ec ff ff       	call   8007bd <strcpy>
	fsipcbuf.open.req_omode = mode;
  801abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac2:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aca:	b8 01 00 00 00       	mov    $0x1,%eax
  801acf:	e8 f6 fd ff ff       	call   8018ca <fsipc>
  801ad4:	89 c3                	mov    %eax,%ebx
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	79 14                	jns    801af1 <open+0x6f>
		fd_close(fd, 0);
  801add:	83 ec 08             	sub    $0x8,%esp
  801ae0:	6a 00                	push   $0x0
  801ae2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae5:	e8 47 f9 ff ff       	call   801431 <fd_close>
		return r;
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	89 da                	mov    %ebx,%edx
  801aef:	eb 17                	jmp    801b08 <open+0x86>
	}

	return fd2num(fd);
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	ff 75 f4             	pushl  -0xc(%ebp)
  801af7:	e8 13 f8 ff ff       	call   80130f <fd2num>
  801afc:	89 c2                	mov    %eax,%edx
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	eb 05                	jmp    801b08 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b03:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b08:	89 d0                	mov    %edx,%eax
  801b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b15:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1a:	b8 08 00 00 00       	mov    $0x8,%eax
  801b1f:	e8 a6 fd ff ff       	call   8018ca <fsipc>
}
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    

00801b26 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b2e:	83 ec 0c             	sub    $0xc,%esp
  801b31:	ff 75 08             	pushl  0x8(%ebp)
  801b34:	e8 e6 f7 ff ff       	call   80131f <fd2data>
  801b39:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b3b:	83 c4 08             	add    $0x8,%esp
  801b3e:	68 fb 29 80 00       	push   $0x8029fb
  801b43:	53                   	push   %ebx
  801b44:	e8 74 ec ff ff       	call   8007bd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b49:	8b 46 04             	mov    0x4(%esi),%eax
  801b4c:	2b 06                	sub    (%esi),%eax
  801b4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b54:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b5b:	00 00 00 
	stat->st_dev = &devpipe;
  801b5e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b65:	30 80 00 
	return 0;
}
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5e                   	pop    %esi
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	53                   	push   %ebx
  801b78:	83 ec 0c             	sub    $0xc,%esp
  801b7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b7e:	53                   	push   %ebx
  801b7f:	6a 00                	push   $0x0
  801b81:	e8 bf f0 ff ff       	call   800c45 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b86:	89 1c 24             	mov    %ebx,(%esp)
  801b89:	e8 91 f7 ff ff       	call   80131f <fd2data>
  801b8e:	83 c4 08             	add    $0x8,%esp
  801b91:	50                   	push   %eax
  801b92:	6a 00                	push   $0x0
  801b94:	e8 ac f0 ff ff       	call   800c45 <sys_page_unmap>
}
  801b99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801baa:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bac:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801bb1:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbd:	e8 fd 05 00 00       	call   8021bf <pageref>
  801bc2:	89 c3                	mov    %eax,%ebx
  801bc4:	89 3c 24             	mov    %edi,(%esp)
  801bc7:	e8 f3 05 00 00       	call   8021bf <pageref>
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	39 c3                	cmp    %eax,%ebx
  801bd1:	0f 94 c1             	sete   %cl
  801bd4:	0f b6 c9             	movzbl %cl,%ecx
  801bd7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bda:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801be0:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801be6:	39 ce                	cmp    %ecx,%esi
  801be8:	74 1e                	je     801c08 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801bea:	39 c3                	cmp    %eax,%ebx
  801bec:	75 be                	jne    801bac <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bee:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801bf4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf7:	50                   	push   %eax
  801bf8:	56                   	push   %esi
  801bf9:	68 02 2a 80 00       	push   $0x802a02
  801bfe:	e8 35 e6 ff ff       	call   800238 <cprintf>
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	eb a4                	jmp    801bac <_pipeisclosed+0xe>
	}
}
  801c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5e                   	pop    %esi
  801c10:	5f                   	pop    %edi
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	57                   	push   %edi
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	83 ec 28             	sub    $0x28,%esp
  801c1c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c1f:	56                   	push   %esi
  801c20:	e8 fa f6 ff ff       	call   80131f <fd2data>
  801c25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	bf 00 00 00 00       	mov    $0x0,%edi
  801c2f:	eb 4b                	jmp    801c7c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c31:	89 da                	mov    %ebx,%edx
  801c33:	89 f0                	mov    %esi,%eax
  801c35:	e8 64 ff ff ff       	call   801b9e <_pipeisclosed>
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	75 48                	jne    801c86 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c3e:	e8 5e ef ff ff       	call   800ba1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c43:	8b 43 04             	mov    0x4(%ebx),%eax
  801c46:	8b 0b                	mov    (%ebx),%ecx
  801c48:	8d 51 20             	lea    0x20(%ecx),%edx
  801c4b:	39 d0                	cmp    %edx,%eax
  801c4d:	73 e2                	jae    801c31 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c52:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c56:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c59:	89 c2                	mov    %eax,%edx
  801c5b:	c1 fa 1f             	sar    $0x1f,%edx
  801c5e:	89 d1                	mov    %edx,%ecx
  801c60:	c1 e9 1b             	shr    $0x1b,%ecx
  801c63:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c66:	83 e2 1f             	and    $0x1f,%edx
  801c69:	29 ca                	sub    %ecx,%edx
  801c6b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c73:	83 c0 01             	add    $0x1,%eax
  801c76:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c79:	83 c7 01             	add    $0x1,%edi
  801c7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7f:	75 c2                	jne    801c43 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c81:	8b 45 10             	mov    0x10(%ebp),%eax
  801c84:	eb 05                	jmp    801c8b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c86:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	57                   	push   %edi
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	83 ec 18             	sub    $0x18,%esp
  801c9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c9f:	57                   	push   %edi
  801ca0:	e8 7a f6 ff ff       	call   80131f <fd2data>
  801ca5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801caf:	eb 3d                	jmp    801cee <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cb1:	85 db                	test   %ebx,%ebx
  801cb3:	74 04                	je     801cb9 <devpipe_read+0x26>
				return i;
  801cb5:	89 d8                	mov    %ebx,%eax
  801cb7:	eb 44                	jmp    801cfd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cb9:	89 f2                	mov    %esi,%edx
  801cbb:	89 f8                	mov    %edi,%eax
  801cbd:	e8 dc fe ff ff       	call   801b9e <_pipeisclosed>
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	75 32                	jne    801cf8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cc6:	e8 d6 ee ff ff       	call   800ba1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ccb:	8b 06                	mov    (%esi),%eax
  801ccd:	3b 46 04             	cmp    0x4(%esi),%eax
  801cd0:	74 df                	je     801cb1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cd2:	99                   	cltd   
  801cd3:	c1 ea 1b             	shr    $0x1b,%edx
  801cd6:	01 d0                	add    %edx,%eax
  801cd8:	83 e0 1f             	and    $0x1f,%eax
  801cdb:	29 d0                	sub    %edx,%eax
  801cdd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ce8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ceb:	83 c3 01             	add    $0x1,%ebx
  801cee:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cf1:	75 d8                	jne    801ccb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf3:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf6:	eb 05                	jmp    801cfd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	56                   	push   %esi
  801d09:	53                   	push   %ebx
  801d0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	e8 20 f6 ff ff       	call   801336 <fd_alloc>
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	89 c2                	mov    %eax,%edx
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	0f 88 2c 01 00 00    	js     801e4f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d23:	83 ec 04             	sub    $0x4,%esp
  801d26:	68 07 04 00 00       	push   $0x407
  801d2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2e:	6a 00                	push   $0x0
  801d30:	e8 8b ee ff ff       	call   800bc0 <sys_page_alloc>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	89 c2                	mov    %eax,%edx
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	0f 88 0d 01 00 00    	js     801e4f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d42:	83 ec 0c             	sub    $0xc,%esp
  801d45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d48:	50                   	push   %eax
  801d49:	e8 e8 f5 ff ff       	call   801336 <fd_alloc>
  801d4e:	89 c3                	mov    %eax,%ebx
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	85 c0                	test   %eax,%eax
  801d55:	0f 88 e2 00 00 00    	js     801e3d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5b:	83 ec 04             	sub    $0x4,%esp
  801d5e:	68 07 04 00 00       	push   $0x407
  801d63:	ff 75 f0             	pushl  -0x10(%ebp)
  801d66:	6a 00                	push   $0x0
  801d68:	e8 53 ee ff ff       	call   800bc0 <sys_page_alloc>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	0f 88 c3 00 00 00    	js     801e3d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d7a:	83 ec 0c             	sub    $0xc,%esp
  801d7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d80:	e8 9a f5 ff ff       	call   80131f <fd2data>
  801d85:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d87:	83 c4 0c             	add    $0xc,%esp
  801d8a:	68 07 04 00 00       	push   $0x407
  801d8f:	50                   	push   %eax
  801d90:	6a 00                	push   $0x0
  801d92:	e8 29 ee ff ff       	call   800bc0 <sys_page_alloc>
  801d97:	89 c3                	mov    %eax,%ebx
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	0f 88 89 00 00 00    	js     801e2d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	ff 75 f0             	pushl  -0x10(%ebp)
  801daa:	e8 70 f5 ff ff       	call   80131f <fd2data>
  801daf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801db6:	50                   	push   %eax
  801db7:	6a 00                	push   $0x0
  801db9:	56                   	push   %esi
  801dba:	6a 00                	push   $0x0
  801dbc:	e8 42 ee ff ff       	call   800c03 <sys_page_map>
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	83 c4 20             	add    $0x20,%esp
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	78 55                	js     801e1f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ddf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ded:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df4:	83 ec 0c             	sub    $0xc,%esp
  801df7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfa:	e8 10 f5 ff ff       	call   80130f <fd2num>
  801dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e02:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e04:	83 c4 04             	add    $0x4,%esp
  801e07:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0a:	e8 00 f5 ff ff       	call   80130f <fd2num>
  801e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e12:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1d:	eb 30                	jmp    801e4f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e1f:	83 ec 08             	sub    $0x8,%esp
  801e22:	56                   	push   %esi
  801e23:	6a 00                	push   $0x0
  801e25:	e8 1b ee ff ff       	call   800c45 <sys_page_unmap>
  801e2a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e2d:	83 ec 08             	sub    $0x8,%esp
  801e30:	ff 75 f0             	pushl  -0x10(%ebp)
  801e33:	6a 00                	push   $0x0
  801e35:	e8 0b ee ff ff       	call   800c45 <sys_page_unmap>
  801e3a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	ff 75 f4             	pushl  -0xc(%ebp)
  801e43:	6a 00                	push   $0x0
  801e45:	e8 fb ed ff ff       	call   800c45 <sys_page_unmap>
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e4f:	89 d0                	mov    %edx,%eax
  801e51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e61:	50                   	push   %eax
  801e62:	ff 75 08             	pushl  0x8(%ebp)
  801e65:	e8 1b f5 ff ff       	call   801385 <fd_lookup>
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 18                	js     801e89 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	e8 a3 f4 ff ff       	call   80131f <fd2data>
	return _pipeisclosed(fd, p);
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e81:	e8 18 fd ff ff       	call   801b9e <_pipeisclosed>
  801e86:	83 c4 10             	add    $0x10,%esp
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e9b:	68 1a 2a 80 00       	push   $0x802a1a
  801ea0:	ff 75 0c             	pushl  0xc(%ebp)
  801ea3:	e8 15 e9 ff ff       	call   8007bd <strcpy>
	return 0;
}
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	57                   	push   %edi
  801eb3:	56                   	push   %esi
  801eb4:	53                   	push   %ebx
  801eb5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ebb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec6:	eb 2d                	jmp    801ef5 <devcons_write+0x46>
		m = n - tot;
  801ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ecb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ecd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ed0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ed5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed8:	83 ec 04             	sub    $0x4,%esp
  801edb:	53                   	push   %ebx
  801edc:	03 45 0c             	add    0xc(%ebp),%eax
  801edf:	50                   	push   %eax
  801ee0:	57                   	push   %edi
  801ee1:	e8 69 ea ff ff       	call   80094f <memmove>
		sys_cputs(buf, m);
  801ee6:	83 c4 08             	add    $0x8,%esp
  801ee9:	53                   	push   %ebx
  801eea:	57                   	push   %edi
  801eeb:	e8 14 ec ff ff       	call   800b04 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef0:	01 de                	add    %ebx,%esi
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	89 f0                	mov    %esi,%eax
  801ef7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801efa:	72 cc                	jb     801ec8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801efc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    

00801f04 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	83 ec 08             	sub    $0x8,%esp
  801f0a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f13:	74 2a                	je     801f3f <devcons_read+0x3b>
  801f15:	eb 05                	jmp    801f1c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f17:	e8 85 ec ff ff       	call   800ba1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f1c:	e8 01 ec ff ff       	call   800b22 <sys_cgetc>
  801f21:	85 c0                	test   %eax,%eax
  801f23:	74 f2                	je     801f17 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 16                	js     801f3f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f29:	83 f8 04             	cmp    $0x4,%eax
  801f2c:	74 0c                	je     801f3a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f31:	88 02                	mov    %al,(%edx)
	return 1;
  801f33:	b8 01 00 00 00       	mov    $0x1,%eax
  801f38:	eb 05                	jmp    801f3f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f3a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    

00801f41 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f47:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f4d:	6a 01                	push   $0x1
  801f4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f52:	50                   	push   %eax
  801f53:	e8 ac eb ff ff       	call   800b04 <sys_cputs>
}
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <getchar>:

int
getchar(void)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f63:	6a 01                	push   $0x1
  801f65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f68:	50                   	push   %eax
  801f69:	6a 00                	push   $0x0
  801f6b:	e8 7e f6 ff ff       	call   8015ee <read>
	if (r < 0)
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 0f                	js     801f86 <getchar+0x29>
		return r;
	if (r < 1)
  801f77:	85 c0                	test   %eax,%eax
  801f79:	7e 06                	jle    801f81 <getchar+0x24>
		return -E_EOF;
	return c;
  801f7b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f7f:	eb 05                	jmp    801f86 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f81:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f91:	50                   	push   %eax
  801f92:	ff 75 08             	pushl  0x8(%ebp)
  801f95:	e8 eb f3 ff ff       	call   801385 <fd_lookup>
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 11                	js     801fb2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801faa:	39 10                	cmp    %edx,(%eax)
  801fac:	0f 94 c0             	sete   %al
  801faf:	0f b6 c0             	movzbl %al,%eax
}
  801fb2:	c9                   	leave  
  801fb3:	c3                   	ret    

00801fb4 <opencons>:

int
opencons(void)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	e8 73 f3 ff ff       	call   801336 <fd_alloc>
  801fc3:	83 c4 10             	add    $0x10,%esp
		return r;
  801fc6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	78 3e                	js     80200a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fcc:	83 ec 04             	sub    $0x4,%esp
  801fcf:	68 07 04 00 00       	push   $0x407
  801fd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd7:	6a 00                	push   $0x0
  801fd9:	e8 e2 eb ff ff       	call   800bc0 <sys_page_alloc>
  801fde:	83 c4 10             	add    $0x10,%esp
		return r;
  801fe1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	78 23                	js     80200a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fe7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ffc:	83 ec 0c             	sub    $0xc,%esp
  801fff:	50                   	push   %eax
  802000:	e8 0a f3 ff ff       	call   80130f <fd2num>
  802005:	89 c2                	mov    %eax,%edx
  802007:	83 c4 10             	add    $0x10,%esp
}
  80200a:	89 d0                	mov    %edx,%eax
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802014:	83 3d 00 60 c0 00 00 	cmpl   $0x0,0xc06000
  80201b:	75 2a                	jne    802047 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80201d:	83 ec 04             	sub    $0x4,%esp
  802020:	6a 07                	push   $0x7
  802022:	68 00 f0 bf ee       	push   $0xeebff000
  802027:	6a 00                	push   $0x0
  802029:	e8 92 eb ff ff       	call   800bc0 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	79 12                	jns    802047 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802035:	50                   	push   %eax
  802036:	68 32 29 80 00       	push   $0x802932
  80203b:	6a 23                	push   $0x23
  80203d:	68 26 2a 80 00       	push   $0x802a26
  802042:	e8 18 e1 ff ff       	call   80015f <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802047:	8b 45 08             	mov    0x8(%ebp),%eax
  80204a:	a3 00 60 c0 00       	mov    %eax,0xc06000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80204f:	83 ec 08             	sub    $0x8,%esp
  802052:	68 79 20 80 00       	push   $0x802079
  802057:	6a 00                	push   $0x0
  802059:	e8 ad ec ff ff       	call   800d0b <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	85 c0                	test   %eax,%eax
  802063:	79 12                	jns    802077 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802065:	50                   	push   %eax
  802066:	68 32 29 80 00       	push   $0x802932
  80206b:	6a 2c                	push   $0x2c
  80206d:	68 26 2a 80 00       	push   $0x802a26
  802072:	e8 e8 e0 ff ff       	call   80015f <_panic>
	}
}
  802077:	c9                   	leave  
  802078:	c3                   	ret    

00802079 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802079:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80207a:	a1 00 60 c0 00       	mov    0xc06000,%eax
	call *%eax
  80207f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802081:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802084:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802088:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80208d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802091:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802093:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802096:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802097:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80209a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80209b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80209c:	c3                   	ret    

0080209d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	56                   	push   %esi
  8020a1:	53                   	push   %ebx
  8020a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8020a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	75 12                	jne    8020c1 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020af:	83 ec 0c             	sub    $0xc,%esp
  8020b2:	68 00 00 c0 ee       	push   $0xeec00000
  8020b7:	e8 b4 ec ff ff       	call   800d70 <sys_ipc_recv>
  8020bc:	83 c4 10             	add    $0x10,%esp
  8020bf:	eb 0c                	jmp    8020cd <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020c1:	83 ec 0c             	sub    $0xc,%esp
  8020c4:	50                   	push   %eax
  8020c5:	e8 a6 ec ff ff       	call   800d70 <sys_ipc_recv>
  8020ca:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020cd:	85 f6                	test   %esi,%esi
  8020cf:	0f 95 c1             	setne  %cl
  8020d2:	85 db                	test   %ebx,%ebx
  8020d4:	0f 95 c2             	setne  %dl
  8020d7:	84 d1                	test   %dl,%cl
  8020d9:	74 09                	je     8020e4 <ipc_recv+0x47>
  8020db:	89 c2                	mov    %eax,%edx
  8020dd:	c1 ea 1f             	shr    $0x1f,%edx
  8020e0:	84 d2                	test   %dl,%dl
  8020e2:	75 2d                	jne    802111 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020e4:	85 f6                	test   %esi,%esi
  8020e6:	74 0d                	je     8020f5 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020e8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8020ed:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8020f3:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020f5:	85 db                	test   %ebx,%ebx
  8020f7:	74 0d                	je     802106 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020f9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8020fe:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802104:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802106:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80210b:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    

00802118 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	57                   	push   %edi
  80211c:	56                   	push   %esi
  80211d:	53                   	push   %ebx
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	8b 7d 08             	mov    0x8(%ebp),%edi
  802124:	8b 75 0c             	mov    0xc(%ebp),%esi
  802127:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80212a:	85 db                	test   %ebx,%ebx
  80212c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802131:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802134:	ff 75 14             	pushl  0x14(%ebp)
  802137:	53                   	push   %ebx
  802138:	56                   	push   %esi
  802139:	57                   	push   %edi
  80213a:	e8 0e ec ff ff       	call   800d4d <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80213f:	89 c2                	mov    %eax,%edx
  802141:	c1 ea 1f             	shr    $0x1f,%edx
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	84 d2                	test   %dl,%dl
  802149:	74 17                	je     802162 <ipc_send+0x4a>
  80214b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80214e:	74 12                	je     802162 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802150:	50                   	push   %eax
  802151:	68 34 2a 80 00       	push   $0x802a34
  802156:	6a 47                	push   $0x47
  802158:	68 42 2a 80 00       	push   $0x802a42
  80215d:	e8 fd df ff ff       	call   80015f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802162:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802165:	75 07                	jne    80216e <ipc_send+0x56>
			sys_yield();
  802167:	e8 35 ea ff ff       	call   800ba1 <sys_yield>
  80216c:	eb c6                	jmp    802134 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80216e:	85 c0                	test   %eax,%eax
  802170:	75 c2                	jne    802134 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802172:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802175:	5b                   	pop    %ebx
  802176:	5e                   	pop    %esi
  802177:	5f                   	pop    %edi
  802178:	5d                   	pop    %ebp
  802179:	c3                   	ret    

0080217a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802180:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802185:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80218b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802191:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802197:	39 ca                	cmp    %ecx,%edx
  802199:	75 13                	jne    8021ae <ipc_find_env+0x34>
			return envs[i].env_id;
  80219b:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8021a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021a6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8021ac:	eb 0f                	jmp    8021bd <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021ae:	83 c0 01             	add    $0x1,%eax
  8021b1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021b6:	75 cd                	jne    802185 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    

008021bf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
  8021c2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	c1 e8 16             	shr    $0x16,%eax
  8021ca:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021d1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d6:	f6 c1 01             	test   $0x1,%cl
  8021d9:	74 1d                	je     8021f8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021db:	c1 ea 0c             	shr    $0xc,%edx
  8021de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021e5:	f6 c2 01             	test   $0x1,%dl
  8021e8:	74 0e                	je     8021f8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ea:	c1 ea 0c             	shr    $0xc,%edx
  8021ed:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021f4:	ef 
  8021f5:	0f b7 c0             	movzwl %ax,%eax
}
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__udivdi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80220b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80220f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 f6                	test   %esi,%esi
  802219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80221d:	89 ca                	mov    %ecx,%edx
  80221f:	89 f8                	mov    %edi,%eax
  802221:	75 3d                	jne    802260 <__udivdi3+0x60>
  802223:	39 cf                	cmp    %ecx,%edi
  802225:	0f 87 c5 00 00 00    	ja     8022f0 <__udivdi3+0xf0>
  80222b:	85 ff                	test   %edi,%edi
  80222d:	89 fd                	mov    %edi,%ebp
  80222f:	75 0b                	jne    80223c <__udivdi3+0x3c>
  802231:	b8 01 00 00 00       	mov    $0x1,%eax
  802236:	31 d2                	xor    %edx,%edx
  802238:	f7 f7                	div    %edi
  80223a:	89 c5                	mov    %eax,%ebp
  80223c:	89 c8                	mov    %ecx,%eax
  80223e:	31 d2                	xor    %edx,%edx
  802240:	f7 f5                	div    %ebp
  802242:	89 c1                	mov    %eax,%ecx
  802244:	89 d8                	mov    %ebx,%eax
  802246:	89 cf                	mov    %ecx,%edi
  802248:	f7 f5                	div    %ebp
  80224a:	89 c3                	mov    %eax,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	39 ce                	cmp    %ecx,%esi
  802262:	77 74                	ja     8022d8 <__udivdi3+0xd8>
  802264:	0f bd fe             	bsr    %esi,%edi
  802267:	83 f7 1f             	xor    $0x1f,%edi
  80226a:	0f 84 98 00 00 00    	je     802308 <__udivdi3+0x108>
  802270:	bb 20 00 00 00       	mov    $0x20,%ebx
  802275:	89 f9                	mov    %edi,%ecx
  802277:	89 c5                	mov    %eax,%ebp
  802279:	29 fb                	sub    %edi,%ebx
  80227b:	d3 e6                	shl    %cl,%esi
  80227d:	89 d9                	mov    %ebx,%ecx
  80227f:	d3 ed                	shr    %cl,%ebp
  802281:	89 f9                	mov    %edi,%ecx
  802283:	d3 e0                	shl    %cl,%eax
  802285:	09 ee                	or     %ebp,%esi
  802287:	89 d9                	mov    %ebx,%ecx
  802289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228d:	89 d5                	mov    %edx,%ebp
  80228f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802293:	d3 ed                	shr    %cl,%ebp
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e2                	shl    %cl,%edx
  802299:	89 d9                	mov    %ebx,%ecx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	09 c2                	or     %eax,%edx
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	89 ea                	mov    %ebp,%edx
  8022a3:	f7 f6                	div    %esi
  8022a5:	89 d5                	mov    %edx,%ebp
  8022a7:	89 c3                	mov    %eax,%ebx
  8022a9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	72 10                	jb     8022c1 <__udivdi3+0xc1>
  8022b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e6                	shl    %cl,%esi
  8022b9:	39 c6                	cmp    %eax,%esi
  8022bb:	73 07                	jae    8022c4 <__udivdi3+0xc4>
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	75 03                	jne    8022c4 <__udivdi3+0xc4>
  8022c1:	83 eb 01             	sub    $0x1,%ebx
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 d8                	mov    %ebx,%eax
  8022c8:	89 fa                	mov    %edi,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	31 ff                	xor    %edi,%edi
  8022da:	31 db                	xor    %ebx,%ebx
  8022dc:	89 d8                	mov    %ebx,%eax
  8022de:	89 fa                	mov    %edi,%edx
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	89 d8                	mov    %ebx,%eax
  8022f2:	f7 f7                	div    %edi
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	89 c3                	mov    %eax,%ebx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 fa                	mov    %edi,%edx
  8022fc:	83 c4 1c             	add    $0x1c,%esp
  8022ff:	5b                   	pop    %ebx
  802300:	5e                   	pop    %esi
  802301:	5f                   	pop    %edi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	39 ce                	cmp    %ecx,%esi
  80230a:	72 0c                	jb     802318 <__udivdi3+0x118>
  80230c:	31 db                	xor    %ebx,%ebx
  80230e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802312:	0f 87 34 ff ff ff    	ja     80224c <__udivdi3+0x4c>
  802318:	bb 01 00 00 00       	mov    $0x1,%ebx
  80231d:	e9 2a ff ff ff       	jmp    80224c <__udivdi3+0x4c>
  802322:	66 90                	xchg   %ax,%ax
  802324:	66 90                	xchg   %ax,%ax
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__umoddi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80233b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80233f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 d2                	test   %edx,%edx
  802349:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80234d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802351:	89 f3                	mov    %esi,%ebx
  802353:	89 3c 24             	mov    %edi,(%esp)
  802356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235a:	75 1c                	jne    802378 <__umoddi3+0x48>
  80235c:	39 f7                	cmp    %esi,%edi
  80235e:	76 50                	jbe    8023b0 <__umoddi3+0x80>
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	f7 f7                	div    %edi
  802366:	89 d0                	mov    %edx,%eax
  802368:	31 d2                	xor    %edx,%edx
  80236a:	83 c4 1c             	add    $0x1c,%esp
  80236d:	5b                   	pop    %ebx
  80236e:	5e                   	pop    %esi
  80236f:	5f                   	pop    %edi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
  802372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802378:	39 f2                	cmp    %esi,%edx
  80237a:	89 d0                	mov    %edx,%eax
  80237c:	77 52                	ja     8023d0 <__umoddi3+0xa0>
  80237e:	0f bd ea             	bsr    %edx,%ebp
  802381:	83 f5 1f             	xor    $0x1f,%ebp
  802384:	75 5a                	jne    8023e0 <__umoddi3+0xb0>
  802386:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80238a:	0f 82 e0 00 00 00    	jb     802470 <__umoddi3+0x140>
  802390:	39 0c 24             	cmp    %ecx,(%esp)
  802393:	0f 86 d7 00 00 00    	jbe    802470 <__umoddi3+0x140>
  802399:	8b 44 24 08          	mov    0x8(%esp),%eax
  80239d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023a1:	83 c4 1c             	add    $0x1c,%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5e                   	pop    %esi
  8023a6:	5f                   	pop    %edi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	85 ff                	test   %edi,%edi
  8023b2:	89 fd                	mov    %edi,%ebp
  8023b4:	75 0b                	jne    8023c1 <__umoddi3+0x91>
  8023b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	f7 f7                	div    %edi
  8023bf:	89 c5                	mov    %eax,%ebp
  8023c1:	89 f0                	mov    %esi,%eax
  8023c3:	31 d2                	xor    %edx,%edx
  8023c5:	f7 f5                	div    %ebp
  8023c7:	89 c8                	mov    %ecx,%eax
  8023c9:	f7 f5                	div    %ebp
  8023cb:	89 d0                	mov    %edx,%eax
  8023cd:	eb 99                	jmp    802368 <__umoddi3+0x38>
  8023cf:	90                   	nop
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	83 c4 1c             	add    $0x1c,%esp
  8023d7:	5b                   	pop    %ebx
  8023d8:	5e                   	pop    %esi
  8023d9:	5f                   	pop    %edi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	8b 34 24             	mov    (%esp),%esi
  8023e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023e8:	89 e9                	mov    %ebp,%ecx
  8023ea:	29 ef                	sub    %ebp,%edi
  8023ec:	d3 e0                	shl    %cl,%eax
  8023ee:	89 f9                	mov    %edi,%ecx
  8023f0:	89 f2                	mov    %esi,%edx
  8023f2:	d3 ea                	shr    %cl,%edx
  8023f4:	89 e9                	mov    %ebp,%ecx
  8023f6:	09 c2                	or     %eax,%edx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 14 24             	mov    %edx,(%esp)
  8023fd:	89 f2                	mov    %esi,%edx
  8023ff:	d3 e2                	shl    %cl,%edx
  802401:	89 f9                	mov    %edi,%ecx
  802403:	89 54 24 04          	mov    %edx,0x4(%esp)
  802407:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80240b:	d3 e8                	shr    %cl,%eax
  80240d:	89 e9                	mov    %ebp,%ecx
  80240f:	89 c6                	mov    %eax,%esi
  802411:	d3 e3                	shl    %cl,%ebx
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 d0                	mov    %edx,%eax
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	09 d8                	or     %ebx,%eax
  80241d:	89 d3                	mov    %edx,%ebx
  80241f:	89 f2                	mov    %esi,%edx
  802421:	f7 34 24             	divl   (%esp)
  802424:	89 d6                	mov    %edx,%esi
  802426:	d3 e3                	shl    %cl,%ebx
  802428:	f7 64 24 04          	mull   0x4(%esp)
  80242c:	39 d6                	cmp    %edx,%esi
  80242e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802432:	89 d1                	mov    %edx,%ecx
  802434:	89 c3                	mov    %eax,%ebx
  802436:	72 08                	jb     802440 <__umoddi3+0x110>
  802438:	75 11                	jne    80244b <__umoddi3+0x11b>
  80243a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80243e:	73 0b                	jae    80244b <__umoddi3+0x11b>
  802440:	2b 44 24 04          	sub    0x4(%esp),%eax
  802444:	1b 14 24             	sbb    (%esp),%edx
  802447:	89 d1                	mov    %edx,%ecx
  802449:	89 c3                	mov    %eax,%ebx
  80244b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80244f:	29 da                	sub    %ebx,%edx
  802451:	19 ce                	sbb    %ecx,%esi
  802453:	89 f9                	mov    %edi,%ecx
  802455:	89 f0                	mov    %esi,%eax
  802457:	d3 e0                	shl    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	d3 ea                	shr    %cl,%edx
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	d3 ee                	shr    %cl,%esi
  802461:	09 d0                	or     %edx,%eax
  802463:	89 f2                	mov    %esi,%edx
  802465:	83 c4 1c             	add    $0x1c,%esp
  802468:	5b                   	pop    %ebx
  802469:	5e                   	pop    %esi
  80246a:	5f                   	pop    %edi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	8d 76 00             	lea    0x0(%esi),%esi
  802470:	29 f9                	sub    %edi,%ecx
  802472:	19 d6                	sbb    %edx,%esi
  802474:	89 74 24 04          	mov    %esi,0x4(%esp)
  802478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80247c:	e9 18 ff ff ff       	jmp    802399 <__umoddi3+0x69>
