
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 20 1f 80 00       	push   $0x801f20
  800045:	e8 01 02 00 00       	call   80024b <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 75 0b 00 00       	call   800bd3 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 40 1f 80 00       	push   $0x801f40
  80006f:	6a 0e                	push   $0xe
  800071:	68 2a 1f 80 00       	push   $0x801f2a
  800076:	e8 f7 00 00 00       	call   800172 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 6c 1f 80 00       	push   $0x801f6c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 f4 06 00 00       	call   80077d <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 23 0d 00 00       	call   800dc4 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 3c 1f 80 00       	push   $0x801f3c
  8000ae:	e8 98 01 00 00       	call   80024b <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 3c 1f 80 00       	push   $0x801f3c
  8000c0:	e8 86 01 00 00       	call   80024b <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d3:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000da:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000dd:	e8 b3 0a 00 00       	call   800b95 <sys_getenvid>
  8000e2:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000e8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8000ed:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000f2:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8000f7:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8000fa:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800100:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800103:	39 c8                	cmp    %ecx,%eax
  800105:	0f 44 fb             	cmove  %ebx,%edi
  800108:	b9 01 00 00 00       	mov    $0x1,%ecx
  80010d:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800110:	83 c2 01             	add    $0x1,%edx
  800113:	83 c3 7c             	add    $0x7c,%ebx
  800116:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80011c:	75 d9                	jne    8000f7 <libmain+0x2d>
  80011e:	89 f0                	mov    %esi,%eax
  800120:	84 c0                	test   %al,%al
  800122:	74 06                	je     80012a <libmain+0x60>
  800124:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80012e:	7e 0a                	jle    80013a <libmain+0x70>
		binaryname = argv[0];
  800130:	8b 45 0c             	mov    0xc(%ebp),%eax
  800133:	8b 00                	mov    (%eax),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	ff 75 0c             	pushl  0xc(%ebp)
  800140:	ff 75 08             	pushl  0x8(%ebp)
  800143:	e8 49 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800148:	e8 0b 00 00 00       	call   800158 <exit>
}
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80015e:	e8 bb 0e 00 00       	call   80101e <close_all>
	sys_env_destroy(0);
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	6a 00                	push   $0x0
  800168:	e8 e7 09 00 00       	call   800b54 <sys_env_destroy>
}
  80016d:	83 c4 10             	add    $0x10,%esp
  800170:	c9                   	leave  
  800171:	c3                   	ret    

00800172 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800177:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800180:	e8 10 0a 00 00       	call   800b95 <sys_getenvid>
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 0c             	pushl  0xc(%ebp)
  80018b:	ff 75 08             	pushl  0x8(%ebp)
  80018e:	56                   	push   %esi
  80018f:	50                   	push   %eax
  800190:	68 98 1f 80 00       	push   $0x801f98
  800195:	e8 b1 00 00 00       	call   80024b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019a:	83 c4 18             	add    $0x18,%esp
  80019d:	53                   	push   %ebx
  80019e:	ff 75 10             	pushl  0x10(%ebp)
  8001a1:	e8 54 00 00 00       	call   8001fa <vcprintf>
	cprintf("\n");
  8001a6:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
  8001ad:	e8 99 00 00 00       	call   80024b <cprintf>
  8001b2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b5:	cc                   	int3   
  8001b6:	eb fd                	jmp    8001b5 <_panic+0x43>

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 04             	sub    $0x4,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 13                	mov    (%ebx),%edx
  8001c4:	8d 42 01             	lea    0x1(%edx),%eax
  8001c7:	89 03                	mov    %eax,(%ebx)
  8001c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d5:	75 1a                	jne    8001f1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	68 ff 00 00 00       	push   $0xff
  8001df:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 2f 09 00 00       	call   800b17 <sys_cputs>
		b->idx = 0;
  8001e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ee:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800203:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020a:	00 00 00 
	b.cnt = 0;
  80020d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800214:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800217:	ff 75 0c             	pushl  0xc(%ebp)
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	68 b8 01 80 00       	push   $0x8001b8
  800229:	e8 54 01 00 00       	call   800382 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022e:	83 c4 08             	add    $0x8,%esp
  800231:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800237:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023d:	50                   	push   %eax
  80023e:	e8 d4 08 00 00       	call   800b17 <sys_cputs>

	return b.cnt;
}
  800243:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800251:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800254:	50                   	push   %eax
  800255:	ff 75 08             	pushl  0x8(%ebp)
  800258:	e8 9d ff ff ff       	call   8001fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 1c             	sub    $0x1c,%esp
  800268:	89 c7                	mov    %eax,%edi
  80026a:	89 d6                	mov    %edx,%esi
  80026c:	8b 45 08             	mov    0x8(%ebp),%eax
  80026f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800272:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800275:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800278:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80027b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800280:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800283:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800286:	39 d3                	cmp    %edx,%ebx
  800288:	72 05                	jb     80028f <printnum+0x30>
  80028a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028d:	77 45                	ja     8002d4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	ff 75 18             	pushl  0x18(%ebp)
  800295:	8b 45 14             	mov    0x14(%ebp),%eax
  800298:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80029b:	53                   	push   %ebx
  80029c:	ff 75 10             	pushl  0x10(%ebp)
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ae:	e8 dd 19 00 00       	call   801c90 <__udivdi3>
  8002b3:	83 c4 18             	add    $0x18,%esp
  8002b6:	52                   	push   %edx
  8002b7:	50                   	push   %eax
  8002b8:	89 f2                	mov    %esi,%edx
  8002ba:	89 f8                	mov    %edi,%eax
  8002bc:	e8 9e ff ff ff       	call   80025f <printnum>
  8002c1:	83 c4 20             	add    $0x20,%esp
  8002c4:	eb 18                	jmp    8002de <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	56                   	push   %esi
  8002ca:	ff 75 18             	pushl  0x18(%ebp)
  8002cd:	ff d7                	call   *%edi
  8002cf:	83 c4 10             	add    $0x10,%esp
  8002d2:	eb 03                	jmp    8002d7 <printnum+0x78>
  8002d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d7:	83 eb 01             	sub    $0x1,%ebx
  8002da:	85 db                	test   %ebx,%ebx
  8002dc:	7f e8                	jg     8002c6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	56                   	push   %esi
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f1:	e8 ca 1a 00 00       	call   801dc0 <__umoddi3>
  8002f6:	83 c4 14             	add    $0x14,%esp
  8002f9:	0f be 80 bb 1f 80 00 	movsbl 0x801fbb(%eax),%eax
  800300:	50                   	push   %eax
  800301:	ff d7                	call   *%edi
}
  800303:	83 c4 10             	add    $0x10,%esp
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800311:	83 fa 01             	cmp    $0x1,%edx
  800314:	7e 0e                	jle    800324 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	8b 52 04             	mov    0x4(%edx),%edx
  800322:	eb 22                	jmp    800346 <getuint+0x38>
	else if (lflag)
  800324:	85 d2                	test   %edx,%edx
  800326:	74 10                	je     800338 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032d:	89 08                	mov    %ecx,(%eax)
  80032f:	8b 02                	mov    (%edx),%eax
  800331:	ba 00 00 00 00       	mov    $0x0,%edx
  800336:	eb 0e                	jmp    800346 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800352:	8b 10                	mov    (%eax),%edx
  800354:	3b 50 04             	cmp    0x4(%eax),%edx
  800357:	73 0a                	jae    800363 <sprintputch+0x1b>
		*b->buf++ = ch;
  800359:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	88 02                	mov    %al,(%edx)
}
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80036b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036e:	50                   	push   %eax
  80036f:	ff 75 10             	pushl  0x10(%ebp)
  800372:	ff 75 0c             	pushl  0xc(%ebp)
  800375:	ff 75 08             	pushl  0x8(%ebp)
  800378:	e8 05 00 00 00       	call   800382 <vprintfmt>
	va_end(ap);
}
  80037d:	83 c4 10             	add    $0x10,%esp
  800380:	c9                   	leave  
  800381:	c3                   	ret    

00800382 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	57                   	push   %edi
  800386:	56                   	push   %esi
  800387:	53                   	push   %ebx
  800388:	83 ec 2c             	sub    $0x2c,%esp
  80038b:	8b 75 08             	mov    0x8(%ebp),%esi
  80038e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800391:	8b 7d 10             	mov    0x10(%ebp),%edi
  800394:	eb 12                	jmp    8003a8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800396:	85 c0                	test   %eax,%eax
  800398:	0f 84 89 03 00 00    	je     800727 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80039e:	83 ec 08             	sub    $0x8,%esp
  8003a1:	53                   	push   %ebx
  8003a2:	50                   	push   %eax
  8003a3:	ff d6                	call   *%esi
  8003a5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a8:	83 c7 01             	add    $0x1,%edi
  8003ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003af:	83 f8 25             	cmp    $0x25,%eax
  8003b2:	75 e2                	jne    800396 <vprintfmt+0x14>
  8003b4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003b8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d2:	eb 07                	jmp    8003db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8d 47 01             	lea    0x1(%edi),%eax
  8003de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e1:	0f b6 07             	movzbl (%edi),%eax
  8003e4:	0f b6 c8             	movzbl %al,%ecx
  8003e7:	83 e8 23             	sub    $0x23,%eax
  8003ea:	3c 55                	cmp    $0x55,%al
  8003ec:	0f 87 1a 03 00 00    	ja     80070c <vprintfmt+0x38a>
  8003f2:	0f b6 c0             	movzbl %al,%eax
  8003f5:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ff:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800403:	eb d6                	jmp    8003db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800408:	b8 00 00 00 00       	mov    $0x0,%eax
  80040d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800410:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800413:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800417:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80041a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80041d:	83 fa 09             	cmp    $0x9,%edx
  800420:	77 39                	ja     80045b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800422:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800425:	eb e9                	jmp    800410 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 48 04             	lea    0x4(%eax),%ecx
  80042d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800430:	8b 00                	mov    (%eax),%eax
  800432:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800438:	eb 27                	jmp    800461 <vprintfmt+0xdf>
  80043a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80043d:	85 c0                	test   %eax,%eax
  80043f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800444:	0f 49 c8             	cmovns %eax,%ecx
  800447:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044d:	eb 8c                	jmp    8003db <vprintfmt+0x59>
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800452:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800459:	eb 80                	jmp    8003db <vprintfmt+0x59>
  80045b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80045e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800461:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800465:	0f 89 70 ff ff ff    	jns    8003db <vprintfmt+0x59>
				width = precision, precision = -1;
  80046b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80046e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800471:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800478:	e9 5e ff ff ff       	jmp    8003db <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80047d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800483:	e9 53 ff ff ff       	jmp    8003db <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800488:	8b 45 14             	mov    0x14(%ebp),%eax
  80048b:	8d 50 04             	lea    0x4(%eax),%edx
  80048e:	89 55 14             	mov    %edx,0x14(%ebp)
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	53                   	push   %ebx
  800495:	ff 30                	pushl  (%eax)
  800497:	ff d6                	call   *%esi
			break;
  800499:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80049f:	e9 04 ff ff ff       	jmp    8003a8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	99                   	cltd   
  8004b0:	31 d0                	xor    %edx,%eax
  8004b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b4:	83 f8 0f             	cmp    $0xf,%eax
  8004b7:	7f 0b                	jg     8004c4 <vprintfmt+0x142>
  8004b9:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  8004c0:	85 d2                	test   %edx,%edx
  8004c2:	75 18                	jne    8004dc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004c4:	50                   	push   %eax
  8004c5:	68 d3 1f 80 00       	push   $0x801fd3
  8004ca:	53                   	push   %ebx
  8004cb:	56                   	push   %esi
  8004cc:	e8 94 fe ff ff       	call   800365 <printfmt>
  8004d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d7:	e9 cc fe ff ff       	jmp    8003a8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004dc:	52                   	push   %edx
  8004dd:	68 a5 23 80 00       	push   $0x8023a5
  8004e2:	53                   	push   %ebx
  8004e3:	56                   	push   %esi
  8004e4:	e8 7c fe ff ff       	call   800365 <printfmt>
  8004e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ef:	e9 b4 fe ff ff       	jmp    8003a8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8d 50 04             	lea    0x4(%eax),%edx
  8004fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ff:	85 ff                	test   %edi,%edi
  800501:	b8 cc 1f 80 00       	mov    $0x801fcc,%eax
  800506:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800509:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050d:	0f 8e 94 00 00 00    	jle    8005a7 <vprintfmt+0x225>
  800513:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800517:	0f 84 98 00 00 00    	je     8005b5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	ff 75 d0             	pushl  -0x30(%ebp)
  800523:	57                   	push   %edi
  800524:	e8 86 02 00 00       	call   8007af <strnlen>
  800529:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052c:	29 c1                	sub    %eax,%ecx
  80052e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800531:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800534:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800538:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800540:	eb 0f                	jmp    800551 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	ff 75 e0             	pushl  -0x20(%ebp)
  800549:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	83 ef 01             	sub    $0x1,%edi
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	85 ff                	test   %edi,%edi
  800553:	7f ed                	jg     800542 <vprintfmt+0x1c0>
  800555:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800558:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80055b:	85 c9                	test   %ecx,%ecx
  80055d:	b8 00 00 00 00       	mov    $0x0,%eax
  800562:	0f 49 c1             	cmovns %ecx,%eax
  800565:	29 c1                	sub    %eax,%ecx
  800567:	89 75 08             	mov    %esi,0x8(%ebp)
  80056a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800570:	89 cb                	mov    %ecx,%ebx
  800572:	eb 4d                	jmp    8005c1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800574:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800578:	74 1b                	je     800595 <vprintfmt+0x213>
  80057a:	0f be c0             	movsbl %al,%eax
  80057d:	83 e8 20             	sub    $0x20,%eax
  800580:	83 f8 5e             	cmp    $0x5e,%eax
  800583:	76 10                	jbe    800595 <vprintfmt+0x213>
					putch('?', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	ff 75 0c             	pushl  0xc(%ebp)
  80058b:	6a 3f                	push   $0x3f
  80058d:	ff 55 08             	call   *0x8(%ebp)
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb 0d                	jmp    8005a2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	ff 75 0c             	pushl  0xc(%ebp)
  80059b:	52                   	push   %edx
  80059c:	ff 55 08             	call   *0x8(%ebp)
  80059f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a2:	83 eb 01             	sub    $0x1,%ebx
  8005a5:	eb 1a                	jmp    8005c1 <vprintfmt+0x23f>
  8005a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b3:	eb 0c                	jmp    8005c1 <vprintfmt+0x23f>
  8005b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c1:	83 c7 01             	add    $0x1,%edi
  8005c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c8:	0f be d0             	movsbl %al,%edx
  8005cb:	85 d2                	test   %edx,%edx
  8005cd:	74 23                	je     8005f2 <vprintfmt+0x270>
  8005cf:	85 f6                	test   %esi,%esi
  8005d1:	78 a1                	js     800574 <vprintfmt+0x1f2>
  8005d3:	83 ee 01             	sub    $0x1,%esi
  8005d6:	79 9c                	jns    800574 <vprintfmt+0x1f2>
  8005d8:	89 df                	mov    %ebx,%edi
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e0:	eb 18                	jmp    8005fa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	53                   	push   %ebx
  8005e6:	6a 20                	push   $0x20
  8005e8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ea:	83 ef 01             	sub    $0x1,%edi
  8005ed:	83 c4 10             	add    $0x10,%esp
  8005f0:	eb 08                	jmp    8005fa <vprintfmt+0x278>
  8005f2:	89 df                	mov    %ebx,%edi
  8005f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	7f e4                	jg     8005e2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800601:	e9 a2 fd ff ff       	jmp    8003a8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800606:	83 fa 01             	cmp    $0x1,%edx
  800609:	7e 16                	jle    800621 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 08             	lea    0x8(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 50 04             	mov    0x4(%eax),%edx
  800617:	8b 00                	mov    (%eax),%eax
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061f:	eb 32                	jmp    800653 <vprintfmt+0x2d1>
	else if (lflag)
  800621:	85 d2                	test   %edx,%edx
  800623:	74 18                	je     80063d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 00                	mov    (%eax),%eax
  800630:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800633:	89 c1                	mov    %eax,%ecx
  800635:	c1 f9 1f             	sar    $0x1f,%ecx
  800638:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80063b:	eb 16                	jmp    800653 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	8b 00                	mov    (%eax),%eax
  800648:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064b:	89 c1                	mov    %eax,%ecx
  80064d:	c1 f9 1f             	sar    $0x1f,%ecx
  800650:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800653:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800656:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800659:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800662:	79 74                	jns    8006d8 <vprintfmt+0x356>
				putch('-', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 2d                	push   $0x2d
  80066a:	ff d6                	call   *%esi
				num = -(long long) num;
  80066c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80066f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800672:	f7 d8                	neg    %eax
  800674:	83 d2 00             	adc    $0x0,%edx
  800677:	f7 da                	neg    %edx
  800679:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80067c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800681:	eb 55                	jmp    8006d8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 83 fc ff ff       	call   80030e <getuint>
			base = 10;
  80068b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800690:	eb 46                	jmp    8006d8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
  800695:	e8 74 fc ff ff       	call   80030e <getuint>
			base = 8;
  80069a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80069f:	eb 37                	jmp    8006d8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	6a 30                	push   $0x30
  8006a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a9:	83 c4 08             	add    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 78                	push   $0x78
  8006af:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 04             	lea    0x4(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ba:	8b 00                	mov    (%eax),%eax
  8006bc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006c9:	eb 0d                	jmp    8006d8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 3b fc ff ff       	call   80030e <getuint>
			base = 16;
  8006d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d8:	83 ec 0c             	sub    $0xc,%esp
  8006db:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006df:	57                   	push   %edi
  8006e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e3:	51                   	push   %ecx
  8006e4:	52                   	push   %edx
  8006e5:	50                   	push   %eax
  8006e6:	89 da                	mov    %ebx,%edx
  8006e8:	89 f0                	mov    %esi,%eax
  8006ea:	e8 70 fb ff ff       	call   80025f <printnum>
			break;
  8006ef:	83 c4 20             	add    $0x20,%esp
  8006f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f5:	e9 ae fc ff ff       	jmp    8003a8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	51                   	push   %ecx
  8006ff:	ff d6                	call   *%esi
			break;
  800701:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800704:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800707:	e9 9c fc ff ff       	jmp    8003a8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	6a 25                	push   $0x25
  800712:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 03                	jmp    80071c <vprintfmt+0x39a>
  800719:	83 ef 01             	sub    $0x1,%edi
  80071c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800720:	75 f7                	jne    800719 <vprintfmt+0x397>
  800722:	e9 81 fc ff ff       	jmp    8003a8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800727:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072a:	5b                   	pop    %ebx
  80072b:	5e                   	pop    %esi
  80072c:	5f                   	pop    %edi
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	83 ec 18             	sub    $0x18,%esp
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800742:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800745:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074c:	85 c0                	test   %eax,%eax
  80074e:	74 26                	je     800776 <vsnprintf+0x47>
  800750:	85 d2                	test   %edx,%edx
  800752:	7e 22                	jle    800776 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800754:	ff 75 14             	pushl  0x14(%ebp)
  800757:	ff 75 10             	pushl  0x10(%ebp)
  80075a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	68 48 03 80 00       	push   $0x800348
  800763:	e8 1a fc ff ff       	call   800382 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	eb 05                	jmp    80077b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800786:	50                   	push   %eax
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	ff 75 08             	pushl  0x8(%ebp)
  800790:	e8 9a ff ff ff       	call   80072f <vsnprintf>
	va_end(ap);

	return rc;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a2:	eb 03                	jmp    8007a7 <strlen+0x10>
		n++;
  8007a4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ab:	75 f7                	jne    8007a4 <strlen+0xd>
		n++;
	return n;
}
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bd:	eb 03                	jmp    8007c2 <strnlen+0x13>
		n++;
  8007bf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c2:	39 c2                	cmp    %eax,%edx
  8007c4:	74 08                	je     8007ce <strnlen+0x1f>
  8007c6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ca:	75 f3                	jne    8007bf <strnlen+0x10>
  8007cc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007da:	89 c2                	mov    %eax,%edx
  8007dc:	83 c2 01             	add    $0x1,%edx
  8007df:	83 c1 01             	add    $0x1,%ecx
  8007e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e9:	84 db                	test   %bl,%bl
  8007eb:	75 ef                	jne    8007dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f7:	53                   	push   %ebx
  8007f8:	e8 9a ff ff ff       	call   800797 <strlen>
  8007fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	01 d8                	add    %ebx,%eax
  800805:	50                   	push   %eax
  800806:	e8 c5 ff ff ff       	call   8007d0 <strcpy>
	return dst;
}
  80080b:	89 d8                	mov    %ebx,%eax
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	89 f3                	mov    %esi,%ebx
  80081f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800822:	89 f2                	mov    %esi,%edx
  800824:	eb 0f                	jmp    800835 <strncpy+0x23>
		*dst++ = *src;
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082f:	80 39 01             	cmpb   $0x1,(%ecx)
  800832:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800835:	39 da                	cmp    %ebx,%edx
  800837:	75 ed                	jne    800826 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800839:	89 f0                	mov    %esi,%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084a:	8b 55 10             	mov    0x10(%ebp),%edx
  80084d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084f:	85 d2                	test   %edx,%edx
  800851:	74 21                	je     800874 <strlcpy+0x35>
  800853:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800857:	89 f2                	mov    %esi,%edx
  800859:	eb 09                	jmp    800864 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085b:	83 c2 01             	add    $0x1,%edx
  80085e:	83 c1 01             	add    $0x1,%ecx
  800861:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800864:	39 c2                	cmp    %eax,%edx
  800866:	74 09                	je     800871 <strlcpy+0x32>
  800868:	0f b6 19             	movzbl (%ecx),%ebx
  80086b:	84 db                	test   %bl,%bl
  80086d:	75 ec                	jne    80085b <strlcpy+0x1c>
  80086f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800871:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800874:	29 f0                	sub    %esi,%eax
}
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800883:	eb 06                	jmp    80088b <strcmp+0x11>
		p++, q++;
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088b:	0f b6 01             	movzbl (%ecx),%eax
  80088e:	84 c0                	test   %al,%al
  800890:	74 04                	je     800896 <strcmp+0x1c>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	74 ef                	je     800885 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800896:	0f b6 c0             	movzbl %al,%eax
  800899:	0f b6 12             	movzbl (%edx),%edx
  80089c:	29 d0                	sub    %edx,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	89 c3                	mov    %eax,%ebx
  8008ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008af:	eb 06                	jmp    8008b7 <strncmp+0x17>
		n--, p++, q++;
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b7:	39 d8                	cmp    %ebx,%eax
  8008b9:	74 15                	je     8008d0 <strncmp+0x30>
  8008bb:	0f b6 08             	movzbl (%eax),%ecx
  8008be:	84 c9                	test   %cl,%cl
  8008c0:	74 04                	je     8008c6 <strncmp+0x26>
  8008c2:	3a 0a                	cmp    (%edx),%cl
  8008c4:	74 eb                	je     8008b1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 00             	movzbl (%eax),%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
  8008ce:	eb 05                	jmp    8008d5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e2:	eb 07                	jmp    8008eb <strchr+0x13>
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	74 0f                	je     8008f7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e8:	83 c0 01             	add    $0x1,%eax
  8008eb:	0f b6 10             	movzbl (%eax),%edx
  8008ee:	84 d2                	test   %dl,%dl
  8008f0:	75 f2                	jne    8008e4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	eb 03                	jmp    800908 <strfind+0xf>
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	74 04                	je     800913 <strfind+0x1a>
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f2                	jne    800905 <strfind+0xc>
			break;
	return (char *) s;
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800921:	85 c9                	test   %ecx,%ecx
  800923:	74 36                	je     80095b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 28                	jne    800955 <memset+0x40>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 23                	jne    800955 <memset+0x40>
		c &= 0xFF;
  800932:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800936:	89 d3                	mov    %edx,%ebx
  800938:	c1 e3 08             	shl    $0x8,%ebx
  80093b:	89 d6                	mov    %edx,%esi
  80093d:	c1 e6 18             	shl    $0x18,%esi
  800940:	89 d0                	mov    %edx,%eax
  800942:	c1 e0 10             	shl    $0x10,%eax
  800945:	09 f0                	or     %esi,%eax
  800947:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800949:	89 d8                	mov    %ebx,%eax
  80094b:	09 d0                	or     %edx,%eax
  80094d:	c1 e9 02             	shr    $0x2,%ecx
  800950:	fc                   	cld    
  800951:	f3 ab                	rep stos %eax,%es:(%edi)
  800953:	eb 06                	jmp    80095b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
  800958:	fc                   	cld    
  800959:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095b:	89 f8                	mov    %edi,%eax
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800970:	39 c6                	cmp    %eax,%esi
  800972:	73 35                	jae    8009a9 <memmove+0x47>
  800974:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800977:	39 d0                	cmp    %edx,%eax
  800979:	73 2e                	jae    8009a9 <memmove+0x47>
		s += n;
		d += n;
  80097b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097e:	89 d6                	mov    %edx,%esi
  800980:	09 fe                	or     %edi,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	75 13                	jne    80099d <memmove+0x3b>
  80098a:	f6 c1 03             	test   $0x3,%cl
  80098d:	75 0e                	jne    80099d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80098f:	83 ef 04             	sub    $0x4,%edi
  800992:	8d 72 fc             	lea    -0x4(%edx),%esi
  800995:	c1 e9 02             	shr    $0x2,%ecx
  800998:	fd                   	std    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 09                	jmp    8009a6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099d:	83 ef 01             	sub    $0x1,%edi
  8009a0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a3:	fd                   	std    
  8009a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a6:	fc                   	cld    
  8009a7:	eb 1d                	jmp    8009c6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a9:	89 f2                	mov    %esi,%edx
  8009ab:	09 c2                	or     %eax,%edx
  8009ad:	f6 c2 03             	test   $0x3,%dl
  8009b0:	75 0f                	jne    8009c1 <memmove+0x5f>
  8009b2:	f6 c1 03             	test   $0x3,%cl
  8009b5:	75 0a                	jne    8009c1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  8009ba:	89 c7                	mov    %eax,%edi
  8009bc:	fc                   	cld    
  8009bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bf:	eb 05                	jmp    8009c6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009cd:	ff 75 10             	pushl  0x10(%ebp)
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	ff 75 08             	pushl  0x8(%ebp)
  8009d6:	e8 87 ff ff ff       	call   800962 <memmove>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e8:	89 c6                	mov    %eax,%esi
  8009ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ed:	eb 1a                	jmp    800a09 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ef:	0f b6 08             	movzbl (%eax),%ecx
  8009f2:	0f b6 1a             	movzbl (%edx),%ebx
  8009f5:	38 d9                	cmp    %bl,%cl
  8009f7:	74 0a                	je     800a03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f9:	0f b6 c1             	movzbl %cl,%eax
  8009fc:	0f b6 db             	movzbl %bl,%ebx
  8009ff:	29 d8                	sub    %ebx,%eax
  800a01:	eb 0f                	jmp    800a12 <memcmp+0x35>
		s1++, s2++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a09:	39 f0                	cmp    %esi,%eax
  800a0b:	75 e2                	jne    8009ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a1d:	89 c1                	mov    %eax,%ecx
  800a1f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a22:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a26:	eb 0a                	jmp    800a32 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a28:	0f b6 10             	movzbl (%eax),%edx
  800a2b:	39 da                	cmp    %ebx,%edx
  800a2d:	74 07                	je     800a36 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2f:	83 c0 01             	add    $0x1,%eax
  800a32:	39 c8                	cmp    %ecx,%eax
  800a34:	72 f2                	jb     800a28 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a36:	5b                   	pop    %ebx
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a45:	eb 03                	jmp    800a4a <strtol+0x11>
		s++;
  800a47:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4a:	0f b6 01             	movzbl (%ecx),%eax
  800a4d:	3c 20                	cmp    $0x20,%al
  800a4f:	74 f6                	je     800a47 <strtol+0xe>
  800a51:	3c 09                	cmp    $0x9,%al
  800a53:	74 f2                	je     800a47 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a55:	3c 2b                	cmp    $0x2b,%al
  800a57:	75 0a                	jne    800a63 <strtol+0x2a>
		s++;
  800a59:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a61:	eb 11                	jmp    800a74 <strtol+0x3b>
  800a63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a68:	3c 2d                	cmp    $0x2d,%al
  800a6a:	75 08                	jne    800a74 <strtol+0x3b>
		s++, neg = 1;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7a:	75 15                	jne    800a91 <strtol+0x58>
  800a7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7f:	75 10                	jne    800a91 <strtol+0x58>
  800a81:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a85:	75 7c                	jne    800b03 <strtol+0xca>
		s += 2, base = 16;
  800a87:	83 c1 02             	add    $0x2,%ecx
  800a8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8f:	eb 16                	jmp    800aa7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a91:	85 db                	test   %ebx,%ebx
  800a93:	75 12                	jne    800aa7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a95:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9d:	75 08                	jne    800aa7 <strtol+0x6e>
		s++, base = 8;
  800a9f:	83 c1 01             	add    $0x1,%ecx
  800aa2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aaf:	0f b6 11             	movzbl (%ecx),%edx
  800ab2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 09             	cmp    $0x9,%bl
  800aba:	77 08                	ja     800ac4 <strtol+0x8b>
			dig = *s - '0';
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 30             	sub    $0x30,%edx
  800ac2:	eb 22                	jmp    800ae6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	80 fb 19             	cmp    $0x19,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ace:	0f be d2             	movsbl %dl,%edx
  800ad1:	83 ea 57             	sub    $0x57,%edx
  800ad4:	eb 10                	jmp    800ae6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 19             	cmp    $0x19,%bl
  800ade:	77 16                	ja     800af6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae0:	0f be d2             	movsbl %dl,%edx
  800ae3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae9:	7d 0b                	jge    800af6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af4:	eb b9                	jmp    800aaf <strtol+0x76>

	if (endptr)
  800af6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afa:	74 0d                	je     800b09 <strtol+0xd0>
		*endptr = (char *) s;
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	89 0e                	mov    %ecx,(%esi)
  800b01:	eb 06                	jmp    800b09 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b03:	85 db                	test   %ebx,%ebx
  800b05:	74 98                	je     800a9f <strtol+0x66>
  800b07:	eb 9e                	jmp    800aa7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b09:	89 c2                	mov    %eax,%edx
  800b0b:	f7 da                	neg    %edx
  800b0d:	85 ff                	test   %edi,%edi
  800b0f:	0f 45 c2             	cmovne %edx,%eax
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	89 c7                	mov    %eax,%edi
  800b2c:	89 c6                	mov    %eax,%esi
  800b2e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b40:	b8 01 00 00 00       	mov    $0x1,%eax
  800b45:	89 d1                	mov    %edx,%ecx
  800b47:	89 d3                	mov    %edx,%ebx
  800b49:	89 d7                	mov    %edx,%edi
  800b4b:	89 d6                	mov    %edx,%esi
  800b4d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b62:	b8 03 00 00 00       	mov    $0x3,%eax
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	89 cb                	mov    %ecx,%ebx
  800b6c:	89 cf                	mov    %ecx,%edi
  800b6e:	89 ce                	mov    %ecx,%esi
  800b70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b72:	85 c0                	test   %eax,%eax
  800b74:	7e 17                	jle    800b8d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b76:	83 ec 0c             	sub    $0xc,%esp
  800b79:	50                   	push   %eax
  800b7a:	6a 03                	push   $0x3
  800b7c:	68 bf 22 80 00       	push   $0x8022bf
  800b81:	6a 23                	push   $0x23
  800b83:	68 dc 22 80 00       	push   $0x8022dc
  800b88:	e8 e5 f5 ff ff       	call   800172 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba5:	89 d1                	mov    %edx,%ecx
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_yield>:

void
sys_yield(void)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc4:	89 d1                	mov    %edx,%ecx
  800bc6:	89 d3                	mov    %edx,%ebx
  800bc8:	89 d7                	mov    %edx,%edi
  800bca:	89 d6                	mov    %edx,%esi
  800bcc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800bdc:	be 00 00 00 00       	mov    $0x0,%esi
  800be1:	b8 04 00 00 00       	mov    $0x4,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bef:	89 f7                	mov    %esi,%edi
  800bf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 17                	jle    800c0e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	50                   	push   %eax
  800bfb:	6a 04                	push   $0x4
  800bfd:	68 bf 22 80 00       	push   $0x8022bf
  800c02:	6a 23                	push   $0x23
  800c04:	68 dc 22 80 00       	push   $0x8022dc
  800c09:	e8 64 f5 ff ff       	call   800172 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c30:	8b 75 18             	mov    0x18(%ebp),%esi
  800c33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7e 17                	jle    800c50 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	50                   	push   %eax
  800c3d:	6a 05                	push   $0x5
  800c3f:	68 bf 22 80 00       	push   $0x8022bf
  800c44:	6a 23                	push   $0x23
  800c46:	68 dc 22 80 00       	push   $0x8022dc
  800c4b:	e8 22 f5 ff ff       	call   800172 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c66:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 df                	mov    %ebx,%edi
  800c73:	89 de                	mov    %ebx,%esi
  800c75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7e 17                	jle    800c92 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	50                   	push   %eax
  800c7f:	6a 06                	push   $0x6
  800c81:	68 bf 22 80 00       	push   $0x8022bf
  800c86:	6a 23                	push   $0x23
  800c88:	68 dc 22 80 00       	push   $0x8022dc
  800c8d:	e8 e0 f4 ff ff       	call   800172 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 17                	jle    800cd4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 08                	push   $0x8
  800cc3:	68 bf 22 80 00       	push   $0x8022bf
  800cc8:	6a 23                	push   $0x23
  800cca:	68 dc 22 80 00       	push   $0x8022dc
  800ccf:	e8 9e f4 ff ff       	call   800172 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cea:	b8 09 00 00 00       	mov    $0x9,%eax
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	89 de                	mov    %ebx,%esi
  800cf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 17                	jle    800d16 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 09                	push   $0x9
  800d05:	68 bf 22 80 00       	push   $0x8022bf
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 dc 22 80 00       	push   $0x8022dc
  800d11:	e8 5c f4 ff ff       	call   800172 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 df                	mov    %ebx,%edi
  800d39:	89 de                	mov    %ebx,%esi
  800d3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7e 17                	jle    800d58 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 0a                	push   $0xa
  800d47:	68 bf 22 80 00       	push   $0x8022bf
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 dc 22 80 00       	push   $0x8022dc
  800d53:	e8 1a f4 ff ff       	call   800172 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	be 00 00 00 00       	mov    $0x0,%esi
  800d6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	89 cb                	mov    %ecx,%ebx
  800d9b:	89 cf                	mov    %ecx,%edi
  800d9d:	89 ce                	mov    %ecx,%esi
  800d9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 0d                	push   $0xd
  800dab:	68 bf 22 80 00       	push   $0x8022bf
  800db0:	6a 23                	push   $0x23
  800db2:	68 dc 22 80 00       	push   $0x8022dc
  800db7:	e8 b6 f3 ff ff       	call   800172 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dca:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dd1:	75 2a                	jne    800dfd <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800dd3:	83 ec 04             	sub    $0x4,%esp
  800dd6:	6a 07                	push   $0x7
  800dd8:	68 00 f0 bf ee       	push   $0xeebff000
  800ddd:	6a 00                	push   $0x0
  800ddf:	e8 ef fd ff ff       	call   800bd3 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800de4:	83 c4 10             	add    $0x10,%esp
  800de7:	85 c0                	test   %eax,%eax
  800de9:	79 12                	jns    800dfd <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800deb:	50                   	push   %eax
  800dec:	68 ea 22 80 00       	push   $0x8022ea
  800df1:	6a 23                	push   $0x23
  800df3:	68 ee 22 80 00       	push   $0x8022ee
  800df8:	e8 75 f3 ff ff       	call   800172 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e05:	83 ec 08             	sub    $0x8,%esp
  800e08:	68 2f 0e 80 00       	push   $0x800e2f
  800e0d:	6a 00                	push   $0x0
  800e0f:	e8 0a ff ff ff       	call   800d1e <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	85 c0                	test   %eax,%eax
  800e19:	79 12                	jns    800e2d <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e1b:	50                   	push   %eax
  800e1c:	68 ea 22 80 00       	push   $0x8022ea
  800e21:	6a 2c                	push   $0x2c
  800e23:	68 ee 22 80 00       	push   $0x8022ee
  800e28:	e8 45 f3 ff ff       	call   800172 <_panic>
	}
}
  800e2d:	c9                   	leave  
  800e2e:	c3                   	ret    

00800e2f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e2f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e30:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e35:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e37:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e3a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e3e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e43:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e47:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e49:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e4c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e4d:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e50:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e51:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e52:	c3                   	ret    

00800e53 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
  800e59:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
  800e69:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e73:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e80:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e85:	89 c2                	mov    %eax,%edx
  800e87:	c1 ea 16             	shr    $0x16,%edx
  800e8a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e91:	f6 c2 01             	test   $0x1,%dl
  800e94:	74 11                	je     800ea7 <fd_alloc+0x2d>
  800e96:	89 c2                	mov    %eax,%edx
  800e98:	c1 ea 0c             	shr    $0xc,%edx
  800e9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea2:	f6 c2 01             	test   $0x1,%dl
  800ea5:	75 09                	jne    800eb0 <fd_alloc+0x36>
			*fd_store = fd;
  800ea7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	eb 17                	jmp    800ec7 <fd_alloc+0x4d>
  800eb0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eba:	75 c9                	jne    800e85 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ebc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ec2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ecf:	83 f8 1f             	cmp    $0x1f,%eax
  800ed2:	77 36                	ja     800f0a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed4:	c1 e0 0c             	shl    $0xc,%eax
  800ed7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800edc:	89 c2                	mov    %eax,%edx
  800ede:	c1 ea 16             	shr    $0x16,%edx
  800ee1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee8:	f6 c2 01             	test   $0x1,%dl
  800eeb:	74 24                	je     800f11 <fd_lookup+0x48>
  800eed:	89 c2                	mov    %eax,%edx
  800eef:	c1 ea 0c             	shr    $0xc,%edx
  800ef2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef9:	f6 c2 01             	test   $0x1,%dl
  800efc:	74 1a                	je     800f18 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800efe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f01:	89 02                	mov    %eax,(%edx)
	return 0;
  800f03:	b8 00 00 00 00       	mov    $0x0,%eax
  800f08:	eb 13                	jmp    800f1d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0f:	eb 0c                	jmp    800f1d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f16:	eb 05                	jmp    800f1d <fd_lookup+0x54>
  800f18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 08             	sub    $0x8,%esp
  800f25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f28:	ba 7c 23 80 00       	mov    $0x80237c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f2d:	eb 13                	jmp    800f42 <dev_lookup+0x23>
  800f2f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f32:	39 08                	cmp    %ecx,(%eax)
  800f34:	75 0c                	jne    800f42 <dev_lookup+0x23>
			*dev = devtab[i];
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f40:	eb 2e                	jmp    800f70 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f42:	8b 02                	mov    (%edx),%eax
  800f44:	85 c0                	test   %eax,%eax
  800f46:	75 e7                	jne    800f2f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f48:	a1 04 40 80 00       	mov    0x804004,%eax
  800f4d:	8b 40 48             	mov    0x48(%eax),%eax
  800f50:	83 ec 04             	sub    $0x4,%esp
  800f53:	51                   	push   %ecx
  800f54:	50                   	push   %eax
  800f55:	68 fc 22 80 00       	push   $0x8022fc
  800f5a:	e8 ec f2 ff ff       	call   80024b <cprintf>
	*dev = 0;
  800f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f62:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 10             	sub    $0x10,%esp
  800f7a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f8a:	c1 e8 0c             	shr    $0xc,%eax
  800f8d:	50                   	push   %eax
  800f8e:	e8 36 ff ff ff       	call   800ec9 <fd_lookup>
  800f93:	83 c4 08             	add    $0x8,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 05                	js     800f9f <fd_close+0x2d>
	    || fd != fd2)
  800f9a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f9d:	74 0c                	je     800fab <fd_close+0x39>
		return (must_exist ? r : 0);
  800f9f:	84 db                	test   %bl,%bl
  800fa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa6:	0f 44 c2             	cmove  %edx,%eax
  800fa9:	eb 41                	jmp    800fec <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb1:	50                   	push   %eax
  800fb2:	ff 36                	pushl  (%esi)
  800fb4:	e8 66 ff ff ff       	call   800f1f <dev_lookup>
  800fb9:	89 c3                	mov    %eax,%ebx
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 1a                	js     800fdc <fd_close+0x6a>
		if (dev->dev_close)
  800fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fc8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	74 0b                	je     800fdc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	56                   	push   %esi
  800fd5:	ff d0                	call   *%eax
  800fd7:	89 c3                	mov    %eax,%ebx
  800fd9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fdc:	83 ec 08             	sub    $0x8,%esp
  800fdf:	56                   	push   %esi
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 71 fc ff ff       	call   800c58 <sys_page_unmap>
	return r;
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	89 d8                	mov    %ebx,%eax
}
  800fec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	ff 75 08             	pushl  0x8(%ebp)
  801000:	e8 c4 fe ff ff       	call   800ec9 <fd_lookup>
  801005:	83 c4 08             	add    $0x8,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 10                	js     80101c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	6a 01                	push   $0x1
  801011:	ff 75 f4             	pushl  -0xc(%ebp)
  801014:	e8 59 ff ff ff       	call   800f72 <fd_close>
  801019:	83 c4 10             	add    $0x10,%esp
}
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <close_all>:

void
close_all(void)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	53                   	push   %ebx
  801022:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801025:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80102a:	83 ec 0c             	sub    $0xc,%esp
  80102d:	53                   	push   %ebx
  80102e:	e8 c0 ff ff ff       	call   800ff3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801033:	83 c3 01             	add    $0x1,%ebx
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	83 fb 20             	cmp    $0x20,%ebx
  80103c:	75 ec                	jne    80102a <close_all+0xc>
		close(i);
}
  80103e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	83 ec 2c             	sub    $0x2c,%esp
  80104c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80104f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801052:	50                   	push   %eax
  801053:	ff 75 08             	pushl  0x8(%ebp)
  801056:	e8 6e fe ff ff       	call   800ec9 <fd_lookup>
  80105b:	83 c4 08             	add    $0x8,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	0f 88 c1 00 00 00    	js     801127 <dup+0xe4>
		return r;
	close(newfdnum);
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	56                   	push   %esi
  80106a:	e8 84 ff ff ff       	call   800ff3 <close>

	newfd = INDEX2FD(newfdnum);
  80106f:	89 f3                	mov    %esi,%ebx
  801071:	c1 e3 0c             	shl    $0xc,%ebx
  801074:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80107a:	83 c4 04             	add    $0x4,%esp
  80107d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801080:	e8 de fd ff ff       	call   800e63 <fd2data>
  801085:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801087:	89 1c 24             	mov    %ebx,(%esp)
  80108a:	e8 d4 fd ff ff       	call   800e63 <fd2data>
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801095:	89 f8                	mov    %edi,%eax
  801097:	c1 e8 16             	shr    $0x16,%eax
  80109a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a1:	a8 01                	test   $0x1,%al
  8010a3:	74 37                	je     8010dc <dup+0x99>
  8010a5:	89 f8                	mov    %edi,%eax
  8010a7:	c1 e8 0c             	shr    $0xc,%eax
  8010aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b1:	f6 c2 01             	test   $0x1,%dl
  8010b4:	74 26                	je     8010dc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c5:	50                   	push   %eax
  8010c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c9:	6a 00                	push   $0x0
  8010cb:	57                   	push   %edi
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 43 fb ff ff       	call   800c16 <sys_page_map>
  8010d3:	89 c7                	mov    %eax,%edi
  8010d5:	83 c4 20             	add    $0x20,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 2e                	js     80110a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010df:	89 d0                	mov    %edx,%eax
  8010e1:	c1 e8 0c             	shr    $0xc,%eax
  8010e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f3:	50                   	push   %eax
  8010f4:	53                   	push   %ebx
  8010f5:	6a 00                	push   $0x0
  8010f7:	52                   	push   %edx
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 17 fb ff ff       	call   800c16 <sys_page_map>
  8010ff:	89 c7                	mov    %eax,%edi
  801101:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801104:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801106:	85 ff                	test   %edi,%edi
  801108:	79 1d                	jns    801127 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	53                   	push   %ebx
  80110e:	6a 00                	push   $0x0
  801110:	e8 43 fb ff ff       	call   800c58 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801115:	83 c4 08             	add    $0x8,%esp
  801118:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111b:	6a 00                	push   $0x0
  80111d:	e8 36 fb ff ff       	call   800c58 <sys_page_unmap>
	return r;
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	89 f8                	mov    %edi,%eax
}
  801127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	53                   	push   %ebx
  801133:	83 ec 14             	sub    $0x14,%esp
  801136:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801139:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	53                   	push   %ebx
  80113e:	e8 86 fd ff ff       	call   800ec9 <fd_lookup>
  801143:	83 c4 08             	add    $0x8,%esp
  801146:	89 c2                	mov    %eax,%edx
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 6d                	js     8011b9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801152:	50                   	push   %eax
  801153:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801156:	ff 30                	pushl  (%eax)
  801158:	e8 c2 fd ff ff       	call   800f1f <dev_lookup>
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	85 c0                	test   %eax,%eax
  801162:	78 4c                	js     8011b0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801164:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801167:	8b 42 08             	mov    0x8(%edx),%eax
  80116a:	83 e0 03             	and    $0x3,%eax
  80116d:	83 f8 01             	cmp    $0x1,%eax
  801170:	75 21                	jne    801193 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801172:	a1 04 40 80 00       	mov    0x804004,%eax
  801177:	8b 40 48             	mov    0x48(%eax),%eax
  80117a:	83 ec 04             	sub    $0x4,%esp
  80117d:	53                   	push   %ebx
  80117e:	50                   	push   %eax
  80117f:	68 40 23 80 00       	push   $0x802340
  801184:	e8 c2 f0 ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801191:	eb 26                	jmp    8011b9 <read+0x8a>
	}
	if (!dev->dev_read)
  801193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801196:	8b 40 08             	mov    0x8(%eax),%eax
  801199:	85 c0                	test   %eax,%eax
  80119b:	74 17                	je     8011b4 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	ff 75 10             	pushl  0x10(%ebp)
  8011a3:	ff 75 0c             	pushl  0xc(%ebp)
  8011a6:	52                   	push   %edx
  8011a7:	ff d0                	call   *%eax
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	eb 09                	jmp    8011b9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	eb 05                	jmp    8011b9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8011b9:	89 d0                	mov    %edx,%eax
  8011bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	57                   	push   %edi
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d4:	eb 21                	jmp    8011f7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	89 f0                	mov    %esi,%eax
  8011db:	29 d8                	sub    %ebx,%eax
  8011dd:	50                   	push   %eax
  8011de:	89 d8                	mov    %ebx,%eax
  8011e0:	03 45 0c             	add    0xc(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	57                   	push   %edi
  8011e5:	e8 45 ff ff ff       	call   80112f <read>
		if (m < 0)
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 10                	js     801201 <readn+0x41>
			return m;
		if (m == 0)
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	74 0a                	je     8011ff <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f5:	01 c3                	add    %eax,%ebx
  8011f7:	39 f3                	cmp    %esi,%ebx
  8011f9:	72 db                	jb     8011d6 <readn+0x16>
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	eb 02                	jmp    801201 <readn+0x41>
  8011ff:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5f                   	pop    %edi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	53                   	push   %ebx
  80120d:	83 ec 14             	sub    $0x14,%esp
  801210:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801213:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	53                   	push   %ebx
  801218:	e8 ac fc ff ff       	call   800ec9 <fd_lookup>
  80121d:	83 c4 08             	add    $0x8,%esp
  801220:	89 c2                	mov    %eax,%edx
  801222:	85 c0                	test   %eax,%eax
  801224:	78 68                	js     80128e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801230:	ff 30                	pushl  (%eax)
  801232:	e8 e8 fc ff ff       	call   800f1f <dev_lookup>
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 47                	js     801285 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801245:	75 21                	jne    801268 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801247:	a1 04 40 80 00       	mov    0x804004,%eax
  80124c:	8b 40 48             	mov    0x48(%eax),%eax
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	53                   	push   %ebx
  801253:	50                   	push   %eax
  801254:	68 5c 23 80 00       	push   $0x80235c
  801259:	e8 ed ef ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801266:	eb 26                	jmp    80128e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801268:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126b:	8b 52 0c             	mov    0xc(%edx),%edx
  80126e:	85 d2                	test   %edx,%edx
  801270:	74 17                	je     801289 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	ff 75 10             	pushl  0x10(%ebp)
  801278:	ff 75 0c             	pushl  0xc(%ebp)
  80127b:	50                   	push   %eax
  80127c:	ff d2                	call   *%edx
  80127e:	89 c2                	mov    %eax,%edx
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	eb 09                	jmp    80128e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801285:	89 c2                	mov    %eax,%edx
  801287:	eb 05                	jmp    80128e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801289:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80128e:	89 d0                	mov    %edx,%eax
  801290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <seek>:

int
seek(int fdnum, off_t offset)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129e:	50                   	push   %eax
  80129f:	ff 75 08             	pushl  0x8(%ebp)
  8012a2:	e8 22 fc ff ff       	call   800ec9 <fd_lookup>
  8012a7:	83 c4 08             	add    $0x8,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 0e                	js     8012bc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 14             	sub    $0x14,%esp
  8012c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	53                   	push   %ebx
  8012cd:	e8 f7 fb ff ff       	call   800ec9 <fd_lookup>
  8012d2:	83 c4 08             	add    $0x8,%esp
  8012d5:	89 c2                	mov    %eax,%edx
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 65                	js     801340 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e5:	ff 30                	pushl  (%eax)
  8012e7:	e8 33 fc ff ff       	call   800f1f <dev_lookup>
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 44                	js     801337 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fa:	75 21                	jne    80131d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801301:	8b 40 48             	mov    0x48(%eax),%eax
  801304:	83 ec 04             	sub    $0x4,%esp
  801307:	53                   	push   %ebx
  801308:	50                   	push   %eax
  801309:	68 1c 23 80 00       	push   $0x80231c
  80130e:	e8 38 ef ff ff       	call   80024b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80131b:	eb 23                	jmp    801340 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80131d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801320:	8b 52 18             	mov    0x18(%edx),%edx
  801323:	85 d2                	test   %edx,%edx
  801325:	74 14                	je     80133b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	ff 75 0c             	pushl  0xc(%ebp)
  80132d:	50                   	push   %eax
  80132e:	ff d2                	call   *%edx
  801330:	89 c2                	mov    %eax,%edx
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	eb 09                	jmp    801340 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801337:	89 c2                	mov    %eax,%edx
  801339:	eb 05                	jmp    801340 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80133b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801340:	89 d0                	mov    %edx,%eax
  801342:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801345:	c9                   	leave  
  801346:	c3                   	ret    

00801347 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	53                   	push   %ebx
  80134b:	83 ec 14             	sub    $0x14,%esp
  80134e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801351:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	ff 75 08             	pushl  0x8(%ebp)
  801358:	e8 6c fb ff ff       	call   800ec9 <fd_lookup>
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	89 c2                	mov    %eax,%edx
  801362:	85 c0                	test   %eax,%eax
  801364:	78 58                	js     8013be <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801370:	ff 30                	pushl  (%eax)
  801372:	e8 a8 fb ff ff       	call   800f1f <dev_lookup>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 37                	js     8013b5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80137e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801381:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801385:	74 32                	je     8013b9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801387:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80138a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801391:	00 00 00 
	stat->st_isdir = 0;
  801394:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80139b:	00 00 00 
	stat->st_dev = dev;
  80139e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	53                   	push   %ebx
  8013a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ab:	ff 50 14             	call   *0x14(%eax)
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	eb 09                	jmp    8013be <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b5:	89 c2                	mov    %eax,%edx
  8013b7:	eb 05                	jmp    8013be <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013be:	89 d0                	mov    %edx,%eax
  8013c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	6a 00                	push   $0x0
  8013cf:	ff 75 08             	pushl  0x8(%ebp)
  8013d2:	e8 e3 01 00 00       	call   8015ba <open>
  8013d7:	89 c3                	mov    %eax,%ebx
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	78 1b                	js     8013fb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	ff 75 0c             	pushl  0xc(%ebp)
  8013e6:	50                   	push   %eax
  8013e7:	e8 5b ff ff ff       	call   801347 <fstat>
  8013ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ee:	89 1c 24             	mov    %ebx,(%esp)
  8013f1:	e8 fd fb ff ff       	call   800ff3 <close>
	return r;
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	89 f0                	mov    %esi,%eax
}
  8013fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fe:	5b                   	pop    %ebx
  8013ff:	5e                   	pop    %esi
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
  801407:	89 c6                	mov    %eax,%esi
  801409:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80140b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801412:	75 12                	jne    801426 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	6a 01                	push   $0x1
  801419:	e8 f3 07 00 00       	call   801c11 <ipc_find_env>
  80141e:	a3 00 40 80 00       	mov    %eax,0x804000
  801423:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801426:	6a 07                	push   $0x7
  801428:	68 00 50 80 00       	push   $0x805000
  80142d:	56                   	push   %esi
  80142e:	ff 35 00 40 80 00    	pushl  0x804000
  801434:	e8 76 07 00 00       	call   801baf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801439:	83 c4 0c             	add    $0xc,%esp
  80143c:	6a 00                	push   $0x0
  80143e:	53                   	push   %ebx
  80143f:	6a 00                	push   $0x0
  801441:	e8 f7 06 00 00       	call   801b3d <ipc_recv>
}
  801446:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    

0080144d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	8b 40 0c             	mov    0xc(%eax),%eax
  801459:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80145e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801461:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801466:	ba 00 00 00 00       	mov    $0x0,%edx
  80146b:	b8 02 00 00 00       	mov    $0x2,%eax
  801470:	e8 8d ff ff ff       	call   801402 <fsipc>
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80147d:	8b 45 08             	mov    0x8(%ebp),%eax
  801480:	8b 40 0c             	mov    0xc(%eax),%eax
  801483:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801488:	ba 00 00 00 00       	mov    $0x0,%edx
  80148d:	b8 06 00 00 00       	mov    $0x6,%eax
  801492:	e8 6b ff ff ff       	call   801402 <fsipc>
}
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	53                   	push   %ebx
  80149d:	83 ec 04             	sub    $0x4,%esp
  8014a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b3:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b8:	e8 45 ff ff ff       	call   801402 <fsipc>
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 2c                	js     8014ed <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	68 00 50 80 00       	push   $0x805000
  8014c9:	53                   	push   %ebx
  8014ca:	e8 01 f3 ff ff       	call   8007d0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014cf:	a1 80 50 80 00       	mov    0x805080,%eax
  8014d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014da:	a1 84 50 80 00       	mov    0x805084,%eax
  8014df:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fe:	8b 52 0c             	mov    0xc(%edx),%edx
  801501:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801507:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80150c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801511:	0f 47 c2             	cmova  %edx,%eax
  801514:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801519:	50                   	push   %eax
  80151a:	ff 75 0c             	pushl  0xc(%ebp)
  80151d:	68 08 50 80 00       	push   $0x805008
  801522:	e8 3b f4 ff ff       	call   800962 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801527:	ba 00 00 00 00       	mov    $0x0,%edx
  80152c:	b8 04 00 00 00       	mov    $0x4,%eax
  801531:	e8 cc fe ff ff       	call   801402 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801536:	c9                   	leave  
  801537:	c3                   	ret    

00801538 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	56                   	push   %esi
  80153c:	53                   	push   %ebx
  80153d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801540:	8b 45 08             	mov    0x8(%ebp),%eax
  801543:	8b 40 0c             	mov    0xc(%eax),%eax
  801546:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80154b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801551:	ba 00 00 00 00       	mov    $0x0,%edx
  801556:	b8 03 00 00 00       	mov    $0x3,%eax
  80155b:	e8 a2 fe ff ff       	call   801402 <fsipc>
  801560:	89 c3                	mov    %eax,%ebx
  801562:	85 c0                	test   %eax,%eax
  801564:	78 4b                	js     8015b1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801566:	39 c6                	cmp    %eax,%esi
  801568:	73 16                	jae    801580 <devfile_read+0x48>
  80156a:	68 8c 23 80 00       	push   $0x80238c
  80156f:	68 93 23 80 00       	push   $0x802393
  801574:	6a 7c                	push   $0x7c
  801576:	68 a8 23 80 00       	push   $0x8023a8
  80157b:	e8 f2 eb ff ff       	call   800172 <_panic>
	assert(r <= PGSIZE);
  801580:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801585:	7e 16                	jle    80159d <devfile_read+0x65>
  801587:	68 b3 23 80 00       	push   $0x8023b3
  80158c:	68 93 23 80 00       	push   $0x802393
  801591:	6a 7d                	push   $0x7d
  801593:	68 a8 23 80 00       	push   $0x8023a8
  801598:	e8 d5 eb ff ff       	call   800172 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	50                   	push   %eax
  8015a1:	68 00 50 80 00       	push   $0x805000
  8015a6:	ff 75 0c             	pushl  0xc(%ebp)
  8015a9:	e8 b4 f3 ff ff       	call   800962 <memmove>
	return r;
  8015ae:	83 c4 10             	add    $0x10,%esp
}
  8015b1:	89 d8                	mov    %ebx,%eax
  8015b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b6:	5b                   	pop    %ebx
  8015b7:	5e                   	pop    %esi
  8015b8:	5d                   	pop    %ebp
  8015b9:	c3                   	ret    

008015ba <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 20             	sub    $0x20,%esp
  8015c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c4:	53                   	push   %ebx
  8015c5:	e8 cd f1 ff ff       	call   800797 <strlen>
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d2:	7f 67                	jg     80163b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	e8 9a f8 ff ff       	call   800e7a <fd_alloc>
  8015e0:	83 c4 10             	add    $0x10,%esp
		return r;
  8015e3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 57                	js     801640 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	53                   	push   %ebx
  8015ed:	68 00 50 80 00       	push   $0x805000
  8015f2:	e8 d9 f1 ff ff       	call   8007d0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fa:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801602:	b8 01 00 00 00       	mov    $0x1,%eax
  801607:	e8 f6 fd ff ff       	call   801402 <fsipc>
  80160c:	89 c3                	mov    %eax,%ebx
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	79 14                	jns    801629 <open+0x6f>
		fd_close(fd, 0);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	6a 00                	push   $0x0
  80161a:	ff 75 f4             	pushl  -0xc(%ebp)
  80161d:	e8 50 f9 ff ff       	call   800f72 <fd_close>
		return r;
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	89 da                	mov    %ebx,%edx
  801627:	eb 17                	jmp    801640 <open+0x86>
	}

	return fd2num(fd);
  801629:	83 ec 0c             	sub    $0xc,%esp
  80162c:	ff 75 f4             	pushl  -0xc(%ebp)
  80162f:	e8 1f f8 ff ff       	call   800e53 <fd2num>
  801634:	89 c2                	mov    %eax,%edx
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	eb 05                	jmp    801640 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80163b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801640:	89 d0                	mov    %edx,%eax
  801642:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80164d:	ba 00 00 00 00       	mov    $0x0,%edx
  801652:	b8 08 00 00 00       	mov    $0x8,%eax
  801657:	e8 a6 fd ff ff       	call   801402 <fsipc>
}
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	56                   	push   %esi
  801662:	53                   	push   %ebx
  801663:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	e8 f2 f7 ff ff       	call   800e63 <fd2data>
  801671:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801673:	83 c4 08             	add    $0x8,%esp
  801676:	68 bf 23 80 00       	push   $0x8023bf
  80167b:	53                   	push   %ebx
  80167c:	e8 4f f1 ff ff       	call   8007d0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801681:	8b 46 04             	mov    0x4(%esi),%eax
  801684:	2b 06                	sub    (%esi),%eax
  801686:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80168c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801693:	00 00 00 
	stat->st_dev = &devpipe;
  801696:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80169d:	30 80 00 
	return 0;
}
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	53                   	push   %ebx
  8016b0:	83 ec 0c             	sub    $0xc,%esp
  8016b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016b6:	53                   	push   %ebx
  8016b7:	6a 00                	push   $0x0
  8016b9:	e8 9a f5 ff ff       	call   800c58 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016be:	89 1c 24             	mov    %ebx,(%esp)
  8016c1:	e8 9d f7 ff ff       	call   800e63 <fd2data>
  8016c6:	83 c4 08             	add    $0x8,%esp
  8016c9:	50                   	push   %eax
  8016ca:	6a 00                	push   $0x0
  8016cc:	e8 87 f5 ff ff       	call   800c58 <sys_page_unmap>
}
  8016d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d4:	c9                   	leave  
  8016d5:	c3                   	ret    

008016d6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	57                   	push   %edi
  8016da:	56                   	push   %esi
  8016db:	53                   	push   %ebx
  8016dc:	83 ec 1c             	sub    $0x1c,%esp
  8016df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016e2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8016e9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016ec:	83 ec 0c             	sub    $0xc,%esp
  8016ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8016f2:	e8 53 05 00 00       	call   801c4a <pageref>
  8016f7:	89 c3                	mov    %eax,%ebx
  8016f9:	89 3c 24             	mov    %edi,(%esp)
  8016fc:	e8 49 05 00 00       	call   801c4a <pageref>
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	39 c3                	cmp    %eax,%ebx
  801706:	0f 94 c1             	sete   %cl
  801709:	0f b6 c9             	movzbl %cl,%ecx
  80170c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80170f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801715:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801718:	39 ce                	cmp    %ecx,%esi
  80171a:	74 1b                	je     801737 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80171c:	39 c3                	cmp    %eax,%ebx
  80171e:	75 c4                	jne    8016e4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801720:	8b 42 58             	mov    0x58(%edx),%eax
  801723:	ff 75 e4             	pushl  -0x1c(%ebp)
  801726:	50                   	push   %eax
  801727:	56                   	push   %esi
  801728:	68 c6 23 80 00       	push   $0x8023c6
  80172d:	e8 19 eb ff ff       	call   80024b <cprintf>
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	eb ad                	jmp    8016e4 <_pipeisclosed+0xe>
	}
}
  801737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173d:	5b                   	pop    %ebx
  80173e:	5e                   	pop    %esi
  80173f:	5f                   	pop    %edi
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	57                   	push   %edi
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
  801748:	83 ec 28             	sub    $0x28,%esp
  80174b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80174e:	56                   	push   %esi
  80174f:	e8 0f f7 ff ff       	call   800e63 <fd2data>
  801754:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	bf 00 00 00 00       	mov    $0x0,%edi
  80175e:	eb 4b                	jmp    8017ab <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801760:	89 da                	mov    %ebx,%edx
  801762:	89 f0                	mov    %esi,%eax
  801764:	e8 6d ff ff ff       	call   8016d6 <_pipeisclosed>
  801769:	85 c0                	test   %eax,%eax
  80176b:	75 48                	jne    8017b5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80176d:	e8 42 f4 ff ff       	call   800bb4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801772:	8b 43 04             	mov    0x4(%ebx),%eax
  801775:	8b 0b                	mov    (%ebx),%ecx
  801777:	8d 51 20             	lea    0x20(%ecx),%edx
  80177a:	39 d0                	cmp    %edx,%eax
  80177c:	73 e2                	jae    801760 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80177e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801781:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801785:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801788:	89 c2                	mov    %eax,%edx
  80178a:	c1 fa 1f             	sar    $0x1f,%edx
  80178d:	89 d1                	mov    %edx,%ecx
  80178f:	c1 e9 1b             	shr    $0x1b,%ecx
  801792:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801795:	83 e2 1f             	and    $0x1f,%edx
  801798:	29 ca                	sub    %ecx,%edx
  80179a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80179e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017a2:	83 c0 01             	add    $0x1,%eax
  8017a5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a8:	83 c7 01             	add    $0x1,%edi
  8017ab:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017ae:	75 c2                	jne    801772 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b3:	eb 05                	jmp    8017ba <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017b5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017bd:	5b                   	pop    %ebx
  8017be:	5e                   	pop    %esi
  8017bf:	5f                   	pop    %edi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	57                   	push   %edi
  8017c6:	56                   	push   %esi
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 18             	sub    $0x18,%esp
  8017cb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017ce:	57                   	push   %edi
  8017cf:	e8 8f f6 ff ff       	call   800e63 <fd2data>
  8017d4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017de:	eb 3d                	jmp    80181d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017e0:	85 db                	test   %ebx,%ebx
  8017e2:	74 04                	je     8017e8 <devpipe_read+0x26>
				return i;
  8017e4:	89 d8                	mov    %ebx,%eax
  8017e6:	eb 44                	jmp    80182c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017e8:	89 f2                	mov    %esi,%edx
  8017ea:	89 f8                	mov    %edi,%eax
  8017ec:	e8 e5 fe ff ff       	call   8016d6 <_pipeisclosed>
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	75 32                	jne    801827 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017f5:	e8 ba f3 ff ff       	call   800bb4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017fa:	8b 06                	mov    (%esi),%eax
  8017fc:	3b 46 04             	cmp    0x4(%esi),%eax
  8017ff:	74 df                	je     8017e0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801801:	99                   	cltd   
  801802:	c1 ea 1b             	shr    $0x1b,%edx
  801805:	01 d0                	add    %edx,%eax
  801807:	83 e0 1f             	and    $0x1f,%eax
  80180a:	29 d0                	sub    %edx,%eax
  80180c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801814:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801817:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80181a:	83 c3 01             	add    $0x1,%ebx
  80181d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801820:	75 d8                	jne    8017fa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801822:	8b 45 10             	mov    0x10(%ebp),%eax
  801825:	eb 05                	jmp    80182c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80182c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5f                   	pop    %edi
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	56                   	push   %esi
  801838:	53                   	push   %ebx
  801839:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80183c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	e8 35 f6 ff ff       	call   800e7a <fd_alloc>
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	89 c2                	mov    %eax,%edx
  80184a:	85 c0                	test   %eax,%eax
  80184c:	0f 88 2c 01 00 00    	js     80197e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801852:	83 ec 04             	sub    $0x4,%esp
  801855:	68 07 04 00 00       	push   $0x407
  80185a:	ff 75 f4             	pushl  -0xc(%ebp)
  80185d:	6a 00                	push   $0x0
  80185f:	e8 6f f3 ff ff       	call   800bd3 <sys_page_alloc>
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	89 c2                	mov    %eax,%edx
  801869:	85 c0                	test   %eax,%eax
  80186b:	0f 88 0d 01 00 00    	js     80197e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801871:	83 ec 0c             	sub    $0xc,%esp
  801874:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801877:	50                   	push   %eax
  801878:	e8 fd f5 ff ff       	call   800e7a <fd_alloc>
  80187d:	89 c3                	mov    %eax,%ebx
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	85 c0                	test   %eax,%eax
  801884:	0f 88 e2 00 00 00    	js     80196c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	68 07 04 00 00       	push   $0x407
  801892:	ff 75 f0             	pushl  -0x10(%ebp)
  801895:	6a 00                	push   $0x0
  801897:	e8 37 f3 ff ff       	call   800bd3 <sys_page_alloc>
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	0f 88 c3 00 00 00    	js     80196c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8018af:	e8 af f5 ff ff       	call   800e63 <fd2data>
  8018b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b6:	83 c4 0c             	add    $0xc,%esp
  8018b9:	68 07 04 00 00       	push   $0x407
  8018be:	50                   	push   %eax
  8018bf:	6a 00                	push   $0x0
  8018c1:	e8 0d f3 ff ff       	call   800bd3 <sys_page_alloc>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	0f 88 89 00 00 00    	js     80195c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d3:	83 ec 0c             	sub    $0xc,%esp
  8018d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d9:	e8 85 f5 ff ff       	call   800e63 <fd2data>
  8018de:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018e5:	50                   	push   %eax
  8018e6:	6a 00                	push   $0x0
  8018e8:	56                   	push   %esi
  8018e9:	6a 00                	push   $0x0
  8018eb:	e8 26 f3 ff ff       	call   800c16 <sys_page_map>
  8018f0:	89 c3                	mov    %eax,%ebx
  8018f2:	83 c4 20             	add    $0x20,%esp
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 55                	js     80194e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018f9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801902:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801904:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801907:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80190e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801914:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801917:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801919:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 f4             	pushl  -0xc(%ebp)
  801929:	e8 25 f5 ff ff       	call   800e53 <fd2num>
  80192e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801931:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801933:	83 c4 04             	add    $0x4,%esp
  801936:	ff 75 f0             	pushl  -0x10(%ebp)
  801939:	e8 15 f5 ff ff       	call   800e53 <fd2num>
  80193e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801941:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	ba 00 00 00 00       	mov    $0x0,%edx
  80194c:	eb 30                	jmp    80197e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80194e:	83 ec 08             	sub    $0x8,%esp
  801951:	56                   	push   %esi
  801952:	6a 00                	push   $0x0
  801954:	e8 ff f2 ff ff       	call   800c58 <sys_page_unmap>
  801959:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	ff 75 f0             	pushl  -0x10(%ebp)
  801962:	6a 00                	push   $0x0
  801964:	e8 ef f2 ff ff       	call   800c58 <sys_page_unmap>
  801969:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	ff 75 f4             	pushl  -0xc(%ebp)
  801972:	6a 00                	push   $0x0
  801974:	e8 df f2 ff ff       	call   800c58 <sys_page_unmap>
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80197e:	89 d0                	mov    %edx,%eax
  801980:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801983:	5b                   	pop    %ebx
  801984:	5e                   	pop    %esi
  801985:	5d                   	pop    %ebp
  801986:	c3                   	ret    

00801987 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801990:	50                   	push   %eax
  801991:	ff 75 08             	pushl  0x8(%ebp)
  801994:	e8 30 f5 ff ff       	call   800ec9 <fd_lookup>
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 18                	js     8019b8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a6:	e8 b8 f4 ff ff       	call   800e63 <fd2data>
	return _pipeisclosed(fd, p);
  8019ab:	89 c2                	mov    %eax,%edx
  8019ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b0:	e8 21 fd ff ff       	call   8016d6 <_pipeisclosed>
  8019b5:	83 c4 10             	add    $0x10,%esp
}
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019ca:	68 de 23 80 00       	push   $0x8023de
  8019cf:	ff 75 0c             	pushl  0xc(%ebp)
  8019d2:	e8 f9 ed ff ff       	call   8007d0 <strcpy>
	return 0;
}
  8019d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	57                   	push   %edi
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ea:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f5:	eb 2d                	jmp    801a24 <devcons_write+0x46>
		m = n - tot;
  8019f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019fa:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019fc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019ff:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a04:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a07:	83 ec 04             	sub    $0x4,%esp
  801a0a:	53                   	push   %ebx
  801a0b:	03 45 0c             	add    0xc(%ebp),%eax
  801a0e:	50                   	push   %eax
  801a0f:	57                   	push   %edi
  801a10:	e8 4d ef ff ff       	call   800962 <memmove>
		sys_cputs(buf, m);
  801a15:	83 c4 08             	add    $0x8,%esp
  801a18:	53                   	push   %ebx
  801a19:	57                   	push   %edi
  801a1a:	e8 f8 f0 ff ff       	call   800b17 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a1f:	01 de                	add    %ebx,%esi
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	89 f0                	mov    %esi,%eax
  801a26:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a29:	72 cc                	jb     8019f7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5f                   	pop    %edi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 08             	sub    $0x8,%esp
  801a39:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a42:	74 2a                	je     801a6e <devcons_read+0x3b>
  801a44:	eb 05                	jmp    801a4b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a46:	e8 69 f1 ff ff       	call   800bb4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a4b:	e8 e5 f0 ff ff       	call   800b35 <sys_cgetc>
  801a50:	85 c0                	test   %eax,%eax
  801a52:	74 f2                	je     801a46 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 16                	js     801a6e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a58:	83 f8 04             	cmp    $0x4,%eax
  801a5b:	74 0c                	je     801a69 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a60:	88 02                	mov    %al,(%edx)
	return 1;
  801a62:	b8 01 00 00 00       	mov    $0x1,%eax
  801a67:	eb 05                	jmp    801a6e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a69:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a76:	8b 45 08             	mov    0x8(%ebp),%eax
  801a79:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a7c:	6a 01                	push   $0x1
  801a7e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a81:	50                   	push   %eax
  801a82:	e8 90 f0 ff ff       	call   800b17 <sys_cputs>
}
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <getchar>:

int
getchar(void)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a92:	6a 01                	push   $0x1
  801a94:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a97:	50                   	push   %eax
  801a98:	6a 00                	push   $0x0
  801a9a:	e8 90 f6 ff ff       	call   80112f <read>
	if (r < 0)
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	78 0f                	js     801ab5 <getchar+0x29>
		return r;
	if (r < 1)
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	7e 06                	jle    801ab0 <getchar+0x24>
		return -E_EOF;
	return c;
  801aaa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801aae:	eb 05                	jmp    801ab5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ab0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801abd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac0:	50                   	push   %eax
  801ac1:	ff 75 08             	pushl  0x8(%ebp)
  801ac4:	e8 00 f4 ff ff       	call   800ec9 <fd_lookup>
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 11                	js     801ae1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad9:	39 10                	cmp    %edx,(%eax)
  801adb:	0f 94 c0             	sete   %al
  801ade:	0f b6 c0             	movzbl %al,%eax
}
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <opencons>:

int
opencons(void)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ae9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aec:	50                   	push   %eax
  801aed:	e8 88 f3 ff ff       	call   800e7a <fd_alloc>
  801af2:	83 c4 10             	add    $0x10,%esp
		return r;
  801af5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 3e                	js     801b39 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801afb:	83 ec 04             	sub    $0x4,%esp
  801afe:	68 07 04 00 00       	push   $0x407
  801b03:	ff 75 f4             	pushl  -0xc(%ebp)
  801b06:	6a 00                	push   $0x0
  801b08:	e8 c6 f0 ff ff       	call   800bd3 <sys_page_alloc>
  801b0d:	83 c4 10             	add    $0x10,%esp
		return r;
  801b10:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 23                	js     801b39 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b16:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b24:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	50                   	push   %eax
  801b2f:	e8 1f f3 ff ff       	call   800e53 <fd2num>
  801b34:	89 c2                	mov    %eax,%edx
  801b36:	83 c4 10             	add    $0x10,%esp
}
  801b39:	89 d0                	mov    %edx,%eax
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	8b 75 08             	mov    0x8(%ebp),%esi
  801b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	75 12                	jne    801b61 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	68 00 00 c0 ee       	push   $0xeec00000
  801b57:	e8 27 f2 ff ff       	call   800d83 <sys_ipc_recv>
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	eb 0c                	jmp    801b6d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	50                   	push   %eax
  801b65:	e8 19 f2 ff ff       	call   800d83 <sys_ipc_recv>
  801b6a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801b6d:	85 f6                	test   %esi,%esi
  801b6f:	0f 95 c1             	setne  %cl
  801b72:	85 db                	test   %ebx,%ebx
  801b74:	0f 95 c2             	setne  %dl
  801b77:	84 d1                	test   %dl,%cl
  801b79:	74 09                	je     801b84 <ipc_recv+0x47>
  801b7b:	89 c2                	mov    %eax,%edx
  801b7d:	c1 ea 1f             	shr    $0x1f,%edx
  801b80:	84 d2                	test   %dl,%dl
  801b82:	75 24                	jne    801ba8 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b84:	85 f6                	test   %esi,%esi
  801b86:	74 0a                	je     801b92 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b88:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8d:	8b 40 74             	mov    0x74(%eax),%eax
  801b90:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b92:	85 db                	test   %ebx,%ebx
  801b94:	74 0a                	je     801ba0 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801b96:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9b:	8b 40 78             	mov    0x78(%eax),%eax
  801b9e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ba0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba5:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ba8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bab:	5b                   	pop    %ebx
  801bac:	5e                   	pop    %esi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	57                   	push   %edi
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bbb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801bc1:	85 db                	test   %ebx,%ebx
  801bc3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bc8:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bcb:	ff 75 14             	pushl  0x14(%ebp)
  801bce:	53                   	push   %ebx
  801bcf:	56                   	push   %esi
  801bd0:	57                   	push   %edi
  801bd1:	e8 8a f1 ff ff       	call   800d60 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	c1 ea 1f             	shr    $0x1f,%edx
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	84 d2                	test   %dl,%dl
  801be0:	74 17                	je     801bf9 <ipc_send+0x4a>
  801be2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be5:	74 12                	je     801bf9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801be7:	50                   	push   %eax
  801be8:	68 ea 23 80 00       	push   $0x8023ea
  801bed:	6a 47                	push   $0x47
  801bef:	68 f8 23 80 00       	push   $0x8023f8
  801bf4:	e8 79 e5 ff ff       	call   800172 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801bf9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bfc:	75 07                	jne    801c05 <ipc_send+0x56>
			sys_yield();
  801bfe:	e8 b1 ef ff ff       	call   800bb4 <sys_yield>
  801c03:	eb c6                	jmp    801bcb <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801c05:	85 c0                	test   %eax,%eax
  801c07:	75 c2                	jne    801bcb <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5f                   	pop    %edi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c17:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c1c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c1f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c25:	8b 52 50             	mov    0x50(%edx),%edx
  801c28:	39 ca                	cmp    %ecx,%edx
  801c2a:	75 0d                	jne    801c39 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c2c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c2f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c34:	8b 40 48             	mov    0x48(%eax),%eax
  801c37:	eb 0f                	jmp    801c48 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c39:	83 c0 01             	add    $0x1,%eax
  801c3c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c41:	75 d9                	jne    801c1c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c50:	89 d0                	mov    %edx,%eax
  801c52:	c1 e8 16             	shr    $0x16,%eax
  801c55:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c61:	f6 c1 01             	test   $0x1,%cl
  801c64:	74 1d                	je     801c83 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c66:	c1 ea 0c             	shr    $0xc,%edx
  801c69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c70:	f6 c2 01             	test   $0x1,%dl
  801c73:	74 0e                	je     801c83 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c75:	c1 ea 0c             	shr    $0xc,%edx
  801c78:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c7f:	ef 
  801c80:	0f b7 c0             	movzwl %ax,%eax
}
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
  801c85:	66 90                	xchg   %ax,%ax
  801c87:	66 90                	xchg   %ax,%ax
  801c89:	66 90                	xchg   %ax,%ax
  801c8b:	66 90                	xchg   %ax,%ax
  801c8d:	66 90                	xchg   %ax,%ax
  801c8f:	90                   	nop

00801c90 <__udivdi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 f6                	test   %esi,%esi
  801ca9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cad:	89 ca                	mov    %ecx,%edx
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	75 3d                	jne    801cf0 <__udivdi3+0x60>
  801cb3:	39 cf                	cmp    %ecx,%edi
  801cb5:	0f 87 c5 00 00 00    	ja     801d80 <__udivdi3+0xf0>
  801cbb:	85 ff                	test   %edi,%edi
  801cbd:	89 fd                	mov    %edi,%ebp
  801cbf:	75 0b                	jne    801ccc <__udivdi3+0x3c>
  801cc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc6:	31 d2                	xor    %edx,%edx
  801cc8:	f7 f7                	div    %edi
  801cca:	89 c5                	mov    %eax,%ebp
  801ccc:	89 c8                	mov    %ecx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	f7 f5                	div    %ebp
  801cd2:	89 c1                	mov    %eax,%ecx
  801cd4:	89 d8                	mov    %ebx,%eax
  801cd6:	89 cf                	mov    %ecx,%edi
  801cd8:	f7 f5                	div    %ebp
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	89 fa                	mov    %edi,%edx
  801ce0:	83 c4 1c             	add    $0x1c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
  801ce8:	90                   	nop
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	39 ce                	cmp    %ecx,%esi
  801cf2:	77 74                	ja     801d68 <__udivdi3+0xd8>
  801cf4:	0f bd fe             	bsr    %esi,%edi
  801cf7:	83 f7 1f             	xor    $0x1f,%edi
  801cfa:	0f 84 98 00 00 00    	je     801d98 <__udivdi3+0x108>
  801d00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	29 fb                	sub    %edi,%ebx
  801d0b:	d3 e6                	shl    %cl,%esi
  801d0d:	89 d9                	mov    %ebx,%ecx
  801d0f:	d3 ed                	shr    %cl,%ebp
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e0                	shl    %cl,%eax
  801d15:	09 ee                	or     %ebp,%esi
  801d17:	89 d9                	mov    %ebx,%ecx
  801d19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1d:	89 d5                	mov    %edx,%ebp
  801d1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d23:	d3 ed                	shr    %cl,%ebp
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	d3 e2                	shl    %cl,%edx
  801d29:	89 d9                	mov    %ebx,%ecx
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	09 c2                	or     %eax,%edx
  801d2f:	89 d0                	mov    %edx,%eax
  801d31:	89 ea                	mov    %ebp,%edx
  801d33:	f7 f6                	div    %esi
  801d35:	89 d5                	mov    %edx,%ebp
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	f7 64 24 0c          	mull   0xc(%esp)
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	72 10                	jb     801d51 <__udivdi3+0xc1>
  801d41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e6                	shl    %cl,%esi
  801d49:	39 c6                	cmp    %eax,%esi
  801d4b:	73 07                	jae    801d54 <__udivdi3+0xc4>
  801d4d:	39 d5                	cmp    %edx,%ebp
  801d4f:	75 03                	jne    801d54 <__udivdi3+0xc4>
  801d51:	83 eb 01             	sub    $0x1,%ebx
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	89 fa                	mov    %edi,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	31 ff                	xor    %edi,%edi
  801d6a:	31 db                	xor    %ebx,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	f7 f7                	div    %edi
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 fa                	mov    %edi,%edx
  801d8c:	83 c4 1c             	add    $0x1c,%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5f                   	pop    %edi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	39 ce                	cmp    %ecx,%esi
  801d9a:	72 0c                	jb     801da8 <__udivdi3+0x118>
  801d9c:	31 db                	xor    %ebx,%ebx
  801d9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801da2:	0f 87 34 ff ff ff    	ja     801cdc <__udivdi3+0x4c>
  801da8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dad:	e9 2a ff ff ff       	jmp    801cdc <__udivdi3+0x4c>
  801db2:	66 90                	xchg   %ax,%ax
  801db4:	66 90                	xchg   %ax,%ax
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__umoddi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd7:	85 d2                	test   %edx,%edx
  801dd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 f3                	mov    %esi,%ebx
  801de3:	89 3c 24             	mov    %edi,(%esp)
  801de6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dea:	75 1c                	jne    801e08 <__umoddi3+0x48>
  801dec:	39 f7                	cmp    %esi,%edi
  801dee:	76 50                	jbe    801e40 <__umoddi3+0x80>
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	f7 f7                	div    %edi
  801df6:	89 d0                	mov    %edx,%eax
  801df8:	31 d2                	xor    %edx,%edx
  801dfa:	83 c4 1c             	add    $0x1c,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
  801e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e08:	39 f2                	cmp    %esi,%edx
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	77 52                	ja     801e60 <__umoddi3+0xa0>
  801e0e:	0f bd ea             	bsr    %edx,%ebp
  801e11:	83 f5 1f             	xor    $0x1f,%ebp
  801e14:	75 5a                	jne    801e70 <__umoddi3+0xb0>
  801e16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e1a:	0f 82 e0 00 00 00    	jb     801f00 <__umoddi3+0x140>
  801e20:	39 0c 24             	cmp    %ecx,(%esp)
  801e23:	0f 86 d7 00 00 00    	jbe    801f00 <__umoddi3+0x140>
  801e29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	85 ff                	test   %edi,%edi
  801e42:	89 fd                	mov    %edi,%ebp
  801e44:	75 0b                	jne    801e51 <__umoddi3+0x91>
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	f7 f7                	div    %edi
  801e4f:	89 c5                	mov    %eax,%ebp
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	f7 f5                	div    %ebp
  801e57:	89 c8                	mov    %ecx,%eax
  801e59:	f7 f5                	div    %ebp
  801e5b:	89 d0                	mov    %edx,%eax
  801e5d:	eb 99                	jmp    801df8 <__umoddi3+0x38>
  801e5f:	90                   	nop
  801e60:	89 c8                	mov    %ecx,%eax
  801e62:	89 f2                	mov    %esi,%edx
  801e64:	83 c4 1c             	add    $0x1c,%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    
  801e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e70:	8b 34 24             	mov    (%esp),%esi
  801e73:	bf 20 00 00 00       	mov    $0x20,%edi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	29 ef                	sub    %ebp,%edi
  801e7c:	d3 e0                	shl    %cl,%eax
  801e7e:	89 f9                	mov    %edi,%ecx
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	d3 ea                	shr    %cl,%edx
  801e84:	89 e9                	mov    %ebp,%ecx
  801e86:	09 c2                	or     %eax,%edx
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	89 14 24             	mov    %edx,(%esp)
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	d3 e2                	shl    %cl,%edx
  801e91:	89 f9                	mov    %edi,%ecx
  801e93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e9b:	d3 e8                	shr    %cl,%eax
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	89 c6                	mov    %eax,%esi
  801ea1:	d3 e3                	shl    %cl,%ebx
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 d0                	mov    %edx,%eax
  801ea7:	d3 e8                	shr    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	09 d8                	or     %ebx,%eax
  801ead:	89 d3                	mov    %edx,%ebx
  801eaf:	89 f2                	mov    %esi,%edx
  801eb1:	f7 34 24             	divl   (%esp)
  801eb4:	89 d6                	mov    %edx,%esi
  801eb6:	d3 e3                	shl    %cl,%ebx
  801eb8:	f7 64 24 04          	mull   0x4(%esp)
  801ebc:	39 d6                	cmp    %edx,%esi
  801ebe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec2:	89 d1                	mov    %edx,%ecx
  801ec4:	89 c3                	mov    %eax,%ebx
  801ec6:	72 08                	jb     801ed0 <__umoddi3+0x110>
  801ec8:	75 11                	jne    801edb <__umoddi3+0x11b>
  801eca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ece:	73 0b                	jae    801edb <__umoddi3+0x11b>
  801ed0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ed4:	1b 14 24             	sbb    (%esp),%edx
  801ed7:	89 d1                	mov    %edx,%ecx
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801edf:	29 da                	sub    %ebx,%edx
  801ee1:	19 ce                	sbb    %ecx,%esi
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	d3 e0                	shl    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	d3 ea                	shr    %cl,%edx
  801eed:	89 e9                	mov    %ebp,%ecx
  801eef:	d3 ee                	shr    %cl,%esi
  801ef1:	09 d0                	or     %edx,%eax
  801ef3:	89 f2                	mov    %esi,%edx
  801ef5:	83 c4 1c             	add    $0x1c,%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    
  801efd:	8d 76 00             	lea    0x0(%esi),%esi
  801f00:	29 f9                	sub    %edi,%ecx
  801f02:	19 d6                	sbb    %edx,%esi
  801f04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0c:	e9 18 ff ff ff       	jmp    801e29 <__umoddi3+0x69>
