
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
  800040:	68 60 1f 80 00       	push   $0x801f60
  800045:	e8 04 02 00 00       	call   80024e <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 78 0b 00 00       	call   800bd6 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 1f 80 00       	push   $0x801f80
  80006f:	6a 0f                	push   $0xf
  800071:	68 6a 1f 80 00       	push   $0x801f6a
  800076:	e8 fa 00 00 00       	call   800175 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 1f 80 00       	push   $0x801fac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 f7 06 00 00       	call   800780 <snprintf>
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
  80009c:	e8 46 0d 00 00       	call   800de7 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 6a 0a 00 00       	call   800b1a <sys_cputs>
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
  8000c8:	e8 cb 0a 00 00       	call   800b98 <sys_getenvid>
  8000cd:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	50                   	push   %eax
  8000d3:	68 d0 1f 80 00       	push   $0x801fd0
  8000d8:	e8 71 01 00 00       	call   80024e <cprintf>
  8000dd:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000e3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000e8:	83 c4 10             	add    $0x10,%esp
  8000eb:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000f0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000f5:	89 c1                	mov    %eax,%ecx
  8000f7:	c1 e1 07             	shl    $0x7,%ecx
  8000fa:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  800101:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800104:	39 cb                	cmp    %ecx,%ebx
  800106:	0f 44 fa             	cmove  %edx,%edi
  800109:	b9 01 00 00 00       	mov    $0x1,%ecx
  80010e:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	81 c2 84 00 00 00    	add    $0x84,%edx
  80011a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80011f:	75 d4                	jne    8000f5 <libmain+0x40>
  800121:	89 f0                	mov    %esi,%eax
  800123:	84 c0                	test   %al,%al
  800125:	74 06                	je     80012d <libmain+0x78>
  800127:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800131:	7e 0a                	jle    80013d <libmain+0x88>
		binaryname = argv[0];
  800133:	8b 45 0c             	mov    0xc(%ebp),%eax
  800136:	8b 00                	mov    (%eax),%eax
  800138:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 46 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  80014b:	e8 0b 00 00 00       	call   80015b <exit>
}
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800161:	e8 db 0e 00 00       	call   801041 <close_all>
	sys_env_destroy(0);
  800166:	83 ec 0c             	sub    $0xc,%esp
  800169:	6a 00                	push   $0x0
  80016b:	e8 e7 09 00 00       	call   800b57 <sys_env_destroy>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80017a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800183:	e8 10 0a 00 00       	call   800b98 <sys_getenvid>
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	ff 75 0c             	pushl  0xc(%ebp)
  80018e:	ff 75 08             	pushl  0x8(%ebp)
  800191:	56                   	push   %esi
  800192:	50                   	push   %eax
  800193:	68 fc 1f 80 00       	push   $0x801ffc
  800198:	e8 b1 00 00 00       	call   80024e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019d:	83 c4 18             	add    $0x18,%esp
  8001a0:	53                   	push   %ebx
  8001a1:	ff 75 10             	pushl  0x10(%ebp)
  8001a4:	e8 54 00 00 00       	call   8001fd <vcprintf>
	cprintf("\n");
  8001a9:	c7 04 24 37 24 80 00 	movl   $0x802437,(%esp)
  8001b0:	e8 99 00 00 00       	call   80024e <cprintf>
  8001b5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b8:	cc                   	int3   
  8001b9:	eb fd                	jmp    8001b8 <_panic+0x43>

008001bb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	53                   	push   %ebx
  8001bf:	83 ec 04             	sub    $0x4,%esp
  8001c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c5:	8b 13                	mov    (%ebx),%edx
  8001c7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ca:	89 03                	mov    %eax,(%ebx)
  8001cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d8:	75 1a                	jne    8001f4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001da:	83 ec 08             	sub    $0x8,%esp
  8001dd:	68 ff 00 00 00       	push   $0xff
  8001e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e5:	50                   	push   %eax
  8001e6:	e8 2f 09 00 00       	call   800b1a <sys_cputs>
		b->idx = 0;
  8001eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800206:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020d:	00 00 00 
	b.cnt = 0;
  800210:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800217:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021a:	ff 75 0c             	pushl  0xc(%ebp)
  80021d:	ff 75 08             	pushl  0x8(%ebp)
  800220:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800226:	50                   	push   %eax
  800227:	68 bb 01 80 00       	push   $0x8001bb
  80022c:	e8 54 01 00 00       	call   800385 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800231:	83 c4 08             	add    $0x8,%esp
  800234:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80023a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800240:	50                   	push   %eax
  800241:	e8 d4 08 00 00       	call   800b1a <sys_cputs>

	return b.cnt;
}
  800246:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800254:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800257:	50                   	push   %eax
  800258:	ff 75 08             	pushl  0x8(%ebp)
  80025b:	e8 9d ff ff ff       	call   8001fd <vcprintf>
	va_end(ap);

	return cnt;
}
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	57                   	push   %edi
  800266:	56                   	push   %esi
  800267:	53                   	push   %ebx
  800268:	83 ec 1c             	sub    $0x1c,%esp
  80026b:	89 c7                	mov    %eax,%edi
  80026d:	89 d6                	mov    %edx,%esi
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	8b 55 0c             	mov    0xc(%ebp),%edx
  800275:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800278:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80027e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800283:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800286:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800289:	39 d3                	cmp    %edx,%ebx
  80028b:	72 05                	jb     800292 <printnum+0x30>
  80028d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800290:	77 45                	ja     8002d7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	ff 75 18             	pushl  0x18(%ebp)
  800298:	8b 45 14             	mov    0x14(%ebp),%eax
  80029b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80029e:	53                   	push   %ebx
  80029f:	ff 75 10             	pushl  0x10(%ebp)
  8002a2:	83 ec 08             	sub    $0x8,%esp
  8002a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b1:	e8 0a 1a 00 00       	call   801cc0 <__udivdi3>
  8002b6:	83 c4 18             	add    $0x18,%esp
  8002b9:	52                   	push   %edx
  8002ba:	50                   	push   %eax
  8002bb:	89 f2                	mov    %esi,%edx
  8002bd:	89 f8                	mov    %edi,%eax
  8002bf:	e8 9e ff ff ff       	call   800262 <printnum>
  8002c4:	83 c4 20             	add    $0x20,%esp
  8002c7:	eb 18                	jmp    8002e1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	56                   	push   %esi
  8002cd:	ff 75 18             	pushl  0x18(%ebp)
  8002d0:	ff d7                	call   *%edi
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	eb 03                	jmp    8002da <printnum+0x78>
  8002d7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002da:	83 eb 01             	sub    $0x1,%ebx
  8002dd:	85 db                	test   %ebx,%ebx
  8002df:	7f e8                	jg     8002c9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e1:	83 ec 08             	sub    $0x8,%esp
  8002e4:	56                   	push   %esi
  8002e5:	83 ec 04             	sub    $0x4,%esp
  8002e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f4:	e8 f7 1a 00 00       	call   801df0 <__umoddi3>
  8002f9:	83 c4 14             	add    $0x14,%esp
  8002fc:	0f be 80 1f 20 80 00 	movsbl 0x80201f(%eax),%eax
  800303:	50                   	push   %eax
  800304:	ff d7                	call   *%edi
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800314:	83 fa 01             	cmp    $0x1,%edx
  800317:	7e 0e                	jle    800327 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	8b 52 04             	mov    0x4(%edx),%edx
  800325:	eb 22                	jmp    800349 <getuint+0x38>
	else if (lflag)
  800327:	85 d2                	test   %edx,%edx
  800329:	74 10                	je     80033b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800330:	89 08                	mov    %ecx,(%eax)
  800332:	8b 02                	mov    (%edx),%eax
  800334:	ba 00 00 00 00       	mov    $0x0,%edx
  800339:	eb 0e                	jmp    800349 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800340:	89 08                	mov    %ecx,(%eax)
  800342:	8b 02                	mov    (%edx),%eax
  800344:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800351:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800355:	8b 10                	mov    (%eax),%edx
  800357:	3b 50 04             	cmp    0x4(%eax),%edx
  80035a:	73 0a                	jae    800366 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 45 08             	mov    0x8(%ebp),%eax
  800364:	88 02                	mov    %al,(%edx)
}
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80036e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800371:	50                   	push   %eax
  800372:	ff 75 10             	pushl  0x10(%ebp)
  800375:	ff 75 0c             	pushl  0xc(%ebp)
  800378:	ff 75 08             	pushl  0x8(%ebp)
  80037b:	e8 05 00 00 00       	call   800385 <vprintfmt>
	va_end(ap);
}
  800380:	83 c4 10             	add    $0x10,%esp
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 2c             	sub    $0x2c,%esp
  80038e:	8b 75 08             	mov    0x8(%ebp),%esi
  800391:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800394:	8b 7d 10             	mov    0x10(%ebp),%edi
  800397:	eb 12                	jmp    8003ab <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800399:	85 c0                	test   %eax,%eax
  80039b:	0f 84 89 03 00 00    	je     80072a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	53                   	push   %ebx
  8003a5:	50                   	push   %eax
  8003a6:	ff d6                	call   *%esi
  8003a8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ab:	83 c7 01             	add    $0x1,%edi
  8003ae:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b2:	83 f8 25             	cmp    $0x25,%eax
  8003b5:	75 e2                	jne    800399 <vprintfmt+0x14>
  8003b7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d5:	eb 07                	jmp    8003de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003da:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8d 47 01             	lea    0x1(%edi),%eax
  8003e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e4:	0f b6 07             	movzbl (%edi),%eax
  8003e7:	0f b6 c8             	movzbl %al,%ecx
  8003ea:	83 e8 23             	sub    $0x23,%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 1a 03 00 00    	ja     80070f <vprintfmt+0x38a>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800402:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800406:	eb d6                	jmp    8003de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800413:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800416:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80041a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80041d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800420:	83 fa 09             	cmp    $0x9,%edx
  800423:	77 39                	ja     80045e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800425:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800428:	eb e9                	jmp    800413 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8d 48 04             	lea    0x4(%eax),%ecx
  800430:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800433:	8b 00                	mov    (%eax),%eax
  800435:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80043b:	eb 27                	jmp    800464 <vprintfmt+0xdf>
  80043d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	b9 00 00 00 00       	mov    $0x0,%ecx
  800447:	0f 49 c8             	cmovns %eax,%ecx
  80044a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800450:	eb 8c                	jmp    8003de <vprintfmt+0x59>
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800455:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80045c:	eb 80                	jmp    8003de <vprintfmt+0x59>
  80045e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800461:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800464:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800468:	0f 89 70 ff ff ff    	jns    8003de <vprintfmt+0x59>
				width = precision, precision = -1;
  80046e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800471:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800474:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80047b:	e9 5e ff ff ff       	jmp    8003de <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800480:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800486:	e9 53 ff ff ff       	jmp    8003de <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	53                   	push   %ebx
  800498:	ff 30                	pushl  (%eax)
  80049a:	ff d6                	call   *%esi
			break;
  80049c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a2:	e9 04 ff ff ff       	jmp    8003ab <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 50 04             	lea    0x4(%eax),%edx
  8004ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b0:	8b 00                	mov    (%eax),%eax
  8004b2:	99                   	cltd   
  8004b3:	31 d0                	xor    %edx,%eax
  8004b5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b7:	83 f8 0f             	cmp    $0xf,%eax
  8004ba:	7f 0b                	jg     8004c7 <vprintfmt+0x142>
  8004bc:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	75 18                	jne    8004df <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004c7:	50                   	push   %eax
  8004c8:	68 37 20 80 00       	push   $0x802037
  8004cd:	53                   	push   %ebx
  8004ce:	56                   	push   %esi
  8004cf:	e8 94 fe ff ff       	call   800368 <printfmt>
  8004d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004da:	e9 cc fe ff ff       	jmp    8003ab <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004df:	52                   	push   %edx
  8004e0:	68 05 24 80 00       	push   $0x802405
  8004e5:	53                   	push   %ebx
  8004e6:	56                   	push   %esi
  8004e7:	e8 7c fe ff ff       	call   800368 <printfmt>
  8004ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f2:	e9 b4 fe ff ff       	jmp    8003ab <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 50 04             	lea    0x4(%eax),%edx
  8004fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800500:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800502:	85 ff                	test   %edi,%edi
  800504:	b8 30 20 80 00       	mov    $0x802030,%eax
  800509:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80050c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800510:	0f 8e 94 00 00 00    	jle    8005aa <vprintfmt+0x225>
  800516:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80051a:	0f 84 98 00 00 00    	je     8005b8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	ff 75 d0             	pushl  -0x30(%ebp)
  800526:	57                   	push   %edi
  800527:	e8 86 02 00 00       	call   8007b2 <strnlen>
  80052c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800534:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800537:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80053b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800541:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	eb 0f                	jmp    800554 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	53                   	push   %ebx
  800549:	ff 75 e0             	pushl  -0x20(%ebp)
  80054c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054e:	83 ef 01             	sub    $0x1,%edi
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	85 ff                	test   %edi,%edi
  800556:	7f ed                	jg     800545 <vprintfmt+0x1c0>
  800558:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80055b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80055e:	85 c9                	test   %ecx,%ecx
  800560:	b8 00 00 00 00       	mov    $0x0,%eax
  800565:	0f 49 c1             	cmovns %ecx,%eax
  800568:	29 c1                	sub    %eax,%ecx
  80056a:	89 75 08             	mov    %esi,0x8(%ebp)
  80056d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800570:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800573:	89 cb                	mov    %ecx,%ebx
  800575:	eb 4d                	jmp    8005c4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800577:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057b:	74 1b                	je     800598 <vprintfmt+0x213>
  80057d:	0f be c0             	movsbl %al,%eax
  800580:	83 e8 20             	sub    $0x20,%eax
  800583:	83 f8 5e             	cmp    $0x5e,%eax
  800586:	76 10                	jbe    800598 <vprintfmt+0x213>
					putch('?', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	ff 75 0c             	pushl  0xc(%ebp)
  80058e:	6a 3f                	push   $0x3f
  800590:	ff 55 08             	call   *0x8(%ebp)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 0d                	jmp    8005a5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	ff 75 0c             	pushl  0xc(%ebp)
  80059e:	52                   	push   %edx
  80059f:	ff 55 08             	call   *0x8(%ebp)
  8005a2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a5:	83 eb 01             	sub    $0x1,%ebx
  8005a8:	eb 1a                	jmp    8005c4 <vprintfmt+0x23f>
  8005aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b6:	eb 0c                	jmp    8005c4 <vprintfmt+0x23f>
  8005b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c4:	83 c7 01             	add    $0x1,%edi
  8005c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005cb:	0f be d0             	movsbl %al,%edx
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	74 23                	je     8005f5 <vprintfmt+0x270>
  8005d2:	85 f6                	test   %esi,%esi
  8005d4:	78 a1                	js     800577 <vprintfmt+0x1f2>
  8005d6:	83 ee 01             	sub    $0x1,%esi
  8005d9:	79 9c                	jns    800577 <vprintfmt+0x1f2>
  8005db:	89 df                	mov    %ebx,%edi
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	eb 18                	jmp    8005fd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 20                	push   $0x20
  8005eb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ed:	83 ef 01             	sub    $0x1,%edi
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	eb 08                	jmp    8005fd <vprintfmt+0x278>
  8005f5:	89 df                	mov    %ebx,%edi
  8005f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fd:	85 ff                	test   %edi,%edi
  8005ff:	7f e4                	jg     8005e5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800604:	e9 a2 fd ff ff       	jmp    8003ab <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800609:	83 fa 01             	cmp    $0x1,%edx
  80060c:	7e 16                	jle    800624 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 08             	lea    0x8(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 50 04             	mov    0x4(%eax),%edx
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800622:	eb 32                	jmp    800656 <vprintfmt+0x2d1>
	else if (lflag)
  800624:	85 d2                	test   %edx,%edx
  800626:	74 18                	je     800640 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 00                	mov    (%eax),%eax
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	89 c1                	mov    %eax,%ecx
  800638:	c1 f9 1f             	sar    $0x1f,%ecx
  80063b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80063e:	eb 16                	jmp    800656 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 00                	mov    (%eax),%eax
  80064b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064e:	89 c1                	mov    %eax,%ecx
  800650:	c1 f9 1f             	sar    $0x1f,%ecx
  800653:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800656:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800659:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800661:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800665:	79 74                	jns    8006db <vprintfmt+0x356>
				putch('-', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 2d                	push   $0x2d
  80066d:	ff d6                	call   *%esi
				num = -(long long) num;
  80066f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800672:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800675:	f7 d8                	neg    %eax
  800677:	83 d2 00             	adc    $0x0,%edx
  80067a:	f7 da                	neg    %edx
  80067c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80067f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800684:	eb 55                	jmp    8006db <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 83 fc ff ff       	call   800311 <getuint>
			base = 10;
  80068e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800693:	eb 46                	jmp    8006db <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 74 fc ff ff       	call   800311 <getuint>
			base = 8;
  80069d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006a2:	eb 37                	jmp    8006db <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 30                	push   $0x30
  8006aa:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ac:	83 c4 08             	add    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 78                	push   $0x78
  8006b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006cc:	eb 0d                	jmp    8006db <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d1:	e8 3b fc ff ff       	call   800311 <getuint>
			base = 16;
  8006d6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006db:	83 ec 0c             	sub    $0xc,%esp
  8006de:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e2:	57                   	push   %edi
  8006e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e6:	51                   	push   %ecx
  8006e7:	52                   	push   %edx
  8006e8:	50                   	push   %eax
  8006e9:	89 da                	mov    %ebx,%edx
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	e8 70 fb ff ff       	call   800262 <printnum>
			break;
  8006f2:	83 c4 20             	add    $0x20,%esp
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f8:	e9 ae fc ff ff       	jmp    8003ab <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	51                   	push   %ecx
  800702:	ff d6                	call   *%esi
			break;
  800704:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070a:	e9 9c fc ff ff       	jmp    8003ab <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 25                	push   $0x25
  800715:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb 03                	jmp    80071f <vprintfmt+0x39a>
  80071c:	83 ef 01             	sub    $0x1,%edi
  80071f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800723:	75 f7                	jne    80071c <vprintfmt+0x397>
  800725:	e9 81 fc ff ff       	jmp    8003ab <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 18             	sub    $0x18,%esp
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800741:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800745:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800748:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 26                	je     800779 <vsnprintf+0x47>
  800753:	85 d2                	test   %edx,%edx
  800755:	7e 22                	jle    800779 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800757:	ff 75 14             	pushl  0x14(%ebp)
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	68 4b 03 80 00       	push   $0x80034b
  800766:	e8 1a fc ff ff       	call   800385 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 05                	jmp    80077e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800779:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800789:	50                   	push   %eax
  80078a:	ff 75 10             	pushl  0x10(%ebp)
  80078d:	ff 75 0c             	pushl  0xc(%ebp)
  800790:	ff 75 08             	pushl  0x8(%ebp)
  800793:	e8 9a ff ff ff       	call   800732 <vsnprintf>
	va_end(ap);

	return rc;
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 03                	jmp    8007aa <strlen+0x10>
		n++;
  8007a7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ae:	75 f7                	jne    8007a7 <strlen+0xd>
		n++;
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c0:	eb 03                	jmp    8007c5 <strnlen+0x13>
		n++;
  8007c2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	39 c2                	cmp    %eax,%edx
  8007c7:	74 08                	je     8007d1 <strnlen+0x1f>
  8007c9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007cd:	75 f3                	jne    8007c2 <strnlen+0x10>
  8007cf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	83 c2 01             	add    $0x1,%edx
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ec:	84 db                	test   %bl,%bl
  8007ee:	75 ef                	jne    8007df <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f0:	5b                   	pop    %ebx
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fa:	53                   	push   %ebx
  8007fb:	e8 9a ff ff ff       	call   80079a <strlen>
  800800:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800803:	ff 75 0c             	pushl  0xc(%ebp)
  800806:	01 d8                	add    %ebx,%eax
  800808:	50                   	push   %eax
  800809:	e8 c5 ff ff ff       	call   8007d3 <strcpy>
	return dst;
}
  80080e:	89 d8                	mov    %ebx,%eax
  800810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	8b 75 08             	mov    0x8(%ebp),%esi
  80081d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800820:	89 f3                	mov    %esi,%ebx
  800822:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800825:	89 f2                	mov    %esi,%edx
  800827:	eb 0f                	jmp    800838 <strncpy+0x23>
		*dst++ = *src;
  800829:	83 c2 01             	add    $0x1,%edx
  80082c:	0f b6 01             	movzbl (%ecx),%eax
  80082f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800832:	80 39 01             	cmpb   $0x1,(%ecx)
  800835:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800838:	39 da                	cmp    %ebx,%edx
  80083a:	75 ed                	jne    800829 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083c:	89 f0                	mov    %esi,%eax
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 75 08             	mov    0x8(%ebp),%esi
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084d:	8b 55 10             	mov    0x10(%ebp),%edx
  800850:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800852:	85 d2                	test   %edx,%edx
  800854:	74 21                	je     800877 <strlcpy+0x35>
  800856:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085a:	89 f2                	mov    %esi,%edx
  80085c:	eb 09                	jmp    800867 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800867:	39 c2                	cmp    %eax,%edx
  800869:	74 09                	je     800874 <strlcpy+0x32>
  80086b:	0f b6 19             	movzbl (%ecx),%ebx
  80086e:	84 db                	test   %bl,%bl
  800870:	75 ec                	jne    80085e <strlcpy+0x1c>
  800872:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800874:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800877:	29 f0                	sub    %esi,%eax
}
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800886:	eb 06                	jmp    80088e <strcmp+0x11>
		p++, q++;
  800888:	83 c1 01             	add    $0x1,%ecx
  80088b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088e:	0f b6 01             	movzbl (%ecx),%eax
  800891:	84 c0                	test   %al,%al
  800893:	74 04                	je     800899 <strcmp+0x1c>
  800895:	3a 02                	cmp    (%edx),%al
  800897:	74 ef                	je     800888 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800899:	0f b6 c0             	movzbl %al,%eax
  80089c:	0f b6 12             	movzbl (%edx),%edx
  80089f:	29 d0                	sub    %edx,%eax
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ad:	89 c3                	mov    %eax,%ebx
  8008af:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b2:	eb 06                	jmp    8008ba <strncmp+0x17>
		n--, p++, q++;
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ba:	39 d8                	cmp    %ebx,%eax
  8008bc:	74 15                	je     8008d3 <strncmp+0x30>
  8008be:	0f b6 08             	movzbl (%eax),%ecx
  8008c1:	84 c9                	test   %cl,%cl
  8008c3:	74 04                	je     8008c9 <strncmp+0x26>
  8008c5:	3a 0a                	cmp    (%edx),%cl
  8008c7:	74 eb                	je     8008b4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 00             	movzbl (%eax),%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
  8008d1:	eb 05                	jmp    8008d8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	eb 07                	jmp    8008ee <strchr+0x13>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 0f                	je     8008fa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f2                	jne    8008e7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800906:	eb 03                	jmp    80090b <strfind+0xf>
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 04                	je     800916 <strfind+0x1a>
  800912:	84 d2                	test   %dl,%dl
  800914:	75 f2                	jne    800908 <strfind+0xc>
			break;
	return (char *) s;
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	57                   	push   %edi
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	74 36                	je     80095e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800928:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092e:	75 28                	jne    800958 <memset+0x40>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 23                	jne    800958 <memset+0x40>
		c &= 0xFF;
  800935:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800939:	89 d3                	mov    %edx,%ebx
  80093b:	c1 e3 08             	shl    $0x8,%ebx
  80093e:	89 d6                	mov    %edx,%esi
  800940:	c1 e6 18             	shl    $0x18,%esi
  800943:	89 d0                	mov    %edx,%eax
  800945:	c1 e0 10             	shl    $0x10,%eax
  800948:	09 f0                	or     %esi,%eax
  80094a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80094c:	89 d8                	mov    %ebx,%eax
  80094e:	09 d0                	or     %edx,%eax
  800950:	c1 e9 02             	shr    $0x2,%ecx
  800953:	fc                   	cld    
  800954:	f3 ab                	rep stos %eax,%es:(%edi)
  800956:	eb 06                	jmp    80095e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800958:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095b:	fc                   	cld    
  80095c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095e:	89 f8                	mov    %edi,%eax
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800973:	39 c6                	cmp    %eax,%esi
  800975:	73 35                	jae    8009ac <memmove+0x47>
  800977:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097a:	39 d0                	cmp    %edx,%eax
  80097c:	73 2e                	jae    8009ac <memmove+0x47>
		s += n;
		d += n;
  80097e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800981:	89 d6                	mov    %edx,%esi
  800983:	09 fe                	or     %edi,%esi
  800985:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098b:	75 13                	jne    8009a0 <memmove+0x3b>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0e                	jne    8009a0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800992:	83 ef 04             	sub    $0x4,%edi
  800995:	8d 72 fc             	lea    -0x4(%edx),%esi
  800998:	c1 e9 02             	shr    $0x2,%ecx
  80099b:	fd                   	std    
  80099c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099e:	eb 09                	jmp    8009a9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a0:	83 ef 01             	sub    $0x1,%edi
  8009a3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a6:	fd                   	std    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a9:	fc                   	cld    
  8009aa:	eb 1d                	jmp    8009c9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	89 f2                	mov    %esi,%edx
  8009ae:	09 c2                	or     %eax,%edx
  8009b0:	f6 c2 03             	test   $0x3,%dl
  8009b3:	75 0f                	jne    8009c4 <memmove+0x5f>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0a                	jne    8009c4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	fc                   	cld    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 05                	jmp    8009c9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c9:	5e                   	pop    %esi
  8009ca:	5f                   	pop    %edi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d0:	ff 75 10             	pushl  0x10(%ebp)
  8009d3:	ff 75 0c             	pushl  0xc(%ebp)
  8009d6:	ff 75 08             	pushl  0x8(%ebp)
  8009d9:	e8 87 ff ff ff       	call   800965 <memmove>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009eb:	89 c6                	mov    %eax,%esi
  8009ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f0:	eb 1a                	jmp    800a0c <memcmp+0x2c>
		if (*s1 != *s2)
  8009f2:	0f b6 08             	movzbl (%eax),%ecx
  8009f5:	0f b6 1a             	movzbl (%edx),%ebx
  8009f8:	38 d9                	cmp    %bl,%cl
  8009fa:	74 0a                	je     800a06 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009fc:	0f b6 c1             	movzbl %cl,%eax
  8009ff:	0f b6 db             	movzbl %bl,%ebx
  800a02:	29 d8                	sub    %ebx,%eax
  800a04:	eb 0f                	jmp    800a15 <memcmp+0x35>
		s1++, s2++;
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0c:	39 f0                	cmp    %esi,%eax
  800a0e:	75 e2                	jne    8009f2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	53                   	push   %ebx
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a20:	89 c1                	mov    %eax,%ecx
  800a22:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a25:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a29:	eb 0a                	jmp    800a35 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2b:	0f b6 10             	movzbl (%eax),%edx
  800a2e:	39 da                	cmp    %ebx,%edx
  800a30:	74 07                	je     800a39 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	39 c8                	cmp    %ecx,%eax
  800a37:	72 f2                	jb     800a2b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a48:	eb 03                	jmp    800a4d <strtol+0x11>
		s++;
  800a4a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4d:	0f b6 01             	movzbl (%ecx),%eax
  800a50:	3c 20                	cmp    $0x20,%al
  800a52:	74 f6                	je     800a4a <strtol+0xe>
  800a54:	3c 09                	cmp    $0x9,%al
  800a56:	74 f2                	je     800a4a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a58:	3c 2b                	cmp    $0x2b,%al
  800a5a:	75 0a                	jne    800a66 <strtol+0x2a>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a64:	eb 11                	jmp    800a77 <strtol+0x3b>
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6b:	3c 2d                	cmp    $0x2d,%al
  800a6d:	75 08                	jne    800a77 <strtol+0x3b>
		s++, neg = 1;
  800a6f:	83 c1 01             	add    $0x1,%ecx
  800a72:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a77:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7d:	75 15                	jne    800a94 <strtol+0x58>
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	75 10                	jne    800a94 <strtol+0x58>
  800a84:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a88:	75 7c                	jne    800b06 <strtol+0xca>
		s += 2, base = 16;
  800a8a:	83 c1 02             	add    $0x2,%ecx
  800a8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a92:	eb 16                	jmp    800aaa <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	75 12                	jne    800aaa <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a98:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa0:	75 08                	jne    800aaa <strtol+0x6e>
		s++, base = 8;
  800aa2:	83 c1 01             	add    $0x1,%ecx
  800aa5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab2:	0f b6 11             	movzbl (%ecx),%edx
  800ab5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 09             	cmp    $0x9,%bl
  800abd:	77 08                	ja     800ac7 <strtol+0x8b>
			dig = *s - '0';
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 30             	sub    $0x30,%edx
  800ac5:	eb 22                	jmp    800ae9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 57             	sub    $0x57,%edx
  800ad7:	eb 10                	jmp    800ae9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adc:	89 f3                	mov    %esi,%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 16                	ja     800af9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae3:	0f be d2             	movsbl %dl,%edx
  800ae6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aec:	7d 0b                	jge    800af9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aee:	83 c1 01             	add    $0x1,%ecx
  800af1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af7:	eb b9                	jmp    800ab2 <strtol+0x76>

	if (endptr)
  800af9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afd:	74 0d                	je     800b0c <strtol+0xd0>
		*endptr = (char *) s;
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	89 0e                	mov    %ecx,(%esi)
  800b04:	eb 06                	jmp    800b0c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b06:	85 db                	test   %ebx,%ebx
  800b08:	74 98                	je     800aa2 <strtol+0x66>
  800b0a:	eb 9e                	jmp    800aaa <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b0c:	89 c2                	mov    %eax,%edx
  800b0e:	f7 da                	neg    %edx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	0f 45 c2             	cmovne %edx,%eax
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	b8 00 00 00 00       	mov    $0x0,%eax
  800b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	89 c3                	mov    %eax,%ebx
  800b2d:	89 c7                	mov    %eax,%edi
  800b2f:	89 c6                	mov    %eax,%esi
  800b31:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 01 00 00 00       	mov    $0x1,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b65:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	89 cb                	mov    %ecx,%ebx
  800b6f:	89 cf                	mov    %ecx,%edi
  800b71:	89 ce                	mov    %ecx,%esi
  800b73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	7e 17                	jle    800b90 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 03                	push   $0x3
  800b7f:	68 1f 23 80 00       	push   $0x80231f
  800b84:	6a 23                	push   $0x23
  800b86:	68 3c 23 80 00       	push   $0x80233c
  800b8b:	e8 e5 f5 ff ff       	call   800175 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba8:	89 d1                	mov    %edx,%ecx
  800baa:	89 d3                	mov    %edx,%ebx
  800bac:	89 d7                	mov    %edx,%edi
  800bae:	89 d6                	mov    %edx,%esi
  800bb0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_yield>:

void
sys_yield(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdf:	be 00 00 00 00       	mov    $0x0,%esi
  800be4:	b8 04 00 00 00       	mov    $0x4,%eax
  800be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf2:	89 f7                	mov    %esi,%edi
  800bf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	7e 17                	jle    800c11 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 04                	push   $0x4
  800c00:	68 1f 23 80 00       	push   $0x80231f
  800c05:	6a 23                	push   $0x23
  800c07:	68 3c 23 80 00       	push   $0x80233c
  800c0c:	e8 64 f5 ff ff       	call   800175 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	b8 05 00 00 00       	mov    $0x5,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c33:	8b 75 18             	mov    0x18(%ebp),%esi
  800c36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 05                	push   $0x5
  800c42:	68 1f 23 80 00       	push   $0x80231f
  800c47:	6a 23                	push   $0x23
  800c49:	68 3c 23 80 00       	push   $0x80233c
  800c4e:	e8 22 f5 ff ff       	call   800175 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c69:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	89 df                	mov    %ebx,%edi
  800c76:	89 de                	mov    %ebx,%esi
  800c78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 17                	jle    800c95 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 06                	push   $0x6
  800c84:	68 1f 23 80 00       	push   $0x80231f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 3c 23 80 00       	push   $0x80233c
  800c90:	e8 e0 f4 ff ff       	call   800175 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cab:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 df                	mov    %ebx,%edi
  800cb8:	89 de                	mov    %ebx,%esi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 08                	push   $0x8
  800cc6:	68 1f 23 80 00       	push   $0x80231f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 3c 23 80 00       	push   $0x80233c
  800cd2:	e8 9e f4 ff ff       	call   800175 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ced:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	89 df                	mov    %ebx,%edi
  800cfa:	89 de                	mov    %ebx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 09                	push   $0x9
  800d08:	68 1f 23 80 00       	push   $0x80231f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 3c 23 80 00       	push   $0x80233c
  800d14:	e8 5c f4 ff ff       	call   800175 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 0a                	push   $0xa
  800d4a:	68 1f 23 80 00       	push   $0x80231f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 3c 23 80 00       	push   $0x80233c
  800d56:	e8 1a f4 ff ff       	call   800175 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	be 00 00 00 00       	mov    $0x0,%esi
  800d6e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d94:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 cb                	mov    %ecx,%ebx
  800d9e:	89 cf                	mov    %ecx,%edi
  800da0:	89 ce                	mov    %ecx,%esi
  800da2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da4:	85 c0                	test   %eax,%eax
  800da6:	7e 17                	jle    800dbf <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	50                   	push   %eax
  800dac:	6a 0d                	push   $0xd
  800dae:	68 1f 23 80 00       	push   $0x80231f
  800db3:	6a 23                	push   $0x23
  800db5:	68 3c 23 80 00       	push   $0x80233c
  800dba:	e8 b6 f3 ff ff       	call   800175 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ded:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800df4:	75 2a                	jne    800e20 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  800df6:	83 ec 04             	sub    $0x4,%esp
  800df9:	6a 07                	push   $0x7
  800dfb:	68 00 f0 bf ee       	push   $0xeebff000
  800e00:	6a 00                	push   $0x0
  800e02:	e8 cf fd ff ff       	call   800bd6 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  800e07:	83 c4 10             	add    $0x10,%esp
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	79 12                	jns    800e20 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  800e0e:	50                   	push   %eax
  800e0f:	68 4a 23 80 00       	push   $0x80234a
  800e14:	6a 23                	push   $0x23
  800e16:	68 4e 23 80 00       	push   $0x80234e
  800e1b:	e8 55 f3 ff ff       	call   800175 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	a3 08 40 80 00       	mov    %eax,0x804008
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	68 52 0e 80 00       	push   $0x800e52
  800e30:	6a 00                	push   $0x0
  800e32:	e8 ea fe ff ff       	call   800d21 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  800e37:	83 c4 10             	add    $0x10,%esp
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	79 12                	jns    800e50 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  800e3e:	50                   	push   %eax
  800e3f:	68 4a 23 80 00       	push   $0x80234a
  800e44:	6a 2c                	push   $0x2c
  800e46:	68 4e 23 80 00       	push   $0x80234e
  800e4b:	e8 25 f3 ff ff       	call   800175 <_panic>
	}
}
  800e50:	c9                   	leave  
  800e51:	c3                   	ret    

00800e52 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e52:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e53:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e58:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e5a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  800e5d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  800e61:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  800e66:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  800e6a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  800e6c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800e6f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800e70:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800e73:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800e74:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e75:	c3                   	ret    

00800e76 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e81:	c1 e8 0c             	shr    $0xc,%eax
}
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e96:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	c1 ea 16             	shr    $0x16,%edx
  800ead:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb4:	f6 c2 01             	test   $0x1,%dl
  800eb7:	74 11                	je     800eca <fd_alloc+0x2d>
  800eb9:	89 c2                	mov    %eax,%edx
  800ebb:	c1 ea 0c             	shr    $0xc,%edx
  800ebe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec5:	f6 c2 01             	test   $0x1,%dl
  800ec8:	75 09                	jne    800ed3 <fd_alloc+0x36>
			*fd_store = fd;
  800eca:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ecc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed1:	eb 17                	jmp    800eea <fd_alloc+0x4d>
  800ed3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ed8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800edd:	75 c9                	jne    800ea8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800edf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ee5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ef2:	83 f8 1f             	cmp    $0x1f,%eax
  800ef5:	77 36                	ja     800f2d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ef7:	c1 e0 0c             	shl    $0xc,%eax
  800efa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eff:	89 c2                	mov    %eax,%edx
  800f01:	c1 ea 16             	shr    $0x16,%edx
  800f04:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0b:	f6 c2 01             	test   $0x1,%dl
  800f0e:	74 24                	je     800f34 <fd_lookup+0x48>
  800f10:	89 c2                	mov    %eax,%edx
  800f12:	c1 ea 0c             	shr    $0xc,%edx
  800f15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1c:	f6 c2 01             	test   $0x1,%dl
  800f1f:	74 1a                	je     800f3b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f24:	89 02                	mov    %eax,(%edx)
	return 0;
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	eb 13                	jmp    800f40 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f32:	eb 0c                	jmp    800f40 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f34:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f39:	eb 05                	jmp    800f40 <fd_lookup+0x54>
  800f3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	83 ec 08             	sub    $0x8,%esp
  800f48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4b:	ba dc 23 80 00       	mov    $0x8023dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f50:	eb 13                	jmp    800f65 <dev_lookup+0x23>
  800f52:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f55:	39 08                	cmp    %ecx,(%eax)
  800f57:	75 0c                	jne    800f65 <dev_lookup+0x23>
			*dev = devtab[i];
  800f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f63:	eb 2e                	jmp    800f93 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f65:	8b 02                	mov    (%edx),%eax
  800f67:	85 c0                	test   %eax,%eax
  800f69:	75 e7                	jne    800f52 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f6b:	a1 04 40 80 00       	mov    0x804004,%eax
  800f70:	8b 40 50             	mov    0x50(%eax),%eax
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	51                   	push   %ecx
  800f77:	50                   	push   %eax
  800f78:	68 5c 23 80 00       	push   $0x80235c
  800f7d:	e8 cc f2 ff ff       	call   80024e <cprintf>
	*dev = 0;
  800f82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f85:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 10             	sub    $0x10,%esp
  800f9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800fa0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa6:	50                   	push   %eax
  800fa7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fad:	c1 e8 0c             	shr    $0xc,%eax
  800fb0:	50                   	push   %eax
  800fb1:	e8 36 ff ff ff       	call   800eec <fd_lookup>
  800fb6:	83 c4 08             	add    $0x8,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 05                	js     800fc2 <fd_close+0x2d>
	    || fd != fd2)
  800fbd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fc0:	74 0c                	je     800fce <fd_close+0x39>
		return (must_exist ? r : 0);
  800fc2:	84 db                	test   %bl,%bl
  800fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc9:	0f 44 c2             	cmove  %edx,%eax
  800fcc:	eb 41                	jmp    80100f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fce:	83 ec 08             	sub    $0x8,%esp
  800fd1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fd4:	50                   	push   %eax
  800fd5:	ff 36                	pushl  (%esi)
  800fd7:	e8 66 ff ff ff       	call   800f42 <dev_lookup>
  800fdc:	89 c3                	mov    %eax,%ebx
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	78 1a                	js     800fff <fd_close+0x6a>
		if (dev->dev_close)
  800fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800feb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	74 0b                	je     800fff <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	56                   	push   %esi
  800ff8:	ff d0                	call   *%eax
  800ffa:	89 c3                	mov    %eax,%ebx
  800ffc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	56                   	push   %esi
  801003:	6a 00                	push   $0x0
  801005:	e8 51 fc ff ff       	call   800c5b <sys_page_unmap>
	return r;
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	89 d8                	mov    %ebx,%eax
}
  80100f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801012:	5b                   	pop    %ebx
  801013:	5e                   	pop    %esi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80101c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101f:	50                   	push   %eax
  801020:	ff 75 08             	pushl  0x8(%ebp)
  801023:	e8 c4 fe ff ff       	call   800eec <fd_lookup>
  801028:	83 c4 08             	add    $0x8,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	78 10                	js     80103f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	6a 01                	push   $0x1
  801034:	ff 75 f4             	pushl  -0xc(%ebp)
  801037:	e8 59 ff ff ff       	call   800f95 <fd_close>
  80103c:	83 c4 10             	add    $0x10,%esp
}
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <close_all>:

void
close_all(void)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	53                   	push   %ebx
  801045:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801048:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	53                   	push   %ebx
  801051:	e8 c0 ff ff ff       	call   801016 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801056:	83 c3 01             	add    $0x1,%ebx
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	83 fb 20             	cmp    $0x20,%ebx
  80105f:	75 ec                	jne    80104d <close_all+0xc>
		close(i);
}
  801061:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801064:	c9                   	leave  
  801065:	c3                   	ret    

00801066 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
  80106c:	83 ec 2c             	sub    $0x2c,%esp
  80106f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801072:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	ff 75 08             	pushl  0x8(%ebp)
  801079:	e8 6e fe ff ff       	call   800eec <fd_lookup>
  80107e:	83 c4 08             	add    $0x8,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	0f 88 c1 00 00 00    	js     80114a <dup+0xe4>
		return r;
	close(newfdnum);
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	56                   	push   %esi
  80108d:	e8 84 ff ff ff       	call   801016 <close>

	newfd = INDEX2FD(newfdnum);
  801092:	89 f3                	mov    %esi,%ebx
  801094:	c1 e3 0c             	shl    $0xc,%ebx
  801097:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80109d:	83 c4 04             	add    $0x4,%esp
  8010a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a3:	e8 de fd ff ff       	call   800e86 <fd2data>
  8010a8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010aa:	89 1c 24             	mov    %ebx,(%esp)
  8010ad:	e8 d4 fd ff ff       	call   800e86 <fd2data>
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010b8:	89 f8                	mov    %edi,%eax
  8010ba:	c1 e8 16             	shr    $0x16,%eax
  8010bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c4:	a8 01                	test   $0x1,%al
  8010c6:	74 37                	je     8010ff <dup+0x99>
  8010c8:	89 f8                	mov    %edi,%eax
  8010ca:	c1 e8 0c             	shr    $0xc,%eax
  8010cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d4:	f6 c2 01             	test   $0x1,%dl
  8010d7:	74 26                	je     8010ff <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e8:	50                   	push   %eax
  8010e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ec:	6a 00                	push   $0x0
  8010ee:	57                   	push   %edi
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 23 fb ff ff       	call   800c19 <sys_page_map>
  8010f6:	89 c7                	mov    %eax,%edi
  8010f8:	83 c4 20             	add    $0x20,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 2e                	js     80112d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801102:	89 d0                	mov    %edx,%eax
  801104:	c1 e8 0c             	shr    $0xc,%eax
  801107:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	25 07 0e 00 00       	and    $0xe07,%eax
  801116:	50                   	push   %eax
  801117:	53                   	push   %ebx
  801118:	6a 00                	push   $0x0
  80111a:	52                   	push   %edx
  80111b:	6a 00                	push   $0x0
  80111d:	e8 f7 fa ff ff       	call   800c19 <sys_page_map>
  801122:	89 c7                	mov    %eax,%edi
  801124:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801127:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801129:	85 ff                	test   %edi,%edi
  80112b:	79 1d                	jns    80114a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	53                   	push   %ebx
  801131:	6a 00                	push   $0x0
  801133:	e8 23 fb ff ff       	call   800c5b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801138:	83 c4 08             	add    $0x8,%esp
  80113b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80113e:	6a 00                	push   $0x0
  801140:	e8 16 fb ff ff       	call   800c5b <sys_page_unmap>
	return r;
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	89 f8                	mov    %edi,%eax
}
  80114a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114d:	5b                   	pop    %ebx
  80114e:	5e                   	pop    %esi
  80114f:	5f                   	pop    %edi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	53                   	push   %ebx
  801156:	83 ec 14             	sub    $0x14,%esp
  801159:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80115c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	53                   	push   %ebx
  801161:	e8 86 fd ff ff       	call   800eec <fd_lookup>
  801166:	83 c4 08             	add    $0x8,%esp
  801169:	89 c2                	mov    %eax,%edx
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 6d                	js     8011dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116f:	83 ec 08             	sub    $0x8,%esp
  801172:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801175:	50                   	push   %eax
  801176:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801179:	ff 30                	pushl  (%eax)
  80117b:	e8 c2 fd ff ff       	call   800f42 <dev_lookup>
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	78 4c                	js     8011d3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801187:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80118a:	8b 42 08             	mov    0x8(%edx),%eax
  80118d:	83 e0 03             	and    $0x3,%eax
  801190:	83 f8 01             	cmp    $0x1,%eax
  801193:	75 21                	jne    8011b6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801195:	a1 04 40 80 00       	mov    0x804004,%eax
  80119a:	8b 40 50             	mov    0x50(%eax),%eax
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	53                   	push   %ebx
  8011a1:	50                   	push   %eax
  8011a2:	68 a0 23 80 00       	push   $0x8023a0
  8011a7:	e8 a2 f0 ff ff       	call   80024e <cprintf>
		return -E_INVAL;
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011b4:	eb 26                	jmp    8011dc <read+0x8a>
	}
	if (!dev->dev_read)
  8011b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b9:	8b 40 08             	mov    0x8(%eax),%eax
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	74 17                	je     8011d7 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	ff 75 10             	pushl  0x10(%ebp)
  8011c6:	ff 75 0c             	pushl  0xc(%ebp)
  8011c9:	52                   	push   %edx
  8011ca:	ff d0                	call   *%eax
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	eb 09                	jmp    8011dc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d3:	89 c2                	mov    %eax,%edx
  8011d5:	eb 05                	jmp    8011dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8011dc:	89 d0                	mov    %edx,%eax
  8011de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	57                   	push   %edi
  8011e7:	56                   	push   %esi
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f7:	eb 21                	jmp    80121a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	29 d8                	sub    %ebx,%eax
  801200:	50                   	push   %eax
  801201:	89 d8                	mov    %ebx,%eax
  801203:	03 45 0c             	add    0xc(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	57                   	push   %edi
  801208:	e8 45 ff ff ff       	call   801152 <read>
		if (m < 0)
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 10                	js     801224 <readn+0x41>
			return m;
		if (m == 0)
  801214:	85 c0                	test   %eax,%eax
  801216:	74 0a                	je     801222 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801218:	01 c3                	add    %eax,%ebx
  80121a:	39 f3                	cmp    %esi,%ebx
  80121c:	72 db                	jb     8011f9 <readn+0x16>
  80121e:	89 d8                	mov    %ebx,%eax
  801220:	eb 02                	jmp    801224 <readn+0x41>
  801222:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801224:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	53                   	push   %ebx
  801230:	83 ec 14             	sub    $0x14,%esp
  801233:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801236:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	53                   	push   %ebx
  80123b:	e8 ac fc ff ff       	call   800eec <fd_lookup>
  801240:	83 c4 08             	add    $0x8,%esp
  801243:	89 c2                	mov    %eax,%edx
  801245:	85 c0                	test   %eax,%eax
  801247:	78 68                	js     8012b1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801253:	ff 30                	pushl  (%eax)
  801255:	e8 e8 fc ff ff       	call   800f42 <dev_lookup>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 47                	js     8012a8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801264:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801268:	75 21                	jne    80128b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80126a:	a1 04 40 80 00       	mov    0x804004,%eax
  80126f:	8b 40 50             	mov    0x50(%eax),%eax
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	53                   	push   %ebx
  801276:	50                   	push   %eax
  801277:	68 bc 23 80 00       	push   $0x8023bc
  80127c:	e8 cd ef ff ff       	call   80024e <cprintf>
		return -E_INVAL;
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801289:	eb 26                	jmp    8012b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80128b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128e:	8b 52 0c             	mov    0xc(%edx),%edx
  801291:	85 d2                	test   %edx,%edx
  801293:	74 17                	je     8012ac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	ff 75 10             	pushl  0x10(%ebp)
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	50                   	push   %eax
  80129f:	ff d2                	call   *%edx
  8012a1:	89 c2                	mov    %eax,%edx
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	eb 09                	jmp    8012b1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a8:	89 c2                	mov    %eax,%edx
  8012aa:	eb 05                	jmp    8012b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012b1:	89 d0                	mov    %edx,%eax
  8012b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	ff 75 08             	pushl  0x8(%ebp)
  8012c5:	e8 22 fc ff ff       	call   800eec <fd_lookup>
  8012ca:	83 c4 08             	add    $0x8,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 0e                	js     8012df <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 14             	sub    $0x14,%esp
  8012e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	53                   	push   %ebx
  8012f0:	e8 f7 fb ff ff       	call   800eec <fd_lookup>
  8012f5:	83 c4 08             	add    $0x8,%esp
  8012f8:	89 c2                	mov    %eax,%edx
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 65                	js     801363 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	ff 30                	pushl  (%eax)
  80130a:	e8 33 fc ff ff       	call   800f42 <dev_lookup>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	78 44                	js     80135a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801316:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801319:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80131d:	75 21                	jne    801340 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80131f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801324:	8b 40 50             	mov    0x50(%eax),%eax
  801327:	83 ec 04             	sub    $0x4,%esp
  80132a:	53                   	push   %ebx
  80132b:	50                   	push   %eax
  80132c:	68 7c 23 80 00       	push   $0x80237c
  801331:	e8 18 ef ff ff       	call   80024e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80133e:	eb 23                	jmp    801363 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801340:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801343:	8b 52 18             	mov    0x18(%edx),%edx
  801346:	85 d2                	test   %edx,%edx
  801348:	74 14                	je     80135e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	ff 75 0c             	pushl  0xc(%ebp)
  801350:	50                   	push   %eax
  801351:	ff d2                	call   *%edx
  801353:	89 c2                	mov    %eax,%edx
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	eb 09                	jmp    801363 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135a:	89 c2                	mov    %eax,%edx
  80135c:	eb 05                	jmp    801363 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80135e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801363:	89 d0                	mov    %edx,%eax
  801365:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	53                   	push   %ebx
  80136e:	83 ec 14             	sub    $0x14,%esp
  801371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801374:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801377:	50                   	push   %eax
  801378:	ff 75 08             	pushl  0x8(%ebp)
  80137b:	e8 6c fb ff ff       	call   800eec <fd_lookup>
  801380:	83 c4 08             	add    $0x8,%esp
  801383:	89 c2                	mov    %eax,%edx
  801385:	85 c0                	test   %eax,%eax
  801387:	78 58                	js     8013e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	ff 30                	pushl  (%eax)
  801395:	e8 a8 fb ff ff       	call   800f42 <dev_lookup>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 37                	js     8013d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013a8:	74 32                	je     8013dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013b4:	00 00 00 
	stat->st_isdir = 0;
  8013b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013be:	00 00 00 
	stat->st_dev = dev;
  8013c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	53                   	push   %ebx
  8013cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ce:	ff 50 14             	call   *0x14(%eax)
  8013d1:	89 c2                	mov    %eax,%edx
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	eb 09                	jmp    8013e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d8:	89 c2                	mov    %eax,%edx
  8013da:	eb 05                	jmp    8013e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013e1:	89 d0                	mov    %edx,%eax
  8013e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	6a 00                	push   $0x0
  8013f2:	ff 75 08             	pushl  0x8(%ebp)
  8013f5:	e8 e3 01 00 00       	call   8015dd <open>
  8013fa:	89 c3                	mov    %eax,%ebx
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 1b                	js     80141e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	ff 75 0c             	pushl  0xc(%ebp)
  801409:	50                   	push   %eax
  80140a:	e8 5b ff ff ff       	call   80136a <fstat>
  80140f:	89 c6                	mov    %eax,%esi
	close(fd);
  801411:	89 1c 24             	mov    %ebx,(%esp)
  801414:	e8 fd fb ff ff       	call   801016 <close>
	return r;
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	89 f0                	mov    %esi,%eax
}
  80141e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	56                   	push   %esi
  801429:	53                   	push   %ebx
  80142a:	89 c6                	mov    %eax,%esi
  80142c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80142e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801435:	75 12                	jne    801449 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	6a 01                	push   $0x1
  80143c:	e8 f6 07 00 00       	call   801c37 <ipc_find_env>
  801441:	a3 00 40 80 00       	mov    %eax,0x804000
  801446:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801449:	6a 07                	push   $0x7
  80144b:	68 00 50 80 00       	push   $0x805000
  801450:	56                   	push   %esi
  801451:	ff 35 00 40 80 00    	pushl  0x804000
  801457:	e8 79 07 00 00       	call   801bd5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80145c:	83 c4 0c             	add    $0xc,%esp
  80145f:	6a 00                	push   $0x0
  801461:	53                   	push   %ebx
  801462:	6a 00                	push   $0x0
  801464:	e8 f7 06 00 00       	call   801b60 <ipc_recv>
}
  801469:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146c:	5b                   	pop    %ebx
  80146d:	5e                   	pop    %esi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	8b 40 0c             	mov    0xc(%eax),%eax
  80147c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801481:	8b 45 0c             	mov    0xc(%ebp),%eax
  801484:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801489:	ba 00 00 00 00       	mov    $0x0,%edx
  80148e:	b8 02 00 00 00       	mov    $0x2,%eax
  801493:	e8 8d ff ff ff       	call   801425 <fsipc>
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b5:	e8 6b ff ff ff       	call   801425 <fsipc>
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8014db:	e8 45 ff ff ff       	call   801425 <fsipc>
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 2c                	js     801510 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	68 00 50 80 00       	push   $0x805000
  8014ec:	53                   	push   %ebx
  8014ed:	e8 e1 f2 ff ff       	call   8007d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801502:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151e:	8b 55 08             	mov    0x8(%ebp),%edx
  801521:	8b 52 0c             	mov    0xc(%edx),%edx
  801524:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80152a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80152f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801534:	0f 47 c2             	cmova  %edx,%eax
  801537:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80153c:	50                   	push   %eax
  80153d:	ff 75 0c             	pushl  0xc(%ebp)
  801540:	68 08 50 80 00       	push   $0x805008
  801545:	e8 1b f4 ff ff       	call   800965 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80154a:	ba 00 00 00 00       	mov    $0x0,%edx
  80154f:	b8 04 00 00 00       	mov    $0x4,%eax
  801554:	e8 cc fe ff ff       	call   801425 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	56                   	push   %esi
  80155f:	53                   	push   %ebx
  801560:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801563:	8b 45 08             	mov    0x8(%ebp),%eax
  801566:	8b 40 0c             	mov    0xc(%eax),%eax
  801569:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80156e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801574:	ba 00 00 00 00       	mov    $0x0,%edx
  801579:	b8 03 00 00 00       	mov    $0x3,%eax
  80157e:	e8 a2 fe ff ff       	call   801425 <fsipc>
  801583:	89 c3                	mov    %eax,%ebx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 4b                	js     8015d4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801589:	39 c6                	cmp    %eax,%esi
  80158b:	73 16                	jae    8015a3 <devfile_read+0x48>
  80158d:	68 ec 23 80 00       	push   $0x8023ec
  801592:	68 f3 23 80 00       	push   $0x8023f3
  801597:	6a 7c                	push   $0x7c
  801599:	68 08 24 80 00       	push   $0x802408
  80159e:	e8 d2 eb ff ff       	call   800175 <_panic>
	assert(r <= PGSIZE);
  8015a3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015a8:	7e 16                	jle    8015c0 <devfile_read+0x65>
  8015aa:	68 13 24 80 00       	push   $0x802413
  8015af:	68 f3 23 80 00       	push   $0x8023f3
  8015b4:	6a 7d                	push   $0x7d
  8015b6:	68 08 24 80 00       	push   $0x802408
  8015bb:	e8 b5 eb ff ff       	call   800175 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c0:	83 ec 04             	sub    $0x4,%esp
  8015c3:	50                   	push   %eax
  8015c4:	68 00 50 80 00       	push   $0x805000
  8015c9:	ff 75 0c             	pushl  0xc(%ebp)
  8015cc:	e8 94 f3 ff ff       	call   800965 <memmove>
	return r;
  8015d1:	83 c4 10             	add    $0x10,%esp
}
  8015d4:	89 d8                	mov    %ebx,%eax
  8015d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5e                   	pop    %esi
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    

008015dd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 20             	sub    $0x20,%esp
  8015e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015e7:	53                   	push   %ebx
  8015e8:	e8 ad f1 ff ff       	call   80079a <strlen>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015f5:	7f 67                	jg     80165e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	e8 9a f8 ff ff       	call   800e9d <fd_alloc>
  801603:	83 c4 10             	add    $0x10,%esp
		return r;
  801606:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 57                	js     801663 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	53                   	push   %ebx
  801610:	68 00 50 80 00       	push   $0x805000
  801615:	e8 b9 f1 ff ff       	call   8007d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80161a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801622:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801625:	b8 01 00 00 00       	mov    $0x1,%eax
  80162a:	e8 f6 fd ff ff       	call   801425 <fsipc>
  80162f:	89 c3                	mov    %eax,%ebx
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	79 14                	jns    80164c <open+0x6f>
		fd_close(fd, 0);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	6a 00                	push   $0x0
  80163d:	ff 75 f4             	pushl  -0xc(%ebp)
  801640:	e8 50 f9 ff ff       	call   800f95 <fd_close>
		return r;
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	89 da                	mov    %ebx,%edx
  80164a:	eb 17                	jmp    801663 <open+0x86>
	}

	return fd2num(fd);
  80164c:	83 ec 0c             	sub    $0xc,%esp
  80164f:	ff 75 f4             	pushl  -0xc(%ebp)
  801652:	e8 1f f8 ff ff       	call   800e76 <fd2num>
  801657:	89 c2                	mov    %eax,%edx
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 05                	jmp    801663 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80165e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801663:	89 d0                	mov    %edx,%eax
  801665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801670:	ba 00 00 00 00       	mov    $0x0,%edx
  801675:	b8 08 00 00 00       	mov    $0x8,%eax
  80167a:	e8 a6 fd ff ff       	call   801425 <fsipc>
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801689:	83 ec 0c             	sub    $0xc,%esp
  80168c:	ff 75 08             	pushl  0x8(%ebp)
  80168f:	e8 f2 f7 ff ff       	call   800e86 <fd2data>
  801694:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801696:	83 c4 08             	add    $0x8,%esp
  801699:	68 1f 24 80 00       	push   $0x80241f
  80169e:	53                   	push   %ebx
  80169f:	e8 2f f1 ff ff       	call   8007d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016a4:	8b 46 04             	mov    0x4(%esi),%eax
  8016a7:	2b 06                	sub    (%esi),%eax
  8016a9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b6:	00 00 00 
	stat->st_dev = &devpipe;
  8016b9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016c0:	30 80 00 
	return 0;
}
  8016c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    

008016cf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016d9:	53                   	push   %ebx
  8016da:	6a 00                	push   $0x0
  8016dc:	e8 7a f5 ff ff       	call   800c5b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016e1:	89 1c 24             	mov    %ebx,(%esp)
  8016e4:	e8 9d f7 ff ff       	call   800e86 <fd2data>
  8016e9:	83 c4 08             	add    $0x8,%esp
  8016ec:	50                   	push   %eax
  8016ed:	6a 00                	push   $0x0
  8016ef:	e8 67 f5 ff ff       	call   800c5b <sys_page_unmap>
}
  8016f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f7:	c9                   	leave  
  8016f8:	c3                   	ret    

008016f9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	57                   	push   %edi
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
  8016ff:	83 ec 1c             	sub    $0x1c,%esp
  801702:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801705:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801707:	a1 04 40 80 00       	mov    0x804004,%eax
  80170c:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80170f:	83 ec 0c             	sub    $0xc,%esp
  801712:	ff 75 e0             	pushl  -0x20(%ebp)
  801715:	e8 5d 05 00 00       	call   801c77 <pageref>
  80171a:	89 c3                	mov    %eax,%ebx
  80171c:	89 3c 24             	mov    %edi,(%esp)
  80171f:	e8 53 05 00 00       	call   801c77 <pageref>
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	39 c3                	cmp    %eax,%ebx
  801729:	0f 94 c1             	sete   %cl
  80172c:	0f b6 c9             	movzbl %cl,%ecx
  80172f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801732:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801738:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  80173b:	39 ce                	cmp    %ecx,%esi
  80173d:	74 1b                	je     80175a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80173f:	39 c3                	cmp    %eax,%ebx
  801741:	75 c4                	jne    801707 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801743:	8b 42 60             	mov    0x60(%edx),%eax
  801746:	ff 75 e4             	pushl  -0x1c(%ebp)
  801749:	50                   	push   %eax
  80174a:	56                   	push   %esi
  80174b:	68 26 24 80 00       	push   $0x802426
  801750:	e8 f9 ea ff ff       	call   80024e <cprintf>
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	eb ad                	jmp    801707 <_pipeisclosed+0xe>
	}
}
  80175a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80175d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801760:	5b                   	pop    %ebx
  801761:	5e                   	pop    %esi
  801762:	5f                   	pop    %edi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	57                   	push   %edi
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	83 ec 28             	sub    $0x28,%esp
  80176e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801771:	56                   	push   %esi
  801772:	e8 0f f7 ff ff       	call   800e86 <fd2data>
  801777:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	bf 00 00 00 00       	mov    $0x0,%edi
  801781:	eb 4b                	jmp    8017ce <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801783:	89 da                	mov    %ebx,%edx
  801785:	89 f0                	mov    %esi,%eax
  801787:	e8 6d ff ff ff       	call   8016f9 <_pipeisclosed>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	75 48                	jne    8017d8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801790:	e8 22 f4 ff ff       	call   800bb7 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801795:	8b 43 04             	mov    0x4(%ebx),%eax
  801798:	8b 0b                	mov    (%ebx),%ecx
  80179a:	8d 51 20             	lea    0x20(%ecx),%edx
  80179d:	39 d0                	cmp    %edx,%eax
  80179f:	73 e2                	jae    801783 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017a8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017ab:	89 c2                	mov    %eax,%edx
  8017ad:	c1 fa 1f             	sar    $0x1f,%edx
  8017b0:	89 d1                	mov    %edx,%ecx
  8017b2:	c1 e9 1b             	shr    $0x1b,%ecx
  8017b5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017b8:	83 e2 1f             	and    $0x1f,%edx
  8017bb:	29 ca                	sub    %ecx,%edx
  8017bd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017c1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017c5:	83 c0 01             	add    $0x1,%eax
  8017c8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017cb:	83 c7 01             	add    $0x1,%edi
  8017ce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017d1:	75 c2                	jne    801795 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d6:	eb 05                	jmp    8017dd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5f                   	pop    %edi
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	57                   	push   %edi
  8017e9:	56                   	push   %esi
  8017ea:	53                   	push   %ebx
  8017eb:	83 ec 18             	sub    $0x18,%esp
  8017ee:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017f1:	57                   	push   %edi
  8017f2:	e8 8f f6 ff ff       	call   800e86 <fd2data>
  8017f7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801801:	eb 3d                	jmp    801840 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801803:	85 db                	test   %ebx,%ebx
  801805:	74 04                	je     80180b <devpipe_read+0x26>
				return i;
  801807:	89 d8                	mov    %ebx,%eax
  801809:	eb 44                	jmp    80184f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80180b:	89 f2                	mov    %esi,%edx
  80180d:	89 f8                	mov    %edi,%eax
  80180f:	e8 e5 fe ff ff       	call   8016f9 <_pipeisclosed>
  801814:	85 c0                	test   %eax,%eax
  801816:	75 32                	jne    80184a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801818:	e8 9a f3 ff ff       	call   800bb7 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80181d:	8b 06                	mov    (%esi),%eax
  80181f:	3b 46 04             	cmp    0x4(%esi),%eax
  801822:	74 df                	je     801803 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801824:	99                   	cltd   
  801825:	c1 ea 1b             	shr    $0x1b,%edx
  801828:	01 d0                	add    %edx,%eax
  80182a:	83 e0 1f             	and    $0x1f,%eax
  80182d:	29 d0                	sub    %edx,%eax
  80182f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801834:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801837:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80183a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80183d:	83 c3 01             	add    $0x1,%ebx
  801840:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801843:	75 d8                	jne    80181d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801845:	8b 45 10             	mov    0x10(%ebp),%eax
  801848:	eb 05                	jmp    80184f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80184a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80184f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5f                   	pop    %edi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80185f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801862:	50                   	push   %eax
  801863:	e8 35 f6 ff ff       	call   800e9d <fd_alloc>
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	89 c2                	mov    %eax,%edx
  80186d:	85 c0                	test   %eax,%eax
  80186f:	0f 88 2c 01 00 00    	js     8019a1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	68 07 04 00 00       	push   $0x407
  80187d:	ff 75 f4             	pushl  -0xc(%ebp)
  801880:	6a 00                	push   $0x0
  801882:	e8 4f f3 ff ff       	call   800bd6 <sys_page_alloc>
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	89 c2                	mov    %eax,%edx
  80188c:	85 c0                	test   %eax,%eax
  80188e:	0f 88 0d 01 00 00    	js     8019a1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189a:	50                   	push   %eax
  80189b:	e8 fd f5 ff ff       	call   800e9d <fd_alloc>
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	0f 88 e2 00 00 00    	js     80198f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ad:	83 ec 04             	sub    $0x4,%esp
  8018b0:	68 07 04 00 00       	push   $0x407
  8018b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b8:	6a 00                	push   $0x0
  8018ba:	e8 17 f3 ff ff       	call   800bd6 <sys_page_alloc>
  8018bf:	89 c3                	mov    %eax,%ebx
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	0f 88 c3 00 00 00    	js     80198f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018cc:	83 ec 0c             	sub    $0xc,%esp
  8018cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d2:	e8 af f5 ff ff       	call   800e86 <fd2data>
  8018d7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d9:	83 c4 0c             	add    $0xc,%esp
  8018dc:	68 07 04 00 00       	push   $0x407
  8018e1:	50                   	push   %eax
  8018e2:	6a 00                	push   $0x0
  8018e4:	e8 ed f2 ff ff       	call   800bd6 <sys_page_alloc>
  8018e9:	89 c3                	mov    %eax,%ebx
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	0f 88 89 00 00 00    	js     80197f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f6:	83 ec 0c             	sub    $0xc,%esp
  8018f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018fc:	e8 85 f5 ff ff       	call   800e86 <fd2data>
  801901:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801908:	50                   	push   %eax
  801909:	6a 00                	push   $0x0
  80190b:	56                   	push   %esi
  80190c:	6a 00                	push   $0x0
  80190e:	e8 06 f3 ff ff       	call   800c19 <sys_page_map>
  801913:	89 c3                	mov    %eax,%ebx
  801915:	83 c4 20             	add    $0x20,%esp
  801918:	85 c0                	test   %eax,%eax
  80191a:	78 55                	js     801971 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80191c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801922:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801925:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801927:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801931:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801937:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80193c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	ff 75 f4             	pushl  -0xc(%ebp)
  80194c:	e8 25 f5 ff ff       	call   800e76 <fd2num>
  801951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801954:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801956:	83 c4 04             	add    $0x4,%esp
  801959:	ff 75 f0             	pushl  -0x10(%ebp)
  80195c:	e8 15 f5 ff ff       	call   800e76 <fd2num>
  801961:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801964:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	ba 00 00 00 00       	mov    $0x0,%edx
  80196f:	eb 30                	jmp    8019a1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	56                   	push   %esi
  801975:	6a 00                	push   $0x0
  801977:	e8 df f2 ff ff       	call   800c5b <sys_page_unmap>
  80197c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	ff 75 f0             	pushl  -0x10(%ebp)
  801985:	6a 00                	push   $0x0
  801987:	e8 cf f2 ff ff       	call   800c5b <sys_page_unmap>
  80198c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	ff 75 f4             	pushl  -0xc(%ebp)
  801995:	6a 00                	push   $0x0
  801997:	e8 bf f2 ff ff       	call   800c5b <sys_page_unmap>
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019a1:	89 d0                	mov    %edx,%eax
  8019a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a6:	5b                   	pop    %ebx
  8019a7:	5e                   	pop    %esi
  8019a8:	5d                   	pop    %ebp
  8019a9:	c3                   	ret    

008019aa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	50                   	push   %eax
  8019b4:	ff 75 08             	pushl  0x8(%ebp)
  8019b7:	e8 30 f5 ff ff       	call   800eec <fd_lookup>
  8019bc:	83 c4 10             	add    $0x10,%esp
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 18                	js     8019db <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c9:	e8 b8 f4 ff ff       	call   800e86 <fd2data>
	return _pipeisclosed(fd, p);
  8019ce:	89 c2                	mov    %eax,%edx
  8019d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d3:	e8 21 fd ff ff       	call   8016f9 <_pipeisclosed>
  8019d8:	83 c4 10             	add    $0x10,%esp
}
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e5:	5d                   	pop    %ebp
  8019e6:	c3                   	ret    

008019e7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019ed:	68 3e 24 80 00       	push   $0x80243e
  8019f2:	ff 75 0c             	pushl  0xc(%ebp)
  8019f5:	e8 d9 ed ff ff       	call   8007d3 <strcpy>
	return 0;
}
  8019fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	57                   	push   %edi
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
  801a07:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a0d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a12:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a18:	eb 2d                	jmp    801a47 <devcons_write+0x46>
		m = n - tot;
  801a1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a1d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a1f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a22:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a27:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	53                   	push   %ebx
  801a2e:	03 45 0c             	add    0xc(%ebp),%eax
  801a31:	50                   	push   %eax
  801a32:	57                   	push   %edi
  801a33:	e8 2d ef ff ff       	call   800965 <memmove>
		sys_cputs(buf, m);
  801a38:	83 c4 08             	add    $0x8,%esp
  801a3b:	53                   	push   %ebx
  801a3c:	57                   	push   %edi
  801a3d:	e8 d8 f0 ff ff       	call   800b1a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a42:	01 de                	add    %ebx,%esi
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	89 f0                	mov    %esi,%eax
  801a49:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a4c:	72 cc                	jb     801a1a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a51:	5b                   	pop    %ebx
  801a52:	5e                   	pop    %esi
  801a53:	5f                   	pop    %edi
  801a54:	5d                   	pop    %ebp
  801a55:	c3                   	ret    

00801a56 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 08             	sub    $0x8,%esp
  801a5c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a61:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a65:	74 2a                	je     801a91 <devcons_read+0x3b>
  801a67:	eb 05                	jmp    801a6e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a69:	e8 49 f1 ff ff       	call   800bb7 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a6e:	e8 c5 f0 ff ff       	call   800b38 <sys_cgetc>
  801a73:	85 c0                	test   %eax,%eax
  801a75:	74 f2                	je     801a69 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a77:	85 c0                	test   %eax,%eax
  801a79:	78 16                	js     801a91 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a7b:	83 f8 04             	cmp    $0x4,%eax
  801a7e:	74 0c                	je     801a8c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a83:	88 02                	mov    %al,(%edx)
	return 1;
  801a85:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8a:	eb 05                	jmp    801a91 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a8c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a99:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a9f:	6a 01                	push   $0x1
  801aa1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa4:	50                   	push   %eax
  801aa5:	e8 70 f0 ff ff       	call   800b1a <sys_cputs>
}
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <getchar>:

int
getchar(void)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ab5:	6a 01                	push   $0x1
  801ab7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aba:	50                   	push   %eax
  801abb:	6a 00                	push   $0x0
  801abd:	e8 90 f6 ff ff       	call   801152 <read>
	if (r < 0)
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 0f                	js     801ad8 <getchar+0x29>
		return r;
	if (r < 1)
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	7e 06                	jle    801ad3 <getchar+0x24>
		return -E_EOF;
	return c;
  801acd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ad1:	eb 05                	jmp    801ad8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ad3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae3:	50                   	push   %eax
  801ae4:	ff 75 08             	pushl  0x8(%ebp)
  801ae7:	e8 00 f4 ff ff       	call   800eec <fd_lookup>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	78 11                	js     801b04 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801afc:	39 10                	cmp    %edx,(%eax)
  801afe:	0f 94 c0             	sete   %al
  801b01:	0f b6 c0             	movzbl %al,%eax
}
  801b04:	c9                   	leave  
  801b05:	c3                   	ret    

00801b06 <opencons>:

int
opencons(void)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0f:	50                   	push   %eax
  801b10:	e8 88 f3 ff ff       	call   800e9d <fd_alloc>
  801b15:	83 c4 10             	add    $0x10,%esp
		return r;
  801b18:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 3e                	js     801b5c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b1e:	83 ec 04             	sub    $0x4,%esp
  801b21:	68 07 04 00 00       	push   $0x407
  801b26:	ff 75 f4             	pushl  -0xc(%ebp)
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 a6 f0 ff ff       	call   800bd6 <sys_page_alloc>
  801b30:	83 c4 10             	add    $0x10,%esp
		return r;
  801b33:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 23                	js     801b5c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b39:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b42:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b47:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b4e:	83 ec 0c             	sub    $0xc,%esp
  801b51:	50                   	push   %eax
  801b52:	e8 1f f3 ff ff       	call   800e76 <fd2num>
  801b57:	89 c2                	mov    %eax,%edx
  801b59:	83 c4 10             	add    $0x10,%esp
}
  801b5c:	89 d0                	mov    %edx,%eax
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	8b 75 08             	mov    0x8(%ebp),%esi
  801b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	75 12                	jne    801b84 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	68 00 00 c0 ee       	push   $0xeec00000
  801b7a:	e8 07 f2 ff ff       	call   800d86 <sys_ipc_recv>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	eb 0c                	jmp    801b90 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801b84:	83 ec 0c             	sub    $0xc,%esp
  801b87:	50                   	push   %eax
  801b88:	e8 f9 f1 ff ff       	call   800d86 <sys_ipc_recv>
  801b8d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801b90:	85 f6                	test   %esi,%esi
  801b92:	0f 95 c1             	setne  %cl
  801b95:	85 db                	test   %ebx,%ebx
  801b97:	0f 95 c2             	setne  %dl
  801b9a:	84 d1                	test   %dl,%cl
  801b9c:	74 09                	je     801ba7 <ipc_recv+0x47>
  801b9e:	89 c2                	mov    %eax,%edx
  801ba0:	c1 ea 1f             	shr    $0x1f,%edx
  801ba3:	84 d2                	test   %dl,%dl
  801ba5:	75 27                	jne    801bce <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	74 0a                	je     801bb5 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801bab:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb0:	8b 40 7c             	mov    0x7c(%eax),%eax
  801bb3:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801bb5:	85 db                	test   %ebx,%ebx
  801bb7:	74 0d                	je     801bc6 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801bb9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bbe:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801bc4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801bc6:	a1 04 40 80 00       	mov    0x804004,%eax
  801bcb:	8b 40 78             	mov    0x78(%eax),%eax
}
  801bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	57                   	push   %edi
  801bd9:	56                   	push   %esi
  801bda:	53                   	push   %ebx
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	8b 7d 08             	mov    0x8(%ebp),%edi
  801be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801be7:	85 db                	test   %ebx,%ebx
  801be9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bee:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bf1:	ff 75 14             	pushl  0x14(%ebp)
  801bf4:	53                   	push   %ebx
  801bf5:	56                   	push   %esi
  801bf6:	57                   	push   %edi
  801bf7:	e8 67 f1 ff ff       	call   800d63 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801bfc:	89 c2                	mov    %eax,%edx
  801bfe:	c1 ea 1f             	shr    $0x1f,%edx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	84 d2                	test   %dl,%dl
  801c06:	74 17                	je     801c1f <ipc_send+0x4a>
  801c08:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c0b:	74 12                	je     801c1f <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801c0d:	50                   	push   %eax
  801c0e:	68 4a 24 80 00       	push   $0x80244a
  801c13:	6a 47                	push   $0x47
  801c15:	68 58 24 80 00       	push   $0x802458
  801c1a:	e8 56 e5 ff ff       	call   800175 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801c1f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c22:	75 07                	jne    801c2b <ipc_send+0x56>
			sys_yield();
  801c24:	e8 8e ef ff ff       	call   800bb7 <sys_yield>
  801c29:	eb c6                	jmp    801bf1 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	75 c2                	jne    801bf1 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5f                   	pop    %edi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c42:	89 c2                	mov    %eax,%edx
  801c44:	c1 e2 07             	shl    $0x7,%edx
  801c47:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801c4e:	8b 52 58             	mov    0x58(%edx),%edx
  801c51:	39 ca                	cmp    %ecx,%edx
  801c53:	75 11                	jne    801c66 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801c55:	89 c2                	mov    %eax,%edx
  801c57:	c1 e2 07             	shl    $0x7,%edx
  801c5a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801c61:	8b 40 50             	mov    0x50(%eax),%eax
  801c64:	eb 0f                	jmp    801c75 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c66:	83 c0 01             	add    $0x1,%eax
  801c69:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c6e:	75 d2                	jne    801c42 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c7d:	89 d0                	mov    %edx,%eax
  801c7f:	c1 e8 16             	shr    $0x16,%eax
  801c82:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c8e:	f6 c1 01             	test   $0x1,%cl
  801c91:	74 1d                	je     801cb0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c93:	c1 ea 0c             	shr    $0xc,%edx
  801c96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c9d:	f6 c2 01             	test   $0x1,%dl
  801ca0:	74 0e                	je     801cb0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ca2:	c1 ea 0c             	shr    $0xc,%edx
  801ca5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cac:	ef 
  801cad:	0f b7 c0             	movzwl %ax,%eax
}
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__udivdi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ccb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801ccf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 f6                	test   %esi,%esi
  801cd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cdd:	89 ca                	mov    %ecx,%edx
  801cdf:	89 f8                	mov    %edi,%eax
  801ce1:	75 3d                	jne    801d20 <__udivdi3+0x60>
  801ce3:	39 cf                	cmp    %ecx,%edi
  801ce5:	0f 87 c5 00 00 00    	ja     801db0 <__udivdi3+0xf0>
  801ceb:	85 ff                	test   %edi,%edi
  801ced:	89 fd                	mov    %edi,%ebp
  801cef:	75 0b                	jne    801cfc <__udivdi3+0x3c>
  801cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf6:	31 d2                	xor    %edx,%edx
  801cf8:	f7 f7                	div    %edi
  801cfa:	89 c5                	mov    %eax,%ebp
  801cfc:	89 c8                	mov    %ecx,%eax
  801cfe:	31 d2                	xor    %edx,%edx
  801d00:	f7 f5                	div    %ebp
  801d02:	89 c1                	mov    %eax,%ecx
  801d04:	89 d8                	mov    %ebx,%eax
  801d06:	89 cf                	mov    %ecx,%edi
  801d08:	f7 f5                	div    %ebp
  801d0a:	89 c3                	mov    %eax,%ebx
  801d0c:	89 d8                	mov    %ebx,%eax
  801d0e:	89 fa                	mov    %edi,%edx
  801d10:	83 c4 1c             	add    $0x1c,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    
  801d18:	90                   	nop
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	39 ce                	cmp    %ecx,%esi
  801d22:	77 74                	ja     801d98 <__udivdi3+0xd8>
  801d24:	0f bd fe             	bsr    %esi,%edi
  801d27:	83 f7 1f             	xor    $0x1f,%edi
  801d2a:	0f 84 98 00 00 00    	je     801dc8 <__udivdi3+0x108>
  801d30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	89 c5                	mov    %eax,%ebp
  801d39:	29 fb                	sub    %edi,%ebx
  801d3b:	d3 e6                	shl    %cl,%esi
  801d3d:	89 d9                	mov    %ebx,%ecx
  801d3f:	d3 ed                	shr    %cl,%ebp
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	d3 e0                	shl    %cl,%eax
  801d45:	09 ee                	or     %ebp,%esi
  801d47:	89 d9                	mov    %ebx,%ecx
  801d49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d4d:	89 d5                	mov    %edx,%ebp
  801d4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d53:	d3 ed                	shr    %cl,%ebp
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 e2                	shl    %cl,%edx
  801d59:	89 d9                	mov    %ebx,%ecx
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	09 c2                	or     %eax,%edx
  801d5f:	89 d0                	mov    %edx,%eax
  801d61:	89 ea                	mov    %ebp,%edx
  801d63:	f7 f6                	div    %esi
  801d65:	89 d5                	mov    %edx,%ebp
  801d67:	89 c3                	mov    %eax,%ebx
  801d69:	f7 64 24 0c          	mull   0xc(%esp)
  801d6d:	39 d5                	cmp    %edx,%ebp
  801d6f:	72 10                	jb     801d81 <__udivdi3+0xc1>
  801d71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d75:	89 f9                	mov    %edi,%ecx
  801d77:	d3 e6                	shl    %cl,%esi
  801d79:	39 c6                	cmp    %eax,%esi
  801d7b:	73 07                	jae    801d84 <__udivdi3+0xc4>
  801d7d:	39 d5                	cmp    %edx,%ebp
  801d7f:	75 03                	jne    801d84 <__udivdi3+0xc4>
  801d81:	83 eb 01             	sub    $0x1,%ebx
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	89 d8                	mov    %ebx,%eax
  801d88:	89 fa                	mov    %edi,%edx
  801d8a:	83 c4 1c             	add    $0x1c,%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5f                   	pop    %edi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    
  801d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d98:	31 ff                	xor    %edi,%edi
  801d9a:	31 db                	xor    %ebx,%ebx
  801d9c:	89 d8                	mov    %ebx,%eax
  801d9e:	89 fa                	mov    %edi,%edx
  801da0:	83 c4 1c             	add    $0x1c,%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	89 d8                	mov    %ebx,%eax
  801db2:	f7 f7                	div    %edi
  801db4:	31 ff                	xor    %edi,%edi
  801db6:	89 c3                	mov    %eax,%ebx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 fa                	mov    %edi,%edx
  801dbc:	83 c4 1c             	add    $0x1c,%esp
  801dbf:	5b                   	pop    %ebx
  801dc0:	5e                   	pop    %esi
  801dc1:	5f                   	pop    %edi
  801dc2:	5d                   	pop    %ebp
  801dc3:	c3                   	ret    
  801dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc8:	39 ce                	cmp    %ecx,%esi
  801dca:	72 0c                	jb     801dd8 <__udivdi3+0x118>
  801dcc:	31 db                	xor    %ebx,%ebx
  801dce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801dd2:	0f 87 34 ff ff ff    	ja     801d0c <__udivdi3+0x4c>
  801dd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ddd:	e9 2a ff ff ff       	jmp    801d0c <__udivdi3+0x4c>
  801de2:	66 90                	xchg   %ax,%ax
  801de4:	66 90                	xchg   %ax,%ax
  801de6:	66 90                	xchg   %ax,%ax
  801de8:	66 90                	xchg   %ax,%ax
  801dea:	66 90                	xchg   %ax,%ax
  801dec:	66 90                	xchg   %ax,%ax
  801dee:	66 90                	xchg   %ax,%ax

00801df0 <__umoddi3>:
  801df0:	55                   	push   %ebp
  801df1:	57                   	push   %edi
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
  801df4:	83 ec 1c             	sub    $0x1c,%esp
  801df7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e07:	85 d2                	test   %edx,%edx
  801e09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e11:	89 f3                	mov    %esi,%ebx
  801e13:	89 3c 24             	mov    %edi,(%esp)
  801e16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e1a:	75 1c                	jne    801e38 <__umoddi3+0x48>
  801e1c:	39 f7                	cmp    %esi,%edi
  801e1e:	76 50                	jbe    801e70 <__umoddi3+0x80>
  801e20:	89 c8                	mov    %ecx,%eax
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	f7 f7                	div    %edi
  801e26:	89 d0                	mov    %edx,%eax
  801e28:	31 d2                	xor    %edx,%edx
  801e2a:	83 c4 1c             	add    $0x1c,%esp
  801e2d:	5b                   	pop    %ebx
  801e2e:	5e                   	pop    %esi
  801e2f:	5f                   	pop    %edi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    
  801e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e38:	39 f2                	cmp    %esi,%edx
  801e3a:	89 d0                	mov    %edx,%eax
  801e3c:	77 52                	ja     801e90 <__umoddi3+0xa0>
  801e3e:	0f bd ea             	bsr    %edx,%ebp
  801e41:	83 f5 1f             	xor    $0x1f,%ebp
  801e44:	75 5a                	jne    801ea0 <__umoddi3+0xb0>
  801e46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e4a:	0f 82 e0 00 00 00    	jb     801f30 <__umoddi3+0x140>
  801e50:	39 0c 24             	cmp    %ecx,(%esp)
  801e53:	0f 86 d7 00 00 00    	jbe    801f30 <__umoddi3+0x140>
  801e59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e61:	83 c4 1c             	add    $0x1c,%esp
  801e64:	5b                   	pop    %ebx
  801e65:	5e                   	pop    %esi
  801e66:	5f                   	pop    %edi
  801e67:	5d                   	pop    %ebp
  801e68:	c3                   	ret    
  801e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e70:	85 ff                	test   %edi,%edi
  801e72:	89 fd                	mov    %edi,%ebp
  801e74:	75 0b                	jne    801e81 <__umoddi3+0x91>
  801e76:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7b:	31 d2                	xor    %edx,%edx
  801e7d:	f7 f7                	div    %edi
  801e7f:	89 c5                	mov    %eax,%ebp
  801e81:	89 f0                	mov    %esi,%eax
  801e83:	31 d2                	xor    %edx,%edx
  801e85:	f7 f5                	div    %ebp
  801e87:	89 c8                	mov    %ecx,%eax
  801e89:	f7 f5                	div    %ebp
  801e8b:	89 d0                	mov    %edx,%eax
  801e8d:	eb 99                	jmp    801e28 <__umoddi3+0x38>
  801e8f:	90                   	nop
  801e90:	89 c8                	mov    %ecx,%eax
  801e92:	89 f2                	mov    %esi,%edx
  801e94:	83 c4 1c             	add    $0x1c,%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    
  801e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	8b 34 24             	mov    (%esp),%esi
  801ea3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	29 ef                	sub    %ebp,%edi
  801eac:	d3 e0                	shl    %cl,%eax
  801eae:	89 f9                	mov    %edi,%ecx
  801eb0:	89 f2                	mov    %esi,%edx
  801eb2:	d3 ea                	shr    %cl,%edx
  801eb4:	89 e9                	mov    %ebp,%ecx
  801eb6:	09 c2                	or     %eax,%edx
  801eb8:	89 d8                	mov    %ebx,%eax
  801eba:	89 14 24             	mov    %edx,(%esp)
  801ebd:	89 f2                	mov    %esi,%edx
  801ebf:	d3 e2                	shl    %cl,%edx
  801ec1:	89 f9                	mov    %edi,%ecx
  801ec3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ec7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ecb:	d3 e8                	shr    %cl,%eax
  801ecd:	89 e9                	mov    %ebp,%ecx
  801ecf:	89 c6                	mov    %eax,%esi
  801ed1:	d3 e3                	shl    %cl,%ebx
  801ed3:	89 f9                	mov    %edi,%ecx
  801ed5:	89 d0                	mov    %edx,%eax
  801ed7:	d3 e8                	shr    %cl,%eax
  801ed9:	89 e9                	mov    %ebp,%ecx
  801edb:	09 d8                	or     %ebx,%eax
  801edd:	89 d3                	mov    %edx,%ebx
  801edf:	89 f2                	mov    %esi,%edx
  801ee1:	f7 34 24             	divl   (%esp)
  801ee4:	89 d6                	mov    %edx,%esi
  801ee6:	d3 e3                	shl    %cl,%ebx
  801ee8:	f7 64 24 04          	mull   0x4(%esp)
  801eec:	39 d6                	cmp    %edx,%esi
  801eee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ef2:	89 d1                	mov    %edx,%ecx
  801ef4:	89 c3                	mov    %eax,%ebx
  801ef6:	72 08                	jb     801f00 <__umoddi3+0x110>
  801ef8:	75 11                	jne    801f0b <__umoddi3+0x11b>
  801efa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801efe:	73 0b                	jae    801f0b <__umoddi3+0x11b>
  801f00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f04:	1b 14 24             	sbb    (%esp),%edx
  801f07:	89 d1                	mov    %edx,%ecx
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f0f:	29 da                	sub    %ebx,%edx
  801f11:	19 ce                	sbb    %ecx,%esi
  801f13:	89 f9                	mov    %edi,%ecx
  801f15:	89 f0                	mov    %esi,%eax
  801f17:	d3 e0                	shl    %cl,%eax
  801f19:	89 e9                	mov    %ebp,%ecx
  801f1b:	d3 ea                	shr    %cl,%edx
  801f1d:	89 e9                	mov    %ebp,%ecx
  801f1f:	d3 ee                	shr    %cl,%esi
  801f21:	09 d0                	or     %edx,%eax
  801f23:	89 f2                	mov    %esi,%edx
  801f25:	83 c4 1c             	add    $0x1c,%esp
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	5f                   	pop    %edi
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    
  801f2d:	8d 76 00             	lea    0x0(%esi),%esi
  801f30:	29 f9                	sub    %edi,%ecx
  801f32:	19 d6                	sbb    %edx,%esi
  801f34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f3c:	e9 18 ff ff ff       	jmp    801e59 <__umoddi3+0x69>
