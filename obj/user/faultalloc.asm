
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
  800040:	68 00 25 80 00       	push   $0x802500
  800045:	e8 dc 01 00 00       	call   800226 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 50 0b 00 00       	call   800bae <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 20 25 80 00       	push   $0x802520
  80006f:	6a 0e                	push   $0xe
  800071:	68 0a 25 80 00       	push   $0x80250a
  800076:	e8 d2 00 00 00       	call   80014d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 4c 25 80 00       	push   $0x80254c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 cf 06 00 00       	call   800758 <snprintf>
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
  80009c:	e8 5e 0d 00 00       	call   800dff <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 1c 25 80 00       	push   $0x80251c
  8000ae:	e8 73 01 00 00       	call   800226 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 1c 25 80 00       	push   $0x80251c
  8000c0:	e8 61 01 00 00       	call   800226 <cprintf>
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
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 96 0a 00 00       	call   800b70 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8000e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ea:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ef:	85 db                	test   %ebx,%ebx
  8000f1:	7e 07                	jle    8000fa <libmain+0x30>
		binaryname = argv[0];
  8000f3:	8b 06                	mov    (%esi),%eax
  8000f5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000fa:	83 ec 08             	sub    $0x8,%esp
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	e8 8d ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800104:	e8 2a 00 00 00       	call   800133 <exit>
}
  800109:	83 c4 10             	add    $0x10,%esp
  80010c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800119:	a1 0c 40 80 00       	mov    0x80400c,%eax
	func();
  80011e:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800120:	e8 4b 0a 00 00       	call   800b70 <sys_getenvid>
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	50                   	push   %eax
  800129:	e8 91 0c 00 00       	call   800dbf <sys_thread_free>
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 9a 14 00 00       	call   8015d8 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 e7 09 00 00       	call   800b2f <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 10 0a 00 00       	call   800b70 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 78 25 80 00       	push   $0x802578
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 74 29 80 00 	movl   $0x802974,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 2f 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 d4 08 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 e2 1f 00 00       	call   802270 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 cf 20 00 00       	call   8023a0 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 9b 25 80 00 	movsbl 0x80259b(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 89 03 00 00    	je     800702 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 07             	movzbl (%edi),%eax
  8003bf:	0f b6 c8             	movzbl %al,%ecx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 1a 03 00 00    	ja     8006e7 <vprintfmt+0x38a>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003de:	eb d6                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f8:	83 fa 09             	cmp    $0x9,%edx
  8003fb:	77 39                	ja     800436 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 48 04             	lea    0x4(%eax),%ecx
  800408:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800413:	eb 27                	jmp    80043c <vprintfmt+0xdf>
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	85 c0                	test   %eax,%eax
  80041a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041f:	0f 49 c8             	cmovns %eax,%ecx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800428:	eb 8c                	jmp    8003b6 <vprintfmt+0x59>
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800434:	eb 80                	jmp    8003b6 <vprintfmt+0x59>
  800436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	0f 89 70 ff ff ff    	jns    8003b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800446:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800453:	e9 5e ff ff ff       	jmp    8003b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800458:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045e:	e9 53 ff ff ff       	jmp    8003b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 30                	pushl  (%eax)
  800472:	ff d6                	call   *%esi
			break;
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047a:	e9 04 ff ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	99                   	cltd   
  80048b:	31 d0                	xor    %edx,%eax
  80048d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 b3 25 80 00       	push   $0x8025b3
  8004a5:	53                   	push   %ebx
  8004a6:	56                   	push   %esi
  8004a7:	e8 94 fe ff ff       	call   800340 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b2:	e9 cc fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b7:	52                   	push   %edx
  8004b8:	68 e1 2a 80 00       	push   $0x802ae1
  8004bd:	53                   	push   %ebx
  8004be:	56                   	push   %esi
  8004bf:	e8 7c fe ff ff       	call   800340 <printfmt>
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 b4 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	b8 ac 25 80 00       	mov    $0x8025ac,%eax
  8004e1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e8:	0f 8e 94 00 00 00    	jle    800582 <vprintfmt+0x225>
  8004ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f2:	0f 84 98 00 00 00    	je     800590 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fe:	57                   	push   %edi
  8004ff:	e8 86 02 00 00       	call   80078a <strnlen>
  800504:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800519:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0f                	jmp    80052c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	ff 75 e0             	pushl  -0x20(%ebp)
  800524:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f ed                	jg     80051d <vprintfmt+0x1c0>
  800530:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800533:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800536:	85 c9                	test   %ecx,%ecx
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	0f 49 c1             	cmovns %ecx,%eax
  800540:	29 c1                	sub    %eax,%ecx
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	89 cb                	mov    %ecx,%ebx
  80054d:	eb 4d                	jmp    80059c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800553:	74 1b                	je     800570 <vprintfmt+0x213>
  800555:	0f be c0             	movsbl %al,%eax
  800558:	83 e8 20             	sub    $0x20,%eax
  80055b:	83 f8 5e             	cmp    $0x5e,%eax
  80055e:	76 10                	jbe    800570 <vprintfmt+0x213>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	6a 3f                	push   $0x3f
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 0d                	jmp    80057d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	52                   	push   %edx
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	83 eb 01             	sub    $0x1,%ebx
  800580:	eb 1a                	jmp    80059c <vprintfmt+0x23f>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	eb 0c                	jmp    80059c <vprintfmt+0x23f>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	0f be d0             	movsbl %al,%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 23                	je     8005cd <vprintfmt+0x270>
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	78 a1                	js     80054f <vprintfmt+0x1f2>
  8005ae:	83 ee 01             	sub    $0x1,%esi
  8005b1:	79 9c                	jns    80054f <vprintfmt+0x1f2>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	eb 18                	jmp    8005d5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 20                	push   $0x20
  8005c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	83 ef 01             	sub    $0x1,%edi
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 08                	jmp    8005d5 <vprintfmt+0x278>
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	7f e4                	jg     8005bd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	e9 a2 fd ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e1:	83 fa 01             	cmp    $0x1,%edx
  8005e4:	7e 16                	jle    8005fc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fa:	eb 32                	jmp    80062e <vprintfmt+0x2d1>
	else if (lflag)
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 18                	je     800618 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 c1                	mov    %eax,%ecx
  800610:	c1 f9 1f             	sar    $0x1f,%ecx
  800613:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800616:	eb 16                	jmp    80062e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 c1                	mov    %eax,%ecx
  800628:	c1 f9 1f             	sar    $0x1f,%ecx
  80062b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063d:	79 74                	jns    8006b3 <vprintfmt+0x356>
				putch('-', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 2d                	push   $0x2d
  800645:	ff d6                	call   *%esi
				num = -(long long) num;
  800647:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064d:	f7 d8                	neg    %eax
  80064f:	83 d2 00             	adc    $0x0,%edx
  800652:	f7 da                	neg    %edx
  800654:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800657:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065c:	eb 55                	jmp    8006b3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 83 fc ff ff       	call   8002e9 <getuint>
			base = 10;
  800666:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066b:	eb 46                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 74 fc ff ff       	call   8002e9 <getuint>
			base = 8;
  800675:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80067a:	eb 37                	jmp    8006b3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 30                	push   $0x30
  800682:	ff d6                	call   *%esi
			putch('x', putdat);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 78                	push   $0x78
  80068a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a4:	eb 0d                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 3b fc ff ff       	call   8002e9 <getuint>
			base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b3:	83 ec 0c             	sub    $0xc,%esp
  8006b6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ba:	57                   	push   %edi
  8006bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006be:	51                   	push   %ecx
  8006bf:	52                   	push   %edx
  8006c0:	50                   	push   %eax
  8006c1:	89 da                	mov    %ebx,%edx
  8006c3:	89 f0                	mov    %esi,%eax
  8006c5:	e8 70 fb ff ff       	call   80023a <printnum>
			break;
  8006ca:	83 c4 20             	add    $0x20,%esp
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d0:	e9 ae fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	51                   	push   %ecx
  8006da:	ff d6                	call   *%esi
			break;
  8006dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e2:	e9 9c fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 25                	push   $0x25
  8006ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	eb 03                	jmp    8006f7 <vprintfmt+0x39a>
  8006f4:	83 ef 01             	sub    $0x1,%edi
  8006f7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fb:	75 f7                	jne    8006f4 <vprintfmt+0x397>
  8006fd:	e9 81 fc ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800716:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800719:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800720:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800727:	85 c0                	test   %eax,%eax
  800729:	74 26                	je     800751 <vsnprintf+0x47>
  80072b:	85 d2                	test   %edx,%edx
  80072d:	7e 22                	jle    800751 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072f:	ff 75 14             	pushl  0x14(%ebp)
  800732:	ff 75 10             	pushl  0x10(%ebp)
  800735:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	68 23 03 80 00       	push   $0x800323
  80073e:	e8 1a fc ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800743:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800746:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 05                	jmp    800756 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 9a ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 03                	jmp    800782 <strlen+0x10>
		n++;
  80077f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f7                	jne    80077f <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	ba 00 00 00 00       	mov    $0x0,%edx
  800798:	eb 03                	jmp    80079d <strnlen+0x13>
		n++;
  80079a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	39 c2                	cmp    %eax,%edx
  80079f:	74 08                	je     8007a9 <strnlen+0x1f>
  8007a1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a5:	75 f3                	jne    80079a <strnlen+0x10>
  8007a7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	89 c2                	mov    %eax,%edx
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c4:	84 db                	test   %bl,%bl
  8007c6:	75 ef                	jne    8007b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	53                   	push   %ebx
  8007d3:	e8 9a ff ff ff       	call   800772 <strlen>
  8007d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	01 d8                	add    %ebx,%eax
  8007e0:	50                   	push   %eax
  8007e1:	e8 c5 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007e6:	89 d8                	mov    %ebx,%eax
  8007e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f8:	89 f3                	mov    %esi,%ebx
  8007fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 0f                	jmp    800810 <strncpy+0x23>
		*dst++ = *src;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	0f b6 01             	movzbl (%ecx),%eax
  800807:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 39 01             	cmpb   $0x1,(%ecx)
  80080d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	39 da                	cmp    %ebx,%edx
  800812:	75 ed                	jne    800801 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	89 f0                	mov    %esi,%eax
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	8b 55 10             	mov    0x10(%ebp),%edx
  800828:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082a:	85 d2                	test   %edx,%edx
  80082c:	74 21                	je     80084f <strlcpy+0x35>
  80082e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800832:	89 f2                	mov    %esi,%edx
  800834:	eb 09                	jmp    80083f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083f:	39 c2                	cmp    %eax,%edx
  800841:	74 09                	je     80084c <strlcpy+0x32>
  800843:	0f b6 19             	movzbl (%ecx),%ebx
  800846:	84 db                	test   %bl,%bl
  800848:	75 ec                	jne    800836 <strlcpy+0x1c>
  80084a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084f:	29 f0                	sub    %esi,%eax
}
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strcmp+0x11>
		p++, q++;
  800860:	83 c1 01             	add    $0x1,%ecx
  800863:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800866:	0f b6 01             	movzbl (%ecx),%eax
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x1c>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 ef                	je     800860 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 c3                	mov    %eax,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strncmp+0x17>
		n--, p++, q++;
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 15                	je     8008ab <strncmp+0x30>
  800896:	0f b6 08             	movzbl (%eax),%ecx
  800899:	84 c9                	test   %cl,%cl
  80089b:	74 04                	je     8008a1 <strncmp+0x26>
  80089d:	3a 0a                	cmp    (%edx),%cl
  80089f:	74 eb                	je     80088c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 00             	movzbl (%eax),%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
  8008a9:	eb 05                	jmp    8008b0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bd:	eb 07                	jmp    8008c6 <strchr+0x13>
		if (*s == c)
  8008bf:	38 ca                	cmp    %cl,%dl
  8008c1:	74 0f                	je     8008d2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c3:	83 c0 01             	add    $0x1,%eax
  8008c6:	0f b6 10             	movzbl (%eax),%edx
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	75 f2                	jne    8008bf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	eb 03                	jmp    8008e3 <strfind+0xf>
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 04                	je     8008ee <strfind+0x1a>
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	75 f2                	jne    8008e0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 36                	je     800936 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 28                	jne    800930 <memset+0x40>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 23                	jne    800930 <memset+0x40>
		c &= 0xFF;
  80090d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800911:	89 d3                	mov    %edx,%ebx
  800913:	c1 e3 08             	shl    $0x8,%ebx
  800916:	89 d6                	mov    %edx,%esi
  800918:	c1 e6 18             	shl    $0x18,%esi
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	c1 e0 10             	shl    $0x10,%eax
  800920:	09 f0                	or     %esi,%eax
  800922:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800924:	89 d8                	mov    %ebx,%eax
  800926:	09 d0                	or     %edx,%eax
  800928:	c1 e9 02             	shr    $0x2,%ecx
  80092b:	fc                   	cld    
  80092c:	f3 ab                	rep stos %eax,%es:(%edi)
  80092e:	eb 06                	jmp    800936 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	fc                   	cld    
  800934:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800936:	89 f8                	mov    %edi,%eax
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 75 0c             	mov    0xc(%ebp),%esi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094b:	39 c6                	cmp    %eax,%esi
  80094d:	73 35                	jae    800984 <memmove+0x47>
  80094f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800952:	39 d0                	cmp    %edx,%eax
  800954:	73 2e                	jae    800984 <memmove+0x47>
		s += n;
		d += n;
  800956:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 d6                	mov    %edx,%esi
  80095b:	09 fe                	or     %edi,%esi
  80095d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800963:	75 13                	jne    800978 <memmove+0x3b>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 0e                	jne    800978 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096a:	83 ef 04             	sub    $0x4,%edi
  80096d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800970:	c1 e9 02             	shr    $0x2,%ecx
  800973:	fd                   	std    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 09                	jmp    800981 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800978:	83 ef 01             	sub    $0x1,%edi
  80097b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097e:	fd                   	std    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800981:	fc                   	cld    
  800982:	eb 1d                	jmp    8009a1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 f2                	mov    %esi,%edx
  800986:	09 c2                	or     %eax,%edx
  800988:	f6 c2 03             	test   $0x3,%dl
  80098b:	75 0f                	jne    80099c <memmove+0x5f>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0a                	jne    80099c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800992:	c1 e9 02             	shr    $0x2,%ecx
  800995:	89 c7                	mov    %eax,%edi
  800997:	fc                   	cld    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 05                	jmp    8009a1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099c:	89 c7                	mov    %eax,%edi
  80099e:	fc                   	cld    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a8:	ff 75 10             	pushl  0x10(%ebp)
  8009ab:	ff 75 0c             	pushl  0xc(%ebp)
  8009ae:	ff 75 08             	pushl  0x8(%ebp)
  8009b1:	e8 87 ff ff ff       	call   80093d <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	89 c6                	mov    %eax,%esi
  8009c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	eb 1a                	jmp    8009e4 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	74 0a                	je     8009de <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d4:	0f b6 c1             	movzbl %cl,%eax
  8009d7:	0f b6 db             	movzbl %bl,%ebx
  8009da:	29 d8                	sub    %ebx,%eax
  8009dc:	eb 0f                	jmp    8009ed <memcmp+0x35>
		s1++, s2++;
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e4:	39 f0                	cmp    %esi,%eax
  8009e6:	75 e2                	jne    8009ca <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f8:	89 c1                	mov    %eax,%ecx
  8009fa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a01:	eb 0a                	jmp    800a0d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	0f b6 10             	movzbl (%eax),%edx
  800a06:	39 da                	cmp    %ebx,%edx
  800a08:	74 07                	je     800a11 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 c8                	cmp    %ecx,%eax
  800a0f:	72 f2                	jb     800a03 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	75 0a                	jne    800a3e <strtol+0x2a>
		s++;
  800a34:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3c:	eb 11                	jmp    800a4f <strtol+0x3b>
  800a3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a43:	3c 2d                	cmp    $0x2d,%al
  800a45:	75 08                	jne    800a4f <strtol+0x3b>
		s++, neg = 1;
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 15                	jne    800a6c <strtol+0x58>
  800a57:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5a:	75 10                	jne    800a6c <strtol+0x58>
  800a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a60:	75 7c                	jne    800ade <strtol+0xca>
		s += 2, base = 16;
  800a62:	83 c1 02             	add    $0x2,%ecx
  800a65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6a:	eb 16                	jmp    800a82 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	75 12                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a70:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a75:	80 39 30             	cmpb   $0x30,(%ecx)
  800a78:	75 08                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8a:	0f b6 11             	movzbl (%ecx),%edx
  800a8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 09             	cmp    $0x9,%bl
  800a95:	77 08                	ja     800a9f <strtol+0x8b>
			dig = *s - '0';
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 30             	sub    $0x30,%edx
  800a9d:	eb 22                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 08                	ja     800ab1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 57             	sub    $0x57,%edx
  800aaf:	eb 10                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 16                	ja     800ad1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac4:	7d 0b                	jge    800ad1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acf:	eb b9                	jmp    800a8a <strtol+0x76>

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 0d                	je     800ae4 <strtol+0xd0>
		*endptr = (char *) s;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	89 0e                	mov    %ecx,(%esi)
  800adc:	eb 06                	jmp    800ae4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	74 98                	je     800a7a <strtol+0x66>
  800ae2:	eb 9e                	jmp    800a82 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
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
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 17                	jle    800b68 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 9f 28 80 00       	push   $0x80289f
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 bc 28 80 00       	push   $0x8028bc
  800b63:	e8 e5 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 9f 28 80 00       	push   $0x80289f
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 bc 28 80 00       	push   $0x8028bc
  800be4:	e8 64 f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 9f 28 80 00       	push   $0x80289f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 bc 28 80 00       	push   $0x8028bc
  800c26:	e8 22 f5 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 06 00 00 00       	mov    $0x6,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 9f 28 80 00       	push   $0x80289f
  800c61:	6a 23                	push   $0x23
  800c63:	68 bc 28 80 00       	push   $0x8028bc
  800c68:	e8 e0 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	b8 08 00 00 00       	mov    $0x8,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 9f 28 80 00       	push   $0x80289f
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 bc 28 80 00       	push   $0x8028bc
  800caa:	e8 9e f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 9f 28 80 00       	push   $0x80289f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 bc 28 80 00       	push   $0x8028bc
  800cec:	e8 5c f4 ff ff       	call   80014d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 0a                	push   $0xa
  800d22:	68 9f 28 80 00       	push   $0x80289f
  800d27:	6a 23                	push   $0x23
  800d29:	68 bc 28 80 00       	push   $0x8028bc
  800d2e:	e8 1a f4 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0d                	push   $0xd
  800d86:	68 9f 28 80 00       	push   $0x80289f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 bc 28 80 00       	push   $0x8028bc
  800d92:	e8 b6 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800daa:	b8 0e 00 00 00       	mov    $0xe,%eax
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	89 cb                	mov    %ecx,%ebx
  800db4:	89 cf                	mov    %ecx,%edi
  800db6:	89 ce                	mov    %ecx,%esi
  800db8:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dca:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	89 cb                	mov    %ecx,%ebx
  800dd4:	89 cf                	mov    %ecx,%edi
  800dd6:	89 ce                	mov    %ecx,%esi
  800dd8:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dea:	b8 10 00 00 00       	mov    $0x10,%eax
  800def:	8b 55 08             	mov    0x8(%ebp),%edx
  800df2:	89 cb                	mov    %ecx,%ebx
  800df4:	89 cf                	mov    %ecx,%edi
  800df6:	89 ce                	mov    %ecx,%esi
  800df8:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e05:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e0c:	75 2a                	jne    800e38 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800e0e:	83 ec 04             	sub    $0x4,%esp
  800e11:	6a 07                	push   $0x7
  800e13:	68 00 f0 bf ee       	push   $0xeebff000
  800e18:	6a 00                	push   $0x0
  800e1a:	e8 8f fd ff ff       	call   800bae <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800e1f:	83 c4 10             	add    $0x10,%esp
  800e22:	85 c0                	test   %eax,%eax
  800e24:	79 12                	jns    800e38 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800e26:	50                   	push   %eax
  800e27:	68 a6 29 80 00       	push   $0x8029a6
  800e2c:	6a 23                	push   $0x23
  800e2e:	68 ca 28 80 00       	push   $0x8028ca
  800e33:	e8 15 f3 ff ff       	call   80014d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e40:	83 ec 08             	sub    $0x8,%esp
  800e43:	68 6a 0e 80 00       	push   $0x800e6a
  800e48:	6a 00                	push   $0x0
  800e4a:	e8 aa fe ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	79 12                	jns    800e68 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e56:	50                   	push   %eax
  800e57:	68 a6 29 80 00       	push   $0x8029a6
  800e5c:	6a 2c                	push   $0x2c
  800e5e:	68 ca 28 80 00       	push   $0x8028ca
  800e63:	e8 e5 f2 ff ff       	call   80014d <_panic>
	}
}
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e6a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e6b:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e70:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e72:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e75:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e79:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e7e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e82:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e84:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e87:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e88:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e8b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e8c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e8d:	c3                   	ret    

00800e8e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	53                   	push   %ebx
  800e92:	83 ec 04             	sub    $0x4,%esp
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e98:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e9a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e9e:	74 11                	je     800eb1 <pgfault+0x23>
  800ea0:	89 d8                	mov    %ebx,%eax
  800ea2:	c1 e8 0c             	shr    $0xc,%eax
  800ea5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eac:	f6 c4 08             	test   $0x8,%ah
  800eaf:	75 14                	jne    800ec5 <pgfault+0x37>
		panic("faulting access");
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	68 d8 28 80 00       	push   $0x8028d8
  800eb9:	6a 1f                	push   $0x1f
  800ebb:	68 e8 28 80 00       	push   $0x8028e8
  800ec0:	e8 88 f2 ff ff       	call   80014d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ec5:	83 ec 04             	sub    $0x4,%esp
  800ec8:	6a 07                	push   $0x7
  800eca:	68 00 f0 7f 00       	push   $0x7ff000
  800ecf:	6a 00                	push   $0x0
  800ed1:	e8 d8 fc ff ff       	call   800bae <sys_page_alloc>
	if (r < 0) {
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	79 12                	jns    800eef <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800edd:	50                   	push   %eax
  800ede:	68 f3 28 80 00       	push   $0x8028f3
  800ee3:	6a 2d                	push   $0x2d
  800ee5:	68 e8 28 80 00       	push   $0x8028e8
  800eea:	e8 5e f2 ff ff       	call   80014d <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eef:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ef5:	83 ec 04             	sub    $0x4,%esp
  800ef8:	68 00 10 00 00       	push   $0x1000
  800efd:	53                   	push   %ebx
  800efe:	68 00 f0 7f 00       	push   $0x7ff000
  800f03:	e8 9d fa ff ff       	call   8009a5 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f08:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0f:	53                   	push   %ebx
  800f10:	6a 00                	push   $0x0
  800f12:	68 00 f0 7f 00       	push   $0x7ff000
  800f17:	6a 00                	push   $0x0
  800f19:	e8 d3 fc ff ff       	call   800bf1 <sys_page_map>
	if (r < 0) {
  800f1e:	83 c4 20             	add    $0x20,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	79 12                	jns    800f37 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f25:	50                   	push   %eax
  800f26:	68 f3 28 80 00       	push   $0x8028f3
  800f2b:	6a 34                	push   $0x34
  800f2d:	68 e8 28 80 00       	push   $0x8028e8
  800f32:	e8 16 f2 ff ff       	call   80014d <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f37:	83 ec 08             	sub    $0x8,%esp
  800f3a:	68 00 f0 7f 00       	push   $0x7ff000
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 ed fc ff ff       	call   800c33 <sys_page_unmap>
	if (r < 0) {
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	79 12                	jns    800f5f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f4d:	50                   	push   %eax
  800f4e:	68 f3 28 80 00       	push   $0x8028f3
  800f53:	6a 38                	push   $0x38
  800f55:	68 e8 28 80 00       	push   $0x8028e8
  800f5a:	e8 ee f1 ff ff       	call   80014d <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
  800f6a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f6d:	68 8e 0e 80 00       	push   $0x800e8e
  800f72:	e8 88 fe ff ff       	call   800dff <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f77:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7c:	cd 30                	int    $0x30
  800f7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	79 17                	jns    800f9f <fork+0x3b>
		panic("fork fault %e");
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	68 0c 29 80 00       	push   $0x80290c
  800f90:	68 85 00 00 00       	push   $0x85
  800f95:	68 e8 28 80 00       	push   $0x8028e8
  800f9a:	e8 ae f1 ff ff       	call   80014d <_panic>
  800f9f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fa1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fa5:	75 24                	jne    800fcb <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fa7:	e8 c4 fb ff ff       	call   800b70 <sys_getenvid>
  800fac:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fb1:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800fb7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fbc:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc6:	e9 64 01 00 00       	jmp    80112f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	6a 07                	push   $0x7
  800fd0:	68 00 f0 bf ee       	push   $0xeebff000
  800fd5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd8:	e8 d1 fb ff ff       	call   800bae <sys_page_alloc>
  800fdd:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fe0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fe5:	89 d8                	mov    %ebx,%eax
  800fe7:	c1 e8 16             	shr    $0x16,%eax
  800fea:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff1:	a8 01                	test   $0x1,%al
  800ff3:	0f 84 fc 00 00 00    	je     8010f5 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ff9:	89 d8                	mov    %ebx,%eax
  800ffb:	c1 e8 0c             	shr    $0xc,%eax
  800ffe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801005:	f6 c2 01             	test   $0x1,%dl
  801008:	0f 84 e7 00 00 00    	je     8010f5 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80100e:	89 c6                	mov    %eax,%esi
  801010:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801013:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101a:	f6 c6 04             	test   $0x4,%dh
  80101d:	74 39                	je     801058 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80101f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	25 07 0e 00 00       	and    $0xe07,%eax
  80102e:	50                   	push   %eax
  80102f:	56                   	push   %esi
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	6a 00                	push   $0x0
  801034:	e8 b8 fb ff ff       	call   800bf1 <sys_page_map>
		if (r < 0) {
  801039:	83 c4 20             	add    $0x20,%esp
  80103c:	85 c0                	test   %eax,%eax
  80103e:	0f 89 b1 00 00 00    	jns    8010f5 <fork+0x191>
		    	panic("sys page map fault %e");
  801044:	83 ec 04             	sub    $0x4,%esp
  801047:	68 1a 29 80 00       	push   $0x80291a
  80104c:	6a 55                	push   $0x55
  80104e:	68 e8 28 80 00       	push   $0x8028e8
  801053:	e8 f5 f0 ff ff       	call   80014d <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801058:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105f:	f6 c2 02             	test   $0x2,%dl
  801062:	75 0c                	jne    801070 <fork+0x10c>
  801064:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106b:	f6 c4 08             	test   $0x8,%ah
  80106e:	74 5b                	je     8010cb <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	68 05 08 00 00       	push   $0x805
  801078:	56                   	push   %esi
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	6a 00                	push   $0x0
  80107d:	e8 6f fb ff ff       	call   800bf1 <sys_page_map>
		if (r < 0) {
  801082:	83 c4 20             	add    $0x20,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	79 14                	jns    80109d <fork+0x139>
		    	panic("sys page map fault %e");
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	68 1a 29 80 00       	push   $0x80291a
  801091:	6a 5c                	push   $0x5c
  801093:	68 e8 28 80 00       	push   $0x8028e8
  801098:	e8 b0 f0 ff ff       	call   80014d <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	68 05 08 00 00       	push   $0x805
  8010a5:	56                   	push   %esi
  8010a6:	6a 00                	push   $0x0
  8010a8:	56                   	push   %esi
  8010a9:	6a 00                	push   $0x0
  8010ab:	e8 41 fb ff ff       	call   800bf1 <sys_page_map>
		if (r < 0) {
  8010b0:	83 c4 20             	add    $0x20,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	79 3e                	jns    8010f5 <fork+0x191>
		    	panic("sys page map fault %e");
  8010b7:	83 ec 04             	sub    $0x4,%esp
  8010ba:	68 1a 29 80 00       	push   $0x80291a
  8010bf:	6a 60                	push   $0x60
  8010c1:	68 e8 28 80 00       	push   $0x8028e8
  8010c6:	e8 82 f0 ff ff       	call   80014d <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	6a 05                	push   $0x5
  8010d0:	56                   	push   %esi
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	6a 00                	push   $0x0
  8010d5:	e8 17 fb ff ff       	call   800bf1 <sys_page_map>
		if (r < 0) {
  8010da:	83 c4 20             	add    $0x20,%esp
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	79 14                	jns    8010f5 <fork+0x191>
		    	panic("sys page map fault %e");
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	68 1a 29 80 00       	push   $0x80291a
  8010e9:	6a 65                	push   $0x65
  8010eb:	68 e8 28 80 00       	push   $0x8028e8
  8010f0:	e8 58 f0 ff ff       	call   80014d <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010f5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010fb:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801101:	0f 85 de fe ff ff    	jne    800fe5 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801107:	a1 04 40 80 00       	mov    0x804004,%eax
  80110c:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  801112:	83 ec 08             	sub    $0x8,%esp
  801115:	50                   	push   %eax
  801116:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801119:	57                   	push   %edi
  80111a:	e8 da fb ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	6a 02                	push   $0x2
  801124:	57                   	push   %edi
  801125:	e8 4b fb ff ff       	call   800c75 <sys_env_set_status>
	
	return envid;
  80112a:	83 c4 10             	add    $0x10,%esp
  80112d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80112f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <sfork>:

envid_t
sfork(void)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801149:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80114f:	83 ec 08             	sub    $0x8,%esp
  801152:	53                   	push   %ebx
  801153:	68 ac 29 80 00       	push   $0x8029ac
  801158:	e8 c9 f0 ff ff       	call   800226 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80115d:	c7 04 24 13 01 80 00 	movl   $0x800113,(%esp)
  801164:	e8 36 fc ff ff       	call   800d9f <sys_thread_create>
  801169:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80116b:	83 c4 08             	add    $0x8,%esp
  80116e:	53                   	push   %ebx
  80116f:	68 ac 29 80 00       	push   $0x8029ac
  801174:	e8 ad f0 ff ff       	call   800226 <cprintf>
	return id;
}
  801179:	89 f0                	mov    %esi,%eax
  80117b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117e:	5b                   	pop    %ebx
  80117f:	5e                   	pop    %esi
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    

00801182 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801188:	ff 75 08             	pushl  0x8(%ebp)
  80118b:	e8 2f fc ff ff       	call   800dbf <sys_thread_free>
}
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  80119b:	ff 75 08             	pushl  0x8(%ebp)
  80119e:	e8 3c fc ff ff       	call   800ddf <sys_thread_join>
}
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	6a 07                	push   $0x7
  8011b8:	6a 00                	push   $0x0
  8011ba:	56                   	push   %esi
  8011bb:	e8 ee f9 ff ff       	call   800bae <sys_page_alloc>
	if (r < 0) {
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	79 15                	jns    8011dc <queue_append+0x34>
		panic("%e\n", r);
  8011c7:	50                   	push   %eax
  8011c8:	68 a6 29 80 00       	push   $0x8029a6
  8011cd:	68 c4 00 00 00       	push   $0xc4
  8011d2:	68 e8 28 80 00       	push   $0x8028e8
  8011d7:	e8 71 ef ff ff       	call   80014d <_panic>
	}	
	wt->envid = envid;
  8011dc:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	ff 33                	pushl  (%ebx)
  8011e7:	56                   	push   %esi
  8011e8:	68 d0 29 80 00       	push   $0x8029d0
  8011ed:	e8 34 f0 ff ff       	call   800226 <cprintf>
	if (queue->first == NULL) {
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	83 3b 00             	cmpl   $0x0,(%ebx)
  8011f8:	75 29                	jne    801223 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8011fa:	83 ec 0c             	sub    $0xc,%esp
  8011fd:	68 30 29 80 00       	push   $0x802930
  801202:	e8 1f f0 ff ff       	call   800226 <cprintf>
		queue->first = wt;
  801207:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80120d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801214:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80121b:	00 00 00 
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	eb 2b                	jmp    80124e <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801223:	83 ec 0c             	sub    $0xc,%esp
  801226:	68 4a 29 80 00       	push   $0x80294a
  80122b:	e8 f6 ef ff ff       	call   800226 <cprintf>
		queue->last->next = wt;
  801230:	8b 43 04             	mov    0x4(%ebx),%eax
  801233:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80123a:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801241:	00 00 00 
		queue->last = wt;
  801244:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80124b:	83 c4 10             	add    $0x10,%esp
	}
}
  80124e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	53                   	push   %ebx
  801259:	83 ec 04             	sub    $0x4,%esp
  80125c:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80125f:	8b 02                	mov    (%edx),%eax
  801261:	85 c0                	test   %eax,%eax
  801263:	75 17                	jne    80127c <queue_pop+0x27>
		panic("queue empty!\n");
  801265:	83 ec 04             	sub    $0x4,%esp
  801268:	68 68 29 80 00       	push   $0x802968
  80126d:	68 d8 00 00 00       	push   $0xd8
  801272:	68 e8 28 80 00       	push   $0x8028e8
  801277:	e8 d1 ee ff ff       	call   80014d <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80127c:	8b 48 04             	mov    0x4(%eax),%ecx
  80127f:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  801281:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	53                   	push   %ebx
  801287:	68 76 29 80 00       	push   $0x802976
  80128c:	e8 95 ef ff ff       	call   800226 <cprintf>
	return envid;
}
  801291:	89 d8                	mov    %ebx,%eax
  801293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8012a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a7:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	74 5a                	je     801308 <mutex_lock+0x70>
  8012ae:	8b 43 04             	mov    0x4(%ebx),%eax
  8012b1:	83 38 00             	cmpl   $0x0,(%eax)
  8012b4:	75 52                	jne    801308 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	68 f8 29 80 00       	push   $0x8029f8
  8012be:	e8 63 ef ff ff       	call   800226 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8012c3:	8b 5b 04             	mov    0x4(%ebx),%ebx
  8012c6:	e8 a5 f8 ff ff       	call   800b70 <sys_getenvid>
  8012cb:	83 c4 08             	add    $0x8,%esp
  8012ce:	53                   	push   %ebx
  8012cf:	50                   	push   %eax
  8012d0:	e8 d3 fe ff ff       	call   8011a8 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012d5:	e8 96 f8 ff ff       	call   800b70 <sys_getenvid>
  8012da:	83 c4 08             	add    $0x8,%esp
  8012dd:	6a 04                	push   $0x4
  8012df:	50                   	push   %eax
  8012e0:	e8 90 f9 ff ff       	call   800c75 <sys_env_set_status>
		if (r < 0) {
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	79 15                	jns    801301 <mutex_lock+0x69>
			panic("%e\n", r);
  8012ec:	50                   	push   %eax
  8012ed:	68 a6 29 80 00       	push   $0x8029a6
  8012f2:	68 eb 00 00 00       	push   $0xeb
  8012f7:	68 e8 28 80 00       	push   $0x8028e8
  8012fc:	e8 4c ee ff ff       	call   80014d <_panic>
		}
		sys_yield();
  801301:	e8 89 f8 ff ff       	call   800b8f <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801306:	eb 18                	jmp    801320 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  801308:	83 ec 0c             	sub    $0xc,%esp
  80130b:	68 18 2a 80 00       	push   $0x802a18
  801310:	e8 11 ef ff ff       	call   800226 <cprintf>
	mtx->owner = sys_getenvid();}
  801315:	e8 56 f8 ff ff       	call   800b70 <sys_getenvid>
  80131a:	89 43 08             	mov    %eax,0x8(%ebx)
  80131d:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801320:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801323:	c9                   	leave  
  801324:	c3                   	ret    

00801325 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	53                   	push   %ebx
  801329:	83 ec 04             	sub    $0x4,%esp
  80132c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80132f:	b8 00 00 00 00       	mov    $0x0,%eax
  801334:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801337:	8b 43 04             	mov    0x4(%ebx),%eax
  80133a:	83 38 00             	cmpl   $0x0,(%eax)
  80133d:	74 33                	je     801372 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80133f:	83 ec 0c             	sub    $0xc,%esp
  801342:	50                   	push   %eax
  801343:	e8 0d ff ff ff       	call   801255 <queue_pop>
  801348:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80134b:	83 c4 08             	add    $0x8,%esp
  80134e:	6a 02                	push   $0x2
  801350:	50                   	push   %eax
  801351:	e8 1f f9 ff ff       	call   800c75 <sys_env_set_status>
		if (r < 0) {
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	79 15                	jns    801372 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80135d:	50                   	push   %eax
  80135e:	68 a6 29 80 00       	push   $0x8029a6
  801363:	68 00 01 00 00       	push   $0x100
  801368:	68 e8 28 80 00       	push   $0x8028e8
  80136d:	e8 db ed ff ff       	call   80014d <_panic>
		}
	}

	asm volatile("pause");
  801372:	f3 90                	pause  
	//sys_yield();
}
  801374:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801377:	c9                   	leave  
  801378:	c3                   	ret    

00801379 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	53                   	push   %ebx
  80137d:	83 ec 04             	sub    $0x4,%esp
  801380:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801383:	e8 e8 f7 ff ff       	call   800b70 <sys_getenvid>
  801388:	83 ec 04             	sub    $0x4,%esp
  80138b:	6a 07                	push   $0x7
  80138d:	53                   	push   %ebx
  80138e:	50                   	push   %eax
  80138f:	e8 1a f8 ff ff       	call   800bae <sys_page_alloc>
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	79 15                	jns    8013b0 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80139b:	50                   	push   %eax
  80139c:	68 91 29 80 00       	push   $0x802991
  8013a1:	68 0d 01 00 00       	push   $0x10d
  8013a6:	68 e8 28 80 00       	push   $0x8028e8
  8013ab:	e8 9d ed ff ff       	call   80014d <_panic>
	}	
	mtx->locked = 0;
  8013b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8013b6:	8b 43 04             	mov    0x4(%ebx),%eax
  8013b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8013bf:	8b 43 04             	mov    0x4(%ebx),%eax
  8013c2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8013c9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8013d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d3:	c9                   	leave  
  8013d4:	c3                   	ret    

008013d5 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8013db:	e8 90 f7 ff ff       	call   800b70 <sys_getenvid>
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	ff 75 08             	pushl  0x8(%ebp)
  8013e6:	50                   	push   %eax
  8013e7:	e8 47 f8 ff ff       	call   800c33 <sys_page_unmap>
	if (r < 0) {
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	79 15                	jns    801408 <mutex_destroy+0x33>
		panic("%e\n", r);
  8013f3:	50                   	push   %eax
  8013f4:	68 a6 29 80 00       	push   $0x8029a6
  8013f9:	68 1a 01 00 00       	push   $0x11a
  8013fe:	68 e8 28 80 00       	push   $0x8028e8
  801403:	e8 45 ed ff ff       	call   80014d <_panic>
	}
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	05 00 00 00 30       	add    $0x30000000,%eax
  801415:	c1 e8 0c             	shr    $0xc,%eax
}
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    

0080141a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80141d:	8b 45 08             	mov    0x8(%ebp),%eax
  801420:	05 00 00 00 30       	add    $0x30000000,%eax
  801425:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80142a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801437:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80143c:	89 c2                	mov    %eax,%edx
  80143e:	c1 ea 16             	shr    $0x16,%edx
  801441:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801448:	f6 c2 01             	test   $0x1,%dl
  80144b:	74 11                	je     80145e <fd_alloc+0x2d>
  80144d:	89 c2                	mov    %eax,%edx
  80144f:	c1 ea 0c             	shr    $0xc,%edx
  801452:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801459:	f6 c2 01             	test   $0x1,%dl
  80145c:	75 09                	jne    801467 <fd_alloc+0x36>
			*fd_store = fd;
  80145e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801460:	b8 00 00 00 00       	mov    $0x0,%eax
  801465:	eb 17                	jmp    80147e <fd_alloc+0x4d>
  801467:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80146c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801471:	75 c9                	jne    80143c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801473:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801479:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801486:	83 f8 1f             	cmp    $0x1f,%eax
  801489:	77 36                	ja     8014c1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80148b:	c1 e0 0c             	shl    $0xc,%eax
  80148e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801493:	89 c2                	mov    %eax,%edx
  801495:	c1 ea 16             	shr    $0x16,%edx
  801498:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80149f:	f6 c2 01             	test   $0x1,%dl
  8014a2:	74 24                	je     8014c8 <fd_lookup+0x48>
  8014a4:	89 c2                	mov    %eax,%edx
  8014a6:	c1 ea 0c             	shr    $0xc,%edx
  8014a9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b0:	f6 c2 01             	test   $0x1,%dl
  8014b3:	74 1a                	je     8014cf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b8:	89 02                	mov    %eax,(%edx)
	return 0;
  8014ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bf:	eb 13                	jmp    8014d4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c6:	eb 0c                	jmp    8014d4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cd:	eb 05                	jmp    8014d4 <fd_lookup+0x54>
  8014cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014df:	ba b8 2a 80 00       	mov    $0x802ab8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014e4:	eb 13                	jmp    8014f9 <dev_lookup+0x23>
  8014e6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014e9:	39 08                	cmp    %ecx,(%eax)
  8014eb:	75 0c                	jne    8014f9 <dev_lookup+0x23>
			*dev = devtab[i];
  8014ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f7:	eb 31                	jmp    80152a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014f9:	8b 02                	mov    (%edx),%eax
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	75 e7                	jne    8014e6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ff:	a1 04 40 80 00       	mov    0x804004,%eax
  801504:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80150a:	83 ec 04             	sub    $0x4,%esp
  80150d:	51                   	push   %ecx
  80150e:	50                   	push   %eax
  80150f:	68 38 2a 80 00       	push   $0x802a38
  801514:	e8 0d ed ff ff       	call   800226 <cprintf>
	*dev = 0;
  801519:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80152a:	c9                   	leave  
  80152b:	c3                   	ret    

0080152c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
  801531:	83 ec 10             	sub    $0x10,%esp
  801534:	8b 75 08             	mov    0x8(%ebp),%esi
  801537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80153a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153d:	50                   	push   %eax
  80153e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801544:	c1 e8 0c             	shr    $0xc,%eax
  801547:	50                   	push   %eax
  801548:	e8 33 ff ff ff       	call   801480 <fd_lookup>
  80154d:	83 c4 08             	add    $0x8,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 05                	js     801559 <fd_close+0x2d>
	    || fd != fd2)
  801554:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801557:	74 0c                	je     801565 <fd_close+0x39>
		return (must_exist ? r : 0);
  801559:	84 db                	test   %bl,%bl
  80155b:	ba 00 00 00 00       	mov    $0x0,%edx
  801560:	0f 44 c2             	cmove  %edx,%eax
  801563:	eb 41                	jmp    8015a6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801565:	83 ec 08             	sub    $0x8,%esp
  801568:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	ff 36                	pushl  (%esi)
  80156e:	e8 63 ff ff ff       	call   8014d6 <dev_lookup>
  801573:	89 c3                	mov    %eax,%ebx
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 1a                	js     801596 <fd_close+0x6a>
		if (dev->dev_close)
  80157c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801582:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801587:	85 c0                	test   %eax,%eax
  801589:	74 0b                	je     801596 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	56                   	push   %esi
  80158f:	ff d0                	call   *%eax
  801591:	89 c3                	mov    %eax,%ebx
  801593:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	56                   	push   %esi
  80159a:	6a 00                	push   $0x0
  80159c:	e8 92 f6 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	89 d8                	mov    %ebx,%eax
}
  8015a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a9:	5b                   	pop    %ebx
  8015aa:	5e                   	pop    %esi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    

008015ad <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	ff 75 08             	pushl  0x8(%ebp)
  8015ba:	e8 c1 fe ff ff       	call   801480 <fd_lookup>
  8015bf:	83 c4 08             	add    $0x8,%esp
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 10                	js     8015d6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	6a 01                	push   $0x1
  8015cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ce:	e8 59 ff ff ff       	call   80152c <fd_close>
  8015d3:	83 c4 10             	add    $0x10,%esp
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <close_all>:

void
close_all(void)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015df:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	53                   	push   %ebx
  8015e8:	e8 c0 ff ff ff       	call   8015ad <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ed:	83 c3 01             	add    $0x1,%ebx
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	83 fb 20             	cmp    $0x20,%ebx
  8015f6:	75 ec                	jne    8015e4 <close_all+0xc>
		close(i);
}
  8015f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	57                   	push   %edi
  801601:	56                   	push   %esi
  801602:	53                   	push   %ebx
  801603:	83 ec 2c             	sub    $0x2c,%esp
  801606:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801609:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	ff 75 08             	pushl  0x8(%ebp)
  801610:	e8 6b fe ff ff       	call   801480 <fd_lookup>
  801615:	83 c4 08             	add    $0x8,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	0f 88 c1 00 00 00    	js     8016e1 <dup+0xe4>
		return r;
	close(newfdnum);
  801620:	83 ec 0c             	sub    $0xc,%esp
  801623:	56                   	push   %esi
  801624:	e8 84 ff ff ff       	call   8015ad <close>

	newfd = INDEX2FD(newfdnum);
  801629:	89 f3                	mov    %esi,%ebx
  80162b:	c1 e3 0c             	shl    $0xc,%ebx
  80162e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801634:	83 c4 04             	add    $0x4,%esp
  801637:	ff 75 e4             	pushl  -0x1c(%ebp)
  80163a:	e8 db fd ff ff       	call   80141a <fd2data>
  80163f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801641:	89 1c 24             	mov    %ebx,(%esp)
  801644:	e8 d1 fd ff ff       	call   80141a <fd2data>
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80164f:	89 f8                	mov    %edi,%eax
  801651:	c1 e8 16             	shr    $0x16,%eax
  801654:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80165b:	a8 01                	test   $0x1,%al
  80165d:	74 37                	je     801696 <dup+0x99>
  80165f:	89 f8                	mov    %edi,%eax
  801661:	c1 e8 0c             	shr    $0xc,%eax
  801664:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80166b:	f6 c2 01             	test   $0x1,%dl
  80166e:	74 26                	je     801696 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801670:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801677:	83 ec 0c             	sub    $0xc,%esp
  80167a:	25 07 0e 00 00       	and    $0xe07,%eax
  80167f:	50                   	push   %eax
  801680:	ff 75 d4             	pushl  -0x2c(%ebp)
  801683:	6a 00                	push   $0x0
  801685:	57                   	push   %edi
  801686:	6a 00                	push   $0x0
  801688:	e8 64 f5 ff ff       	call   800bf1 <sys_page_map>
  80168d:	89 c7                	mov    %eax,%edi
  80168f:	83 c4 20             	add    $0x20,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 2e                	js     8016c4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801696:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801699:	89 d0                	mov    %edx,%eax
  80169b:	c1 e8 0c             	shr    $0xc,%eax
  80169e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ad:	50                   	push   %eax
  8016ae:	53                   	push   %ebx
  8016af:	6a 00                	push   $0x0
  8016b1:	52                   	push   %edx
  8016b2:	6a 00                	push   $0x0
  8016b4:	e8 38 f5 ff ff       	call   800bf1 <sys_page_map>
  8016b9:	89 c7                	mov    %eax,%edi
  8016bb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016be:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016c0:	85 ff                	test   %edi,%edi
  8016c2:	79 1d                	jns    8016e1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	53                   	push   %ebx
  8016c8:	6a 00                	push   $0x0
  8016ca:	e8 64 f5 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016cf:	83 c4 08             	add    $0x8,%esp
  8016d2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016d5:	6a 00                	push   $0x0
  8016d7:	e8 57 f5 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	89 f8                	mov    %edi,%eax
}
  8016e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5e                   	pop    %esi
  8016e6:	5f                   	pop    %edi
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    

008016e9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 14             	sub    $0x14,%esp
  8016f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f6:	50                   	push   %eax
  8016f7:	53                   	push   %ebx
  8016f8:	e8 83 fd ff ff       	call   801480 <fd_lookup>
  8016fd:	83 c4 08             	add    $0x8,%esp
  801700:	89 c2                	mov    %eax,%edx
  801702:	85 c0                	test   %eax,%eax
  801704:	78 70                	js     801776 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170c:	50                   	push   %eax
  80170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801710:	ff 30                	pushl  (%eax)
  801712:	e8 bf fd ff ff       	call   8014d6 <dev_lookup>
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 4f                	js     80176d <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80171e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801721:	8b 42 08             	mov    0x8(%edx),%eax
  801724:	83 e0 03             	and    $0x3,%eax
  801727:	83 f8 01             	cmp    $0x1,%eax
  80172a:	75 24                	jne    801750 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80172c:	a1 04 40 80 00       	mov    0x804004,%eax
  801731:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	53                   	push   %ebx
  80173b:	50                   	push   %eax
  80173c:	68 7c 2a 80 00       	push   $0x802a7c
  801741:	e8 e0 ea ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80174e:	eb 26                	jmp    801776 <read+0x8d>
	}
	if (!dev->dev_read)
  801750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801753:	8b 40 08             	mov    0x8(%eax),%eax
  801756:	85 c0                	test   %eax,%eax
  801758:	74 17                	je     801771 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80175a:	83 ec 04             	sub    $0x4,%esp
  80175d:	ff 75 10             	pushl  0x10(%ebp)
  801760:	ff 75 0c             	pushl  0xc(%ebp)
  801763:	52                   	push   %edx
  801764:	ff d0                	call   *%eax
  801766:	89 c2                	mov    %eax,%edx
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	eb 09                	jmp    801776 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176d:	89 c2                	mov    %eax,%edx
  80176f:	eb 05                	jmp    801776 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801771:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801776:	89 d0                	mov    %edx,%eax
  801778:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177b:	c9                   	leave  
  80177c:	c3                   	ret    

0080177d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	57                   	push   %edi
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	83 ec 0c             	sub    $0xc,%esp
  801786:	8b 7d 08             	mov    0x8(%ebp),%edi
  801789:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80178c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801791:	eb 21                	jmp    8017b4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801793:	83 ec 04             	sub    $0x4,%esp
  801796:	89 f0                	mov    %esi,%eax
  801798:	29 d8                	sub    %ebx,%eax
  80179a:	50                   	push   %eax
  80179b:	89 d8                	mov    %ebx,%eax
  80179d:	03 45 0c             	add    0xc(%ebp),%eax
  8017a0:	50                   	push   %eax
  8017a1:	57                   	push   %edi
  8017a2:	e8 42 ff ff ff       	call   8016e9 <read>
		if (m < 0)
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 10                	js     8017be <readn+0x41>
			return m;
		if (m == 0)
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	74 0a                	je     8017bc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b2:	01 c3                	add    %eax,%ebx
  8017b4:	39 f3                	cmp    %esi,%ebx
  8017b6:	72 db                	jb     801793 <readn+0x16>
  8017b8:	89 d8                	mov    %ebx,%eax
  8017ba:	eb 02                	jmp    8017be <readn+0x41>
  8017bc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c1:	5b                   	pop    %ebx
  8017c2:	5e                   	pop    %esi
  8017c3:	5f                   	pop    %edi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 14             	sub    $0x14,%esp
  8017cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d3:	50                   	push   %eax
  8017d4:	53                   	push   %ebx
  8017d5:	e8 a6 fc ff ff       	call   801480 <fd_lookup>
  8017da:	83 c4 08             	add    $0x8,%esp
  8017dd:	89 c2                	mov    %eax,%edx
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 6b                	js     80184e <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e9:	50                   	push   %eax
  8017ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ed:	ff 30                	pushl  (%eax)
  8017ef:	e8 e2 fc ff ff       	call   8014d6 <dev_lookup>
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 4a                	js     801845 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801802:	75 24                	jne    801828 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801804:	a1 04 40 80 00       	mov    0x804004,%eax
  801809:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	53                   	push   %ebx
  801813:	50                   	push   %eax
  801814:	68 98 2a 80 00       	push   $0x802a98
  801819:	e8 08 ea ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801826:	eb 26                	jmp    80184e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801828:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182b:	8b 52 0c             	mov    0xc(%edx),%edx
  80182e:	85 d2                	test   %edx,%edx
  801830:	74 17                	je     801849 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801832:	83 ec 04             	sub    $0x4,%esp
  801835:	ff 75 10             	pushl  0x10(%ebp)
  801838:	ff 75 0c             	pushl  0xc(%ebp)
  80183b:	50                   	push   %eax
  80183c:	ff d2                	call   *%edx
  80183e:	89 c2                	mov    %eax,%edx
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	eb 09                	jmp    80184e <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801845:	89 c2                	mov    %eax,%edx
  801847:	eb 05                	jmp    80184e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801849:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80184e:	89 d0                	mov    %edx,%eax
  801850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <seek>:

int
seek(int fdnum, off_t offset)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80185e:	50                   	push   %eax
  80185f:	ff 75 08             	pushl  0x8(%ebp)
  801862:	e8 19 fc ff ff       	call   801480 <fd_lookup>
  801867:	83 c4 08             	add    $0x8,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 0e                	js     80187c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80186e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801871:	8b 55 0c             	mov    0xc(%ebp),%edx
  801874:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801877:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 14             	sub    $0x14,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801888:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188b:	50                   	push   %eax
  80188c:	53                   	push   %ebx
  80188d:	e8 ee fb ff ff       	call   801480 <fd_lookup>
  801892:	83 c4 08             	add    $0x8,%esp
  801895:	89 c2                	mov    %eax,%edx
  801897:	85 c0                	test   %eax,%eax
  801899:	78 68                	js     801903 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a1:	50                   	push   %eax
  8018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a5:	ff 30                	pushl  (%eax)
  8018a7:	e8 2a fc ff ff       	call   8014d6 <dev_lookup>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 47                	js     8018fa <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ba:	75 24                	jne    8018e0 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018bc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	53                   	push   %ebx
  8018cb:	50                   	push   %eax
  8018cc:	68 58 2a 80 00       	push   $0x802a58
  8018d1:	e8 50 e9 ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018de:	eb 23                	jmp    801903 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e3:	8b 52 18             	mov    0x18(%edx),%edx
  8018e6:	85 d2                	test   %edx,%edx
  8018e8:	74 14                	je     8018fe <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	ff 75 0c             	pushl  0xc(%ebp)
  8018f0:	50                   	push   %eax
  8018f1:	ff d2                	call   *%edx
  8018f3:	89 c2                	mov    %eax,%edx
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	eb 09                	jmp    801903 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fa:	89 c2                	mov    %eax,%edx
  8018fc:	eb 05                	jmp    801903 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801903:	89 d0                	mov    %edx,%eax
  801905:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	53                   	push   %ebx
  80190e:	83 ec 14             	sub    $0x14,%esp
  801911:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801914:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801917:	50                   	push   %eax
  801918:	ff 75 08             	pushl  0x8(%ebp)
  80191b:	e8 60 fb ff ff       	call   801480 <fd_lookup>
  801920:	83 c4 08             	add    $0x8,%esp
  801923:	89 c2                	mov    %eax,%edx
  801925:	85 c0                	test   %eax,%eax
  801927:	78 58                	js     801981 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801933:	ff 30                	pushl  (%eax)
  801935:	e8 9c fb ff ff       	call   8014d6 <dev_lookup>
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 37                	js     801978 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801941:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801944:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801948:	74 32                	je     80197c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80194a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80194d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801954:	00 00 00 
	stat->st_isdir = 0;
  801957:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80195e:	00 00 00 
	stat->st_dev = dev;
  801961:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801967:	83 ec 08             	sub    $0x8,%esp
  80196a:	53                   	push   %ebx
  80196b:	ff 75 f0             	pushl  -0x10(%ebp)
  80196e:	ff 50 14             	call   *0x14(%eax)
  801971:	89 c2                	mov    %eax,%edx
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	eb 09                	jmp    801981 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801978:	89 c2                	mov    %eax,%edx
  80197a:	eb 05                	jmp    801981 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80197c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801981:	89 d0                	mov    %edx,%eax
  801983:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80198d:	83 ec 08             	sub    $0x8,%esp
  801990:	6a 00                	push   $0x0
  801992:	ff 75 08             	pushl  0x8(%ebp)
  801995:	e8 e3 01 00 00       	call   801b7d <open>
  80199a:	89 c3                	mov    %eax,%ebx
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 1b                	js     8019be <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019a3:	83 ec 08             	sub    $0x8,%esp
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	50                   	push   %eax
  8019aa:	e8 5b ff ff ff       	call   80190a <fstat>
  8019af:	89 c6                	mov    %eax,%esi
	close(fd);
  8019b1:	89 1c 24             	mov    %ebx,(%esp)
  8019b4:	e8 f4 fb ff ff       	call   8015ad <close>
	return r;
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	89 f0                	mov    %esi,%eax
}
  8019be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c1:	5b                   	pop    %ebx
  8019c2:	5e                   	pop    %esi
  8019c3:	5d                   	pop    %ebp
  8019c4:	c3                   	ret    

008019c5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	56                   	push   %esi
  8019c9:	53                   	push   %ebx
  8019ca:	89 c6                	mov    %eax,%esi
  8019cc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019ce:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019d5:	75 12                	jne    8019e9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	6a 01                	push   $0x1
  8019dc:	e8 05 08 00 00       	call   8021e6 <ipc_find_env>
  8019e1:	a3 00 40 80 00       	mov    %eax,0x804000
  8019e6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019e9:	6a 07                	push   $0x7
  8019eb:	68 00 50 80 00       	push   $0x805000
  8019f0:	56                   	push   %esi
  8019f1:	ff 35 00 40 80 00    	pushl  0x804000
  8019f7:	e8 88 07 00 00       	call   802184 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019fc:	83 c4 0c             	add    $0xc,%esp
  8019ff:	6a 00                	push   $0x0
  801a01:	53                   	push   %ebx
  801a02:	6a 00                	push   $0x0
  801a04:	e8 00 07 00 00       	call   802109 <ipc_recv>
}
  801a09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0c:	5b                   	pop    %ebx
  801a0d:	5e                   	pop    %esi
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a16:	8b 45 08             	mov    0x8(%ebp),%eax
  801a19:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a24:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a29:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2e:	b8 02 00 00 00       	mov    $0x2,%eax
  801a33:	e8 8d ff ff ff       	call   8019c5 <fsipc>
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	8b 40 0c             	mov    0xc(%eax),%eax
  801a46:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a50:	b8 06 00 00 00       	mov    $0x6,%eax
  801a55:	e8 6b ff ff ff       	call   8019c5 <fsipc>
}
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    

00801a5c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 04             	sub    $0x4,%esp
  801a63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a66:	8b 45 08             	mov    0x8(%ebp),%eax
  801a69:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	b8 05 00 00 00       	mov    $0x5,%eax
  801a7b:	e8 45 ff ff ff       	call   8019c5 <fsipc>
  801a80:	85 c0                	test   %eax,%eax
  801a82:	78 2c                	js     801ab0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a84:	83 ec 08             	sub    $0x8,%esp
  801a87:	68 00 50 80 00       	push   $0x805000
  801a8c:	53                   	push   %ebx
  801a8d:	e8 19 ed ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a92:	a1 80 50 80 00       	mov    0x805080,%eax
  801a97:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a9d:	a1 84 50 80 00       	mov    0x805084,%eax
  801aa2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 0c             	sub    $0xc,%esp
  801abb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801abe:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac1:	8b 52 0c             	mov    0xc(%edx),%edx
  801ac4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801aca:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801acf:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ad4:	0f 47 c2             	cmova  %edx,%eax
  801ad7:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801adc:	50                   	push   %eax
  801add:	ff 75 0c             	pushl  0xc(%ebp)
  801ae0:	68 08 50 80 00       	push   $0x805008
  801ae5:	e8 53 ee ff ff       	call   80093d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801aea:	ba 00 00 00 00       	mov    $0x0,%edx
  801aef:	b8 04 00 00 00       	mov    $0x4,%eax
  801af4:	e8 cc fe ff ff       	call   8019c5 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	8b 40 0c             	mov    0xc(%eax),%eax
  801b09:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b0e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b14:	ba 00 00 00 00       	mov    $0x0,%edx
  801b19:	b8 03 00 00 00       	mov    $0x3,%eax
  801b1e:	e8 a2 fe ff ff       	call   8019c5 <fsipc>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 4b                	js     801b74 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b29:	39 c6                	cmp    %eax,%esi
  801b2b:	73 16                	jae    801b43 <devfile_read+0x48>
  801b2d:	68 c8 2a 80 00       	push   $0x802ac8
  801b32:	68 cf 2a 80 00       	push   $0x802acf
  801b37:	6a 7c                	push   $0x7c
  801b39:	68 e4 2a 80 00       	push   $0x802ae4
  801b3e:	e8 0a e6 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  801b43:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b48:	7e 16                	jle    801b60 <devfile_read+0x65>
  801b4a:	68 ef 2a 80 00       	push   $0x802aef
  801b4f:	68 cf 2a 80 00       	push   $0x802acf
  801b54:	6a 7d                	push   $0x7d
  801b56:	68 e4 2a 80 00       	push   $0x802ae4
  801b5b:	e8 ed e5 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b60:	83 ec 04             	sub    $0x4,%esp
  801b63:	50                   	push   %eax
  801b64:	68 00 50 80 00       	push   $0x805000
  801b69:	ff 75 0c             	pushl  0xc(%ebp)
  801b6c:	e8 cc ed ff ff       	call   80093d <memmove>
	return r;
  801b71:	83 c4 10             	add    $0x10,%esp
}
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	53                   	push   %ebx
  801b81:	83 ec 20             	sub    $0x20,%esp
  801b84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b87:	53                   	push   %ebx
  801b88:	e8 e5 eb ff ff       	call   800772 <strlen>
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b95:	7f 67                	jg     801bfe <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9d:	50                   	push   %eax
  801b9e:	e8 8e f8 ff ff       	call   801431 <fd_alloc>
  801ba3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ba6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 57                	js     801c03 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bac:	83 ec 08             	sub    $0x8,%esp
  801baf:	53                   	push   %ebx
  801bb0:	68 00 50 80 00       	push   $0x805000
  801bb5:	e8 f1 eb ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc5:	b8 01 00 00 00       	mov    $0x1,%eax
  801bca:	e8 f6 fd ff ff       	call   8019c5 <fsipc>
  801bcf:	89 c3                	mov    %eax,%ebx
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	79 14                	jns    801bec <open+0x6f>
		fd_close(fd, 0);
  801bd8:	83 ec 08             	sub    $0x8,%esp
  801bdb:	6a 00                	push   $0x0
  801bdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801be0:	e8 47 f9 ff ff       	call   80152c <fd_close>
		return r;
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	89 da                	mov    %ebx,%edx
  801bea:	eb 17                	jmp    801c03 <open+0x86>
	}

	return fd2num(fd);
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf2:	e8 13 f8 ff ff       	call   80140a <fd2num>
  801bf7:	89 c2                	mov    %eax,%edx
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	eb 05                	jmp    801c03 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bfe:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c03:	89 d0                	mov    %edx,%eax
  801c05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c10:	ba 00 00 00 00       	mov    $0x0,%edx
  801c15:	b8 08 00 00 00       	mov    $0x8,%eax
  801c1a:	e8 a6 fd ff ff       	call   8019c5 <fsipc>
}
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	ff 75 08             	pushl  0x8(%ebp)
  801c2f:	e8 e6 f7 ff ff       	call   80141a <fd2data>
  801c34:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c36:	83 c4 08             	add    $0x8,%esp
  801c39:	68 fb 2a 80 00       	push   $0x802afb
  801c3e:	53                   	push   %ebx
  801c3f:	e8 67 eb ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c44:	8b 46 04             	mov    0x4(%esi),%eax
  801c47:	2b 06                	sub    (%esi),%eax
  801c49:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c4f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c56:	00 00 00 
	stat->st_dev = &devpipe;
  801c59:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c60:	30 80 00 
	return 0;
}
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
  801c68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5e                   	pop    %esi
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	53                   	push   %ebx
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c79:	53                   	push   %ebx
  801c7a:	6a 00                	push   $0x0
  801c7c:	e8 b2 ef ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c81:	89 1c 24             	mov    %ebx,(%esp)
  801c84:	e8 91 f7 ff ff       	call   80141a <fd2data>
  801c89:	83 c4 08             	add    $0x8,%esp
  801c8c:	50                   	push   %eax
  801c8d:	6a 00                	push   $0x0
  801c8f:	e8 9f ef ff ff       	call   800c33 <sys_page_unmap>
}
  801c94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	57                   	push   %edi
  801c9d:	56                   	push   %esi
  801c9e:	53                   	push   %ebx
  801c9f:	83 ec 1c             	sub    $0x1c,%esp
  801ca2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ca5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ca7:	a1 04 40 80 00       	mov    0x804004,%eax
  801cac:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cb2:	83 ec 0c             	sub    $0xc,%esp
  801cb5:	ff 75 e0             	pushl  -0x20(%ebp)
  801cb8:	e8 6e 05 00 00       	call   80222b <pageref>
  801cbd:	89 c3                	mov    %eax,%ebx
  801cbf:	89 3c 24             	mov    %edi,(%esp)
  801cc2:	e8 64 05 00 00       	call   80222b <pageref>
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	39 c3                	cmp    %eax,%ebx
  801ccc:	0f 94 c1             	sete   %cl
  801ccf:	0f b6 c9             	movzbl %cl,%ecx
  801cd2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cd5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cdb:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801ce1:	39 ce                	cmp    %ecx,%esi
  801ce3:	74 1e                	je     801d03 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ce5:	39 c3                	cmp    %eax,%ebx
  801ce7:	75 be                	jne    801ca7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ce9:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801cef:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cf2:	50                   	push   %eax
  801cf3:	56                   	push   %esi
  801cf4:	68 02 2b 80 00       	push   $0x802b02
  801cf9:	e8 28 e5 ff ff       	call   800226 <cprintf>
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	eb a4                	jmp    801ca7 <_pipeisclosed+0xe>
	}
}
  801d03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d09:	5b                   	pop    %ebx
  801d0a:	5e                   	pop    %esi
  801d0b:	5f                   	pop    %edi
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    

00801d0e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 28             	sub    $0x28,%esp
  801d17:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d1a:	56                   	push   %esi
  801d1b:	e8 fa f6 ff ff       	call   80141a <fd2data>
  801d20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d22:	83 c4 10             	add    $0x10,%esp
  801d25:	bf 00 00 00 00       	mov    $0x0,%edi
  801d2a:	eb 4b                	jmp    801d77 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d2c:	89 da                	mov    %ebx,%edx
  801d2e:	89 f0                	mov    %esi,%eax
  801d30:	e8 64 ff ff ff       	call   801c99 <_pipeisclosed>
  801d35:	85 c0                	test   %eax,%eax
  801d37:	75 48                	jne    801d81 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d39:	e8 51 ee ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d3e:	8b 43 04             	mov    0x4(%ebx),%eax
  801d41:	8b 0b                	mov    (%ebx),%ecx
  801d43:	8d 51 20             	lea    0x20(%ecx),%edx
  801d46:	39 d0                	cmp    %edx,%eax
  801d48:	73 e2                	jae    801d2c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d4d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d51:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d54:	89 c2                	mov    %eax,%edx
  801d56:	c1 fa 1f             	sar    $0x1f,%edx
  801d59:	89 d1                	mov    %edx,%ecx
  801d5b:	c1 e9 1b             	shr    $0x1b,%ecx
  801d5e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d61:	83 e2 1f             	and    $0x1f,%edx
  801d64:	29 ca                	sub    %ecx,%edx
  801d66:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d6a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d6e:	83 c0 01             	add    $0x1,%eax
  801d71:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d74:	83 c7 01             	add    $0x1,%edi
  801d77:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d7a:	75 c2                	jne    801d3e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d7f:	eb 05                	jmp    801d86 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d81:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d89:	5b                   	pop    %ebx
  801d8a:	5e                   	pop    %esi
  801d8b:	5f                   	pop    %edi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	83 ec 18             	sub    $0x18,%esp
  801d97:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d9a:	57                   	push   %edi
  801d9b:	e8 7a f6 ff ff       	call   80141a <fd2data>
  801da0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801daa:	eb 3d                	jmp    801de9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dac:	85 db                	test   %ebx,%ebx
  801dae:	74 04                	je     801db4 <devpipe_read+0x26>
				return i;
  801db0:	89 d8                	mov    %ebx,%eax
  801db2:	eb 44                	jmp    801df8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801db4:	89 f2                	mov    %esi,%edx
  801db6:	89 f8                	mov    %edi,%eax
  801db8:	e8 dc fe ff ff       	call   801c99 <_pipeisclosed>
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	75 32                	jne    801df3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dc1:	e8 c9 ed ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dc6:	8b 06                	mov    (%esi),%eax
  801dc8:	3b 46 04             	cmp    0x4(%esi),%eax
  801dcb:	74 df                	je     801dac <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dcd:	99                   	cltd   
  801dce:	c1 ea 1b             	shr    $0x1b,%edx
  801dd1:	01 d0                	add    %edx,%eax
  801dd3:	83 e0 1f             	and    $0x1f,%eax
  801dd6:	29 d0                	sub    %edx,%eax
  801dd8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801de0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801de3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de6:	83 c3 01             	add    $0x1,%ebx
  801de9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dec:	75 d8                	jne    801dc6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dee:	8b 45 10             	mov    0x10(%ebp),%eax
  801df1:	eb 05                	jmp    801df8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfb:	5b                   	pop    %ebx
  801dfc:	5e                   	pop    %esi
  801dfd:	5f                   	pop    %edi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	56                   	push   %esi
  801e04:	53                   	push   %ebx
  801e05:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	e8 20 f6 ff ff       	call   801431 <fd_alloc>
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	89 c2                	mov    %eax,%edx
  801e16:	85 c0                	test   %eax,%eax
  801e18:	0f 88 2c 01 00 00    	js     801f4a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e1e:	83 ec 04             	sub    $0x4,%esp
  801e21:	68 07 04 00 00       	push   $0x407
  801e26:	ff 75 f4             	pushl  -0xc(%ebp)
  801e29:	6a 00                	push   $0x0
  801e2b:	e8 7e ed ff ff       	call   800bae <sys_page_alloc>
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	89 c2                	mov    %eax,%edx
  801e35:	85 c0                	test   %eax,%eax
  801e37:	0f 88 0d 01 00 00    	js     801f4a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e3d:	83 ec 0c             	sub    $0xc,%esp
  801e40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e43:	50                   	push   %eax
  801e44:	e8 e8 f5 ff ff       	call   801431 <fd_alloc>
  801e49:	89 c3                	mov    %eax,%ebx
  801e4b:	83 c4 10             	add    $0x10,%esp
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	0f 88 e2 00 00 00    	js     801f38 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e56:	83 ec 04             	sub    $0x4,%esp
  801e59:	68 07 04 00 00       	push   $0x407
  801e5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e61:	6a 00                	push   $0x0
  801e63:	e8 46 ed ff ff       	call   800bae <sys_page_alloc>
  801e68:	89 c3                	mov    %eax,%ebx
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	0f 88 c3 00 00 00    	js     801f38 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e75:	83 ec 0c             	sub    $0xc,%esp
  801e78:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7b:	e8 9a f5 ff ff       	call   80141a <fd2data>
  801e80:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e82:	83 c4 0c             	add    $0xc,%esp
  801e85:	68 07 04 00 00       	push   $0x407
  801e8a:	50                   	push   %eax
  801e8b:	6a 00                	push   $0x0
  801e8d:	e8 1c ed ff ff       	call   800bae <sys_page_alloc>
  801e92:	89 c3                	mov    %eax,%ebx
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	85 c0                	test   %eax,%eax
  801e99:	0f 88 89 00 00 00    	js     801f28 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e9f:	83 ec 0c             	sub    $0xc,%esp
  801ea2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea5:	e8 70 f5 ff ff       	call   80141a <fd2data>
  801eaa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eb1:	50                   	push   %eax
  801eb2:	6a 00                	push   $0x0
  801eb4:	56                   	push   %esi
  801eb5:	6a 00                	push   $0x0
  801eb7:	e8 35 ed ff ff       	call   800bf1 <sys_page_map>
  801ebc:	89 c3                	mov    %eax,%ebx
  801ebe:	83 c4 20             	add    $0x20,%esp
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 55                	js     801f1a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ec5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ece:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eda:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ee0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ee8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eef:	83 ec 0c             	sub    $0xc,%esp
  801ef2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef5:	e8 10 f5 ff ff       	call   80140a <fd2num>
  801efa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801efd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801eff:	83 c4 04             	add    $0x4,%esp
  801f02:	ff 75 f0             	pushl  -0x10(%ebp)
  801f05:	e8 00 f5 ff ff       	call   80140a <fd2num>
  801f0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f0d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	ba 00 00 00 00       	mov    $0x0,%edx
  801f18:	eb 30                	jmp    801f4a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	56                   	push   %esi
  801f1e:	6a 00                	push   $0x0
  801f20:	e8 0e ed ff ff       	call   800c33 <sys_page_unmap>
  801f25:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f28:	83 ec 08             	sub    $0x8,%esp
  801f2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2e:	6a 00                	push   $0x0
  801f30:	e8 fe ec ff ff       	call   800c33 <sys_page_unmap>
  801f35:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f38:	83 ec 08             	sub    $0x8,%esp
  801f3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3e:	6a 00                	push   $0x0
  801f40:	e8 ee ec ff ff       	call   800c33 <sys_page_unmap>
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f4a:	89 d0                	mov    %edx,%eax
  801f4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5c:	50                   	push   %eax
  801f5d:	ff 75 08             	pushl  0x8(%ebp)
  801f60:	e8 1b f5 ff ff       	call   801480 <fd_lookup>
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	78 18                	js     801f84 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f6c:	83 ec 0c             	sub    $0xc,%esp
  801f6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f72:	e8 a3 f4 ff ff       	call   80141a <fd2data>
	return _pipeisclosed(fd, p);
  801f77:	89 c2                	mov    %eax,%edx
  801f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7c:	e8 18 fd ff ff       	call   801c99 <_pipeisclosed>
  801f81:	83 c4 10             	add    $0x10,%esp
}
  801f84:	c9                   	leave  
  801f85:	c3                   	ret    

00801f86 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    

00801f90 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f96:	68 1a 2b 80 00       	push   $0x802b1a
  801f9b:	ff 75 0c             	pushl  0xc(%ebp)
  801f9e:	e8 08 e8 ff ff       	call   8007ab <strcpy>
	return 0;
}
  801fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    

00801faa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	57                   	push   %edi
  801fae:	56                   	push   %esi
  801faf:	53                   	push   %ebx
  801fb0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fbb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc1:	eb 2d                	jmp    801ff0 <devcons_write+0x46>
		m = n - tot;
  801fc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fc6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fc8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fcb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fd0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fd3:	83 ec 04             	sub    $0x4,%esp
  801fd6:	53                   	push   %ebx
  801fd7:	03 45 0c             	add    0xc(%ebp),%eax
  801fda:	50                   	push   %eax
  801fdb:	57                   	push   %edi
  801fdc:	e8 5c e9 ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  801fe1:	83 c4 08             	add    $0x8,%esp
  801fe4:	53                   	push   %ebx
  801fe5:	57                   	push   %edi
  801fe6:	e8 07 eb ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801feb:	01 de                	add    %ebx,%esi
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	89 f0                	mov    %esi,%eax
  801ff2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ff5:	72 cc                	jb     801fc3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ff7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffa:	5b                   	pop    %ebx
  801ffb:	5e                   	pop    %esi
  801ffc:	5f                   	pop    %edi
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    

00801fff <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	83 ec 08             	sub    $0x8,%esp
  802005:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80200a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80200e:	74 2a                	je     80203a <devcons_read+0x3b>
  802010:	eb 05                	jmp    802017 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802012:	e8 78 eb ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802017:	e8 f4 ea ff ff       	call   800b10 <sys_cgetc>
  80201c:	85 c0                	test   %eax,%eax
  80201e:	74 f2                	je     802012 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802020:	85 c0                	test   %eax,%eax
  802022:	78 16                	js     80203a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802024:	83 f8 04             	cmp    $0x4,%eax
  802027:	74 0c                	je     802035 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802029:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202c:	88 02                	mov    %al,(%edx)
	return 1;
  80202e:	b8 01 00 00 00       	mov    $0x1,%eax
  802033:	eb 05                	jmp    80203a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802035:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80203a:	c9                   	leave  
  80203b:	c3                   	ret    

0080203c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802042:	8b 45 08             	mov    0x8(%ebp),%eax
  802045:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802048:	6a 01                	push   $0x1
  80204a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204d:	50                   	push   %eax
  80204e:	e8 9f ea ff ff       	call   800af2 <sys_cputs>
}
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	c9                   	leave  
  802057:	c3                   	ret    

00802058 <getchar>:

int
getchar(void)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80205e:	6a 01                	push   $0x1
  802060:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802063:	50                   	push   %eax
  802064:	6a 00                	push   $0x0
  802066:	e8 7e f6 ff ff       	call   8016e9 <read>
	if (r < 0)
  80206b:	83 c4 10             	add    $0x10,%esp
  80206e:	85 c0                	test   %eax,%eax
  802070:	78 0f                	js     802081 <getchar+0x29>
		return r;
	if (r < 1)
  802072:	85 c0                	test   %eax,%eax
  802074:	7e 06                	jle    80207c <getchar+0x24>
		return -E_EOF;
	return c;
  802076:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80207a:	eb 05                	jmp    802081 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80207c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802081:	c9                   	leave  
  802082:	c3                   	ret    

00802083 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802089:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208c:	50                   	push   %eax
  80208d:	ff 75 08             	pushl  0x8(%ebp)
  802090:	e8 eb f3 ff ff       	call   801480 <fd_lookup>
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	85 c0                	test   %eax,%eax
  80209a:	78 11                	js     8020ad <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80209c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a5:	39 10                	cmp    %edx,(%eax)
  8020a7:	0f 94 c0             	sete   %al
  8020aa:	0f b6 c0             	movzbl %al,%eax
}
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <opencons>:

int
opencons(void)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b8:	50                   	push   %eax
  8020b9:	e8 73 f3 ff ff       	call   801431 <fd_alloc>
  8020be:	83 c4 10             	add    $0x10,%esp
		return r;
  8020c1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	78 3e                	js     802105 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020c7:	83 ec 04             	sub    $0x4,%esp
  8020ca:	68 07 04 00 00       	push   $0x407
  8020cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d2:	6a 00                	push   $0x0
  8020d4:	e8 d5 ea ff ff       	call   800bae <sys_page_alloc>
  8020d9:	83 c4 10             	add    $0x10,%esp
		return r;
  8020dc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	78 23                	js     802105 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020e2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020eb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020f7:	83 ec 0c             	sub    $0xc,%esp
  8020fa:	50                   	push   %eax
  8020fb:	e8 0a f3 ff ff       	call   80140a <fd2num>
  802100:	89 c2                	mov    %eax,%edx
  802102:	83 c4 10             	add    $0x10,%esp
}
  802105:	89 d0                	mov    %edx,%eax
  802107:	c9                   	leave  
  802108:	c3                   	ret    

00802109 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802109:	55                   	push   %ebp
  80210a:	89 e5                	mov    %esp,%ebp
  80210c:	56                   	push   %esi
  80210d:	53                   	push   %ebx
  80210e:	8b 75 08             	mov    0x8(%ebp),%esi
  802111:	8b 45 0c             	mov    0xc(%ebp),%eax
  802114:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802117:	85 c0                	test   %eax,%eax
  802119:	75 12                	jne    80212d <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80211b:	83 ec 0c             	sub    $0xc,%esp
  80211e:	68 00 00 c0 ee       	push   $0xeec00000
  802123:	e8 36 ec ff ff       	call   800d5e <sys_ipc_recv>
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	eb 0c                	jmp    802139 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80212d:	83 ec 0c             	sub    $0xc,%esp
  802130:	50                   	push   %eax
  802131:	e8 28 ec ff ff       	call   800d5e <sys_ipc_recv>
  802136:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802139:	85 f6                	test   %esi,%esi
  80213b:	0f 95 c1             	setne  %cl
  80213e:	85 db                	test   %ebx,%ebx
  802140:	0f 95 c2             	setne  %dl
  802143:	84 d1                	test   %dl,%cl
  802145:	74 09                	je     802150 <ipc_recv+0x47>
  802147:	89 c2                	mov    %eax,%edx
  802149:	c1 ea 1f             	shr    $0x1f,%edx
  80214c:	84 d2                	test   %dl,%dl
  80214e:	75 2d                	jne    80217d <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802150:	85 f6                	test   %esi,%esi
  802152:	74 0d                	je     802161 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802154:	a1 04 40 80 00       	mov    0x804004,%eax
  802159:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80215f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802161:	85 db                	test   %ebx,%ebx
  802163:	74 0d                	je     802172 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802165:	a1 04 40 80 00       	mov    0x804004,%eax
  80216a:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802170:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802172:	a1 04 40 80 00       	mov    0x804004,%eax
  802177:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80217d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802180:	5b                   	pop    %ebx
  802181:	5e                   	pop    %esi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    

00802184 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	57                   	push   %edi
  802188:	56                   	push   %esi
  802189:	53                   	push   %ebx
  80218a:	83 ec 0c             	sub    $0xc,%esp
  80218d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802190:	8b 75 0c             	mov    0xc(%ebp),%esi
  802193:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802196:	85 db                	test   %ebx,%ebx
  802198:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80219d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021a0:	ff 75 14             	pushl  0x14(%ebp)
  8021a3:	53                   	push   %ebx
  8021a4:	56                   	push   %esi
  8021a5:	57                   	push   %edi
  8021a6:	e8 90 eb ff ff       	call   800d3b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8021ab:	89 c2                	mov    %eax,%edx
  8021ad:	c1 ea 1f             	shr    $0x1f,%edx
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	84 d2                	test   %dl,%dl
  8021b5:	74 17                	je     8021ce <ipc_send+0x4a>
  8021b7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ba:	74 12                	je     8021ce <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021bc:	50                   	push   %eax
  8021bd:	68 26 2b 80 00       	push   $0x802b26
  8021c2:	6a 47                	push   $0x47
  8021c4:	68 34 2b 80 00       	push   $0x802b34
  8021c9:	e8 7f df ff ff       	call   80014d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021ce:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021d1:	75 07                	jne    8021da <ipc_send+0x56>
			sys_yield();
  8021d3:	e8 b7 e9 ff ff       	call   800b8f <sys_yield>
  8021d8:	eb c6                	jmp    8021a0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021da:	85 c0                	test   %eax,%eax
  8021dc:	75 c2                	jne    8021a0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021e1:	5b                   	pop    %ebx
  8021e2:	5e                   	pop    %esi
  8021e3:	5f                   	pop    %edi
  8021e4:	5d                   	pop    %ebp
  8021e5:	c3                   	ret    

008021e6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021ec:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021f1:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8021f7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021fd:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802203:	39 ca                	cmp    %ecx,%edx
  802205:	75 13                	jne    80221a <ipc_find_env+0x34>
			return envs[i].env_id;
  802207:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80220d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802212:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802218:	eb 0f                	jmp    802229 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80221a:	83 c0 01             	add    $0x1,%eax
  80221d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802222:	75 cd                	jne    8021f1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802224:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    

0080222b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802231:	89 d0                	mov    %edx,%eax
  802233:	c1 e8 16             	shr    $0x16,%eax
  802236:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80223d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802242:	f6 c1 01             	test   $0x1,%cl
  802245:	74 1d                	je     802264 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802247:	c1 ea 0c             	shr    $0xc,%edx
  80224a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802251:	f6 c2 01             	test   $0x1,%dl
  802254:	74 0e                	je     802264 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802256:	c1 ea 0c             	shr    $0xc,%edx
  802259:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802260:	ef 
  802261:	0f b7 c0             	movzwl %ax,%eax
}
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    
  802266:	66 90                	xchg   %ax,%ax
  802268:	66 90                	xchg   %ax,%ax
  80226a:	66 90                	xchg   %ax,%ax
  80226c:	66 90                	xchg   %ax,%ax
  80226e:	66 90                	xchg   %ax,%ax

00802270 <__udivdi3>:
  802270:	55                   	push   %ebp
  802271:	57                   	push   %edi
  802272:	56                   	push   %esi
  802273:	53                   	push   %ebx
  802274:	83 ec 1c             	sub    $0x1c,%esp
  802277:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80227b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80227f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802283:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802287:	85 f6                	test   %esi,%esi
  802289:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80228d:	89 ca                	mov    %ecx,%edx
  80228f:	89 f8                	mov    %edi,%eax
  802291:	75 3d                	jne    8022d0 <__udivdi3+0x60>
  802293:	39 cf                	cmp    %ecx,%edi
  802295:	0f 87 c5 00 00 00    	ja     802360 <__udivdi3+0xf0>
  80229b:	85 ff                	test   %edi,%edi
  80229d:	89 fd                	mov    %edi,%ebp
  80229f:	75 0b                	jne    8022ac <__udivdi3+0x3c>
  8022a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a6:	31 d2                	xor    %edx,%edx
  8022a8:	f7 f7                	div    %edi
  8022aa:	89 c5                	mov    %eax,%ebp
  8022ac:	89 c8                	mov    %ecx,%eax
  8022ae:	31 d2                	xor    %edx,%edx
  8022b0:	f7 f5                	div    %ebp
  8022b2:	89 c1                	mov    %eax,%ecx
  8022b4:	89 d8                	mov    %ebx,%eax
  8022b6:	89 cf                	mov    %ecx,%edi
  8022b8:	f7 f5                	div    %ebp
  8022ba:	89 c3                	mov    %eax,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	39 ce                	cmp    %ecx,%esi
  8022d2:	77 74                	ja     802348 <__udivdi3+0xd8>
  8022d4:	0f bd fe             	bsr    %esi,%edi
  8022d7:	83 f7 1f             	xor    $0x1f,%edi
  8022da:	0f 84 98 00 00 00    	je     802378 <__udivdi3+0x108>
  8022e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022e5:	89 f9                	mov    %edi,%ecx
  8022e7:	89 c5                	mov    %eax,%ebp
  8022e9:	29 fb                	sub    %edi,%ebx
  8022eb:	d3 e6                	shl    %cl,%esi
  8022ed:	89 d9                	mov    %ebx,%ecx
  8022ef:	d3 ed                	shr    %cl,%ebp
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	d3 e0                	shl    %cl,%eax
  8022f5:	09 ee                	or     %ebp,%esi
  8022f7:	89 d9                	mov    %ebx,%ecx
  8022f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022fd:	89 d5                	mov    %edx,%ebp
  8022ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802303:	d3 ed                	shr    %cl,%ebp
  802305:	89 f9                	mov    %edi,%ecx
  802307:	d3 e2                	shl    %cl,%edx
  802309:	89 d9                	mov    %ebx,%ecx
  80230b:	d3 e8                	shr    %cl,%eax
  80230d:	09 c2                	or     %eax,%edx
  80230f:	89 d0                	mov    %edx,%eax
  802311:	89 ea                	mov    %ebp,%edx
  802313:	f7 f6                	div    %esi
  802315:	89 d5                	mov    %edx,%ebp
  802317:	89 c3                	mov    %eax,%ebx
  802319:	f7 64 24 0c          	mull   0xc(%esp)
  80231d:	39 d5                	cmp    %edx,%ebp
  80231f:	72 10                	jb     802331 <__udivdi3+0xc1>
  802321:	8b 74 24 08          	mov    0x8(%esp),%esi
  802325:	89 f9                	mov    %edi,%ecx
  802327:	d3 e6                	shl    %cl,%esi
  802329:	39 c6                	cmp    %eax,%esi
  80232b:	73 07                	jae    802334 <__udivdi3+0xc4>
  80232d:	39 d5                	cmp    %edx,%ebp
  80232f:	75 03                	jne    802334 <__udivdi3+0xc4>
  802331:	83 eb 01             	sub    $0x1,%ebx
  802334:	31 ff                	xor    %edi,%edi
  802336:	89 d8                	mov    %ebx,%eax
  802338:	89 fa                	mov    %edi,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	31 ff                	xor    %edi,%edi
  80234a:	31 db                	xor    %ebx,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	89 d8                	mov    %ebx,%eax
  802362:	f7 f7                	div    %edi
  802364:	31 ff                	xor    %edi,%edi
  802366:	89 c3                	mov    %eax,%ebx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 fa                	mov    %edi,%edx
  80236c:	83 c4 1c             	add    $0x1c,%esp
  80236f:	5b                   	pop    %ebx
  802370:	5e                   	pop    %esi
  802371:	5f                   	pop    %edi
  802372:	5d                   	pop    %ebp
  802373:	c3                   	ret    
  802374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802378:	39 ce                	cmp    %ecx,%esi
  80237a:	72 0c                	jb     802388 <__udivdi3+0x118>
  80237c:	31 db                	xor    %ebx,%ebx
  80237e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802382:	0f 87 34 ff ff ff    	ja     8022bc <__udivdi3+0x4c>
  802388:	bb 01 00 00 00       	mov    $0x1,%ebx
  80238d:	e9 2a ff ff ff       	jmp    8022bc <__udivdi3+0x4c>
  802392:	66 90                	xchg   %ax,%ax
  802394:	66 90                	xchg   %ax,%ax
  802396:	66 90                	xchg   %ax,%ax
  802398:	66 90                	xchg   %ax,%ax
  80239a:	66 90                	xchg   %ax,%ax
  80239c:	66 90                	xchg   %ax,%ax
  80239e:	66 90                	xchg   %ax,%ax

008023a0 <__umoddi3>:
  8023a0:	55                   	push   %ebp
  8023a1:	57                   	push   %edi
  8023a2:	56                   	push   %esi
  8023a3:	53                   	push   %ebx
  8023a4:	83 ec 1c             	sub    $0x1c,%esp
  8023a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023b7:	85 d2                	test   %edx,%edx
  8023b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023c1:	89 f3                	mov    %esi,%ebx
  8023c3:	89 3c 24             	mov    %edi,(%esp)
  8023c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ca:	75 1c                	jne    8023e8 <__umoddi3+0x48>
  8023cc:	39 f7                	cmp    %esi,%edi
  8023ce:	76 50                	jbe    802420 <__umoddi3+0x80>
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	f7 f7                	div    %edi
  8023d6:	89 d0                	mov    %edx,%eax
  8023d8:	31 d2                	xor    %edx,%edx
  8023da:	83 c4 1c             	add    $0x1c,%esp
  8023dd:	5b                   	pop    %ebx
  8023de:	5e                   	pop    %esi
  8023df:	5f                   	pop    %edi
  8023e0:	5d                   	pop    %ebp
  8023e1:	c3                   	ret    
  8023e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e8:	39 f2                	cmp    %esi,%edx
  8023ea:	89 d0                	mov    %edx,%eax
  8023ec:	77 52                	ja     802440 <__umoddi3+0xa0>
  8023ee:	0f bd ea             	bsr    %edx,%ebp
  8023f1:	83 f5 1f             	xor    $0x1f,%ebp
  8023f4:	75 5a                	jne    802450 <__umoddi3+0xb0>
  8023f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023fa:	0f 82 e0 00 00 00    	jb     8024e0 <__umoddi3+0x140>
  802400:	39 0c 24             	cmp    %ecx,(%esp)
  802403:	0f 86 d7 00 00 00    	jbe    8024e0 <__umoddi3+0x140>
  802409:	8b 44 24 08          	mov    0x8(%esp),%eax
  80240d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802411:	83 c4 1c             	add    $0x1c,%esp
  802414:	5b                   	pop    %ebx
  802415:	5e                   	pop    %esi
  802416:	5f                   	pop    %edi
  802417:	5d                   	pop    %ebp
  802418:	c3                   	ret    
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	85 ff                	test   %edi,%edi
  802422:	89 fd                	mov    %edi,%ebp
  802424:	75 0b                	jne    802431 <__umoddi3+0x91>
  802426:	b8 01 00 00 00       	mov    $0x1,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f7                	div    %edi
  80242f:	89 c5                	mov    %eax,%ebp
  802431:	89 f0                	mov    %esi,%eax
  802433:	31 d2                	xor    %edx,%edx
  802435:	f7 f5                	div    %ebp
  802437:	89 c8                	mov    %ecx,%eax
  802439:	f7 f5                	div    %ebp
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	eb 99                	jmp    8023d8 <__umoddi3+0x38>
  80243f:	90                   	nop
  802440:	89 c8                	mov    %ecx,%eax
  802442:	89 f2                	mov    %esi,%edx
  802444:	83 c4 1c             	add    $0x1c,%esp
  802447:	5b                   	pop    %ebx
  802448:	5e                   	pop    %esi
  802449:	5f                   	pop    %edi
  80244a:	5d                   	pop    %ebp
  80244b:	c3                   	ret    
  80244c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802450:	8b 34 24             	mov    (%esp),%esi
  802453:	bf 20 00 00 00       	mov    $0x20,%edi
  802458:	89 e9                	mov    %ebp,%ecx
  80245a:	29 ef                	sub    %ebp,%edi
  80245c:	d3 e0                	shl    %cl,%eax
  80245e:	89 f9                	mov    %edi,%ecx
  802460:	89 f2                	mov    %esi,%edx
  802462:	d3 ea                	shr    %cl,%edx
  802464:	89 e9                	mov    %ebp,%ecx
  802466:	09 c2                	or     %eax,%edx
  802468:	89 d8                	mov    %ebx,%eax
  80246a:	89 14 24             	mov    %edx,(%esp)
  80246d:	89 f2                	mov    %esi,%edx
  80246f:	d3 e2                	shl    %cl,%edx
  802471:	89 f9                	mov    %edi,%ecx
  802473:	89 54 24 04          	mov    %edx,0x4(%esp)
  802477:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80247b:	d3 e8                	shr    %cl,%eax
  80247d:	89 e9                	mov    %ebp,%ecx
  80247f:	89 c6                	mov    %eax,%esi
  802481:	d3 e3                	shl    %cl,%ebx
  802483:	89 f9                	mov    %edi,%ecx
  802485:	89 d0                	mov    %edx,%eax
  802487:	d3 e8                	shr    %cl,%eax
  802489:	89 e9                	mov    %ebp,%ecx
  80248b:	09 d8                	or     %ebx,%eax
  80248d:	89 d3                	mov    %edx,%ebx
  80248f:	89 f2                	mov    %esi,%edx
  802491:	f7 34 24             	divl   (%esp)
  802494:	89 d6                	mov    %edx,%esi
  802496:	d3 e3                	shl    %cl,%ebx
  802498:	f7 64 24 04          	mull   0x4(%esp)
  80249c:	39 d6                	cmp    %edx,%esi
  80249e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024a2:	89 d1                	mov    %edx,%ecx
  8024a4:	89 c3                	mov    %eax,%ebx
  8024a6:	72 08                	jb     8024b0 <__umoddi3+0x110>
  8024a8:	75 11                	jne    8024bb <__umoddi3+0x11b>
  8024aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024ae:	73 0b                	jae    8024bb <__umoddi3+0x11b>
  8024b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024b4:	1b 14 24             	sbb    (%esp),%edx
  8024b7:	89 d1                	mov    %edx,%ecx
  8024b9:	89 c3                	mov    %eax,%ebx
  8024bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024bf:	29 da                	sub    %ebx,%edx
  8024c1:	19 ce                	sbb    %ecx,%esi
  8024c3:	89 f9                	mov    %edi,%ecx
  8024c5:	89 f0                	mov    %esi,%eax
  8024c7:	d3 e0                	shl    %cl,%eax
  8024c9:	89 e9                	mov    %ebp,%ecx
  8024cb:	d3 ea                	shr    %cl,%edx
  8024cd:	89 e9                	mov    %ebp,%ecx
  8024cf:	d3 ee                	shr    %cl,%esi
  8024d1:	09 d0                	or     %edx,%eax
  8024d3:	89 f2                	mov    %esi,%edx
  8024d5:	83 c4 1c             	add    $0x1c,%esp
  8024d8:	5b                   	pop    %ebx
  8024d9:	5e                   	pop    %esi
  8024da:	5f                   	pop    %edi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    
  8024dd:	8d 76 00             	lea    0x0(%esi),%esi
  8024e0:	29 f9                	sub    %edi,%ecx
  8024e2:	19 d6                	sbb    %edx,%esi
  8024e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ec:	e9 18 ff ff ff       	jmp    802409 <__umoddi3+0x69>
