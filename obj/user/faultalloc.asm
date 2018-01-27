
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
  800040:	68 40 22 80 00       	push   $0x802240
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
  80006a:	68 60 22 80 00       	push   $0x802260
  80006f:	6a 0e                	push   $0xe
  800071:	68 4a 22 80 00       	push   $0x80224a
  800076:	e8 d2 00 00 00       	call   80014d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 22 80 00       	push   $0x80228c
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
  80009c:	e8 3e 0d 00 00       	call   800ddf <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 5c 22 80 00       	push   $0x80225c
  8000ae:	e8 73 01 00 00       	call   800226 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 5c 22 80 00       	push   $0x80225c
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
  8000df:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  800139:	e8 ef 11 00 00       	call   80132d <close_all>
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
  80016b:	68 b8 22 80 00       	push   $0x8022b8
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 73 27 80 00 	movl   $0x802773,(%esp)
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
  800289:	e8 22 1d 00 00       	call   801fb0 <__udivdi3>
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
  8002cc:	e8 0f 1e 00 00       	call   8020e0 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 db 22 80 00 	movsbl 0x8022db(%eax),%eax
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
  8003d0:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
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
  800494:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 f3 22 80 00       	push   $0x8022f3
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
  8004b8:	68 41 27 80 00       	push   $0x802741
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
  8004dc:	b8 ec 22 80 00       	mov    $0x8022ec,%eax
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
  800b57:	68 df 25 80 00       	push   $0x8025df
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 fc 25 80 00       	push   $0x8025fc
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
  800bd8:	68 df 25 80 00       	push   $0x8025df
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 fc 25 80 00       	push   $0x8025fc
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
  800c1a:	68 df 25 80 00       	push   $0x8025df
  800c1f:	6a 23                	push   $0x23
  800c21:	68 fc 25 80 00       	push   $0x8025fc
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
  800c5c:	68 df 25 80 00       	push   $0x8025df
  800c61:	6a 23                	push   $0x23
  800c63:	68 fc 25 80 00       	push   $0x8025fc
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
  800c9e:	68 df 25 80 00       	push   $0x8025df
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 fc 25 80 00       	push   $0x8025fc
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
  800ce0:	68 df 25 80 00       	push   $0x8025df
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 fc 25 80 00       	push   $0x8025fc
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
  800d22:	68 df 25 80 00       	push   $0x8025df
  800d27:	6a 23                	push   $0x23
  800d29:	68 fc 25 80 00       	push   $0x8025fc
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
  800d86:	68 df 25 80 00       	push   $0x8025df
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 fc 25 80 00       	push   $0x8025fc
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

00800ddf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800de5:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dec:	75 2a                	jne    800e18 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	6a 07                	push   $0x7
  800df3:	68 00 f0 bf ee       	push   $0xeebff000
  800df8:	6a 00                	push   $0x0
  800dfa:	e8 af fd ff ff       	call   800bae <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800dff:	83 c4 10             	add    $0x10,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	79 12                	jns    800e18 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800e06:	50                   	push   %eax
  800e07:	68 0a 26 80 00       	push   $0x80260a
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 0e 26 80 00       	push   $0x80260e
  800e13:	e8 35 f3 ff ff       	call   80014d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e20:	83 ec 08             	sub    $0x8,%esp
  800e23:	68 4a 0e 80 00       	push   $0x800e4a
  800e28:	6a 00                	push   $0x0
  800e2a:	e8 ca fe ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	79 12                	jns    800e48 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e36:	50                   	push   %eax
  800e37:	68 0a 26 80 00       	push   $0x80260a
  800e3c:	6a 2c                	push   $0x2c
  800e3e:	68 0e 26 80 00       	push   $0x80260e
  800e43:	e8 05 f3 ff ff       	call   80014d <_panic>
	}
}
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e4a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e4b:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e50:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e52:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e55:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e59:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e5e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e62:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e64:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e67:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e68:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e6b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e6c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e6d:	c3                   	ret    

00800e6e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	53                   	push   %ebx
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e78:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800e7a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e7e:	74 11                	je     800e91 <pgfault+0x23>
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	c1 e8 0c             	shr    $0xc,%eax
  800e85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e8c:	f6 c4 08             	test   $0x8,%ah
  800e8f:	75 14                	jne    800ea5 <pgfault+0x37>
		panic("faulting access");
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	68 1c 26 80 00       	push   $0x80261c
  800e99:	6a 1e                	push   $0x1e
  800e9b:	68 2c 26 80 00       	push   $0x80262c
  800ea0:	e8 a8 f2 ff ff       	call   80014d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	6a 07                	push   $0x7
  800eaa:	68 00 f0 7f 00       	push   $0x7ff000
  800eaf:	6a 00                	push   $0x0
  800eb1:	e8 f8 fc ff ff       	call   800bae <sys_page_alloc>
	if (r < 0) {
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	79 12                	jns    800ecf <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800ebd:	50                   	push   %eax
  800ebe:	68 37 26 80 00       	push   $0x802637
  800ec3:	6a 2c                	push   $0x2c
  800ec5:	68 2c 26 80 00       	push   $0x80262c
  800eca:	e8 7e f2 ff ff       	call   80014d <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ecf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	68 00 10 00 00       	push   $0x1000
  800edd:	53                   	push   %ebx
  800ede:	68 00 f0 7f 00       	push   $0x7ff000
  800ee3:	e8 bd fa ff ff       	call   8009a5 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800ee8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eef:	53                   	push   %ebx
  800ef0:	6a 00                	push   $0x0
  800ef2:	68 00 f0 7f 00       	push   $0x7ff000
  800ef7:	6a 00                	push   $0x0
  800ef9:	e8 f3 fc ff ff       	call   800bf1 <sys_page_map>
	if (r < 0) {
  800efe:	83 c4 20             	add    $0x20,%esp
  800f01:	85 c0                	test   %eax,%eax
  800f03:	79 12                	jns    800f17 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f05:	50                   	push   %eax
  800f06:	68 37 26 80 00       	push   $0x802637
  800f0b:	6a 33                	push   $0x33
  800f0d:	68 2c 26 80 00       	push   $0x80262c
  800f12:	e8 36 f2 ff ff       	call   80014d <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f17:	83 ec 08             	sub    $0x8,%esp
  800f1a:	68 00 f0 7f 00       	push   $0x7ff000
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 0d fd ff ff       	call   800c33 <sys_page_unmap>
	if (r < 0) {
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 12                	jns    800f3f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f2d:	50                   	push   %eax
  800f2e:	68 37 26 80 00       	push   $0x802637
  800f33:	6a 37                	push   $0x37
  800f35:	68 2c 26 80 00       	push   $0x80262c
  800f3a:	e8 0e f2 ff ff       	call   80014d <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800f3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	57                   	push   %edi
  800f48:	56                   	push   %esi
  800f49:	53                   	push   %ebx
  800f4a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800f4d:	68 6e 0e 80 00       	push   $0x800e6e
  800f52:	e8 88 fe ff ff       	call   800ddf <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f57:	b8 07 00 00 00       	mov    $0x7,%eax
  800f5c:	cd 30                	int    $0x30
  800f5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	79 17                	jns    800f7f <fork+0x3b>
		panic("fork fault %e");
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	68 50 26 80 00       	push   $0x802650
  800f70:	68 84 00 00 00       	push   $0x84
  800f75:	68 2c 26 80 00       	push   $0x80262c
  800f7a:	e8 ce f1 ff ff       	call   80014d <_panic>
  800f7f:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800f81:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f85:	75 24                	jne    800fab <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f87:	e8 e4 fb ff ff       	call   800b70 <sys_getenvid>
  800f8c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f91:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800f97:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa6:	e9 64 01 00 00       	jmp    80110f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800fab:	83 ec 04             	sub    $0x4,%esp
  800fae:	6a 07                	push   $0x7
  800fb0:	68 00 f0 bf ee       	push   $0xeebff000
  800fb5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb8:	e8 f1 fb ff ff       	call   800bae <sys_page_alloc>
  800fbd:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fc0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fc5:	89 d8                	mov    %ebx,%eax
  800fc7:	c1 e8 16             	shr    $0x16,%eax
  800fca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd1:	a8 01                	test   $0x1,%al
  800fd3:	0f 84 fc 00 00 00    	je     8010d5 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800fd9:	89 d8                	mov    %ebx,%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
  800fde:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800fe5:	f6 c2 01             	test   $0x1,%dl
  800fe8:	0f 84 e7 00 00 00    	je     8010d5 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800fee:	89 c6                	mov    %eax,%esi
  800ff0:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ff3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ffa:	f6 c6 04             	test   $0x4,%dh
  800ffd:	74 39                	je     801038 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801006:	83 ec 0c             	sub    $0xc,%esp
  801009:	25 07 0e 00 00       	and    $0xe07,%eax
  80100e:	50                   	push   %eax
  80100f:	56                   	push   %esi
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	6a 00                	push   $0x0
  801014:	e8 d8 fb ff ff       	call   800bf1 <sys_page_map>
		if (r < 0) {
  801019:	83 c4 20             	add    $0x20,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	0f 89 b1 00 00 00    	jns    8010d5 <fork+0x191>
		    	panic("sys page map fault %e");
  801024:	83 ec 04             	sub    $0x4,%esp
  801027:	68 5e 26 80 00       	push   $0x80265e
  80102c:	6a 54                	push   $0x54
  80102e:	68 2c 26 80 00       	push   $0x80262c
  801033:	e8 15 f1 ff ff       	call   80014d <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801038:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103f:	f6 c2 02             	test   $0x2,%dl
  801042:	75 0c                	jne    801050 <fork+0x10c>
  801044:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80104b:	f6 c4 08             	test   $0x8,%ah
  80104e:	74 5b                	je     8010ab <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	68 05 08 00 00       	push   $0x805
  801058:	56                   	push   %esi
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	6a 00                	push   $0x0
  80105d:	e8 8f fb ff ff       	call   800bf1 <sys_page_map>
		if (r < 0) {
  801062:	83 c4 20             	add    $0x20,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	79 14                	jns    80107d <fork+0x139>
		    	panic("sys page map fault %e");
  801069:	83 ec 04             	sub    $0x4,%esp
  80106c:	68 5e 26 80 00       	push   $0x80265e
  801071:	6a 5b                	push   $0x5b
  801073:	68 2c 26 80 00       	push   $0x80262c
  801078:	e8 d0 f0 ff ff       	call   80014d <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80107d:	83 ec 0c             	sub    $0xc,%esp
  801080:	68 05 08 00 00       	push   $0x805
  801085:	56                   	push   %esi
  801086:	6a 00                	push   $0x0
  801088:	56                   	push   %esi
  801089:	6a 00                	push   $0x0
  80108b:	e8 61 fb ff ff       	call   800bf1 <sys_page_map>
		if (r < 0) {
  801090:	83 c4 20             	add    $0x20,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	79 3e                	jns    8010d5 <fork+0x191>
		    	panic("sys page map fault %e");
  801097:	83 ec 04             	sub    $0x4,%esp
  80109a:	68 5e 26 80 00       	push   $0x80265e
  80109f:	6a 5f                	push   $0x5f
  8010a1:	68 2c 26 80 00       	push   $0x80262c
  8010a6:	e8 a2 f0 ff ff       	call   80014d <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	6a 05                	push   $0x5
  8010b0:	56                   	push   %esi
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	6a 00                	push   $0x0
  8010b5:	e8 37 fb ff ff       	call   800bf1 <sys_page_map>
		if (r < 0) {
  8010ba:	83 c4 20             	add    $0x20,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	79 14                	jns    8010d5 <fork+0x191>
		    	panic("sys page map fault %e");
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	68 5e 26 80 00       	push   $0x80265e
  8010c9:	6a 64                	push   $0x64
  8010cb:	68 2c 26 80 00       	push   $0x80262c
  8010d0:	e8 78 f0 ff ff       	call   80014d <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8010d5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010db:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010e1:	0f 85 de fe ff ff    	jne    800fc5 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8010e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ec:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  8010f2:	83 ec 08             	sub    $0x8,%esp
  8010f5:	50                   	push   %eax
  8010f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f9:	57                   	push   %edi
  8010fa:	e8 fa fb ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8010ff:	83 c4 08             	add    $0x8,%esp
  801102:	6a 02                	push   $0x2
  801104:	57                   	push   %edi
  801105:	e8 6b fb ff ff       	call   800c75 <sys_env_set_status>
	
	return envid;
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80110f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5f                   	pop    %edi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <sfork>:

envid_t
sfork(void)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80111a:	b8 00 00 00 00       	mov    $0x0,%eax
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    

00801121 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	56                   	push   %esi
  801125:	53                   	push   %ebx
  801126:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801129:	89 1d 0c 40 80 00    	mov    %ebx,0x80400c
	cprintf("in fork.c thread create. func: %x\n", func);
  80112f:	83 ec 08             	sub    $0x8,%esp
  801132:	53                   	push   %ebx
  801133:	68 74 26 80 00       	push   $0x802674
  801138:	e8 e9 f0 ff ff       	call   800226 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80113d:	c7 04 24 13 01 80 00 	movl   $0x800113,(%esp)
  801144:	e8 56 fc ff ff       	call   800d9f <sys_thread_create>
  801149:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	53                   	push   %ebx
  80114f:	68 74 26 80 00       	push   $0x802674
  801154:	e8 cd f0 ff ff       	call   800226 <cprintf>
	return id;
}
  801159:	89 f0                	mov    %esi,%eax
  80115b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5e                   	pop    %esi
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801165:	8b 45 08             	mov    0x8(%ebp),%eax
  801168:	05 00 00 00 30       	add    $0x30000000,%eax
  80116d:	c1 e8 0c             	shr    $0xc,%eax
}
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801175:	8b 45 08             	mov    0x8(%ebp),%eax
  801178:	05 00 00 00 30       	add    $0x30000000,%eax
  80117d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801182:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801194:	89 c2                	mov    %eax,%edx
  801196:	c1 ea 16             	shr    $0x16,%edx
  801199:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a0:	f6 c2 01             	test   $0x1,%dl
  8011a3:	74 11                	je     8011b6 <fd_alloc+0x2d>
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	c1 ea 0c             	shr    $0xc,%edx
  8011aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b1:	f6 c2 01             	test   $0x1,%dl
  8011b4:	75 09                	jne    8011bf <fd_alloc+0x36>
			*fd_store = fd;
  8011b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bd:	eb 17                	jmp    8011d6 <fd_alloc+0x4d>
  8011bf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011c4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c9:	75 c9                	jne    801194 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011cb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011d1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011de:	83 f8 1f             	cmp    $0x1f,%eax
  8011e1:	77 36                	ja     801219 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e3:	c1 e0 0c             	shl    $0xc,%eax
  8011e6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011eb:	89 c2                	mov    %eax,%edx
  8011ed:	c1 ea 16             	shr    $0x16,%edx
  8011f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f7:	f6 c2 01             	test   $0x1,%dl
  8011fa:	74 24                	je     801220 <fd_lookup+0x48>
  8011fc:	89 c2                	mov    %eax,%edx
  8011fe:	c1 ea 0c             	shr    $0xc,%edx
  801201:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801208:	f6 c2 01             	test   $0x1,%dl
  80120b:	74 1a                	je     801227 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801210:	89 02                	mov    %eax,(%edx)
	return 0;
  801212:	b8 00 00 00 00       	mov    $0x0,%eax
  801217:	eb 13                	jmp    80122c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801219:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121e:	eb 0c                	jmp    80122c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801220:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801225:	eb 05                	jmp    80122c <fd_lookup+0x54>
  801227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801237:	ba 18 27 80 00       	mov    $0x802718,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80123c:	eb 13                	jmp    801251 <dev_lookup+0x23>
  80123e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801241:	39 08                	cmp    %ecx,(%eax)
  801243:	75 0c                	jne    801251 <dev_lookup+0x23>
			*dev = devtab[i];
  801245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801248:	89 01                	mov    %eax,(%ecx)
			return 0;
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
  80124f:	eb 2e                	jmp    80127f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801251:	8b 02                	mov    (%edx),%eax
  801253:	85 c0                	test   %eax,%eax
  801255:	75 e7                	jne    80123e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801257:	a1 04 40 80 00       	mov    0x804004,%eax
  80125c:	8b 40 7c             	mov    0x7c(%eax),%eax
  80125f:	83 ec 04             	sub    $0x4,%esp
  801262:	51                   	push   %ecx
  801263:	50                   	push   %eax
  801264:	68 98 26 80 00       	push   $0x802698
  801269:	e8 b8 ef ff ff       	call   800226 <cprintf>
	*dev = 0;
  80126e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801271:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80127f:	c9                   	leave  
  801280:	c3                   	ret    

00801281 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 10             	sub    $0x10,%esp
  801289:	8b 75 08             	mov    0x8(%ebp),%esi
  80128c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801292:	50                   	push   %eax
  801293:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801299:	c1 e8 0c             	shr    $0xc,%eax
  80129c:	50                   	push   %eax
  80129d:	e8 36 ff ff ff       	call   8011d8 <fd_lookup>
  8012a2:	83 c4 08             	add    $0x8,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 05                	js     8012ae <fd_close+0x2d>
	    || fd != fd2)
  8012a9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ac:	74 0c                	je     8012ba <fd_close+0x39>
		return (must_exist ? r : 0);
  8012ae:	84 db                	test   %bl,%bl
  8012b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b5:	0f 44 c2             	cmove  %edx,%eax
  8012b8:	eb 41                	jmp    8012fb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	ff 36                	pushl  (%esi)
  8012c3:	e8 66 ff ff ff       	call   80122e <dev_lookup>
  8012c8:	89 c3                	mov    %eax,%ebx
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 1a                	js     8012eb <fd_close+0x6a>
		if (dev->dev_close)
  8012d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012d7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	74 0b                	je     8012eb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012e0:	83 ec 0c             	sub    $0xc,%esp
  8012e3:	56                   	push   %esi
  8012e4:	ff d0                	call   *%eax
  8012e6:	89 c3                	mov    %eax,%ebx
  8012e8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	56                   	push   %esi
  8012ef:	6a 00                	push   $0x0
  8012f1:	e8 3d f9 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	89 d8                	mov    %ebx,%eax
}
  8012fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fe:	5b                   	pop    %ebx
  8012ff:	5e                   	pop    %esi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	ff 75 08             	pushl  0x8(%ebp)
  80130f:	e8 c4 fe ff ff       	call   8011d8 <fd_lookup>
  801314:	83 c4 08             	add    $0x8,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 10                	js     80132b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	6a 01                	push   $0x1
  801320:	ff 75 f4             	pushl  -0xc(%ebp)
  801323:	e8 59 ff ff ff       	call   801281 <fd_close>
  801328:	83 c4 10             	add    $0x10,%esp
}
  80132b:	c9                   	leave  
  80132c:	c3                   	ret    

0080132d <close_all>:

void
close_all(void)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	53                   	push   %ebx
  801331:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801334:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	53                   	push   %ebx
  80133d:	e8 c0 ff ff ff       	call   801302 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801342:	83 c3 01             	add    $0x1,%ebx
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	83 fb 20             	cmp    $0x20,%ebx
  80134b:	75 ec                	jne    801339 <close_all+0xc>
		close(i);
}
  80134d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801350:	c9                   	leave  
  801351:	c3                   	ret    

00801352 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	57                   	push   %edi
  801356:	56                   	push   %esi
  801357:	53                   	push   %ebx
  801358:	83 ec 2c             	sub    $0x2c,%esp
  80135b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80135e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	ff 75 08             	pushl  0x8(%ebp)
  801365:	e8 6e fe ff ff       	call   8011d8 <fd_lookup>
  80136a:	83 c4 08             	add    $0x8,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	0f 88 c1 00 00 00    	js     801436 <dup+0xe4>
		return r;
	close(newfdnum);
  801375:	83 ec 0c             	sub    $0xc,%esp
  801378:	56                   	push   %esi
  801379:	e8 84 ff ff ff       	call   801302 <close>

	newfd = INDEX2FD(newfdnum);
  80137e:	89 f3                	mov    %esi,%ebx
  801380:	c1 e3 0c             	shl    $0xc,%ebx
  801383:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801389:	83 c4 04             	add    $0x4,%esp
  80138c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80138f:	e8 de fd ff ff       	call   801172 <fd2data>
  801394:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801396:	89 1c 24             	mov    %ebx,(%esp)
  801399:	e8 d4 fd ff ff       	call   801172 <fd2data>
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013a4:	89 f8                	mov    %edi,%eax
  8013a6:	c1 e8 16             	shr    $0x16,%eax
  8013a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013b0:	a8 01                	test   $0x1,%al
  8013b2:	74 37                	je     8013eb <dup+0x99>
  8013b4:	89 f8                	mov    %edi,%eax
  8013b6:	c1 e8 0c             	shr    $0xc,%eax
  8013b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c0:	f6 c2 01             	test   $0x1,%dl
  8013c3:	74 26                	je     8013eb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cc:	83 ec 0c             	sub    $0xc,%esp
  8013cf:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d4:	50                   	push   %eax
  8013d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d8:	6a 00                	push   $0x0
  8013da:	57                   	push   %edi
  8013db:	6a 00                	push   $0x0
  8013dd:	e8 0f f8 ff ff       	call   800bf1 <sys_page_map>
  8013e2:	89 c7                	mov    %eax,%edi
  8013e4:	83 c4 20             	add    $0x20,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 2e                	js     801419 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013ee:	89 d0                	mov    %edx,%eax
  8013f0:	c1 e8 0c             	shr    $0xc,%eax
  8013f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013fa:	83 ec 0c             	sub    $0xc,%esp
  8013fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801402:	50                   	push   %eax
  801403:	53                   	push   %ebx
  801404:	6a 00                	push   $0x0
  801406:	52                   	push   %edx
  801407:	6a 00                	push   $0x0
  801409:	e8 e3 f7 ff ff       	call   800bf1 <sys_page_map>
  80140e:	89 c7                	mov    %eax,%edi
  801410:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801413:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801415:	85 ff                	test   %edi,%edi
  801417:	79 1d                	jns    801436 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	53                   	push   %ebx
  80141d:	6a 00                	push   $0x0
  80141f:	e8 0f f8 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801424:	83 c4 08             	add    $0x8,%esp
  801427:	ff 75 d4             	pushl  -0x2c(%ebp)
  80142a:	6a 00                	push   $0x0
  80142c:	e8 02 f8 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	89 f8                	mov    %edi,%eax
}
  801436:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801439:	5b                   	pop    %ebx
  80143a:	5e                   	pop    %esi
  80143b:	5f                   	pop    %edi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	53                   	push   %ebx
  801442:	83 ec 14             	sub    $0x14,%esp
  801445:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801448:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144b:	50                   	push   %eax
  80144c:	53                   	push   %ebx
  80144d:	e8 86 fd ff ff       	call   8011d8 <fd_lookup>
  801452:	83 c4 08             	add    $0x8,%esp
  801455:	89 c2                	mov    %eax,%edx
  801457:	85 c0                	test   %eax,%eax
  801459:	78 6d                	js     8014c8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801465:	ff 30                	pushl  (%eax)
  801467:	e8 c2 fd ff ff       	call   80122e <dev_lookup>
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 4c                	js     8014bf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801473:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801476:	8b 42 08             	mov    0x8(%edx),%eax
  801479:	83 e0 03             	and    $0x3,%eax
  80147c:	83 f8 01             	cmp    $0x1,%eax
  80147f:	75 21                	jne    8014a2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801481:	a1 04 40 80 00       	mov    0x804004,%eax
  801486:	8b 40 7c             	mov    0x7c(%eax),%eax
  801489:	83 ec 04             	sub    $0x4,%esp
  80148c:	53                   	push   %ebx
  80148d:	50                   	push   %eax
  80148e:	68 dc 26 80 00       	push   $0x8026dc
  801493:	e8 8e ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014a0:	eb 26                	jmp    8014c8 <read+0x8a>
	}
	if (!dev->dev_read)
  8014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a5:	8b 40 08             	mov    0x8(%eax),%eax
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	74 17                	je     8014c3 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014ac:	83 ec 04             	sub    $0x4,%esp
  8014af:	ff 75 10             	pushl  0x10(%ebp)
  8014b2:	ff 75 0c             	pushl  0xc(%ebp)
  8014b5:	52                   	push   %edx
  8014b6:	ff d0                	call   *%eax
  8014b8:	89 c2                	mov    %eax,%edx
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	eb 09                	jmp    8014c8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bf:	89 c2                	mov    %eax,%edx
  8014c1:	eb 05                	jmp    8014c8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014c8:	89 d0                	mov    %edx,%eax
  8014ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	57                   	push   %edi
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 0c             	sub    $0xc,%esp
  8014d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014db:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e3:	eb 21                	jmp    801506 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	89 f0                	mov    %esi,%eax
  8014ea:	29 d8                	sub    %ebx,%eax
  8014ec:	50                   	push   %eax
  8014ed:	89 d8                	mov    %ebx,%eax
  8014ef:	03 45 0c             	add    0xc(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	57                   	push   %edi
  8014f4:	e8 45 ff ff ff       	call   80143e <read>
		if (m < 0)
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 10                	js     801510 <readn+0x41>
			return m;
		if (m == 0)
  801500:	85 c0                	test   %eax,%eax
  801502:	74 0a                	je     80150e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801504:	01 c3                	add    %eax,%ebx
  801506:	39 f3                	cmp    %esi,%ebx
  801508:	72 db                	jb     8014e5 <readn+0x16>
  80150a:	89 d8                	mov    %ebx,%eax
  80150c:	eb 02                	jmp    801510 <readn+0x41>
  80150e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801510:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801513:	5b                   	pop    %ebx
  801514:	5e                   	pop    %esi
  801515:	5f                   	pop    %edi
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    

00801518 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	53                   	push   %ebx
  80151c:	83 ec 14             	sub    $0x14,%esp
  80151f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801522:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801525:	50                   	push   %eax
  801526:	53                   	push   %ebx
  801527:	e8 ac fc ff ff       	call   8011d8 <fd_lookup>
  80152c:	83 c4 08             	add    $0x8,%esp
  80152f:	89 c2                	mov    %eax,%edx
  801531:	85 c0                	test   %eax,%eax
  801533:	78 68                	js     80159d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153f:	ff 30                	pushl  (%eax)
  801541:	e8 e8 fc ff ff       	call   80122e <dev_lookup>
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 47                	js     801594 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801550:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801554:	75 21                	jne    801577 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801556:	a1 04 40 80 00       	mov    0x804004,%eax
  80155b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80155e:	83 ec 04             	sub    $0x4,%esp
  801561:	53                   	push   %ebx
  801562:	50                   	push   %eax
  801563:	68 f8 26 80 00       	push   $0x8026f8
  801568:	e8 b9 ec ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801575:	eb 26                	jmp    80159d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801577:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157a:	8b 52 0c             	mov    0xc(%edx),%edx
  80157d:	85 d2                	test   %edx,%edx
  80157f:	74 17                	je     801598 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801581:	83 ec 04             	sub    $0x4,%esp
  801584:	ff 75 10             	pushl  0x10(%ebp)
  801587:	ff 75 0c             	pushl  0xc(%ebp)
  80158a:	50                   	push   %eax
  80158b:	ff d2                	call   *%edx
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	eb 09                	jmp    80159d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801594:	89 c2                	mov    %eax,%edx
  801596:	eb 05                	jmp    80159d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801598:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80159d:	89 d0                	mov    %edx,%eax
  80159f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	ff 75 08             	pushl  0x8(%ebp)
  8015b1:	e8 22 fc ff ff       	call   8011d8 <fd_lookup>
  8015b6:	83 c4 08             	add    $0x8,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 0e                	js     8015cb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 14             	sub    $0x14,%esp
  8015d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	53                   	push   %ebx
  8015dc:	e8 f7 fb ff ff       	call   8011d8 <fd_lookup>
  8015e1:	83 c4 08             	add    $0x8,%esp
  8015e4:	89 c2                	mov    %eax,%edx
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 65                	js     80164f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ea:	83 ec 08             	sub    $0x8,%esp
  8015ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f0:	50                   	push   %eax
  8015f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f4:	ff 30                	pushl  (%eax)
  8015f6:	e8 33 fc ff ff       	call   80122e <dev_lookup>
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 44                	js     801646 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801602:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801605:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801609:	75 21                	jne    80162c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80160b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801610:	8b 40 7c             	mov    0x7c(%eax),%eax
  801613:	83 ec 04             	sub    $0x4,%esp
  801616:	53                   	push   %ebx
  801617:	50                   	push   %eax
  801618:	68 b8 26 80 00       	push   $0x8026b8
  80161d:	e8 04 ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80162a:	eb 23                	jmp    80164f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80162c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162f:	8b 52 18             	mov    0x18(%edx),%edx
  801632:	85 d2                	test   %edx,%edx
  801634:	74 14                	je     80164a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	ff 75 0c             	pushl  0xc(%ebp)
  80163c:	50                   	push   %eax
  80163d:	ff d2                	call   *%edx
  80163f:	89 c2                	mov    %eax,%edx
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	eb 09                	jmp    80164f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801646:	89 c2                	mov    %eax,%edx
  801648:	eb 05                	jmp    80164f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80164a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80164f:	89 d0                	mov    %edx,%eax
  801651:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	53                   	push   %ebx
  80165a:	83 ec 14             	sub    $0x14,%esp
  80165d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801660:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	ff 75 08             	pushl  0x8(%ebp)
  801667:	e8 6c fb ff ff       	call   8011d8 <fd_lookup>
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	89 c2                	mov    %eax,%edx
  801671:	85 c0                	test   %eax,%eax
  801673:	78 58                	js     8016cd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167b:	50                   	push   %eax
  80167c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167f:	ff 30                	pushl  (%eax)
  801681:	e8 a8 fb ff ff       	call   80122e <dev_lookup>
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 37                	js     8016c4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80168d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801690:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801694:	74 32                	je     8016c8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801696:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801699:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016a0:	00 00 00 
	stat->st_isdir = 0;
  8016a3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016aa:	00 00 00 
	stat->st_dev = dev;
  8016ad:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	53                   	push   %ebx
  8016b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ba:	ff 50 14             	call   *0x14(%eax)
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	eb 09                	jmp    8016cd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	89 c2                	mov    %eax,%edx
  8016c6:	eb 05                	jmp    8016cd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016cd:	89 d0                	mov    %edx,%eax
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	56                   	push   %esi
  8016d8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	6a 00                	push   $0x0
  8016de:	ff 75 08             	pushl  0x8(%ebp)
  8016e1:	e8 e3 01 00 00       	call   8018c9 <open>
  8016e6:	89 c3                	mov    %eax,%ebx
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 1b                	js     80170a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	ff 75 0c             	pushl  0xc(%ebp)
  8016f5:	50                   	push   %eax
  8016f6:	e8 5b ff ff ff       	call   801656 <fstat>
  8016fb:	89 c6                	mov    %eax,%esi
	close(fd);
  8016fd:	89 1c 24             	mov    %ebx,(%esp)
  801700:	e8 fd fb ff ff       	call   801302 <close>
	return r;
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	89 f0                	mov    %esi,%eax
}
  80170a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    

00801711 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
  801716:	89 c6                	mov    %eax,%esi
  801718:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80171a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801721:	75 12                	jne    801735 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801723:	83 ec 0c             	sub    $0xc,%esp
  801726:	6a 01                	push   $0x1
  801728:	e8 05 08 00 00       	call   801f32 <ipc_find_env>
  80172d:	a3 00 40 80 00       	mov    %eax,0x804000
  801732:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801735:	6a 07                	push   $0x7
  801737:	68 00 50 80 00       	push   $0x805000
  80173c:	56                   	push   %esi
  80173d:	ff 35 00 40 80 00    	pushl  0x804000
  801743:	e8 88 07 00 00       	call   801ed0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801748:	83 c4 0c             	add    $0xc,%esp
  80174b:	6a 00                	push   $0x0
  80174d:	53                   	push   %ebx
  80174e:	6a 00                	push   $0x0
  801750:	e8 00 07 00 00       	call   801e55 <ipc_recv>
}
  801755:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801758:	5b                   	pop    %ebx
  801759:	5e                   	pop    %esi
  80175a:	5d                   	pop    %ebp
  80175b:	c3                   	ret    

0080175c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	8b 40 0c             	mov    0xc(%eax),%eax
  801768:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80176d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801770:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801775:	ba 00 00 00 00       	mov    $0x0,%edx
  80177a:	b8 02 00 00 00       	mov    $0x2,%eax
  80177f:	e8 8d ff ff ff       	call   801711 <fsipc>
}
  801784:	c9                   	leave  
  801785:	c3                   	ret    

00801786 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 40 0c             	mov    0xc(%eax),%eax
  801792:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	b8 06 00 00 00       	mov    $0x6,%eax
  8017a1:	e8 6b ff ff ff       	call   801711 <fsipc>
}
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	53                   	push   %ebx
  8017ac:	83 ec 04             	sub    $0x4,%esp
  8017af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c7:	e8 45 ff ff ff       	call   801711 <fsipc>
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 2c                	js     8017fc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	68 00 50 80 00       	push   $0x805000
  8017d8:	53                   	push   %ebx
  8017d9:	e8 cd ef ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017de:	a1 80 50 80 00       	mov    0x805080,%eax
  8017e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    

00801801 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	83 ec 0c             	sub    $0xc,%esp
  801807:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80180a:	8b 55 08             	mov    0x8(%ebp),%edx
  80180d:	8b 52 0c             	mov    0xc(%edx),%edx
  801810:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801816:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80181b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801820:	0f 47 c2             	cmova  %edx,%eax
  801823:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801828:	50                   	push   %eax
  801829:	ff 75 0c             	pushl  0xc(%ebp)
  80182c:	68 08 50 80 00       	push   $0x805008
  801831:	e8 07 f1 ff ff       	call   80093d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801836:	ba 00 00 00 00       	mov    $0x0,%edx
  80183b:	b8 04 00 00 00       	mov    $0x4,%eax
  801840:	e8 cc fe ff ff       	call   801711 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801845:	c9                   	leave  
  801846:	c3                   	ret    

00801847 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
  80184c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	8b 40 0c             	mov    0xc(%eax),%eax
  801855:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80185a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801860:	ba 00 00 00 00       	mov    $0x0,%edx
  801865:	b8 03 00 00 00       	mov    $0x3,%eax
  80186a:	e8 a2 fe ff ff       	call   801711 <fsipc>
  80186f:	89 c3                	mov    %eax,%ebx
  801871:	85 c0                	test   %eax,%eax
  801873:	78 4b                	js     8018c0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801875:	39 c6                	cmp    %eax,%esi
  801877:	73 16                	jae    80188f <devfile_read+0x48>
  801879:	68 28 27 80 00       	push   $0x802728
  80187e:	68 2f 27 80 00       	push   $0x80272f
  801883:	6a 7c                	push   $0x7c
  801885:	68 44 27 80 00       	push   $0x802744
  80188a:	e8 be e8 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  80188f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801894:	7e 16                	jle    8018ac <devfile_read+0x65>
  801896:	68 4f 27 80 00       	push   $0x80274f
  80189b:	68 2f 27 80 00       	push   $0x80272f
  8018a0:	6a 7d                	push   $0x7d
  8018a2:	68 44 27 80 00       	push   $0x802744
  8018a7:	e8 a1 e8 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ac:	83 ec 04             	sub    $0x4,%esp
  8018af:	50                   	push   %eax
  8018b0:	68 00 50 80 00       	push   $0x805000
  8018b5:	ff 75 0c             	pushl  0xc(%ebp)
  8018b8:	e8 80 f0 ff ff       	call   80093d <memmove>
	return r;
  8018bd:	83 c4 10             	add    $0x10,%esp
}
  8018c0:	89 d8                	mov    %ebx,%eax
  8018c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    

008018c9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 20             	sub    $0x20,%esp
  8018d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d3:	53                   	push   %ebx
  8018d4:	e8 99 ee ff ff       	call   800772 <strlen>
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e1:	7f 67                	jg     80194a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e9:	50                   	push   %eax
  8018ea:	e8 9a f8 ff ff       	call   801189 <fd_alloc>
  8018ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 57                	js     80194f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	53                   	push   %ebx
  8018fc:	68 00 50 80 00       	push   $0x805000
  801901:	e8 a5 ee ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801906:	8b 45 0c             	mov    0xc(%ebp),%eax
  801909:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80190e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801911:	b8 01 00 00 00       	mov    $0x1,%eax
  801916:	e8 f6 fd ff ff       	call   801711 <fsipc>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	79 14                	jns    801938 <open+0x6f>
		fd_close(fd, 0);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	6a 00                	push   $0x0
  801929:	ff 75 f4             	pushl  -0xc(%ebp)
  80192c:	e8 50 f9 ff ff       	call   801281 <fd_close>
		return r;
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	89 da                	mov    %ebx,%edx
  801936:	eb 17                	jmp    80194f <open+0x86>
	}

	return fd2num(fd);
  801938:	83 ec 0c             	sub    $0xc,%esp
  80193b:	ff 75 f4             	pushl  -0xc(%ebp)
  80193e:	e8 1f f8 ff ff       	call   801162 <fd2num>
  801943:	89 c2                	mov    %eax,%edx
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	eb 05                	jmp    80194f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80194a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80194f:	89 d0                	mov    %edx,%eax
  801951:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195c:	ba 00 00 00 00       	mov    $0x0,%edx
  801961:	b8 08 00 00 00       	mov    $0x8,%eax
  801966:	e8 a6 fd ff ff       	call   801711 <fsipc>
}
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    

0080196d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	ff 75 08             	pushl  0x8(%ebp)
  80197b:	e8 f2 f7 ff ff       	call   801172 <fd2data>
  801980:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801982:	83 c4 08             	add    $0x8,%esp
  801985:	68 5b 27 80 00       	push   $0x80275b
  80198a:	53                   	push   %ebx
  80198b:	e8 1b ee ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801990:	8b 46 04             	mov    0x4(%esi),%eax
  801993:	2b 06                	sub    (%esi),%eax
  801995:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80199b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a2:	00 00 00 
	stat->st_dev = &devpipe;
  8019a5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019ac:	30 80 00 
	return 0;
}
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b7:	5b                   	pop    %ebx
  8019b8:	5e                   	pop    %esi
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	53                   	push   %ebx
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c5:	53                   	push   %ebx
  8019c6:	6a 00                	push   $0x0
  8019c8:	e8 66 f2 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019cd:	89 1c 24             	mov    %ebx,(%esp)
  8019d0:	e8 9d f7 ff ff       	call   801172 <fd2data>
  8019d5:	83 c4 08             	add    $0x8,%esp
  8019d8:	50                   	push   %eax
  8019d9:	6a 00                	push   $0x0
  8019db:	e8 53 f2 ff ff       	call   800c33 <sys_page_unmap>
}
  8019e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	57                   	push   %edi
  8019e9:	56                   	push   %esi
  8019ea:	53                   	push   %ebx
  8019eb:	83 ec 1c             	sub    $0x1c,%esp
  8019ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019f1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8019f8:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	ff 75 e0             	pushl  -0x20(%ebp)
  801a04:	e8 6b 05 00 00       	call   801f74 <pageref>
  801a09:	89 c3                	mov    %eax,%ebx
  801a0b:	89 3c 24             	mov    %edi,(%esp)
  801a0e:	e8 61 05 00 00       	call   801f74 <pageref>
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	39 c3                	cmp    %eax,%ebx
  801a18:	0f 94 c1             	sete   %cl
  801a1b:	0f b6 c9             	movzbl %cl,%ecx
  801a1e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a21:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a27:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801a2d:	39 ce                	cmp    %ecx,%esi
  801a2f:	74 1e                	je     801a4f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801a31:	39 c3                	cmp    %eax,%ebx
  801a33:	75 be                	jne    8019f3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a35:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801a3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a3e:	50                   	push   %eax
  801a3f:	56                   	push   %esi
  801a40:	68 62 27 80 00       	push   $0x802762
  801a45:	e8 dc e7 ff ff       	call   800226 <cprintf>
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	eb a4                	jmp    8019f3 <_pipeisclosed+0xe>
	}
}
  801a4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	5f                   	pop    %edi
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	57                   	push   %edi
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 28             	sub    $0x28,%esp
  801a63:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a66:	56                   	push   %esi
  801a67:	e8 06 f7 ff ff       	call   801172 <fd2data>
  801a6c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	bf 00 00 00 00       	mov    $0x0,%edi
  801a76:	eb 4b                	jmp    801ac3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a78:	89 da                	mov    %ebx,%edx
  801a7a:	89 f0                	mov    %esi,%eax
  801a7c:	e8 64 ff ff ff       	call   8019e5 <_pipeisclosed>
  801a81:	85 c0                	test   %eax,%eax
  801a83:	75 48                	jne    801acd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a85:	e8 05 f1 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a8a:	8b 43 04             	mov    0x4(%ebx),%eax
  801a8d:	8b 0b                	mov    (%ebx),%ecx
  801a8f:	8d 51 20             	lea    0x20(%ecx),%edx
  801a92:	39 d0                	cmp    %edx,%eax
  801a94:	73 e2                	jae    801a78 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a99:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a9d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aa0:	89 c2                	mov    %eax,%edx
  801aa2:	c1 fa 1f             	sar    $0x1f,%edx
  801aa5:	89 d1                	mov    %edx,%ecx
  801aa7:	c1 e9 1b             	shr    $0x1b,%ecx
  801aaa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aad:	83 e2 1f             	and    $0x1f,%edx
  801ab0:	29 ca                	sub    %ecx,%edx
  801ab2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ab6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aba:	83 c0 01             	add    $0x1,%eax
  801abd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac0:	83 c7 01             	add    $0x1,%edi
  801ac3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac6:	75 c2                	jne    801a8a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ac8:	8b 45 10             	mov    0x10(%ebp),%eax
  801acb:	eb 05                	jmp    801ad2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801acd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ad2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5e                   	pop    %esi
  801ad7:	5f                   	pop    %edi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	57                   	push   %edi
  801ade:	56                   	push   %esi
  801adf:	53                   	push   %ebx
  801ae0:	83 ec 18             	sub    $0x18,%esp
  801ae3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ae6:	57                   	push   %edi
  801ae7:	e8 86 f6 ff ff       	call   801172 <fd2data>
  801aec:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801af6:	eb 3d                	jmp    801b35 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801af8:	85 db                	test   %ebx,%ebx
  801afa:	74 04                	je     801b00 <devpipe_read+0x26>
				return i;
  801afc:	89 d8                	mov    %ebx,%eax
  801afe:	eb 44                	jmp    801b44 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b00:	89 f2                	mov    %esi,%edx
  801b02:	89 f8                	mov    %edi,%eax
  801b04:	e8 dc fe ff ff       	call   8019e5 <_pipeisclosed>
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	75 32                	jne    801b3f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b0d:	e8 7d f0 ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b12:	8b 06                	mov    (%esi),%eax
  801b14:	3b 46 04             	cmp    0x4(%esi),%eax
  801b17:	74 df                	je     801af8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b19:	99                   	cltd   
  801b1a:	c1 ea 1b             	shr    $0x1b,%edx
  801b1d:	01 d0                	add    %edx,%eax
  801b1f:	83 e0 1f             	and    $0x1f,%eax
  801b22:	29 d0                	sub    %edx,%eax
  801b24:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b2f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b32:	83 c3 01             	add    $0x1,%ebx
  801b35:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b38:	75 d8                	jne    801b12 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3d:	eb 05                	jmp    801b44 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5f                   	pop    %edi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
  801b51:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b57:	50                   	push   %eax
  801b58:	e8 2c f6 ff ff       	call   801189 <fd_alloc>
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	85 c0                	test   %eax,%eax
  801b64:	0f 88 2c 01 00 00    	js     801c96 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6a:	83 ec 04             	sub    $0x4,%esp
  801b6d:	68 07 04 00 00       	push   $0x407
  801b72:	ff 75 f4             	pushl  -0xc(%ebp)
  801b75:	6a 00                	push   $0x0
  801b77:	e8 32 f0 ff ff       	call   800bae <sys_page_alloc>
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	89 c2                	mov    %eax,%edx
  801b81:	85 c0                	test   %eax,%eax
  801b83:	0f 88 0d 01 00 00    	js     801c96 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b89:	83 ec 0c             	sub    $0xc,%esp
  801b8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b8f:	50                   	push   %eax
  801b90:	e8 f4 f5 ff ff       	call   801189 <fd_alloc>
  801b95:	89 c3                	mov    %eax,%ebx
  801b97:	83 c4 10             	add    $0x10,%esp
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	0f 88 e2 00 00 00    	js     801c84 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba2:	83 ec 04             	sub    $0x4,%esp
  801ba5:	68 07 04 00 00       	push   $0x407
  801baa:	ff 75 f0             	pushl  -0x10(%ebp)
  801bad:	6a 00                	push   $0x0
  801baf:	e8 fa ef ff ff       	call   800bae <sys_page_alloc>
  801bb4:	89 c3                	mov    %eax,%ebx
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	0f 88 c3 00 00 00    	js     801c84 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bc1:	83 ec 0c             	sub    $0xc,%esp
  801bc4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc7:	e8 a6 f5 ff ff       	call   801172 <fd2data>
  801bcc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bce:	83 c4 0c             	add    $0xc,%esp
  801bd1:	68 07 04 00 00       	push   $0x407
  801bd6:	50                   	push   %eax
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 d0 ef ff ff       	call   800bae <sys_page_alloc>
  801bde:	89 c3                	mov    %eax,%ebx
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	85 c0                	test   %eax,%eax
  801be5:	0f 88 89 00 00 00    	js     801c74 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf1:	e8 7c f5 ff ff       	call   801172 <fd2data>
  801bf6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bfd:	50                   	push   %eax
  801bfe:	6a 00                	push   $0x0
  801c00:	56                   	push   %esi
  801c01:	6a 00                	push   $0x0
  801c03:	e8 e9 ef ff ff       	call   800bf1 <sys_page_map>
  801c08:	89 c3                	mov    %eax,%ebx
  801c0a:	83 c4 20             	add    $0x20,%esp
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	78 55                	js     801c66 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c26:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c3b:	83 ec 0c             	sub    $0xc,%esp
  801c3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c41:	e8 1c f5 ff ff       	call   801162 <fd2num>
  801c46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c49:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c4b:	83 c4 04             	add    $0x4,%esp
  801c4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c51:	e8 0c f5 ff ff       	call   801162 <fd2num>
  801c56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c59:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c64:	eb 30                	jmp    801c96 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c66:	83 ec 08             	sub    $0x8,%esp
  801c69:	56                   	push   %esi
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 c2 ef ff ff       	call   800c33 <sys_page_unmap>
  801c71:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c74:	83 ec 08             	sub    $0x8,%esp
  801c77:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7a:	6a 00                	push   $0x0
  801c7c:	e8 b2 ef ff ff       	call   800c33 <sys_page_unmap>
  801c81:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c84:	83 ec 08             	sub    $0x8,%esp
  801c87:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8a:	6a 00                	push   $0x0
  801c8c:	e8 a2 ef ff ff       	call   800c33 <sys_page_unmap>
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c96:	89 d0                	mov    %edx,%eax
  801c98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9b:	5b                   	pop    %ebx
  801c9c:	5e                   	pop    %esi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca8:	50                   	push   %eax
  801ca9:	ff 75 08             	pushl  0x8(%ebp)
  801cac:	e8 27 f5 ff ff       	call   8011d8 <fd_lookup>
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	78 18                	js     801cd0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cb8:	83 ec 0c             	sub    $0xc,%esp
  801cbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbe:	e8 af f4 ff ff       	call   801172 <fd2data>
	return _pipeisclosed(fd, p);
  801cc3:	89 c2                	mov    %eax,%edx
  801cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc8:	e8 18 fd ff ff       	call   8019e5 <_pipeisclosed>
  801ccd:	83 c4 10             	add    $0x10,%esp
}
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    

00801cd2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    

00801cdc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ce2:	68 7a 27 80 00       	push   $0x80277a
  801ce7:	ff 75 0c             	pushl  0xc(%ebp)
  801cea:	e8 bc ea ff ff       	call   8007ab <strcpy>
	return 0;
}
  801cef:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	57                   	push   %edi
  801cfa:	56                   	push   %esi
  801cfb:	53                   	push   %ebx
  801cfc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d02:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d07:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d0d:	eb 2d                	jmp    801d3c <devcons_write+0x46>
		m = n - tot;
  801d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d12:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d14:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d17:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d1c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	53                   	push   %ebx
  801d23:	03 45 0c             	add    0xc(%ebp),%eax
  801d26:	50                   	push   %eax
  801d27:	57                   	push   %edi
  801d28:	e8 10 ec ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  801d2d:	83 c4 08             	add    $0x8,%esp
  801d30:	53                   	push   %ebx
  801d31:	57                   	push   %edi
  801d32:	e8 bb ed ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d37:	01 de                	add    %ebx,%esi
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	89 f0                	mov    %esi,%eax
  801d3e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d41:	72 cc                	jb     801d0f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d46:	5b                   	pop    %ebx
  801d47:	5e                   	pop    %esi
  801d48:	5f                   	pop    %edi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	83 ec 08             	sub    $0x8,%esp
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d5a:	74 2a                	je     801d86 <devcons_read+0x3b>
  801d5c:	eb 05                	jmp    801d63 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d5e:	e8 2c ee ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d63:	e8 a8 ed ff ff       	call   800b10 <sys_cgetc>
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	74 f2                	je     801d5e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 16                	js     801d86 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d70:	83 f8 04             	cmp    $0x4,%eax
  801d73:	74 0c                	je     801d81 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d78:	88 02                	mov    %al,(%edx)
	return 1;
  801d7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7f:	eb 05                	jmp    801d86 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d81:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d86:	c9                   	leave  
  801d87:	c3                   	ret    

00801d88 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d91:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d94:	6a 01                	push   $0x1
  801d96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d99:	50                   	push   %eax
  801d9a:	e8 53 ed ff ff       	call   800af2 <sys_cputs>
}
  801d9f:	83 c4 10             	add    $0x10,%esp
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <getchar>:

int
getchar(void)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801daa:	6a 01                	push   $0x1
  801dac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801daf:	50                   	push   %eax
  801db0:	6a 00                	push   $0x0
  801db2:	e8 87 f6 ff ff       	call   80143e <read>
	if (r < 0)
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	78 0f                	js     801dcd <getchar+0x29>
		return r;
	if (r < 1)
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	7e 06                	jle    801dc8 <getchar+0x24>
		return -E_EOF;
	return c;
  801dc2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dc6:	eb 05                	jmp    801dcd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dc8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd8:	50                   	push   %eax
  801dd9:	ff 75 08             	pushl  0x8(%ebp)
  801ddc:	e8 f7 f3 ff ff       	call   8011d8 <fd_lookup>
  801de1:	83 c4 10             	add    $0x10,%esp
  801de4:	85 c0                	test   %eax,%eax
  801de6:	78 11                	js     801df9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801deb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df1:	39 10                	cmp    %edx,(%eax)
  801df3:	0f 94 c0             	sete   %al
  801df6:	0f b6 c0             	movzbl %al,%eax
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <opencons>:

int
opencons(void)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e04:	50                   	push   %eax
  801e05:	e8 7f f3 ff ff       	call   801189 <fd_alloc>
  801e0a:	83 c4 10             	add    $0x10,%esp
		return r;
  801e0d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 3e                	js     801e51 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e13:	83 ec 04             	sub    $0x4,%esp
  801e16:	68 07 04 00 00       	push   $0x407
  801e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 89 ed ff ff       	call   800bae <sys_page_alloc>
  801e25:	83 c4 10             	add    $0x10,%esp
		return r;
  801e28:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 23                	js     801e51 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e37:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e43:	83 ec 0c             	sub    $0xc,%esp
  801e46:	50                   	push   %eax
  801e47:	e8 16 f3 ff ff       	call   801162 <fd2num>
  801e4c:	89 c2                	mov    %eax,%edx
  801e4e:	83 c4 10             	add    $0x10,%esp
}
  801e51:	89 d0                	mov    %edx,%eax
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	56                   	push   %esi
  801e59:	53                   	push   %ebx
  801e5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e63:	85 c0                	test   %eax,%eax
  801e65:	75 12                	jne    801e79 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e67:	83 ec 0c             	sub    $0xc,%esp
  801e6a:	68 00 00 c0 ee       	push   $0xeec00000
  801e6f:	e8 ea ee ff ff       	call   800d5e <sys_ipc_recv>
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	eb 0c                	jmp    801e85 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	50                   	push   %eax
  801e7d:	e8 dc ee ff ff       	call   800d5e <sys_ipc_recv>
  801e82:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e85:	85 f6                	test   %esi,%esi
  801e87:	0f 95 c1             	setne  %cl
  801e8a:	85 db                	test   %ebx,%ebx
  801e8c:	0f 95 c2             	setne  %dl
  801e8f:	84 d1                	test   %dl,%cl
  801e91:	74 09                	je     801e9c <ipc_recv+0x47>
  801e93:	89 c2                	mov    %eax,%edx
  801e95:	c1 ea 1f             	shr    $0x1f,%edx
  801e98:	84 d2                	test   %dl,%dl
  801e9a:	75 2d                	jne    801ec9 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e9c:	85 f6                	test   %esi,%esi
  801e9e:	74 0d                	je     801ead <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801ea0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801eab:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ead:	85 db                	test   %ebx,%ebx
  801eaf:	74 0d                	je     801ebe <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801eb1:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb6:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801ebc:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ebe:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801ec9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ecc:	5b                   	pop    %ebx
  801ecd:	5e                   	pop    %esi
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	57                   	push   %edi
  801ed4:	56                   	push   %esi
  801ed5:	53                   	push   %ebx
  801ed6:	83 ec 0c             	sub    $0xc,%esp
  801ed9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801edc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ee2:	85 db                	test   %ebx,%ebx
  801ee4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ee9:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801eec:	ff 75 14             	pushl  0x14(%ebp)
  801eef:	53                   	push   %ebx
  801ef0:	56                   	push   %esi
  801ef1:	57                   	push   %edi
  801ef2:	e8 44 ee ff ff       	call   800d3b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ef7:	89 c2                	mov    %eax,%edx
  801ef9:	c1 ea 1f             	shr    $0x1f,%edx
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	84 d2                	test   %dl,%dl
  801f01:	74 17                	je     801f1a <ipc_send+0x4a>
  801f03:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f06:	74 12                	je     801f1a <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f08:	50                   	push   %eax
  801f09:	68 86 27 80 00       	push   $0x802786
  801f0e:	6a 47                	push   $0x47
  801f10:	68 94 27 80 00       	push   $0x802794
  801f15:	e8 33 e2 ff ff       	call   80014d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f1a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1d:	75 07                	jne    801f26 <ipc_send+0x56>
			sys_yield();
  801f1f:	e8 6b ec ff ff       	call   800b8f <sys_yield>
  801f24:	eb c6                	jmp    801eec <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f26:	85 c0                	test   %eax,%eax
  801f28:	75 c2                	jne    801eec <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5f                   	pop    %edi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f38:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f3d:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801f43:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f49:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f4f:	39 ca                	cmp    %ecx,%edx
  801f51:	75 10                	jne    801f63 <ipc_find_env+0x31>
			return envs[i].env_id;
  801f53:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801f59:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f5e:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f61:	eb 0f                	jmp    801f72 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f63:	83 c0 01             	add    $0x1,%eax
  801f66:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f6b:	75 d0                	jne    801f3d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7a:	89 d0                	mov    %edx,%eax
  801f7c:	c1 e8 16             	shr    $0x16,%eax
  801f7f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8b:	f6 c1 01             	test   $0x1,%cl
  801f8e:	74 1d                	je     801fad <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f90:	c1 ea 0c             	shr    $0xc,%edx
  801f93:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f9a:	f6 c2 01             	test   $0x1,%dl
  801f9d:	74 0e                	je     801fad <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f9f:	c1 ea 0c             	shr    $0xc,%edx
  801fa2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fa9:	ef 
  801faa:	0f b7 c0             	movzwl %ax,%eax
}
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    
  801faf:	90                   	nop

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fcd:	89 ca                	mov    %ecx,%edx
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	75 3d                	jne    802010 <__udivdi3+0x60>
  801fd3:	39 cf                	cmp    %ecx,%edi
  801fd5:	0f 87 c5 00 00 00    	ja     8020a0 <__udivdi3+0xf0>
  801fdb:	85 ff                	test   %edi,%edi
  801fdd:	89 fd                	mov    %edi,%ebp
  801fdf:	75 0b                	jne    801fec <__udivdi3+0x3c>
  801fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe6:	31 d2                	xor    %edx,%edx
  801fe8:	f7 f7                	div    %edi
  801fea:	89 c5                	mov    %eax,%ebp
  801fec:	89 c8                	mov    %ecx,%eax
  801fee:	31 d2                	xor    %edx,%edx
  801ff0:	f7 f5                	div    %ebp
  801ff2:	89 c1                	mov    %eax,%ecx
  801ff4:	89 d8                	mov    %ebx,%eax
  801ff6:	89 cf                	mov    %ecx,%edi
  801ff8:	f7 f5                	div    %ebp
  801ffa:	89 c3                	mov    %eax,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	39 ce                	cmp    %ecx,%esi
  802012:	77 74                	ja     802088 <__udivdi3+0xd8>
  802014:	0f bd fe             	bsr    %esi,%edi
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	0f 84 98 00 00 00    	je     8020b8 <__udivdi3+0x108>
  802020:	bb 20 00 00 00       	mov    $0x20,%ebx
  802025:	89 f9                	mov    %edi,%ecx
  802027:	89 c5                	mov    %eax,%ebp
  802029:	29 fb                	sub    %edi,%ebx
  80202b:	d3 e6                	shl    %cl,%esi
  80202d:	89 d9                	mov    %ebx,%ecx
  80202f:	d3 ed                	shr    %cl,%ebp
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e0                	shl    %cl,%eax
  802035:	09 ee                	or     %ebp,%esi
  802037:	89 d9                	mov    %ebx,%ecx
  802039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203d:	89 d5                	mov    %edx,%ebp
  80203f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802043:	d3 ed                	shr    %cl,%ebp
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e2                	shl    %cl,%edx
  802049:	89 d9                	mov    %ebx,%ecx
  80204b:	d3 e8                	shr    %cl,%eax
  80204d:	09 c2                	or     %eax,%edx
  80204f:	89 d0                	mov    %edx,%eax
  802051:	89 ea                	mov    %ebp,%edx
  802053:	f7 f6                	div    %esi
  802055:	89 d5                	mov    %edx,%ebp
  802057:	89 c3                	mov    %eax,%ebx
  802059:	f7 64 24 0c          	mull   0xc(%esp)
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	72 10                	jb     802071 <__udivdi3+0xc1>
  802061:	8b 74 24 08          	mov    0x8(%esp),%esi
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e6                	shl    %cl,%esi
  802069:	39 c6                	cmp    %eax,%esi
  80206b:	73 07                	jae    802074 <__udivdi3+0xc4>
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	75 03                	jne    802074 <__udivdi3+0xc4>
  802071:	83 eb 01             	sub    $0x1,%ebx
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 d8                	mov    %ebx,%eax
  802078:	89 fa                	mov    %edi,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	31 ff                	xor    %edi,%edi
  80208a:	31 db                	xor    %ebx,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	f7 f7                	div    %edi
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 c3                	mov    %eax,%ebx
  8020a8:	89 d8                	mov    %ebx,%eax
  8020aa:	89 fa                	mov    %edi,%edx
  8020ac:	83 c4 1c             	add    $0x1c,%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5f                   	pop    %edi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
  8020b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b8:	39 ce                	cmp    %ecx,%esi
  8020ba:	72 0c                	jb     8020c8 <__udivdi3+0x118>
  8020bc:	31 db                	xor    %ebx,%ebx
  8020be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020c2:	0f 87 34 ff ff ff    	ja     801ffc <__udivdi3+0x4c>
  8020c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020cd:	e9 2a ff ff ff       	jmp    801ffc <__udivdi3+0x4c>
  8020d2:	66 90                	xchg   %ax,%ax
  8020d4:	66 90                	xchg   %ax,%ax
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802101:	89 f3                	mov    %esi,%ebx
  802103:	89 3c 24             	mov    %edi,(%esp)
  802106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210a:	75 1c                	jne    802128 <__umoddi3+0x48>
  80210c:	39 f7                	cmp    %esi,%edi
  80210e:	76 50                	jbe    802160 <__umoddi3+0x80>
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	f7 f7                	div    %edi
  802116:	89 d0                	mov    %edx,%eax
  802118:	31 d2                	xor    %edx,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	39 f2                	cmp    %esi,%edx
  80212a:	89 d0                	mov    %edx,%eax
  80212c:	77 52                	ja     802180 <__umoddi3+0xa0>
  80212e:	0f bd ea             	bsr    %edx,%ebp
  802131:	83 f5 1f             	xor    $0x1f,%ebp
  802134:	75 5a                	jne    802190 <__umoddi3+0xb0>
  802136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80213a:	0f 82 e0 00 00 00    	jb     802220 <__umoddi3+0x140>
  802140:	39 0c 24             	cmp    %ecx,(%esp)
  802143:	0f 86 d7 00 00 00    	jbe    802220 <__umoddi3+0x140>
  802149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80214d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802151:	83 c4 1c             	add    $0x1c,%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	85 ff                	test   %edi,%edi
  802162:	89 fd                	mov    %edi,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x91>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f7                	div    %edi
  80216f:	89 c5                	mov    %eax,%ebp
  802171:	89 f0                	mov    %esi,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f5                	div    %ebp
  802177:	89 c8                	mov    %ecx,%eax
  802179:	f7 f5                	div    %ebp
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	eb 99                	jmp    802118 <__umoddi3+0x38>
  80217f:	90                   	nop
  802180:	89 c8                	mov    %ecx,%eax
  802182:	89 f2                	mov    %esi,%edx
  802184:	83 c4 1c             	add    $0x1c,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5f                   	pop    %edi
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802190:	8b 34 24             	mov    (%esp),%esi
  802193:	bf 20 00 00 00       	mov    $0x20,%edi
  802198:	89 e9                	mov    %ebp,%ecx
  80219a:	29 ef                	sub    %ebp,%edi
  80219c:	d3 e0                	shl    %cl,%eax
  80219e:	89 f9                	mov    %edi,%ecx
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	d3 ea                	shr    %cl,%edx
  8021a4:	89 e9                	mov    %ebp,%ecx
  8021a6:	09 c2                	or     %eax,%edx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 14 24             	mov    %edx,(%esp)
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	d3 e2                	shl    %cl,%edx
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	89 c6                	mov    %eax,%esi
  8021c1:	d3 e3                	shl    %cl,%ebx
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 d0                	mov    %edx,%eax
  8021c7:	d3 e8                	shr    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	09 d8                	or     %ebx,%eax
  8021cd:	89 d3                	mov    %edx,%ebx
  8021cf:	89 f2                	mov    %esi,%edx
  8021d1:	f7 34 24             	divl   (%esp)
  8021d4:	89 d6                	mov    %edx,%esi
  8021d6:	d3 e3                	shl    %cl,%ebx
  8021d8:	f7 64 24 04          	mull   0x4(%esp)
  8021dc:	39 d6                	cmp    %edx,%esi
  8021de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e2:	89 d1                	mov    %edx,%ecx
  8021e4:	89 c3                	mov    %eax,%ebx
  8021e6:	72 08                	jb     8021f0 <__umoddi3+0x110>
  8021e8:	75 11                	jne    8021fb <__umoddi3+0x11b>
  8021ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ee:	73 0b                	jae    8021fb <__umoddi3+0x11b>
  8021f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021f4:	1b 14 24             	sbb    (%esp),%edx
  8021f7:	89 d1                	mov    %edx,%ecx
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ff:	29 da                	sub    %ebx,%edx
  802201:	19 ce                	sbb    %ecx,%esi
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 f0                	mov    %esi,%eax
  802207:	d3 e0                	shl    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	d3 ea                	shr    %cl,%edx
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	d3 ee                	shr    %cl,%esi
  802211:	09 d0                	or     %edx,%eax
  802213:	89 f2                	mov    %esi,%edx
  802215:	83 c4 1c             	add    $0x1c,%esp
  802218:	5b                   	pop    %ebx
  802219:	5e                   	pop    %esi
  80221a:	5f                   	pop    %edi
  80221b:	5d                   	pop    %ebp
  80221c:	c3                   	ret    
  80221d:	8d 76 00             	lea    0x0(%esi),%esi
  802220:	29 f9                	sub    %edi,%ecx
  802222:	19 d6                	sbb    %edx,%esi
  802224:	89 74 24 04          	mov    %esi,0x4(%esp)
  802228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80222c:	e9 18 ff ff ff       	jmp    802149 <__umoddi3+0x69>
