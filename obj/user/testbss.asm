
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
  800039:	68 a0 1e 80 00       	push   $0x801ea0
  80003e:	e8 1a 02 00 00       	call   80025d <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 1b 1f 80 00       	push   $0x801f1b
  80005b:	6a 11                	push   $0x11
  80005d:	68 38 1f 80 00       	push   $0x801f38
  800062:	e8 1d 01 00 00       	call   800184 <_panic>
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
  800096:	68 c0 1e 80 00       	push   $0x801ec0
  80009b:	6a 16                	push   $0x16
  80009d:	68 38 1f 80 00       	push   $0x801f38
  8000a2:	e8 dd 00 00 00       	call   800184 <_panic>
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
  8000b4:	68 e8 1e 80 00       	push   $0x801ee8
  8000b9:	e8 9f 01 00 00       	call   80025d <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 47 1f 80 00       	push   $0x801f47
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 38 1f 80 00       	push   $0x801f38
  8000d7:	e8 a8 00 00 00       	call   800184 <_panic>

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
  8000ef:	e8 b3 0a 00 00       	call   800ba7 <sys_getenvid>
  8000f4:	8b 3d 20 40 c0 00    	mov    0xc04020,%edi
  8000fa:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8000ff:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800109:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80010c:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800112:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800115:	39 c8                	cmp    %ecx,%eax
  800117:	0f 44 fb             	cmove  %ebx,%edi
  80011a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80011f:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800122:	83 c2 01             	add    $0x1,%edx
  800125:	83 c3 7c             	add    $0x7c,%ebx
  800128:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80012e:	75 d9                	jne    800109 <libmain+0x2d>
  800130:	89 f0                	mov    %esi,%eax
  800132:	84 c0                	test   %al,%al
  800134:	74 06                	je     80013c <libmain+0x60>
  800136:	89 3d 20 40 c0 00    	mov    %edi,0xc04020
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800140:	7e 0a                	jle    80014c <libmain+0x70>
		binaryname = argv[0];
  800142:	8b 45 0c             	mov    0xc(%ebp),%eax
  800145:	8b 00                	mov    (%eax),%eax
  800147:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80014c:	83 ec 08             	sub    $0x8,%esp
  80014f:	ff 75 0c             	pushl  0xc(%ebp)
  800152:	ff 75 08             	pushl  0x8(%ebp)
  800155:	e8 d9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80015a:	e8 0b 00 00 00       	call   80016a <exit>
}
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800170:	e8 2c 0e 00 00       	call   800fa1 <close_all>
	sys_env_destroy(0);
  800175:	83 ec 0c             	sub    $0xc,%esp
  800178:	6a 00                	push   $0x0
  80017a:	e8 e7 09 00 00       	call   800b66 <sys_env_destroy>
}
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800189:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800192:	e8 10 0a 00 00       	call   800ba7 <sys_getenvid>
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 0c             	pushl  0xc(%ebp)
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	56                   	push   %esi
  8001a1:	50                   	push   %eax
  8001a2:	68 68 1f 80 00       	push   $0x801f68
  8001a7:	e8 b1 00 00 00       	call   80025d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ac:	83 c4 18             	add    $0x18,%esp
  8001af:	53                   	push   %ebx
  8001b0:	ff 75 10             	pushl  0x10(%ebp)
  8001b3:	e8 54 00 00 00       	call   80020c <vcprintf>
	cprintf("\n");
  8001b8:	c7 04 24 36 1f 80 00 	movl   $0x801f36,(%esp)
  8001bf:	e8 99 00 00 00       	call   80025d <cprintf>
  8001c4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c7:	cc                   	int3   
  8001c8:	eb fd                	jmp    8001c7 <_panic+0x43>

008001ca <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 04             	sub    $0x4,%esp
  8001d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d4:	8b 13                	mov    (%ebx),%edx
  8001d6:	8d 42 01             	lea    0x1(%edx),%eax
  8001d9:	89 03                	mov    %eax,(%ebx)
  8001db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001de:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e7:	75 1a                	jne    800203 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	68 ff 00 00 00       	push   $0xff
  8001f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f4:	50                   	push   %eax
  8001f5:	e8 2f 09 00 00       	call   800b29 <sys_cputs>
		b->idx = 0;
  8001fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800200:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800203:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800207:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800215:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021c:	00 00 00 
	b.cnt = 0;
  80021f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800226:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800229:	ff 75 0c             	pushl  0xc(%ebp)
  80022c:	ff 75 08             	pushl  0x8(%ebp)
  80022f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800235:	50                   	push   %eax
  800236:	68 ca 01 80 00       	push   $0x8001ca
  80023b:	e8 54 01 00 00       	call   800394 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800240:	83 c4 08             	add    $0x8,%esp
  800243:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800249:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024f:	50                   	push   %eax
  800250:	e8 d4 08 00 00       	call   800b29 <sys_cputs>

	return b.cnt;
}
  800255:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    

0080025d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800263:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800266:	50                   	push   %eax
  800267:	ff 75 08             	pushl  0x8(%ebp)
  80026a:	e8 9d ff ff ff       	call   80020c <vcprintf>
	va_end(ap);

	return cnt;
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    

00800271 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 1c             	sub    $0x1c,%esp
  80027a:	89 c7                	mov    %eax,%edi
  80027c:	89 d6                	mov    %edx,%esi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	8b 55 0c             	mov    0xc(%ebp),%edx
  800284:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800287:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80028d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800292:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800295:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800298:	39 d3                	cmp    %edx,%ebx
  80029a:	72 05                	jb     8002a1 <printnum+0x30>
  80029c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80029f:	77 45                	ja     8002e6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	ff 75 18             	pushl  0x18(%ebp)
  8002a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002aa:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ad:	53                   	push   %ebx
  8002ae:	ff 75 10             	pushl  0x10(%ebp)
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c0:	e8 4b 19 00 00       	call   801c10 <__udivdi3>
  8002c5:	83 c4 18             	add    $0x18,%esp
  8002c8:	52                   	push   %edx
  8002c9:	50                   	push   %eax
  8002ca:	89 f2                	mov    %esi,%edx
  8002cc:	89 f8                	mov    %edi,%eax
  8002ce:	e8 9e ff ff ff       	call   800271 <printnum>
  8002d3:	83 c4 20             	add    $0x20,%esp
  8002d6:	eb 18                	jmp    8002f0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	56                   	push   %esi
  8002dc:	ff 75 18             	pushl  0x18(%ebp)
  8002df:	ff d7                	call   *%edi
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	eb 03                	jmp    8002e9 <printnum+0x78>
  8002e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e9:	83 eb 01             	sub    $0x1,%ebx
  8002ec:	85 db                	test   %ebx,%ebx
  8002ee:	7f e8                	jg     8002d8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	56                   	push   %esi
  8002f4:	83 ec 04             	sub    $0x4,%esp
  8002f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8002fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800300:	ff 75 d8             	pushl  -0x28(%ebp)
  800303:	e8 38 1a 00 00       	call   801d40 <__umoddi3>
  800308:	83 c4 14             	add    $0x14,%esp
  80030b:	0f be 80 8b 1f 80 00 	movsbl 0x801f8b(%eax),%eax
  800312:	50                   	push   %eax
  800313:	ff d7                	call   *%edi
}
  800315:	83 c4 10             	add    $0x10,%esp
  800318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800323:	83 fa 01             	cmp    $0x1,%edx
  800326:	7e 0e                	jle    800336 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032d:	89 08                	mov    %ecx,(%eax)
  80032f:	8b 02                	mov    (%edx),%eax
  800331:	8b 52 04             	mov    0x4(%edx),%edx
  800334:	eb 22                	jmp    800358 <getuint+0x38>
	else if (lflag)
  800336:	85 d2                	test   %edx,%edx
  800338:	74 10                	je     80034a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 02                	mov    (%edx),%eax
  800343:	ba 00 00 00 00       	mov    $0x0,%edx
  800348:	eb 0e                	jmp    800358 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800360:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800364:	8b 10                	mov    (%eax),%edx
  800366:	3b 50 04             	cmp    0x4(%eax),%edx
  800369:	73 0a                	jae    800375 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	88 02                	mov    %al,(%edx)
}
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80037d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800380:	50                   	push   %eax
  800381:	ff 75 10             	pushl  0x10(%ebp)
  800384:	ff 75 0c             	pushl  0xc(%ebp)
  800387:	ff 75 08             	pushl  0x8(%ebp)
  80038a:	e8 05 00 00 00       	call   800394 <vprintfmt>
	va_end(ap);
}
  80038f:	83 c4 10             	add    $0x10,%esp
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 2c             	sub    $0x2c,%esp
  80039d:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a6:	eb 12                	jmp    8003ba <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a8:	85 c0                	test   %eax,%eax
  8003aa:	0f 84 89 03 00 00    	je     800739 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	53                   	push   %ebx
  8003b4:	50                   	push   %eax
  8003b5:	ff d6                	call   *%esi
  8003b7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ba:	83 c7 01             	add    $0x1,%edi
  8003bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003c1:	83 f8 25             	cmp    $0x25,%eax
  8003c4:	75 e2                	jne    8003a8 <vprintfmt+0x14>
  8003c6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003ca:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003df:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e4:	eb 07                	jmp    8003ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8d 47 01             	lea    0x1(%edi),%eax
  8003f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f3:	0f b6 07             	movzbl (%edi),%eax
  8003f6:	0f b6 c8             	movzbl %al,%ecx
  8003f9:	83 e8 23             	sub    $0x23,%eax
  8003fc:	3c 55                	cmp    $0x55,%al
  8003fe:	0f 87 1a 03 00 00    	ja     80071e <vprintfmt+0x38a>
  800404:	0f b6 c0             	movzbl %al,%eax
  800407:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800411:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800415:	eb d6                	jmp    8003ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800422:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800425:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800429:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80042c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80042f:	83 fa 09             	cmp    $0x9,%edx
  800432:	77 39                	ja     80046d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800434:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800437:	eb e9                	jmp    800422 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 48 04             	lea    0x4(%eax),%ecx
  80043f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800442:	8b 00                	mov    (%eax),%eax
  800444:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044a:	eb 27                	jmp    800473 <vprintfmt+0xdf>
  80044c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80044f:	85 c0                	test   %eax,%eax
  800451:	b9 00 00 00 00       	mov    $0x0,%ecx
  800456:	0f 49 c8             	cmovns %eax,%ecx
  800459:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80045f:	eb 8c                	jmp    8003ed <vprintfmt+0x59>
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800464:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80046b:	eb 80                	jmp    8003ed <vprintfmt+0x59>
  80046d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800470:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800473:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800477:	0f 89 70 ff ff ff    	jns    8003ed <vprintfmt+0x59>
				width = precision, precision = -1;
  80047d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800480:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048a:	e9 5e ff ff ff       	jmp    8003ed <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800495:	e9 53 ff ff ff       	jmp    8003ed <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	ff 30                	pushl  (%eax)
  8004a9:	ff d6                	call   *%esi
			break;
  8004ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b1:	e9 04 ff ff ff       	jmp    8003ba <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 50 04             	lea    0x4(%eax),%edx
  8004bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	99                   	cltd   
  8004c2:	31 d0                	xor    %edx,%eax
  8004c4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c6:	83 f8 0f             	cmp    $0xf,%eax
  8004c9:	7f 0b                	jg     8004d6 <vprintfmt+0x142>
  8004cb:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	75 18                	jne    8004ee <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004d6:	50                   	push   %eax
  8004d7:	68 a3 1f 80 00       	push   $0x801fa3
  8004dc:	53                   	push   %ebx
  8004dd:	56                   	push   %esi
  8004de:	e8 94 fe ff ff       	call   800377 <printfmt>
  8004e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e9:	e9 cc fe ff ff       	jmp    8003ba <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ee:	52                   	push   %edx
  8004ef:	68 55 23 80 00       	push   $0x802355
  8004f4:	53                   	push   %ebx
  8004f5:	56                   	push   %esi
  8004f6:	e8 7c fe ff ff       	call   800377 <printfmt>
  8004fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	e9 b4 fe ff ff       	jmp    8003ba <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 04             	lea    0x4(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800511:	85 ff                	test   %edi,%edi
  800513:	b8 9c 1f 80 00       	mov    $0x801f9c,%eax
  800518:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051f:	0f 8e 94 00 00 00    	jle    8005b9 <vprintfmt+0x225>
  800525:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800529:	0f 84 98 00 00 00    	je     8005c7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	ff 75 d0             	pushl  -0x30(%ebp)
  800535:	57                   	push   %edi
  800536:	e8 86 02 00 00       	call   8007c1 <strnlen>
  80053b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053e:	29 c1                	sub    %eax,%ecx
  800540:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800543:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800546:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800550:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800552:	eb 0f                	jmp    800563 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	53                   	push   %ebx
  800558:	ff 75 e0             	pushl  -0x20(%ebp)
  80055b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055d:	83 ef 01             	sub    $0x1,%edi
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	85 ff                	test   %edi,%edi
  800565:	7f ed                	jg     800554 <vprintfmt+0x1c0>
  800567:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80056d:	85 c9                	test   %ecx,%ecx
  80056f:	b8 00 00 00 00       	mov    $0x0,%eax
  800574:	0f 49 c1             	cmovns %ecx,%eax
  800577:	29 c1                	sub    %eax,%ecx
  800579:	89 75 08             	mov    %esi,0x8(%ebp)
  80057c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800582:	89 cb                	mov    %ecx,%ebx
  800584:	eb 4d                	jmp    8005d3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800586:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058a:	74 1b                	je     8005a7 <vprintfmt+0x213>
  80058c:	0f be c0             	movsbl %al,%eax
  80058f:	83 e8 20             	sub    $0x20,%eax
  800592:	83 f8 5e             	cmp    $0x5e,%eax
  800595:	76 10                	jbe    8005a7 <vprintfmt+0x213>
					putch('?', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	ff 75 0c             	pushl  0xc(%ebp)
  80059d:	6a 3f                	push   $0x3f
  80059f:	ff 55 08             	call   *0x8(%ebp)
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb 0d                	jmp    8005b4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 0c             	pushl  0xc(%ebp)
  8005ad:	52                   	push   %edx
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b4:	83 eb 01             	sub    $0x1,%ebx
  8005b7:	eb 1a                	jmp    8005d3 <vprintfmt+0x23f>
  8005b9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005bf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c5:	eb 0c                	jmp    8005d3 <vprintfmt+0x23f>
  8005c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d3:	83 c7 01             	add    $0x1,%edi
  8005d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005da:	0f be d0             	movsbl %al,%edx
  8005dd:	85 d2                	test   %edx,%edx
  8005df:	74 23                	je     800604 <vprintfmt+0x270>
  8005e1:	85 f6                	test   %esi,%esi
  8005e3:	78 a1                	js     800586 <vprintfmt+0x1f2>
  8005e5:	83 ee 01             	sub    $0x1,%esi
  8005e8:	79 9c                	jns    800586 <vprintfmt+0x1f2>
  8005ea:	89 df                	mov    %ebx,%edi
  8005ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f2:	eb 18                	jmp    80060c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	6a 20                	push   $0x20
  8005fa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fc:	83 ef 01             	sub    $0x1,%edi
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	eb 08                	jmp    80060c <vprintfmt+0x278>
  800604:	89 df                	mov    %ebx,%edi
  800606:	8b 75 08             	mov    0x8(%ebp),%esi
  800609:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060c:	85 ff                	test   %edi,%edi
  80060e:	7f e4                	jg     8005f4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800613:	e9 a2 fd ff ff       	jmp    8003ba <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800618:	83 fa 01             	cmp    $0x1,%edx
  80061b:	7e 16                	jle    800633 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 08             	lea    0x8(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
  800626:	8b 50 04             	mov    0x4(%eax),%edx
  800629:	8b 00                	mov    (%eax),%eax
  80062b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800631:	eb 32                	jmp    800665 <vprintfmt+0x2d1>
	else if (lflag)
  800633:	85 d2                	test   %edx,%edx
  800635:	74 18                	je     80064f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 50 04             	lea    0x4(%eax),%edx
  80063d:	89 55 14             	mov    %edx,0x14(%ebp)
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	89 c1                	mov    %eax,%ecx
  800647:	c1 f9 1f             	sar    $0x1f,%ecx
  80064a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80064d:	eb 16                	jmp    800665 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 04             	lea    0x4(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 c1                	mov    %eax,%ecx
  80065f:	c1 f9 1f             	sar    $0x1f,%ecx
  800662:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800665:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800668:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80066b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800670:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800674:	79 74                	jns    8006ea <vprintfmt+0x356>
				putch('-', putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 2d                	push   $0x2d
  80067c:	ff d6                	call   *%esi
				num = -(long long) num;
  80067e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800681:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800684:	f7 d8                	neg    %eax
  800686:	83 d2 00             	adc    $0x0,%edx
  800689:	f7 da                	neg    %edx
  80068b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80068e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800693:	eb 55                	jmp    8006ea <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 83 fc ff ff       	call   800320 <getuint>
			base = 10;
  80069d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006a2:	eb 46                	jmp    8006ea <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a7:	e8 74 fc ff ff       	call   800320 <getuint>
			base = 8;
  8006ac:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006b1:	eb 37                	jmp    8006ea <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 30                	push   $0x30
  8006b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 78                	push   $0x78
  8006c1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 50 04             	lea    0x4(%eax),%edx
  8006c9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006db:	eb 0d                	jmp    8006ea <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e0:	e8 3b fc ff ff       	call   800320 <getuint>
			base = 16;
  8006e5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ea:	83 ec 0c             	sub    $0xc,%esp
  8006ed:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f1:	57                   	push   %edi
  8006f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f5:	51                   	push   %ecx
  8006f6:	52                   	push   %edx
  8006f7:	50                   	push   %eax
  8006f8:	89 da                	mov    %ebx,%edx
  8006fa:	89 f0                	mov    %esi,%eax
  8006fc:	e8 70 fb ff ff       	call   800271 <printnum>
			break;
  800701:	83 c4 20             	add    $0x20,%esp
  800704:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800707:	e9 ae fc ff ff       	jmp    8003ba <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	51                   	push   %ecx
  800711:	ff d6                	call   *%esi
			break;
  800713:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800716:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800719:	e9 9c fc ff ff       	jmp    8003ba <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	6a 25                	push   $0x25
  800724:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	eb 03                	jmp    80072e <vprintfmt+0x39a>
  80072b:	83 ef 01             	sub    $0x1,%edi
  80072e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800732:	75 f7                	jne    80072b <vprintfmt+0x397>
  800734:	e9 81 fc ff ff       	jmp    8003ba <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800739:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073c:	5b                   	pop    %ebx
  80073d:	5e                   	pop    %esi
  80073e:	5f                   	pop    %edi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 18             	sub    $0x18,%esp
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800750:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800754:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800757:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075e:	85 c0                	test   %eax,%eax
  800760:	74 26                	je     800788 <vsnprintf+0x47>
  800762:	85 d2                	test   %edx,%edx
  800764:	7e 22                	jle    800788 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800766:	ff 75 14             	pushl  0x14(%ebp)
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076f:	50                   	push   %eax
  800770:	68 5a 03 80 00       	push   $0x80035a
  800775:	e8 1a fc ff ff       	call   800394 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800780:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	eb 05                	jmp    80078d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800788:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800795:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800798:	50                   	push   %eax
  800799:	ff 75 10             	pushl  0x10(%ebp)
  80079c:	ff 75 0c             	pushl  0xc(%ebp)
  80079f:	ff 75 08             	pushl  0x8(%ebp)
  8007a2:	e8 9a ff ff ff       	call   800741 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    

008007a9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b4:	eb 03                	jmp    8007b9 <strlen+0x10>
		n++;
  8007b6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bd:	75 f7                	jne    8007b6 <strlen+0xd>
		n++;
	return n;
}
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8007cf:	eb 03                	jmp    8007d4 <strnlen+0x13>
		n++;
  8007d1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d4:	39 c2                	cmp    %eax,%edx
  8007d6:	74 08                	je     8007e0 <strnlen+0x1f>
  8007d8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007dc:	75 f3                	jne    8007d1 <strnlen+0x10>
  8007de:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ec:	89 c2                	mov    %eax,%edx
  8007ee:	83 c2 01             	add    $0x1,%edx
  8007f1:	83 c1 01             	add    $0x1,%ecx
  8007f4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007fb:	84 db                	test   %bl,%bl
  8007fd:	75 ef                	jne    8007ee <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ff:	5b                   	pop    %ebx
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800809:	53                   	push   %ebx
  80080a:	e8 9a ff ff ff       	call   8007a9 <strlen>
  80080f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800812:	ff 75 0c             	pushl  0xc(%ebp)
  800815:	01 d8                	add    %ebx,%eax
  800817:	50                   	push   %eax
  800818:	e8 c5 ff ff ff       	call   8007e2 <strcpy>
	return dst;
}
  80081d:	89 d8                	mov    %ebx,%eax
  80081f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800822:	c9                   	leave  
  800823:	c3                   	ret    

00800824 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	89 f3                	mov    %esi,%ebx
  800831:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800834:	89 f2                	mov    %esi,%edx
  800836:	eb 0f                	jmp    800847 <strncpy+0x23>
		*dst++ = *src;
  800838:	83 c2 01             	add    $0x1,%edx
  80083b:	0f b6 01             	movzbl (%ecx),%eax
  80083e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800841:	80 39 01             	cmpb   $0x1,(%ecx)
  800844:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800847:	39 da                	cmp    %ebx,%edx
  800849:	75 ed                	jne    800838 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084b:	89 f0                	mov    %esi,%eax
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	8b 75 08             	mov    0x8(%ebp),%esi
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085c:	8b 55 10             	mov    0x10(%ebp),%edx
  80085f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800861:	85 d2                	test   %edx,%edx
  800863:	74 21                	je     800886 <strlcpy+0x35>
  800865:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800869:	89 f2                	mov    %esi,%edx
  80086b:	eb 09                	jmp    800876 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086d:	83 c2 01             	add    $0x1,%edx
  800870:	83 c1 01             	add    $0x1,%ecx
  800873:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800876:	39 c2                	cmp    %eax,%edx
  800878:	74 09                	je     800883 <strlcpy+0x32>
  80087a:	0f b6 19             	movzbl (%ecx),%ebx
  80087d:	84 db                	test   %bl,%bl
  80087f:	75 ec                	jne    80086d <strlcpy+0x1c>
  800881:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800883:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800886:	29 f0                	sub    %esi,%eax
}
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800895:	eb 06                	jmp    80089d <strcmp+0x11>
		p++, q++;
  800897:	83 c1 01             	add    $0x1,%ecx
  80089a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089d:	0f b6 01             	movzbl (%ecx),%eax
  8008a0:	84 c0                	test   %al,%al
  8008a2:	74 04                	je     8008a8 <strcmp+0x1c>
  8008a4:	3a 02                	cmp    (%edx),%al
  8008a6:	74 ef                	je     800897 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a8:	0f b6 c0             	movzbl %al,%eax
  8008ab:	0f b6 12             	movzbl (%edx),%edx
  8008ae:	29 d0                	sub    %edx,%eax
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	89 c3                	mov    %eax,%ebx
  8008be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c1:	eb 06                	jmp    8008c9 <strncmp+0x17>
		n--, p++, q++;
  8008c3:	83 c0 01             	add    $0x1,%eax
  8008c6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c9:	39 d8                	cmp    %ebx,%eax
  8008cb:	74 15                	je     8008e2 <strncmp+0x30>
  8008cd:	0f b6 08             	movzbl (%eax),%ecx
  8008d0:	84 c9                	test   %cl,%cl
  8008d2:	74 04                	je     8008d8 <strncmp+0x26>
  8008d4:	3a 0a                	cmp    (%edx),%cl
  8008d6:	74 eb                	je     8008c3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d8:	0f b6 00             	movzbl (%eax),%eax
  8008db:	0f b6 12             	movzbl (%edx),%edx
  8008de:	29 d0                	sub    %edx,%eax
  8008e0:	eb 05                	jmp    8008e7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f4:	eb 07                	jmp    8008fd <strchr+0x13>
		if (*s == c)
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 0f                	je     800909 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 10             	movzbl (%eax),%edx
  800900:	84 d2                	test   %dl,%dl
  800902:	75 f2                	jne    8008f6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800915:	eb 03                	jmp    80091a <strfind+0xf>
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091d:	38 ca                	cmp    %cl,%dl
  80091f:	74 04                	je     800925 <strfind+0x1a>
  800921:	84 d2                	test   %dl,%dl
  800923:	75 f2                	jne    800917 <strfind+0xc>
			break;
	return (char *) s;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	57                   	push   %edi
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800933:	85 c9                	test   %ecx,%ecx
  800935:	74 36                	je     80096d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800937:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093d:	75 28                	jne    800967 <memset+0x40>
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 23                	jne    800967 <memset+0x40>
		c &= 0xFF;
  800944:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800948:	89 d3                	mov    %edx,%ebx
  80094a:	c1 e3 08             	shl    $0x8,%ebx
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	c1 e6 18             	shl    $0x18,%esi
  800952:	89 d0                	mov    %edx,%eax
  800954:	c1 e0 10             	shl    $0x10,%eax
  800957:	09 f0                	or     %esi,%eax
  800959:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80095b:	89 d8                	mov    %ebx,%eax
  80095d:	09 d0                	or     %edx,%eax
  80095f:	c1 e9 02             	shr    $0x2,%ecx
  800962:	fc                   	cld    
  800963:	f3 ab                	rep stos %eax,%es:(%edi)
  800965:	eb 06                	jmp    80096d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	fc                   	cld    
  80096b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096d:	89 f8                	mov    %edi,%eax
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800982:	39 c6                	cmp    %eax,%esi
  800984:	73 35                	jae    8009bb <memmove+0x47>
  800986:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800989:	39 d0                	cmp    %edx,%eax
  80098b:	73 2e                	jae    8009bb <memmove+0x47>
		s += n;
		d += n;
  80098d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	89 d6                	mov    %edx,%esi
  800992:	09 fe                	or     %edi,%esi
  800994:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099a:	75 13                	jne    8009af <memmove+0x3b>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 0e                	jne    8009af <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a1:	83 ef 04             	sub    $0x4,%edi
  8009a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
  8009aa:	fd                   	std    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 09                	jmp    8009b8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009af:	83 ef 01             	sub    $0x1,%edi
  8009b2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b5:	fd                   	std    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b8:	fc                   	cld    
  8009b9:	eb 1d                	jmp    8009d8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	89 f2                	mov    %esi,%edx
  8009bd:	09 c2                	or     %eax,%edx
  8009bf:	f6 c2 03             	test   $0x3,%dl
  8009c2:	75 0f                	jne    8009d3 <memmove+0x5f>
  8009c4:	f6 c1 03             	test   $0x3,%cl
  8009c7:	75 0a                	jne    8009d3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c9:	c1 e9 02             	shr    $0x2,%ecx
  8009cc:	89 c7                	mov    %eax,%edi
  8009ce:	fc                   	cld    
  8009cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d1:	eb 05                	jmp    8009d8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d3:	89 c7                	mov    %eax,%edi
  8009d5:	fc                   	cld    
  8009d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d8:	5e                   	pop    %esi
  8009d9:	5f                   	pop    %edi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009df:	ff 75 10             	pushl  0x10(%ebp)
  8009e2:	ff 75 0c             	pushl  0xc(%ebp)
  8009e5:	ff 75 08             	pushl  0x8(%ebp)
  8009e8:	e8 87 ff ff ff       	call   800974 <memmove>
}
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fa:	89 c6                	mov    %eax,%esi
  8009fc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ff:	eb 1a                	jmp    800a1b <memcmp+0x2c>
		if (*s1 != *s2)
  800a01:	0f b6 08             	movzbl (%eax),%ecx
  800a04:	0f b6 1a             	movzbl (%edx),%ebx
  800a07:	38 d9                	cmp    %bl,%cl
  800a09:	74 0a                	je     800a15 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a0b:	0f b6 c1             	movzbl %cl,%eax
  800a0e:	0f b6 db             	movzbl %bl,%ebx
  800a11:	29 d8                	sub    %ebx,%eax
  800a13:	eb 0f                	jmp    800a24 <memcmp+0x35>
		s1++, s2++;
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1b:	39 f0                	cmp    %esi,%eax
  800a1d:	75 e2                	jne    800a01 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	53                   	push   %ebx
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a2f:	89 c1                	mov    %eax,%ecx
  800a31:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a34:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a38:	eb 0a                	jmp    800a44 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3a:	0f b6 10             	movzbl (%eax),%edx
  800a3d:	39 da                	cmp    %ebx,%edx
  800a3f:	74 07                	je     800a48 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a41:	83 c0 01             	add    $0x1,%eax
  800a44:	39 c8                	cmp    %ecx,%eax
  800a46:	72 f2                	jb     800a3a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	57                   	push   %edi
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a57:	eb 03                	jmp    800a5c <strtol+0x11>
		s++;
  800a59:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5c:	0f b6 01             	movzbl (%ecx),%eax
  800a5f:	3c 20                	cmp    $0x20,%al
  800a61:	74 f6                	je     800a59 <strtol+0xe>
  800a63:	3c 09                	cmp    $0x9,%al
  800a65:	74 f2                	je     800a59 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a67:	3c 2b                	cmp    $0x2b,%al
  800a69:	75 0a                	jne    800a75 <strtol+0x2a>
		s++;
  800a6b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a73:	eb 11                	jmp    800a86 <strtol+0x3b>
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a7a:	3c 2d                	cmp    $0x2d,%al
  800a7c:	75 08                	jne    800a86 <strtol+0x3b>
		s++, neg = 1;
  800a7e:	83 c1 01             	add    $0x1,%ecx
  800a81:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a86:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8c:	75 15                	jne    800aa3 <strtol+0x58>
  800a8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a91:	75 10                	jne    800aa3 <strtol+0x58>
  800a93:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a97:	75 7c                	jne    800b15 <strtol+0xca>
		s += 2, base = 16;
  800a99:	83 c1 02             	add    $0x2,%ecx
  800a9c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa1:	eb 16                	jmp    800ab9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa3:	85 db                	test   %ebx,%ebx
  800aa5:	75 12                	jne    800ab9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aac:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaf:	75 08                	jne    800ab9 <strtol+0x6e>
		s++, base = 8;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  800abe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac1:	0f b6 11             	movzbl (%ecx),%edx
  800ac4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	80 fb 09             	cmp    $0x9,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0x8b>
			dig = *s - '0';
  800ace:	0f be d2             	movsbl %dl,%edx
  800ad1:	83 ea 30             	sub    $0x30,%edx
  800ad4:	eb 22                	jmp    800af8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 19             	cmp    $0x19,%bl
  800ade:	77 08                	ja     800ae8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae0:	0f be d2             	movsbl %dl,%edx
  800ae3:	83 ea 57             	sub    $0x57,%edx
  800ae6:	eb 10                	jmp    800af8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aeb:	89 f3                	mov    %esi,%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 16                	ja     800b08 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af2:	0f be d2             	movsbl %dl,%edx
  800af5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800afb:	7d 0b                	jge    800b08 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800afd:	83 c1 01             	add    $0x1,%ecx
  800b00:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b04:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b06:	eb b9                	jmp    800ac1 <strtol+0x76>

	if (endptr)
  800b08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0c:	74 0d                	je     800b1b <strtol+0xd0>
		*endptr = (char *) s;
  800b0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b11:	89 0e                	mov    %ecx,(%esi)
  800b13:	eb 06                	jmp    800b1b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b15:	85 db                	test   %ebx,%ebx
  800b17:	74 98                	je     800ab1 <strtol+0x66>
  800b19:	eb 9e                	jmp    800ab9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b1b:	89 c2                	mov    %eax,%edx
  800b1d:	f7 da                	neg    %edx
  800b1f:	85 ff                	test   %edi,%edi
  800b21:	0f 45 c2             	cmovne %edx,%eax
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	89 c3                	mov    %eax,%ebx
  800b3c:	89 c7                	mov    %eax,%edi
  800b3e:	89 c6                	mov    %eax,%esi
  800b40:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 01 00 00 00       	mov    $0x1,%eax
  800b57:	89 d1                	mov    %edx,%ecx
  800b59:	89 d3                	mov    %edx,%ebx
  800b5b:	89 d7                	mov    %edx,%edi
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b74:	b8 03 00 00 00       	mov    $0x3,%eax
  800b79:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7c:	89 cb                	mov    %ecx,%ebx
  800b7e:	89 cf                	mov    %ecx,%edi
  800b80:	89 ce                	mov    %ecx,%esi
  800b82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7e 17                	jle    800b9f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 03                	push   $0x3
  800b8e:	68 7f 22 80 00       	push   $0x80227f
  800b93:	6a 23                	push   $0x23
  800b95:	68 9c 22 80 00       	push   $0x80229c
  800b9a:	e8 e5 f5 ff ff       	call   800184 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb7:	89 d1                	mov    %edx,%ecx
  800bb9:	89 d3                	mov    %edx,%ebx
  800bbb:	89 d7                	mov    %edx,%edi
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_yield>:

void
sys_yield(void)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd6:	89 d1                	mov    %edx,%ecx
  800bd8:	89 d3                	mov    %edx,%ebx
  800bda:	89 d7                	mov    %edx,%edi
  800bdc:	89 d6                	mov    %edx,%esi
  800bde:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	be 00 00 00 00       	mov    $0x0,%esi
  800bf3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c01:	89 f7                	mov    %esi,%edi
  800c03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	7e 17                	jle    800c20 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	50                   	push   %eax
  800c0d:	6a 04                	push   $0x4
  800c0f:	68 7f 22 80 00       	push   $0x80227f
  800c14:	6a 23                	push   $0x23
  800c16:	68 9c 22 80 00       	push   $0x80229c
  800c1b:	e8 64 f5 ff ff       	call   800184 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	b8 05 00 00 00       	mov    $0x5,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c42:	8b 75 18             	mov    0x18(%ebp),%esi
  800c45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7e 17                	jle    800c62 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	50                   	push   %eax
  800c4f:	6a 05                	push   $0x5
  800c51:	68 7f 22 80 00       	push   $0x80227f
  800c56:	6a 23                	push   $0x23
  800c58:	68 9c 22 80 00       	push   $0x80229c
  800c5d:	e8 22 f5 ff ff       	call   800184 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c78:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	89 df                	mov    %ebx,%edi
  800c85:	89 de                	mov    %ebx,%esi
  800c87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 17                	jle    800ca4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	50                   	push   %eax
  800c91:	6a 06                	push   $0x6
  800c93:	68 7f 22 80 00       	push   $0x80227f
  800c98:	6a 23                	push   $0x23
  800c9a:	68 9c 22 80 00       	push   $0x80229c
  800c9f:	e8 e0 f4 ff ff       	call   800184 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	89 df                	mov    %ebx,%edi
  800cc7:	89 de                	mov    %ebx,%esi
  800cc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 17                	jle    800ce6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 08                	push   $0x8
  800cd5:	68 7f 22 80 00       	push   $0x80227f
  800cda:	6a 23                	push   $0x23
  800cdc:	68 9c 22 80 00       	push   $0x80229c
  800ce1:	e8 9e f4 ff ff       	call   800184 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	b8 09 00 00 00       	mov    $0x9,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 17                	jle    800d28 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 09                	push   $0x9
  800d17:	68 7f 22 80 00       	push   $0x80227f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 9c 22 80 00       	push   $0x80229c
  800d23:	e8 5c f4 ff ff       	call   800184 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 17                	jle    800d6a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 0a                	push   $0xa
  800d59:	68 7f 22 80 00       	push   $0x80227f
  800d5e:	6a 23                	push   $0x23
  800d60:	68 9c 22 80 00       	push   $0x80229c
  800d65:	e8 1a f4 ff ff       	call   800184 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d78:	be 00 00 00 00       	mov    $0x0,%esi
  800d7d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d85:	8b 55 08             	mov    0x8(%ebp),%edx
  800d88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 cb                	mov    %ecx,%ebx
  800dad:	89 cf                	mov    %ecx,%edi
  800daf:	89 ce                	mov    %ecx,%esi
  800db1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7e 17                	jle    800dce <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	50                   	push   %eax
  800dbb:	6a 0d                	push   $0xd
  800dbd:	68 7f 22 80 00       	push   $0x80227f
  800dc2:	6a 23                	push   $0x23
  800dc4:	68 9c 22 80 00       	push   $0x80229c
  800dc9:	e8 b6 f3 ff ff       	call   800184 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	05 00 00 00 30       	add    $0x30000000,%eax
  800de1:	c1 e8 0c             	shr    $0xc,%eax
}
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	05 00 00 00 30       	add    $0x30000000,%eax
  800df1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e03:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e08:	89 c2                	mov    %eax,%edx
  800e0a:	c1 ea 16             	shr    $0x16,%edx
  800e0d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e14:	f6 c2 01             	test   $0x1,%dl
  800e17:	74 11                	je     800e2a <fd_alloc+0x2d>
  800e19:	89 c2                	mov    %eax,%edx
  800e1b:	c1 ea 0c             	shr    $0xc,%edx
  800e1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e25:	f6 c2 01             	test   $0x1,%dl
  800e28:	75 09                	jne    800e33 <fd_alloc+0x36>
			*fd_store = fd;
  800e2a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e31:	eb 17                	jmp    800e4a <fd_alloc+0x4d>
  800e33:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e38:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3d:	75 c9                	jne    800e08 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e3f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e45:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e52:	83 f8 1f             	cmp    $0x1f,%eax
  800e55:	77 36                	ja     800e8d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e57:	c1 e0 0c             	shl    $0xc,%eax
  800e5a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e5f:	89 c2                	mov    %eax,%edx
  800e61:	c1 ea 16             	shr    $0x16,%edx
  800e64:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6b:	f6 c2 01             	test   $0x1,%dl
  800e6e:	74 24                	je     800e94 <fd_lookup+0x48>
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	c1 ea 0c             	shr    $0xc,%edx
  800e75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7c:	f6 c2 01             	test   $0x1,%dl
  800e7f:	74 1a                	je     800e9b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e84:	89 02                	mov    %eax,(%edx)
	return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	eb 13                	jmp    800ea0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e92:	eb 0c                	jmp    800ea0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e99:	eb 05                	jmp    800ea0 <fd_lookup+0x54>
  800e9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 08             	sub    $0x8,%esp
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eab:	ba 2c 23 80 00       	mov    $0x80232c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb0:	eb 13                	jmp    800ec5 <dev_lookup+0x23>
  800eb2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eb5:	39 08                	cmp    %ecx,(%eax)
  800eb7:	75 0c                	jne    800ec5 <dev_lookup+0x23>
			*dev = devtab[i];
  800eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	eb 2e                	jmp    800ef3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec5:	8b 02                	mov    (%edx),%eax
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	75 e7                	jne    800eb2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ecb:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800ed0:	8b 40 48             	mov    0x48(%eax),%eax
  800ed3:	83 ec 04             	sub    $0x4,%esp
  800ed6:	51                   	push   %ecx
  800ed7:	50                   	push   %eax
  800ed8:	68 ac 22 80 00       	push   $0x8022ac
  800edd:	e8 7b f3 ff ff       	call   80025d <cprintf>
	*dev = 0;
  800ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 10             	sub    $0x10,%esp
  800efd:	8b 75 08             	mov    0x8(%ebp),%esi
  800f00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f06:	50                   	push   %eax
  800f07:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f0d:	c1 e8 0c             	shr    $0xc,%eax
  800f10:	50                   	push   %eax
  800f11:	e8 36 ff ff ff       	call   800e4c <fd_lookup>
  800f16:	83 c4 08             	add    $0x8,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 05                	js     800f22 <fd_close+0x2d>
	    || fd != fd2)
  800f1d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f20:	74 0c                	je     800f2e <fd_close+0x39>
		return (must_exist ? r : 0);
  800f22:	84 db                	test   %bl,%bl
  800f24:	ba 00 00 00 00       	mov    $0x0,%edx
  800f29:	0f 44 c2             	cmove  %edx,%eax
  800f2c:	eb 41                	jmp    800f6f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f2e:	83 ec 08             	sub    $0x8,%esp
  800f31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f34:	50                   	push   %eax
  800f35:	ff 36                	pushl  (%esi)
  800f37:	e8 66 ff ff ff       	call   800ea2 <dev_lookup>
  800f3c:	89 c3                	mov    %eax,%ebx
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	78 1a                	js     800f5f <fd_close+0x6a>
		if (dev->dev_close)
  800f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f48:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f4b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	74 0b                	je     800f5f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	56                   	push   %esi
  800f58:	ff d0                	call   *%eax
  800f5a:	89 c3                	mov    %eax,%ebx
  800f5c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f5f:	83 ec 08             	sub    $0x8,%esp
  800f62:	56                   	push   %esi
  800f63:	6a 00                	push   $0x0
  800f65:	e8 00 fd ff ff       	call   800c6a <sys_page_unmap>
	return r;
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	89 d8                	mov    %ebx,%eax
}
  800f6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7f:	50                   	push   %eax
  800f80:	ff 75 08             	pushl  0x8(%ebp)
  800f83:	e8 c4 fe ff ff       	call   800e4c <fd_lookup>
  800f88:	83 c4 08             	add    $0x8,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	78 10                	js     800f9f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	6a 01                	push   $0x1
  800f94:	ff 75 f4             	pushl  -0xc(%ebp)
  800f97:	e8 59 ff ff ff       	call   800ef5 <fd_close>
  800f9c:	83 c4 10             	add    $0x10,%esp
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <close_all>:

void
close_all(void)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	53                   	push   %ebx
  800fb1:	e8 c0 ff ff ff       	call   800f76 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb6:	83 c3 01             	add    $0x1,%ebx
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	83 fb 20             	cmp    $0x20,%ebx
  800fbf:	75 ec                	jne    800fad <close_all+0xc>
		close(i);
}
  800fc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	57                   	push   %edi
  800fca:	56                   	push   %esi
  800fcb:	53                   	push   %ebx
  800fcc:	83 ec 2c             	sub    $0x2c,%esp
  800fcf:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd5:	50                   	push   %eax
  800fd6:	ff 75 08             	pushl  0x8(%ebp)
  800fd9:	e8 6e fe ff ff       	call   800e4c <fd_lookup>
  800fde:	83 c4 08             	add    $0x8,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	0f 88 c1 00 00 00    	js     8010aa <dup+0xe4>
		return r;
	close(newfdnum);
  800fe9:	83 ec 0c             	sub    $0xc,%esp
  800fec:	56                   	push   %esi
  800fed:	e8 84 ff ff ff       	call   800f76 <close>

	newfd = INDEX2FD(newfdnum);
  800ff2:	89 f3                	mov    %esi,%ebx
  800ff4:	c1 e3 0c             	shl    $0xc,%ebx
  800ff7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ffd:	83 c4 04             	add    $0x4,%esp
  801000:	ff 75 e4             	pushl  -0x1c(%ebp)
  801003:	e8 de fd ff ff       	call   800de6 <fd2data>
  801008:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80100a:	89 1c 24             	mov    %ebx,(%esp)
  80100d:	e8 d4 fd ff ff       	call   800de6 <fd2data>
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801018:	89 f8                	mov    %edi,%eax
  80101a:	c1 e8 16             	shr    $0x16,%eax
  80101d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801024:	a8 01                	test   $0x1,%al
  801026:	74 37                	je     80105f <dup+0x99>
  801028:	89 f8                	mov    %edi,%eax
  80102a:	c1 e8 0c             	shr    $0xc,%eax
  80102d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801034:	f6 c2 01             	test   $0x1,%dl
  801037:	74 26                	je     80105f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801039:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	25 07 0e 00 00       	and    $0xe07,%eax
  801048:	50                   	push   %eax
  801049:	ff 75 d4             	pushl  -0x2c(%ebp)
  80104c:	6a 00                	push   $0x0
  80104e:	57                   	push   %edi
  80104f:	6a 00                	push   $0x0
  801051:	e8 d2 fb ff ff       	call   800c28 <sys_page_map>
  801056:	89 c7                	mov    %eax,%edi
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 2e                	js     80108d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801062:	89 d0                	mov    %edx,%eax
  801064:	c1 e8 0c             	shr    $0xc,%eax
  801067:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	25 07 0e 00 00       	and    $0xe07,%eax
  801076:	50                   	push   %eax
  801077:	53                   	push   %ebx
  801078:	6a 00                	push   $0x0
  80107a:	52                   	push   %edx
  80107b:	6a 00                	push   $0x0
  80107d:	e8 a6 fb ff ff       	call   800c28 <sys_page_map>
  801082:	89 c7                	mov    %eax,%edi
  801084:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801087:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801089:	85 ff                	test   %edi,%edi
  80108b:	79 1d                	jns    8010aa <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	53                   	push   %ebx
  801091:	6a 00                	push   $0x0
  801093:	e8 d2 fb ff ff       	call   800c6a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801098:	83 c4 08             	add    $0x8,%esp
  80109b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 c5 fb ff ff       	call   800c6a <sys_page_unmap>
	return r;
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	89 f8                	mov    %edi,%eax
}
  8010aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 14             	sub    $0x14,%esp
  8010b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010bf:	50                   	push   %eax
  8010c0:	53                   	push   %ebx
  8010c1:	e8 86 fd ff ff       	call   800e4c <fd_lookup>
  8010c6:	83 c4 08             	add    $0x8,%esp
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	78 6d                	js     80113c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010cf:	83 ec 08             	sub    $0x8,%esp
  8010d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d5:	50                   	push   %eax
  8010d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d9:	ff 30                	pushl  (%eax)
  8010db:	e8 c2 fd ff ff       	call   800ea2 <dev_lookup>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 4c                	js     801133 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ea:	8b 42 08             	mov    0x8(%edx),%eax
  8010ed:	83 e0 03             	and    $0x3,%eax
  8010f0:	83 f8 01             	cmp    $0x1,%eax
  8010f3:	75 21                	jne    801116 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f5:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8010fa:	8b 40 48             	mov    0x48(%eax),%eax
  8010fd:	83 ec 04             	sub    $0x4,%esp
  801100:	53                   	push   %ebx
  801101:	50                   	push   %eax
  801102:	68 f0 22 80 00       	push   $0x8022f0
  801107:	e8 51 f1 ff ff       	call   80025d <cprintf>
		return -E_INVAL;
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801114:	eb 26                	jmp    80113c <read+0x8a>
	}
	if (!dev->dev_read)
  801116:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801119:	8b 40 08             	mov    0x8(%eax),%eax
  80111c:	85 c0                	test   %eax,%eax
  80111e:	74 17                	je     801137 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801120:	83 ec 04             	sub    $0x4,%esp
  801123:	ff 75 10             	pushl  0x10(%ebp)
  801126:	ff 75 0c             	pushl  0xc(%ebp)
  801129:	52                   	push   %edx
  80112a:	ff d0                	call   *%eax
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	eb 09                	jmp    80113c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801133:	89 c2                	mov    %eax,%edx
  801135:	eb 05                	jmp    80113c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801137:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80113c:	89 d0                	mov    %edx,%eax
  80113e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 0c             	sub    $0xc,%esp
  80114c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80114f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801152:	bb 00 00 00 00       	mov    $0x0,%ebx
  801157:	eb 21                	jmp    80117a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	89 f0                	mov    %esi,%eax
  80115e:	29 d8                	sub    %ebx,%eax
  801160:	50                   	push   %eax
  801161:	89 d8                	mov    %ebx,%eax
  801163:	03 45 0c             	add    0xc(%ebp),%eax
  801166:	50                   	push   %eax
  801167:	57                   	push   %edi
  801168:	e8 45 ff ff ff       	call   8010b2 <read>
		if (m < 0)
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	85 c0                	test   %eax,%eax
  801172:	78 10                	js     801184 <readn+0x41>
			return m;
		if (m == 0)
  801174:	85 c0                	test   %eax,%eax
  801176:	74 0a                	je     801182 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801178:	01 c3                	add    %eax,%ebx
  80117a:	39 f3                	cmp    %esi,%ebx
  80117c:	72 db                	jb     801159 <readn+0x16>
  80117e:	89 d8                	mov    %ebx,%eax
  801180:	eb 02                	jmp    801184 <readn+0x41>
  801182:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	53                   	push   %ebx
  801190:	83 ec 14             	sub    $0x14,%esp
  801193:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801196:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	53                   	push   %ebx
  80119b:	e8 ac fc ff ff       	call   800e4c <fd_lookup>
  8011a0:	83 c4 08             	add    $0x8,%esp
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 68                	js     801211 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011af:	50                   	push   %eax
  8011b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b3:	ff 30                	pushl  (%eax)
  8011b5:	e8 e8 fc ff ff       	call   800ea2 <dev_lookup>
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 47                	js     801208 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011c8:	75 21                	jne    8011eb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ca:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011cf:	8b 40 48             	mov    0x48(%eax),%eax
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	53                   	push   %ebx
  8011d6:	50                   	push   %eax
  8011d7:	68 0c 23 80 00       	push   $0x80230c
  8011dc:	e8 7c f0 ff ff       	call   80025d <cprintf>
		return -E_INVAL;
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e9:	eb 26                	jmp    801211 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ee:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f1:	85 d2                	test   %edx,%edx
  8011f3:	74 17                	je     80120c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	ff 75 10             	pushl  0x10(%ebp)
  8011fb:	ff 75 0c             	pushl  0xc(%ebp)
  8011fe:	50                   	push   %eax
  8011ff:	ff d2                	call   *%edx
  801201:	89 c2                	mov    %eax,%edx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	eb 09                	jmp    801211 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801208:	89 c2                	mov    %eax,%edx
  80120a:	eb 05                	jmp    801211 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80120c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801211:	89 d0                	mov    %edx,%eax
  801213:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <seek>:

int
seek(int fdnum, off_t offset)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	ff 75 08             	pushl  0x8(%ebp)
  801225:	e8 22 fc ff ff       	call   800e4c <fd_lookup>
  80122a:	83 c4 08             	add    $0x8,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 0e                	js     80123f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801231:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801234:	8b 55 0c             	mov    0xc(%ebp),%edx
  801237:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	53                   	push   %ebx
  801245:	83 ec 14             	sub    $0x14,%esp
  801248:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	53                   	push   %ebx
  801250:	e8 f7 fb ff ff       	call   800e4c <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	89 c2                	mov    %eax,%edx
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 65                	js     8012c3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801268:	ff 30                	pushl  (%eax)
  80126a:	e8 33 fc ff ff       	call   800ea2 <dev_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 44                	js     8012ba <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801279:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127d:	75 21                	jne    8012a0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80127f:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801284:	8b 40 48             	mov    0x48(%eax),%eax
  801287:	83 ec 04             	sub    $0x4,%esp
  80128a:	53                   	push   %ebx
  80128b:	50                   	push   %eax
  80128c:	68 cc 22 80 00       	push   $0x8022cc
  801291:	e8 c7 ef ff ff       	call   80025d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129e:	eb 23                	jmp    8012c3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a3:	8b 52 18             	mov    0x18(%edx),%edx
  8012a6:	85 d2                	test   %edx,%edx
  8012a8:	74 14                	je     8012be <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	ff 75 0c             	pushl  0xc(%ebp)
  8012b0:	50                   	push   %eax
  8012b1:	ff d2                	call   *%edx
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	eb 09                	jmp    8012c3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	eb 05                	jmp    8012c3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012c3:	89 d0                	mov    %edx,%eax
  8012c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 14             	sub    $0x14,%esp
  8012d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d7:	50                   	push   %eax
  8012d8:	ff 75 08             	pushl  0x8(%ebp)
  8012db:	e8 6c fb ff ff       	call   800e4c <fd_lookup>
  8012e0:	83 c4 08             	add    $0x8,%esp
  8012e3:	89 c2                	mov    %eax,%edx
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 58                	js     801341 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f3:	ff 30                	pushl  (%eax)
  8012f5:	e8 a8 fb ff ff       	call   800ea2 <dev_lookup>
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 37                	js     801338 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801301:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801304:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801308:	74 32                	je     80133c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80130a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80130d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801314:	00 00 00 
	stat->st_isdir = 0;
  801317:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80131e:	00 00 00 
	stat->st_dev = dev;
  801321:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	53                   	push   %ebx
  80132b:	ff 75 f0             	pushl  -0x10(%ebp)
  80132e:	ff 50 14             	call   *0x14(%eax)
  801331:	89 c2                	mov    %eax,%edx
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	eb 09                	jmp    801341 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801338:	89 c2                	mov    %eax,%edx
  80133a:	eb 05                	jmp    801341 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80133c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801341:	89 d0                	mov    %edx,%eax
  801343:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	56                   	push   %esi
  80134c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	6a 00                	push   $0x0
  801352:	ff 75 08             	pushl  0x8(%ebp)
  801355:	e8 e3 01 00 00       	call   80153d <open>
  80135a:	89 c3                	mov    %eax,%ebx
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 1b                	js     80137e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	ff 75 0c             	pushl  0xc(%ebp)
  801369:	50                   	push   %eax
  80136a:	e8 5b ff ff ff       	call   8012ca <fstat>
  80136f:	89 c6                	mov    %eax,%esi
	close(fd);
  801371:	89 1c 24             	mov    %ebx,(%esp)
  801374:	e8 fd fb ff ff       	call   800f76 <close>
	return r;
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	89 f0                	mov    %esi,%eax
}
  80137e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	56                   	push   %esi
  801389:	53                   	push   %ebx
  80138a:	89 c6                	mov    %eax,%esi
  80138c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80138e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801395:	75 12                	jne    8013a9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	6a 01                	push   $0x1
  80139c:	e8 f3 07 00 00       	call   801b94 <ipc_find_env>
  8013a1:	a3 00 40 80 00       	mov    %eax,0x804000
  8013a6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013a9:	6a 07                	push   $0x7
  8013ab:	68 00 50 c0 00       	push   $0xc05000
  8013b0:	56                   	push   %esi
  8013b1:	ff 35 00 40 80 00    	pushl  0x804000
  8013b7:	e8 76 07 00 00       	call   801b32 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013bc:	83 c4 0c             	add    $0xc,%esp
  8013bf:	6a 00                	push   $0x0
  8013c1:	53                   	push   %ebx
  8013c2:	6a 00                	push   $0x0
  8013c4:	e8 f7 06 00 00       	call   801ac0 <ipc_recv>
}
  8013c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cc:	5b                   	pop    %ebx
  8013cd:	5e                   	pop    %esi
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dc:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8013e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e4:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ee:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f3:	e8 8d ff ff ff       	call   801385 <fsipc>
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801400:	8b 45 08             	mov    0x8(%ebp),%eax
  801403:	8b 40 0c             	mov    0xc(%eax),%eax
  801406:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  80140b:	ba 00 00 00 00       	mov    $0x0,%edx
  801410:	b8 06 00 00 00       	mov    $0x6,%eax
  801415:	e8 6b ff ff ff       	call   801385 <fsipc>
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	53                   	push   %ebx
  801420:	83 ec 04             	sub    $0x4,%esp
  801423:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
  801429:	8b 40 0c             	mov    0xc(%eax),%eax
  80142c:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801431:	ba 00 00 00 00       	mov    $0x0,%edx
  801436:	b8 05 00 00 00       	mov    $0x5,%eax
  80143b:	e8 45 ff ff ff       	call   801385 <fsipc>
  801440:	85 c0                	test   %eax,%eax
  801442:	78 2c                	js     801470 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	68 00 50 c0 00       	push   $0xc05000
  80144c:	53                   	push   %ebx
  80144d:	e8 90 f3 ff ff       	call   8007e2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801452:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801457:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80145d:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801462:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801470:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 0c             	sub    $0xc,%esp
  80147b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80147e:	8b 55 08             	mov    0x8(%ebp),%edx
  801481:	8b 52 0c             	mov    0xc(%edx),%edx
  801484:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80148a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80148f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801494:	0f 47 c2             	cmova  %edx,%eax
  801497:	a3 04 50 c0 00       	mov    %eax,0xc05004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80149c:	50                   	push   %eax
  80149d:	ff 75 0c             	pushl  0xc(%ebp)
  8014a0:	68 08 50 c0 00       	push   $0xc05008
  8014a5:	e8 ca f4 ff ff       	call   800974 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8014aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014af:	b8 04 00 00 00       	mov    $0x4,%eax
  8014b4:	e8 cc fe ff ff       	call   801385 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c9:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014ce:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8014de:	e8 a2 fe ff ff       	call   801385 <fsipc>
  8014e3:	89 c3                	mov    %eax,%ebx
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 4b                	js     801534 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014e9:	39 c6                	cmp    %eax,%esi
  8014eb:	73 16                	jae    801503 <devfile_read+0x48>
  8014ed:	68 3c 23 80 00       	push   $0x80233c
  8014f2:	68 43 23 80 00       	push   $0x802343
  8014f7:	6a 7c                	push   $0x7c
  8014f9:	68 58 23 80 00       	push   $0x802358
  8014fe:	e8 81 ec ff ff       	call   800184 <_panic>
	assert(r <= PGSIZE);
  801503:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801508:	7e 16                	jle    801520 <devfile_read+0x65>
  80150a:	68 63 23 80 00       	push   $0x802363
  80150f:	68 43 23 80 00       	push   $0x802343
  801514:	6a 7d                	push   $0x7d
  801516:	68 58 23 80 00       	push   $0x802358
  80151b:	e8 64 ec ff ff       	call   800184 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801520:	83 ec 04             	sub    $0x4,%esp
  801523:	50                   	push   %eax
  801524:	68 00 50 c0 00       	push   $0xc05000
  801529:	ff 75 0c             	pushl  0xc(%ebp)
  80152c:	e8 43 f4 ff ff       	call   800974 <memmove>
	return r;
  801531:	83 c4 10             	add    $0x10,%esp
}
  801534:	89 d8                	mov    %ebx,%eax
  801536:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 20             	sub    $0x20,%esp
  801544:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801547:	53                   	push   %ebx
  801548:	e8 5c f2 ff ff       	call   8007a9 <strlen>
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801555:	7f 67                	jg     8015be <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	e8 9a f8 ff ff       	call   800dfd <fd_alloc>
  801563:	83 c4 10             	add    $0x10,%esp
		return r;
  801566:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 57                	js     8015c3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	53                   	push   %ebx
  801570:	68 00 50 c0 00       	push   $0xc05000
  801575:	e8 68 f2 ff ff       	call   8007e2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80157a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157d:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	b8 01 00 00 00       	mov    $0x1,%eax
  80158a:	e8 f6 fd ff ff       	call   801385 <fsipc>
  80158f:	89 c3                	mov    %eax,%ebx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	79 14                	jns    8015ac <open+0x6f>
		fd_close(fd, 0);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	6a 00                	push   $0x0
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	e8 50 f9 ff ff       	call   800ef5 <fd_close>
		return r;
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	89 da                	mov    %ebx,%edx
  8015aa:	eb 17                	jmp    8015c3 <open+0x86>
	}

	return fd2num(fd);
  8015ac:	83 ec 0c             	sub    $0xc,%esp
  8015af:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b2:	e8 1f f8 ff ff       	call   800dd6 <fd2num>
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb 05                	jmp    8015c3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015be:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c3:	89 d0                	mov    %edx,%eax
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d5:	b8 08 00 00 00       	mov    $0x8,%eax
  8015da:	e8 a6 fd ff ff       	call   801385 <fsipc>
}
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
  8015e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	ff 75 08             	pushl  0x8(%ebp)
  8015ef:	e8 f2 f7 ff ff       	call   800de6 <fd2data>
  8015f4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	68 6f 23 80 00       	push   $0x80236f
  8015fe:	53                   	push   %ebx
  8015ff:	e8 de f1 ff ff       	call   8007e2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801604:	8b 46 04             	mov    0x4(%esi),%eax
  801607:	2b 06                	sub    (%esi),%eax
  801609:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80160f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801616:	00 00 00 
	stat->st_dev = &devpipe;
  801619:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801620:	30 80 00 
	return 0;
}
  801623:	b8 00 00 00 00       	mov    $0x0,%eax
  801628:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	53                   	push   %ebx
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801639:	53                   	push   %ebx
  80163a:	6a 00                	push   $0x0
  80163c:	e8 29 f6 ff ff       	call   800c6a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801641:	89 1c 24             	mov    %ebx,(%esp)
  801644:	e8 9d f7 ff ff       	call   800de6 <fd2data>
  801649:	83 c4 08             	add    $0x8,%esp
  80164c:	50                   	push   %eax
  80164d:	6a 00                	push   $0x0
  80164f:	e8 16 f6 ff ff       	call   800c6a <sys_page_unmap>
}
  801654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	57                   	push   %edi
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	83 ec 1c             	sub    $0x1c,%esp
  801662:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801665:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801667:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80166c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80166f:	83 ec 0c             	sub    $0xc,%esp
  801672:	ff 75 e0             	pushl  -0x20(%ebp)
  801675:	e8 53 05 00 00       	call   801bcd <pageref>
  80167a:	89 c3                	mov    %eax,%ebx
  80167c:	89 3c 24             	mov    %edi,(%esp)
  80167f:	e8 49 05 00 00       	call   801bcd <pageref>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	39 c3                	cmp    %eax,%ebx
  801689:	0f 94 c1             	sete   %cl
  80168c:	0f b6 c9             	movzbl %cl,%ecx
  80168f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801692:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801698:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80169b:	39 ce                	cmp    %ecx,%esi
  80169d:	74 1b                	je     8016ba <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80169f:	39 c3                	cmp    %eax,%ebx
  8016a1:	75 c4                	jne    801667 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016a3:	8b 42 58             	mov    0x58(%edx),%eax
  8016a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a9:	50                   	push   %eax
  8016aa:	56                   	push   %esi
  8016ab:	68 76 23 80 00       	push   $0x802376
  8016b0:	e8 a8 eb ff ff       	call   80025d <cprintf>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	eb ad                	jmp    801667 <_pipeisclosed+0xe>
	}
}
  8016ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5e                   	pop    %esi
  8016c2:	5f                   	pop    %edi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	57                   	push   %edi
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 28             	sub    $0x28,%esp
  8016ce:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016d1:	56                   	push   %esi
  8016d2:	e8 0f f7 ff ff       	call   800de6 <fd2data>
  8016d7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	bf 00 00 00 00       	mov    $0x0,%edi
  8016e1:	eb 4b                	jmp    80172e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016e3:	89 da                	mov    %ebx,%edx
  8016e5:	89 f0                	mov    %esi,%eax
  8016e7:	e8 6d ff ff ff       	call   801659 <_pipeisclosed>
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	75 48                	jne    801738 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016f0:	e8 d1 f4 ff ff       	call   800bc6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f5:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f8:	8b 0b                	mov    (%ebx),%ecx
  8016fa:	8d 51 20             	lea    0x20(%ecx),%edx
  8016fd:	39 d0                	cmp    %edx,%eax
  8016ff:	73 e2                	jae    8016e3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801701:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801704:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801708:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80170b:	89 c2                	mov    %eax,%edx
  80170d:	c1 fa 1f             	sar    $0x1f,%edx
  801710:	89 d1                	mov    %edx,%ecx
  801712:	c1 e9 1b             	shr    $0x1b,%ecx
  801715:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801718:	83 e2 1f             	and    $0x1f,%edx
  80171b:	29 ca                	sub    %ecx,%edx
  80171d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801721:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801725:	83 c0 01             	add    $0x1,%eax
  801728:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172b:	83 c7 01             	add    $0x1,%edi
  80172e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801731:	75 c2                	jne    8016f5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801733:	8b 45 10             	mov    0x10(%ebp),%eax
  801736:	eb 05                	jmp    80173d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801738:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80173d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	57                   	push   %edi
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	83 ec 18             	sub    $0x18,%esp
  80174e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801751:	57                   	push   %edi
  801752:	e8 8f f6 ff ff       	call   800de6 <fd2data>
  801757:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801761:	eb 3d                	jmp    8017a0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801763:	85 db                	test   %ebx,%ebx
  801765:	74 04                	je     80176b <devpipe_read+0x26>
				return i;
  801767:	89 d8                	mov    %ebx,%eax
  801769:	eb 44                	jmp    8017af <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80176b:	89 f2                	mov    %esi,%edx
  80176d:	89 f8                	mov    %edi,%eax
  80176f:	e8 e5 fe ff ff       	call   801659 <_pipeisclosed>
  801774:	85 c0                	test   %eax,%eax
  801776:	75 32                	jne    8017aa <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801778:	e8 49 f4 ff ff       	call   800bc6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80177d:	8b 06                	mov    (%esi),%eax
  80177f:	3b 46 04             	cmp    0x4(%esi),%eax
  801782:	74 df                	je     801763 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801784:	99                   	cltd   
  801785:	c1 ea 1b             	shr    $0x1b,%edx
  801788:	01 d0                	add    %edx,%eax
  80178a:	83 e0 1f             	and    $0x1f,%eax
  80178d:	29 d0                	sub    %edx,%eax
  80178f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801797:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80179a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179d:	83 c3 01             	add    $0x1,%ebx
  8017a0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017a3:	75 d8                	jne    80177d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a8:	eb 05                	jmp    8017af <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017aa:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5f                   	pop    %edi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	56                   	push   %esi
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c2:	50                   	push   %eax
  8017c3:	e8 35 f6 ff ff       	call   800dfd <fd_alloc>
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	0f 88 2c 01 00 00    	js     801901 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d5:	83 ec 04             	sub    $0x4,%esp
  8017d8:	68 07 04 00 00       	push   $0x407
  8017dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e0:	6a 00                	push   $0x0
  8017e2:	e8 fe f3 ff ff       	call   800be5 <sys_page_alloc>
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	89 c2                	mov    %eax,%edx
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	0f 88 0d 01 00 00    	js     801901 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017f4:	83 ec 0c             	sub    $0xc,%esp
  8017f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fa:	50                   	push   %eax
  8017fb:	e8 fd f5 ff ff       	call   800dfd <fd_alloc>
  801800:	89 c3                	mov    %eax,%ebx
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	0f 88 e2 00 00 00    	js     8018ef <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180d:	83 ec 04             	sub    $0x4,%esp
  801810:	68 07 04 00 00       	push   $0x407
  801815:	ff 75 f0             	pushl  -0x10(%ebp)
  801818:	6a 00                	push   $0x0
  80181a:	e8 c6 f3 ff ff       	call   800be5 <sys_page_alloc>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	0f 88 c3 00 00 00    	js     8018ef <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	ff 75 f4             	pushl  -0xc(%ebp)
  801832:	e8 af f5 ff ff       	call   800de6 <fd2data>
  801837:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801839:	83 c4 0c             	add    $0xc,%esp
  80183c:	68 07 04 00 00       	push   $0x407
  801841:	50                   	push   %eax
  801842:	6a 00                	push   $0x0
  801844:	e8 9c f3 ff ff       	call   800be5 <sys_page_alloc>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	0f 88 89 00 00 00    	js     8018df <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	ff 75 f0             	pushl  -0x10(%ebp)
  80185c:	e8 85 f5 ff ff       	call   800de6 <fd2data>
  801861:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801868:	50                   	push   %eax
  801869:	6a 00                	push   $0x0
  80186b:	56                   	push   %esi
  80186c:	6a 00                	push   $0x0
  80186e:	e8 b5 f3 ff ff       	call   800c28 <sys_page_map>
  801873:	89 c3                	mov    %eax,%ebx
  801875:	83 c4 20             	add    $0x20,%esp
  801878:	85 c0                	test   %eax,%eax
  80187a:	78 55                	js     8018d1 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80187c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801885:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801887:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801891:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80189c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018a6:	83 ec 0c             	sub    $0xc,%esp
  8018a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ac:	e8 25 f5 ff ff       	call   800dd6 <fd2num>
  8018b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018b6:	83 c4 04             	add    $0x4,%esp
  8018b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bc:	e8 15 f5 ff ff       	call   800dd6 <fd2num>
  8018c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c4:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	eb 30                	jmp    801901 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018d1:	83 ec 08             	sub    $0x8,%esp
  8018d4:	56                   	push   %esi
  8018d5:	6a 00                	push   $0x0
  8018d7:	e8 8e f3 ff ff       	call   800c6a <sys_page_unmap>
  8018dc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018df:	83 ec 08             	sub    $0x8,%esp
  8018e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e5:	6a 00                	push   $0x0
  8018e7:	e8 7e f3 ff ff       	call   800c6a <sys_page_unmap>
  8018ec:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f5:	6a 00                	push   $0x0
  8018f7:	e8 6e f3 ff ff       	call   800c6a <sys_page_unmap>
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801901:	89 d0                	mov    %edx,%eax
  801903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	ff 75 08             	pushl  0x8(%ebp)
  801917:	e8 30 f5 ff ff       	call   800e4c <fd_lookup>
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 18                	js     80193b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 f4             	pushl  -0xc(%ebp)
  801929:	e8 b8 f4 ff ff       	call   800de6 <fd2data>
	return _pipeisclosed(fd, p);
  80192e:	89 c2                	mov    %eax,%edx
  801930:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801933:	e8 21 fd ff ff       	call   801659 <_pipeisclosed>
  801938:	83 c4 10             	add    $0x10,%esp
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    

00801947 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80194d:	68 8e 23 80 00       	push   $0x80238e
  801952:	ff 75 0c             	pushl  0xc(%ebp)
  801955:	e8 88 ee ff ff       	call   8007e2 <strcpy>
	return 0;
}
  80195a:	b8 00 00 00 00       	mov    $0x0,%eax
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	57                   	push   %edi
  801965:	56                   	push   %esi
  801966:	53                   	push   %ebx
  801967:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80196d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801972:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801978:	eb 2d                	jmp    8019a7 <devcons_write+0x46>
		m = n - tot;
  80197a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80197d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80197f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801982:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801987:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80198a:	83 ec 04             	sub    $0x4,%esp
  80198d:	53                   	push   %ebx
  80198e:	03 45 0c             	add    0xc(%ebp),%eax
  801991:	50                   	push   %eax
  801992:	57                   	push   %edi
  801993:	e8 dc ef ff ff       	call   800974 <memmove>
		sys_cputs(buf, m);
  801998:	83 c4 08             	add    $0x8,%esp
  80199b:	53                   	push   %ebx
  80199c:	57                   	push   %edi
  80199d:	e8 87 f1 ff ff       	call   800b29 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a2:	01 de                	add    %ebx,%esi
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	89 f0                	mov    %esi,%eax
  8019a9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ac:	72 cc                	jb     80197a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5e                   	pop    %esi
  8019b3:	5f                   	pop    %edi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019c5:	74 2a                	je     8019f1 <devcons_read+0x3b>
  8019c7:	eb 05                	jmp    8019ce <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019c9:	e8 f8 f1 ff ff       	call   800bc6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019ce:	e8 74 f1 ff ff       	call   800b47 <sys_cgetc>
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	74 f2                	je     8019c9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 16                	js     8019f1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019db:	83 f8 04             	cmp    $0x4,%eax
  8019de:	74 0c                	je     8019ec <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e3:	88 02                	mov    %al,(%edx)
	return 1;
  8019e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ea:	eb 05                	jmp    8019f1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019ff:	6a 01                	push   $0x1
  801a01:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a04:	50                   	push   %eax
  801a05:	e8 1f f1 ff ff       	call   800b29 <sys_cputs>
}
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <getchar>:

int
getchar(void)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a15:	6a 01                	push   $0x1
  801a17:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a1a:	50                   	push   %eax
  801a1b:	6a 00                	push   $0x0
  801a1d:	e8 90 f6 ff ff       	call   8010b2 <read>
	if (r < 0)
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 0f                	js     801a38 <getchar+0x29>
		return r;
	if (r < 1)
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	7e 06                	jle    801a33 <getchar+0x24>
		return -E_EOF;
	return c;
  801a2d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a31:	eb 05                	jmp    801a38 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a33:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a43:	50                   	push   %eax
  801a44:	ff 75 08             	pushl  0x8(%ebp)
  801a47:	e8 00 f4 ff ff       	call   800e4c <fd_lookup>
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 11                	js     801a64 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a56:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a5c:	39 10                	cmp    %edx,(%eax)
  801a5e:	0f 94 c0             	sete   %al
  801a61:	0f b6 c0             	movzbl %al,%eax
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <opencons>:

int
opencons(void)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6f:	50                   	push   %eax
  801a70:	e8 88 f3 ff ff       	call   800dfd <fd_alloc>
  801a75:	83 c4 10             	add    $0x10,%esp
		return r;
  801a78:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 3e                	js     801abc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a7e:	83 ec 04             	sub    $0x4,%esp
  801a81:	68 07 04 00 00       	push   $0x407
  801a86:	ff 75 f4             	pushl  -0xc(%ebp)
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 55 f1 ff ff       	call   800be5 <sys_page_alloc>
  801a90:	83 c4 10             	add    $0x10,%esp
		return r;
  801a93:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a95:	85 c0                	test   %eax,%eax
  801a97:	78 23                	js     801abc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a99:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	50                   	push   %eax
  801ab2:	e8 1f f3 ff ff       	call   800dd6 <fd2num>
  801ab7:	89 c2                	mov    %eax,%edx
  801ab9:	83 c4 10             	add    $0x10,%esp
}
  801abc:	89 d0                	mov    %edx,%eax
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
  801ac5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	75 12                	jne    801ae4 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ad2:	83 ec 0c             	sub    $0xc,%esp
  801ad5:	68 00 00 c0 ee       	push   $0xeec00000
  801ada:	e8 b6 f2 ff ff       	call   800d95 <sys_ipc_recv>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	eb 0c                	jmp    801af0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	50                   	push   %eax
  801ae8:	e8 a8 f2 ff ff       	call   800d95 <sys_ipc_recv>
  801aed:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801af0:	85 f6                	test   %esi,%esi
  801af2:	0f 95 c1             	setne  %cl
  801af5:	85 db                	test   %ebx,%ebx
  801af7:	0f 95 c2             	setne  %dl
  801afa:	84 d1                	test   %dl,%cl
  801afc:	74 09                	je     801b07 <ipc_recv+0x47>
  801afe:	89 c2                	mov    %eax,%edx
  801b00:	c1 ea 1f             	shr    $0x1f,%edx
  801b03:	84 d2                	test   %dl,%dl
  801b05:	75 24                	jne    801b2b <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b07:	85 f6                	test   %esi,%esi
  801b09:	74 0a                	je     801b15 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b0b:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b10:	8b 40 74             	mov    0x74(%eax),%eax
  801b13:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b15:	85 db                	test   %ebx,%ebx
  801b17:	74 0a                	je     801b23 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801b19:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b1e:	8b 40 78             	mov    0x78(%eax),%eax
  801b21:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b23:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b28:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2e:	5b                   	pop    %ebx
  801b2f:	5e                   	pop    %esi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	57                   	push   %edi
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b44:	85 db                	test   %ebx,%ebx
  801b46:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b4b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b4e:	ff 75 14             	pushl  0x14(%ebp)
  801b51:	53                   	push   %ebx
  801b52:	56                   	push   %esi
  801b53:	57                   	push   %edi
  801b54:	e8 19 f2 ff ff       	call   800d72 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b59:	89 c2                	mov    %eax,%edx
  801b5b:	c1 ea 1f             	shr    $0x1f,%edx
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	84 d2                	test   %dl,%dl
  801b63:	74 17                	je     801b7c <ipc_send+0x4a>
  801b65:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b68:	74 12                	je     801b7c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b6a:	50                   	push   %eax
  801b6b:	68 9a 23 80 00       	push   $0x80239a
  801b70:	6a 47                	push   $0x47
  801b72:	68 a8 23 80 00       	push   $0x8023a8
  801b77:	e8 08 e6 ff ff       	call   800184 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b7c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b7f:	75 07                	jne    801b88 <ipc_send+0x56>
			sys_yield();
  801b81:	e8 40 f0 ff ff       	call   800bc6 <sys_yield>
  801b86:	eb c6                	jmp    801b4e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	75 c2                	jne    801b4e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5e                   	pop    %esi
  801b91:	5f                   	pop    %edi
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b9a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b9f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ba2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ba8:	8b 52 50             	mov    0x50(%edx),%edx
  801bab:	39 ca                	cmp    %ecx,%edx
  801bad:	75 0d                	jne    801bbc <ipc_find_env+0x28>
			return envs[i].env_id;
  801baf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bb2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bb7:	8b 40 48             	mov    0x48(%eax),%eax
  801bba:	eb 0f                	jmp    801bcb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bbc:	83 c0 01             	add    $0x1,%eax
  801bbf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bc4:	75 d9                	jne    801b9f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd3:	89 d0                	mov    %edx,%eax
  801bd5:	c1 e8 16             	shr    $0x16,%eax
  801bd8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be4:	f6 c1 01             	test   $0x1,%cl
  801be7:	74 1d                	je     801c06 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801be9:	c1 ea 0c             	shr    $0xc,%edx
  801bec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf3:	f6 c2 01             	test   $0x1,%dl
  801bf6:	74 0e                	je     801c06 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bf8:	c1 ea 0c             	shr    $0xc,%edx
  801bfb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c02:	ef 
  801c03:	0f b7 c0             	movzwl %ax,%eax
}
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	66 90                	xchg   %ax,%ax
  801c0a:	66 90                	xchg   %ax,%ax
  801c0c:	66 90                	xchg   %ax,%ax
  801c0e:	66 90                	xchg   %ax,%ax

00801c10 <__udivdi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c27:	85 f6                	test   %esi,%esi
  801c29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c2d:	89 ca                	mov    %ecx,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	75 3d                	jne    801c70 <__udivdi3+0x60>
  801c33:	39 cf                	cmp    %ecx,%edi
  801c35:	0f 87 c5 00 00 00    	ja     801d00 <__udivdi3+0xf0>
  801c3b:	85 ff                	test   %edi,%edi
  801c3d:	89 fd                	mov    %edi,%ebp
  801c3f:	75 0b                	jne    801c4c <__udivdi3+0x3c>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	31 d2                	xor    %edx,%edx
  801c48:	f7 f7                	div    %edi
  801c4a:	89 c5                	mov    %eax,%ebp
  801c4c:	89 c8                	mov    %ecx,%eax
  801c4e:	31 d2                	xor    %edx,%edx
  801c50:	f7 f5                	div    %ebp
  801c52:	89 c1                	mov    %eax,%ecx
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	89 cf                	mov    %ecx,%edi
  801c58:	f7 f5                	div    %ebp
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	39 ce                	cmp    %ecx,%esi
  801c72:	77 74                	ja     801ce8 <__udivdi3+0xd8>
  801c74:	0f bd fe             	bsr    %esi,%edi
  801c77:	83 f7 1f             	xor    $0x1f,%edi
  801c7a:	0f 84 98 00 00 00    	je     801d18 <__udivdi3+0x108>
  801c80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	89 c5                	mov    %eax,%ebp
  801c89:	29 fb                	sub    %edi,%ebx
  801c8b:	d3 e6                	shl    %cl,%esi
  801c8d:	89 d9                	mov    %ebx,%ecx
  801c8f:	d3 ed                	shr    %cl,%ebp
  801c91:	89 f9                	mov    %edi,%ecx
  801c93:	d3 e0                	shl    %cl,%eax
  801c95:	09 ee                	or     %ebp,%esi
  801c97:	89 d9                	mov    %ebx,%ecx
  801c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9d:	89 d5                	mov    %edx,%ebp
  801c9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ca3:	d3 ed                	shr    %cl,%ebp
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e2                	shl    %cl,%edx
  801ca9:	89 d9                	mov    %ebx,%ecx
  801cab:	d3 e8                	shr    %cl,%eax
  801cad:	09 c2                	or     %eax,%edx
  801caf:	89 d0                	mov    %edx,%eax
  801cb1:	89 ea                	mov    %ebp,%edx
  801cb3:	f7 f6                	div    %esi
  801cb5:	89 d5                	mov    %edx,%ebp
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	f7 64 24 0c          	mull   0xc(%esp)
  801cbd:	39 d5                	cmp    %edx,%ebp
  801cbf:	72 10                	jb     801cd1 <__udivdi3+0xc1>
  801cc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e6                	shl    %cl,%esi
  801cc9:	39 c6                	cmp    %eax,%esi
  801ccb:	73 07                	jae    801cd4 <__udivdi3+0xc4>
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	75 03                	jne    801cd4 <__udivdi3+0xc4>
  801cd1:	83 eb 01             	sub    $0x1,%ebx
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 d8                	mov    %ebx,%eax
  801cd8:	89 fa                	mov    %edi,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	31 ff                	xor    %edi,%edi
  801cea:	31 db                	xor    %ebx,%ebx
  801cec:	89 d8                	mov    %ebx,%eax
  801cee:	89 fa                	mov    %edi,%edx
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	90                   	nop
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	f7 f7                	div    %edi
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 fa                	mov    %edi,%edx
  801d0c:	83 c4 1c             	add    $0x1c,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	39 ce                	cmp    %ecx,%esi
  801d1a:	72 0c                	jb     801d28 <__udivdi3+0x118>
  801d1c:	31 db                	xor    %ebx,%ebx
  801d1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d22:	0f 87 34 ff ff ff    	ja     801c5c <__udivdi3+0x4c>
  801d28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d2d:	e9 2a ff ff ff       	jmp    801c5c <__udivdi3+0x4c>
  801d32:	66 90                	xchg   %ax,%ax
  801d34:	66 90                	xchg   %ax,%ax
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__umoddi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
  801d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	85 d2                	test   %edx,%edx
  801d59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f3                	mov    %esi,%ebx
  801d63:	89 3c 24             	mov    %edi,(%esp)
  801d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6a:	75 1c                	jne    801d88 <__umoddi3+0x48>
  801d6c:	39 f7                	cmp    %esi,%edi
  801d6e:	76 50                	jbe    801dc0 <__umoddi3+0x80>
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	f7 f7                	div    %edi
  801d76:	89 d0                	mov    %edx,%eax
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	39 f2                	cmp    %esi,%edx
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	77 52                	ja     801de0 <__umoddi3+0xa0>
  801d8e:	0f bd ea             	bsr    %edx,%ebp
  801d91:	83 f5 1f             	xor    $0x1f,%ebp
  801d94:	75 5a                	jne    801df0 <__umoddi3+0xb0>
  801d96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d9a:	0f 82 e0 00 00 00    	jb     801e80 <__umoddi3+0x140>
  801da0:	39 0c 24             	cmp    %ecx,(%esp)
  801da3:	0f 86 d7 00 00 00    	jbe    801e80 <__umoddi3+0x140>
  801da9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db1:	83 c4 1c             	add    $0x1c,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	85 ff                	test   %edi,%edi
  801dc2:	89 fd                	mov    %edi,%ebp
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0x91>
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f7                	div    %edi
  801dcf:	89 c5                	mov    %eax,%ebp
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f5                	div    %ebp
  801dd7:	89 c8                	mov    %ecx,%eax
  801dd9:	f7 f5                	div    %ebp
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	eb 99                	jmp    801d78 <__umoddi3+0x38>
  801ddf:	90                   	nop
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	83 c4 1c             	add    $0x1c,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    
  801dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df0:	8b 34 24             	mov    (%esp),%esi
  801df3:	bf 20 00 00 00       	mov    $0x20,%edi
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	29 ef                	sub    %ebp,%edi
  801dfc:	d3 e0                	shl    %cl,%eax
  801dfe:	89 f9                	mov    %edi,%ecx
  801e00:	89 f2                	mov    %esi,%edx
  801e02:	d3 ea                	shr    %cl,%edx
  801e04:	89 e9                	mov    %ebp,%ecx
  801e06:	09 c2                	or     %eax,%edx
  801e08:	89 d8                	mov    %ebx,%eax
  801e0a:	89 14 24             	mov    %edx,(%esp)
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	d3 e2                	shl    %cl,%edx
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	89 c6                	mov    %eax,%esi
  801e21:	d3 e3                	shl    %cl,%ebx
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	d3 e8                	shr    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	09 d8                	or     %ebx,%eax
  801e2d:	89 d3                	mov    %edx,%ebx
  801e2f:	89 f2                	mov    %esi,%edx
  801e31:	f7 34 24             	divl   (%esp)
  801e34:	89 d6                	mov    %edx,%esi
  801e36:	d3 e3                	shl    %cl,%ebx
  801e38:	f7 64 24 04          	mull   0x4(%esp)
  801e3c:	39 d6                	cmp    %edx,%esi
  801e3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e42:	89 d1                	mov    %edx,%ecx
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	72 08                	jb     801e50 <__umoddi3+0x110>
  801e48:	75 11                	jne    801e5b <__umoddi3+0x11b>
  801e4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e4e:	73 0b                	jae    801e5b <__umoddi3+0x11b>
  801e50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e54:	1b 14 24             	sbb    (%esp),%edx
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e5f:	29 da                	sub    %ebx,%edx
  801e61:	19 ce                	sbb    %ecx,%esi
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e0                	shl    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	d3 ea                	shr    %cl,%edx
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	09 d0                	or     %edx,%eax
  801e73:	89 f2                	mov    %esi,%edx
  801e75:	83 c4 1c             	add    $0x1c,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
  801e80:	29 f9                	sub    %edi,%ecx
  801e82:	19 d6                	sbb    %edx,%esi
  801e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e8c:	e9 18 ff ff ff       	jmp    801da9 <__umoddi3+0x69>
