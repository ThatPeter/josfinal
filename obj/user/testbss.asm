
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
  800039:	68 e0 1e 80 00       	push   $0x801ee0
  80003e:	e8 32 02 00 00       	call   800275 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 5b 1f 80 00       	push   $0x801f5b
  80005b:	6a 11                	push   $0x11
  80005d:	68 78 1f 80 00       	push   $0x801f78
  800062:	e8 35 01 00 00       	call   80019c <_panic>
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
  800096:	68 00 1f 80 00       	push   $0x801f00
  80009b:	6a 16                	push   $0x16
  80009d:	68 78 1f 80 00       	push   $0x801f78
  8000a2:	e8 f5 00 00 00       	call   80019c <_panic>
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
  8000b4:	68 28 1f 80 00       	push   $0x801f28
  8000b9:	e8 b7 01 00 00       	call   800275 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 87 1f 80 00       	push   $0x801f87
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 78 1f 80 00       	push   $0x801f78
  8000d7:	e8 c0 00 00 00       	call   80019c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e5:	c7 05 20 40 c0 00 00 	movl   $0x0,0xc04020
  8000ec:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000ef:	e8 cb 0a 00 00       	call   800bbf <sys_getenvid>
  8000f4:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8000f6:	83 ec 08             	sub    $0x8,%esp
  8000f9:	50                   	push   %eax
  8000fa:	68 a0 1f 80 00       	push   $0x801fa0
  8000ff:	e8 71 01 00 00       	call   800275 <cprintf>
  800104:	8b 3d 20 40 c0 00    	mov    0xc04020,%edi
  80010a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800117:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  80011c:	89 c1                	mov    %eax,%ecx
  80011e:	c1 e1 07             	shl    $0x7,%ecx
  800121:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800128:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  80012b:	39 cb                	cmp    %ecx,%ebx
  80012d:	0f 44 fa             	cmove  %edx,%edi
  800130:	b9 01 00 00 00       	mov    $0x1,%ecx
  800135:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800138:	83 c0 01             	add    $0x1,%eax
  80013b:	81 c2 84 00 00 00    	add    $0x84,%edx
  800141:	3d 00 04 00 00       	cmp    $0x400,%eax
  800146:	75 d4                	jne    80011c <libmain+0x40>
  800148:	89 f0                	mov    %esi,%eax
  80014a:	84 c0                	test   %al,%al
  80014c:	74 06                	je     800154 <libmain+0x78>
  80014e:	89 3d 20 40 c0 00    	mov    %edi,0xc04020
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800154:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800158:	7e 0a                	jle    800164 <libmain+0x88>
		binaryname = argv[0];
  80015a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015d:	8b 00                	mov    (%eax),%eax
  80015f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	ff 75 0c             	pushl  0xc(%ebp)
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 c1 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800172:	e8 0b 00 00 00       	call   800182 <exit>
}
  800177:	83 c4 10             	add    $0x10,%esp
  80017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    

00800182 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800188:	e8 4c 0e 00 00       	call   800fd9 <close_all>
	sys_env_destroy(0);
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	6a 00                	push   $0x0
  800192:	e8 e7 09 00 00       	call   800b7e <sys_env_destroy>
}
  800197:	83 c4 10             	add    $0x10,%esp
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001aa:	e8 10 0a 00 00       	call   800bbf <sys_getenvid>
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	ff 75 0c             	pushl  0xc(%ebp)
  8001b5:	ff 75 08             	pushl  0x8(%ebp)
  8001b8:	56                   	push   %esi
  8001b9:	50                   	push   %eax
  8001ba:	68 cc 1f 80 00       	push   $0x801fcc
  8001bf:	e8 b1 00 00 00       	call   800275 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c4:	83 c4 18             	add    $0x18,%esp
  8001c7:	53                   	push   %ebx
  8001c8:	ff 75 10             	pushl  0x10(%ebp)
  8001cb:	e8 54 00 00 00       	call   800224 <vcprintf>
	cprintf("\n");
  8001d0:	c7 04 24 76 1f 80 00 	movl   $0x801f76,(%esp)
  8001d7:	e8 99 00 00 00       	call   800275 <cprintf>
  8001dc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001df:	cc                   	int3   
  8001e0:	eb fd                	jmp    8001df <_panic+0x43>

008001e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 04             	sub    $0x4,%esp
  8001e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ec:	8b 13                	mov    (%ebx),%edx
  8001ee:	8d 42 01             	lea    0x1(%edx),%eax
  8001f1:	89 03                	mov    %eax,(%ebx)
  8001f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ff:	75 1a                	jne    80021b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	68 ff 00 00 00       	push   $0xff
  800209:	8d 43 08             	lea    0x8(%ebx),%eax
  80020c:	50                   	push   %eax
  80020d:	e8 2f 09 00 00       	call   800b41 <sys_cputs>
		b->idx = 0;
  800212:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800218:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80021b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80022d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800234:	00 00 00 
	b.cnt = 0;
  800237:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800241:	ff 75 0c             	pushl  0xc(%ebp)
  800244:	ff 75 08             	pushl  0x8(%ebp)
  800247:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024d:	50                   	push   %eax
  80024e:	68 e2 01 80 00       	push   $0x8001e2
  800253:	e8 54 01 00 00       	call   8003ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800258:	83 c4 08             	add    $0x8,%esp
  80025b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800261:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800267:	50                   	push   %eax
  800268:	e8 d4 08 00 00       	call   800b41 <sys_cputs>

	return b.cnt;
}
  80026d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027e:	50                   	push   %eax
  80027f:	ff 75 08             	pushl  0x8(%ebp)
  800282:	e8 9d ff ff ff       	call   800224 <vcprintf>
	va_end(ap);

	return cnt;
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	57                   	push   %edi
  80028d:	56                   	push   %esi
  80028e:	53                   	push   %ebx
  80028f:	83 ec 1c             	sub    $0x1c,%esp
  800292:	89 c7                	mov    %eax,%edi
  800294:	89 d6                	mov    %edx,%esi
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80029f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002ad:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002b0:	39 d3                	cmp    %edx,%ebx
  8002b2:	72 05                	jb     8002b9 <printnum+0x30>
  8002b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b7:	77 45                	ja     8002fe <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b9:	83 ec 0c             	sub    $0xc,%esp
  8002bc:	ff 75 18             	pushl  0x18(%ebp)
  8002bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c5:	53                   	push   %ebx
  8002c6:	ff 75 10             	pushl  0x10(%ebp)
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d8:	e8 73 19 00 00       	call   801c50 <__udivdi3>
  8002dd:	83 c4 18             	add    $0x18,%esp
  8002e0:	52                   	push   %edx
  8002e1:	50                   	push   %eax
  8002e2:	89 f2                	mov    %esi,%edx
  8002e4:	89 f8                	mov    %edi,%eax
  8002e6:	e8 9e ff ff ff       	call   800289 <printnum>
  8002eb:	83 c4 20             	add    $0x20,%esp
  8002ee:	eb 18                	jmp    800308 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	56                   	push   %esi
  8002f4:	ff 75 18             	pushl  0x18(%ebp)
  8002f7:	ff d7                	call   *%edi
  8002f9:	83 c4 10             	add    $0x10,%esp
  8002fc:	eb 03                	jmp    800301 <printnum+0x78>
  8002fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800301:	83 eb 01             	sub    $0x1,%ebx
  800304:	85 db                	test   %ebx,%ebx
  800306:	7f e8                	jg     8002f0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800308:	83 ec 08             	sub    $0x8,%esp
  80030b:	56                   	push   %esi
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800312:	ff 75 e0             	pushl  -0x20(%ebp)
  800315:	ff 75 dc             	pushl  -0x24(%ebp)
  800318:	ff 75 d8             	pushl  -0x28(%ebp)
  80031b:	e8 60 1a 00 00       	call   801d80 <__umoddi3>
  800320:	83 c4 14             	add    $0x14,%esp
  800323:	0f be 80 ef 1f 80 00 	movsbl 0x801fef(%eax),%eax
  80032a:	50                   	push   %eax
  80032b:	ff d7                	call   *%edi
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800333:	5b                   	pop    %ebx
  800334:	5e                   	pop    %esi
  800335:	5f                   	pop    %edi
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033b:	83 fa 01             	cmp    $0x1,%edx
  80033e:	7e 0e                	jle    80034e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 08             	lea    0x8(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	8b 52 04             	mov    0x4(%edx),%edx
  80034c:	eb 22                	jmp    800370 <getuint+0x38>
	else if (lflag)
  80034e:	85 d2                	test   %edx,%edx
  800350:	74 10                	je     800362 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 04             	lea    0x4(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	ba 00 00 00 00       	mov    $0x0,%edx
  800360:	eb 0e                	jmp    800370 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800362:	8b 10                	mov    (%eax),%edx
  800364:	8d 4a 04             	lea    0x4(%edx),%ecx
  800367:	89 08                	mov    %ecx,(%eax)
  800369:	8b 02                	mov    (%edx),%eax
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800378:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	3b 50 04             	cmp    0x4(%eax),%edx
  800381:	73 0a                	jae    80038d <sprintputch+0x1b>
		*b->buf++ = ch;
  800383:	8d 4a 01             	lea    0x1(%edx),%ecx
  800386:	89 08                	mov    %ecx,(%eax)
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	88 02                	mov    %al,(%edx)
}
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800395:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800398:	50                   	push   %eax
  800399:	ff 75 10             	pushl  0x10(%ebp)
  80039c:	ff 75 0c             	pushl  0xc(%ebp)
  80039f:	ff 75 08             	pushl  0x8(%ebp)
  8003a2:	e8 05 00 00 00       	call   8003ac <vprintfmt>
	va_end(ap);
}
  8003a7:	83 c4 10             	add    $0x10,%esp
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 2c             	sub    $0x2c,%esp
  8003b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003be:	eb 12                	jmp    8003d2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	0f 84 89 03 00 00    	je     800751 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	53                   	push   %ebx
  8003cc:	50                   	push   %eax
  8003cd:	ff d6                	call   *%esi
  8003cf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d2:	83 c7 01             	add    $0x1,%edi
  8003d5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d9:	83 f8 25             	cmp    $0x25,%eax
  8003dc:	75 e2                	jne    8003c0 <vprintfmt+0x14>
  8003de:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fc:	eb 07                	jmp    800405 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800401:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8d 47 01             	lea    0x1(%edi),%eax
  800408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040b:	0f b6 07             	movzbl (%edi),%eax
  80040e:	0f b6 c8             	movzbl %al,%ecx
  800411:	83 e8 23             	sub    $0x23,%eax
  800414:	3c 55                	cmp    $0x55,%al
  800416:	0f 87 1a 03 00 00    	ja     800736 <vprintfmt+0x38a>
  80041c:	0f b6 c0             	movzbl %al,%eax
  80041f:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800429:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042d:	eb d6                	jmp    800405 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800432:	b8 00 00 00 00       	mov    $0x0,%eax
  800437:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800441:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800444:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800447:	83 fa 09             	cmp    $0x9,%edx
  80044a:	77 39                	ja     800485 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80044f:	eb e9                	jmp    80043a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 48 04             	lea    0x4(%eax),%ecx
  800457:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800462:	eb 27                	jmp    80048b <vprintfmt+0xdf>
  800464:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800467:	85 c0                	test   %eax,%eax
  800469:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046e:	0f 49 c8             	cmovns %eax,%ecx
  800471:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800477:	eb 8c                	jmp    800405 <vprintfmt+0x59>
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800483:	eb 80                	jmp    800405 <vprintfmt+0x59>
  800485:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800488:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80048b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048f:	0f 89 70 ff ff ff    	jns    800405 <vprintfmt+0x59>
				width = precision, precision = -1;
  800495:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800498:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004a2:	e9 5e ff ff ff       	jmp    800405 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ad:	e9 53 ff ff ff       	jmp    800405 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	53                   	push   %ebx
  8004bf:	ff 30                	pushl  (%eax)
  8004c1:	ff d6                	call   *%esi
			break;
  8004c3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c9:	e9 04 ff ff ff       	jmp    8003d2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 50 04             	lea    0x4(%eax),%edx
  8004d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	99                   	cltd   
  8004da:	31 d0                	xor    %edx,%eax
  8004dc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004de:	83 f8 0f             	cmp    $0xf,%eax
  8004e1:	7f 0b                	jg     8004ee <vprintfmt+0x142>
  8004e3:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  8004ea:	85 d2                	test   %edx,%edx
  8004ec:	75 18                	jne    800506 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ee:	50                   	push   %eax
  8004ef:	68 07 20 80 00       	push   $0x802007
  8004f4:	53                   	push   %ebx
  8004f5:	56                   	push   %esi
  8004f6:	e8 94 fe ff ff       	call   80038f <printfmt>
  8004fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800501:	e9 cc fe ff ff       	jmp    8003d2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800506:	52                   	push   %edx
  800507:	68 d5 23 80 00       	push   $0x8023d5
  80050c:	53                   	push   %ebx
  80050d:	56                   	push   %esi
  80050e:	e8 7c fe ff ff       	call   80038f <printfmt>
  800513:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800519:	e9 b4 fe ff ff       	jmp    8003d2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800529:	85 ff                	test   %edi,%edi
  80052b:	b8 00 20 80 00       	mov    $0x802000,%eax
  800530:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800533:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800537:	0f 8e 94 00 00 00    	jle    8005d1 <vprintfmt+0x225>
  80053d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800541:	0f 84 98 00 00 00    	je     8005df <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	ff 75 d0             	pushl  -0x30(%ebp)
  80054d:	57                   	push   %edi
  80054e:	e8 86 02 00 00       	call   8007d9 <strnlen>
  800553:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800556:	29 c1                	sub    %eax,%ecx
  800558:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80055b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80055e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800562:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800565:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800568:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056a:	eb 0f                	jmp    80057b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	ff 75 e0             	pushl  -0x20(%ebp)
  800573:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800575:	83 ef 01             	sub    $0x1,%edi
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	85 ff                	test   %edi,%edi
  80057d:	7f ed                	jg     80056c <vprintfmt+0x1c0>
  80057f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800582:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800585:	85 c9                	test   %ecx,%ecx
  800587:	b8 00 00 00 00       	mov    $0x0,%eax
  80058c:	0f 49 c1             	cmovns %ecx,%eax
  80058f:	29 c1                	sub    %eax,%ecx
  800591:	89 75 08             	mov    %esi,0x8(%ebp)
  800594:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800597:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059a:	89 cb                	mov    %ecx,%ebx
  80059c:	eb 4d                	jmp    8005eb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a2:	74 1b                	je     8005bf <vprintfmt+0x213>
  8005a4:	0f be c0             	movsbl %al,%eax
  8005a7:	83 e8 20             	sub    $0x20,%eax
  8005aa:	83 f8 5e             	cmp    $0x5e,%eax
  8005ad:	76 10                	jbe    8005bf <vprintfmt+0x213>
					putch('?', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	ff 75 0c             	pushl  0xc(%ebp)
  8005b5:	6a 3f                	push   $0x3f
  8005b7:	ff 55 08             	call   *0x8(%ebp)
  8005ba:	83 c4 10             	add    $0x10,%esp
  8005bd:	eb 0d                	jmp    8005cc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	ff 75 0c             	pushl  0xc(%ebp)
  8005c5:	52                   	push   %edx
  8005c6:	ff 55 08             	call   *0x8(%ebp)
  8005c9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cc:	83 eb 01             	sub    $0x1,%ebx
  8005cf:	eb 1a                	jmp    8005eb <vprintfmt+0x23f>
  8005d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005dd:	eb 0c                	jmp    8005eb <vprintfmt+0x23f>
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005eb:	83 c7 01             	add    $0x1,%edi
  8005ee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005f2:	0f be d0             	movsbl %al,%edx
  8005f5:	85 d2                	test   %edx,%edx
  8005f7:	74 23                	je     80061c <vprintfmt+0x270>
  8005f9:	85 f6                	test   %esi,%esi
  8005fb:	78 a1                	js     80059e <vprintfmt+0x1f2>
  8005fd:	83 ee 01             	sub    $0x1,%esi
  800600:	79 9c                	jns    80059e <vprintfmt+0x1f2>
  800602:	89 df                	mov    %ebx,%edi
  800604:	8b 75 08             	mov    0x8(%ebp),%esi
  800607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060a:	eb 18                	jmp    800624 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	6a 20                	push   $0x20
  800612:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800614:	83 ef 01             	sub    $0x1,%edi
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	eb 08                	jmp    800624 <vprintfmt+0x278>
  80061c:	89 df                	mov    %ebx,%edi
  80061e:	8b 75 08             	mov    0x8(%ebp),%esi
  800621:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800624:	85 ff                	test   %edi,%edi
  800626:	7f e4                	jg     80060c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800628:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062b:	e9 a2 fd ff ff       	jmp    8003d2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800630:	83 fa 01             	cmp    $0x1,%edx
  800633:	7e 16                	jle    80064b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 50 08             	lea    0x8(%eax),%edx
  80063b:	89 55 14             	mov    %edx,0x14(%ebp)
  80063e:	8b 50 04             	mov    0x4(%eax),%edx
  800641:	8b 00                	mov    (%eax),%eax
  800643:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800646:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800649:	eb 32                	jmp    80067d <vprintfmt+0x2d1>
	else if (lflag)
  80064b:	85 d2                	test   %edx,%edx
  80064d:	74 18                	je     800667 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 04             	lea    0x4(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 c1                	mov    %eax,%ecx
  80065f:	c1 f9 1f             	sar    $0x1f,%ecx
  800662:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800665:	eb 16                	jmp    80067d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8d 50 04             	lea    0x4(%eax),%edx
  80066d:	89 55 14             	mov    %edx,0x14(%ebp)
  800670:	8b 00                	mov    (%eax),%eax
  800672:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800675:	89 c1                	mov    %eax,%ecx
  800677:	c1 f9 1f             	sar    $0x1f,%ecx
  80067a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800680:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800683:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800688:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068c:	79 74                	jns    800702 <vprintfmt+0x356>
				putch('-', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 2d                	push   $0x2d
  800694:	ff d6                	call   *%esi
				num = -(long long) num;
  800696:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800699:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80069c:	f7 d8                	neg    %eax
  80069e:	83 d2 00             	adc    $0x0,%edx
  8006a1:	f7 da                	neg    %edx
  8006a3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ab:	eb 55                	jmp    800702 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b0:	e8 83 fc ff ff       	call   800338 <getuint>
			base = 10;
  8006b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ba:	eb 46                	jmp    800702 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bf:	e8 74 fc ff ff       	call   800338 <getuint>
			base = 8;
  8006c4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006c9:	eb 37                	jmp    800702 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 30                	push   $0x30
  8006d1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 78                	push   $0x78
  8006d9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8d 50 04             	lea    0x4(%eax),%edx
  8006e1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006eb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ee:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006f3:	eb 0d                	jmp    800702 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f8:	e8 3b fc ff ff       	call   800338 <getuint>
			base = 16;
  8006fd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800702:	83 ec 0c             	sub    $0xc,%esp
  800705:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800709:	57                   	push   %edi
  80070a:	ff 75 e0             	pushl  -0x20(%ebp)
  80070d:	51                   	push   %ecx
  80070e:	52                   	push   %edx
  80070f:	50                   	push   %eax
  800710:	89 da                	mov    %ebx,%edx
  800712:	89 f0                	mov    %esi,%eax
  800714:	e8 70 fb ff ff       	call   800289 <printnum>
			break;
  800719:	83 c4 20             	add    $0x20,%esp
  80071c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071f:	e9 ae fc ff ff       	jmp    8003d2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	51                   	push   %ecx
  800729:	ff d6                	call   *%esi
			break;
  80072b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800731:	e9 9c fc ff ff       	jmp    8003d2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 25                	push   $0x25
  80073c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	eb 03                	jmp    800746 <vprintfmt+0x39a>
  800743:	83 ef 01             	sub    $0x1,%edi
  800746:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80074a:	75 f7                	jne    800743 <vprintfmt+0x397>
  80074c:	e9 81 fc ff ff       	jmp    8003d2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800751:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800754:	5b                   	pop    %ebx
  800755:	5e                   	pop    %esi
  800756:	5f                   	pop    %edi
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 18             	sub    $0x18,%esp
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800765:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800768:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800776:	85 c0                	test   %eax,%eax
  800778:	74 26                	je     8007a0 <vsnprintf+0x47>
  80077a:	85 d2                	test   %edx,%edx
  80077c:	7e 22                	jle    8007a0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077e:	ff 75 14             	pushl  0x14(%ebp)
  800781:	ff 75 10             	pushl  0x10(%ebp)
  800784:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800787:	50                   	push   %eax
  800788:	68 72 03 80 00       	push   $0x800372
  80078d:	e8 1a fc ff ff       	call   8003ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800792:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800795:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	eb 05                	jmp    8007a5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ad:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b0:	50                   	push   %eax
  8007b1:	ff 75 10             	pushl  0x10(%ebp)
  8007b4:	ff 75 0c             	pushl  0xc(%ebp)
  8007b7:	ff 75 08             	pushl  0x8(%ebp)
  8007ba:	e8 9a ff ff ff       	call   800759 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cc:	eb 03                	jmp    8007d1 <strlen+0x10>
		n++;
  8007ce:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d5:	75 f7                	jne    8007ce <strlen+0xd>
		n++;
	return n;
}
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007df:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e7:	eb 03                	jmp    8007ec <strnlen+0x13>
		n++;
  8007e9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ec:	39 c2                	cmp    %eax,%edx
  8007ee:	74 08                	je     8007f8 <strnlen+0x1f>
  8007f0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f4:	75 f3                	jne    8007e9 <strnlen+0x10>
  8007f6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	53                   	push   %ebx
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800804:	89 c2                	mov    %eax,%edx
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	83 c1 01             	add    $0x1,%ecx
  80080c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800810:	88 5a ff             	mov    %bl,-0x1(%edx)
  800813:	84 db                	test   %bl,%bl
  800815:	75 ef                	jne    800806 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800821:	53                   	push   %ebx
  800822:	e8 9a ff ff ff       	call   8007c1 <strlen>
  800827:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082a:	ff 75 0c             	pushl  0xc(%ebp)
  80082d:	01 d8                	add    %ebx,%eax
  80082f:	50                   	push   %eax
  800830:	e8 c5 ff ff ff       	call   8007fa <strcpy>
	return dst;
}
  800835:	89 d8                	mov    %ebx,%eax
  800837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	56                   	push   %esi
  800840:	53                   	push   %ebx
  800841:	8b 75 08             	mov    0x8(%ebp),%esi
  800844:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800847:	89 f3                	mov    %esi,%ebx
  800849:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084c:	89 f2                	mov    %esi,%edx
  80084e:	eb 0f                	jmp    80085f <strncpy+0x23>
		*dst++ = *src;
  800850:	83 c2 01             	add    $0x1,%edx
  800853:	0f b6 01             	movzbl (%ecx),%eax
  800856:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800859:	80 39 01             	cmpb   $0x1,(%ecx)
  80085c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085f:	39 da                	cmp    %ebx,%edx
  800861:	75 ed                	jne    800850 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800863:	89 f0                	mov    %esi,%eax
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	56                   	push   %esi
  80086d:	53                   	push   %ebx
  80086e:	8b 75 08             	mov    0x8(%ebp),%esi
  800871:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800874:	8b 55 10             	mov    0x10(%ebp),%edx
  800877:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800879:	85 d2                	test   %edx,%edx
  80087b:	74 21                	je     80089e <strlcpy+0x35>
  80087d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800881:	89 f2                	mov    %esi,%edx
  800883:	eb 09                	jmp    80088e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800885:	83 c2 01             	add    $0x1,%edx
  800888:	83 c1 01             	add    $0x1,%ecx
  80088b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80088e:	39 c2                	cmp    %eax,%edx
  800890:	74 09                	je     80089b <strlcpy+0x32>
  800892:	0f b6 19             	movzbl (%ecx),%ebx
  800895:	84 db                	test   %bl,%bl
  800897:	75 ec                	jne    800885 <strlcpy+0x1c>
  800899:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80089b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089e:	29 f0                	sub    %esi,%eax
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ad:	eb 06                	jmp    8008b5 <strcmp+0x11>
		p++, q++;
  8008af:	83 c1 01             	add    $0x1,%ecx
  8008b2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b5:	0f b6 01             	movzbl (%ecx),%eax
  8008b8:	84 c0                	test   %al,%al
  8008ba:	74 04                	je     8008c0 <strcmp+0x1c>
  8008bc:	3a 02                	cmp    (%edx),%al
  8008be:	74 ef                	je     8008af <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c0:	0f b6 c0             	movzbl %al,%eax
  8008c3:	0f b6 12             	movzbl (%edx),%edx
  8008c6:	29 d0                	sub    %edx,%eax
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	53                   	push   %ebx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d4:	89 c3                	mov    %eax,%ebx
  8008d6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d9:	eb 06                	jmp    8008e1 <strncmp+0x17>
		n--, p++, q++;
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e1:	39 d8                	cmp    %ebx,%eax
  8008e3:	74 15                	je     8008fa <strncmp+0x30>
  8008e5:	0f b6 08             	movzbl (%eax),%ecx
  8008e8:	84 c9                	test   %cl,%cl
  8008ea:	74 04                	je     8008f0 <strncmp+0x26>
  8008ec:	3a 0a                	cmp    (%edx),%cl
  8008ee:	74 eb                	je     8008db <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f0:	0f b6 00             	movzbl (%eax),%eax
  8008f3:	0f b6 12             	movzbl (%edx),%edx
  8008f6:	29 d0                	sub    %edx,%eax
  8008f8:	eb 05                	jmp    8008ff <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ff:	5b                   	pop    %ebx
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090c:	eb 07                	jmp    800915 <strchr+0x13>
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 0f                	je     800921 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	0f b6 10             	movzbl (%eax),%edx
  800918:	84 d2                	test   %dl,%dl
  80091a:	75 f2                	jne    80090e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092d:	eb 03                	jmp    800932 <strfind+0xf>
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800935:	38 ca                	cmp    %cl,%dl
  800937:	74 04                	je     80093d <strfind+0x1a>
  800939:	84 d2                	test   %dl,%dl
  80093b:	75 f2                	jne    80092f <strfind+0xc>
			break;
	return (char *) s;
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	57                   	push   %edi
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 7d 08             	mov    0x8(%ebp),%edi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094b:	85 c9                	test   %ecx,%ecx
  80094d:	74 36                	je     800985 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800955:	75 28                	jne    80097f <memset+0x40>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 23                	jne    80097f <memset+0x40>
		c &= 0xFF;
  80095c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800960:	89 d3                	mov    %edx,%ebx
  800962:	c1 e3 08             	shl    $0x8,%ebx
  800965:	89 d6                	mov    %edx,%esi
  800967:	c1 e6 18             	shl    $0x18,%esi
  80096a:	89 d0                	mov    %edx,%eax
  80096c:	c1 e0 10             	shl    $0x10,%eax
  80096f:	09 f0                	or     %esi,%eax
  800971:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800973:	89 d8                	mov    %ebx,%eax
  800975:	09 d0                	or     %edx,%eax
  800977:	c1 e9 02             	shr    $0x2,%ecx
  80097a:	fc                   	cld    
  80097b:	f3 ab                	rep stos %eax,%es:(%edi)
  80097d:	eb 06                	jmp    800985 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800982:	fc                   	cld    
  800983:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800985:	89 f8                	mov    %edi,%eax
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 75 0c             	mov    0xc(%ebp),%esi
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099a:	39 c6                	cmp    %eax,%esi
  80099c:	73 35                	jae    8009d3 <memmove+0x47>
  80099e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a1:	39 d0                	cmp    %edx,%eax
  8009a3:	73 2e                	jae    8009d3 <memmove+0x47>
		s += n;
		d += n;
  8009a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	89 d6                	mov    %edx,%esi
  8009aa:	09 fe                	or     %edi,%esi
  8009ac:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b2:	75 13                	jne    8009c7 <memmove+0x3b>
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 0e                	jne    8009c7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b9:	83 ef 04             	sub    $0x4,%edi
  8009bc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
  8009c2:	fd                   	std    
  8009c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c5:	eb 09                	jmp    8009d0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c7:	83 ef 01             	sub    $0x1,%edi
  8009ca:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009cd:	fd                   	std    
  8009ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d0:	fc                   	cld    
  8009d1:	eb 1d                	jmp    8009f0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d3:	89 f2                	mov    %esi,%edx
  8009d5:	09 c2                	or     %eax,%edx
  8009d7:	f6 c2 03             	test   $0x3,%dl
  8009da:	75 0f                	jne    8009eb <memmove+0x5f>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0a                	jne    8009eb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e9:	eb 05                	jmp    8009f0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	fc                   	cld    
  8009ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f7:	ff 75 10             	pushl  0x10(%ebp)
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	ff 75 08             	pushl  0x8(%ebp)
  800a00:	e8 87 ff ff ff       	call   80098c <memmove>
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a12:	89 c6                	mov    %eax,%esi
  800a14:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a17:	eb 1a                	jmp    800a33 <memcmp+0x2c>
		if (*s1 != *s2)
  800a19:	0f b6 08             	movzbl (%eax),%ecx
  800a1c:	0f b6 1a             	movzbl (%edx),%ebx
  800a1f:	38 d9                	cmp    %bl,%cl
  800a21:	74 0a                	je     800a2d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a23:	0f b6 c1             	movzbl %cl,%eax
  800a26:	0f b6 db             	movzbl %bl,%ebx
  800a29:	29 d8                	sub    %ebx,%eax
  800a2b:	eb 0f                	jmp    800a3c <memcmp+0x35>
		s1++, s2++;
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a33:	39 f0                	cmp    %esi,%eax
  800a35:	75 e2                	jne    800a19 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a47:	89 c1                	mov    %eax,%ecx
  800a49:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a50:	eb 0a                	jmp    800a5c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a52:	0f b6 10             	movzbl (%eax),%edx
  800a55:	39 da                	cmp    %ebx,%edx
  800a57:	74 07                	je     800a60 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a59:	83 c0 01             	add    $0x1,%eax
  800a5c:	39 c8                	cmp    %ecx,%eax
  800a5e:	72 f2                	jb     800a52 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a60:	5b                   	pop    %ebx
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	eb 03                	jmp    800a74 <strtol+0x11>
		s++;
  800a71:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	0f b6 01             	movzbl (%ecx),%eax
  800a77:	3c 20                	cmp    $0x20,%al
  800a79:	74 f6                	je     800a71 <strtol+0xe>
  800a7b:	3c 09                	cmp    $0x9,%al
  800a7d:	74 f2                	je     800a71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7f:	3c 2b                	cmp    $0x2b,%al
  800a81:	75 0a                	jne    800a8d <strtol+0x2a>
		s++;
  800a83:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 11                	jmp    800a9e <strtol+0x3b>
  800a8d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a92:	3c 2d                	cmp    $0x2d,%al
  800a94:	75 08                	jne    800a9e <strtol+0x3b>
		s++, neg = 1;
  800a96:	83 c1 01             	add    $0x1,%ecx
  800a99:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa4:	75 15                	jne    800abb <strtol+0x58>
  800aa6:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa9:	75 10                	jne    800abb <strtol+0x58>
  800aab:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aaf:	75 7c                	jne    800b2d <strtol+0xca>
		s += 2, base = 16;
  800ab1:	83 c1 02             	add    $0x2,%ecx
  800ab4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab9:	eb 16                	jmp    800ad1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	75 12                	jne    800ad1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800abf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac7:	75 08                	jne    800ad1 <strtol+0x6e>
		s++, base = 8;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad9:	0f b6 11             	movzbl (%ecx),%edx
  800adc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800adf:	89 f3                	mov    %esi,%ebx
  800ae1:	80 fb 09             	cmp    $0x9,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x8b>
			dig = *s - '0';
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 30             	sub    $0x30,%edx
  800aec:	eb 22                	jmp    800b10 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 08                	ja     800b00 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 57             	sub    $0x57,%edx
  800afe:	eb 10                	jmp    800b10 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b03:	89 f3                	mov    %esi,%ebx
  800b05:	80 fb 19             	cmp    $0x19,%bl
  800b08:	77 16                	ja     800b20 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b0a:	0f be d2             	movsbl %dl,%edx
  800b0d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b10:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b13:	7d 0b                	jge    800b20 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b15:	83 c1 01             	add    $0x1,%ecx
  800b18:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b1e:	eb b9                	jmp    800ad9 <strtol+0x76>

	if (endptr)
  800b20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b24:	74 0d                	je     800b33 <strtol+0xd0>
		*endptr = (char *) s;
  800b26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b29:	89 0e                	mov    %ecx,(%esi)
  800b2b:	eb 06                	jmp    800b33 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2d:	85 db                	test   %ebx,%ebx
  800b2f:	74 98                	je     800ac9 <strtol+0x66>
  800b31:	eb 9e                	jmp    800ad1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b33:	89 c2                	mov    %eax,%edx
  800b35:	f7 da                	neg    %edx
  800b37:	85 ff                	test   %edi,%edi
  800b39:	0f 45 c2             	cmovne %edx,%eax
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	89 c6                	mov    %eax,%esi
  800b58:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_cgetc>:

int
sys_cgetc(void)
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
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	89 cb                	mov    %ecx,%ebx
  800b96:	89 cf                	mov    %ecx,%edi
  800b98:	89 ce                	mov    %ecx,%esi
  800b9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 17                	jle    800bb7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 03                	push   $0x3
  800ba6:	68 ff 22 80 00       	push   $0x8022ff
  800bab:	6a 23                	push   $0x23
  800bad:	68 1c 23 80 00       	push   $0x80231c
  800bb2:	e8 e5 f5 ff ff       	call   80019c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_yield>:

void
sys_yield(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	be 00 00 00 00       	mov    $0x0,%esi
  800c0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c19:	89 f7                	mov    %esi,%edi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 04                	push   $0x4
  800c27:	68 ff 22 80 00       	push   $0x8022ff
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 1c 23 80 00       	push   $0x80231c
  800c33:	e8 64 f5 ff ff       	call   80019c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 05                	push   $0x5
  800c69:	68 ff 22 80 00       	push   $0x8022ff
  800c6e:	6a 23                	push   $0x23
  800c70:	68 1c 23 80 00       	push   $0x80231c
  800c75:	e8 22 f5 ff ff       	call   80019c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 06 00 00 00       	mov    $0x6,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 06                	push   $0x6
  800cab:	68 ff 22 80 00       	push   $0x8022ff
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 1c 23 80 00       	push   $0x80231c
  800cb7:	e8 e0 f4 ff ff       	call   80019c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 08                	push   $0x8
  800ced:	68 ff 22 80 00       	push   $0x8022ff
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 1c 23 80 00       	push   $0x80231c
  800cf9:	e8 9e f4 ff ff       	call   80019c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 09 00 00 00       	mov    $0x9,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 09                	push   $0x9
  800d2f:	68 ff 22 80 00       	push   $0x8022ff
  800d34:	6a 23                	push   $0x23
  800d36:	68 1c 23 80 00       	push   $0x80231c
  800d3b:	e8 5c f4 ff ff       	call   80019c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d56:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 df                	mov    %ebx,%edi
  800d63:	89 de                	mov    %ebx,%esi
  800d65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 0a                	push   $0xa
  800d71:	68 ff 22 80 00       	push   $0x8022ff
  800d76:	6a 23                	push   $0x23
  800d78:	68 1c 23 80 00       	push   $0x80231c
  800d7d:	e8 1a f4 ff ff       	call   80019c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	be 00 00 00 00       	mov    $0x0,%esi
  800d95:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 cb                	mov    %ecx,%ebx
  800dc5:	89 cf                	mov    %ecx,%edi
  800dc7:	89 ce                	mov    %ecx,%esi
  800dc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7e 17                	jle    800de6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	50                   	push   %eax
  800dd3:	6a 0d                	push   $0xd
  800dd5:	68 ff 22 80 00       	push   $0x8022ff
  800dda:	6a 23                	push   $0x23
  800ddc:	68 1c 23 80 00       	push   $0x80231c
  800de1:	e8 b6 f3 ff ff       	call   80019c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	89 ce                	mov    %ecx,%esi
  800e07:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
  800e14:	05 00 00 00 30       	add    $0x30000000,%eax
  800e19:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
  800e24:	05 00 00 00 30       	add    $0x30000000,%eax
  800e29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e40:	89 c2                	mov    %eax,%edx
  800e42:	c1 ea 16             	shr    $0x16,%edx
  800e45:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4c:	f6 c2 01             	test   $0x1,%dl
  800e4f:	74 11                	je     800e62 <fd_alloc+0x2d>
  800e51:	89 c2                	mov    %eax,%edx
  800e53:	c1 ea 0c             	shr    $0xc,%edx
  800e56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5d:	f6 c2 01             	test   $0x1,%dl
  800e60:	75 09                	jne    800e6b <fd_alloc+0x36>
			*fd_store = fd;
  800e62:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e64:	b8 00 00 00 00       	mov    $0x0,%eax
  800e69:	eb 17                	jmp    800e82 <fd_alloc+0x4d>
  800e6b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e70:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e75:	75 c9                	jne    800e40 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e77:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e7d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e8a:	83 f8 1f             	cmp    $0x1f,%eax
  800e8d:	77 36                	ja     800ec5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e8f:	c1 e0 0c             	shl    $0xc,%eax
  800e92:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e97:	89 c2                	mov    %eax,%edx
  800e99:	c1 ea 16             	shr    $0x16,%edx
  800e9c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea3:	f6 c2 01             	test   $0x1,%dl
  800ea6:	74 24                	je     800ecc <fd_lookup+0x48>
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	c1 ea 0c             	shr    $0xc,%edx
  800ead:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb4:	f6 c2 01             	test   $0x1,%dl
  800eb7:	74 1a                	je     800ed3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebc:	89 02                	mov    %eax,(%edx)
	return 0;
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	eb 13                	jmp    800ed8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eca:	eb 0c                	jmp    800ed8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ecc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed1:	eb 05                	jmp    800ed8 <fd_lookup+0x54>
  800ed3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 08             	sub    $0x8,%esp
  800ee0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee3:	ba ac 23 80 00       	mov    $0x8023ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ee8:	eb 13                	jmp    800efd <dev_lookup+0x23>
  800eea:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eed:	39 08                	cmp    %ecx,(%eax)
  800eef:	75 0c                	jne    800efd <dev_lookup+0x23>
			*dev = devtab[i];
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  800efb:	eb 2e                	jmp    800f2b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800efd:	8b 02                	mov    (%edx),%eax
  800eff:	85 c0                	test   %eax,%eax
  800f01:	75 e7                	jne    800eea <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f03:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f08:	8b 40 50             	mov    0x50(%eax),%eax
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	51                   	push   %ecx
  800f0f:	50                   	push   %eax
  800f10:	68 2c 23 80 00       	push   $0x80232c
  800f15:	e8 5b f3 ff ff       	call   800275 <cprintf>
	*dev = 0;
  800f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f23:	83 c4 10             	add    $0x10,%esp
  800f26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
  800f32:	83 ec 10             	sub    $0x10,%esp
  800f35:	8b 75 08             	mov    0x8(%ebp),%esi
  800f38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3e:	50                   	push   %eax
  800f3f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f45:	c1 e8 0c             	shr    $0xc,%eax
  800f48:	50                   	push   %eax
  800f49:	e8 36 ff ff ff       	call   800e84 <fd_lookup>
  800f4e:	83 c4 08             	add    $0x8,%esp
  800f51:	85 c0                	test   %eax,%eax
  800f53:	78 05                	js     800f5a <fd_close+0x2d>
	    || fd != fd2)
  800f55:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f58:	74 0c                	je     800f66 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f5a:	84 db                	test   %bl,%bl
  800f5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f61:	0f 44 c2             	cmove  %edx,%eax
  800f64:	eb 41                	jmp    800fa7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f66:	83 ec 08             	sub    $0x8,%esp
  800f69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f6c:	50                   	push   %eax
  800f6d:	ff 36                	pushl  (%esi)
  800f6f:	e8 66 ff ff ff       	call   800eda <dev_lookup>
  800f74:	89 c3                	mov    %eax,%ebx
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 1a                	js     800f97 <fd_close+0x6a>
		if (dev->dev_close)
  800f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f80:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f83:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	74 0b                	je     800f97 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	56                   	push   %esi
  800f90:	ff d0                	call   *%eax
  800f92:	89 c3                	mov    %eax,%ebx
  800f94:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f97:	83 ec 08             	sub    $0x8,%esp
  800f9a:	56                   	push   %esi
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 e0 fc ff ff       	call   800c82 <sys_page_unmap>
	return r;
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	89 d8                	mov    %ebx,%eax
}
  800fa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb7:	50                   	push   %eax
  800fb8:	ff 75 08             	pushl  0x8(%ebp)
  800fbb:	e8 c4 fe ff ff       	call   800e84 <fd_lookup>
  800fc0:	83 c4 08             	add    $0x8,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 10                	js     800fd7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fc7:	83 ec 08             	sub    $0x8,%esp
  800fca:	6a 01                	push   $0x1
  800fcc:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcf:	e8 59 ff ff ff       	call   800f2d <fd_close>
  800fd4:	83 c4 10             	add    $0x10,%esp
}
  800fd7:	c9                   	leave  
  800fd8:	c3                   	ret    

00800fd9 <close_all>:

void
close_all(void)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	53                   	push   %ebx
  800fe9:	e8 c0 ff ff ff       	call   800fae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fee:	83 c3 01             	add    $0x1,%ebx
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	83 fb 20             	cmp    $0x20,%ebx
  800ff7:	75 ec                	jne    800fe5 <close_all+0xc>
		close(i);
}
  800ff9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	83 ec 2c             	sub    $0x2c,%esp
  801007:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80100a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80100d:	50                   	push   %eax
  80100e:	ff 75 08             	pushl  0x8(%ebp)
  801011:	e8 6e fe ff ff       	call   800e84 <fd_lookup>
  801016:	83 c4 08             	add    $0x8,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	0f 88 c1 00 00 00    	js     8010e2 <dup+0xe4>
		return r;
	close(newfdnum);
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	56                   	push   %esi
  801025:	e8 84 ff ff ff       	call   800fae <close>

	newfd = INDEX2FD(newfdnum);
  80102a:	89 f3                	mov    %esi,%ebx
  80102c:	c1 e3 0c             	shl    $0xc,%ebx
  80102f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801035:	83 c4 04             	add    $0x4,%esp
  801038:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103b:	e8 de fd ff ff       	call   800e1e <fd2data>
  801040:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801042:	89 1c 24             	mov    %ebx,(%esp)
  801045:	e8 d4 fd ff ff       	call   800e1e <fd2data>
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801050:	89 f8                	mov    %edi,%eax
  801052:	c1 e8 16             	shr    $0x16,%eax
  801055:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105c:	a8 01                	test   $0x1,%al
  80105e:	74 37                	je     801097 <dup+0x99>
  801060:	89 f8                	mov    %edi,%eax
  801062:	c1 e8 0c             	shr    $0xc,%eax
  801065:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106c:	f6 c2 01             	test   $0x1,%dl
  80106f:	74 26                	je     801097 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801071:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	25 07 0e 00 00       	and    $0xe07,%eax
  801080:	50                   	push   %eax
  801081:	ff 75 d4             	pushl  -0x2c(%ebp)
  801084:	6a 00                	push   $0x0
  801086:	57                   	push   %edi
  801087:	6a 00                	push   $0x0
  801089:	e8 b2 fb ff ff       	call   800c40 <sys_page_map>
  80108e:	89 c7                	mov    %eax,%edi
  801090:	83 c4 20             	add    $0x20,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 2e                	js     8010c5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801097:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80109a:	89 d0                	mov    %edx,%eax
  80109c:	c1 e8 0c             	shr    $0xc,%eax
  80109f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ae:	50                   	push   %eax
  8010af:	53                   	push   %ebx
  8010b0:	6a 00                	push   $0x0
  8010b2:	52                   	push   %edx
  8010b3:	6a 00                	push   $0x0
  8010b5:	e8 86 fb ff ff       	call   800c40 <sys_page_map>
  8010ba:	89 c7                	mov    %eax,%edi
  8010bc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010bf:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c1:	85 ff                	test   %edi,%edi
  8010c3:	79 1d                	jns    8010e2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	53                   	push   %ebx
  8010c9:	6a 00                	push   $0x0
  8010cb:	e8 b2 fb ff ff       	call   800c82 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d6:	6a 00                	push   $0x0
  8010d8:	e8 a5 fb ff ff       	call   800c82 <sys_page_unmap>
	return r;
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	89 f8                	mov    %edi,%eax
}
  8010e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 14             	sub    $0x14,%esp
  8010f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f7:	50                   	push   %eax
  8010f8:	53                   	push   %ebx
  8010f9:	e8 86 fd ff ff       	call   800e84 <fd_lookup>
  8010fe:	83 c4 08             	add    $0x8,%esp
  801101:	89 c2                	mov    %eax,%edx
  801103:	85 c0                	test   %eax,%eax
  801105:	78 6d                	js     801174 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801107:	83 ec 08             	sub    $0x8,%esp
  80110a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801111:	ff 30                	pushl  (%eax)
  801113:	e8 c2 fd ff ff       	call   800eda <dev_lookup>
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 4c                	js     80116b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801122:	8b 42 08             	mov    0x8(%edx),%eax
  801125:	83 e0 03             	and    $0x3,%eax
  801128:	83 f8 01             	cmp    $0x1,%eax
  80112b:	75 21                	jne    80114e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80112d:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801132:	8b 40 50             	mov    0x50(%eax),%eax
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	53                   	push   %ebx
  801139:	50                   	push   %eax
  80113a:	68 70 23 80 00       	push   $0x802370
  80113f:	e8 31 f1 ff ff       	call   800275 <cprintf>
		return -E_INVAL;
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114c:	eb 26                	jmp    801174 <read+0x8a>
	}
	if (!dev->dev_read)
  80114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801151:	8b 40 08             	mov    0x8(%eax),%eax
  801154:	85 c0                	test   %eax,%eax
  801156:	74 17                	je     80116f <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	ff 75 10             	pushl  0x10(%ebp)
  80115e:	ff 75 0c             	pushl  0xc(%ebp)
  801161:	52                   	push   %edx
  801162:	ff d0                	call   *%eax
  801164:	89 c2                	mov    %eax,%edx
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	eb 09                	jmp    801174 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	eb 05                	jmp    801174 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80116f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801174:	89 d0                	mov    %edx,%eax
  801176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	8b 7d 08             	mov    0x8(%ebp),%edi
  801187:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118f:	eb 21                	jmp    8011b2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801191:	83 ec 04             	sub    $0x4,%esp
  801194:	89 f0                	mov    %esi,%eax
  801196:	29 d8                	sub    %ebx,%eax
  801198:	50                   	push   %eax
  801199:	89 d8                	mov    %ebx,%eax
  80119b:	03 45 0c             	add    0xc(%ebp),%eax
  80119e:	50                   	push   %eax
  80119f:	57                   	push   %edi
  8011a0:	e8 45 ff ff ff       	call   8010ea <read>
		if (m < 0)
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 10                	js     8011bc <readn+0x41>
			return m;
		if (m == 0)
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 0a                	je     8011ba <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b0:	01 c3                	add    %eax,%ebx
  8011b2:	39 f3                	cmp    %esi,%ebx
  8011b4:	72 db                	jb     801191 <readn+0x16>
  8011b6:	89 d8                	mov    %ebx,%eax
  8011b8:	eb 02                	jmp    8011bc <readn+0x41>
  8011ba:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 14             	sub    $0x14,%esp
  8011cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d1:	50                   	push   %eax
  8011d2:	53                   	push   %ebx
  8011d3:	e8 ac fc ff ff       	call   800e84 <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 68                	js     801249 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011eb:	ff 30                	pushl  (%eax)
  8011ed:	e8 e8 fc ff ff       	call   800eda <dev_lookup>
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 47                	js     801240 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801200:	75 21                	jne    801223 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801202:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801207:	8b 40 50             	mov    0x50(%eax),%eax
  80120a:	83 ec 04             	sub    $0x4,%esp
  80120d:	53                   	push   %ebx
  80120e:	50                   	push   %eax
  80120f:	68 8c 23 80 00       	push   $0x80238c
  801214:	e8 5c f0 ff ff       	call   800275 <cprintf>
		return -E_INVAL;
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801221:	eb 26                	jmp    801249 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801223:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801226:	8b 52 0c             	mov    0xc(%edx),%edx
  801229:	85 d2                	test   %edx,%edx
  80122b:	74 17                	je     801244 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80122d:	83 ec 04             	sub    $0x4,%esp
  801230:	ff 75 10             	pushl  0x10(%ebp)
  801233:	ff 75 0c             	pushl  0xc(%ebp)
  801236:	50                   	push   %eax
  801237:	ff d2                	call   *%edx
  801239:	89 c2                	mov    %eax,%edx
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	eb 09                	jmp    801249 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801240:	89 c2                	mov    %eax,%edx
  801242:	eb 05                	jmp    801249 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801244:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801249:	89 d0                	mov    %edx,%eax
  80124b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124e:	c9                   	leave  
  80124f:	c3                   	ret    

00801250 <seek>:

int
seek(int fdnum, off_t offset)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801256:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	ff 75 08             	pushl  0x8(%ebp)
  80125d:	e8 22 fc ff ff       	call   800e84 <fd_lookup>
  801262:	83 c4 08             	add    $0x8,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	78 0e                	js     801277 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801269:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80126c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801272:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801277:	c9                   	leave  
  801278:	c3                   	ret    

00801279 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	53                   	push   %ebx
  80127d:	83 ec 14             	sub    $0x14,%esp
  801280:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801283:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801286:	50                   	push   %eax
  801287:	53                   	push   %ebx
  801288:	e8 f7 fb ff ff       	call   800e84 <fd_lookup>
  80128d:	83 c4 08             	add    $0x8,%esp
  801290:	89 c2                	mov    %eax,%edx
  801292:	85 c0                	test   %eax,%eax
  801294:	78 65                	js     8012fb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a0:	ff 30                	pushl  (%eax)
  8012a2:	e8 33 fc ff ff       	call   800eda <dev_lookup>
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 44                	js     8012f2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b5:	75 21                	jne    8012d8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b7:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012bc:	8b 40 50             	mov    0x50(%eax),%eax
  8012bf:	83 ec 04             	sub    $0x4,%esp
  8012c2:	53                   	push   %ebx
  8012c3:	50                   	push   %eax
  8012c4:	68 4c 23 80 00       	push   $0x80234c
  8012c9:	e8 a7 ef ff ff       	call   800275 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d6:	eb 23                	jmp    8012fb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012db:	8b 52 18             	mov    0x18(%edx),%edx
  8012de:	85 d2                	test   %edx,%edx
  8012e0:	74 14                	je     8012f6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	ff 75 0c             	pushl  0xc(%ebp)
  8012e8:	50                   	push   %eax
  8012e9:	ff d2                	call   *%edx
  8012eb:	89 c2                	mov    %eax,%edx
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	eb 09                	jmp    8012fb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	eb 05                	jmp    8012fb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012fb:	89 d0                	mov    %edx,%eax
  8012fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 14             	sub    $0x14,%esp
  801309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	ff 75 08             	pushl  0x8(%ebp)
  801313:	e8 6c fb ff ff       	call   800e84 <fd_lookup>
  801318:	83 c4 08             	add    $0x8,%esp
  80131b:	89 c2                	mov    %eax,%edx
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 58                	js     801379 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801327:	50                   	push   %eax
  801328:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132b:	ff 30                	pushl  (%eax)
  80132d:	e8 a8 fb ff ff       	call   800eda <dev_lookup>
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 37                	js     801370 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801339:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801340:	74 32                	je     801374 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801342:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801345:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80134c:	00 00 00 
	stat->st_isdir = 0;
  80134f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801356:	00 00 00 
	stat->st_dev = dev;
  801359:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	53                   	push   %ebx
  801363:	ff 75 f0             	pushl  -0x10(%ebp)
  801366:	ff 50 14             	call   *0x14(%eax)
  801369:	89 c2                	mov    %eax,%edx
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	eb 09                	jmp    801379 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801370:	89 c2                	mov    %eax,%edx
  801372:	eb 05                	jmp    801379 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801374:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801379:	89 d0                	mov    %edx,%eax
  80137b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801385:	83 ec 08             	sub    $0x8,%esp
  801388:	6a 00                	push   $0x0
  80138a:	ff 75 08             	pushl  0x8(%ebp)
  80138d:	e8 e3 01 00 00       	call   801575 <open>
  801392:	89 c3                	mov    %eax,%ebx
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	78 1b                	js     8013b6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	ff 75 0c             	pushl  0xc(%ebp)
  8013a1:	50                   	push   %eax
  8013a2:	e8 5b ff ff ff       	call   801302 <fstat>
  8013a7:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a9:	89 1c 24             	mov    %ebx,(%esp)
  8013ac:	e8 fd fb ff ff       	call   800fae <close>
	return r;
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	89 f0                	mov    %esi,%eax
}
  8013b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5e                   	pop    %esi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	56                   	push   %esi
  8013c1:	53                   	push   %ebx
  8013c2:	89 c6                	mov    %eax,%esi
  8013c4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013cd:	75 12                	jne    8013e1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	6a 01                	push   $0x1
  8013d4:	e8 f6 07 00 00       	call   801bcf <ipc_find_env>
  8013d9:	a3 00 40 80 00       	mov    %eax,0x804000
  8013de:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013e1:	6a 07                	push   $0x7
  8013e3:	68 00 50 c0 00       	push   $0xc05000
  8013e8:	56                   	push   %esi
  8013e9:	ff 35 00 40 80 00    	pushl  0x804000
  8013ef:	e8 79 07 00 00       	call   801b6d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f4:	83 c4 0c             	add    $0xc,%esp
  8013f7:	6a 00                	push   $0x0
  8013f9:	53                   	push   %ebx
  8013fa:	6a 00                	push   $0x0
  8013fc:	e8 f7 06 00 00       	call   801af8 <ipc_recv>
}
  801401:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801404:	5b                   	pop    %ebx
  801405:	5e                   	pop    %esi
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
  801411:	8b 40 0c             	mov    0xc(%eax),%eax
  801414:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801419:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141c:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801421:	ba 00 00 00 00       	mov    $0x0,%edx
  801426:	b8 02 00 00 00       	mov    $0x2,%eax
  80142b:	e8 8d ff ff ff       	call   8013bd <fsipc>
}
  801430:	c9                   	leave  
  801431:	c3                   	ret    

00801432 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801438:	8b 45 08             	mov    0x8(%ebp),%eax
  80143b:	8b 40 0c             	mov    0xc(%eax),%eax
  80143e:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801443:	ba 00 00 00 00       	mov    $0x0,%edx
  801448:	b8 06 00 00 00       	mov    $0x6,%eax
  80144d:	e8 6b ff ff ff       	call   8013bd <fsipc>
}
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	53                   	push   %ebx
  801458:	83 ec 04             	sub    $0x4,%esp
  80145b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80145e:	8b 45 08             	mov    0x8(%ebp),%eax
  801461:	8b 40 0c             	mov    0xc(%eax),%eax
  801464:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801469:	ba 00 00 00 00       	mov    $0x0,%edx
  80146e:	b8 05 00 00 00       	mov    $0x5,%eax
  801473:	e8 45 ff ff ff       	call   8013bd <fsipc>
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 2c                	js     8014a8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	68 00 50 c0 00       	push   $0xc05000
  801484:	53                   	push   %ebx
  801485:	e8 70 f3 ff ff       	call   8007fa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80148a:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80148f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801495:	a1 84 50 c0 00       	mov    0xc05084,%eax
  80149a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ab:	c9                   	leave  
  8014ac:	c3                   	ret    

008014ad <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	83 ec 0c             	sub    $0xc,%esp
  8014b3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bc:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014c2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014c7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014cc:	0f 47 c2             	cmova  %edx,%eax
  8014cf:	a3 04 50 c0 00       	mov    %eax,0xc05004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014d4:	50                   	push   %eax
  8014d5:	ff 75 0c             	pushl  0xc(%ebp)
  8014d8:	68 08 50 c0 00       	push   $0xc05008
  8014dd:	e8 aa f4 ff ff       	call   80098c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8014e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ec:	e8 cc fe ff ff       	call   8013bd <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801501:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801506:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80150c:	ba 00 00 00 00       	mov    $0x0,%edx
  801511:	b8 03 00 00 00       	mov    $0x3,%eax
  801516:	e8 a2 fe ff ff       	call   8013bd <fsipc>
  80151b:	89 c3                	mov    %eax,%ebx
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 4b                	js     80156c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801521:	39 c6                	cmp    %eax,%esi
  801523:	73 16                	jae    80153b <devfile_read+0x48>
  801525:	68 bc 23 80 00       	push   $0x8023bc
  80152a:	68 c3 23 80 00       	push   $0x8023c3
  80152f:	6a 7c                	push   $0x7c
  801531:	68 d8 23 80 00       	push   $0x8023d8
  801536:	e8 61 ec ff ff       	call   80019c <_panic>
	assert(r <= PGSIZE);
  80153b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801540:	7e 16                	jle    801558 <devfile_read+0x65>
  801542:	68 e3 23 80 00       	push   $0x8023e3
  801547:	68 c3 23 80 00       	push   $0x8023c3
  80154c:	6a 7d                	push   $0x7d
  80154e:	68 d8 23 80 00       	push   $0x8023d8
  801553:	e8 44 ec ff ff       	call   80019c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801558:	83 ec 04             	sub    $0x4,%esp
  80155b:	50                   	push   %eax
  80155c:	68 00 50 c0 00       	push   $0xc05000
  801561:	ff 75 0c             	pushl  0xc(%ebp)
  801564:	e8 23 f4 ff ff       	call   80098c <memmove>
	return r;
  801569:	83 c4 10             	add    $0x10,%esp
}
  80156c:	89 d8                	mov    %ebx,%eax
  80156e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801571:	5b                   	pop    %ebx
  801572:	5e                   	pop    %esi
  801573:	5d                   	pop    %ebp
  801574:	c3                   	ret    

00801575 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	53                   	push   %ebx
  801579:	83 ec 20             	sub    $0x20,%esp
  80157c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80157f:	53                   	push   %ebx
  801580:	e8 3c f2 ff ff       	call   8007c1 <strlen>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80158d:	7f 67                	jg     8015f6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158f:	83 ec 0c             	sub    $0xc,%esp
  801592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	e8 9a f8 ff ff       	call   800e35 <fd_alloc>
  80159b:	83 c4 10             	add    $0x10,%esp
		return r;
  80159e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 57                	js     8015fb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	53                   	push   %ebx
  8015a8:	68 00 50 c0 00       	push   $0xc05000
  8015ad:	e8 48 f2 ff ff       	call   8007fa <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b5:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c2:	e8 f6 fd ff ff       	call   8013bd <fsipc>
  8015c7:	89 c3                	mov    %eax,%ebx
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	79 14                	jns    8015e4 <open+0x6f>
		fd_close(fd, 0);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	6a 00                	push   $0x0
  8015d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d8:	e8 50 f9 ff ff       	call   800f2d <fd_close>
		return r;
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	89 da                	mov    %ebx,%edx
  8015e2:	eb 17                	jmp    8015fb <open+0x86>
	}

	return fd2num(fd);
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ea:	e8 1f f8 ff ff       	call   800e0e <fd2num>
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	eb 05                	jmp    8015fb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015fb:	89 d0                	mov    %edx,%eax
  8015fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801608:	ba 00 00 00 00       	mov    $0x0,%edx
  80160d:	b8 08 00 00 00       	mov    $0x8,%eax
  801612:	e8 a6 fd ff ff       	call   8013bd <fsipc>
}
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	56                   	push   %esi
  80161d:	53                   	push   %ebx
  80161e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801621:	83 ec 0c             	sub    $0xc,%esp
  801624:	ff 75 08             	pushl  0x8(%ebp)
  801627:	e8 f2 f7 ff ff       	call   800e1e <fd2data>
  80162c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80162e:	83 c4 08             	add    $0x8,%esp
  801631:	68 ef 23 80 00       	push   $0x8023ef
  801636:	53                   	push   %ebx
  801637:	e8 be f1 ff ff       	call   8007fa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80163c:	8b 46 04             	mov    0x4(%esi),%eax
  80163f:	2b 06                	sub    (%esi),%eax
  801641:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801647:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80164e:	00 00 00 
	stat->st_dev = &devpipe;
  801651:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801658:	30 80 00 
	return 0;
}
  80165b:	b8 00 00 00 00       	mov    $0x0,%eax
  801660:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801663:	5b                   	pop    %ebx
  801664:	5e                   	pop    %esi
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	53                   	push   %ebx
  80166b:	83 ec 0c             	sub    $0xc,%esp
  80166e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801671:	53                   	push   %ebx
  801672:	6a 00                	push   $0x0
  801674:	e8 09 f6 ff ff       	call   800c82 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801679:	89 1c 24             	mov    %ebx,(%esp)
  80167c:	e8 9d f7 ff ff       	call   800e1e <fd2data>
  801681:	83 c4 08             	add    $0x8,%esp
  801684:	50                   	push   %eax
  801685:	6a 00                	push   $0x0
  801687:	e8 f6 f5 ff ff       	call   800c82 <sys_page_unmap>
}
  80168c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168f:	c9                   	leave  
  801690:	c3                   	ret    

00801691 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	57                   	push   %edi
  801695:	56                   	push   %esi
  801696:	53                   	push   %ebx
  801697:	83 ec 1c             	sub    $0x1c,%esp
  80169a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80169d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80169f:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8016a4:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016a7:	83 ec 0c             	sub    $0xc,%esp
  8016aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ad:	e8 5d 05 00 00       	call   801c0f <pageref>
  8016b2:	89 c3                	mov    %eax,%ebx
  8016b4:	89 3c 24             	mov    %edi,(%esp)
  8016b7:	e8 53 05 00 00       	call   801c0f <pageref>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	39 c3                	cmp    %eax,%ebx
  8016c1:	0f 94 c1             	sete   %cl
  8016c4:	0f b6 c9             	movzbl %cl,%ecx
  8016c7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016ca:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  8016d0:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  8016d3:	39 ce                	cmp    %ecx,%esi
  8016d5:	74 1b                	je     8016f2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016d7:	39 c3                	cmp    %eax,%ebx
  8016d9:	75 c4                	jne    80169f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016db:	8b 42 60             	mov    0x60(%edx),%eax
  8016de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e1:	50                   	push   %eax
  8016e2:	56                   	push   %esi
  8016e3:	68 f6 23 80 00       	push   $0x8023f6
  8016e8:	e8 88 eb ff ff       	call   800275 <cprintf>
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	eb ad                	jmp    80169f <_pipeisclosed+0xe>
	}
}
  8016f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5e                   	pop    %esi
  8016fa:	5f                   	pop    %edi
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	57                   	push   %edi
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	83 ec 28             	sub    $0x28,%esp
  801706:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801709:	56                   	push   %esi
  80170a:	e8 0f f7 ff ff       	call   800e1e <fd2data>
  80170f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801711:	83 c4 10             	add    $0x10,%esp
  801714:	bf 00 00 00 00       	mov    $0x0,%edi
  801719:	eb 4b                	jmp    801766 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80171b:	89 da                	mov    %ebx,%edx
  80171d:	89 f0                	mov    %esi,%eax
  80171f:	e8 6d ff ff ff       	call   801691 <_pipeisclosed>
  801724:	85 c0                	test   %eax,%eax
  801726:	75 48                	jne    801770 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801728:	e8 b1 f4 ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80172d:	8b 43 04             	mov    0x4(%ebx),%eax
  801730:	8b 0b                	mov    (%ebx),%ecx
  801732:	8d 51 20             	lea    0x20(%ecx),%edx
  801735:	39 d0                	cmp    %edx,%eax
  801737:	73 e2                	jae    80171b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801739:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801740:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801743:	89 c2                	mov    %eax,%edx
  801745:	c1 fa 1f             	sar    $0x1f,%edx
  801748:	89 d1                	mov    %edx,%ecx
  80174a:	c1 e9 1b             	shr    $0x1b,%ecx
  80174d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801750:	83 e2 1f             	and    $0x1f,%edx
  801753:	29 ca                	sub    %ecx,%edx
  801755:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801759:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80175d:	83 c0 01             	add    $0x1,%eax
  801760:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801763:	83 c7 01             	add    $0x1,%edi
  801766:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801769:	75 c2                	jne    80172d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80176b:	8b 45 10             	mov    0x10(%ebp),%eax
  80176e:	eb 05                	jmp    801775 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801770:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801775:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5f                   	pop    %edi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	57                   	push   %edi
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	83 ec 18             	sub    $0x18,%esp
  801786:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801789:	57                   	push   %edi
  80178a:	e8 8f f6 ff ff       	call   800e1e <fd2data>
  80178f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	bb 00 00 00 00       	mov    $0x0,%ebx
  801799:	eb 3d                	jmp    8017d8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80179b:	85 db                	test   %ebx,%ebx
  80179d:	74 04                	je     8017a3 <devpipe_read+0x26>
				return i;
  80179f:	89 d8                	mov    %ebx,%eax
  8017a1:	eb 44                	jmp    8017e7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017a3:	89 f2                	mov    %esi,%edx
  8017a5:	89 f8                	mov    %edi,%eax
  8017a7:	e8 e5 fe ff ff       	call   801691 <_pipeisclosed>
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	75 32                	jne    8017e2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017b0:	e8 29 f4 ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017b5:	8b 06                	mov    (%esi),%eax
  8017b7:	3b 46 04             	cmp    0x4(%esi),%eax
  8017ba:	74 df                	je     80179b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017bc:	99                   	cltd   
  8017bd:	c1 ea 1b             	shr    $0x1b,%edx
  8017c0:	01 d0                	add    %edx,%eax
  8017c2:	83 e0 1f             	and    $0x1f,%eax
  8017c5:	29 d0                	sub    %edx,%eax
  8017c7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017cf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017d2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d5:	83 c3 01             	add    $0x1,%ebx
  8017d8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017db:	75 d8                	jne    8017b5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e0:	eb 05                	jmp    8017e7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017e2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ea:	5b                   	pop    %ebx
  8017eb:	5e                   	pop    %esi
  8017ec:	5f                   	pop    %edi
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	56                   	push   %esi
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fa:	50                   	push   %eax
  8017fb:	e8 35 f6 ff ff       	call   800e35 <fd_alloc>
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	89 c2                	mov    %eax,%edx
  801805:	85 c0                	test   %eax,%eax
  801807:	0f 88 2c 01 00 00    	js     801939 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180d:	83 ec 04             	sub    $0x4,%esp
  801810:	68 07 04 00 00       	push   $0x407
  801815:	ff 75 f4             	pushl  -0xc(%ebp)
  801818:	6a 00                	push   $0x0
  80181a:	e8 de f3 ff ff       	call   800bfd <sys_page_alloc>
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	89 c2                	mov    %eax,%edx
  801824:	85 c0                	test   %eax,%eax
  801826:	0f 88 0d 01 00 00    	js     801939 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	e8 fd f5 ff ff       	call   800e35 <fd_alloc>
  801838:	89 c3                	mov    %eax,%ebx
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	0f 88 e2 00 00 00    	js     801927 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801845:	83 ec 04             	sub    $0x4,%esp
  801848:	68 07 04 00 00       	push   $0x407
  80184d:	ff 75 f0             	pushl  -0x10(%ebp)
  801850:	6a 00                	push   $0x0
  801852:	e8 a6 f3 ff ff       	call   800bfd <sys_page_alloc>
  801857:	89 c3                	mov    %eax,%ebx
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	85 c0                	test   %eax,%eax
  80185e:	0f 88 c3 00 00 00    	js     801927 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	ff 75 f4             	pushl  -0xc(%ebp)
  80186a:	e8 af f5 ff ff       	call   800e1e <fd2data>
  80186f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801871:	83 c4 0c             	add    $0xc,%esp
  801874:	68 07 04 00 00       	push   $0x407
  801879:	50                   	push   %eax
  80187a:	6a 00                	push   $0x0
  80187c:	e8 7c f3 ff ff       	call   800bfd <sys_page_alloc>
  801881:	89 c3                	mov    %eax,%ebx
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	0f 88 89 00 00 00    	js     801917 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	ff 75 f0             	pushl  -0x10(%ebp)
  801894:	e8 85 f5 ff ff       	call   800e1e <fd2data>
  801899:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018a0:	50                   	push   %eax
  8018a1:	6a 00                	push   $0x0
  8018a3:	56                   	push   %esi
  8018a4:	6a 00                	push   $0x0
  8018a6:	e8 95 f3 ff ff       	call   800c40 <sys_page_map>
  8018ab:	89 c3                	mov    %eax,%ebx
  8018ad:	83 c4 20             	add    $0x20,%esp
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 55                	js     801909 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018b4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018c9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018de:	83 ec 0c             	sub    $0xc,%esp
  8018e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e4:	e8 25 f5 ff ff       	call   800e0e <fd2num>
  8018e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018ec:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018ee:	83 c4 04             	add    $0x4,%esp
  8018f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f4:	e8 15 f5 ff ff       	call   800e0e <fd2num>
  8018f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018fc:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	ba 00 00 00 00       	mov    $0x0,%edx
  801907:	eb 30                	jmp    801939 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	56                   	push   %esi
  80190d:	6a 00                	push   $0x0
  80190f:	e8 6e f3 ff ff       	call   800c82 <sys_page_unmap>
  801914:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	ff 75 f0             	pushl  -0x10(%ebp)
  80191d:	6a 00                	push   $0x0
  80191f:	e8 5e f3 ff ff       	call   800c82 <sys_page_unmap>
  801924:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	ff 75 f4             	pushl  -0xc(%ebp)
  80192d:	6a 00                	push   $0x0
  80192f:	e8 4e f3 ff ff       	call   800c82 <sys_page_unmap>
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801939:	89 d0                	mov    %edx,%eax
  80193b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	5d                   	pop    %ebp
  801941:	c3                   	ret    

00801942 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801948:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194b:	50                   	push   %eax
  80194c:	ff 75 08             	pushl  0x8(%ebp)
  80194f:	e8 30 f5 ff ff       	call   800e84 <fd_lookup>
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	85 c0                	test   %eax,%eax
  801959:	78 18                	js     801973 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	ff 75 f4             	pushl  -0xc(%ebp)
  801961:	e8 b8 f4 ff ff       	call   800e1e <fd2data>
	return _pipeisclosed(fd, p);
  801966:	89 c2                	mov    %eax,%edx
  801968:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196b:	e8 21 fd ff ff       	call   801691 <_pipeisclosed>
  801970:	83 c4 10             	add    $0x10,%esp
}
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801978:	b8 00 00 00 00       	mov    $0x0,%eax
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801985:	68 0e 24 80 00       	push   $0x80240e
  80198a:	ff 75 0c             	pushl  0xc(%ebp)
  80198d:	e8 68 ee ff ff       	call   8007fa <strcpy>
	return 0;
}
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	57                   	push   %edi
  80199d:	56                   	push   %esi
  80199e:	53                   	push   %ebx
  80199f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019aa:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019b0:	eb 2d                	jmp    8019df <devcons_write+0x46>
		m = n - tot;
  8019b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019b5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019b7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019ba:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019bf:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019c2:	83 ec 04             	sub    $0x4,%esp
  8019c5:	53                   	push   %ebx
  8019c6:	03 45 0c             	add    0xc(%ebp),%eax
  8019c9:	50                   	push   %eax
  8019ca:	57                   	push   %edi
  8019cb:	e8 bc ef ff ff       	call   80098c <memmove>
		sys_cputs(buf, m);
  8019d0:	83 c4 08             	add    $0x8,%esp
  8019d3:	53                   	push   %ebx
  8019d4:	57                   	push   %edi
  8019d5:	e8 67 f1 ff ff       	call   800b41 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019da:	01 de                	add    %ebx,%esi
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	89 f0                	mov    %esi,%eax
  8019e1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019e4:	72 cc                	jb     8019b2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5e                   	pop    %esi
  8019eb:	5f                   	pop    %edi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 08             	sub    $0x8,%esp
  8019f4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019fd:	74 2a                	je     801a29 <devcons_read+0x3b>
  8019ff:	eb 05                	jmp    801a06 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a01:	e8 d8 f1 ff ff       	call   800bde <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a06:	e8 54 f1 ff ff       	call   800b5f <sys_cgetc>
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	74 f2                	je     801a01 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 16                	js     801a29 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a13:	83 f8 04             	cmp    $0x4,%eax
  801a16:	74 0c                	je     801a24 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1b:	88 02                	mov    %al,(%edx)
	return 1;
  801a1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a22:	eb 05                	jmp    801a29 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a24:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a31:	8b 45 08             	mov    0x8(%ebp),%eax
  801a34:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a37:	6a 01                	push   $0x1
  801a39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a3c:	50                   	push   %eax
  801a3d:	e8 ff f0 ff ff       	call   800b41 <sys_cputs>
}
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <getchar>:

int
getchar(void)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a4d:	6a 01                	push   $0x1
  801a4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a52:	50                   	push   %eax
  801a53:	6a 00                	push   $0x0
  801a55:	e8 90 f6 ff ff       	call   8010ea <read>
	if (r < 0)
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 0f                	js     801a70 <getchar+0x29>
		return r;
	if (r < 1)
  801a61:	85 c0                	test   %eax,%eax
  801a63:	7e 06                	jle    801a6b <getchar+0x24>
		return -E_EOF;
	return c;
  801a65:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a69:	eb 05                	jmp    801a70 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a6b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7b:	50                   	push   %eax
  801a7c:	ff 75 08             	pushl  0x8(%ebp)
  801a7f:	e8 00 f4 ff ff       	call   800e84 <fd_lookup>
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 11                	js     801a9c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a94:	39 10                	cmp    %edx,(%eax)
  801a96:	0f 94 c0             	sete   %al
  801a99:	0f b6 c0             	movzbl %al,%eax
}
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <opencons>:

int
opencons(void)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	50                   	push   %eax
  801aa8:	e8 88 f3 ff ff       	call   800e35 <fd_alloc>
  801aad:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 3e                	js     801af4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab6:	83 ec 04             	sub    $0x4,%esp
  801ab9:	68 07 04 00 00       	push   $0x407
  801abe:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac1:	6a 00                	push   $0x0
  801ac3:	e8 35 f1 ff ff       	call   800bfd <sys_page_alloc>
  801ac8:	83 c4 10             	add    $0x10,%esp
		return r;
  801acb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 23                	js     801af4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ad1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ada:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	50                   	push   %eax
  801aea:	e8 1f f3 ff ff       	call   800e0e <fd2num>
  801aef:	89 c2                	mov    %eax,%edx
  801af1:	83 c4 10             	add    $0x10,%esp
}
  801af4:	89 d0                	mov    %edx,%eax
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	56                   	push   %esi
  801afc:	53                   	push   %ebx
  801afd:	8b 75 08             	mov    0x8(%ebp),%esi
  801b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801b06:	85 c0                	test   %eax,%eax
  801b08:	75 12                	jne    801b1c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	68 00 00 c0 ee       	push   $0xeec00000
  801b12:	e8 96 f2 ff ff       	call   800dad <sys_ipc_recv>
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	eb 0c                	jmp    801b28 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801b1c:	83 ec 0c             	sub    $0xc,%esp
  801b1f:	50                   	push   %eax
  801b20:	e8 88 f2 ff ff       	call   800dad <sys_ipc_recv>
  801b25:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801b28:	85 f6                	test   %esi,%esi
  801b2a:	0f 95 c1             	setne  %cl
  801b2d:	85 db                	test   %ebx,%ebx
  801b2f:	0f 95 c2             	setne  %dl
  801b32:	84 d1                	test   %dl,%cl
  801b34:	74 09                	je     801b3f <ipc_recv+0x47>
  801b36:	89 c2                	mov    %eax,%edx
  801b38:	c1 ea 1f             	shr    $0x1f,%edx
  801b3b:	84 d2                	test   %dl,%dl
  801b3d:	75 27                	jne    801b66 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b3f:	85 f6                	test   %esi,%esi
  801b41:	74 0a                	je     801b4d <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b43:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b48:	8b 40 7c             	mov    0x7c(%eax),%eax
  801b4b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b4d:	85 db                	test   %ebx,%ebx
  801b4f:	74 0d                	je     801b5e <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801b51:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b56:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801b5c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b5e:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b63:	8b 40 78             	mov    0x78(%eax),%eax
}
  801b66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    

00801b6d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	57                   	push   %edi
  801b71:	56                   	push   %esi
  801b72:	53                   	push   %ebx
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b79:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b7f:	85 db                	test   %ebx,%ebx
  801b81:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b86:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b89:	ff 75 14             	pushl  0x14(%ebp)
  801b8c:	53                   	push   %ebx
  801b8d:	56                   	push   %esi
  801b8e:	57                   	push   %edi
  801b8f:	e8 f6 f1 ff ff       	call   800d8a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b94:	89 c2                	mov    %eax,%edx
  801b96:	c1 ea 1f             	shr    $0x1f,%edx
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	84 d2                	test   %dl,%dl
  801b9e:	74 17                	je     801bb7 <ipc_send+0x4a>
  801ba0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ba3:	74 12                	je     801bb7 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ba5:	50                   	push   %eax
  801ba6:	68 1a 24 80 00       	push   $0x80241a
  801bab:	6a 47                	push   $0x47
  801bad:	68 28 24 80 00       	push   $0x802428
  801bb2:	e8 e5 e5 ff ff       	call   80019c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801bb7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bba:	75 07                	jne    801bc3 <ipc_send+0x56>
			sys_yield();
  801bbc:	e8 1d f0 ff ff       	call   800bde <sys_yield>
  801bc1:	eb c6                	jmp    801b89 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	75 c2                	jne    801b89 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801bc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bca:	5b                   	pop    %ebx
  801bcb:	5e                   	pop    %esi
  801bcc:	5f                   	pop    %edi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bd5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bda:	89 c2                	mov    %eax,%edx
  801bdc:	c1 e2 07             	shl    $0x7,%edx
  801bdf:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801be6:	8b 52 58             	mov    0x58(%edx),%edx
  801be9:	39 ca                	cmp    %ecx,%edx
  801beb:	75 11                	jne    801bfe <ipc_find_env+0x2f>
			return envs[i].env_id;
  801bed:	89 c2                	mov    %eax,%edx
  801bef:	c1 e2 07             	shl    $0x7,%edx
  801bf2:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801bf9:	8b 40 50             	mov    0x50(%eax),%eax
  801bfc:	eb 0f                	jmp    801c0d <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bfe:	83 c0 01             	add    $0x1,%eax
  801c01:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c06:	75 d2                	jne    801bda <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c15:	89 d0                	mov    %edx,%eax
  801c17:	c1 e8 16             	shr    $0x16,%eax
  801c1a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c21:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c26:	f6 c1 01             	test   $0x1,%cl
  801c29:	74 1d                	je     801c48 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c2b:	c1 ea 0c             	shr    $0xc,%edx
  801c2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c35:	f6 c2 01             	test   $0x1,%dl
  801c38:	74 0e                	je     801c48 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c3a:	c1 ea 0c             	shr    $0xc,%edx
  801c3d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c44:	ef 
  801c45:	0f b7 c0             	movzwl %ax,%eax
}
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    
  801c4a:	66 90                	xchg   %ax,%ax
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__udivdi3>:
  801c50:	55                   	push   %ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	83 ec 1c             	sub    $0x1c,%esp
  801c57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c67:	85 f6                	test   %esi,%esi
  801c69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6d:	89 ca                	mov    %ecx,%edx
  801c6f:	89 f8                	mov    %edi,%eax
  801c71:	75 3d                	jne    801cb0 <__udivdi3+0x60>
  801c73:	39 cf                	cmp    %ecx,%edi
  801c75:	0f 87 c5 00 00 00    	ja     801d40 <__udivdi3+0xf0>
  801c7b:	85 ff                	test   %edi,%edi
  801c7d:	89 fd                	mov    %edi,%ebp
  801c7f:	75 0b                	jne    801c8c <__udivdi3+0x3c>
  801c81:	b8 01 00 00 00       	mov    $0x1,%eax
  801c86:	31 d2                	xor    %edx,%edx
  801c88:	f7 f7                	div    %edi
  801c8a:	89 c5                	mov    %eax,%ebp
  801c8c:	89 c8                	mov    %ecx,%eax
  801c8e:	31 d2                	xor    %edx,%edx
  801c90:	f7 f5                	div    %ebp
  801c92:	89 c1                	mov    %eax,%ecx
  801c94:	89 d8                	mov    %ebx,%eax
  801c96:	89 cf                	mov    %ecx,%edi
  801c98:	f7 f5                	div    %ebp
  801c9a:	89 c3                	mov    %eax,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	39 ce                	cmp    %ecx,%esi
  801cb2:	77 74                	ja     801d28 <__udivdi3+0xd8>
  801cb4:	0f bd fe             	bsr    %esi,%edi
  801cb7:	83 f7 1f             	xor    $0x1f,%edi
  801cba:	0f 84 98 00 00 00    	je     801d58 <__udivdi3+0x108>
  801cc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	89 c5                	mov    %eax,%ebp
  801cc9:	29 fb                	sub    %edi,%ebx
  801ccb:	d3 e6                	shl    %cl,%esi
  801ccd:	89 d9                	mov    %ebx,%ecx
  801ccf:	d3 ed                	shr    %cl,%ebp
  801cd1:	89 f9                	mov    %edi,%ecx
  801cd3:	d3 e0                	shl    %cl,%eax
  801cd5:	09 ee                	or     %ebp,%esi
  801cd7:	89 d9                	mov    %ebx,%ecx
  801cd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cdd:	89 d5                	mov    %edx,%ebp
  801cdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ce3:	d3 ed                	shr    %cl,%ebp
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 e2                	shl    %cl,%edx
  801ce9:	89 d9                	mov    %ebx,%ecx
  801ceb:	d3 e8                	shr    %cl,%eax
  801ced:	09 c2                	or     %eax,%edx
  801cef:	89 d0                	mov    %edx,%eax
  801cf1:	89 ea                	mov    %ebp,%edx
  801cf3:	f7 f6                	div    %esi
  801cf5:	89 d5                	mov    %edx,%ebp
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	f7 64 24 0c          	mull   0xc(%esp)
  801cfd:	39 d5                	cmp    %edx,%ebp
  801cff:	72 10                	jb     801d11 <__udivdi3+0xc1>
  801d01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	d3 e6                	shl    %cl,%esi
  801d09:	39 c6                	cmp    %eax,%esi
  801d0b:	73 07                	jae    801d14 <__udivdi3+0xc4>
  801d0d:	39 d5                	cmp    %edx,%ebp
  801d0f:	75 03                	jne    801d14 <__udivdi3+0xc4>
  801d11:	83 eb 01             	sub    $0x1,%ebx
  801d14:	31 ff                	xor    %edi,%edi
  801d16:	89 d8                	mov    %ebx,%eax
  801d18:	89 fa                	mov    %edi,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	31 ff                	xor    %edi,%edi
  801d2a:	31 db                	xor    %ebx,%ebx
  801d2c:	89 d8                	mov    %ebx,%eax
  801d2e:	89 fa                	mov    %edi,%edx
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    
  801d38:	90                   	nop
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	89 d8                	mov    %ebx,%eax
  801d42:	f7 f7                	div    %edi
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 c3                	mov    %eax,%ebx
  801d48:	89 d8                	mov    %ebx,%eax
  801d4a:	89 fa                	mov    %edi,%edx
  801d4c:	83 c4 1c             	add    $0x1c,%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5f                   	pop    %edi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    
  801d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d58:	39 ce                	cmp    %ecx,%esi
  801d5a:	72 0c                	jb     801d68 <__udivdi3+0x118>
  801d5c:	31 db                	xor    %ebx,%ebx
  801d5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d62:	0f 87 34 ff ff ff    	ja     801c9c <__udivdi3+0x4c>
  801d68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d6d:	e9 2a ff ff ff       	jmp    801c9c <__udivdi3+0x4c>
  801d72:	66 90                	xchg   %ax,%ax
  801d74:	66 90                	xchg   %ax,%ax
  801d76:	66 90                	xchg   %ax,%ax
  801d78:	66 90                	xchg   %ax,%ax
  801d7a:	66 90                	xchg   %ax,%ax
  801d7c:	66 90                	xchg   %ax,%ax
  801d7e:	66 90                	xchg   %ax,%ax

00801d80 <__umoddi3>:
  801d80:	55                   	push   %ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	83 ec 1c             	sub    $0x1c,%esp
  801d87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d97:	85 d2                	test   %edx,%edx
  801d99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801da1:	89 f3                	mov    %esi,%ebx
  801da3:	89 3c 24             	mov    %edi,(%esp)
  801da6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801daa:	75 1c                	jne    801dc8 <__umoddi3+0x48>
  801dac:	39 f7                	cmp    %esi,%edi
  801dae:	76 50                	jbe    801e00 <__umoddi3+0x80>
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	f7 f7                	div    %edi
  801db6:	89 d0                	mov    %edx,%eax
  801db8:	31 d2                	xor    %edx,%edx
  801dba:	83 c4 1c             	add    $0x1c,%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5f                   	pop    %edi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    
  801dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc8:	39 f2                	cmp    %esi,%edx
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	77 52                	ja     801e20 <__umoddi3+0xa0>
  801dce:	0f bd ea             	bsr    %edx,%ebp
  801dd1:	83 f5 1f             	xor    $0x1f,%ebp
  801dd4:	75 5a                	jne    801e30 <__umoddi3+0xb0>
  801dd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dda:	0f 82 e0 00 00 00    	jb     801ec0 <__umoddi3+0x140>
  801de0:	39 0c 24             	cmp    %ecx,(%esp)
  801de3:	0f 86 d7 00 00 00    	jbe    801ec0 <__umoddi3+0x140>
  801de9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ded:	8b 54 24 04          	mov    0x4(%esp),%edx
  801df1:	83 c4 1c             	add    $0x1c,%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5f                   	pop    %edi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    
  801df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e00:	85 ff                	test   %edi,%edi
  801e02:	89 fd                	mov    %edi,%ebp
  801e04:	75 0b                	jne    801e11 <__umoddi3+0x91>
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	f7 f7                	div    %edi
  801e0f:	89 c5                	mov    %eax,%ebp
  801e11:	89 f0                	mov    %esi,%eax
  801e13:	31 d2                	xor    %edx,%edx
  801e15:	f7 f5                	div    %ebp
  801e17:	89 c8                	mov    %ecx,%eax
  801e19:	f7 f5                	div    %ebp
  801e1b:	89 d0                	mov    %edx,%eax
  801e1d:	eb 99                	jmp    801db8 <__umoddi3+0x38>
  801e1f:	90                   	nop
  801e20:	89 c8                	mov    %ecx,%eax
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	83 c4 1c             	add    $0x1c,%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    
  801e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e30:	8b 34 24             	mov    (%esp),%esi
  801e33:	bf 20 00 00 00       	mov    $0x20,%edi
  801e38:	89 e9                	mov    %ebp,%ecx
  801e3a:	29 ef                	sub    %ebp,%edi
  801e3c:	d3 e0                	shl    %cl,%eax
  801e3e:	89 f9                	mov    %edi,%ecx
  801e40:	89 f2                	mov    %esi,%edx
  801e42:	d3 ea                	shr    %cl,%edx
  801e44:	89 e9                	mov    %ebp,%ecx
  801e46:	09 c2                	or     %eax,%edx
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	89 14 24             	mov    %edx,(%esp)
  801e4d:	89 f2                	mov    %esi,%edx
  801e4f:	d3 e2                	shl    %cl,%edx
  801e51:	89 f9                	mov    %edi,%ecx
  801e53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e5b:	d3 e8                	shr    %cl,%eax
  801e5d:	89 e9                	mov    %ebp,%ecx
  801e5f:	89 c6                	mov    %eax,%esi
  801e61:	d3 e3                	shl    %cl,%ebx
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 d0                	mov    %edx,%eax
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	09 d8                	or     %ebx,%eax
  801e6d:	89 d3                	mov    %edx,%ebx
  801e6f:	89 f2                	mov    %esi,%edx
  801e71:	f7 34 24             	divl   (%esp)
  801e74:	89 d6                	mov    %edx,%esi
  801e76:	d3 e3                	shl    %cl,%ebx
  801e78:	f7 64 24 04          	mull   0x4(%esp)
  801e7c:	39 d6                	cmp    %edx,%esi
  801e7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e82:	89 d1                	mov    %edx,%ecx
  801e84:	89 c3                	mov    %eax,%ebx
  801e86:	72 08                	jb     801e90 <__umoddi3+0x110>
  801e88:	75 11                	jne    801e9b <__umoddi3+0x11b>
  801e8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e8e:	73 0b                	jae    801e9b <__umoddi3+0x11b>
  801e90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e94:	1b 14 24             	sbb    (%esp),%edx
  801e97:	89 d1                	mov    %edx,%ecx
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e9f:	29 da                	sub    %ebx,%edx
  801ea1:	19 ce                	sbb    %ecx,%esi
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 f0                	mov    %esi,%eax
  801ea7:	d3 e0                	shl    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	d3 ea                	shr    %cl,%edx
  801ead:	89 e9                	mov    %ebp,%ecx
  801eaf:	d3 ee                	shr    %cl,%esi
  801eb1:	09 d0                	or     %edx,%eax
  801eb3:	89 f2                	mov    %esi,%edx
  801eb5:	83 c4 1c             	add    $0x1c,%esp
  801eb8:	5b                   	pop    %ebx
  801eb9:	5e                   	pop    %esi
  801eba:	5f                   	pop    %edi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	29 f9                	sub    %edi,%ecx
  801ec2:	19 d6                	sbb    %edx,%esi
  801ec4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ecc:	e9 18 ff ff ff       	jmp    801de9 <__umoddi3+0x69>
