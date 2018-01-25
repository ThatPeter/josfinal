
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
  800039:	68 60 22 80 00       	push   $0x802260
  80003e:	e8 f6 01 00 00       	call   800239 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 db 22 80 00       	push   $0x8022db
  80005b:	6a 11                	push   $0x11
  80005d:	68 f8 22 80 00       	push   $0x8022f8
  800062:	e8 f9 00 00 00       	call   800160 <_panic>
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
  800096:	68 80 22 80 00       	push   $0x802280
  80009b:	6a 16                	push   $0x16
  80009d:	68 f8 22 80 00       	push   $0x8022f8
  8000a2:	e8 b9 00 00 00       	call   800160 <_panic>
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
  8000b4:	68 a8 22 80 00       	push   $0x8022a8
  8000b9:	e8 7b 01 00 00       	call   800239 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 07 23 80 00       	push   $0x802307
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 f8 22 80 00       	push   $0x8022f8
  8000d7:	e8 84 00 00 00       	call   800160 <_panic>

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
  8000e7:	e8 97 0a 00 00       	call   800b83 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	89 c2                	mov    %eax,%edx
  8000f3:	c1 e2 07             	shl    $0x7,%edx
  8000f6:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000fd:	a3 20 40 c0 00       	mov    %eax,0xc04020
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800102:	85 db                	test   %ebx,%ebx
  800104:	7e 07                	jle    80010d <libmain+0x31>
		binaryname = argv[0];
  800106:	8b 06                	mov    (%esi),%eax
  800108:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010d:	83 ec 08             	sub    $0x8,%esp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	e8 1c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800117:	e8 2a 00 00 00       	call   800146 <exit>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80012c:	a1 24 40 c0 00       	mov    0xc04024,%eax
	func();
  800131:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800133:	e8 4b 0a 00 00       	call   800b83 <sys_getenvid>
  800138:	83 ec 0c             	sub    $0xc,%esp
  80013b:	50                   	push   %eax
  80013c:	e8 91 0c 00 00       	call   800dd2 <sys_thread_free>
}
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014c:	e8 5e 11 00 00       	call   8012af <close_all>
	sys_env_destroy(0);
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	6a 00                	push   $0x0
  800156:	e8 e7 09 00 00       	call   800b42 <sys_env_destroy>
}
  80015b:	83 c4 10             	add    $0x10,%esp
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800165:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800168:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80016e:	e8 10 0a 00 00       	call   800b83 <sys_getenvid>
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	ff 75 0c             	pushl  0xc(%ebp)
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	56                   	push   %esi
  80017d:	50                   	push   %eax
  80017e:	68 28 23 80 00       	push   $0x802328
  800183:	e8 b1 00 00 00       	call   800239 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	83 c4 18             	add    $0x18,%esp
  80018b:	53                   	push   %ebx
  80018c:	ff 75 10             	pushl  0x10(%ebp)
  80018f:	e8 54 00 00 00       	call   8001e8 <vcprintf>
	cprintf("\n");
  800194:	c7 04 24 f6 22 80 00 	movl   $0x8022f6,(%esp)
  80019b:	e8 99 00 00 00       	call   800239 <cprintf>
  8001a0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x43>

008001a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 04             	sub    $0x4,%esp
  8001ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b0:	8b 13                	mov    (%ebx),%edx
  8001b2:	8d 42 01             	lea    0x1(%edx),%eax
  8001b5:	89 03                	mov    %eax,(%ebx)
  8001b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c3:	75 1a                	jne    8001df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	68 ff 00 00 00       	push   $0xff
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 2f 09 00 00       	call   800b05 <sys_cputs>
		b->idx = 0;
  8001d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f8:	00 00 00 
	b.cnt = 0;
  8001fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800202:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800205:	ff 75 0c             	pushl  0xc(%ebp)
  800208:	ff 75 08             	pushl  0x8(%ebp)
  80020b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800211:	50                   	push   %eax
  800212:	68 a6 01 80 00       	push   $0x8001a6
  800217:	e8 54 01 00 00       	call   800370 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021c:	83 c4 08             	add    $0x8,%esp
  80021f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800225:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022b:	50                   	push   %eax
  80022c:	e8 d4 08 00 00       	call   800b05 <sys_cputs>

	return b.cnt;
}
  800231:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800242:	50                   	push   %eax
  800243:	ff 75 08             	pushl  0x8(%ebp)
  800246:	e8 9d ff ff ff       	call   8001e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    

0080024d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	57                   	push   %edi
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 1c             	sub    $0x1c,%esp
  800256:	89 c7                	mov    %eax,%edi
  800258:	89 d6                	mov    %edx,%esi
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800266:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800269:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800271:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800274:	39 d3                	cmp    %edx,%ebx
  800276:	72 05                	jb     80027d <printnum+0x30>
  800278:	39 45 10             	cmp    %eax,0x10(%ebp)
  80027b:	77 45                	ja     8002c2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	ff 75 18             	pushl  0x18(%ebp)
  800283:	8b 45 14             	mov    0x14(%ebp),%eax
  800286:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800289:	53                   	push   %ebx
  80028a:	ff 75 10             	pushl  0x10(%ebp)
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	ff 75 e4             	pushl  -0x1c(%ebp)
  800293:	ff 75 e0             	pushl  -0x20(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 1f 1d 00 00       	call   801fc0 <__udivdi3>
  8002a1:	83 c4 18             	add    $0x18,%esp
  8002a4:	52                   	push   %edx
  8002a5:	50                   	push   %eax
  8002a6:	89 f2                	mov    %esi,%edx
  8002a8:	89 f8                	mov    %edi,%eax
  8002aa:	e8 9e ff ff ff       	call   80024d <printnum>
  8002af:	83 c4 20             	add    $0x20,%esp
  8002b2:	eb 18                	jmp    8002cc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	56                   	push   %esi
  8002b8:	ff 75 18             	pushl  0x18(%ebp)
  8002bb:	ff d7                	call   *%edi
  8002bd:	83 c4 10             	add    $0x10,%esp
  8002c0:	eb 03                	jmp    8002c5 <printnum+0x78>
  8002c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c5:	83 eb 01             	sub    $0x1,%ebx
  8002c8:	85 db                	test   %ebx,%ebx
  8002ca:	7f e8                	jg     8002b4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	56                   	push   %esi
  8002d0:	83 ec 04             	sub    $0x4,%esp
  8002d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002df:	e8 0c 1e 00 00       	call   8020f0 <__umoddi3>
  8002e4:	83 c4 14             	add    $0x14,%esp
  8002e7:	0f be 80 4b 23 80 00 	movsbl 0x80234b(%eax),%eax
  8002ee:	50                   	push   %eax
  8002ef:	ff d7                	call   *%edi
}
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ff:	83 fa 01             	cmp    $0x1,%edx
  800302:	7e 0e                	jle    800312 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 08             	lea    0x8(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	8b 52 04             	mov    0x4(%edx),%edx
  800310:	eb 22                	jmp    800334 <getuint+0x38>
	else if (lflag)
  800312:	85 d2                	test   %edx,%edx
  800314:	74 10                	je     800326 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
  800324:	eb 0e                	jmp    800334 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800340:	8b 10                	mov    (%eax),%edx
  800342:	3b 50 04             	cmp    0x4(%eax),%edx
  800345:	73 0a                	jae    800351 <sprintputch+0x1b>
		*b->buf++ = ch;
  800347:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034a:	89 08                	mov    %ecx,(%eax)
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	88 02                	mov    %al,(%edx)
}
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800359:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035c:	50                   	push   %eax
  80035d:	ff 75 10             	pushl  0x10(%ebp)
  800360:	ff 75 0c             	pushl  0xc(%ebp)
  800363:	ff 75 08             	pushl  0x8(%ebp)
  800366:	e8 05 00 00 00       	call   800370 <vprintfmt>
	va_end(ap);
}
  80036b:	83 c4 10             	add    $0x10,%esp
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
  800376:	83 ec 2c             	sub    $0x2c,%esp
  800379:	8b 75 08             	mov    0x8(%ebp),%esi
  80037c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800382:	eb 12                	jmp    800396 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800384:	85 c0                	test   %eax,%eax
  800386:	0f 84 89 03 00 00    	je     800715 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	53                   	push   %ebx
  800390:	50                   	push   %eax
  800391:	ff d6                	call   *%esi
  800393:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800396:	83 c7 01             	add    $0x1,%edi
  800399:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039d:	83 f8 25             	cmp    $0x25,%eax
  8003a0:	75 e2                	jne    800384 <vprintfmt+0x14>
  8003a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c0:	eb 07                	jmp    8003c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8d 47 01             	lea    0x1(%edi),%eax
  8003cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cf:	0f b6 07             	movzbl (%edi),%eax
  8003d2:	0f b6 c8             	movzbl %al,%ecx
  8003d5:	83 e8 23             	sub    $0x23,%eax
  8003d8:	3c 55                	cmp    $0x55,%al
  8003da:	0f 87 1a 03 00 00    	ja     8006fa <vprintfmt+0x38a>
  8003e0:	0f b6 c0             	movzbl %al,%eax
  8003e3:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f1:	eb d6                	jmp    8003c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800401:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800405:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800408:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040b:	83 fa 09             	cmp    $0x9,%edx
  80040e:	77 39                	ja     800449 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800410:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800413:	eb e9                	jmp    8003fe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8d 48 04             	lea    0x4(%eax),%ecx
  80041b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041e:	8b 00                	mov    (%eax),%eax
  800420:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800426:	eb 27                	jmp    80044f <vprintfmt+0xdf>
  800428:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800432:	0f 49 c8             	cmovns %eax,%ecx
  800435:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043b:	eb 8c                	jmp    8003c9 <vprintfmt+0x59>
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800440:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800447:	eb 80                	jmp    8003c9 <vprintfmt+0x59>
  800449:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800453:	0f 89 70 ff ff ff    	jns    8003c9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800459:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800466:	e9 5e ff ff ff       	jmp    8003c9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800471:	e9 53 ff ff ff       	jmp    8003c9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	53                   	push   %ebx
  800483:	ff 30                	pushl  (%eax)
  800485:	ff d6                	call   *%esi
			break;
  800487:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048d:	e9 04 ff ff ff       	jmp    800396 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	99                   	cltd   
  80049e:	31 d0                	xor    %edx,%eax
  8004a0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a2:	83 f8 0f             	cmp    $0xf,%eax
  8004a5:	7f 0b                	jg     8004b2 <vprintfmt+0x142>
  8004a7:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	75 18                	jne    8004ca <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004b2:	50                   	push   %eax
  8004b3:	68 63 23 80 00       	push   $0x802363
  8004b8:	53                   	push   %ebx
  8004b9:	56                   	push   %esi
  8004ba:	e8 94 fe ff ff       	call   800353 <printfmt>
  8004bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c5:	e9 cc fe ff ff       	jmp    800396 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ca:	52                   	push   %edx
  8004cb:	68 91 27 80 00       	push   $0x802791
  8004d0:	53                   	push   %ebx
  8004d1:	56                   	push   %esi
  8004d2:	e8 7c fe ff ff       	call   800353 <printfmt>
  8004d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004dd:	e9 b4 fe ff ff       	jmp    800396 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 50 04             	lea    0x4(%eax),%edx
  8004e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004eb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	b8 5c 23 80 00       	mov    $0x80235c,%eax
  8004f4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fb:	0f 8e 94 00 00 00    	jle    800595 <vprintfmt+0x225>
  800501:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800505:	0f 84 98 00 00 00    	je     8005a3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	ff 75 d0             	pushl  -0x30(%ebp)
  800511:	57                   	push   %edi
  800512:	e8 86 02 00 00       	call   80079d <strnlen>
  800517:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051a:	29 c1                	sub    %eax,%ecx
  80051c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80051f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800522:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800526:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800529:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052e:	eb 0f                	jmp    80053f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	53                   	push   %ebx
  800534:	ff 75 e0             	pushl  -0x20(%ebp)
  800537:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	83 ef 01             	sub    $0x1,%edi
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	85 ff                	test   %edi,%edi
  800541:	7f ed                	jg     800530 <vprintfmt+0x1c0>
  800543:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800546:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800549:	85 c9                	test   %ecx,%ecx
  80054b:	b8 00 00 00 00       	mov    $0x0,%eax
  800550:	0f 49 c1             	cmovns %ecx,%eax
  800553:	29 c1                	sub    %eax,%ecx
  800555:	89 75 08             	mov    %esi,0x8(%ebp)
  800558:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055e:	89 cb                	mov    %ecx,%ebx
  800560:	eb 4d                	jmp    8005af <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800562:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800566:	74 1b                	je     800583 <vprintfmt+0x213>
  800568:	0f be c0             	movsbl %al,%eax
  80056b:	83 e8 20             	sub    $0x20,%eax
  80056e:	83 f8 5e             	cmp    $0x5e,%eax
  800571:	76 10                	jbe    800583 <vprintfmt+0x213>
					putch('?', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	ff 75 0c             	pushl  0xc(%ebp)
  800579:	6a 3f                	push   $0x3f
  80057b:	ff 55 08             	call   *0x8(%ebp)
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	eb 0d                	jmp    800590 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	ff 75 0c             	pushl  0xc(%ebp)
  800589:	52                   	push   %edx
  80058a:	ff 55 08             	call   *0x8(%ebp)
  80058d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800590:	83 eb 01             	sub    $0x1,%ebx
  800593:	eb 1a                	jmp    8005af <vprintfmt+0x23f>
  800595:	89 75 08             	mov    %esi,0x8(%ebp)
  800598:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a1:	eb 0c                	jmp    8005af <vprintfmt+0x23f>
  8005a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005af:	83 c7 01             	add    $0x1,%edi
  8005b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b6:	0f be d0             	movsbl %al,%edx
  8005b9:	85 d2                	test   %edx,%edx
  8005bb:	74 23                	je     8005e0 <vprintfmt+0x270>
  8005bd:	85 f6                	test   %esi,%esi
  8005bf:	78 a1                	js     800562 <vprintfmt+0x1f2>
  8005c1:	83 ee 01             	sub    $0x1,%esi
  8005c4:	79 9c                	jns    800562 <vprintfmt+0x1f2>
  8005c6:	89 df                	mov    %ebx,%edi
  8005c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ce:	eb 18                	jmp    8005e8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 20                	push   $0x20
  8005d6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d8:	83 ef 01             	sub    $0x1,%edi
  8005db:	83 c4 10             	add    $0x10,%esp
  8005de:	eb 08                	jmp    8005e8 <vprintfmt+0x278>
  8005e0:	89 df                	mov    %ebx,%edi
  8005e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e8:	85 ff                	test   %edi,%edi
  8005ea:	7f e4                	jg     8005d0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ef:	e9 a2 fd ff ff       	jmp    800396 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f4:	83 fa 01             	cmp    $0x1,%edx
  8005f7:	7e 16                	jle    80060f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 08             	lea    0x8(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	8b 50 04             	mov    0x4(%eax),%edx
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060d:	eb 32                	jmp    800641 <vprintfmt+0x2d1>
	else if (lflag)
  80060f:	85 d2                	test   %edx,%edx
  800611:	74 18                	je     80062b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 50 04             	lea    0x4(%eax),%edx
  800619:	89 55 14             	mov    %edx,0x14(%ebp)
  80061c:	8b 00                	mov    (%eax),%eax
  80061e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800621:	89 c1                	mov    %eax,%ecx
  800623:	c1 f9 1f             	sar    $0x1f,%ecx
  800626:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800629:	eb 16                	jmp    800641 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 04             	lea    0x4(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 c1                	mov    %eax,%ecx
  80063b:	c1 f9 1f             	sar    $0x1f,%ecx
  80063e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800641:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800644:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800647:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800650:	79 74                	jns    8006c6 <vprintfmt+0x356>
				putch('-', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 2d                	push   $0x2d
  800658:	ff d6                	call   *%esi
				num = -(long long) num;
  80065a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800660:	f7 d8                	neg    %eax
  800662:	83 d2 00             	adc    $0x0,%edx
  800665:	f7 da                	neg    %edx
  800667:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066f:	eb 55                	jmp    8006c6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 83 fc ff ff       	call   8002fc <getuint>
			base = 10;
  800679:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067e:	eb 46                	jmp    8006c6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800680:	8d 45 14             	lea    0x14(%ebp),%eax
  800683:	e8 74 fc ff ff       	call   8002fc <getuint>
			base = 8;
  800688:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80068d:	eb 37                	jmp    8006c6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	6a 30                	push   $0x30
  800695:	ff d6                	call   *%esi
			putch('x', putdat);
  800697:	83 c4 08             	add    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	6a 78                	push   $0x78
  80069d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 50 04             	lea    0x4(%eax),%edx
  8006a5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006af:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b7:	eb 0d                	jmp    8006c6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bc:	e8 3b fc ff ff       	call   8002fc <getuint>
			base = 16;
  8006c1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c6:	83 ec 0c             	sub    $0xc,%esp
  8006c9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cd:	57                   	push   %edi
  8006ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d1:	51                   	push   %ecx
  8006d2:	52                   	push   %edx
  8006d3:	50                   	push   %eax
  8006d4:	89 da                	mov    %ebx,%edx
  8006d6:	89 f0                	mov    %esi,%eax
  8006d8:	e8 70 fb ff ff       	call   80024d <printnum>
			break;
  8006dd:	83 c4 20             	add    $0x20,%esp
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e3:	e9 ae fc ff ff       	jmp    800396 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	51                   	push   %ecx
  8006ed:	ff d6                	call   *%esi
			break;
  8006ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f5:	e9 9c fc ff ff       	jmp    800396 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 25                	push   $0x25
  800700:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 03                	jmp    80070a <vprintfmt+0x39a>
  800707:	83 ef 01             	sub    $0x1,%edi
  80070a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070e:	75 f7                	jne    800707 <vprintfmt+0x397>
  800710:	e9 81 fc ff ff       	jmp    800396 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800718:	5b                   	pop    %ebx
  800719:	5e                   	pop    %esi
  80071a:	5f                   	pop    %edi
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 18             	sub    $0x18,%esp
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800729:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800730:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800733:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073a:	85 c0                	test   %eax,%eax
  80073c:	74 26                	je     800764 <vsnprintf+0x47>
  80073e:	85 d2                	test   %edx,%edx
  800740:	7e 22                	jle    800764 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800742:	ff 75 14             	pushl  0x14(%ebp)
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	68 36 03 80 00       	push   $0x800336
  800751:	e8 1a fc ff ff       	call   800370 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800756:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800759:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 05                	jmp    800769 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800764:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800774:	50                   	push   %eax
  800775:	ff 75 10             	pushl  0x10(%ebp)
  800778:	ff 75 0c             	pushl  0xc(%ebp)
  80077b:	ff 75 08             	pushl  0x8(%ebp)
  80077e:	e8 9a ff ff ff       	call   80071d <vsnprintf>
	va_end(ap);

	return rc;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
  800790:	eb 03                	jmp    800795 <strlen+0x10>
		n++;
  800792:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800799:	75 f7                	jne    800792 <strlen+0xd>
		n++;
	return n;
}
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ab:	eb 03                	jmp    8007b0 <strnlen+0x13>
		n++;
  8007ad:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	39 c2                	cmp    %eax,%edx
  8007b2:	74 08                	je     8007bc <strnlen+0x1f>
  8007b4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b8:	75 f3                	jne    8007ad <strnlen+0x10>
  8007ba:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	53                   	push   %ebx
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	83 c2 01             	add    $0x1,%edx
  8007cd:	83 c1 01             	add    $0x1,%ecx
  8007d0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	75 ef                	jne    8007ca <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e5:	53                   	push   %ebx
  8007e6:	e8 9a ff ff ff       	call   800785 <strlen>
  8007eb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	01 d8                	add    %ebx,%eax
  8007f3:	50                   	push   %eax
  8007f4:	e8 c5 ff ff ff       	call   8007be <strcpy>
	return dst;
}
  8007f9:	89 d8                	mov    %ebx,%eax
  8007fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	89 f3                	mov    %esi,%ebx
  80080d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	89 f2                	mov    %esi,%edx
  800812:	eb 0f                	jmp    800823 <strncpy+0x23>
		*dst++ = *src;
  800814:	83 c2 01             	add    $0x1,%edx
  800817:	0f b6 01             	movzbl (%ecx),%eax
  80081a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081d:	80 39 01             	cmpb   $0x1,(%ecx)
  800820:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	39 da                	cmp    %ebx,%edx
  800825:	75 ed                	jne    800814 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800827:	89 f0                	mov    %esi,%eax
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	8b 75 08             	mov    0x8(%ebp),%esi
  800835:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800838:	8b 55 10             	mov    0x10(%ebp),%edx
  80083b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083d:	85 d2                	test   %edx,%edx
  80083f:	74 21                	je     800862 <strlcpy+0x35>
  800841:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800845:	89 f2                	mov    %esi,%edx
  800847:	eb 09                	jmp    800852 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800849:	83 c2 01             	add    $0x1,%edx
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800852:	39 c2                	cmp    %eax,%edx
  800854:	74 09                	je     80085f <strlcpy+0x32>
  800856:	0f b6 19             	movzbl (%ecx),%ebx
  800859:	84 db                	test   %bl,%bl
  80085b:	75 ec                	jne    800849 <strlcpy+0x1c>
  80085d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800862:	29 f0                	sub    %esi,%eax
}
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800871:	eb 06                	jmp    800879 <strcmp+0x11>
		p++, q++;
  800873:	83 c1 01             	add    $0x1,%ecx
  800876:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800879:	0f b6 01             	movzbl (%ecx),%eax
  80087c:	84 c0                	test   %al,%al
  80087e:	74 04                	je     800884 <strcmp+0x1c>
  800880:	3a 02                	cmp    (%edx),%al
  800882:	74 ef                	je     800873 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800884:	0f b6 c0             	movzbl %al,%eax
  800887:	0f b6 12             	movzbl (%edx),%edx
  80088a:	29 d0                	sub    %edx,%eax
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	53                   	push   %ebx
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
  800898:	89 c3                	mov    %eax,%ebx
  80089a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089d:	eb 06                	jmp    8008a5 <strncmp+0x17>
		n--, p++, q++;
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a5:	39 d8                	cmp    %ebx,%eax
  8008a7:	74 15                	je     8008be <strncmp+0x30>
  8008a9:	0f b6 08             	movzbl (%eax),%ecx
  8008ac:	84 c9                	test   %cl,%cl
  8008ae:	74 04                	je     8008b4 <strncmp+0x26>
  8008b0:	3a 0a                	cmp    (%edx),%cl
  8008b2:	74 eb                	je     80089f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b4:	0f b6 00             	movzbl (%eax),%eax
  8008b7:	0f b6 12             	movzbl (%edx),%edx
  8008ba:	29 d0                	sub    %edx,%eax
  8008bc:	eb 05                	jmp    8008c3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	eb 07                	jmp    8008d9 <strchr+0x13>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 0f                	je     8008e5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	0f b6 10             	movzbl (%eax),%edx
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f2                	jne    8008d2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f1:	eb 03                	jmp    8008f6 <strfind+0xf>
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f9:	38 ca                	cmp    %cl,%dl
  8008fb:	74 04                	je     800901 <strfind+0x1a>
  8008fd:	84 d2                	test   %dl,%dl
  8008ff:	75 f2                	jne    8008f3 <strfind+0xc>
			break;
	return (char *) s;
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	57                   	push   %edi
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090f:	85 c9                	test   %ecx,%ecx
  800911:	74 36                	je     800949 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800913:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800919:	75 28                	jne    800943 <memset+0x40>
  80091b:	f6 c1 03             	test   $0x3,%cl
  80091e:	75 23                	jne    800943 <memset+0x40>
		c &= 0xFF;
  800920:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800924:	89 d3                	mov    %edx,%ebx
  800926:	c1 e3 08             	shl    $0x8,%ebx
  800929:	89 d6                	mov    %edx,%esi
  80092b:	c1 e6 18             	shl    $0x18,%esi
  80092e:	89 d0                	mov    %edx,%eax
  800930:	c1 e0 10             	shl    $0x10,%eax
  800933:	09 f0                	or     %esi,%eax
  800935:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800937:	89 d8                	mov    %ebx,%eax
  800939:	09 d0                	or     %edx,%eax
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	fc                   	cld    
  80093f:	f3 ab                	rep stos %eax,%es:(%edi)
  800941:	eb 06                	jmp    800949 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	fc                   	cld    
  800947:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800949:	89 f8                	mov    %edi,%eax
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5f                   	pop    %edi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095e:	39 c6                	cmp    %eax,%esi
  800960:	73 35                	jae    800997 <memmove+0x47>
  800962:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800965:	39 d0                	cmp    %edx,%eax
  800967:	73 2e                	jae    800997 <memmove+0x47>
		s += n;
		d += n;
  800969:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096c:	89 d6                	mov    %edx,%esi
  80096e:	09 fe                	or     %edi,%esi
  800970:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800976:	75 13                	jne    80098b <memmove+0x3b>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 0e                	jne    80098b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097d:	83 ef 04             	sub    $0x4,%edi
  800980:	8d 72 fc             	lea    -0x4(%edx),%esi
  800983:	c1 e9 02             	shr    $0x2,%ecx
  800986:	fd                   	std    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb 09                	jmp    800994 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098b:	83 ef 01             	sub    $0x1,%edi
  80098e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800991:	fd                   	std    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800994:	fc                   	cld    
  800995:	eb 1d                	jmp    8009b4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	89 f2                	mov    %esi,%edx
  800999:	09 c2                	or     %eax,%edx
  80099b:	f6 c2 03             	test   $0x3,%dl
  80099e:	75 0f                	jne    8009af <memmove+0x5f>
  8009a0:	f6 c1 03             	test   $0x3,%cl
  8009a3:	75 0a                	jne    8009af <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a5:	c1 e9 02             	shr    $0x2,%ecx
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 05                	jmp    8009b4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009af:	89 c7                	mov    %eax,%edi
  8009b1:	fc                   	cld    
  8009b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bb:	ff 75 10             	pushl  0x10(%ebp)
  8009be:	ff 75 0c             	pushl  0xc(%ebp)
  8009c1:	ff 75 08             	pushl  0x8(%ebp)
  8009c4:	e8 87 ff ff ff       	call   800950 <memmove>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d6:	89 c6                	mov    %eax,%esi
  8009d8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	eb 1a                	jmp    8009f7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009dd:	0f b6 08             	movzbl (%eax),%ecx
  8009e0:	0f b6 1a             	movzbl (%edx),%ebx
  8009e3:	38 d9                	cmp    %bl,%cl
  8009e5:	74 0a                	je     8009f1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e7:	0f b6 c1             	movzbl %cl,%eax
  8009ea:	0f b6 db             	movzbl %bl,%ebx
  8009ed:	29 d8                	sub    %ebx,%eax
  8009ef:	eb 0f                	jmp    800a00 <memcmp+0x35>
		s1++, s2++;
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	39 f0                	cmp    %esi,%eax
  8009f9:	75 e2                	jne    8009dd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	53                   	push   %ebx
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0b:	89 c1                	mov    %eax,%ecx
  800a0d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a10:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a14:	eb 0a                	jmp    800a20 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a16:	0f b6 10             	movzbl (%eax),%edx
  800a19:	39 da                	cmp    %ebx,%edx
  800a1b:	74 07                	je     800a24 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1d:	83 c0 01             	add    $0x1,%eax
  800a20:	39 c8                	cmp    %ecx,%eax
  800a22:	72 f2                	jb     800a16 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a24:	5b                   	pop    %ebx
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a33:	eb 03                	jmp    800a38 <strtol+0x11>
		s++;
  800a35:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a38:	0f b6 01             	movzbl (%ecx),%eax
  800a3b:	3c 20                	cmp    $0x20,%al
  800a3d:	74 f6                	je     800a35 <strtol+0xe>
  800a3f:	3c 09                	cmp    $0x9,%al
  800a41:	74 f2                	je     800a35 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a43:	3c 2b                	cmp    $0x2b,%al
  800a45:	75 0a                	jne    800a51 <strtol+0x2a>
		s++;
  800a47:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4f:	eb 11                	jmp    800a62 <strtol+0x3b>
  800a51:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a56:	3c 2d                	cmp    $0x2d,%al
  800a58:	75 08                	jne    800a62 <strtol+0x3b>
		s++, neg = 1;
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a62:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a68:	75 15                	jne    800a7f <strtol+0x58>
  800a6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6d:	75 10                	jne    800a7f <strtol+0x58>
  800a6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a73:	75 7c                	jne    800af1 <strtol+0xca>
		s += 2, base = 16;
  800a75:	83 c1 02             	add    $0x2,%ecx
  800a78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7d:	eb 16                	jmp    800a95 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7f:	85 db                	test   %ebx,%ebx
  800a81:	75 12                	jne    800a95 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a83:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a88:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8b:	75 08                	jne    800a95 <strtol+0x6e>
		s++, base = 8;
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9d:	0f b6 11             	movzbl (%ecx),%edx
  800aa0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 09             	cmp    $0x9,%bl
  800aa8:	77 08                	ja     800ab2 <strtol+0x8b>
			dig = *s - '0';
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 30             	sub    $0x30,%edx
  800ab0:	eb 22                	jmp    800ad4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 08                	ja     800ac4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 57             	sub    $0x57,%edx
  800ac2:	eb 10                	jmp    800ad4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	80 fb 19             	cmp    $0x19,%bl
  800acc:	77 16                	ja     800ae4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ace:	0f be d2             	movsbl %dl,%edx
  800ad1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad7:	7d 0b                	jge    800ae4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad9:	83 c1 01             	add    $0x1,%ecx
  800adc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae2:	eb b9                	jmp    800a9d <strtol+0x76>

	if (endptr)
  800ae4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae8:	74 0d                	je     800af7 <strtol+0xd0>
		*endptr = (char *) s;
  800aea:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aed:	89 0e                	mov    %ecx,(%esi)
  800aef:	eb 06                	jmp    800af7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af1:	85 db                	test   %ebx,%ebx
  800af3:	74 98                	je     800a8d <strtol+0x66>
  800af5:	eb 9e                	jmp    800a95 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af7:	89 c2                	mov    %eax,%edx
  800af9:	f7 da                	neg    %edx
  800afb:	85 ff                	test   %edi,%edi
  800afd:	0f 45 c2             	cmovne %edx,%eax
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	89 c7                	mov    %eax,%edi
  800b1a:	89 c6                	mov    %eax,%esi
  800b1c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b33:	89 d1                	mov    %edx,%ecx
  800b35:	89 d3                	mov    %edx,%ebx
  800b37:	89 d7                	mov    %edx,%edi
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b50:	b8 03 00 00 00       	mov    $0x3,%eax
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	89 cb                	mov    %ecx,%ebx
  800b5a:	89 cf                	mov    %ecx,%edi
  800b5c:	89 ce                	mov    %ecx,%esi
  800b5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b60:	85 c0                	test   %eax,%eax
  800b62:	7e 17                	jle    800b7b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 03                	push   $0x3
  800b6a:	68 3f 26 80 00       	push   $0x80263f
  800b6f:	6a 23                	push   $0x23
  800b71:	68 5c 26 80 00       	push   $0x80265c
  800b76:	e8 e5 f5 ff ff       	call   800160 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b93:	89 d1                	mov    %edx,%ecx
  800b95:	89 d3                	mov    %edx,%ebx
  800b97:	89 d7                	mov    %edx,%edi
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_yield>:

void
sys_yield(void)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb2:	89 d1                	mov    %edx,%ecx
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	89 d7                	mov    %edx,%edi
  800bb8:	89 d6                	mov    %edx,%esi
  800bba:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bca:	be 00 00 00 00       	mov    $0x0,%esi
  800bcf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdd:	89 f7                	mov    %esi,%edi
  800bdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 04                	push   $0x4
  800beb:	68 3f 26 80 00       	push   $0x80263f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 5c 26 80 00       	push   $0x80265c
  800bf7:	e8 64 f5 ff ff       	call   800160 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 05                	push   $0x5
  800c2d:	68 3f 26 80 00       	push   $0x80263f
  800c32:	6a 23                	push   $0x23
  800c34:	68 5c 26 80 00       	push   $0x80265c
  800c39:	e8 22 f5 ff ff       	call   800160 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 06 00 00 00       	mov    $0x6,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 06                	push   $0x6
  800c6f:	68 3f 26 80 00       	push   $0x80263f
  800c74:	6a 23                	push   $0x23
  800c76:	68 5c 26 80 00       	push   $0x80265c
  800c7b:	e8 e0 f4 ff ff       	call   800160 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 08                	push   $0x8
  800cb1:	68 3f 26 80 00       	push   $0x80263f
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 5c 26 80 00       	push   $0x80265c
  800cbd:	e8 9e f4 ff ff       	call   800160 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 17                	jle    800d04 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 09                	push   $0x9
  800cf3:	68 3f 26 80 00       	push   $0x80263f
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 5c 26 80 00       	push   $0x80265c
  800cff:	e8 5c f4 ff ff       	call   800160 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 17                	jle    800d46 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	50                   	push   %eax
  800d33:	6a 0a                	push   $0xa
  800d35:	68 3f 26 80 00       	push   $0x80263f
  800d3a:	6a 23                	push   $0x23
  800d3c:	68 5c 26 80 00       	push   $0x80265c
  800d41:	e8 1a f4 ff ff       	call   800160 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	be 00 00 00 00       	mov    $0x0,%esi
  800d59:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
  800d77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	89 cb                	mov    %ecx,%ebx
  800d89:	89 cf                	mov    %ecx,%edi
  800d8b:	89 ce                	mov    %ecx,%esi
  800d8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7e 17                	jle    800daa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	50                   	push   %eax
  800d97:	6a 0d                	push   $0xd
  800d99:	68 3f 26 80 00       	push   $0x80263f
  800d9e:	6a 23                	push   $0x23
  800da0:	68 5c 26 80 00       	push   $0x80265c
  800da5:	e8 b6 f3 ff ff       	call   800160 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800daa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	89 cb                	mov    %ecx,%ebx
  800dc7:	89 cf                	mov    %ecx,%edi
  800dc9:	89 ce                	mov    %ecx,%esi
  800dcb:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 cb                	mov    %ecx,%ebx
  800de7:	89 cf                	mov    %ecx,%edi
  800de9:	89 ce                	mov    %ecx,%esi
  800deb:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	53                   	push   %ebx
  800df6:	83 ec 04             	sub    $0x4,%esp
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dfc:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dfe:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e02:	74 11                	je     800e15 <pgfault+0x23>
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	c1 e8 0c             	shr    $0xc,%eax
  800e09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e10:	f6 c4 08             	test   $0x8,%ah
  800e13:	75 14                	jne    800e29 <pgfault+0x37>
		panic("faulting access");
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	68 6a 26 80 00       	push   $0x80266a
  800e1d:	6a 1e                	push   $0x1e
  800e1f:	68 7a 26 80 00       	push   $0x80267a
  800e24:	e8 37 f3 ff ff       	call   800160 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	6a 07                	push   $0x7
  800e2e:	68 00 f0 7f 00       	push   $0x7ff000
  800e33:	6a 00                	push   $0x0
  800e35:	e8 87 fd ff ff       	call   800bc1 <sys_page_alloc>
	if (r < 0) {
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	79 12                	jns    800e53 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e41:	50                   	push   %eax
  800e42:	68 85 26 80 00       	push   $0x802685
  800e47:	6a 2c                	push   $0x2c
  800e49:	68 7a 26 80 00       	push   $0x80267a
  800e4e:	e8 0d f3 ff ff       	call   800160 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e53:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e59:	83 ec 04             	sub    $0x4,%esp
  800e5c:	68 00 10 00 00       	push   $0x1000
  800e61:	53                   	push   %ebx
  800e62:	68 00 f0 7f 00       	push   $0x7ff000
  800e67:	e8 4c fb ff ff       	call   8009b8 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e6c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e73:	53                   	push   %ebx
  800e74:	6a 00                	push   $0x0
  800e76:	68 00 f0 7f 00       	push   $0x7ff000
  800e7b:	6a 00                	push   $0x0
  800e7d:	e8 82 fd ff ff       	call   800c04 <sys_page_map>
	if (r < 0) {
  800e82:	83 c4 20             	add    $0x20,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	79 12                	jns    800e9b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e89:	50                   	push   %eax
  800e8a:	68 85 26 80 00       	push   $0x802685
  800e8f:	6a 33                	push   $0x33
  800e91:	68 7a 26 80 00       	push   $0x80267a
  800e96:	e8 c5 f2 ff ff       	call   800160 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	68 00 f0 7f 00       	push   $0x7ff000
  800ea3:	6a 00                	push   $0x0
  800ea5:	e8 9c fd ff ff       	call   800c46 <sys_page_unmap>
	if (r < 0) {
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	79 12                	jns    800ec3 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800eb1:	50                   	push   %eax
  800eb2:	68 85 26 80 00       	push   $0x802685
  800eb7:	6a 37                	push   $0x37
  800eb9:	68 7a 26 80 00       	push   $0x80267a
  800ebe:	e8 9d f2 ff ff       	call   800160 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ec3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800ed1:	68 f2 0d 80 00       	push   $0x800df2
  800ed6:	e8 f3 0e 00 00       	call   801dce <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800edb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ee0:	cd 30                	int    $0x30
  800ee2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	79 17                	jns    800f03 <fork+0x3b>
		panic("fork fault %e");
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	68 9e 26 80 00       	push   $0x80269e
  800ef4:	68 84 00 00 00       	push   $0x84
  800ef9:	68 7a 26 80 00       	push   $0x80267a
  800efe:	e8 5d f2 ff ff       	call   800160 <_panic>
  800f03:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f05:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f09:	75 25                	jne    800f30 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f0b:	e8 73 fc ff ff       	call   800b83 <sys_getenvid>
  800f10:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f15:	89 c2                	mov    %eax,%edx
  800f17:	c1 e2 07             	shl    $0x7,%edx
  800f1a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800f21:	a3 20 40 c0 00       	mov    %eax,0xc04020
		return 0;
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	e9 61 01 00 00       	jmp    801091 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f30:	83 ec 04             	sub    $0x4,%esp
  800f33:	6a 07                	push   $0x7
  800f35:	68 00 f0 bf ee       	push   $0xeebff000
  800f3a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3d:	e8 7f fc ff ff       	call   800bc1 <sys_page_alloc>
  800f42:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f45:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f4a:	89 d8                	mov    %ebx,%eax
  800f4c:	c1 e8 16             	shr    $0x16,%eax
  800f4f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f56:	a8 01                	test   $0x1,%al
  800f58:	0f 84 fc 00 00 00    	je     80105a <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f5e:	89 d8                	mov    %ebx,%eax
  800f60:	c1 e8 0c             	shr    $0xc,%eax
  800f63:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f6a:	f6 c2 01             	test   $0x1,%dl
  800f6d:	0f 84 e7 00 00 00    	je     80105a <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f73:	89 c6                	mov    %eax,%esi
  800f75:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f78:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f7f:	f6 c6 04             	test   $0x4,%dh
  800f82:	74 39                	je     800fbd <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f84:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	25 07 0e 00 00       	and    $0xe07,%eax
  800f93:	50                   	push   %eax
  800f94:	56                   	push   %esi
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	6a 00                	push   $0x0
  800f99:	e8 66 fc ff ff       	call   800c04 <sys_page_map>
		if (r < 0) {
  800f9e:	83 c4 20             	add    $0x20,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	0f 89 b1 00 00 00    	jns    80105a <fork+0x192>
		    	panic("sys page map fault %e");
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	68 ac 26 80 00       	push   $0x8026ac
  800fb1:	6a 54                	push   $0x54
  800fb3:	68 7a 26 80 00       	push   $0x80267a
  800fb8:	e8 a3 f1 ff ff       	call   800160 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fbd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc4:	f6 c2 02             	test   $0x2,%dl
  800fc7:	75 0c                	jne    800fd5 <fork+0x10d>
  800fc9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd0:	f6 c4 08             	test   $0x8,%ah
  800fd3:	74 5b                	je     801030 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	68 05 08 00 00       	push   $0x805
  800fdd:	56                   	push   %esi
  800fde:	57                   	push   %edi
  800fdf:	56                   	push   %esi
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 1d fc ff ff       	call   800c04 <sys_page_map>
		if (r < 0) {
  800fe7:	83 c4 20             	add    $0x20,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	79 14                	jns    801002 <fork+0x13a>
		    	panic("sys page map fault %e");
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 ac 26 80 00       	push   $0x8026ac
  800ff6:	6a 5b                	push   $0x5b
  800ff8:	68 7a 26 80 00       	push   $0x80267a
  800ffd:	e8 5e f1 ff ff       	call   800160 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	68 05 08 00 00       	push   $0x805
  80100a:	56                   	push   %esi
  80100b:	6a 00                	push   $0x0
  80100d:	56                   	push   %esi
  80100e:	6a 00                	push   $0x0
  801010:	e8 ef fb ff ff       	call   800c04 <sys_page_map>
		if (r < 0) {
  801015:	83 c4 20             	add    $0x20,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	79 3e                	jns    80105a <fork+0x192>
		    	panic("sys page map fault %e");
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	68 ac 26 80 00       	push   $0x8026ac
  801024:	6a 5f                	push   $0x5f
  801026:	68 7a 26 80 00       	push   $0x80267a
  80102b:	e8 30 f1 ff ff       	call   800160 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	6a 05                	push   $0x5
  801035:	56                   	push   %esi
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	6a 00                	push   $0x0
  80103a:	e8 c5 fb ff ff       	call   800c04 <sys_page_map>
		if (r < 0) {
  80103f:	83 c4 20             	add    $0x20,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	79 14                	jns    80105a <fork+0x192>
		    	panic("sys page map fault %e");
  801046:	83 ec 04             	sub    $0x4,%esp
  801049:	68 ac 26 80 00       	push   $0x8026ac
  80104e:	6a 64                	push   $0x64
  801050:	68 7a 26 80 00       	push   $0x80267a
  801055:	e8 06 f1 ff ff       	call   800160 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80105a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801060:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801066:	0f 85 de fe ff ff    	jne    800f4a <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80106c:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801071:	8b 40 70             	mov    0x70(%eax),%eax
  801074:	83 ec 08             	sub    $0x8,%esp
  801077:	50                   	push   %eax
  801078:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80107b:	57                   	push   %edi
  80107c:	e8 8b fc ff ff       	call   800d0c <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801081:	83 c4 08             	add    $0x8,%esp
  801084:	6a 02                	push   $0x2
  801086:	57                   	push   %edi
  801087:	e8 fc fb ff ff       	call   800c88 <sys_env_set_status>
	
	return envid;
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801091:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sfork>:

envid_t
sfork(void)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80109c:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8010ab:	89 1d 24 40 c0 00    	mov    %ebx,0xc04024
	cprintf("in fork.c thread create. func: %x\n", func);
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	53                   	push   %ebx
  8010b5:	68 c4 26 80 00       	push   $0x8026c4
  8010ba:	e8 7a f1 ff ff       	call   800239 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8010bf:	c7 04 24 26 01 80 00 	movl   $0x800126,(%esp)
  8010c6:	e8 e7 fc ff ff       	call   800db2 <sys_thread_create>
  8010cb:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010cd:	83 c4 08             	add    $0x8,%esp
  8010d0:	53                   	push   %ebx
  8010d1:	68 c4 26 80 00       	push   $0x8026c4
  8010d6:	e8 5e f1 ff ff       	call   800239 <cprintf>
	return id;
	//return 0;
}
  8010db:	89 f0                	mov    %esi,%eax
  8010dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ef:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801104:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801111:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801116:	89 c2                	mov    %eax,%edx
  801118:	c1 ea 16             	shr    $0x16,%edx
  80111b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801122:	f6 c2 01             	test   $0x1,%dl
  801125:	74 11                	je     801138 <fd_alloc+0x2d>
  801127:	89 c2                	mov    %eax,%edx
  801129:	c1 ea 0c             	shr    $0xc,%edx
  80112c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801133:	f6 c2 01             	test   $0x1,%dl
  801136:	75 09                	jne    801141 <fd_alloc+0x36>
			*fd_store = fd;
  801138:	89 01                	mov    %eax,(%ecx)
			return 0;
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
  80113f:	eb 17                	jmp    801158 <fd_alloc+0x4d>
  801141:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801146:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80114b:	75 c9                	jne    801116 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80114d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801153:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801160:	83 f8 1f             	cmp    $0x1f,%eax
  801163:	77 36                	ja     80119b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801165:	c1 e0 0c             	shl    $0xc,%eax
  801168:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80116d:	89 c2                	mov    %eax,%edx
  80116f:	c1 ea 16             	shr    $0x16,%edx
  801172:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801179:	f6 c2 01             	test   $0x1,%dl
  80117c:	74 24                	je     8011a2 <fd_lookup+0x48>
  80117e:	89 c2                	mov    %eax,%edx
  801180:	c1 ea 0c             	shr    $0xc,%edx
  801183:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118a:	f6 c2 01             	test   $0x1,%dl
  80118d:	74 1a                	je     8011a9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80118f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801192:	89 02                	mov    %eax,(%edx)
	return 0;
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
  801199:	eb 13                	jmp    8011ae <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80119b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a0:	eb 0c                	jmp    8011ae <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a7:	eb 05                	jmp    8011ae <fd_lookup+0x54>
  8011a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b9:	ba 68 27 80 00       	mov    $0x802768,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011be:	eb 13                	jmp    8011d3 <dev_lookup+0x23>
  8011c0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011c3:	39 08                	cmp    %ecx,(%eax)
  8011c5:	75 0c                	jne    8011d3 <dev_lookup+0x23>
			*dev = devtab[i];
  8011c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d1:	eb 2e                	jmp    801201 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d3:	8b 02                	mov    (%edx),%eax
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	75 e7                	jne    8011c0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011d9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011de:	8b 40 54             	mov    0x54(%eax),%eax
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	51                   	push   %ecx
  8011e5:	50                   	push   %eax
  8011e6:	68 e8 26 80 00       	push   $0x8026e8
  8011eb:	e8 49 f0 ff ff       	call   800239 <cprintf>
	*dev = 0;
  8011f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801201:	c9                   	leave  
  801202:	c3                   	ret    

00801203 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	83 ec 10             	sub    $0x10,%esp
  80120b:	8b 75 08             	mov    0x8(%ebp),%esi
  80120e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80121b:	c1 e8 0c             	shr    $0xc,%eax
  80121e:	50                   	push   %eax
  80121f:	e8 36 ff ff ff       	call   80115a <fd_lookup>
  801224:	83 c4 08             	add    $0x8,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 05                	js     801230 <fd_close+0x2d>
	    || fd != fd2)
  80122b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80122e:	74 0c                	je     80123c <fd_close+0x39>
		return (must_exist ? r : 0);
  801230:	84 db                	test   %bl,%bl
  801232:	ba 00 00 00 00       	mov    $0x0,%edx
  801237:	0f 44 c2             	cmove  %edx,%eax
  80123a:	eb 41                	jmp    80127d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801242:	50                   	push   %eax
  801243:	ff 36                	pushl  (%esi)
  801245:	e8 66 ff ff ff       	call   8011b0 <dev_lookup>
  80124a:	89 c3                	mov    %eax,%ebx
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	78 1a                	js     80126d <fd_close+0x6a>
		if (dev->dev_close)
  801253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801256:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801259:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80125e:	85 c0                	test   %eax,%eax
  801260:	74 0b                	je     80126d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	56                   	push   %esi
  801266:	ff d0                	call   *%eax
  801268:	89 c3                	mov    %eax,%ebx
  80126a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	56                   	push   %esi
  801271:	6a 00                	push   $0x0
  801273:	e8 ce f9 ff ff       	call   800c46 <sys_page_unmap>
	return r;
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	89 d8                	mov    %ebx,%eax
}
  80127d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	ff 75 08             	pushl  0x8(%ebp)
  801291:	e8 c4 fe ff ff       	call   80115a <fd_lookup>
  801296:	83 c4 08             	add    $0x8,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 10                	js     8012ad <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	6a 01                	push   $0x1
  8012a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a5:	e8 59 ff ff ff       	call   801203 <fd_close>
  8012aa:	83 c4 10             	add    $0x10,%esp
}
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <close_all>:

void
close_all(void)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	53                   	push   %ebx
  8012b3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	53                   	push   %ebx
  8012bf:	e8 c0 ff ff ff       	call   801284 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c4:	83 c3 01             	add    $0x1,%ebx
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	83 fb 20             	cmp    $0x20,%ebx
  8012cd:	75 ec                	jne    8012bb <close_all+0xc>
		close(i);
}
  8012cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 2c             	sub    $0x2c,%esp
  8012dd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 6e fe ff ff       	call   80115a <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	0f 88 c1 00 00 00    	js     8013b8 <dup+0xe4>
		return r;
	close(newfdnum);
  8012f7:	83 ec 0c             	sub    $0xc,%esp
  8012fa:	56                   	push   %esi
  8012fb:	e8 84 ff ff ff       	call   801284 <close>

	newfd = INDEX2FD(newfdnum);
  801300:	89 f3                	mov    %esi,%ebx
  801302:	c1 e3 0c             	shl    $0xc,%ebx
  801305:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80130b:	83 c4 04             	add    $0x4,%esp
  80130e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801311:	e8 de fd ff ff       	call   8010f4 <fd2data>
  801316:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801318:	89 1c 24             	mov    %ebx,(%esp)
  80131b:	e8 d4 fd ff ff       	call   8010f4 <fd2data>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801326:	89 f8                	mov    %edi,%eax
  801328:	c1 e8 16             	shr    $0x16,%eax
  80132b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801332:	a8 01                	test   $0x1,%al
  801334:	74 37                	je     80136d <dup+0x99>
  801336:	89 f8                	mov    %edi,%eax
  801338:	c1 e8 0c             	shr    $0xc,%eax
  80133b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801342:	f6 c2 01             	test   $0x1,%dl
  801345:	74 26                	je     80136d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801347:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	25 07 0e 00 00       	and    $0xe07,%eax
  801356:	50                   	push   %eax
  801357:	ff 75 d4             	pushl  -0x2c(%ebp)
  80135a:	6a 00                	push   $0x0
  80135c:	57                   	push   %edi
  80135d:	6a 00                	push   $0x0
  80135f:	e8 a0 f8 ff ff       	call   800c04 <sys_page_map>
  801364:	89 c7                	mov    %eax,%edi
  801366:	83 c4 20             	add    $0x20,%esp
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 2e                	js     80139b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80136d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801370:	89 d0                	mov    %edx,%eax
  801372:	c1 e8 0c             	shr    $0xc,%eax
  801375:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137c:	83 ec 0c             	sub    $0xc,%esp
  80137f:	25 07 0e 00 00       	and    $0xe07,%eax
  801384:	50                   	push   %eax
  801385:	53                   	push   %ebx
  801386:	6a 00                	push   $0x0
  801388:	52                   	push   %edx
  801389:	6a 00                	push   $0x0
  80138b:	e8 74 f8 ff ff       	call   800c04 <sys_page_map>
  801390:	89 c7                	mov    %eax,%edi
  801392:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801395:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801397:	85 ff                	test   %edi,%edi
  801399:	79 1d                	jns    8013b8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	53                   	push   %ebx
  80139f:	6a 00                	push   $0x0
  8013a1:	e8 a0 f8 ff ff       	call   800c46 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013a6:	83 c4 08             	add    $0x8,%esp
  8013a9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ac:	6a 00                	push   $0x0
  8013ae:	e8 93 f8 ff ff       	call   800c46 <sys_page_unmap>
	return r;
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	89 f8                	mov    %edi,%eax
}
  8013b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bb:	5b                   	pop    %ebx
  8013bc:	5e                   	pop    %esi
  8013bd:	5f                   	pop    %edi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	53                   	push   %ebx
  8013c4:	83 ec 14             	sub    $0x14,%esp
  8013c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	53                   	push   %ebx
  8013cf:	e8 86 fd ff ff       	call   80115a <fd_lookup>
  8013d4:	83 c4 08             	add    $0x8,%esp
  8013d7:	89 c2                	mov    %eax,%edx
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 6d                	js     80144a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e7:	ff 30                	pushl  (%eax)
  8013e9:	e8 c2 fd ff ff       	call   8011b0 <dev_lookup>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 4c                	js     801441 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013f8:	8b 42 08             	mov    0x8(%edx),%eax
  8013fb:	83 e0 03             	and    $0x3,%eax
  8013fe:	83 f8 01             	cmp    $0x1,%eax
  801401:	75 21                	jne    801424 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801403:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801408:	8b 40 54             	mov    0x54(%eax),%eax
  80140b:	83 ec 04             	sub    $0x4,%esp
  80140e:	53                   	push   %ebx
  80140f:	50                   	push   %eax
  801410:	68 2c 27 80 00       	push   $0x80272c
  801415:	e8 1f ee ff ff       	call   800239 <cprintf>
		return -E_INVAL;
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801422:	eb 26                	jmp    80144a <read+0x8a>
	}
	if (!dev->dev_read)
  801424:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801427:	8b 40 08             	mov    0x8(%eax),%eax
  80142a:	85 c0                	test   %eax,%eax
  80142c:	74 17                	je     801445 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80142e:	83 ec 04             	sub    $0x4,%esp
  801431:	ff 75 10             	pushl  0x10(%ebp)
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	52                   	push   %edx
  801438:	ff d0                	call   *%eax
  80143a:	89 c2                	mov    %eax,%edx
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	eb 09                	jmp    80144a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801441:	89 c2                	mov    %eax,%edx
  801443:	eb 05                	jmp    80144a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801445:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80144a:	89 d0                	mov    %edx,%eax
  80144c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	57                   	push   %edi
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
  801457:	83 ec 0c             	sub    $0xc,%esp
  80145a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801460:	bb 00 00 00 00       	mov    $0x0,%ebx
  801465:	eb 21                	jmp    801488 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801467:	83 ec 04             	sub    $0x4,%esp
  80146a:	89 f0                	mov    %esi,%eax
  80146c:	29 d8                	sub    %ebx,%eax
  80146e:	50                   	push   %eax
  80146f:	89 d8                	mov    %ebx,%eax
  801471:	03 45 0c             	add    0xc(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	57                   	push   %edi
  801476:	e8 45 ff ff ff       	call   8013c0 <read>
		if (m < 0)
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 10                	js     801492 <readn+0x41>
			return m;
		if (m == 0)
  801482:	85 c0                	test   %eax,%eax
  801484:	74 0a                	je     801490 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801486:	01 c3                	add    %eax,%ebx
  801488:	39 f3                	cmp    %esi,%ebx
  80148a:	72 db                	jb     801467 <readn+0x16>
  80148c:	89 d8                	mov    %ebx,%eax
  80148e:	eb 02                	jmp    801492 <readn+0x41>
  801490:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801492:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801495:	5b                   	pop    %ebx
  801496:	5e                   	pop    %esi
  801497:	5f                   	pop    %edi
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    

0080149a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	53                   	push   %ebx
  80149e:	83 ec 14             	sub    $0x14,%esp
  8014a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	53                   	push   %ebx
  8014a9:	e8 ac fc ff ff       	call   80115a <fd_lookup>
  8014ae:	83 c4 08             	add    $0x8,%esp
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 68                	js     80151f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	ff 30                	pushl  (%eax)
  8014c3:	e8 e8 fc ff ff       	call   8011b0 <dev_lookup>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 47                	js     801516 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d6:	75 21                	jne    8014f9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8014dd:	8b 40 54             	mov    0x54(%eax),%eax
  8014e0:	83 ec 04             	sub    $0x4,%esp
  8014e3:	53                   	push   %ebx
  8014e4:	50                   	push   %eax
  8014e5:	68 48 27 80 00       	push   $0x802748
  8014ea:	e8 4a ed ff ff       	call   800239 <cprintf>
		return -E_INVAL;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f7:	eb 26                	jmp    80151f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ff:	85 d2                	test   %edx,%edx
  801501:	74 17                	je     80151a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801503:	83 ec 04             	sub    $0x4,%esp
  801506:	ff 75 10             	pushl  0x10(%ebp)
  801509:	ff 75 0c             	pushl  0xc(%ebp)
  80150c:	50                   	push   %eax
  80150d:	ff d2                	call   *%edx
  80150f:	89 c2                	mov    %eax,%edx
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	eb 09                	jmp    80151f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801516:	89 c2                	mov    %eax,%edx
  801518:	eb 05                	jmp    80151f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80151a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80151f:	89 d0                	mov    %edx,%eax
  801521:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <seek>:

int
seek(int fdnum, off_t offset)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80152c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	ff 75 08             	pushl  0x8(%ebp)
  801533:	e8 22 fc ff ff       	call   80115a <fd_lookup>
  801538:	83 c4 08             	add    $0x8,%esp
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 0e                	js     80154d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80153f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801542:	8b 55 0c             	mov    0xc(%ebp),%edx
  801545:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801548:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	53                   	push   %ebx
  801553:	83 ec 14             	sub    $0x14,%esp
  801556:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801559:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	53                   	push   %ebx
  80155e:	e8 f7 fb ff ff       	call   80115a <fd_lookup>
  801563:	83 c4 08             	add    $0x8,%esp
  801566:	89 c2                	mov    %eax,%edx
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 65                	js     8015d1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	ff 30                	pushl  (%eax)
  801578:	e8 33 fc ff ff       	call   8011b0 <dev_lookup>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 44                	js     8015c8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801587:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158b:	75 21                	jne    8015ae <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80158d:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801592:	8b 40 54             	mov    0x54(%eax),%eax
  801595:	83 ec 04             	sub    $0x4,%esp
  801598:	53                   	push   %ebx
  801599:	50                   	push   %eax
  80159a:	68 08 27 80 00       	push   $0x802708
  80159f:	e8 95 ec ff ff       	call   800239 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ac:	eb 23                	jmp    8015d1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b1:	8b 52 18             	mov    0x18(%edx),%edx
  8015b4:	85 d2                	test   %edx,%edx
  8015b6:	74 14                	je     8015cc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	ff 75 0c             	pushl  0xc(%ebp)
  8015be:	50                   	push   %eax
  8015bf:	ff d2                	call   *%edx
  8015c1:	89 c2                	mov    %eax,%edx
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	eb 09                	jmp    8015d1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c8:	89 c2                	mov    %eax,%edx
  8015ca:	eb 05                	jmp    8015d1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015d1:	89 d0                	mov    %edx,%eax
  8015d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 14             	sub    $0x14,%esp
  8015df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	ff 75 08             	pushl  0x8(%ebp)
  8015e9:	e8 6c fb ff ff       	call   80115a <fd_lookup>
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	89 c2                	mov    %eax,%edx
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 58                	js     80164f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	ff 30                	pushl  (%eax)
  801603:	e8 a8 fb ff ff       	call   8011b0 <dev_lookup>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 37                	js     801646 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80160f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801612:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801616:	74 32                	je     80164a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801618:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80161b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801622:	00 00 00 
	stat->st_isdir = 0;
  801625:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80162c:	00 00 00 
	stat->st_dev = dev;
  80162f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	53                   	push   %ebx
  801639:	ff 75 f0             	pushl  -0x10(%ebp)
  80163c:	ff 50 14             	call   *0x14(%eax)
  80163f:	89 c2                	mov    %eax,%edx
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	eb 09                	jmp    80164f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801646:	89 c2                	mov    %eax,%edx
  801648:	eb 05                	jmp    80164f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80164a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80164f:	89 d0                	mov    %edx,%eax
  801651:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	56                   	push   %esi
  80165a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	6a 00                	push   $0x0
  801660:	ff 75 08             	pushl  0x8(%ebp)
  801663:	e8 e3 01 00 00       	call   80184b <open>
  801668:	89 c3                	mov    %eax,%ebx
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 1b                	js     80168c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	ff 75 0c             	pushl  0xc(%ebp)
  801677:	50                   	push   %eax
  801678:	e8 5b ff ff ff       	call   8015d8 <fstat>
  80167d:	89 c6                	mov    %eax,%esi
	close(fd);
  80167f:	89 1c 24             	mov    %ebx,(%esp)
  801682:	e8 fd fb ff ff       	call   801284 <close>
	return r;
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	89 f0                	mov    %esi,%eax
}
  80168c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
  801698:	89 c6                	mov    %eax,%esi
  80169a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80169c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a3:	75 12                	jne    8016b7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	6a 01                	push   $0x1
  8016aa:	e8 88 08 00 00       	call   801f37 <ipc_find_env>
  8016af:	a3 00 40 80 00       	mov    %eax,0x804000
  8016b4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b7:	6a 07                	push   $0x7
  8016b9:	68 00 50 c0 00       	push   $0xc05000
  8016be:	56                   	push   %esi
  8016bf:	ff 35 00 40 80 00    	pushl  0x804000
  8016c5:	e8 0b 08 00 00       	call   801ed5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016ca:	83 c4 0c             	add    $0xc,%esp
  8016cd:	6a 00                	push   $0x0
  8016cf:	53                   	push   %ebx
  8016d0:	6a 00                	push   $0x0
  8016d2:	e8 86 07 00 00       	call   801e5d <ipc_recv>
}
  8016d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016da:	5b                   	pop    %ebx
  8016db:	5e                   	pop    %esi
  8016dc:	5d                   	pop    %ebp
  8016dd:	c3                   	ret    

008016de <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ea:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8016ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f2:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801701:	e8 8d ff ff ff       	call   801693 <fsipc>
}
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80170e:	8b 45 08             	mov    0x8(%ebp),%eax
  801711:	8b 40 0c             	mov    0xc(%eax),%eax
  801714:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801719:	ba 00 00 00 00       	mov    $0x0,%edx
  80171e:	b8 06 00 00 00       	mov    $0x6,%eax
  801723:	e8 6b ff ff ff       	call   801693 <fsipc>
}
  801728:	c9                   	leave  
  801729:	c3                   	ret    

0080172a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	53                   	push   %ebx
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801734:	8b 45 08             	mov    0x8(%ebp),%eax
  801737:	8b 40 0c             	mov    0xc(%eax),%eax
  80173a:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80173f:	ba 00 00 00 00       	mov    $0x0,%edx
  801744:	b8 05 00 00 00       	mov    $0x5,%eax
  801749:	e8 45 ff ff ff       	call   801693 <fsipc>
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 2c                	js     80177e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801752:	83 ec 08             	sub    $0x8,%esp
  801755:	68 00 50 c0 00       	push   $0xc05000
  80175a:	53                   	push   %ebx
  80175b:	e8 5e f0 ff ff       	call   8007be <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801760:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801765:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80176b:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801770:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	83 ec 0c             	sub    $0xc,%esp
  801789:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80178c:	8b 55 08             	mov    0x8(%ebp),%edx
  80178f:	8b 52 0c             	mov    0xc(%edx),%edx
  801792:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801798:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80179d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017a2:	0f 47 c2             	cmova  %edx,%eax
  8017a5:	a3 04 50 c0 00       	mov    %eax,0xc05004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8017aa:	50                   	push   %eax
  8017ab:	ff 75 0c             	pushl  0xc(%ebp)
  8017ae:	68 08 50 c0 00       	push   $0xc05008
  8017b3:	e8 98 f1 ff ff       	call   800950 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8017b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bd:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c2:	e8 cc fe ff ff       	call   801693 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    

008017c9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	56                   	push   %esi
  8017cd:	53                   	push   %ebx
  8017ce:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d7:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8017dc:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ec:	e8 a2 fe ff ff       	call   801693 <fsipc>
  8017f1:	89 c3                	mov    %eax,%ebx
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 4b                	js     801842 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017f7:	39 c6                	cmp    %eax,%esi
  8017f9:	73 16                	jae    801811 <devfile_read+0x48>
  8017fb:	68 78 27 80 00       	push   $0x802778
  801800:	68 7f 27 80 00       	push   $0x80277f
  801805:	6a 7c                	push   $0x7c
  801807:	68 94 27 80 00       	push   $0x802794
  80180c:	e8 4f e9 ff ff       	call   800160 <_panic>
	assert(r <= PGSIZE);
  801811:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801816:	7e 16                	jle    80182e <devfile_read+0x65>
  801818:	68 9f 27 80 00       	push   $0x80279f
  80181d:	68 7f 27 80 00       	push   $0x80277f
  801822:	6a 7d                	push   $0x7d
  801824:	68 94 27 80 00       	push   $0x802794
  801829:	e8 32 e9 ff ff       	call   800160 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80182e:	83 ec 04             	sub    $0x4,%esp
  801831:	50                   	push   %eax
  801832:	68 00 50 c0 00       	push   $0xc05000
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	e8 11 f1 ff ff       	call   800950 <memmove>
	return r;
  80183f:	83 c4 10             	add    $0x10,%esp
}
  801842:	89 d8                	mov    %ebx,%eax
  801844:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801847:	5b                   	pop    %ebx
  801848:	5e                   	pop    %esi
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 20             	sub    $0x20,%esp
  801852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801855:	53                   	push   %ebx
  801856:	e8 2a ef ff ff       	call   800785 <strlen>
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801863:	7f 67                	jg     8018cc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801865:	83 ec 0c             	sub    $0xc,%esp
  801868:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186b:	50                   	push   %eax
  80186c:	e8 9a f8 ff ff       	call   80110b <fd_alloc>
  801871:	83 c4 10             	add    $0x10,%esp
		return r;
  801874:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801876:	85 c0                	test   %eax,%eax
  801878:	78 57                	js     8018d1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	53                   	push   %ebx
  80187e:	68 00 50 c0 00       	push   $0xc05000
  801883:	e8 36 ef ff ff       	call   8007be <strcpy>
	fsipcbuf.open.req_omode = mode;
  801888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188b:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801890:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801893:	b8 01 00 00 00       	mov    $0x1,%eax
  801898:	e8 f6 fd ff ff       	call   801693 <fsipc>
  80189d:	89 c3                	mov    %eax,%ebx
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	79 14                	jns    8018ba <open+0x6f>
		fd_close(fd, 0);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	6a 00                	push   $0x0
  8018ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ae:	e8 50 f9 ff ff       	call   801203 <fd_close>
		return r;
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	89 da                	mov    %ebx,%edx
  8018b8:	eb 17                	jmp    8018d1 <open+0x86>
	}

	return fd2num(fd);
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c0:	e8 1f f8 ff ff       	call   8010e4 <fd2num>
  8018c5:	89 c2                	mov    %eax,%edx
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	eb 05                	jmp    8018d1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018cc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018d1:	89 d0                	mov    %edx,%eax
  8018d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e8:	e8 a6 fd ff ff       	call   801693 <fsipc>
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	56                   	push   %esi
  8018f3:	53                   	push   %ebx
  8018f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	ff 75 08             	pushl  0x8(%ebp)
  8018fd:	e8 f2 f7 ff ff       	call   8010f4 <fd2data>
  801902:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801904:	83 c4 08             	add    $0x8,%esp
  801907:	68 ab 27 80 00       	push   $0x8027ab
  80190c:	53                   	push   %ebx
  80190d:	e8 ac ee ff ff       	call   8007be <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801912:	8b 46 04             	mov    0x4(%esi),%eax
  801915:	2b 06                	sub    (%esi),%eax
  801917:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80191d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801924:	00 00 00 
	stat->st_dev = &devpipe;
  801927:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80192e:	30 80 00 
	return 0;
}
  801931:	b8 00 00 00 00       	mov    $0x0,%eax
  801936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801939:	5b                   	pop    %ebx
  80193a:	5e                   	pop    %esi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    

0080193d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	53                   	push   %ebx
  801941:	83 ec 0c             	sub    $0xc,%esp
  801944:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801947:	53                   	push   %ebx
  801948:	6a 00                	push   $0x0
  80194a:	e8 f7 f2 ff ff       	call   800c46 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80194f:	89 1c 24             	mov    %ebx,(%esp)
  801952:	e8 9d f7 ff ff       	call   8010f4 <fd2data>
  801957:	83 c4 08             	add    $0x8,%esp
  80195a:	50                   	push   %eax
  80195b:	6a 00                	push   $0x0
  80195d:	e8 e4 f2 ff ff       	call   800c46 <sys_page_unmap>
}
  801962:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	57                   	push   %edi
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	83 ec 1c             	sub    $0x1c,%esp
  801970:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801973:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801975:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80197a:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80197d:	83 ec 0c             	sub    $0xc,%esp
  801980:	ff 75 e0             	pushl  -0x20(%ebp)
  801983:	e8 ef 05 00 00       	call   801f77 <pageref>
  801988:	89 c3                	mov    %eax,%ebx
  80198a:	89 3c 24             	mov    %edi,(%esp)
  80198d:	e8 e5 05 00 00       	call   801f77 <pageref>
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	39 c3                	cmp    %eax,%ebx
  801997:	0f 94 c1             	sete   %cl
  80199a:	0f b6 c9             	movzbl %cl,%ecx
  80199d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019a0:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  8019a6:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  8019a9:	39 ce                	cmp    %ecx,%esi
  8019ab:	74 1b                	je     8019c8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019ad:	39 c3                	cmp    %eax,%ebx
  8019af:	75 c4                	jne    801975 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019b1:	8b 42 64             	mov    0x64(%edx),%eax
  8019b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019b7:	50                   	push   %eax
  8019b8:	56                   	push   %esi
  8019b9:	68 b2 27 80 00       	push   $0x8027b2
  8019be:	e8 76 e8 ff ff       	call   800239 <cprintf>
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb ad                	jmp    801975 <_pipeisclosed+0xe>
	}
}
  8019c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ce:	5b                   	pop    %ebx
  8019cf:	5e                   	pop    %esi
  8019d0:	5f                   	pop    %edi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	57                   	push   %edi
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 28             	sub    $0x28,%esp
  8019dc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019df:	56                   	push   %esi
  8019e0:	e8 0f f7 ff ff       	call   8010f4 <fd2data>
  8019e5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ef:	eb 4b                	jmp    801a3c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019f1:	89 da                	mov    %ebx,%edx
  8019f3:	89 f0                	mov    %esi,%eax
  8019f5:	e8 6d ff ff ff       	call   801967 <_pipeisclosed>
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	75 48                	jne    801a46 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019fe:	e8 9f f1 ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a03:	8b 43 04             	mov    0x4(%ebx),%eax
  801a06:	8b 0b                	mov    (%ebx),%ecx
  801a08:	8d 51 20             	lea    0x20(%ecx),%edx
  801a0b:	39 d0                	cmp    %edx,%eax
  801a0d:	73 e2                	jae    8019f1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a12:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a16:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	c1 fa 1f             	sar    $0x1f,%edx
  801a1e:	89 d1                	mov    %edx,%ecx
  801a20:	c1 e9 1b             	shr    $0x1b,%ecx
  801a23:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a26:	83 e2 1f             	and    $0x1f,%edx
  801a29:	29 ca                	sub    %ecx,%edx
  801a2b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a2f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a33:	83 c0 01             	add    $0x1,%eax
  801a36:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a39:	83 c7 01             	add    $0x1,%edi
  801a3c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a3f:	75 c2                	jne    801a03 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a41:	8b 45 10             	mov    0x10(%ebp),%eax
  801a44:	eb 05                	jmp    801a4b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a46:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5e                   	pop    %esi
  801a50:	5f                   	pop    %edi
  801a51:	5d                   	pop    %ebp
  801a52:	c3                   	ret    

00801a53 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	57                   	push   %edi
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	83 ec 18             	sub    $0x18,%esp
  801a5c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a5f:	57                   	push   %edi
  801a60:	e8 8f f6 ff ff       	call   8010f4 <fd2data>
  801a65:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a6f:	eb 3d                	jmp    801aae <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a71:	85 db                	test   %ebx,%ebx
  801a73:	74 04                	je     801a79 <devpipe_read+0x26>
				return i;
  801a75:	89 d8                	mov    %ebx,%eax
  801a77:	eb 44                	jmp    801abd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a79:	89 f2                	mov    %esi,%edx
  801a7b:	89 f8                	mov    %edi,%eax
  801a7d:	e8 e5 fe ff ff       	call   801967 <_pipeisclosed>
  801a82:	85 c0                	test   %eax,%eax
  801a84:	75 32                	jne    801ab8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a86:	e8 17 f1 ff ff       	call   800ba2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a8b:	8b 06                	mov    (%esi),%eax
  801a8d:	3b 46 04             	cmp    0x4(%esi),%eax
  801a90:	74 df                	je     801a71 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a92:	99                   	cltd   
  801a93:	c1 ea 1b             	shr    $0x1b,%edx
  801a96:	01 d0                	add    %edx,%eax
  801a98:	83 e0 1f             	and    $0x1f,%eax
  801a9b:	29 d0                	sub    %edx,%eax
  801a9d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801aa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801aa8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aab:	83 c3 01             	add    $0x1,%ebx
  801aae:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ab1:	75 d8                	jne    801a8b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ab3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab6:	eb 05                	jmp    801abd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ab8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5f                   	pop    %edi
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
  801aca:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801acd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad0:	50                   	push   %eax
  801ad1:	e8 35 f6 ff ff       	call   80110b <fd_alloc>
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	89 c2                	mov    %eax,%edx
  801adb:	85 c0                	test   %eax,%eax
  801add:	0f 88 2c 01 00 00    	js     801c0f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae3:	83 ec 04             	sub    $0x4,%esp
  801ae6:	68 07 04 00 00       	push   $0x407
  801aeb:	ff 75 f4             	pushl  -0xc(%ebp)
  801aee:	6a 00                	push   $0x0
  801af0:	e8 cc f0 ff ff       	call   800bc1 <sys_page_alloc>
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	89 c2                	mov    %eax,%edx
  801afa:	85 c0                	test   %eax,%eax
  801afc:	0f 88 0d 01 00 00    	js     801c0f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b02:	83 ec 0c             	sub    $0xc,%esp
  801b05:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b08:	50                   	push   %eax
  801b09:	e8 fd f5 ff ff       	call   80110b <fd_alloc>
  801b0e:	89 c3                	mov    %eax,%ebx
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	85 c0                	test   %eax,%eax
  801b15:	0f 88 e2 00 00 00    	js     801bfd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b1b:	83 ec 04             	sub    $0x4,%esp
  801b1e:	68 07 04 00 00       	push   $0x407
  801b23:	ff 75 f0             	pushl  -0x10(%ebp)
  801b26:	6a 00                	push   $0x0
  801b28:	e8 94 f0 ff ff       	call   800bc1 <sys_page_alloc>
  801b2d:	89 c3                	mov    %eax,%ebx
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	0f 88 c3 00 00 00    	js     801bfd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b40:	e8 af f5 ff ff       	call   8010f4 <fd2data>
  801b45:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b47:	83 c4 0c             	add    $0xc,%esp
  801b4a:	68 07 04 00 00       	push   $0x407
  801b4f:	50                   	push   %eax
  801b50:	6a 00                	push   $0x0
  801b52:	e8 6a f0 ff ff       	call   800bc1 <sys_page_alloc>
  801b57:	89 c3                	mov    %eax,%ebx
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	0f 88 89 00 00 00    	js     801bed <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b64:	83 ec 0c             	sub    $0xc,%esp
  801b67:	ff 75 f0             	pushl  -0x10(%ebp)
  801b6a:	e8 85 f5 ff ff       	call   8010f4 <fd2data>
  801b6f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b76:	50                   	push   %eax
  801b77:	6a 00                	push   $0x0
  801b79:	56                   	push   %esi
  801b7a:	6a 00                	push   $0x0
  801b7c:	e8 83 f0 ff ff       	call   800c04 <sys_page_map>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	83 c4 20             	add    $0x20,%esp
  801b86:	85 c0                	test   %eax,%eax
  801b88:	78 55                	js     801bdf <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b8a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b93:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b98:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bad:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bb4:	83 ec 0c             	sub    $0xc,%esp
  801bb7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bba:	e8 25 f5 ff ff       	call   8010e4 <fd2num>
  801bbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bc4:	83 c4 04             	add    $0x4,%esp
  801bc7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bca:	e8 15 f5 ff ff       	call   8010e4 <fd2num>
  801bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd2:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  801bdd:	eb 30                	jmp    801c0f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bdf:	83 ec 08             	sub    $0x8,%esp
  801be2:	56                   	push   %esi
  801be3:	6a 00                	push   $0x0
  801be5:	e8 5c f0 ff ff       	call   800c46 <sys_page_unmap>
  801bea:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bed:	83 ec 08             	sub    $0x8,%esp
  801bf0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 4c f0 ff ff       	call   800c46 <sys_page_unmap>
  801bfa:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bfd:	83 ec 08             	sub    $0x8,%esp
  801c00:	ff 75 f4             	pushl  -0xc(%ebp)
  801c03:	6a 00                	push   $0x0
  801c05:	e8 3c f0 ff ff       	call   800c46 <sys_page_unmap>
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c0f:	89 d0                	mov    %edx,%eax
  801c11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    

00801c18 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c21:	50                   	push   %eax
  801c22:	ff 75 08             	pushl  0x8(%ebp)
  801c25:	e8 30 f5 ff ff       	call   80115a <fd_lookup>
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 18                	js     801c49 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c31:	83 ec 0c             	sub    $0xc,%esp
  801c34:	ff 75 f4             	pushl  -0xc(%ebp)
  801c37:	e8 b8 f4 ff ff       	call   8010f4 <fd2data>
	return _pipeisclosed(fd, p);
  801c3c:	89 c2                	mov    %eax,%edx
  801c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c41:	e8 21 fd ff ff       	call   801967 <_pipeisclosed>
  801c46:	83 c4 10             	add    $0x10,%esp
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c5b:	68 ca 27 80 00       	push   $0x8027ca
  801c60:	ff 75 0c             	pushl  0xc(%ebp)
  801c63:	e8 56 eb ff ff       	call   8007be <strcpy>
	return 0;
}
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	57                   	push   %edi
  801c73:	56                   	push   %esi
  801c74:	53                   	push   %ebx
  801c75:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c7b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c80:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c86:	eb 2d                	jmp    801cb5 <devcons_write+0x46>
		m = n - tot;
  801c88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c8b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c8d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c90:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c95:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	53                   	push   %ebx
  801c9c:	03 45 0c             	add    0xc(%ebp),%eax
  801c9f:	50                   	push   %eax
  801ca0:	57                   	push   %edi
  801ca1:	e8 aa ec ff ff       	call   800950 <memmove>
		sys_cputs(buf, m);
  801ca6:	83 c4 08             	add    $0x8,%esp
  801ca9:	53                   	push   %ebx
  801caa:	57                   	push   %edi
  801cab:	e8 55 ee ff ff       	call   800b05 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb0:	01 de                	add    %ebx,%esi
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	89 f0                	mov    %esi,%eax
  801cb7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cba:	72 cc                	jb     801c88 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    

00801cc4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	83 ec 08             	sub    $0x8,%esp
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ccf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cd3:	74 2a                	je     801cff <devcons_read+0x3b>
  801cd5:	eb 05                	jmp    801cdc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cd7:	e8 c6 ee ff ff       	call   800ba2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cdc:	e8 42 ee ff ff       	call   800b23 <sys_cgetc>
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	74 f2                	je     801cd7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	78 16                	js     801cff <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ce9:	83 f8 04             	cmp    $0x4,%eax
  801cec:	74 0c                	je     801cfa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cee:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf1:	88 02                	mov    %al,(%edx)
	return 1;
  801cf3:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf8:	eb 05                	jmp    801cff <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cfa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d07:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d0d:	6a 01                	push   $0x1
  801d0f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d12:	50                   	push   %eax
  801d13:	e8 ed ed ff ff       	call   800b05 <sys_cputs>
}
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <getchar>:

int
getchar(void)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d23:	6a 01                	push   $0x1
  801d25:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d28:	50                   	push   %eax
  801d29:	6a 00                	push   $0x0
  801d2b:	e8 90 f6 ff ff       	call   8013c0 <read>
	if (r < 0)
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	85 c0                	test   %eax,%eax
  801d35:	78 0f                	js     801d46 <getchar+0x29>
		return r;
	if (r < 1)
  801d37:	85 c0                	test   %eax,%eax
  801d39:	7e 06                	jle    801d41 <getchar+0x24>
		return -E_EOF;
	return c;
  801d3b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d3f:	eb 05                	jmp    801d46 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d41:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d51:	50                   	push   %eax
  801d52:	ff 75 08             	pushl  0x8(%ebp)
  801d55:	e8 00 f4 ff ff       	call   80115a <fd_lookup>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 11                	js     801d72 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d64:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6a:	39 10                	cmp    %edx,(%eax)
  801d6c:	0f 94 c0             	sete   %al
  801d6f:	0f b6 c0             	movzbl %al,%eax
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <opencons>:

int
opencons(void)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7d:	50                   	push   %eax
  801d7e:	e8 88 f3 ff ff       	call   80110b <fd_alloc>
  801d83:	83 c4 10             	add    $0x10,%esp
		return r;
  801d86:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 3e                	js     801dca <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d8c:	83 ec 04             	sub    $0x4,%esp
  801d8f:	68 07 04 00 00       	push   $0x407
  801d94:	ff 75 f4             	pushl  -0xc(%ebp)
  801d97:	6a 00                	push   $0x0
  801d99:	e8 23 ee ff ff       	call   800bc1 <sys_page_alloc>
  801d9e:	83 c4 10             	add    $0x10,%esp
		return r;
  801da1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801da3:	85 c0                	test   %eax,%eax
  801da5:	78 23                	js     801dca <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801da7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	50                   	push   %eax
  801dc0:	e8 1f f3 ff ff       	call   8010e4 <fd2num>
  801dc5:	89 c2                	mov    %eax,%edx
  801dc7:	83 c4 10             	add    $0x10,%esp
}
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    

00801dce <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dd4:	83 3d 00 60 c0 00 00 	cmpl   $0x0,0xc06000
  801ddb:	75 2a                	jne    801e07 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	6a 07                	push   $0x7
  801de2:	68 00 f0 bf ee       	push   $0xeebff000
  801de7:	6a 00                	push   $0x0
  801de9:	e8 d3 ed ff ff       	call   800bc1 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	85 c0                	test   %eax,%eax
  801df3:	79 12                	jns    801e07 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801df5:	50                   	push   %eax
  801df6:	68 d6 27 80 00       	push   $0x8027d6
  801dfb:	6a 23                	push   $0x23
  801dfd:	68 da 27 80 00       	push   $0x8027da
  801e02:	e8 59 e3 ff ff       	call   800160 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e07:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0a:	a3 00 60 c0 00       	mov    %eax,0xc06000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e0f:	83 ec 08             	sub    $0x8,%esp
  801e12:	68 39 1e 80 00       	push   $0x801e39
  801e17:	6a 00                	push   $0x0
  801e19:	e8 ee ee ff ff       	call   800d0c <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	85 c0                	test   %eax,%eax
  801e23:	79 12                	jns    801e37 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e25:	50                   	push   %eax
  801e26:	68 d6 27 80 00       	push   $0x8027d6
  801e2b:	6a 2c                	push   $0x2c
  801e2d:	68 da 27 80 00       	push   $0x8027da
  801e32:	e8 29 e3 ff ff       	call   800160 <_panic>
	}
}
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    

00801e39 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e39:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e3a:	a1 00 60 c0 00       	mov    0xc06000,%eax
	call *%eax
  801e3f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e41:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e44:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e48:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e4d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e51:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e53:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e56:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e57:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e5a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e5b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e5c:	c3                   	ret    

00801e5d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	56                   	push   %esi
  801e61:	53                   	push   %ebx
  801e62:	8b 75 08             	mov    0x8(%ebp),%esi
  801e65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	75 12                	jne    801e81 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	68 00 00 c0 ee       	push   $0xeec00000
  801e77:	e8 f5 ee ff ff       	call   800d71 <sys_ipc_recv>
  801e7c:	83 c4 10             	add    $0x10,%esp
  801e7f:	eb 0c                	jmp    801e8d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e81:	83 ec 0c             	sub    $0xc,%esp
  801e84:	50                   	push   %eax
  801e85:	e8 e7 ee ff ff       	call   800d71 <sys_ipc_recv>
  801e8a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e8d:	85 f6                	test   %esi,%esi
  801e8f:	0f 95 c1             	setne  %cl
  801e92:	85 db                	test   %ebx,%ebx
  801e94:	0f 95 c2             	setne  %dl
  801e97:	84 d1                	test   %dl,%cl
  801e99:	74 09                	je     801ea4 <ipc_recv+0x47>
  801e9b:	89 c2                	mov    %eax,%edx
  801e9d:	c1 ea 1f             	shr    $0x1f,%edx
  801ea0:	84 d2                	test   %dl,%dl
  801ea2:	75 2a                	jne    801ece <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ea4:	85 f6                	test   %esi,%esi
  801ea6:	74 0d                	je     801eb5 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801ea8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ead:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801eb3:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801eb5:	85 db                	test   %ebx,%ebx
  801eb7:	74 0d                	je     801ec6 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801eb9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ebe:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801ec4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ec6:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ecb:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801ece:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed1:	5b                   	pop    %ebx
  801ed2:	5e                   	pop    %esi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	57                   	push   %edi
  801ed9:	56                   	push   %esi
  801eda:	53                   	push   %ebx
  801edb:	83 ec 0c             	sub    $0xc,%esp
  801ede:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ee1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ee7:	85 db                	test   %ebx,%ebx
  801ee9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eee:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ef1:	ff 75 14             	pushl  0x14(%ebp)
  801ef4:	53                   	push   %ebx
  801ef5:	56                   	push   %esi
  801ef6:	57                   	push   %edi
  801ef7:	e8 52 ee ff ff       	call   800d4e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801efc:	89 c2                	mov    %eax,%edx
  801efe:	c1 ea 1f             	shr    $0x1f,%edx
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	84 d2                	test   %dl,%dl
  801f06:	74 17                	je     801f1f <ipc_send+0x4a>
  801f08:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f0b:	74 12                	je     801f1f <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f0d:	50                   	push   %eax
  801f0e:	68 e8 27 80 00       	push   $0x8027e8
  801f13:	6a 47                	push   $0x47
  801f15:	68 f6 27 80 00       	push   $0x8027f6
  801f1a:	e8 41 e2 ff ff       	call   800160 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f1f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f22:	75 07                	jne    801f2b <ipc_send+0x56>
			sys_yield();
  801f24:	e8 79 ec ff ff       	call   800ba2 <sys_yield>
  801f29:	eb c6                	jmp    801ef1 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	75 c2                	jne    801ef1 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f32:	5b                   	pop    %ebx
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f3d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f42:	89 c2                	mov    %eax,%edx
  801f44:	c1 e2 07             	shl    $0x7,%edx
  801f47:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801f4e:	8b 52 5c             	mov    0x5c(%edx),%edx
  801f51:	39 ca                	cmp    %ecx,%edx
  801f53:	75 11                	jne    801f66 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f55:	89 c2                	mov    %eax,%edx
  801f57:	c1 e2 07             	shl    $0x7,%edx
  801f5a:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f61:	8b 40 54             	mov    0x54(%eax),%eax
  801f64:	eb 0f                	jmp    801f75 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f66:	83 c0 01             	add    $0x1,%eax
  801f69:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f6e:	75 d2                	jne    801f42 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7d:	89 d0                	mov    %edx,%eax
  801f7f:	c1 e8 16             	shr    $0x16,%eax
  801f82:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8e:	f6 c1 01             	test   $0x1,%cl
  801f91:	74 1d                	je     801fb0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f93:	c1 ea 0c             	shr    $0xc,%edx
  801f96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f9d:	f6 c2 01             	test   $0x1,%dl
  801fa0:	74 0e                	je     801fb0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa2:	c1 ea 0c             	shr    $0xc,%edx
  801fa5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fac:	ef 
  801fad:	0f b7 c0             	movzwl %ax,%eax
}
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
  801fb2:	66 90                	xchg   %ax,%ax
  801fb4:	66 90                	xchg   %ax,%ax
  801fb6:	66 90                	xchg   %ax,%ax
  801fb8:	66 90                	xchg   %ax,%ax
  801fba:	66 90                	xchg   %ax,%ax
  801fbc:	66 90                	xchg   %ax,%ax
  801fbe:	66 90                	xchg   %ax,%ax

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
