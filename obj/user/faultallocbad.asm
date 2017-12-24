
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800040:	68 00 1f 80 00       	push   $0x801f00
  800045:	e8 ec 01 00 00       	call   800236 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 60 0b 00 00       	call   800bbe <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 20 1f 80 00       	push   $0x801f20
  80006f:	6a 0f                	push   $0xf
  800071:	68 0a 1f 80 00       	push   $0x801f0a
  800076:	e8 e2 00 00 00       	call   80015d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 4c 1f 80 00       	push   $0x801f4c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 df 06 00 00       	call   800768 <snprintf>
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
  80009c:	e8 0e 0d 00 00       	call   800daf <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 52 0a 00 00       	call   800b02 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	57                   	push   %edi
  8000b9:	56                   	push   %esi
  8000ba:	53                   	push   %ebx
  8000bb:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000be:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000c5:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000c8:	e8 b3 0a 00 00       	call   800b80 <sys_getenvid>
  8000cd:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000d3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8000d8:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000dd:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8000e2:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8000e5:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8000eb:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8000ee:	39 c8                	cmp    %ecx,%eax
  8000f0:	0f 44 fb             	cmove  %ebx,%edi
  8000f3:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000f8:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000fb:	83 c2 01             	add    $0x1,%edx
  8000fe:	83 c3 7c             	add    $0x7c,%ebx
  800101:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800107:	75 d9                	jne    8000e2 <libmain+0x2d>
  800109:	89 f0                	mov    %esi,%eax
  80010b:	84 c0                	test   %al,%al
  80010d:	74 06                	je     800115 <libmain+0x60>
  80010f:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800115:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800119:	7e 0a                	jle    800125 <libmain+0x70>
		binaryname = argv[0];
  80011b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011e:	8b 00                	mov    (%eax),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	ff 75 0c             	pushl  0xc(%ebp)
  80012b:	ff 75 08             	pushl  0x8(%ebp)
  80012e:	e8 5e ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800133:	e8 0b 00 00 00       	call   800143 <exit>
}
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800149:	e8 bb 0e 00 00       	call   801009 <close_all>
	sys_env_destroy(0);
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	6a 00                	push   $0x0
  800153:	e8 e7 09 00 00       	call   800b3f <sys_env_destroy>
}
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800162:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800165:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80016b:	e8 10 0a 00 00       	call   800b80 <sys_getenvid>
  800170:	83 ec 0c             	sub    $0xc,%esp
  800173:	ff 75 0c             	pushl  0xc(%ebp)
  800176:	ff 75 08             	pushl  0x8(%ebp)
  800179:	56                   	push   %esi
  80017a:	50                   	push   %eax
  80017b:	68 78 1f 80 00       	push   $0x801f78
  800180:	e8 b1 00 00 00       	call   800236 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800185:	83 c4 18             	add    $0x18,%esp
  800188:	53                   	push   %ebx
  800189:	ff 75 10             	pushl  0x10(%ebp)
  80018c:	e8 54 00 00 00       	call   8001e5 <vcprintf>
	cprintf("\n");
  800191:	c7 04 24 b7 23 80 00 	movl   $0x8023b7,(%esp)
  800198:	e8 99 00 00 00       	call   800236 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a0:	cc                   	int3   
  8001a1:	eb fd                	jmp    8001a0 <_panic+0x43>

008001a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 04             	sub    $0x4,%esp
  8001aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ad:	8b 13                	mov    (%ebx),%edx
  8001af:	8d 42 01             	lea    0x1(%edx),%eax
  8001b2:	89 03                	mov    %eax,(%ebx)
  8001b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c0:	75 1a                	jne    8001dc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c2:	83 ec 08             	sub    $0x8,%esp
  8001c5:	68 ff 00 00 00       	push   $0xff
  8001ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cd:	50                   	push   %eax
  8001ce:	e8 2f 09 00 00       	call   800b02 <sys_cputs>
		b->idx = 0;
  8001d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001dc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f5:	00 00 00 
	b.cnt = 0;
  8001f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800202:	ff 75 0c             	pushl  0xc(%ebp)
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020e:	50                   	push   %eax
  80020f:	68 a3 01 80 00       	push   $0x8001a3
  800214:	e8 54 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800219:	83 c4 08             	add    $0x8,%esp
  80021c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800222:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800228:	50                   	push   %eax
  800229:	e8 d4 08 00 00       	call   800b02 <sys_cputs>

	return b.cnt;
}
  80022e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023f:	50                   	push   %eax
  800240:	ff 75 08             	pushl  0x8(%ebp)
  800243:	e8 9d ff ff ff       	call   8001e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 1c             	sub    $0x1c,%esp
  800253:	89 c7                	mov    %eax,%edi
  800255:	89 d6                	mov    %edx,%esi
  800257:	8b 45 08             	mov    0x8(%ebp),%eax
  80025a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800260:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800263:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800271:	39 d3                	cmp    %edx,%ebx
  800273:	72 05                	jb     80027a <printnum+0x30>
  800275:	39 45 10             	cmp    %eax,0x10(%ebp)
  800278:	77 45                	ja     8002bf <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	ff 75 18             	pushl  0x18(%ebp)
  800280:	8b 45 14             	mov    0x14(%ebp),%eax
  800283:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800286:	53                   	push   %ebx
  800287:	ff 75 10             	pushl  0x10(%ebp)
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800290:	ff 75 e0             	pushl  -0x20(%ebp)
  800293:	ff 75 dc             	pushl  -0x24(%ebp)
  800296:	ff 75 d8             	pushl  -0x28(%ebp)
  800299:	e8 d2 19 00 00       	call   801c70 <__udivdi3>
  80029e:	83 c4 18             	add    $0x18,%esp
  8002a1:	52                   	push   %edx
  8002a2:	50                   	push   %eax
  8002a3:	89 f2                	mov    %esi,%edx
  8002a5:	89 f8                	mov    %edi,%eax
  8002a7:	e8 9e ff ff ff       	call   80024a <printnum>
  8002ac:	83 c4 20             	add    $0x20,%esp
  8002af:	eb 18                	jmp    8002c9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	ff 75 18             	pushl  0x18(%ebp)
  8002b8:	ff d7                	call   *%edi
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	eb 03                	jmp    8002c2 <printnum+0x78>
  8002bf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c2:	83 eb 01             	sub    $0x1,%ebx
  8002c5:	85 db                	test   %ebx,%ebx
  8002c7:	7f e8                	jg     8002b1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	56                   	push   %esi
  8002cd:	83 ec 04             	sub    $0x4,%esp
  8002d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002dc:	e8 bf 1a 00 00       	call   801da0 <__umoddi3>
  8002e1:	83 c4 14             	add    $0x14,%esp
  8002e4:	0f be 80 9b 1f 80 00 	movsbl 0x801f9b(%eax),%eax
  8002eb:	50                   	push   %eax
  8002ec:	ff d7                	call   *%edi
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5f                   	pop    %edi
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fc:	83 fa 01             	cmp    $0x1,%edx
  8002ff:	7e 0e                	jle    80030f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 08             	lea    0x8(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	8b 52 04             	mov    0x4(%edx),%edx
  80030d:	eb 22                	jmp    800331 <getuint+0x38>
	else if (lflag)
  80030f:	85 d2                	test   %edx,%edx
  800311:	74 10                	je     800323 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
  800321:	eb 0e                	jmp    800331 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800323:	8b 10                	mov    (%eax),%edx
  800325:	8d 4a 04             	lea    0x4(%edx),%ecx
  800328:	89 08                	mov    %ecx,(%eax)
  80032a:	8b 02                	mov    (%edx),%eax
  80032c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    

00800333 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800339:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	3b 50 04             	cmp    0x4(%eax),%edx
  800342:	73 0a                	jae    80034e <sprintputch+0x1b>
		*b->buf++ = ch;
  800344:	8d 4a 01             	lea    0x1(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	88 02                	mov    %al,(%edx)
}
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800356:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800359:	50                   	push   %eax
  80035a:	ff 75 10             	pushl  0x10(%ebp)
  80035d:	ff 75 0c             	pushl  0xc(%ebp)
  800360:	ff 75 08             	pushl  0x8(%ebp)
  800363:	e8 05 00 00 00       	call   80036d <vprintfmt>
	va_end(ap);
}
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 2c             	sub    $0x2c,%esp
  800376:	8b 75 08             	mov    0x8(%ebp),%esi
  800379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037f:	eb 12                	jmp    800393 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800381:	85 c0                	test   %eax,%eax
  800383:	0f 84 89 03 00 00    	je     800712 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	53                   	push   %ebx
  80038d:	50                   	push   %eax
  80038e:	ff d6                	call   *%esi
  800390:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800393:	83 c7 01             	add    $0x1,%edi
  800396:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039a:	83 f8 25             	cmp    $0x25,%eax
  80039d:	75 e2                	jne    800381 <vprintfmt+0x14>
  80039f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003aa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bd:	eb 07                	jmp    8003c6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8d 47 01             	lea    0x1(%edi),%eax
  8003c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cc:	0f b6 07             	movzbl (%edi),%eax
  8003cf:	0f b6 c8             	movzbl %al,%ecx
  8003d2:	83 e8 23             	sub    $0x23,%eax
  8003d5:	3c 55                	cmp    $0x55,%al
  8003d7:	0f 87 1a 03 00 00    	ja     8006f7 <vprintfmt+0x38a>
  8003dd:	0f b6 c0             	movzbl %al,%eax
  8003e0:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ea:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ee:	eb d6                	jmp    8003c6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fe:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800402:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800405:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800408:	83 fa 09             	cmp    $0x9,%edx
  80040b:	77 39                	ja     800446 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800410:	eb e9                	jmp    8003fb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 48 04             	lea    0x4(%eax),%ecx
  800418:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800423:	eb 27                	jmp    80044c <vprintfmt+0xdf>
  800425:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800428:	85 c0                	test   %eax,%eax
  80042a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042f:	0f 49 c8             	cmovns %eax,%ecx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	eb 8c                	jmp    8003c6 <vprintfmt+0x59>
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800444:	eb 80                	jmp    8003c6 <vprintfmt+0x59>
  800446:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800449:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800450:	0f 89 70 ff ff ff    	jns    8003c6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800456:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800459:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800463:	e9 5e ff ff ff       	jmp    8003c6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800468:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046e:	e9 53 ff ff ff       	jmp    8003c6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8d 50 04             	lea    0x4(%eax),%edx
  800479:	89 55 14             	mov    %edx,0x14(%ebp)
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 30                	pushl  (%eax)
  800482:	ff d6                	call   *%esi
			break;
  800484:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048a:	e9 04 ff ff ff       	jmp    800393 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	99                   	cltd   
  80049b:	31 d0                	xor    %edx,%eax
  80049d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049f:	83 f8 0f             	cmp    $0xf,%eax
  8004a2:	7f 0b                	jg     8004af <vprintfmt+0x142>
  8004a4:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	75 18                	jne    8004c7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004af:	50                   	push   %eax
  8004b0:	68 b3 1f 80 00       	push   $0x801fb3
  8004b5:	53                   	push   %ebx
  8004b6:	56                   	push   %esi
  8004b7:	e8 94 fe ff ff       	call   800350 <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c2:	e9 cc fe ff ff       	jmp    800393 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c7:	52                   	push   %edx
  8004c8:	68 85 23 80 00       	push   $0x802385
  8004cd:	53                   	push   %ebx
  8004ce:	56                   	push   %esi
  8004cf:	e8 7c fe ff ff       	call   800350 <printfmt>
  8004d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	e9 b4 fe ff ff       	jmp    800393 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ea:	85 ff                	test   %edi,%edi
  8004ec:	b8 ac 1f 80 00       	mov    $0x801fac,%eax
  8004f1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f8:	0f 8e 94 00 00 00    	jle    800592 <vprintfmt+0x225>
  8004fe:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800502:	0f 84 98 00 00 00    	je     8005a0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	ff 75 d0             	pushl  -0x30(%ebp)
  80050e:	57                   	push   %edi
  80050f:	e8 86 02 00 00       	call   80079a <strnlen>
  800514:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800517:	29 c1                	sub    %eax,%ecx
  800519:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80051c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800523:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800526:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800529:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	eb 0f                	jmp    80053c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	ff 75 e0             	pushl  -0x20(%ebp)
  800534:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800536:	83 ef 01             	sub    $0x1,%edi
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	85 ff                	test   %edi,%edi
  80053e:	7f ed                	jg     80052d <vprintfmt+0x1c0>
  800540:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800543:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800546:	85 c9                	test   %ecx,%ecx
  800548:	b8 00 00 00 00       	mov    $0x0,%eax
  80054d:	0f 49 c1             	cmovns %ecx,%eax
  800550:	29 c1                	sub    %eax,%ecx
  800552:	89 75 08             	mov    %esi,0x8(%ebp)
  800555:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800558:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055b:	89 cb                	mov    %ecx,%ebx
  80055d:	eb 4d                	jmp    8005ac <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800563:	74 1b                	je     800580 <vprintfmt+0x213>
  800565:	0f be c0             	movsbl %al,%eax
  800568:	83 e8 20             	sub    $0x20,%eax
  80056b:	83 f8 5e             	cmp    $0x5e,%eax
  80056e:	76 10                	jbe    800580 <vprintfmt+0x213>
					putch('?', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	6a 3f                	push   $0x3f
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	eb 0d                	jmp    80058d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	ff 75 0c             	pushl  0xc(%ebp)
  800586:	52                   	push   %edx
  800587:	ff 55 08             	call   *0x8(%ebp)
  80058a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058d:	83 eb 01             	sub    $0x1,%ebx
  800590:	eb 1a                	jmp    8005ac <vprintfmt+0x23f>
  800592:	89 75 08             	mov    %esi,0x8(%ebp)
  800595:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800598:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059e:	eb 0c                	jmp    8005ac <vprintfmt+0x23f>
  8005a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ac:	83 c7 01             	add    $0x1,%edi
  8005af:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b3:	0f be d0             	movsbl %al,%edx
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	74 23                	je     8005dd <vprintfmt+0x270>
  8005ba:	85 f6                	test   %esi,%esi
  8005bc:	78 a1                	js     80055f <vprintfmt+0x1f2>
  8005be:	83 ee 01             	sub    $0x1,%esi
  8005c1:	79 9c                	jns    80055f <vprintfmt+0x1f2>
  8005c3:	89 df                	mov    %ebx,%edi
  8005c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cb:	eb 18                	jmp    8005e5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 20                	push   $0x20
  8005d3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d5:	83 ef 01             	sub    $0x1,%edi
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	eb 08                	jmp    8005e5 <vprintfmt+0x278>
  8005dd:	89 df                	mov    %ebx,%edi
  8005df:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	7f e4                	jg     8005cd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ec:	e9 a2 fd ff ff       	jmp    800393 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f1:	83 fa 01             	cmp    $0x1,%edx
  8005f4:	7e 16                	jle    80060c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 50 08             	lea    0x8(%eax),%edx
  8005fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ff:	8b 50 04             	mov    0x4(%eax),%edx
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800607:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060a:	eb 32                	jmp    80063e <vprintfmt+0x2d1>
	else if (lflag)
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 18                	je     800628 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061e:	89 c1                	mov    %eax,%ecx
  800620:	c1 f9 1f             	sar    $0x1f,%ecx
  800623:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800626:	eb 16                	jmp    80063e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 00                	mov    (%eax),%eax
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	89 c1                	mov    %eax,%ecx
  800638:	c1 f9 1f             	sar    $0x1f,%ecx
  80063b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800641:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800644:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800649:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064d:	79 74                	jns    8006c3 <vprintfmt+0x356>
				putch('-', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 2d                	push   $0x2d
  800655:	ff d6                	call   *%esi
				num = -(long long) num;
  800657:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065d:	f7 d8                	neg    %eax
  80065f:	83 d2 00             	adc    $0x0,%edx
  800662:	f7 da                	neg    %edx
  800664:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800667:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066c:	eb 55                	jmp    8006c3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 83 fc ff ff       	call   8002f9 <getuint>
			base = 10;
  800676:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067b:	eb 46                	jmp    8006c3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067d:	8d 45 14             	lea    0x14(%ebp),%eax
  800680:	e8 74 fc ff ff       	call   8002f9 <getuint>
			base = 8;
  800685:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80068a:	eb 37                	jmp    8006c3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	6a 30                	push   $0x30
  800692:	ff d6                	call   *%esi
			putch('x', putdat);
  800694:	83 c4 08             	add    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 78                	push   $0x78
  80069a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a5:	8b 00                	mov    (%eax),%eax
  8006a7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ac:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006af:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b4:	eb 0d                	jmp    8006c3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b9:	e8 3b fc ff ff       	call   8002f9 <getuint>
			base = 16;
  8006be:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c3:	83 ec 0c             	sub    $0xc,%esp
  8006c6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ca:	57                   	push   %edi
  8006cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ce:	51                   	push   %ecx
  8006cf:	52                   	push   %edx
  8006d0:	50                   	push   %eax
  8006d1:	89 da                	mov    %ebx,%edx
  8006d3:	89 f0                	mov    %esi,%eax
  8006d5:	e8 70 fb ff ff       	call   80024a <printnum>
			break;
  8006da:	83 c4 20             	add    $0x20,%esp
  8006dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e0:	e9 ae fc ff ff       	jmp    800393 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	51                   	push   %ecx
  8006ea:	ff d6                	call   *%esi
			break;
  8006ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f2:	e9 9c fc ff ff       	jmp    800393 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	6a 25                	push   $0x25
  8006fd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	eb 03                	jmp    800707 <vprintfmt+0x39a>
  800704:	83 ef 01             	sub    $0x1,%edi
  800707:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070b:	75 f7                	jne    800704 <vprintfmt+0x397>
  80070d:	e9 81 fc ff ff       	jmp    800393 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800712:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800715:	5b                   	pop    %ebx
  800716:	5e                   	pop    %esi
  800717:	5f                   	pop    %edi
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 18             	sub    $0x18,%esp
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800726:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800729:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800730:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800737:	85 c0                	test   %eax,%eax
  800739:	74 26                	je     800761 <vsnprintf+0x47>
  80073b:	85 d2                	test   %edx,%edx
  80073d:	7e 22                	jle    800761 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073f:	ff 75 14             	pushl  0x14(%ebp)
  800742:	ff 75 10             	pushl  0x10(%ebp)
  800745:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	68 33 03 80 00       	push   $0x800333
  80074e:	e8 1a fc ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800753:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800756:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	eb 05                	jmp    800766 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800771:	50                   	push   %eax
  800772:	ff 75 10             	pushl  0x10(%ebp)
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	ff 75 08             	pushl  0x8(%ebp)
  80077b:	e8 9a ff ff ff       	call   80071a <vsnprintf>
	va_end(ap);

	return rc;
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
  80078d:	eb 03                	jmp    800792 <strlen+0x10>
		n++;
  80078f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800792:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800796:	75 f7                	jne    80078f <strlen+0xd>
		n++;
	return n;
}
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a8:	eb 03                	jmp    8007ad <strnlen+0x13>
		n++;
  8007aa:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ad:	39 c2                	cmp    %eax,%edx
  8007af:	74 08                	je     8007b9 <strnlen+0x1f>
  8007b1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b5:	75 f3                	jne    8007aa <strnlen+0x10>
  8007b7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c5:	89 c2                	mov    %eax,%edx
  8007c7:	83 c2 01             	add    $0x1,%edx
  8007ca:	83 c1 01             	add    $0x1,%ecx
  8007cd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d4:	84 db                	test   %bl,%bl
  8007d6:	75 ef                	jne    8007c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e2:	53                   	push   %ebx
  8007e3:	e8 9a ff ff ff       	call   800782 <strlen>
  8007e8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007eb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ee:	01 d8                	add    %ebx,%eax
  8007f0:	50                   	push   %eax
  8007f1:	e8 c5 ff ff ff       	call   8007bb <strcpy>
	return dst;
}
  8007f6:	89 d8                	mov    %ebx,%eax
  8007f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	8b 75 08             	mov    0x8(%ebp),%esi
  800805:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800808:	89 f3                	mov    %esi,%ebx
  80080a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080d:	89 f2                	mov    %esi,%edx
  80080f:	eb 0f                	jmp    800820 <strncpy+0x23>
		*dst++ = *src;
  800811:	83 c2 01             	add    $0x1,%edx
  800814:	0f b6 01             	movzbl (%ecx),%eax
  800817:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081a:	80 39 01             	cmpb   $0x1,(%ecx)
  80081d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800820:	39 da                	cmp    %ebx,%edx
  800822:	75 ed                	jne    800811 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800824:	89 f0                	mov    %esi,%eax
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 75 08             	mov    0x8(%ebp),%esi
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	8b 55 10             	mov    0x10(%ebp),%edx
  800838:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 21                	je     80085f <strlcpy+0x35>
  80083e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 09                	jmp    80084f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	83 c1 01             	add    $0x1,%ecx
  80084c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084f:	39 c2                	cmp    %eax,%edx
  800851:	74 09                	je     80085c <strlcpy+0x32>
  800853:	0f b6 19             	movzbl (%ecx),%ebx
  800856:	84 db                	test   %bl,%bl
  800858:	75 ec                	jne    800846 <strlcpy+0x1c>
  80085a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085f:	29 f0                	sub    %esi,%eax
}
  800861:	5b                   	pop    %ebx
  800862:	5e                   	pop    %esi
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086e:	eb 06                	jmp    800876 <strcmp+0x11>
		p++, q++;
  800870:	83 c1 01             	add    $0x1,%ecx
  800873:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800876:	0f b6 01             	movzbl (%ecx),%eax
  800879:	84 c0                	test   %al,%al
  80087b:	74 04                	je     800881 <strcmp+0x1c>
  80087d:	3a 02                	cmp    (%edx),%al
  80087f:	74 ef                	je     800870 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800881:	0f b6 c0             	movzbl %al,%eax
  800884:	0f b6 12             	movzbl (%edx),%edx
  800887:	29 d0                	sub    %edx,%eax
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
  800895:	89 c3                	mov    %eax,%ebx
  800897:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089a:	eb 06                	jmp    8008a2 <strncmp+0x17>
		n--, p++, q++;
  80089c:	83 c0 01             	add    $0x1,%eax
  80089f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a2:	39 d8                	cmp    %ebx,%eax
  8008a4:	74 15                	je     8008bb <strncmp+0x30>
  8008a6:	0f b6 08             	movzbl (%eax),%ecx
  8008a9:	84 c9                	test   %cl,%cl
  8008ab:	74 04                	je     8008b1 <strncmp+0x26>
  8008ad:	3a 0a                	cmp    (%edx),%cl
  8008af:	74 eb                	je     80089c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 00             	movzbl (%eax),%eax
  8008b4:	0f b6 12             	movzbl (%edx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
  8008b9:	eb 05                	jmp    8008c0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cd:	eb 07                	jmp    8008d6 <strchr+0x13>
		if (*s == c)
  8008cf:	38 ca                	cmp    %cl,%dl
  8008d1:	74 0f                	je     8008e2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	0f b6 10             	movzbl (%eax),%edx
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	75 f2                	jne    8008cf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ee:	eb 03                	jmp    8008f3 <strfind+0xf>
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 04                	je     8008fe <strfind+0x1a>
  8008fa:	84 d2                	test   %dl,%dl
  8008fc:	75 f2                	jne    8008f0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 7d 08             	mov    0x8(%ebp),%edi
  800909:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	74 36                	je     800946 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800910:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800916:	75 28                	jne    800940 <memset+0x40>
  800918:	f6 c1 03             	test   $0x3,%cl
  80091b:	75 23                	jne    800940 <memset+0x40>
		c &= 0xFF;
  80091d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800921:	89 d3                	mov    %edx,%ebx
  800923:	c1 e3 08             	shl    $0x8,%ebx
  800926:	89 d6                	mov    %edx,%esi
  800928:	c1 e6 18             	shl    $0x18,%esi
  80092b:	89 d0                	mov    %edx,%eax
  80092d:	c1 e0 10             	shl    $0x10,%eax
  800930:	09 f0                	or     %esi,%eax
  800932:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800934:	89 d8                	mov    %ebx,%eax
  800936:	09 d0                	or     %edx,%eax
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	fc                   	cld    
  80093c:	f3 ab                	rep stos %eax,%es:(%edi)
  80093e:	eb 06                	jmp    800946 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800940:	8b 45 0c             	mov    0xc(%ebp),%eax
  800943:	fc                   	cld    
  800944:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800946:	89 f8                	mov    %edi,%eax
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5f                   	pop    %edi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	57                   	push   %edi
  800951:	56                   	push   %esi
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 75 0c             	mov    0xc(%ebp),%esi
  800958:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095b:	39 c6                	cmp    %eax,%esi
  80095d:	73 35                	jae    800994 <memmove+0x47>
  80095f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800962:	39 d0                	cmp    %edx,%eax
  800964:	73 2e                	jae    800994 <memmove+0x47>
		s += n;
		d += n;
  800966:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800969:	89 d6                	mov    %edx,%esi
  80096b:	09 fe                	or     %edi,%esi
  80096d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800973:	75 13                	jne    800988 <memmove+0x3b>
  800975:	f6 c1 03             	test   $0x3,%cl
  800978:	75 0e                	jne    800988 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097a:	83 ef 04             	sub    $0x4,%edi
  80097d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800980:	c1 e9 02             	shr    $0x2,%ecx
  800983:	fd                   	std    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 09                	jmp    800991 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800988:	83 ef 01             	sub    $0x1,%edi
  80098b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098e:	fd                   	std    
  80098f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800991:	fc                   	cld    
  800992:	eb 1d                	jmp    8009b1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800994:	89 f2                	mov    %esi,%edx
  800996:	09 c2                	or     %eax,%edx
  800998:	f6 c2 03             	test   $0x3,%dl
  80099b:	75 0f                	jne    8009ac <memmove+0x5f>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 0a                	jne    8009ac <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
  8009a5:	89 c7                	mov    %eax,%edi
  8009a7:	fc                   	cld    
  8009a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009aa:	eb 05                	jmp    8009b1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ac:	89 c7                	mov    %eax,%edi
  8009ae:	fc                   	cld    
  8009af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b8:	ff 75 10             	pushl  0x10(%ebp)
  8009bb:	ff 75 0c             	pushl  0xc(%ebp)
  8009be:	ff 75 08             	pushl  0x8(%ebp)
  8009c1:	e8 87 ff ff ff       	call   80094d <memmove>
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	56                   	push   %esi
  8009cc:	53                   	push   %ebx
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d3:	89 c6                	mov    %eax,%esi
  8009d5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d8:	eb 1a                	jmp    8009f4 <memcmp+0x2c>
		if (*s1 != *s2)
  8009da:	0f b6 08             	movzbl (%eax),%ecx
  8009dd:	0f b6 1a             	movzbl (%edx),%ebx
  8009e0:	38 d9                	cmp    %bl,%cl
  8009e2:	74 0a                	je     8009ee <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e4:	0f b6 c1             	movzbl %cl,%eax
  8009e7:	0f b6 db             	movzbl %bl,%ebx
  8009ea:	29 d8                	sub    %ebx,%eax
  8009ec:	eb 0f                	jmp    8009fd <memcmp+0x35>
		s1++, s2++;
  8009ee:	83 c0 01             	add    $0x1,%eax
  8009f1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f4:	39 f0                	cmp    %esi,%eax
  8009f6:	75 e2                	jne    8009da <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5e                   	pop    %esi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a08:	89 c1                	mov    %eax,%ecx
  800a0a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a11:	eb 0a                	jmp    800a1d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a13:	0f b6 10             	movzbl (%eax),%edx
  800a16:	39 da                	cmp    %ebx,%edx
  800a18:	74 07                	je     800a21 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	39 c8                	cmp    %ecx,%eax
  800a1f:	72 f2                	jb     800a13 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a21:	5b                   	pop    %ebx
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	57                   	push   %edi
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	eb 03                	jmp    800a35 <strtol+0x11>
		s++;
  800a32:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	0f b6 01             	movzbl (%ecx),%eax
  800a38:	3c 20                	cmp    $0x20,%al
  800a3a:	74 f6                	je     800a32 <strtol+0xe>
  800a3c:	3c 09                	cmp    $0x9,%al
  800a3e:	74 f2                	je     800a32 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a40:	3c 2b                	cmp    $0x2b,%al
  800a42:	75 0a                	jne    800a4e <strtol+0x2a>
		s++;
  800a44:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a47:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4c:	eb 11                	jmp    800a5f <strtol+0x3b>
  800a4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a53:	3c 2d                	cmp    $0x2d,%al
  800a55:	75 08                	jne    800a5f <strtol+0x3b>
		s++, neg = 1;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a65:	75 15                	jne    800a7c <strtol+0x58>
  800a67:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6a:	75 10                	jne    800a7c <strtol+0x58>
  800a6c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a70:	75 7c                	jne    800aee <strtol+0xca>
		s += 2, base = 16;
  800a72:	83 c1 02             	add    $0x2,%ecx
  800a75:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7a:	eb 16                	jmp    800a92 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	75 12                	jne    800a92 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a80:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a85:	80 39 30             	cmpb   $0x30,(%ecx)
  800a88:	75 08                	jne    800a92 <strtol+0x6e>
		s++, base = 8;
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9a:	0f b6 11             	movzbl (%ecx),%edx
  800a9d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 09             	cmp    $0x9,%bl
  800aa5:	77 08                	ja     800aaf <strtol+0x8b>
			dig = *s - '0';
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 30             	sub    $0x30,%edx
  800aad:	eb 22                	jmp    800ad1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aaf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab2:	89 f3                	mov    %esi,%ebx
  800ab4:	80 fb 19             	cmp    $0x19,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	83 ea 57             	sub    $0x57,%edx
  800abf:	eb 10                	jmp    800ad1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 19             	cmp    $0x19,%bl
  800ac9:	77 16                	ja     800ae1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800acb:	0f be d2             	movsbl %dl,%edx
  800ace:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad4:	7d 0b                	jge    800ae1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800add:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adf:	eb b9                	jmp    800a9a <strtol+0x76>

	if (endptr)
  800ae1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae5:	74 0d                	je     800af4 <strtol+0xd0>
		*endptr = (char *) s;
  800ae7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aea:	89 0e                	mov    %ecx,(%esi)
  800aec:	eb 06                	jmp    800af4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aee:	85 db                	test   %ebx,%ebx
  800af0:	74 98                	je     800a8a <strtol+0x66>
  800af2:	eb 9e                	jmp    800a92 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af4:	89 c2                	mov    %eax,%edx
  800af6:	f7 da                	neg    %edx
  800af8:	85 ff                	test   %edi,%edi
  800afa:	0f 45 c2             	cmovne %edx,%eax
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
  800b13:	89 c3                	mov    %eax,%ebx
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	89 c6                	mov    %eax,%esi
  800b19:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	89 cb                	mov    %ecx,%ebx
  800b57:	89 cf                	mov    %ecx,%edi
  800b59:	89 ce                	mov    %ecx,%esi
  800b5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 03                	push   $0x3
  800b67:	68 9f 22 80 00       	push   $0x80229f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 bc 22 80 00       	push   $0x8022bc
  800b73:	e8 e5 f5 ff ff       	call   80015d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_yield>:

void
sys_yield(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	be 00 00 00 00       	mov    $0x0,%esi
  800bcc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	89 f7                	mov    %esi,%edi
  800bdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7e 17                	jle    800bf9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 04                	push   $0x4
  800be8:	68 9f 22 80 00       	push   $0x80229f
  800bed:	6a 23                	push   $0x23
  800bef:	68 bc 22 80 00       	push   $0x8022bc
  800bf4:	e8 64 f5 ff ff       	call   80015d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 05                	push   $0x5
  800c2a:	68 9f 22 80 00       	push   $0x80229f
  800c2f:	6a 23                	push   $0x23
  800c31:	68 bc 22 80 00       	push   $0x8022bc
  800c36:	e8 22 f5 ff ff       	call   80015d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	b8 06 00 00 00       	mov    $0x6,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 06                	push   $0x6
  800c6c:	68 9f 22 80 00       	push   $0x80229f
  800c71:	6a 23                	push   $0x23
  800c73:	68 bc 22 80 00       	push   $0x8022bc
  800c78:	e8 e0 f4 ff ff       	call   80015d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	b8 08 00 00 00       	mov    $0x8,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 08                	push   $0x8
  800cae:	68 9f 22 80 00       	push   $0x80229f
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 bc 22 80 00       	push   $0x8022bc
  800cba:	e8 9e f4 ff ff       	call   80015d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 17                	jle    800d01 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	50                   	push   %eax
  800cee:	6a 09                	push   $0x9
  800cf0:	68 9f 22 80 00       	push   $0x80229f
  800cf5:	6a 23                	push   $0x23
  800cf7:	68 bc 22 80 00       	push   $0x8022bc
  800cfc:	e8 5c f4 ff ff       	call   80015d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d17:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 df                	mov    %ebx,%edi
  800d24:	89 de                	mov    %ebx,%esi
  800d26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7e 17                	jle    800d43 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	50                   	push   %eax
  800d30:	6a 0a                	push   $0xa
  800d32:	68 9f 22 80 00       	push   $0x80229f
  800d37:	6a 23                	push   $0x23
  800d39:	68 bc 22 80 00       	push   $0x8022bc
  800d3e:	e8 1a f4 ff ff       	call   80015d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	be 00 00 00 00       	mov    $0x0,%esi
  800d56:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d67:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 cb                	mov    %ecx,%ebx
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	89 ce                	mov    %ecx,%esi
  800d8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 17                	jle    800da7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 0d                	push   $0xd
  800d96:	68 9f 22 80 00       	push   $0x80229f
  800d9b:	6a 23                	push   $0x23
  800d9d:	68 bc 22 80 00       	push   $0x8022bc
  800da2:	e8 b6 f3 ff ff       	call   80015d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800db5:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dbc:	75 2a                	jne    800de8 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800dbe:	83 ec 04             	sub    $0x4,%esp
  800dc1:	6a 07                	push   $0x7
  800dc3:	68 00 f0 bf ee       	push   $0xeebff000
  800dc8:	6a 00                	push   $0x0
  800dca:	e8 ef fd ff ff       	call   800bbe <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	79 12                	jns    800de8 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800dd6:	50                   	push   %eax
  800dd7:	68 ca 22 80 00       	push   $0x8022ca
  800ddc:	6a 23                	push   $0x23
  800dde:	68 ce 22 80 00       	push   $0x8022ce
  800de3:	e8 75 f3 ff ff       	call   80015d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800df0:	83 ec 08             	sub    $0x8,%esp
  800df3:	68 1a 0e 80 00       	push   $0x800e1a
  800df8:	6a 00                	push   $0x0
  800dfa:	e8 0a ff ff ff       	call   800d09 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800dff:	83 c4 10             	add    $0x10,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	79 12                	jns    800e18 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e06:	50                   	push   %eax
  800e07:	68 ca 22 80 00       	push   $0x8022ca
  800e0c:	6a 2c                	push   $0x2c
  800e0e:	68 ce 22 80 00       	push   $0x8022ce
  800e13:	e8 45 f3 ff ff       	call   80015d <_panic>
	}
}
  800e18:	c9                   	leave  
  800e19:	c3                   	ret    

00800e1a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e1a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e1b:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e20:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e22:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e25:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e29:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e2e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e32:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e34:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e37:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e38:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e3b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e3c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e3d:	c3                   	ret    

00800e3e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	05 00 00 00 30       	add    $0x30000000,%eax
  800e49:	c1 e8 0c             	shr    $0xc,%eax
}
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
  800e54:	05 00 00 00 30       	add    $0x30000000,%eax
  800e59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e5e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	c1 ea 16             	shr    $0x16,%edx
  800e75:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7c:	f6 c2 01             	test   $0x1,%dl
  800e7f:	74 11                	je     800e92 <fd_alloc+0x2d>
  800e81:	89 c2                	mov    %eax,%edx
  800e83:	c1 ea 0c             	shr    $0xc,%edx
  800e86:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8d:	f6 c2 01             	test   $0x1,%dl
  800e90:	75 09                	jne    800e9b <fd_alloc+0x36>
			*fd_store = fd;
  800e92:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
  800e99:	eb 17                	jmp    800eb2 <fd_alloc+0x4d>
  800e9b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ea0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ea5:	75 c9                	jne    800e70 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ead:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eba:	83 f8 1f             	cmp    $0x1f,%eax
  800ebd:	77 36                	ja     800ef5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ebf:	c1 e0 0c             	shl    $0xc,%eax
  800ec2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec7:	89 c2                	mov    %eax,%edx
  800ec9:	c1 ea 16             	shr    $0x16,%edx
  800ecc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed3:	f6 c2 01             	test   $0x1,%dl
  800ed6:	74 24                	je     800efc <fd_lookup+0x48>
  800ed8:	89 c2                	mov    %eax,%edx
  800eda:	c1 ea 0c             	shr    $0xc,%edx
  800edd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee4:	f6 c2 01             	test   $0x1,%dl
  800ee7:	74 1a                	je     800f03 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eec:	89 02                	mov    %eax,(%edx)
	return 0;
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	eb 13                	jmp    800f08 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efa:	eb 0c                	jmp    800f08 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800efc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f01:	eb 05                	jmp    800f08 <fd_lookup+0x54>
  800f03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	83 ec 08             	sub    $0x8,%esp
  800f10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f13:	ba 5c 23 80 00       	mov    $0x80235c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f18:	eb 13                	jmp    800f2d <dev_lookup+0x23>
  800f1a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f1d:	39 08                	cmp    %ecx,(%eax)
  800f1f:	75 0c                	jne    800f2d <dev_lookup+0x23>
			*dev = devtab[i];
  800f21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f24:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	eb 2e                	jmp    800f5b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f2d:	8b 02                	mov    (%edx),%eax
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	75 e7                	jne    800f1a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f33:	a1 04 40 80 00       	mov    0x804004,%eax
  800f38:	8b 40 48             	mov    0x48(%eax),%eax
  800f3b:	83 ec 04             	sub    $0x4,%esp
  800f3e:	51                   	push   %ecx
  800f3f:	50                   	push   %eax
  800f40:	68 dc 22 80 00       	push   $0x8022dc
  800f45:	e8 ec f2 ff ff       	call   800236 <cprintf>
	*dev = 0;
  800f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    

00800f5d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	56                   	push   %esi
  800f61:	53                   	push   %ebx
  800f62:	83 ec 10             	sub    $0x10,%esp
  800f65:	8b 75 08             	mov    0x8(%ebp),%esi
  800f68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6e:	50                   	push   %eax
  800f6f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f75:	c1 e8 0c             	shr    $0xc,%eax
  800f78:	50                   	push   %eax
  800f79:	e8 36 ff ff ff       	call   800eb4 <fd_lookup>
  800f7e:	83 c4 08             	add    $0x8,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 05                	js     800f8a <fd_close+0x2d>
	    || fd != fd2)
  800f85:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f88:	74 0c                	je     800f96 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f8a:	84 db                	test   %bl,%bl
  800f8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f91:	0f 44 c2             	cmove  %edx,%eax
  800f94:	eb 41                	jmp    800fd7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f9c:	50                   	push   %eax
  800f9d:	ff 36                	pushl  (%esi)
  800f9f:	e8 66 ff ff ff       	call   800f0a <dev_lookup>
  800fa4:	89 c3                	mov    %eax,%ebx
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 1a                	js     800fc7 <fd_close+0x6a>
		if (dev->dev_close)
  800fad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fb0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fb3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	74 0b                	je     800fc7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fbc:	83 ec 0c             	sub    $0xc,%esp
  800fbf:	56                   	push   %esi
  800fc0:	ff d0                	call   *%eax
  800fc2:	89 c3                	mov    %eax,%ebx
  800fc4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc7:	83 ec 08             	sub    $0x8,%esp
  800fca:	56                   	push   %esi
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 71 fc ff ff       	call   800c43 <sys_page_unmap>
	return r;
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	89 d8                	mov    %ebx,%eax
}
  800fd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fda:	5b                   	pop    %ebx
  800fdb:	5e                   	pop    %esi
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    

00800fde <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	ff 75 08             	pushl  0x8(%ebp)
  800feb:	e8 c4 fe ff ff       	call   800eb4 <fd_lookup>
  800ff0:	83 c4 08             	add    $0x8,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 10                	js     801007 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	6a 01                	push   $0x1
  800ffc:	ff 75 f4             	pushl  -0xc(%ebp)
  800fff:	e8 59 ff ff ff       	call   800f5d <fd_close>
  801004:	83 c4 10             	add    $0x10,%esp
}
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <close_all>:

void
close_all(void)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	53                   	push   %ebx
  80100d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801010:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	53                   	push   %ebx
  801019:	e8 c0 ff ff ff       	call   800fde <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80101e:	83 c3 01             	add    $0x1,%ebx
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	83 fb 20             	cmp    $0x20,%ebx
  801027:	75 ec                	jne    801015 <close_all+0xc>
		close(i);
}
  801029:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    

0080102e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	83 ec 2c             	sub    $0x2c,%esp
  801037:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80103a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80103d:	50                   	push   %eax
  80103e:	ff 75 08             	pushl  0x8(%ebp)
  801041:	e8 6e fe ff ff       	call   800eb4 <fd_lookup>
  801046:	83 c4 08             	add    $0x8,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	0f 88 c1 00 00 00    	js     801112 <dup+0xe4>
		return r;
	close(newfdnum);
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	56                   	push   %esi
  801055:	e8 84 ff ff ff       	call   800fde <close>

	newfd = INDEX2FD(newfdnum);
  80105a:	89 f3                	mov    %esi,%ebx
  80105c:	c1 e3 0c             	shl    $0xc,%ebx
  80105f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801065:	83 c4 04             	add    $0x4,%esp
  801068:	ff 75 e4             	pushl  -0x1c(%ebp)
  80106b:	e8 de fd ff ff       	call   800e4e <fd2data>
  801070:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801072:	89 1c 24             	mov    %ebx,(%esp)
  801075:	e8 d4 fd ff ff       	call   800e4e <fd2data>
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801080:	89 f8                	mov    %edi,%eax
  801082:	c1 e8 16             	shr    $0x16,%eax
  801085:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80108c:	a8 01                	test   $0x1,%al
  80108e:	74 37                	je     8010c7 <dup+0x99>
  801090:	89 f8                	mov    %edi,%eax
  801092:	c1 e8 0c             	shr    $0xc,%eax
  801095:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80109c:	f6 c2 01             	test   $0x1,%dl
  80109f:	74 26                	je     8010c7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a8:	83 ec 0c             	sub    $0xc,%esp
  8010ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b0:	50                   	push   %eax
  8010b1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b4:	6a 00                	push   $0x0
  8010b6:	57                   	push   %edi
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 43 fb ff ff       	call   800c01 <sys_page_map>
  8010be:	89 c7                	mov    %eax,%edi
  8010c0:	83 c4 20             	add    $0x20,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 2e                	js     8010f5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010ca:	89 d0                	mov    %edx,%eax
  8010cc:	c1 e8 0c             	shr    $0xc,%eax
  8010cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010de:	50                   	push   %eax
  8010df:	53                   	push   %ebx
  8010e0:	6a 00                	push   $0x0
  8010e2:	52                   	push   %edx
  8010e3:	6a 00                	push   $0x0
  8010e5:	e8 17 fb ff ff       	call   800c01 <sys_page_map>
  8010ea:	89 c7                	mov    %eax,%edi
  8010ec:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ef:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f1:	85 ff                	test   %edi,%edi
  8010f3:	79 1d                	jns    801112 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010f5:	83 ec 08             	sub    $0x8,%esp
  8010f8:	53                   	push   %ebx
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 43 fb ff ff       	call   800c43 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801100:	83 c4 08             	add    $0x8,%esp
  801103:	ff 75 d4             	pushl  -0x2c(%ebp)
  801106:	6a 00                	push   $0x0
  801108:	e8 36 fb ff ff       	call   800c43 <sys_page_unmap>
	return r;
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	89 f8                	mov    %edi,%eax
}
  801112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	53                   	push   %ebx
  80111e:	83 ec 14             	sub    $0x14,%esp
  801121:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801124:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	53                   	push   %ebx
  801129:	e8 86 fd ff ff       	call   800eb4 <fd_lookup>
  80112e:	83 c4 08             	add    $0x8,%esp
  801131:	89 c2                	mov    %eax,%edx
  801133:	85 c0                	test   %eax,%eax
  801135:	78 6d                	js     8011a4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801137:	83 ec 08             	sub    $0x8,%esp
  80113a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113d:	50                   	push   %eax
  80113e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801141:	ff 30                	pushl  (%eax)
  801143:	e8 c2 fd ff ff       	call   800f0a <dev_lookup>
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	78 4c                	js     80119b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80114f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801152:	8b 42 08             	mov    0x8(%edx),%eax
  801155:	83 e0 03             	and    $0x3,%eax
  801158:	83 f8 01             	cmp    $0x1,%eax
  80115b:	75 21                	jne    80117e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80115d:	a1 04 40 80 00       	mov    0x804004,%eax
  801162:	8b 40 48             	mov    0x48(%eax),%eax
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	53                   	push   %ebx
  801169:	50                   	push   %eax
  80116a:	68 20 23 80 00       	push   $0x802320
  80116f:	e8 c2 f0 ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80117c:	eb 26                	jmp    8011a4 <read+0x8a>
	}
	if (!dev->dev_read)
  80117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801181:	8b 40 08             	mov    0x8(%eax),%eax
  801184:	85 c0                	test   %eax,%eax
  801186:	74 17                	je     80119f <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801188:	83 ec 04             	sub    $0x4,%esp
  80118b:	ff 75 10             	pushl  0x10(%ebp)
  80118e:	ff 75 0c             	pushl  0xc(%ebp)
  801191:	52                   	push   %edx
  801192:	ff d0                	call   *%eax
  801194:	89 c2                	mov    %eax,%edx
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	eb 09                	jmp    8011a4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119b:	89 c2                	mov    %eax,%edx
  80119d:	eb 05                	jmp    8011a4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80119f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8011a4:	89 d0                	mov    %edx,%eax
  8011a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	57                   	push   %edi
  8011af:	56                   	push   %esi
  8011b0:	53                   	push   %ebx
  8011b1:	83 ec 0c             	sub    $0xc,%esp
  8011b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bf:	eb 21                	jmp    8011e2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c1:	83 ec 04             	sub    $0x4,%esp
  8011c4:	89 f0                	mov    %esi,%eax
  8011c6:	29 d8                	sub    %ebx,%eax
  8011c8:	50                   	push   %eax
  8011c9:	89 d8                	mov    %ebx,%eax
  8011cb:	03 45 0c             	add    0xc(%ebp),%eax
  8011ce:	50                   	push   %eax
  8011cf:	57                   	push   %edi
  8011d0:	e8 45 ff ff ff       	call   80111a <read>
		if (m < 0)
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 10                	js     8011ec <readn+0x41>
			return m;
		if (m == 0)
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	74 0a                	je     8011ea <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e0:	01 c3                	add    %eax,%ebx
  8011e2:	39 f3                	cmp    %esi,%ebx
  8011e4:	72 db                	jb     8011c1 <readn+0x16>
  8011e6:	89 d8                	mov    %ebx,%eax
  8011e8:	eb 02                	jmp    8011ec <readn+0x41>
  8011ea:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5f                   	pop    %edi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 14             	sub    $0x14,%esp
  8011fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801201:	50                   	push   %eax
  801202:	53                   	push   %ebx
  801203:	e8 ac fc ff ff       	call   800eb4 <fd_lookup>
  801208:	83 c4 08             	add    $0x8,%esp
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	85 c0                	test   %eax,%eax
  80120f:	78 68                	js     801279 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	83 ec 08             	sub    $0x8,%esp
  801214:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801217:	50                   	push   %eax
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	ff 30                	pushl  (%eax)
  80121d:	e8 e8 fc ff ff       	call   800f0a <dev_lookup>
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	78 47                	js     801270 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801229:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801230:	75 21                	jne    801253 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801232:	a1 04 40 80 00       	mov    0x804004,%eax
  801237:	8b 40 48             	mov    0x48(%eax),%eax
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	53                   	push   %ebx
  80123e:	50                   	push   %eax
  80123f:	68 3c 23 80 00       	push   $0x80233c
  801244:	e8 ed ef ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801251:	eb 26                	jmp    801279 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801253:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801256:	8b 52 0c             	mov    0xc(%edx),%edx
  801259:	85 d2                	test   %edx,%edx
  80125b:	74 17                	je     801274 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80125d:	83 ec 04             	sub    $0x4,%esp
  801260:	ff 75 10             	pushl  0x10(%ebp)
  801263:	ff 75 0c             	pushl  0xc(%ebp)
  801266:	50                   	push   %eax
  801267:	ff d2                	call   *%edx
  801269:	89 c2                	mov    %eax,%edx
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	eb 09                	jmp    801279 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801270:	89 c2                	mov    %eax,%edx
  801272:	eb 05                	jmp    801279 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801274:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801279:	89 d0                	mov    %edx,%eax
  80127b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <seek>:

int
seek(int fdnum, off_t offset)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801286:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	ff 75 08             	pushl  0x8(%ebp)
  80128d:	e8 22 fc ff ff       	call   800eb4 <fd_lookup>
  801292:	83 c4 08             	add    $0x8,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	78 0e                	js     8012a7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801299:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80129c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    

008012a9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 14             	sub    $0x14,%esp
  8012b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b6:	50                   	push   %eax
  8012b7:	53                   	push   %ebx
  8012b8:	e8 f7 fb ff ff       	call   800eb4 <fd_lookup>
  8012bd:	83 c4 08             	add    $0x8,%esp
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	78 65                	js     80132b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d0:	ff 30                	pushl  (%eax)
  8012d2:	e8 33 fc ff ff       	call   800f0a <dev_lookup>
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 44                	js     801322 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e5:	75 21                	jne    801308 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012e7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ec:	8b 40 48             	mov    0x48(%eax),%eax
  8012ef:	83 ec 04             	sub    $0x4,%esp
  8012f2:	53                   	push   %ebx
  8012f3:	50                   	push   %eax
  8012f4:	68 fc 22 80 00       	push   $0x8022fc
  8012f9:	e8 38 ef ff ff       	call   800236 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801306:	eb 23                	jmp    80132b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801308:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80130b:	8b 52 18             	mov    0x18(%edx),%edx
  80130e:	85 d2                	test   %edx,%edx
  801310:	74 14                	je     801326 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	ff 75 0c             	pushl  0xc(%ebp)
  801318:	50                   	push   %eax
  801319:	ff d2                	call   *%edx
  80131b:	89 c2                	mov    %eax,%edx
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	eb 09                	jmp    80132b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801322:	89 c2                	mov    %eax,%edx
  801324:	eb 05                	jmp    80132b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801326:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80132b:	89 d0                	mov    %edx,%eax
  80132d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	53                   	push   %ebx
  801336:	83 ec 14             	sub    $0x14,%esp
  801339:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	ff 75 08             	pushl  0x8(%ebp)
  801343:	e8 6c fb ff ff       	call   800eb4 <fd_lookup>
  801348:	83 c4 08             	add    $0x8,%esp
  80134b:	89 c2                	mov    %eax,%edx
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 58                	js     8013a9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135b:	ff 30                	pushl  (%eax)
  80135d:	e8 a8 fb ff ff       	call   800f0a <dev_lookup>
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	78 37                	js     8013a0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801369:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801370:	74 32                	je     8013a4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801372:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801375:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80137c:	00 00 00 
	stat->st_isdir = 0;
  80137f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801386:	00 00 00 
	stat->st_dev = dev;
  801389:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	53                   	push   %ebx
  801393:	ff 75 f0             	pushl  -0x10(%ebp)
  801396:	ff 50 14             	call   *0x14(%eax)
  801399:	89 c2                	mov    %eax,%edx
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	eb 09                	jmp    8013a9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a0:	89 c2                	mov    %eax,%edx
  8013a2:	eb 05                	jmp    8013a9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013a9:	89 d0                	mov    %edx,%eax
  8013ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ae:	c9                   	leave  
  8013af:	c3                   	ret    

008013b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	56                   	push   %esi
  8013b4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	6a 00                	push   $0x0
  8013ba:	ff 75 08             	pushl  0x8(%ebp)
  8013bd:	e8 e3 01 00 00       	call   8015a5 <open>
  8013c2:	89 c3                	mov    %eax,%ebx
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 1b                	js     8013e6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	ff 75 0c             	pushl  0xc(%ebp)
  8013d1:	50                   	push   %eax
  8013d2:	e8 5b ff ff ff       	call   801332 <fstat>
  8013d7:	89 c6                	mov    %eax,%esi
	close(fd);
  8013d9:	89 1c 24             	mov    %ebx,(%esp)
  8013dc:	e8 fd fb ff ff       	call   800fde <close>
	return r;
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	89 f0                	mov    %esi,%eax
}
  8013e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e9:	5b                   	pop    %ebx
  8013ea:	5e                   	pop    %esi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	56                   	push   %esi
  8013f1:	53                   	push   %ebx
  8013f2:	89 c6                	mov    %eax,%esi
  8013f4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013f6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013fd:	75 12                	jne    801411 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	6a 01                	push   $0x1
  801404:	e8 f3 07 00 00       	call   801bfc <ipc_find_env>
  801409:	a3 00 40 80 00       	mov    %eax,0x804000
  80140e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801411:	6a 07                	push   $0x7
  801413:	68 00 50 80 00       	push   $0x805000
  801418:	56                   	push   %esi
  801419:	ff 35 00 40 80 00    	pushl  0x804000
  80141f:	e8 76 07 00 00       	call   801b9a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801424:	83 c4 0c             	add    $0xc,%esp
  801427:	6a 00                	push   $0x0
  801429:	53                   	push   %ebx
  80142a:	6a 00                	push   $0x0
  80142c:	e8 f7 06 00 00       	call   801b28 <ipc_recv>
}
  801431:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801434:	5b                   	pop    %ebx
  801435:	5e                   	pop    %esi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80143e:	8b 45 08             	mov    0x8(%ebp),%eax
  801441:	8b 40 0c             	mov    0xc(%eax),%eax
  801444:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801449:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801451:	ba 00 00 00 00       	mov    $0x0,%edx
  801456:	b8 02 00 00 00       	mov    $0x2,%eax
  80145b:	e8 8d ff ff ff       	call   8013ed <fsipc>
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801468:	8b 45 08             	mov    0x8(%ebp),%eax
  80146b:	8b 40 0c             	mov    0xc(%eax),%eax
  80146e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801473:	ba 00 00 00 00       	mov    $0x0,%edx
  801478:	b8 06 00 00 00       	mov    $0x6,%eax
  80147d:	e8 6b ff ff ff       	call   8013ed <fsipc>
}
  801482:	c9                   	leave  
  801483:	c3                   	ret    

00801484 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	53                   	push   %ebx
  801488:	83 ec 04             	sub    $0x4,%esp
  80148b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80148e:	8b 45 08             	mov    0x8(%ebp),%eax
  801491:	8b 40 0c             	mov    0xc(%eax),%eax
  801494:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801499:	ba 00 00 00 00       	mov    $0x0,%edx
  80149e:	b8 05 00 00 00       	mov    $0x5,%eax
  8014a3:	e8 45 ff ff ff       	call   8013ed <fsipc>
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 2c                	js     8014d8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	68 00 50 80 00       	push   $0x805000
  8014b4:	53                   	push   %ebx
  8014b5:	e8 01 f3 ff ff       	call   8007bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ba:	a1 80 50 80 00       	mov    0x805080,%eax
  8014bf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c5:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	83 ec 0c             	sub    $0xc,%esp
  8014e3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ec:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014f2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014f7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014fc:	0f 47 c2             	cmova  %edx,%eax
  8014ff:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801504:	50                   	push   %eax
  801505:	ff 75 0c             	pushl  0xc(%ebp)
  801508:	68 08 50 80 00       	push   $0x805008
  80150d:	e8 3b f4 ff ff       	call   80094d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801512:	ba 00 00 00 00       	mov    $0x0,%edx
  801517:	b8 04 00 00 00       	mov    $0x4,%eax
  80151c:	e8 cc fe ff ff       	call   8013ed <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
  80152e:	8b 40 0c             	mov    0xc(%eax),%eax
  801531:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801536:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80153c:	ba 00 00 00 00       	mov    $0x0,%edx
  801541:	b8 03 00 00 00       	mov    $0x3,%eax
  801546:	e8 a2 fe ff ff       	call   8013ed <fsipc>
  80154b:	89 c3                	mov    %eax,%ebx
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 4b                	js     80159c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801551:	39 c6                	cmp    %eax,%esi
  801553:	73 16                	jae    80156b <devfile_read+0x48>
  801555:	68 6c 23 80 00       	push   $0x80236c
  80155a:	68 73 23 80 00       	push   $0x802373
  80155f:	6a 7c                	push   $0x7c
  801561:	68 88 23 80 00       	push   $0x802388
  801566:	e8 f2 eb ff ff       	call   80015d <_panic>
	assert(r <= PGSIZE);
  80156b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801570:	7e 16                	jle    801588 <devfile_read+0x65>
  801572:	68 93 23 80 00       	push   $0x802393
  801577:	68 73 23 80 00       	push   $0x802373
  80157c:	6a 7d                	push   $0x7d
  80157e:	68 88 23 80 00       	push   $0x802388
  801583:	e8 d5 eb ff ff       	call   80015d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	50                   	push   %eax
  80158c:	68 00 50 80 00       	push   $0x805000
  801591:	ff 75 0c             	pushl  0xc(%ebp)
  801594:	e8 b4 f3 ff ff       	call   80094d <memmove>
	return r;
  801599:	83 c4 10             	add    $0x10,%esp
}
  80159c:	89 d8                	mov    %ebx,%eax
  80159e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 20             	sub    $0x20,%esp
  8015ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015af:	53                   	push   %ebx
  8015b0:	e8 cd f1 ff ff       	call   800782 <strlen>
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015bd:	7f 67                	jg     801626 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	e8 9a f8 ff ff       	call   800e65 <fd_alloc>
  8015cb:	83 c4 10             	add    $0x10,%esp
		return r;
  8015ce:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 57                	js     80162b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	53                   	push   %ebx
  8015d8:	68 00 50 80 00       	push   $0x805000
  8015dd:	e8 d9 f1 ff ff       	call   8007bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f2:	e8 f6 fd ff ff       	call   8013ed <fsipc>
  8015f7:	89 c3                	mov    %eax,%ebx
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	79 14                	jns    801614 <open+0x6f>
		fd_close(fd, 0);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	6a 00                	push   $0x0
  801605:	ff 75 f4             	pushl  -0xc(%ebp)
  801608:	e8 50 f9 ff ff       	call   800f5d <fd_close>
		return r;
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	89 da                	mov    %ebx,%edx
  801612:	eb 17                	jmp    80162b <open+0x86>
	}

	return fd2num(fd);
  801614:	83 ec 0c             	sub    $0xc,%esp
  801617:	ff 75 f4             	pushl  -0xc(%ebp)
  80161a:	e8 1f f8 ff ff       	call   800e3e <fd2num>
  80161f:	89 c2                	mov    %eax,%edx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	eb 05                	jmp    80162b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801626:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80162b:	89 d0                	mov    %edx,%eax
  80162d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801638:	ba 00 00 00 00       	mov    $0x0,%edx
  80163d:	b8 08 00 00 00       	mov    $0x8,%eax
  801642:	e8 a6 fd ff ff       	call   8013ed <fsipc>
}
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	ff 75 08             	pushl  0x8(%ebp)
  801657:	e8 f2 f7 ff ff       	call   800e4e <fd2data>
  80165c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80165e:	83 c4 08             	add    $0x8,%esp
  801661:	68 9f 23 80 00       	push   $0x80239f
  801666:	53                   	push   %ebx
  801667:	e8 4f f1 ff ff       	call   8007bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80166c:	8b 46 04             	mov    0x4(%esi),%eax
  80166f:	2b 06                	sub    (%esi),%eax
  801671:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801677:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167e:	00 00 00 
	stat->st_dev = &devpipe;
  801681:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801688:	30 80 00 
	return 0;
}
  80168b:	b8 00 00 00 00       	mov    $0x0,%eax
  801690:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	53                   	push   %ebx
  80169b:	83 ec 0c             	sub    $0xc,%esp
  80169e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016a1:	53                   	push   %ebx
  8016a2:	6a 00                	push   $0x0
  8016a4:	e8 9a f5 ff ff       	call   800c43 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016a9:	89 1c 24             	mov    %ebx,(%esp)
  8016ac:	e8 9d f7 ff ff       	call   800e4e <fd2data>
  8016b1:	83 c4 08             	add    $0x8,%esp
  8016b4:	50                   	push   %eax
  8016b5:	6a 00                	push   $0x0
  8016b7:	e8 87 f5 ff ff       	call   800c43 <sys_page_unmap>
}
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	57                   	push   %edi
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 1c             	sub    $0x1c,%esp
  8016ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016cd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016d7:	83 ec 0c             	sub    $0xc,%esp
  8016da:	ff 75 e0             	pushl  -0x20(%ebp)
  8016dd:	e8 53 05 00 00       	call   801c35 <pageref>
  8016e2:	89 c3                	mov    %eax,%ebx
  8016e4:	89 3c 24             	mov    %edi,(%esp)
  8016e7:	e8 49 05 00 00       	call   801c35 <pageref>
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	39 c3                	cmp    %eax,%ebx
  8016f1:	0f 94 c1             	sete   %cl
  8016f4:	0f b6 c9             	movzbl %cl,%ecx
  8016f7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016fa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801700:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801703:	39 ce                	cmp    %ecx,%esi
  801705:	74 1b                	je     801722 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801707:	39 c3                	cmp    %eax,%ebx
  801709:	75 c4                	jne    8016cf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80170b:	8b 42 58             	mov    0x58(%edx),%eax
  80170e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801711:	50                   	push   %eax
  801712:	56                   	push   %esi
  801713:	68 a6 23 80 00       	push   $0x8023a6
  801718:	e8 19 eb ff ff       	call   800236 <cprintf>
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	eb ad                	jmp    8016cf <_pipeisclosed+0xe>
	}
}
  801722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801725:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5f                   	pop    %edi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	57                   	push   %edi
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
  801733:	83 ec 28             	sub    $0x28,%esp
  801736:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801739:	56                   	push   %esi
  80173a:	e8 0f f7 ff ff       	call   800e4e <fd2data>
  80173f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	bf 00 00 00 00       	mov    $0x0,%edi
  801749:	eb 4b                	jmp    801796 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80174b:	89 da                	mov    %ebx,%edx
  80174d:	89 f0                	mov    %esi,%eax
  80174f:	e8 6d ff ff ff       	call   8016c1 <_pipeisclosed>
  801754:	85 c0                	test   %eax,%eax
  801756:	75 48                	jne    8017a0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801758:	e8 42 f4 ff ff       	call   800b9f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80175d:	8b 43 04             	mov    0x4(%ebx),%eax
  801760:	8b 0b                	mov    (%ebx),%ecx
  801762:	8d 51 20             	lea    0x20(%ecx),%edx
  801765:	39 d0                	cmp    %edx,%eax
  801767:	73 e2                	jae    80174b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801770:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801773:	89 c2                	mov    %eax,%edx
  801775:	c1 fa 1f             	sar    $0x1f,%edx
  801778:	89 d1                	mov    %edx,%ecx
  80177a:	c1 e9 1b             	shr    $0x1b,%ecx
  80177d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801780:	83 e2 1f             	and    $0x1f,%edx
  801783:	29 ca                	sub    %ecx,%edx
  801785:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801789:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80178d:	83 c0 01             	add    $0x1,%eax
  801790:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801793:	83 c7 01             	add    $0x1,%edi
  801796:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801799:	75 c2                	jne    80175d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80179b:	8b 45 10             	mov    0x10(%ebp),%eax
  80179e:	eb 05                	jmp    8017a5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017a0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5f                   	pop    %edi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	57                   	push   %edi
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
  8017b3:	83 ec 18             	sub    $0x18,%esp
  8017b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017b9:	57                   	push   %edi
  8017ba:	e8 8f f6 ff ff       	call   800e4e <fd2data>
  8017bf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c9:	eb 3d                	jmp    801808 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017cb:	85 db                	test   %ebx,%ebx
  8017cd:	74 04                	je     8017d3 <devpipe_read+0x26>
				return i;
  8017cf:	89 d8                	mov    %ebx,%eax
  8017d1:	eb 44                	jmp    801817 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017d3:	89 f2                	mov    %esi,%edx
  8017d5:	89 f8                	mov    %edi,%eax
  8017d7:	e8 e5 fe ff ff       	call   8016c1 <_pipeisclosed>
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	75 32                	jne    801812 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017e0:	e8 ba f3 ff ff       	call   800b9f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017e5:	8b 06                	mov    (%esi),%eax
  8017e7:	3b 46 04             	cmp    0x4(%esi),%eax
  8017ea:	74 df                	je     8017cb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017ec:	99                   	cltd   
  8017ed:	c1 ea 1b             	shr    $0x1b,%edx
  8017f0:	01 d0                	add    %edx,%eax
  8017f2:	83 e0 1f             	and    $0x1f,%eax
  8017f5:	29 d0                	sub    %edx,%eax
  8017f7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ff:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801802:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801805:	83 c3 01             	add    $0x1,%ebx
  801808:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80180b:	75 d8                	jne    8017e5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80180d:	8b 45 10             	mov    0x10(%ebp),%eax
  801810:	eb 05                	jmp    801817 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801812:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5f                   	pop    %edi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	56                   	push   %esi
  801823:	53                   	push   %ebx
  801824:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801827:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182a:	50                   	push   %eax
  80182b:	e8 35 f6 ff ff       	call   800e65 <fd_alloc>
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	89 c2                	mov    %eax,%edx
  801835:	85 c0                	test   %eax,%eax
  801837:	0f 88 2c 01 00 00    	js     801969 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183d:	83 ec 04             	sub    $0x4,%esp
  801840:	68 07 04 00 00       	push   $0x407
  801845:	ff 75 f4             	pushl  -0xc(%ebp)
  801848:	6a 00                	push   $0x0
  80184a:	e8 6f f3 ff ff       	call   800bbe <sys_page_alloc>
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	89 c2                	mov    %eax,%edx
  801854:	85 c0                	test   %eax,%eax
  801856:	0f 88 0d 01 00 00    	js     801969 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801862:	50                   	push   %eax
  801863:	e8 fd f5 ff ff       	call   800e65 <fd_alloc>
  801868:	89 c3                	mov    %eax,%ebx
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	85 c0                	test   %eax,%eax
  80186f:	0f 88 e2 00 00 00    	js     801957 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	68 07 04 00 00       	push   $0x407
  80187d:	ff 75 f0             	pushl  -0x10(%ebp)
  801880:	6a 00                	push   $0x0
  801882:	e8 37 f3 ff ff       	call   800bbe <sys_page_alloc>
  801887:	89 c3                	mov    %eax,%ebx
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	0f 88 c3 00 00 00    	js     801957 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	ff 75 f4             	pushl  -0xc(%ebp)
  80189a:	e8 af f5 ff ff       	call   800e4e <fd2data>
  80189f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a1:	83 c4 0c             	add    $0xc,%esp
  8018a4:	68 07 04 00 00       	push   $0x407
  8018a9:	50                   	push   %eax
  8018aa:	6a 00                	push   $0x0
  8018ac:	e8 0d f3 ff ff       	call   800bbe <sys_page_alloc>
  8018b1:	89 c3                	mov    %eax,%ebx
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	0f 88 89 00 00 00    	js     801947 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018be:	83 ec 0c             	sub    $0xc,%esp
  8018c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c4:	e8 85 f5 ff ff       	call   800e4e <fd2data>
  8018c9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018d0:	50                   	push   %eax
  8018d1:	6a 00                	push   $0x0
  8018d3:	56                   	push   %esi
  8018d4:	6a 00                	push   $0x0
  8018d6:	e8 26 f3 ff ff       	call   800c01 <sys_page_map>
  8018db:	89 c3                	mov    %eax,%ebx
  8018dd:	83 c4 20             	add    $0x20,%esp
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 55                	js     801939 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018e4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ed:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018f9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801902:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801904:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801907:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80190e:	83 ec 0c             	sub    $0xc,%esp
  801911:	ff 75 f4             	pushl  -0xc(%ebp)
  801914:	e8 25 f5 ff ff       	call   800e3e <fd2num>
  801919:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80191e:	83 c4 04             	add    $0x4,%esp
  801921:	ff 75 f0             	pushl  -0x10(%ebp)
  801924:	e8 15 f5 ff ff       	call   800e3e <fd2num>
  801929:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	ba 00 00 00 00       	mov    $0x0,%edx
  801937:	eb 30                	jmp    801969 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801939:	83 ec 08             	sub    $0x8,%esp
  80193c:	56                   	push   %esi
  80193d:	6a 00                	push   $0x0
  80193f:	e8 ff f2 ff ff       	call   800c43 <sys_page_unmap>
  801944:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	ff 75 f0             	pushl  -0x10(%ebp)
  80194d:	6a 00                	push   $0x0
  80194f:	e8 ef f2 ff ff       	call   800c43 <sys_page_unmap>
  801954:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	ff 75 f4             	pushl  -0xc(%ebp)
  80195d:	6a 00                	push   $0x0
  80195f:	e8 df f2 ff ff       	call   800c43 <sys_page_unmap>
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801969:	89 d0                	mov    %edx,%eax
  80196b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5e                   	pop    %esi
  801970:	5d                   	pop    %ebp
  801971:	c3                   	ret    

00801972 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801978:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197b:	50                   	push   %eax
  80197c:	ff 75 08             	pushl  0x8(%ebp)
  80197f:	e8 30 f5 ff ff       	call   800eb4 <fd_lookup>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	78 18                	js     8019a3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	ff 75 f4             	pushl  -0xc(%ebp)
  801991:	e8 b8 f4 ff ff       	call   800e4e <fd2data>
	return _pipeisclosed(fd, p);
  801996:	89 c2                	mov    %eax,%edx
  801998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199b:	e8 21 fd ff ff       	call   8016c1 <_pipeisclosed>
  8019a0:	83 c4 10             	add    $0x10,%esp
}
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019b5:	68 be 23 80 00       	push   $0x8023be
  8019ba:	ff 75 0c             	pushl  0xc(%ebp)
  8019bd:	e8 f9 ed ff ff       	call   8007bb <strcpy>
	return 0;
}
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	57                   	push   %edi
  8019cd:	56                   	push   %esi
  8019ce:	53                   	push   %ebx
  8019cf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019da:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e0:	eb 2d                	jmp    801a0f <devcons_write+0x46>
		m = n - tot;
  8019e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019e5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019e7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019ea:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019ef:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019f2:	83 ec 04             	sub    $0x4,%esp
  8019f5:	53                   	push   %ebx
  8019f6:	03 45 0c             	add    0xc(%ebp),%eax
  8019f9:	50                   	push   %eax
  8019fa:	57                   	push   %edi
  8019fb:	e8 4d ef ff ff       	call   80094d <memmove>
		sys_cputs(buf, m);
  801a00:	83 c4 08             	add    $0x8,%esp
  801a03:	53                   	push   %ebx
  801a04:	57                   	push   %edi
  801a05:	e8 f8 f0 ff ff       	call   800b02 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a0a:	01 de                	add    %ebx,%esi
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	89 f0                	mov    %esi,%eax
  801a11:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a14:	72 cc                	jb     8019e2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5e                   	pop    %esi
  801a1b:	5f                   	pop    %edi
  801a1c:	5d                   	pop    %ebp
  801a1d:	c3                   	ret    

00801a1e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 08             	sub    $0x8,%esp
  801a24:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a2d:	74 2a                	je     801a59 <devcons_read+0x3b>
  801a2f:	eb 05                	jmp    801a36 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a31:	e8 69 f1 ff ff       	call   800b9f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a36:	e8 e5 f0 ff ff       	call   800b20 <sys_cgetc>
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	74 f2                	je     801a31 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 16                	js     801a59 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a43:	83 f8 04             	cmp    $0x4,%eax
  801a46:	74 0c                	je     801a54 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a48:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a4b:	88 02                	mov    %al,(%edx)
	return 1;
  801a4d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a52:	eb 05                	jmp    801a59 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a54:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a61:	8b 45 08             	mov    0x8(%ebp),%eax
  801a64:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a67:	6a 01                	push   $0x1
  801a69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a6c:	50                   	push   %eax
  801a6d:	e8 90 f0 ff ff       	call   800b02 <sys_cputs>
}
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	c9                   	leave  
  801a76:	c3                   	ret    

00801a77 <getchar>:

int
getchar(void)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a7d:	6a 01                	push   $0x1
  801a7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a82:	50                   	push   %eax
  801a83:	6a 00                	push   $0x0
  801a85:	e8 90 f6 ff ff       	call   80111a <read>
	if (r < 0)
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	78 0f                	js     801aa0 <getchar+0x29>
		return r;
	if (r < 1)
  801a91:	85 c0                	test   %eax,%eax
  801a93:	7e 06                	jle    801a9b <getchar+0x24>
		return -E_EOF;
	return c;
  801a95:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a99:	eb 05                	jmp    801aa0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a9b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801aa0:	c9                   	leave  
  801aa1:	c3                   	ret    

00801aa2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aab:	50                   	push   %eax
  801aac:	ff 75 08             	pushl  0x8(%ebp)
  801aaf:	e8 00 f4 ff ff       	call   800eb4 <fd_lookup>
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 11                	js     801acc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac4:	39 10                	cmp    %edx,(%eax)
  801ac6:	0f 94 c0             	sete   %al
  801ac9:	0f b6 c0             	movzbl %al,%eax
}
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <opencons>:

int
opencons(void)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad7:	50                   	push   %eax
  801ad8:	e8 88 f3 ff ff       	call   800e65 <fd_alloc>
  801add:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	78 3e                	js     801b24 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae6:	83 ec 04             	sub    $0x4,%esp
  801ae9:	68 07 04 00 00       	push   $0x407
  801aee:	ff 75 f4             	pushl  -0xc(%ebp)
  801af1:	6a 00                	push   $0x0
  801af3:	e8 c6 f0 ff ff       	call   800bbe <sys_page_alloc>
  801af8:	83 c4 10             	add    $0x10,%esp
		return r;
  801afb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801afd:	85 c0                	test   %eax,%eax
  801aff:	78 23                	js     801b24 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b16:	83 ec 0c             	sub    $0xc,%esp
  801b19:	50                   	push   %eax
  801b1a:	e8 1f f3 ff ff       	call   800e3e <fd2num>
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	83 c4 10             	add    $0x10,%esp
}
  801b24:	89 d0                	mov    %edx,%eax
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	56                   	push   %esi
  801b2c:	53                   	push   %ebx
  801b2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801b36:	85 c0                	test   %eax,%eax
  801b38:	75 12                	jne    801b4c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	68 00 00 c0 ee       	push   $0xeec00000
  801b42:	e8 27 f2 ff ff       	call   800d6e <sys_ipc_recv>
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	eb 0c                	jmp    801b58 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801b4c:	83 ec 0c             	sub    $0xc,%esp
  801b4f:	50                   	push   %eax
  801b50:	e8 19 f2 ff ff       	call   800d6e <sys_ipc_recv>
  801b55:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801b58:	85 f6                	test   %esi,%esi
  801b5a:	0f 95 c1             	setne  %cl
  801b5d:	85 db                	test   %ebx,%ebx
  801b5f:	0f 95 c2             	setne  %dl
  801b62:	84 d1                	test   %dl,%cl
  801b64:	74 09                	je     801b6f <ipc_recv+0x47>
  801b66:	89 c2                	mov    %eax,%edx
  801b68:	c1 ea 1f             	shr    $0x1f,%edx
  801b6b:	84 d2                	test   %dl,%dl
  801b6d:	75 24                	jne    801b93 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b6f:	85 f6                	test   %esi,%esi
  801b71:	74 0a                	je     801b7d <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b73:	a1 04 40 80 00       	mov    0x804004,%eax
  801b78:	8b 40 74             	mov    0x74(%eax),%eax
  801b7b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b7d:	85 db                	test   %ebx,%ebx
  801b7f:	74 0a                	je     801b8b <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801b81:	a1 04 40 80 00       	mov    0x804004,%eax
  801b86:	8b 40 78             	mov    0x78(%eax),%eax
  801b89:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b90:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5e                   	pop    %esi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	57                   	push   %edi
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 0c             	sub    $0xc,%esp
  801ba3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ba6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ba9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801bac:	85 db                	test   %ebx,%ebx
  801bae:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bb3:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bb6:	ff 75 14             	pushl  0x14(%ebp)
  801bb9:	53                   	push   %ebx
  801bba:	56                   	push   %esi
  801bbb:	57                   	push   %edi
  801bbc:	e8 8a f1 ff ff       	call   800d4b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801bc1:	89 c2                	mov    %eax,%edx
  801bc3:	c1 ea 1f             	shr    $0x1f,%edx
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	84 d2                	test   %dl,%dl
  801bcb:	74 17                	je     801be4 <ipc_send+0x4a>
  801bcd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bd0:	74 12                	je     801be4 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801bd2:	50                   	push   %eax
  801bd3:	68 ca 23 80 00       	push   $0x8023ca
  801bd8:	6a 47                	push   $0x47
  801bda:	68 d8 23 80 00       	push   $0x8023d8
  801bdf:	e8 79 e5 ff ff       	call   80015d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801be4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be7:	75 07                	jne    801bf0 <ipc_send+0x56>
			sys_yield();
  801be9:	e8 b1 ef ff ff       	call   800b9f <sys_yield>
  801bee:	eb c6                	jmp    801bb6 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	75 c2                	jne    801bb6 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf7:	5b                   	pop    %ebx
  801bf8:	5e                   	pop    %esi
  801bf9:	5f                   	pop    %edi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c02:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c07:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c0a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c10:	8b 52 50             	mov    0x50(%edx),%edx
  801c13:	39 ca                	cmp    %ecx,%edx
  801c15:	75 0d                	jne    801c24 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c17:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c1a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c1f:	8b 40 48             	mov    0x48(%eax),%eax
  801c22:	eb 0f                	jmp    801c33 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c24:	83 c0 01             	add    $0x1,%eax
  801c27:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c2c:	75 d9                	jne    801c07 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c3b:	89 d0                	mov    %edx,%eax
  801c3d:	c1 e8 16             	shr    $0x16,%eax
  801c40:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c47:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c4c:	f6 c1 01             	test   $0x1,%cl
  801c4f:	74 1d                	je     801c6e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c51:	c1 ea 0c             	shr    $0xc,%edx
  801c54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c5b:	f6 c2 01             	test   $0x1,%dl
  801c5e:	74 0e                	je     801c6e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c60:	c1 ea 0c             	shr    $0xc,%edx
  801c63:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c6a:	ef 
  801c6b:	0f b7 c0             	movzwl %ax,%eax
}
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <__udivdi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
  801c77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c87:	85 f6                	test   %esi,%esi
  801c89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c8d:	89 ca                	mov    %ecx,%edx
  801c8f:	89 f8                	mov    %edi,%eax
  801c91:	75 3d                	jne    801cd0 <__udivdi3+0x60>
  801c93:	39 cf                	cmp    %ecx,%edi
  801c95:	0f 87 c5 00 00 00    	ja     801d60 <__udivdi3+0xf0>
  801c9b:	85 ff                	test   %edi,%edi
  801c9d:	89 fd                	mov    %edi,%ebp
  801c9f:	75 0b                	jne    801cac <__udivdi3+0x3c>
  801ca1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca6:	31 d2                	xor    %edx,%edx
  801ca8:	f7 f7                	div    %edi
  801caa:	89 c5                	mov    %eax,%ebp
  801cac:	89 c8                	mov    %ecx,%eax
  801cae:	31 d2                	xor    %edx,%edx
  801cb0:	f7 f5                	div    %ebp
  801cb2:	89 c1                	mov    %eax,%ecx
  801cb4:	89 d8                	mov    %ebx,%eax
  801cb6:	89 cf                	mov    %ecx,%edi
  801cb8:	f7 f5                	div    %ebp
  801cba:	89 c3                	mov    %eax,%ebx
  801cbc:	89 d8                	mov    %ebx,%eax
  801cbe:	89 fa                	mov    %edi,%edx
  801cc0:	83 c4 1c             	add    $0x1c,%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    
  801cc8:	90                   	nop
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	39 ce                	cmp    %ecx,%esi
  801cd2:	77 74                	ja     801d48 <__udivdi3+0xd8>
  801cd4:	0f bd fe             	bsr    %esi,%edi
  801cd7:	83 f7 1f             	xor    $0x1f,%edi
  801cda:	0f 84 98 00 00 00    	je     801d78 <__udivdi3+0x108>
  801ce0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	89 c5                	mov    %eax,%ebp
  801ce9:	29 fb                	sub    %edi,%ebx
  801ceb:	d3 e6                	shl    %cl,%esi
  801ced:	89 d9                	mov    %ebx,%ecx
  801cef:	d3 ed                	shr    %cl,%ebp
  801cf1:	89 f9                	mov    %edi,%ecx
  801cf3:	d3 e0                	shl    %cl,%eax
  801cf5:	09 ee                	or     %ebp,%esi
  801cf7:	89 d9                	mov    %ebx,%ecx
  801cf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cfd:	89 d5                	mov    %edx,%ebp
  801cff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d03:	d3 ed                	shr    %cl,%ebp
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	d3 e2                	shl    %cl,%edx
  801d09:	89 d9                	mov    %ebx,%ecx
  801d0b:	d3 e8                	shr    %cl,%eax
  801d0d:	09 c2                	or     %eax,%edx
  801d0f:	89 d0                	mov    %edx,%eax
  801d11:	89 ea                	mov    %ebp,%edx
  801d13:	f7 f6                	div    %esi
  801d15:	89 d5                	mov    %edx,%ebp
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	f7 64 24 0c          	mull   0xc(%esp)
  801d1d:	39 d5                	cmp    %edx,%ebp
  801d1f:	72 10                	jb     801d31 <__udivdi3+0xc1>
  801d21:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	d3 e6                	shl    %cl,%esi
  801d29:	39 c6                	cmp    %eax,%esi
  801d2b:	73 07                	jae    801d34 <__udivdi3+0xc4>
  801d2d:	39 d5                	cmp    %edx,%ebp
  801d2f:	75 03                	jne    801d34 <__udivdi3+0xc4>
  801d31:	83 eb 01             	sub    $0x1,%ebx
  801d34:	31 ff                	xor    %edi,%edi
  801d36:	89 d8                	mov    %ebx,%eax
  801d38:	89 fa                	mov    %edi,%edx
  801d3a:	83 c4 1c             	add    $0x1c,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d48:	31 ff                	xor    %edi,%edi
  801d4a:	31 db                	xor    %ebx,%ebx
  801d4c:	89 d8                	mov    %ebx,%eax
  801d4e:	89 fa                	mov    %edi,%edx
  801d50:	83 c4 1c             	add    $0x1c,%esp
  801d53:	5b                   	pop    %ebx
  801d54:	5e                   	pop    %esi
  801d55:	5f                   	pop    %edi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    
  801d58:	90                   	nop
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	89 d8                	mov    %ebx,%eax
  801d62:	f7 f7                	div    %edi
  801d64:	31 ff                	xor    %edi,%edi
  801d66:	89 c3                	mov    %eax,%ebx
  801d68:	89 d8                	mov    %ebx,%eax
  801d6a:	89 fa                	mov    %edi,%edx
  801d6c:	83 c4 1c             	add    $0x1c,%esp
  801d6f:	5b                   	pop    %ebx
  801d70:	5e                   	pop    %esi
  801d71:	5f                   	pop    %edi
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    
  801d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d78:	39 ce                	cmp    %ecx,%esi
  801d7a:	72 0c                	jb     801d88 <__udivdi3+0x118>
  801d7c:	31 db                	xor    %ebx,%ebx
  801d7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d82:	0f 87 34 ff ff ff    	ja     801cbc <__udivdi3+0x4c>
  801d88:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d8d:	e9 2a ff ff ff       	jmp    801cbc <__udivdi3+0x4c>
  801d92:	66 90                	xchg   %ax,%ax
  801d94:	66 90                	xchg   %ax,%ax
  801d96:	66 90                	xchg   %ax,%ax
  801d98:	66 90                	xchg   %ax,%ax
  801d9a:	66 90                	xchg   %ax,%ax
  801d9c:	66 90                	xchg   %ax,%ax
  801d9e:	66 90                	xchg   %ax,%ax

00801da0 <__umoddi3>:
  801da0:	55                   	push   %ebp
  801da1:	57                   	push   %edi
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	83 ec 1c             	sub    $0x1c,%esp
  801da7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801daf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801db7:	85 d2                	test   %edx,%edx
  801db9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dc1:	89 f3                	mov    %esi,%ebx
  801dc3:	89 3c 24             	mov    %edi,(%esp)
  801dc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dca:	75 1c                	jne    801de8 <__umoddi3+0x48>
  801dcc:	39 f7                	cmp    %esi,%edi
  801dce:	76 50                	jbe    801e20 <__umoddi3+0x80>
  801dd0:	89 c8                	mov    %ecx,%eax
  801dd2:	89 f2                	mov    %esi,%edx
  801dd4:	f7 f7                	div    %edi
  801dd6:	89 d0                	mov    %edx,%eax
  801dd8:	31 d2                	xor    %edx,%edx
  801dda:	83 c4 1c             	add    $0x1c,%esp
  801ddd:	5b                   	pop    %ebx
  801dde:	5e                   	pop    %esi
  801ddf:	5f                   	pop    %edi
  801de0:	5d                   	pop    %ebp
  801de1:	c3                   	ret    
  801de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801de8:	39 f2                	cmp    %esi,%edx
  801dea:	89 d0                	mov    %edx,%eax
  801dec:	77 52                	ja     801e40 <__umoddi3+0xa0>
  801dee:	0f bd ea             	bsr    %edx,%ebp
  801df1:	83 f5 1f             	xor    $0x1f,%ebp
  801df4:	75 5a                	jne    801e50 <__umoddi3+0xb0>
  801df6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dfa:	0f 82 e0 00 00 00    	jb     801ee0 <__umoddi3+0x140>
  801e00:	39 0c 24             	cmp    %ecx,(%esp)
  801e03:	0f 86 d7 00 00 00    	jbe    801ee0 <__umoddi3+0x140>
  801e09:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e11:	83 c4 1c             	add    $0x1c,%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	5f                   	pop    %edi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    
  801e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e20:	85 ff                	test   %edi,%edi
  801e22:	89 fd                	mov    %edi,%ebp
  801e24:	75 0b                	jne    801e31 <__umoddi3+0x91>
  801e26:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	f7 f7                	div    %edi
  801e2f:	89 c5                	mov    %eax,%ebp
  801e31:	89 f0                	mov    %esi,%eax
  801e33:	31 d2                	xor    %edx,%edx
  801e35:	f7 f5                	div    %ebp
  801e37:	89 c8                	mov    %ecx,%eax
  801e39:	f7 f5                	div    %ebp
  801e3b:	89 d0                	mov    %edx,%eax
  801e3d:	eb 99                	jmp    801dd8 <__umoddi3+0x38>
  801e3f:	90                   	nop
  801e40:	89 c8                	mov    %ecx,%eax
  801e42:	89 f2                	mov    %esi,%edx
  801e44:	83 c4 1c             	add    $0x1c,%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5f                   	pop    %edi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    
  801e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e50:	8b 34 24             	mov    (%esp),%esi
  801e53:	bf 20 00 00 00       	mov    $0x20,%edi
  801e58:	89 e9                	mov    %ebp,%ecx
  801e5a:	29 ef                	sub    %ebp,%edi
  801e5c:	d3 e0                	shl    %cl,%eax
  801e5e:	89 f9                	mov    %edi,%ecx
  801e60:	89 f2                	mov    %esi,%edx
  801e62:	d3 ea                	shr    %cl,%edx
  801e64:	89 e9                	mov    %ebp,%ecx
  801e66:	09 c2                	or     %eax,%edx
  801e68:	89 d8                	mov    %ebx,%eax
  801e6a:	89 14 24             	mov    %edx,(%esp)
  801e6d:	89 f2                	mov    %esi,%edx
  801e6f:	d3 e2                	shl    %cl,%edx
  801e71:	89 f9                	mov    %edi,%ecx
  801e73:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e7b:	d3 e8                	shr    %cl,%eax
  801e7d:	89 e9                	mov    %ebp,%ecx
  801e7f:	89 c6                	mov    %eax,%esi
  801e81:	d3 e3                	shl    %cl,%ebx
  801e83:	89 f9                	mov    %edi,%ecx
  801e85:	89 d0                	mov    %edx,%eax
  801e87:	d3 e8                	shr    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	09 d8                	or     %ebx,%eax
  801e8d:	89 d3                	mov    %edx,%ebx
  801e8f:	89 f2                	mov    %esi,%edx
  801e91:	f7 34 24             	divl   (%esp)
  801e94:	89 d6                	mov    %edx,%esi
  801e96:	d3 e3                	shl    %cl,%ebx
  801e98:	f7 64 24 04          	mull   0x4(%esp)
  801e9c:	39 d6                	cmp    %edx,%esi
  801e9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ea2:	89 d1                	mov    %edx,%ecx
  801ea4:	89 c3                	mov    %eax,%ebx
  801ea6:	72 08                	jb     801eb0 <__umoddi3+0x110>
  801ea8:	75 11                	jne    801ebb <__umoddi3+0x11b>
  801eaa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801eae:	73 0b                	jae    801ebb <__umoddi3+0x11b>
  801eb0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801eb4:	1b 14 24             	sbb    (%esp),%edx
  801eb7:	89 d1                	mov    %edx,%ecx
  801eb9:	89 c3                	mov    %eax,%ebx
  801ebb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ebf:	29 da                	sub    %ebx,%edx
  801ec1:	19 ce                	sbb    %ecx,%esi
  801ec3:	89 f9                	mov    %edi,%ecx
  801ec5:	89 f0                	mov    %esi,%eax
  801ec7:	d3 e0                	shl    %cl,%eax
  801ec9:	89 e9                	mov    %ebp,%ecx
  801ecb:	d3 ea                	shr    %cl,%edx
  801ecd:	89 e9                	mov    %ebp,%ecx
  801ecf:	d3 ee                	shr    %cl,%esi
  801ed1:	09 d0                	or     %edx,%eax
  801ed3:	89 f2                	mov    %esi,%edx
  801ed5:	83 c4 1c             	add    $0x1c,%esp
  801ed8:	5b                   	pop    %ebx
  801ed9:	5e                   	pop    %esi
  801eda:	5f                   	pop    %edi
  801edb:	5d                   	pop    %ebp
  801edc:	c3                   	ret    
  801edd:	8d 76 00             	lea    0x0(%esi),%esi
  801ee0:	29 f9                	sub    %edi,%ecx
  801ee2:	19 d6                	sbb    %edx,%esi
  801ee4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ee8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eec:	e9 18 ff ff ff       	jmp    801e09 <__umoddi3+0x69>
