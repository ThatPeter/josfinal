
obj/user/spawnfaultio.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 50             	mov    0x50(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 60 24 80 00       	push   $0x802460
  800047:	e8 c8 01 00 00       	call   800214 <cprintf>
	if ((r = spawnl("faultio", "faultio", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 7e 24 80 00       	push   $0x80247e
  800056:	68 7e 24 80 00       	push   $0x80247e
  80005b:	e8 c7 1a 00 00       	call   801b27 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(faultio) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 86 24 80 00       	push   $0x802486
  80006d:	6a 09                	push   $0x9
  80006f:	68 a0 24 80 00       	push   $0x8024a0
  800074:	e8 c2 00 00 00       	call   80013b <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	57                   	push   %edi
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800084:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80008b:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80008e:	e8 cb 0a 00 00       	call   800b5e <sys_getenvid>
  800093:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	50                   	push   %eax
  800099:	68 b4 24 80 00       	push   $0x8024b4
  80009e:	e8 71 01 00 00       	call   800214 <cprintf>
  8000a3:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000a9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000bb:	89 c1                	mov    %eax,%ecx
  8000bd:	c1 e1 07             	shl    $0x7,%ecx
  8000c0:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000c7:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000ca:	39 cb                	cmp    %ecx,%ebx
  8000cc:	0f 44 fa             	cmove  %edx,%edi
  8000cf:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000d4:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000d7:	83 c0 01             	add    $0x1,%eax
  8000da:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000e0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000e5:	75 d4                	jne    8000bb <libmain+0x40>
  8000e7:	89 f0                	mov    %esi,%eax
  8000e9:	84 c0                	test   %al,%al
  8000eb:	74 06                	je     8000f3 <libmain+0x78>
  8000ed:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000f7:	7e 0a                	jle    800103 <libmain+0x88>
		binaryname = argv[0];
  8000f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fc:	8b 00                	mov    (%eax),%eax
  8000fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	ff 75 0c             	pushl  0xc(%ebp)
  800109:	ff 75 08             	pushl  0x8(%ebp)
  80010c:	e8 22 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800111:	e8 0b 00 00 00       	call   800121 <exit>
}
  800116:	83 c4 10             	add    $0x10,%esp
  800119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011c:	5b                   	pop    %ebx
  80011d:	5e                   	pop    %esi
  80011e:	5f                   	pop    %edi
  80011f:	5d                   	pop    %ebp
  800120:	c3                   	ret    

00800121 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800127:	e8 4c 0e 00 00       	call   800f78 <close_all>
	sys_env_destroy(0);
  80012c:	83 ec 0c             	sub    $0xc,%esp
  80012f:	6a 00                	push   $0x0
  800131:	e8 e7 09 00 00       	call   800b1d <sys_env_destroy>
}
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800140:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800143:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800149:	e8 10 0a 00 00       	call   800b5e <sys_getenvid>
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	56                   	push   %esi
  800158:	50                   	push   %eax
  800159:	68 e0 24 80 00       	push   $0x8024e0
  80015e:	e8 b1 00 00 00       	call   800214 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800163:	83 c4 18             	add    $0x18,%esp
  800166:	53                   	push   %ebx
  800167:	ff 75 10             	pushl  0x10(%ebp)
  80016a:	e8 54 00 00 00       	call   8001c3 <vcprintf>
	cprintf("\n");
  80016f:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  800176:	e8 99 00 00 00       	call   800214 <cprintf>
  80017b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017e:	cc                   	int3   
  80017f:	eb fd                	jmp    80017e <_panic+0x43>

00800181 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	53                   	push   %ebx
  800185:	83 ec 04             	sub    $0x4,%esp
  800188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018b:	8b 13                	mov    (%ebx),%edx
  80018d:	8d 42 01             	lea    0x1(%edx),%eax
  800190:	89 03                	mov    %eax,(%ebx)
  800192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800195:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800199:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019e:	75 1a                	jne    8001ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	68 ff 00 00 00       	push   $0xff
  8001a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ab:	50                   	push   %eax
  8001ac:	e8 2f 09 00 00       	call   800ae0 <sys_cputs>
		b->idx = 0;
  8001b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d3:	00 00 00 
	b.cnt = 0;
  8001d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e0:	ff 75 0c             	pushl  0xc(%ebp)
  8001e3:	ff 75 08             	pushl  0x8(%ebp)
  8001e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ec:	50                   	push   %eax
  8001ed:	68 81 01 80 00       	push   $0x800181
  8001f2:	e8 54 01 00 00       	call   80034b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f7:	83 c4 08             	add    $0x8,%esp
  8001fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800200:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	e8 d4 08 00 00       	call   800ae0 <sys_cputs>

	return b.cnt;
}
  80020c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021d:	50                   	push   %eax
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	e8 9d ff ff ff       	call   8001c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 1c             	sub    $0x1c,%esp
  800231:	89 c7                	mov    %eax,%edi
  800233:	89 d6                	mov    %edx,%esi
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800241:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800244:	bb 00 00 00 00       	mov    $0x0,%ebx
  800249:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024f:	39 d3                	cmp    %edx,%ebx
  800251:	72 05                	jb     800258 <printnum+0x30>
  800253:	39 45 10             	cmp    %eax,0x10(%ebp)
  800256:	77 45                	ja     80029d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	ff 75 18             	pushl  0x18(%ebp)
  80025e:	8b 45 14             	mov    0x14(%ebp),%eax
  800261:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800264:	53                   	push   %ebx
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026e:	ff 75 e0             	pushl  -0x20(%ebp)
  800271:	ff 75 dc             	pushl  -0x24(%ebp)
  800274:	ff 75 d8             	pushl  -0x28(%ebp)
  800277:	e8 54 1f 00 00       	call   8021d0 <__udivdi3>
  80027c:	83 c4 18             	add    $0x18,%esp
  80027f:	52                   	push   %edx
  800280:	50                   	push   %eax
  800281:	89 f2                	mov    %esi,%edx
  800283:	89 f8                	mov    %edi,%eax
  800285:	e8 9e ff ff ff       	call   800228 <printnum>
  80028a:	83 c4 20             	add    $0x20,%esp
  80028d:	eb 18                	jmp    8002a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	ff 75 18             	pushl  0x18(%ebp)
  800296:	ff d7                	call   *%edi
  800298:	83 c4 10             	add    $0x10,%esp
  80029b:	eb 03                	jmp    8002a0 <printnum+0x78>
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a0:	83 eb 01             	sub    $0x1,%ebx
  8002a3:	85 db                	test   %ebx,%ebx
  8002a5:	7f e8                	jg     80028f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	83 ec 04             	sub    $0x4,%esp
  8002ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ba:	e8 41 20 00 00       	call   802300 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 03 25 80 00 	movsbl 0x802503(%eax),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff d7                	call   *%edi
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002da:	83 fa 01             	cmp    $0x1,%edx
  8002dd:	7e 0e                	jle    8002ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e4:	89 08                	mov    %ecx,(%eax)
  8002e6:	8b 02                	mov    (%edx),%eax
  8002e8:	8b 52 04             	mov    0x4(%edx),%edx
  8002eb:	eb 22                	jmp    80030f <getuint+0x38>
	else if (lflag)
  8002ed:	85 d2                	test   %edx,%edx
  8002ef:	74 10                	je     800301 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ff:	eb 0e                	jmp    80030f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 04             	lea    0x4(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800317:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031b:	8b 10                	mov    (%eax),%edx
  80031d:	3b 50 04             	cmp    0x4(%eax),%edx
  800320:	73 0a                	jae    80032c <sprintputch+0x1b>
		*b->buf++ = ch;
  800322:	8d 4a 01             	lea    0x1(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	88 02                	mov    %al,(%edx)
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800334:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800337:	50                   	push   %eax
  800338:	ff 75 10             	pushl  0x10(%ebp)
  80033b:	ff 75 0c             	pushl  0xc(%ebp)
  80033e:	ff 75 08             	pushl  0x8(%ebp)
  800341:	e8 05 00 00 00       	call   80034b <vprintfmt>
	va_end(ap);
}
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	c9                   	leave  
  80034a:	c3                   	ret    

0080034b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
  800351:	83 ec 2c             	sub    $0x2c,%esp
  800354:	8b 75 08             	mov    0x8(%ebp),%esi
  800357:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035d:	eb 12                	jmp    800371 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035f:	85 c0                	test   %eax,%eax
  800361:	0f 84 89 03 00 00    	je     8006f0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800367:	83 ec 08             	sub    $0x8,%esp
  80036a:	53                   	push   %ebx
  80036b:	50                   	push   %eax
  80036c:	ff d6                	call   *%esi
  80036e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800371:	83 c7 01             	add    $0x1,%edi
  800374:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800378:	83 f8 25             	cmp    $0x25,%eax
  80037b:	75 e2                	jne    80035f <vprintfmt+0x14>
  80037d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800381:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800388:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
  80039b:	eb 07                	jmp    8003a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8d 47 01             	lea    0x1(%edi),%eax
  8003a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003aa:	0f b6 07             	movzbl (%edi),%eax
  8003ad:	0f b6 c8             	movzbl %al,%ecx
  8003b0:	83 e8 23             	sub    $0x23,%eax
  8003b3:	3c 55                	cmp    $0x55,%al
  8003b5:	0f 87 1a 03 00 00    	ja     8006d5 <vprintfmt+0x38a>
  8003bb:	0f b6 c0             	movzbl %al,%eax
  8003be:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cc:	eb d6                	jmp    8003a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e6:	83 fa 09             	cmp    $0x9,%edx
  8003e9:	77 39                	ja     800424 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ee:	eb e9                	jmp    8003d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800401:	eb 27                	jmp    80042a <vprintfmt+0xdf>
  800403:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800406:	85 c0                	test   %eax,%eax
  800408:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040d:	0f 49 c8             	cmovns %eax,%ecx
  800410:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800416:	eb 8c                	jmp    8003a4 <vprintfmt+0x59>
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800422:	eb 80                	jmp    8003a4 <vprintfmt+0x59>
  800424:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800427:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042e:	0f 89 70 ff ff ff    	jns    8003a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800434:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800441:	e9 5e ff ff ff       	jmp    8003a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800446:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044c:	e9 53 ff ff ff       	jmp    8003a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	ff 30                	pushl  (%eax)
  800460:	ff d6                	call   *%esi
			break;
  800462:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800468:	e9 04 ff ff ff       	jmp    800371 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 50 04             	lea    0x4(%eax),%edx
  800473:	89 55 14             	mov    %edx,0x14(%ebp)
  800476:	8b 00                	mov    (%eax),%eax
  800478:	99                   	cltd   
  800479:	31 d0                	xor    %edx,%eax
  80047b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047d:	83 f8 0f             	cmp    $0xf,%eax
  800480:	7f 0b                	jg     80048d <vprintfmt+0x142>
  800482:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  800489:	85 d2                	test   %edx,%edx
  80048b:	75 18                	jne    8004a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048d:	50                   	push   %eax
  80048e:	68 1b 25 80 00       	push   $0x80251b
  800493:	53                   	push   %ebx
  800494:	56                   	push   %esi
  800495:	e8 94 fe ff ff       	call   80032e <printfmt>
  80049a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a0:	e9 cc fe ff ff       	jmp    800371 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a5:	52                   	push   %edx
  8004a6:	68 d1 28 80 00       	push   $0x8028d1
  8004ab:	53                   	push   %ebx
  8004ac:	56                   	push   %esi
  8004ad:	e8 7c fe ff ff       	call   80032e <printfmt>
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b8:	e9 b4 fe ff ff       	jmp    800371 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 50 04             	lea    0x4(%eax),%edx
  8004c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c8:	85 ff                	test   %edi,%edi
  8004ca:	b8 14 25 80 00       	mov    $0x802514,%eax
  8004cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d6:	0f 8e 94 00 00 00    	jle    800570 <vprintfmt+0x225>
  8004dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e0:	0f 84 98 00 00 00    	je     80057e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ec:	57                   	push   %edi
  8004ed:	e8 86 02 00 00       	call   800778 <strnlen>
  8004f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f5:	29 c1                	sub    %eax,%ecx
  8004f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800504:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800507:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	eb 0f                	jmp    80051a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	ff 75 e0             	pushl  -0x20(%ebp)
  800512:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 ff                	test   %edi,%edi
  80051c:	7f ed                	jg     80050b <vprintfmt+0x1c0>
  80051e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800521:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800524:	85 c9                	test   %ecx,%ecx
  800526:	b8 00 00 00 00       	mov    $0x0,%eax
  80052b:	0f 49 c1             	cmovns %ecx,%eax
  80052e:	29 c1                	sub    %eax,%ecx
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	89 cb                	mov    %ecx,%ebx
  80053b:	eb 4d                	jmp    80058a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800541:	74 1b                	je     80055e <vprintfmt+0x213>
  800543:	0f be c0             	movsbl %al,%eax
  800546:	83 e8 20             	sub    $0x20,%eax
  800549:	83 f8 5e             	cmp    $0x5e,%eax
  80054c:	76 10                	jbe    80055e <vprintfmt+0x213>
					putch('?', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	ff 75 0c             	pushl  0xc(%ebp)
  800554:	6a 3f                	push   $0x3f
  800556:	ff 55 08             	call   *0x8(%ebp)
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	eb 0d                	jmp    80056b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 0c             	pushl  0xc(%ebp)
  800564:	52                   	push   %edx
  800565:	ff 55 08             	call   *0x8(%ebp)
  800568:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056b:	83 eb 01             	sub    $0x1,%ebx
  80056e:	eb 1a                	jmp    80058a <vprintfmt+0x23f>
  800570:	89 75 08             	mov    %esi,0x8(%ebp)
  800573:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800576:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800579:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057c:	eb 0c                	jmp    80058a <vprintfmt+0x23f>
  80057e:	89 75 08             	mov    %esi,0x8(%ebp)
  800581:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800584:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800587:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058a:	83 c7 01             	add    $0x1,%edi
  80058d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800591:	0f be d0             	movsbl %al,%edx
  800594:	85 d2                	test   %edx,%edx
  800596:	74 23                	je     8005bb <vprintfmt+0x270>
  800598:	85 f6                	test   %esi,%esi
  80059a:	78 a1                	js     80053d <vprintfmt+0x1f2>
  80059c:	83 ee 01             	sub    $0x1,%esi
  80059f:	79 9c                	jns    80053d <vprintfmt+0x1f2>
  8005a1:	89 df                	mov    %ebx,%edi
  8005a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a9:	eb 18                	jmp    8005c3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	6a 20                	push   $0x20
  8005b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b3:	83 ef 01             	sub    $0x1,%edi
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	eb 08                	jmp    8005c3 <vprintfmt+0x278>
  8005bb:	89 df                	mov    %ebx,%edi
  8005bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	7f e4                	jg     8005ab <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ca:	e9 a2 fd ff ff       	jmp    800371 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cf:	83 fa 01             	cmp    $0x1,%edx
  8005d2:	7e 16                	jle    8005ea <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 08             	lea    0x8(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 50 04             	mov    0x4(%eax),%edx
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e8:	eb 32                	jmp    80061c <vprintfmt+0x2d1>
	else if (lflag)
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	74 18                	je     800606 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 c1                	mov    %eax,%ecx
  8005fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800601:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800604:	eb 16                	jmp    80061c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	89 c1                	mov    %eax,%ecx
  800616:	c1 f9 1f             	sar    $0x1f,%ecx
  800619:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800622:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800627:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062b:	79 74                	jns    8006a1 <vprintfmt+0x356>
				putch('-', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 2d                	push   $0x2d
  800633:	ff d6                	call   *%esi
				num = -(long long) num;
  800635:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800638:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063b:	f7 d8                	neg    %eax
  80063d:	83 d2 00             	adc    $0x0,%edx
  800640:	f7 da                	neg    %edx
  800642:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800645:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064a:	eb 55                	jmp    8006a1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	e8 83 fc ff ff       	call   8002d7 <getuint>
			base = 10;
  800654:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800659:	eb 46                	jmp    8006a1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 74 fc ff ff       	call   8002d7 <getuint>
			base = 8;
  800663:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800668:	eb 37                	jmp    8006a1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 30                	push   $0x30
  800670:	ff d6                	call   *%esi
			putch('x', putdat);
  800672:	83 c4 08             	add    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 78                	push   $0x78
  800678:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800692:	eb 0d                	jmp    8006a1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800694:	8d 45 14             	lea    0x14(%ebp),%eax
  800697:	e8 3b fc ff ff       	call   8002d7 <getuint>
			base = 16;
  80069c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a1:	83 ec 0c             	sub    $0xc,%esp
  8006a4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a8:	57                   	push   %edi
  8006a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ac:	51                   	push   %ecx
  8006ad:	52                   	push   %edx
  8006ae:	50                   	push   %eax
  8006af:	89 da                	mov    %ebx,%edx
  8006b1:	89 f0                	mov    %esi,%eax
  8006b3:	e8 70 fb ff ff       	call   800228 <printnum>
			break;
  8006b8:	83 c4 20             	add    $0x20,%esp
  8006bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006be:	e9 ae fc ff ff       	jmp    800371 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	51                   	push   %ecx
  8006c8:	ff d6                	call   *%esi
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d0:	e9 9c fc ff ff       	jmp    800371 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	6a 25                	push   $0x25
  8006db:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 03                	jmp    8006e5 <vprintfmt+0x39a>
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e9:	75 f7                	jne    8006e2 <vprintfmt+0x397>
  8006eb:	e9 81 fc ff ff       	jmp    800371 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f3:	5b                   	pop    %ebx
  8006f4:	5e                   	pop    %esi
  8006f5:	5f                   	pop    %edi
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	83 ec 18             	sub    $0x18,%esp
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800704:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800707:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800715:	85 c0                	test   %eax,%eax
  800717:	74 26                	je     80073f <vsnprintf+0x47>
  800719:	85 d2                	test   %edx,%edx
  80071b:	7e 22                	jle    80073f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071d:	ff 75 14             	pushl  0x14(%ebp)
  800720:	ff 75 10             	pushl  0x10(%ebp)
  800723:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800726:	50                   	push   %eax
  800727:	68 11 03 80 00       	push   $0x800311
  80072c:	e8 1a fc ff ff       	call   80034b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800731:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800734:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	eb 05                	jmp    800744 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800744:	c9                   	leave  
  800745:	c3                   	ret    

00800746 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074f:	50                   	push   %eax
  800750:	ff 75 10             	pushl  0x10(%ebp)
  800753:	ff 75 0c             	pushl  0xc(%ebp)
  800756:	ff 75 08             	pushl  0x8(%ebp)
  800759:	e8 9a ff ff ff       	call   8006f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	eb 03                	jmp    800770 <strlen+0x10>
		n++;
  80076d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800770:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800774:	75 f7                	jne    80076d <strlen+0xd>
		n++;
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800781:	ba 00 00 00 00       	mov    $0x0,%edx
  800786:	eb 03                	jmp    80078b <strnlen+0x13>
		n++;
  800788:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	39 c2                	cmp    %eax,%edx
  80078d:	74 08                	je     800797 <strnlen+0x1f>
  80078f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800793:	75 f3                	jne    800788 <strnlen+0x10>
  800795:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	53                   	push   %ebx
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a3:	89 c2                	mov    %eax,%edx
  8007a5:	83 c2 01             	add    $0x1,%edx
  8007a8:	83 c1 01             	add    $0x1,%ecx
  8007ab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007af:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b2:	84 db                	test   %bl,%bl
  8007b4:	75 ef                	jne    8007a5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c0:	53                   	push   %ebx
  8007c1:	e8 9a ff ff ff       	call   800760 <strlen>
  8007c6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	01 d8                	add    %ebx,%eax
  8007ce:	50                   	push   %eax
  8007cf:	e8 c5 ff ff ff       	call   800799 <strcpy>
	return dst;
}
  8007d4:	89 d8                	mov    %ebx,%eax
  8007d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	56                   	push   %esi
  8007df:	53                   	push   %ebx
  8007e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e6:	89 f3                	mov    %esi,%ebx
  8007e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007eb:	89 f2                	mov    %esi,%edx
  8007ed:	eb 0f                	jmp    8007fe <strncpy+0x23>
		*dst++ = *src;
  8007ef:	83 c2 01             	add    $0x1,%edx
  8007f2:	0f b6 01             	movzbl (%ecx),%eax
  8007f5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fe:	39 da                	cmp    %ebx,%edx
  800800:	75 ed                	jne    8007ef <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800802:	89 f0                	mov    %esi,%eax
  800804:	5b                   	pop    %ebx
  800805:	5e                   	pop    %esi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	8b 75 08             	mov    0x8(%ebp),%esi
  800810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800813:	8b 55 10             	mov    0x10(%ebp),%edx
  800816:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800818:	85 d2                	test   %edx,%edx
  80081a:	74 21                	je     80083d <strlcpy+0x35>
  80081c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800820:	89 f2                	mov    %esi,%edx
  800822:	eb 09                	jmp    80082d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800824:	83 c2 01             	add    $0x1,%edx
  800827:	83 c1 01             	add    $0x1,%ecx
  80082a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082d:	39 c2                	cmp    %eax,%edx
  80082f:	74 09                	je     80083a <strlcpy+0x32>
  800831:	0f b6 19             	movzbl (%ecx),%ebx
  800834:	84 db                	test   %bl,%bl
  800836:	75 ec                	jne    800824 <strlcpy+0x1c>
  800838:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083d:	29 f0                	sub    %esi,%eax
}
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084c:	eb 06                	jmp    800854 <strcmp+0x11>
		p++, q++;
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800854:	0f b6 01             	movzbl (%ecx),%eax
  800857:	84 c0                	test   %al,%al
  800859:	74 04                	je     80085f <strcmp+0x1c>
  80085b:	3a 02                	cmp    (%edx),%al
  80085d:	74 ef                	je     80084e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085f:	0f b6 c0             	movzbl %al,%eax
  800862:	0f b6 12             	movzbl (%edx),%edx
  800865:	29 d0                	sub    %edx,%eax
}
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	89 c3                	mov    %eax,%ebx
  800875:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800878:	eb 06                	jmp    800880 <strncmp+0x17>
		n--, p++, q++;
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800880:	39 d8                	cmp    %ebx,%eax
  800882:	74 15                	je     800899 <strncmp+0x30>
  800884:	0f b6 08             	movzbl (%eax),%ecx
  800887:	84 c9                	test   %cl,%cl
  800889:	74 04                	je     80088f <strncmp+0x26>
  80088b:	3a 0a                	cmp    (%edx),%cl
  80088d:	74 eb                	je     80087a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 00             	movzbl (%eax),%eax
  800892:	0f b6 12             	movzbl (%edx),%edx
  800895:	29 d0                	sub    %edx,%eax
  800897:	eb 05                	jmp    80089e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ab:	eb 07                	jmp    8008b4 <strchr+0x13>
		if (*s == c)
  8008ad:	38 ca                	cmp    %cl,%dl
  8008af:	74 0f                	je     8008c0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	0f b6 10             	movzbl (%eax),%edx
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	75 f2                	jne    8008ad <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cc:	eb 03                	jmp    8008d1 <strfind+0xf>
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	74 04                	je     8008dc <strfind+0x1a>
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	75 f2                	jne    8008ce <strfind+0xc>
			break;
	return (char *) s;
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	57                   	push   %edi
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
  8008e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	74 36                	je     800924 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f4:	75 28                	jne    80091e <memset+0x40>
  8008f6:	f6 c1 03             	test   $0x3,%cl
  8008f9:	75 23                	jne    80091e <memset+0x40>
		c &= 0xFF;
  8008fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ff:	89 d3                	mov    %edx,%ebx
  800901:	c1 e3 08             	shl    $0x8,%ebx
  800904:	89 d6                	mov    %edx,%esi
  800906:	c1 e6 18             	shl    $0x18,%esi
  800909:	89 d0                	mov    %edx,%eax
  80090b:	c1 e0 10             	shl    $0x10,%eax
  80090e:	09 f0                	or     %esi,%eax
  800910:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800912:	89 d8                	mov    %ebx,%eax
  800914:	09 d0                	or     %edx,%eax
  800916:	c1 e9 02             	shr    $0x2,%ecx
  800919:	fc                   	cld    
  80091a:	f3 ab                	rep stos %eax,%es:(%edi)
  80091c:	eb 06                	jmp    800924 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800921:	fc                   	cld    
  800922:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800924:	89 f8                	mov    %edi,%eax
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	57                   	push   %edi
  80092f:	56                   	push   %esi
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 75 0c             	mov    0xc(%ebp),%esi
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800939:	39 c6                	cmp    %eax,%esi
  80093b:	73 35                	jae    800972 <memmove+0x47>
  80093d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800940:	39 d0                	cmp    %edx,%eax
  800942:	73 2e                	jae    800972 <memmove+0x47>
		s += n;
		d += n;
  800944:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800947:	89 d6                	mov    %edx,%esi
  800949:	09 fe                	or     %edi,%esi
  80094b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800951:	75 13                	jne    800966 <memmove+0x3b>
  800953:	f6 c1 03             	test   $0x3,%cl
  800956:	75 0e                	jne    800966 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800958:	83 ef 04             	sub    $0x4,%edi
  80095b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095e:	c1 e9 02             	shr    $0x2,%ecx
  800961:	fd                   	std    
  800962:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800964:	eb 09                	jmp    80096f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800966:	83 ef 01             	sub    $0x1,%edi
  800969:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096c:	fd                   	std    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096f:	fc                   	cld    
  800970:	eb 1d                	jmp    80098f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800972:	89 f2                	mov    %esi,%edx
  800974:	09 c2                	or     %eax,%edx
  800976:	f6 c2 03             	test   $0x3,%dl
  800979:	75 0f                	jne    80098a <memmove+0x5f>
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 0a                	jne    80098a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800980:	c1 e9 02             	shr    $0x2,%ecx
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 05                	jmp    80098f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098a:	89 c7                	mov    %eax,%edi
  80098c:	fc                   	cld    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098f:	5e                   	pop    %esi
  800990:	5f                   	pop    %edi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800996:	ff 75 10             	pushl  0x10(%ebp)
  800999:	ff 75 0c             	pushl  0xc(%ebp)
  80099c:	ff 75 08             	pushl  0x8(%ebp)
  80099f:	e8 87 ff ff ff       	call   80092b <memmove>
}
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	89 c6                	mov    %eax,%esi
  8009b3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b6:	eb 1a                	jmp    8009d2 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b8:	0f b6 08             	movzbl (%eax),%ecx
  8009bb:	0f b6 1a             	movzbl (%edx),%ebx
  8009be:	38 d9                	cmp    %bl,%cl
  8009c0:	74 0a                	je     8009cc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c2:	0f b6 c1             	movzbl %cl,%eax
  8009c5:	0f b6 db             	movzbl %bl,%ebx
  8009c8:	29 d8                	sub    %ebx,%eax
  8009ca:	eb 0f                	jmp    8009db <memcmp+0x35>
		s1++, s2++;
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d2:	39 f0                	cmp    %esi,%eax
  8009d4:	75 e2                	jne    8009b8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	53                   	push   %ebx
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e6:	89 c1                	mov    %eax,%ecx
  8009e8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009eb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ef:	eb 0a                	jmp    8009fb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f1:	0f b6 10             	movzbl (%eax),%edx
  8009f4:	39 da                	cmp    %ebx,%edx
  8009f6:	74 07                	je     8009ff <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f8:	83 c0 01             	add    $0x1,%eax
  8009fb:	39 c8                	cmp    %ecx,%eax
  8009fd:	72 f2                	jb     8009f1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0e:	eb 03                	jmp    800a13 <strtol+0x11>
		s++;
  800a10:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a13:	0f b6 01             	movzbl (%ecx),%eax
  800a16:	3c 20                	cmp    $0x20,%al
  800a18:	74 f6                	je     800a10 <strtol+0xe>
  800a1a:	3c 09                	cmp    $0x9,%al
  800a1c:	74 f2                	je     800a10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1e:	3c 2b                	cmp    $0x2b,%al
  800a20:	75 0a                	jne    800a2c <strtol+0x2a>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a25:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2a:	eb 11                	jmp    800a3d <strtol+0x3b>
  800a2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a31:	3c 2d                	cmp    $0x2d,%al
  800a33:	75 08                	jne    800a3d <strtol+0x3b>
		s++, neg = 1;
  800a35:	83 c1 01             	add    $0x1,%ecx
  800a38:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a43:	75 15                	jne    800a5a <strtol+0x58>
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	75 10                	jne    800a5a <strtol+0x58>
  800a4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4e:	75 7c                	jne    800acc <strtol+0xca>
		s += 2, base = 16;
  800a50:	83 c1 02             	add    $0x2,%ecx
  800a53:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a58:	eb 16                	jmp    800a70 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5a:	85 db                	test   %ebx,%ebx
  800a5c:	75 12                	jne    800a70 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a63:	80 39 30             	cmpb   $0x30,(%ecx)
  800a66:	75 08                	jne    800a70 <strtol+0x6e>
		s++, base = 8;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a78:	0f b6 11             	movzbl (%ecx),%edx
  800a7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7e:	89 f3                	mov    %esi,%ebx
  800a80:	80 fb 09             	cmp    $0x9,%bl
  800a83:	77 08                	ja     800a8d <strtol+0x8b>
			dig = *s - '0';
  800a85:	0f be d2             	movsbl %dl,%edx
  800a88:	83 ea 30             	sub    $0x30,%edx
  800a8b:	eb 22                	jmp    800aaf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 19             	cmp    $0x19,%bl
  800a95:	77 08                	ja     800a9f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 57             	sub    $0x57,%edx
  800a9d:	eb 10                	jmp    800aaf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 16                	ja     800abf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aaf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab2:	7d 0b                	jge    800abf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab4:	83 c1 01             	add    $0x1,%ecx
  800ab7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abd:	eb b9                	jmp    800a78 <strtol+0x76>

	if (endptr)
  800abf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac3:	74 0d                	je     800ad2 <strtol+0xd0>
		*endptr = (char *) s;
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac8:	89 0e                	mov    %ecx,(%esi)
  800aca:	eb 06                	jmp    800ad2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acc:	85 db                	test   %ebx,%ebx
  800ace:	74 98                	je     800a68 <strtol+0x66>
  800ad0:	eb 9e                	jmp    800a70 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad2:	89 c2                	mov    %eax,%edx
  800ad4:	f7 da                	neg    %edx
  800ad6:	85 ff                	test   %edi,%edi
  800ad8:	0f 45 c2             	cmovne %edx,%eax
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aee:	8b 55 08             	mov    0x8(%ebp),%edx
  800af1:	89 c3                	mov    %eax,%ebx
  800af3:	89 c7                	mov    %eax,%edi
  800af5:	89 c6                	mov    %eax,%esi
  800af7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_cgetc>:

int
sys_cgetc(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b30:	8b 55 08             	mov    0x8(%ebp),%edx
  800b33:	89 cb                	mov    %ecx,%ebx
  800b35:	89 cf                	mov    %ecx,%edi
  800b37:	89 ce                	mov    %ecx,%esi
  800b39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 17                	jle    800b56 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	50                   	push   %eax
  800b43:	6a 03                	push   $0x3
  800b45:	68 ff 27 80 00       	push   $0x8027ff
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 1c 28 80 00       	push   $0x80281c
  800b51:	e8 e5 f5 ff ff       	call   80013b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_yield>:

void
sys_yield(void)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
  800b88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8d:	89 d1                	mov    %edx,%ecx
  800b8f:	89 d3                	mov    %edx,%ebx
  800b91:	89 d7                	mov    %edx,%edi
  800b93:	89 d6                	mov    %edx,%esi
  800b95:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	be 00 00 00 00       	mov    $0x0,%esi
  800baa:	b8 04 00 00 00       	mov    $0x4,%eax
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb8:	89 f7                	mov    %esi,%edi
  800bba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 17                	jle    800bd7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 04                	push   $0x4
  800bc6:	68 ff 27 80 00       	push   $0x8027ff
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 1c 28 80 00       	push   $0x80281c
  800bd2:	e8 64 f5 ff ff       	call   80013b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7e 17                	jle    800c19 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 05                	push   $0x5
  800c08:	68 ff 27 80 00       	push   $0x8027ff
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 1c 28 80 00       	push   $0x80281c
  800c14:	e8 22 f5 ff ff       	call   80013b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	89 df                	mov    %ebx,%edi
  800c3c:	89 de                	mov    %ebx,%esi
  800c3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 06                	push   $0x6
  800c4a:	68 ff 27 80 00       	push   $0x8027ff
  800c4f:	6a 23                	push   $0x23
  800c51:	68 1c 28 80 00       	push   $0x80281c
  800c56:	e8 e0 f4 ff ff       	call   80013b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c71:	b8 08 00 00 00       	mov    $0x8,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	89 df                	mov    %ebx,%edi
  800c7e:	89 de                	mov    %ebx,%esi
  800c80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 08                	push   $0x8
  800c8c:	68 ff 27 80 00       	push   $0x8027ff
  800c91:	6a 23                	push   $0x23
  800c93:	68 1c 28 80 00       	push   $0x80281c
  800c98:	e8 9e f4 ff ff       	call   80013b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	89 df                	mov    %ebx,%edi
  800cc0:	89 de                	mov    %ebx,%esi
  800cc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 09                	push   $0x9
  800cce:	68 ff 27 80 00       	push   $0x8027ff
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 1c 28 80 00       	push   $0x80281c
  800cda:	e8 5c f4 ff ff       	call   80013b <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 17                	jle    800d21 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 0a                	push   $0xa
  800d10:	68 ff 27 80 00       	push   $0x8027ff
  800d15:	6a 23                	push   $0x23
  800d17:	68 1c 28 80 00       	push   $0x80281c
  800d1c:	e8 1a f4 ff ff       	call   80013b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	be 00 00 00 00       	mov    $0x0,%esi
  800d34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d45:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	89 cb                	mov    %ecx,%ebx
  800d64:	89 cf                	mov    %ecx,%edi
  800d66:	89 ce                	mov    %ecx,%esi
  800d68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	7e 17                	jle    800d85 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6e:	83 ec 0c             	sub    $0xc,%esp
  800d71:	50                   	push   %eax
  800d72:	6a 0d                	push   $0xd
  800d74:	68 ff 27 80 00       	push   $0x8027ff
  800d79:	6a 23                	push   $0x23
  800d7b:	68 1c 28 80 00       	push   $0x80281c
  800d80:	e8 b6 f3 ff ff       	call   80013b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d98:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	89 cb                	mov    %ecx,%ebx
  800da2:	89 cf                	mov    %ecx,%edi
  800da4:	89 ce                	mov    %ecx,%esi
  800da6:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	05 00 00 00 30       	add    $0x30000000,%eax
  800db8:	c1 e8 0c             	shr    $0xc,%eax
}
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dcd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dda:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ddf:	89 c2                	mov    %eax,%edx
  800de1:	c1 ea 16             	shr    $0x16,%edx
  800de4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800deb:	f6 c2 01             	test   $0x1,%dl
  800dee:	74 11                	je     800e01 <fd_alloc+0x2d>
  800df0:	89 c2                	mov    %eax,%edx
  800df2:	c1 ea 0c             	shr    $0xc,%edx
  800df5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dfc:	f6 c2 01             	test   $0x1,%dl
  800dff:	75 09                	jne    800e0a <fd_alloc+0x36>
			*fd_store = fd;
  800e01:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e03:	b8 00 00 00 00       	mov    $0x0,%eax
  800e08:	eb 17                	jmp    800e21 <fd_alloc+0x4d>
  800e0a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e0f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e14:	75 c9                	jne    800ddf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e16:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e1c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e29:	83 f8 1f             	cmp    $0x1f,%eax
  800e2c:	77 36                	ja     800e64 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e2e:	c1 e0 0c             	shl    $0xc,%eax
  800e31:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	c1 ea 16             	shr    $0x16,%edx
  800e3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e42:	f6 c2 01             	test   $0x1,%dl
  800e45:	74 24                	je     800e6b <fd_lookup+0x48>
  800e47:	89 c2                	mov    %eax,%edx
  800e49:	c1 ea 0c             	shr    $0xc,%edx
  800e4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e53:	f6 c2 01             	test   $0x1,%dl
  800e56:	74 1a                	je     800e72 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e62:	eb 13                	jmp    800e77 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e69:	eb 0c                	jmp    800e77 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e70:	eb 05                	jmp    800e77 <fd_lookup+0x54>
  800e72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 08             	sub    $0x8,%esp
  800e7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e82:	ba a8 28 80 00       	mov    $0x8028a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e87:	eb 13                	jmp    800e9c <dev_lookup+0x23>
  800e89:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e8c:	39 08                	cmp    %ecx,(%eax)
  800e8e:	75 0c                	jne    800e9c <dev_lookup+0x23>
			*dev = devtab[i];
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e93:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	eb 2e                	jmp    800eca <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e9c:	8b 02                	mov    (%edx),%eax
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	75 e7                	jne    800e89 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ea2:	a1 04 40 80 00       	mov    0x804004,%eax
  800ea7:	8b 40 50             	mov    0x50(%eax),%eax
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	51                   	push   %ecx
  800eae:	50                   	push   %eax
  800eaf:	68 2c 28 80 00       	push   $0x80282c
  800eb4:	e8 5b f3 ff ff       	call   800214 <cprintf>
	*dev = 0;
  800eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 10             	sub    $0x10,%esp
  800ed4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edd:	50                   	push   %eax
  800ede:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ee4:	c1 e8 0c             	shr    $0xc,%eax
  800ee7:	50                   	push   %eax
  800ee8:	e8 36 ff ff ff       	call   800e23 <fd_lookup>
  800eed:	83 c4 08             	add    $0x8,%esp
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	78 05                	js     800ef9 <fd_close+0x2d>
	    || fd != fd2)
  800ef4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ef7:	74 0c                	je     800f05 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ef9:	84 db                	test   %bl,%bl
  800efb:	ba 00 00 00 00       	mov    $0x0,%edx
  800f00:	0f 44 c2             	cmove  %edx,%eax
  800f03:	eb 41                	jmp    800f46 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f05:	83 ec 08             	sub    $0x8,%esp
  800f08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f0b:	50                   	push   %eax
  800f0c:	ff 36                	pushl  (%esi)
  800f0e:	e8 66 ff ff ff       	call   800e79 <dev_lookup>
  800f13:	89 c3                	mov    %eax,%ebx
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 1a                	js     800f36 <fd_close+0x6a>
		if (dev->dev_close)
  800f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f22:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	74 0b                	je     800f36 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	56                   	push   %esi
  800f2f:	ff d0                	call   *%eax
  800f31:	89 c3                	mov    %eax,%ebx
  800f33:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f36:	83 ec 08             	sub    $0x8,%esp
  800f39:	56                   	push   %esi
  800f3a:	6a 00                	push   $0x0
  800f3c:	e8 e0 fc ff ff       	call   800c21 <sys_page_unmap>
	return r;
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	89 d8                	mov    %ebx,%eax
}
  800f46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f56:	50                   	push   %eax
  800f57:	ff 75 08             	pushl  0x8(%ebp)
  800f5a:	e8 c4 fe ff ff       	call   800e23 <fd_lookup>
  800f5f:	83 c4 08             	add    $0x8,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 10                	js     800f76 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f66:	83 ec 08             	sub    $0x8,%esp
  800f69:	6a 01                	push   $0x1
  800f6b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6e:	e8 59 ff ff ff       	call   800ecc <fd_close>
  800f73:	83 c4 10             	add    $0x10,%esp
}
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <close_all>:

void
close_all(void)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f7f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	53                   	push   %ebx
  800f88:	e8 c0 ff ff ff       	call   800f4d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f8d:	83 c3 01             	add    $0x1,%ebx
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	83 fb 20             	cmp    $0x20,%ebx
  800f96:	75 ec                	jne    800f84 <close_all+0xc>
		close(i);
}
  800f98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 2c             	sub    $0x2c,%esp
  800fa6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fa9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	ff 75 08             	pushl  0x8(%ebp)
  800fb0:	e8 6e fe ff ff       	call   800e23 <fd_lookup>
  800fb5:	83 c4 08             	add    $0x8,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	0f 88 c1 00 00 00    	js     801081 <dup+0xe4>
		return r;
	close(newfdnum);
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	56                   	push   %esi
  800fc4:	e8 84 ff ff ff       	call   800f4d <close>

	newfd = INDEX2FD(newfdnum);
  800fc9:	89 f3                	mov    %esi,%ebx
  800fcb:	c1 e3 0c             	shl    $0xc,%ebx
  800fce:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fd4:	83 c4 04             	add    $0x4,%esp
  800fd7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fda:	e8 de fd ff ff       	call   800dbd <fd2data>
  800fdf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fe1:	89 1c 24             	mov    %ebx,(%esp)
  800fe4:	e8 d4 fd ff ff       	call   800dbd <fd2data>
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fef:	89 f8                	mov    %edi,%eax
  800ff1:	c1 e8 16             	shr    $0x16,%eax
  800ff4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffb:	a8 01                	test   $0x1,%al
  800ffd:	74 37                	je     801036 <dup+0x99>
  800fff:	89 f8                	mov    %edi,%eax
  801001:	c1 e8 0c             	shr    $0xc,%eax
  801004:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100b:	f6 c2 01             	test   $0x1,%dl
  80100e:	74 26                	je     801036 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801010:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	25 07 0e 00 00       	and    $0xe07,%eax
  80101f:	50                   	push   %eax
  801020:	ff 75 d4             	pushl  -0x2c(%ebp)
  801023:	6a 00                	push   $0x0
  801025:	57                   	push   %edi
  801026:	6a 00                	push   $0x0
  801028:	e8 b2 fb ff ff       	call   800bdf <sys_page_map>
  80102d:	89 c7                	mov    %eax,%edi
  80102f:	83 c4 20             	add    $0x20,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	78 2e                	js     801064 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801036:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801039:	89 d0                	mov    %edx,%eax
  80103b:	c1 e8 0c             	shr    $0xc,%eax
  80103e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	25 07 0e 00 00       	and    $0xe07,%eax
  80104d:	50                   	push   %eax
  80104e:	53                   	push   %ebx
  80104f:	6a 00                	push   $0x0
  801051:	52                   	push   %edx
  801052:	6a 00                	push   $0x0
  801054:	e8 86 fb ff ff       	call   800bdf <sys_page_map>
  801059:	89 c7                	mov    %eax,%edi
  80105b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80105e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801060:	85 ff                	test   %edi,%edi
  801062:	79 1d                	jns    801081 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	53                   	push   %ebx
  801068:	6a 00                	push   $0x0
  80106a:	e8 b2 fb ff ff       	call   800c21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106f:	83 c4 08             	add    $0x8,%esp
  801072:	ff 75 d4             	pushl  -0x2c(%ebp)
  801075:	6a 00                	push   $0x0
  801077:	e8 a5 fb ff ff       	call   800c21 <sys_page_unmap>
	return r;
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	89 f8                	mov    %edi,%eax
}
  801081:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5f                   	pop    %edi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	53                   	push   %ebx
  80108d:	83 ec 14             	sub    $0x14,%esp
  801090:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801093:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801096:	50                   	push   %eax
  801097:	53                   	push   %ebx
  801098:	e8 86 fd ff ff       	call   800e23 <fd_lookup>
  80109d:	83 c4 08             	add    $0x8,%esp
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	78 6d                	js     801113 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ac:	50                   	push   %eax
  8010ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b0:	ff 30                	pushl  (%eax)
  8010b2:	e8 c2 fd ff ff       	call   800e79 <dev_lookup>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 4c                	js     80110a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010c1:	8b 42 08             	mov    0x8(%edx),%eax
  8010c4:	83 e0 03             	and    $0x3,%eax
  8010c7:	83 f8 01             	cmp    $0x1,%eax
  8010ca:	75 21                	jne    8010ed <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d1:	8b 40 50             	mov    0x50(%eax),%eax
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	53                   	push   %ebx
  8010d8:	50                   	push   %eax
  8010d9:	68 6d 28 80 00       	push   $0x80286d
  8010de:	e8 31 f1 ff ff       	call   800214 <cprintf>
		return -E_INVAL;
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010eb:	eb 26                	jmp    801113 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f0:	8b 40 08             	mov    0x8(%eax),%eax
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	74 17                	je     80110e <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	ff 75 10             	pushl  0x10(%ebp)
  8010fd:	ff 75 0c             	pushl  0xc(%ebp)
  801100:	52                   	push   %edx
  801101:	ff d0                	call   *%eax
  801103:	89 c2                	mov    %eax,%edx
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	eb 09                	jmp    801113 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110a:	89 c2                	mov    %eax,%edx
  80110c:	eb 05                	jmp    801113 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80110e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801113:	89 d0                	mov    %edx,%eax
  801115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	8b 7d 08             	mov    0x8(%ebp),%edi
  801126:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801129:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112e:	eb 21                	jmp    801151 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	89 f0                	mov    %esi,%eax
  801135:	29 d8                	sub    %ebx,%eax
  801137:	50                   	push   %eax
  801138:	89 d8                	mov    %ebx,%eax
  80113a:	03 45 0c             	add    0xc(%ebp),%eax
  80113d:	50                   	push   %eax
  80113e:	57                   	push   %edi
  80113f:	e8 45 ff ff ff       	call   801089 <read>
		if (m < 0)
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	78 10                	js     80115b <readn+0x41>
			return m;
		if (m == 0)
  80114b:	85 c0                	test   %eax,%eax
  80114d:	74 0a                	je     801159 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114f:	01 c3                	add    %eax,%ebx
  801151:	39 f3                	cmp    %esi,%ebx
  801153:	72 db                	jb     801130 <readn+0x16>
  801155:	89 d8                	mov    %ebx,%eax
  801157:	eb 02                	jmp    80115b <readn+0x41>
  801159:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80115b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5e                   	pop    %esi
  801160:	5f                   	pop    %edi
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	53                   	push   %ebx
  801167:	83 ec 14             	sub    $0x14,%esp
  80116a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801170:	50                   	push   %eax
  801171:	53                   	push   %ebx
  801172:	e8 ac fc ff ff       	call   800e23 <fd_lookup>
  801177:	83 c4 08             	add    $0x8,%esp
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 68                	js     8011e8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801186:	50                   	push   %eax
  801187:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118a:	ff 30                	pushl  (%eax)
  80118c:	e8 e8 fc ff ff       	call   800e79 <dev_lookup>
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	85 c0                	test   %eax,%eax
  801196:	78 47                	js     8011df <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801198:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80119f:	75 21                	jne    8011c2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a6:	8b 40 50             	mov    0x50(%eax),%eax
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	53                   	push   %ebx
  8011ad:	50                   	push   %eax
  8011ae:	68 89 28 80 00       	push   $0x802889
  8011b3:	e8 5c f0 ff ff       	call   800214 <cprintf>
		return -E_INVAL;
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c0:	eb 26                	jmp    8011e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c5:	8b 52 0c             	mov    0xc(%edx),%edx
  8011c8:	85 d2                	test   %edx,%edx
  8011ca:	74 17                	je     8011e3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	ff 75 10             	pushl  0x10(%ebp)
  8011d2:	ff 75 0c             	pushl  0xc(%ebp)
  8011d5:	50                   	push   %eax
  8011d6:	ff d2                	call   *%edx
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	eb 09                	jmp    8011e8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	eb 05                	jmp    8011e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011e8:	89 d0                	mov    %edx,%eax
  8011ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 22 fc ff ff       	call   800e23 <fd_lookup>
  801201:	83 c4 08             	add    $0x8,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 0e                	js     801216 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801208:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80120b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	53                   	push   %ebx
  80121c:	83 ec 14             	sub    $0x14,%esp
  80121f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801222:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	53                   	push   %ebx
  801227:	e8 f7 fb ff ff       	call   800e23 <fd_lookup>
  80122c:	83 c4 08             	add    $0x8,%esp
  80122f:	89 c2                	mov    %eax,%edx
  801231:	85 c0                	test   %eax,%eax
  801233:	78 65                	js     80129a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801235:	83 ec 08             	sub    $0x8,%esp
  801238:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	ff 30                	pushl  (%eax)
  801241:	e8 33 fc ff ff       	call   800e79 <dev_lookup>
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 44                	js     801291 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801250:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801254:	75 21                	jne    801277 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801256:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80125b:	8b 40 50             	mov    0x50(%eax),%eax
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	53                   	push   %ebx
  801262:	50                   	push   %eax
  801263:	68 4c 28 80 00       	push   $0x80284c
  801268:	e8 a7 ef ff ff       	call   800214 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801275:	eb 23                	jmp    80129a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801277:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127a:	8b 52 18             	mov    0x18(%edx),%edx
  80127d:	85 d2                	test   %edx,%edx
  80127f:	74 14                	je     801295 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	ff 75 0c             	pushl  0xc(%ebp)
  801287:	50                   	push   %eax
  801288:	ff d2                	call   *%edx
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	eb 09                	jmp    80129a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801291:	89 c2                	mov    %eax,%edx
  801293:	eb 05                	jmp    80129a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801295:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80129a:	89 d0                	mov    %edx,%eax
  80129c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129f:	c9                   	leave  
  8012a0:	c3                   	ret    

008012a1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 14             	sub    $0x14,%esp
  8012a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	ff 75 08             	pushl  0x8(%ebp)
  8012b2:	e8 6c fb ff ff       	call   800e23 <fd_lookup>
  8012b7:	83 c4 08             	add    $0x8,%esp
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 58                	js     801318 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c6:	50                   	push   %eax
  8012c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ca:	ff 30                	pushl  (%eax)
  8012cc:	e8 a8 fb ff ff       	call   800e79 <dev_lookup>
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 37                	js     80130f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012db:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012df:	74 32                	je     801313 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012e1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012e4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012eb:	00 00 00 
	stat->st_isdir = 0;
  8012ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012f5:	00 00 00 
	stat->st_dev = dev;
  8012f8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	53                   	push   %ebx
  801302:	ff 75 f0             	pushl  -0x10(%ebp)
  801305:	ff 50 14             	call   *0x14(%eax)
  801308:	89 c2                	mov    %eax,%edx
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	eb 09                	jmp    801318 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130f:	89 c2                	mov    %eax,%edx
  801311:	eb 05                	jmp    801318 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801313:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801318:	89 d0                	mov    %edx,%eax
  80131a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	56                   	push   %esi
  801323:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	6a 00                	push   $0x0
  801329:	ff 75 08             	pushl  0x8(%ebp)
  80132c:	e8 e3 01 00 00       	call   801514 <open>
  801331:	89 c3                	mov    %eax,%ebx
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 1b                	js     801355 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	ff 75 0c             	pushl  0xc(%ebp)
  801340:	50                   	push   %eax
  801341:	e8 5b ff ff ff       	call   8012a1 <fstat>
  801346:	89 c6                	mov    %eax,%esi
	close(fd);
  801348:	89 1c 24             	mov    %ebx,(%esp)
  80134b:	e8 fd fb ff ff       	call   800f4d <close>
	return r;
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	89 f0                	mov    %esi,%eax
}
  801355:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801358:	5b                   	pop    %ebx
  801359:	5e                   	pop    %esi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	56                   	push   %esi
  801360:	53                   	push   %ebx
  801361:	89 c6                	mov    %eax,%esi
  801363:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801365:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80136c:	75 12                	jne    801380 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	6a 01                	push   $0x1
  801373:	e8 d8 0d 00 00       	call   802150 <ipc_find_env>
  801378:	a3 00 40 80 00       	mov    %eax,0x804000
  80137d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801380:	6a 07                	push   $0x7
  801382:	68 00 50 80 00       	push   $0x805000
  801387:	56                   	push   %esi
  801388:	ff 35 00 40 80 00    	pushl  0x804000
  80138e:	e8 5b 0d 00 00       	call   8020ee <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801393:	83 c4 0c             	add    $0xc,%esp
  801396:	6a 00                	push   $0x0
  801398:	53                   	push   %ebx
  801399:	6a 00                	push   $0x0
  80139b:	e8 d9 0c 00 00       	call   802079 <ipc_recv>
}
  8013a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a3:	5b                   	pop    %ebx
  8013a4:	5e                   	pop    %esi
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c5:	b8 02 00 00 00       	mov    $0x2,%eax
  8013ca:	e8 8d ff ff ff       	call   80135c <fsipc>
}
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    

008013d1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013da:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e7:	b8 06 00 00 00       	mov    $0x6,%eax
  8013ec:	e8 6b ff ff ff       	call   80135c <fsipc>
}
  8013f1:	c9                   	leave  
  8013f2:	c3                   	ret    

008013f3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	53                   	push   %ebx
  8013f7:	83 ec 04             	sub    $0x4,%esp
  8013fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801400:	8b 40 0c             	mov    0xc(%eax),%eax
  801403:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801408:	ba 00 00 00 00       	mov    $0x0,%edx
  80140d:	b8 05 00 00 00       	mov    $0x5,%eax
  801412:	e8 45 ff ff ff       	call   80135c <fsipc>
  801417:	85 c0                	test   %eax,%eax
  801419:	78 2c                	js     801447 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	68 00 50 80 00       	push   $0x805000
  801423:	53                   	push   %ebx
  801424:	e8 70 f3 ff ff       	call   800799 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801429:	a1 80 50 80 00       	mov    0x805080,%eax
  80142e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801434:	a1 84 50 80 00       	mov    0x805084,%eax
  801439:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801447:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 0c             	sub    $0xc,%esp
  801452:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801455:	8b 55 08             	mov    0x8(%ebp),%edx
  801458:	8b 52 0c             	mov    0xc(%edx),%edx
  80145b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801461:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801466:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80146b:	0f 47 c2             	cmova  %edx,%eax
  80146e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801473:	50                   	push   %eax
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	68 08 50 80 00       	push   $0x805008
  80147c:	e8 aa f4 ff ff       	call   80092b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801481:	ba 00 00 00 00       	mov    $0x0,%edx
  801486:	b8 04 00 00 00       	mov    $0x4,%eax
  80148b:	e8 cc fe ff ff       	call   80135c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801490:	c9                   	leave  
  801491:	c3                   	ret    

00801492 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	56                   	push   %esi
  801496:	53                   	push   %ebx
  801497:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b5:	e8 a2 fe ff ff       	call   80135c <fsipc>
  8014ba:	89 c3                	mov    %eax,%ebx
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 4b                	js     80150b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014c0:	39 c6                	cmp    %eax,%esi
  8014c2:	73 16                	jae    8014da <devfile_read+0x48>
  8014c4:	68 b8 28 80 00       	push   $0x8028b8
  8014c9:	68 bf 28 80 00       	push   $0x8028bf
  8014ce:	6a 7c                	push   $0x7c
  8014d0:	68 d4 28 80 00       	push   $0x8028d4
  8014d5:	e8 61 ec ff ff       	call   80013b <_panic>
	assert(r <= PGSIZE);
  8014da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014df:	7e 16                	jle    8014f7 <devfile_read+0x65>
  8014e1:	68 df 28 80 00       	push   $0x8028df
  8014e6:	68 bf 28 80 00       	push   $0x8028bf
  8014eb:	6a 7d                	push   $0x7d
  8014ed:	68 d4 28 80 00       	push   $0x8028d4
  8014f2:	e8 44 ec ff ff       	call   80013b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014f7:	83 ec 04             	sub    $0x4,%esp
  8014fa:	50                   	push   %eax
  8014fb:	68 00 50 80 00       	push   $0x805000
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	e8 23 f4 ff ff       	call   80092b <memmove>
	return r;
  801508:	83 c4 10             	add    $0x10,%esp
}
  80150b:	89 d8                	mov    %ebx,%eax
  80150d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5d                   	pop    %ebp
  801513:	c3                   	ret    

00801514 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	53                   	push   %ebx
  801518:	83 ec 20             	sub    $0x20,%esp
  80151b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80151e:	53                   	push   %ebx
  80151f:	e8 3c f2 ff ff       	call   800760 <strlen>
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80152c:	7f 67                	jg     801595 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	e8 9a f8 ff ff       	call   800dd4 <fd_alloc>
  80153a:	83 c4 10             	add    $0x10,%esp
		return r;
  80153d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 57                	js     80159a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	53                   	push   %ebx
  801547:	68 00 50 80 00       	push   $0x805000
  80154c:	e8 48 f2 ff ff       	call   800799 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801551:	8b 45 0c             	mov    0xc(%ebp),%eax
  801554:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801559:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155c:	b8 01 00 00 00       	mov    $0x1,%eax
  801561:	e8 f6 fd ff ff       	call   80135c <fsipc>
  801566:	89 c3                	mov    %eax,%ebx
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	79 14                	jns    801583 <open+0x6f>
		fd_close(fd, 0);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	6a 00                	push   $0x0
  801574:	ff 75 f4             	pushl  -0xc(%ebp)
  801577:	e8 50 f9 ff ff       	call   800ecc <fd_close>
		return r;
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	89 da                	mov    %ebx,%edx
  801581:	eb 17                	jmp    80159a <open+0x86>
	}

	return fd2num(fd);
  801583:	83 ec 0c             	sub    $0xc,%esp
  801586:	ff 75 f4             	pushl  -0xc(%ebp)
  801589:	e8 1f f8 ff ff       	call   800dad <fd2num>
  80158e:	89 c2                	mov    %eax,%edx
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	eb 05                	jmp    80159a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801595:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80159a:	89 d0                	mov    %edx,%eax
  80159c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8015b1:	e8 a6 fd ff ff       	call   80135c <fsipc>
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	57                   	push   %edi
  8015bc:	56                   	push   %esi
  8015bd:	53                   	push   %ebx
  8015be:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015c4:	6a 00                	push   $0x0
  8015c6:	ff 75 08             	pushl  0x8(%ebp)
  8015c9:	e8 46 ff ff ff       	call   801514 <open>
  8015ce:	89 c7                	mov    %eax,%edi
  8015d0:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	0f 88 89 04 00 00    	js     801a6a <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	68 00 02 00 00       	push   $0x200
  8015e9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	57                   	push   %edi
  8015f1:	e8 24 fb ff ff       	call   80111a <readn>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015fe:	75 0c                	jne    80160c <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801600:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801607:	45 4c 46 
  80160a:	74 33                	je     80163f <spawn+0x87>
		close(fd);
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801615:	e8 33 f9 ff ff       	call   800f4d <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80161a:	83 c4 0c             	add    $0xc,%esp
  80161d:	68 7f 45 4c 46       	push   $0x464c457f
  801622:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801628:	68 eb 28 80 00       	push   $0x8028eb
  80162d:	e8 e2 eb ff ff       	call   800214 <cprintf>
		return -E_NOT_EXEC;
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80163a:	e9 de 04 00 00       	jmp    801b1d <spawn+0x565>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80163f:	b8 07 00 00 00       	mov    $0x7,%eax
  801644:	cd 30                	int    $0x30
  801646:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80164c:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801652:	85 c0                	test   %eax,%eax
  801654:	0f 88 1b 04 00 00    	js     801a75 <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80165a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80165f:	89 c2                	mov    %eax,%edx
  801661:	c1 e2 07             	shl    $0x7,%edx
  801664:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80166a:	8d b4 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%esi
  801671:	b9 11 00 00 00       	mov    $0x11,%ecx
  801676:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801678:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80167e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801684:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801689:	be 00 00 00 00       	mov    $0x0,%esi
  80168e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801691:	eb 13                	jmp    8016a6 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	50                   	push   %eax
  801697:	e8 c4 f0 ff ff       	call   800760 <strlen>
  80169c:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016a0:	83 c3 01             	add    $0x1,%ebx
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016ad:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	75 df                	jne    801693 <spawn+0xdb>
  8016b4:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016ba:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016c0:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016c5:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016c7:	89 fa                	mov    %edi,%edx
  8016c9:	83 e2 fc             	and    $0xfffffffc,%edx
  8016cc:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016d3:	29 c2                	sub    %eax,%edx
  8016d5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016db:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016de:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016e3:	0f 86 a2 03 00 00    	jbe    801a8b <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016e9:	83 ec 04             	sub    $0x4,%esp
  8016ec:	6a 07                	push   $0x7
  8016ee:	68 00 00 40 00       	push   $0x400000
  8016f3:	6a 00                	push   $0x0
  8016f5:	e8 a2 f4 ff ff       	call   800b9c <sys_page_alloc>
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	0f 88 90 03 00 00    	js     801a95 <spawn+0x4dd>
  801705:	be 00 00 00 00       	mov    $0x0,%esi
  80170a:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801710:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801713:	eb 30                	jmp    801745 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801715:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80171b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801721:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80172a:	57                   	push   %edi
  80172b:	e8 69 f0 ff ff       	call   800799 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801730:	83 c4 04             	add    $0x4,%esp
  801733:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801736:	e8 25 f0 ff ff       	call   800760 <strlen>
  80173b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80173f:	83 c6 01             	add    $0x1,%esi
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80174b:	7f c8                	jg     801715 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80174d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801753:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801759:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801760:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801766:	74 19                	je     801781 <spawn+0x1c9>
  801768:	68 78 29 80 00       	push   $0x802978
  80176d:	68 bf 28 80 00       	push   $0x8028bf
  801772:	68 f2 00 00 00       	push   $0xf2
  801777:	68 05 29 80 00       	push   $0x802905
  80177c:	e8 ba e9 ff ff       	call   80013b <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801781:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801787:	89 f8                	mov    %edi,%eax
  801789:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80178e:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801791:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801797:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80179a:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8017a0:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	6a 07                	push   $0x7
  8017ab:	68 00 d0 bf ee       	push   $0xeebfd000
  8017b0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017b6:	68 00 00 40 00       	push   $0x400000
  8017bb:	6a 00                	push   $0x0
  8017bd:	e8 1d f4 ff ff       	call   800bdf <sys_page_map>
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	83 c4 20             	add    $0x20,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	0f 88 3c 03 00 00    	js     801b0b <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	68 00 00 40 00       	push   $0x400000
  8017d7:	6a 00                	push   $0x0
  8017d9:	e8 43 f4 ff ff       	call   800c21 <sys_page_unmap>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	0f 88 20 03 00 00    	js     801b0b <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017eb:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017f1:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017f8:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017fe:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801805:	00 00 00 
  801808:	e9 88 01 00 00       	jmp    801995 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80180d:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801813:	83 38 01             	cmpl   $0x1,(%eax)
  801816:	0f 85 6b 01 00 00    	jne    801987 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80181c:	89 c2                	mov    %eax,%edx
  80181e:	8b 40 18             	mov    0x18(%eax),%eax
  801821:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801827:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80182a:	83 f8 01             	cmp    $0x1,%eax
  80182d:	19 c0                	sbb    %eax,%eax
  80182f:	83 e0 fe             	and    $0xfffffffe,%eax
  801832:	83 c0 07             	add    $0x7,%eax
  801835:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80183b:	89 d0                	mov    %edx,%eax
  80183d:	8b 7a 04             	mov    0x4(%edx),%edi
  801840:	89 f9                	mov    %edi,%ecx
  801842:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801848:	8b 7a 10             	mov    0x10(%edx),%edi
  80184b:	8b 52 14             	mov    0x14(%edx),%edx
  80184e:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801854:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801857:	89 f0                	mov    %esi,%eax
  801859:	25 ff 0f 00 00       	and    $0xfff,%eax
  80185e:	74 14                	je     801874 <spawn+0x2bc>
		va -= i;
  801860:	29 c6                	sub    %eax,%esi
		memsz += i;
  801862:	01 c2                	add    %eax,%edx
  801864:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80186a:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80186c:	29 c1                	sub    %eax,%ecx
  80186e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801874:	bb 00 00 00 00       	mov    $0x0,%ebx
  801879:	e9 f7 00 00 00       	jmp    801975 <spawn+0x3bd>
		if (i >= filesz) {
  80187e:	39 fb                	cmp    %edi,%ebx
  801880:	72 27                	jb     8018a9 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801882:	83 ec 04             	sub    $0x4,%esp
  801885:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80188b:	56                   	push   %esi
  80188c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801892:	e8 05 f3 ff ff       	call   800b9c <sys_page_alloc>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	0f 89 c7 00 00 00    	jns    801969 <spawn+0x3b1>
  8018a2:	89 c3                	mov    %eax,%ebx
  8018a4:	e9 fd 01 00 00       	jmp    801aa6 <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018a9:	83 ec 04             	sub    $0x4,%esp
  8018ac:	6a 07                	push   $0x7
  8018ae:	68 00 00 40 00       	push   $0x400000
  8018b3:	6a 00                	push   $0x0
  8018b5:	e8 e2 f2 ff ff       	call   800b9c <sys_page_alloc>
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	0f 88 d7 01 00 00    	js     801a9c <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018ce:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8018d4:	50                   	push   %eax
  8018d5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018db:	e8 0f f9 ff ff       	call   8011ef <seek>
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	0f 88 b5 01 00 00    	js     801aa0 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018eb:	83 ec 04             	sub    $0x4,%esp
  8018ee:	89 f8                	mov    %edi,%eax
  8018f0:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018f6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018fb:	ba 00 10 00 00       	mov    $0x1000,%edx
  801900:	0f 47 c2             	cmova  %edx,%eax
  801903:	50                   	push   %eax
  801904:	68 00 00 40 00       	push   $0x400000
  801909:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80190f:	e8 06 f8 ff ff       	call   80111a <readn>
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	85 c0                	test   %eax,%eax
  801919:	0f 88 85 01 00 00    	js     801aa4 <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80191f:	83 ec 0c             	sub    $0xc,%esp
  801922:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801928:	56                   	push   %esi
  801929:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80192f:	68 00 00 40 00       	push   $0x400000
  801934:	6a 00                	push   $0x0
  801936:	e8 a4 f2 ff ff       	call   800bdf <sys_page_map>
  80193b:	83 c4 20             	add    $0x20,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	79 15                	jns    801957 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801942:	50                   	push   %eax
  801943:	68 11 29 80 00       	push   $0x802911
  801948:	68 25 01 00 00       	push   $0x125
  80194d:	68 05 29 80 00       	push   $0x802905
  801952:	e8 e4 e7 ff ff       	call   80013b <_panic>
			sys_page_unmap(0, UTEMP);
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	68 00 00 40 00       	push   $0x400000
  80195f:	6a 00                	push   $0x0
  801961:	e8 bb f2 ff ff       	call   800c21 <sys_page_unmap>
  801966:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801969:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80196f:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801975:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80197b:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801981:	0f 82 f7 fe ff ff    	jb     80187e <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801987:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80198e:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801995:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80199c:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019a2:	0f 8c 65 fe ff ff    	jl     80180d <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019b1:	e8 97 f5 ff ff       	call   800f4d <close>
  8019b6:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  8019b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019be:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  8019c4:	89 d8                	mov    %ebx,%eax
  8019c6:	c1 e8 16             	shr    $0x16,%eax
  8019c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019d0:	a8 01                	test   $0x1,%al
  8019d2:	74 42                	je     801a16 <spawn+0x45e>
  8019d4:	89 d8                	mov    %ebx,%eax
  8019d6:	c1 e8 0c             	shr    $0xc,%eax
  8019d9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019e0:	f6 c2 01             	test   $0x1,%dl
  8019e3:	74 31                	je     801a16 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  8019e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  8019ec:	f6 c6 04             	test   $0x4,%dh
  8019ef:	74 25                	je     801a16 <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  8019f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019f8:	83 ec 0c             	sub    $0xc,%esp
  8019fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801a00:	50                   	push   %eax
  801a01:	53                   	push   %ebx
  801a02:	56                   	push   %esi
  801a03:	53                   	push   %ebx
  801a04:	6a 00                	push   $0x0
  801a06:	e8 d4 f1 ff ff       	call   800bdf <sys_page_map>
			if (r < 0) {
  801a0b:	83 c4 20             	add    $0x20,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	0f 88 b1 00 00 00    	js     801ac7 <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801a16:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a1c:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a22:	75 a0                	jne    8019c4 <spawn+0x40c>
  801a24:	e9 b3 00 00 00       	jmp    801adc <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801a29:	50                   	push   %eax
  801a2a:	68 2e 29 80 00       	push   $0x80292e
  801a2f:	68 86 00 00 00       	push   $0x86
  801a34:	68 05 29 80 00       	push   $0x802905
  801a39:	e8 fd e6 ff ff       	call   80013b <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a3e:	83 ec 08             	sub    $0x8,%esp
  801a41:	6a 02                	push   $0x2
  801a43:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a49:	e8 15 f2 ff ff       	call   800c63 <sys_env_set_status>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	79 2b                	jns    801a80 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801a55:	50                   	push   %eax
  801a56:	68 48 29 80 00       	push   $0x802948
  801a5b:	68 89 00 00 00       	push   $0x89
  801a60:	68 05 29 80 00       	push   $0x802905
  801a65:	e8 d1 e6 ff ff       	call   80013b <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a6a:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a70:	e9 a8 00 00 00       	jmp    801b1d <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a75:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a7b:	e9 9d 00 00 00       	jmp    801b1d <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a80:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a86:	e9 92 00 00 00       	jmp    801b1d <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a8b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a90:	e9 88 00 00 00       	jmp    801b1d <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a95:	89 c3                	mov    %eax,%ebx
  801a97:	e9 81 00 00 00       	jmp    801b1d <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a9c:	89 c3                	mov    %eax,%ebx
  801a9e:	eb 06                	jmp    801aa6 <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801aa0:	89 c3                	mov    %eax,%ebx
  801aa2:	eb 02                	jmp    801aa6 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801aa4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aaf:	e8 69 f0 ff ff       	call   800b1d <sys_env_destroy>
	close(fd);
  801ab4:	83 c4 04             	add    $0x4,%esp
  801ab7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801abd:	e8 8b f4 ff ff       	call   800f4d <close>
	return r;
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	eb 56                	jmp    801b1d <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801ac7:	50                   	push   %eax
  801ac8:	68 5f 29 80 00       	push   $0x80295f
  801acd:	68 82 00 00 00       	push   $0x82
  801ad2:	68 05 29 80 00       	push   $0x802905
  801ad7:	e8 5f e6 ff ff       	call   80013b <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801adc:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ae3:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801af6:	e8 aa f1 ff ff       	call   800ca5 <sys_env_set_trapframe>
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	85 c0                	test   %eax,%eax
  801b00:	0f 89 38 ff ff ff    	jns    801a3e <spawn+0x486>
  801b06:	e9 1e ff ff ff       	jmp    801a29 <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b0b:	83 ec 08             	sub    $0x8,%esp
  801b0e:	68 00 00 40 00       	push   $0x400000
  801b13:	6a 00                	push   $0x0
  801b15:	e8 07 f1 ff ff       	call   800c21 <sys_page_unmap>
  801b1a:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b1d:	89 d8                	mov    %ebx,%eax
  801b1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5f                   	pop    %edi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b2c:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b34:	eb 03                	jmp    801b39 <spawnl+0x12>
		argc++;
  801b36:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b39:	83 c2 04             	add    $0x4,%edx
  801b3c:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b40:	75 f4                	jne    801b36 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b42:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b49:	83 e2 f0             	and    $0xfffffff0,%edx
  801b4c:	29 d4                	sub    %edx,%esp
  801b4e:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b52:	c1 ea 02             	shr    $0x2,%edx
  801b55:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b5c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b61:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b68:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b6f:	00 
  801b70:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
  801b77:	eb 0a                	jmp    801b83 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b79:	83 c0 01             	add    $0x1,%eax
  801b7c:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b80:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b83:	39 d0                	cmp    %edx,%eax
  801b85:	75 f2                	jne    801b79 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b87:	83 ec 08             	sub    $0x8,%esp
  801b8a:	56                   	push   %esi
  801b8b:	ff 75 08             	pushl  0x8(%ebp)
  801b8e:	e8 25 fa ff ff       	call   8015b8 <spawn>
}
  801b93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5e                   	pop    %esi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	56                   	push   %esi
  801b9e:	53                   	push   %ebx
  801b9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	ff 75 08             	pushl  0x8(%ebp)
  801ba8:	e8 10 f2 ff ff       	call   800dbd <fd2data>
  801bad:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801baf:	83 c4 08             	add    $0x8,%esp
  801bb2:	68 a0 29 80 00       	push   $0x8029a0
  801bb7:	53                   	push   %ebx
  801bb8:	e8 dc eb ff ff       	call   800799 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bbd:	8b 46 04             	mov    0x4(%esi),%eax
  801bc0:	2b 06                	sub    (%esi),%eax
  801bc2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bc8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bcf:	00 00 00 
	stat->st_dev = &devpipe;
  801bd2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bd9:	30 80 00 
	return 0;
}
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  801be1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	53                   	push   %ebx
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bf2:	53                   	push   %ebx
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 27 f0 ff ff       	call   800c21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bfa:	89 1c 24             	mov    %ebx,(%esp)
  801bfd:	e8 bb f1 ff ff       	call   800dbd <fd2data>
  801c02:	83 c4 08             	add    $0x8,%esp
  801c05:	50                   	push   %eax
  801c06:	6a 00                	push   $0x0
  801c08:	e8 14 f0 ff ff       	call   800c21 <sys_page_unmap>
}
  801c0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c10:	c9                   	leave  
  801c11:	c3                   	ret    

00801c12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	57                   	push   %edi
  801c16:	56                   	push   %esi
  801c17:	53                   	push   %ebx
  801c18:	83 ec 1c             	sub    $0x1c,%esp
  801c1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c1e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c20:	a1 04 40 80 00       	mov    0x804004,%eax
  801c25:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c28:	83 ec 0c             	sub    $0xc,%esp
  801c2b:	ff 75 e0             	pushl  -0x20(%ebp)
  801c2e:	e8 5d 05 00 00       	call   802190 <pageref>
  801c33:	89 c3                	mov    %eax,%ebx
  801c35:	89 3c 24             	mov    %edi,(%esp)
  801c38:	e8 53 05 00 00       	call   802190 <pageref>
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	39 c3                	cmp    %eax,%ebx
  801c42:	0f 94 c1             	sete   %cl
  801c45:	0f b6 c9             	movzbl %cl,%ecx
  801c48:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c4b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c51:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801c54:	39 ce                	cmp    %ecx,%esi
  801c56:	74 1b                	je     801c73 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c58:	39 c3                	cmp    %eax,%ebx
  801c5a:	75 c4                	jne    801c20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c5c:	8b 42 60             	mov    0x60(%edx),%eax
  801c5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c62:	50                   	push   %eax
  801c63:	56                   	push   %esi
  801c64:	68 a7 29 80 00       	push   $0x8029a7
  801c69:	e8 a6 e5 ff ff       	call   800214 <cprintf>
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	eb ad                	jmp    801c20 <_pipeisclosed+0xe>
	}
}
  801c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 28             	sub    $0x28,%esp
  801c87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c8a:	56                   	push   %esi
  801c8b:	e8 2d f1 ff ff       	call   800dbd <fd2data>
  801c90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	bf 00 00 00 00       	mov    $0x0,%edi
  801c9a:	eb 4b                	jmp    801ce7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c9c:	89 da                	mov    %ebx,%edx
  801c9e:	89 f0                	mov    %esi,%eax
  801ca0:	e8 6d ff ff ff       	call   801c12 <_pipeisclosed>
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	75 48                	jne    801cf1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ca9:	e8 cf ee ff ff       	call   800b7d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cae:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb1:	8b 0b                	mov    (%ebx),%ecx
  801cb3:	8d 51 20             	lea    0x20(%ecx),%edx
  801cb6:	39 d0                	cmp    %edx,%eax
  801cb8:	73 e2                	jae    801c9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cbd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cc1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cc4:	89 c2                	mov    %eax,%edx
  801cc6:	c1 fa 1f             	sar    $0x1f,%edx
  801cc9:	89 d1                	mov    %edx,%ecx
  801ccb:	c1 e9 1b             	shr    $0x1b,%ecx
  801cce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cd1:	83 e2 1f             	and    $0x1f,%edx
  801cd4:	29 ca                	sub    %ecx,%edx
  801cd6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cde:	83 c0 01             	add    $0x1,%eax
  801ce1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce4:	83 c7 01             	add    $0x1,%edi
  801ce7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cea:	75 c2                	jne    801cae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cec:	8b 45 10             	mov    0x10(%ebp),%eax
  801cef:	eb 05                	jmp    801cf6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 18             	sub    $0x18,%esp
  801d07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d0a:	57                   	push   %edi
  801d0b:	e8 ad f0 ff ff       	call   800dbd <fd2data>
  801d10:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d1a:	eb 3d                	jmp    801d59 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d1c:	85 db                	test   %ebx,%ebx
  801d1e:	74 04                	je     801d24 <devpipe_read+0x26>
				return i;
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	eb 44                	jmp    801d68 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d24:	89 f2                	mov    %esi,%edx
  801d26:	89 f8                	mov    %edi,%eax
  801d28:	e8 e5 fe ff ff       	call   801c12 <_pipeisclosed>
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	75 32                	jne    801d63 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d31:	e8 47 ee ff ff       	call   800b7d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d36:	8b 06                	mov    (%esi),%eax
  801d38:	3b 46 04             	cmp    0x4(%esi),%eax
  801d3b:	74 df                	je     801d1c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3d:	99                   	cltd   
  801d3e:	c1 ea 1b             	shr    $0x1b,%edx
  801d41:	01 d0                	add    %edx,%eax
  801d43:	83 e0 1f             	and    $0x1f,%eax
  801d46:	29 d0                	sub    %edx,%eax
  801d48:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d50:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d53:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d56:	83 c3 01             	add    $0x1,%ebx
  801d59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d5c:	75 d8                	jne    801d36 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d5e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d61:	eb 05                	jmp    801d68 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d63:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6b:	5b                   	pop    %ebx
  801d6c:	5e                   	pop    %esi
  801d6d:	5f                   	pop    %edi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	56                   	push   %esi
  801d74:	53                   	push   %ebx
  801d75:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d7b:	50                   	push   %eax
  801d7c:	e8 53 f0 ff ff       	call   800dd4 <fd_alloc>
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	89 c2                	mov    %eax,%edx
  801d86:	85 c0                	test   %eax,%eax
  801d88:	0f 88 2c 01 00 00    	js     801eba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8e:	83 ec 04             	sub    $0x4,%esp
  801d91:	68 07 04 00 00       	push   $0x407
  801d96:	ff 75 f4             	pushl  -0xc(%ebp)
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 fc ed ff ff       	call   800b9c <sys_page_alloc>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	89 c2                	mov    %eax,%edx
  801da5:	85 c0                	test   %eax,%eax
  801da7:	0f 88 0d 01 00 00    	js     801eba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801dad:	83 ec 0c             	sub    $0xc,%esp
  801db0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	e8 1b f0 ff ff       	call   800dd4 <fd_alloc>
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	0f 88 e2 00 00 00    	js     801ea8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc6:	83 ec 04             	sub    $0x4,%esp
  801dc9:	68 07 04 00 00       	push   $0x407
  801dce:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 c4 ed ff ff       	call   800b9c <sys_page_alloc>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	0f 88 c3 00 00 00    	js     801ea8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	ff 75 f4             	pushl  -0xc(%ebp)
  801deb:	e8 cd ef ff ff       	call   800dbd <fd2data>
  801df0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df2:	83 c4 0c             	add    $0xc,%esp
  801df5:	68 07 04 00 00       	push   $0x407
  801dfa:	50                   	push   %eax
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 9a ed ff ff       	call   800b9c <sys_page_alloc>
  801e02:	89 c3                	mov    %eax,%ebx
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	85 c0                	test   %eax,%eax
  801e09:	0f 88 89 00 00 00    	js     801e98 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0f:	83 ec 0c             	sub    $0xc,%esp
  801e12:	ff 75 f0             	pushl  -0x10(%ebp)
  801e15:	e8 a3 ef ff ff       	call   800dbd <fd2data>
  801e1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e21:	50                   	push   %eax
  801e22:	6a 00                	push   $0x0
  801e24:	56                   	push   %esi
  801e25:	6a 00                	push   $0x0
  801e27:	e8 b3 ed ff ff       	call   800bdf <sys_page_map>
  801e2c:	89 c3                	mov    %eax,%ebx
  801e2e:	83 c4 20             	add    $0x20,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 55                	js     801e8a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e53:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e5f:	83 ec 0c             	sub    $0xc,%esp
  801e62:	ff 75 f4             	pushl  -0xc(%ebp)
  801e65:	e8 43 ef ff ff       	call   800dad <fd2num>
  801e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e6f:	83 c4 04             	add    $0x4,%esp
  801e72:	ff 75 f0             	pushl  -0x10(%ebp)
  801e75:	e8 33 ef ff ff       	call   800dad <fd2num>
  801e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e7d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	ba 00 00 00 00       	mov    $0x0,%edx
  801e88:	eb 30                	jmp    801eba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e8a:	83 ec 08             	sub    $0x8,%esp
  801e8d:	56                   	push   %esi
  801e8e:	6a 00                	push   $0x0
  801e90:	e8 8c ed ff ff       	call   800c21 <sys_page_unmap>
  801e95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e98:	83 ec 08             	sub    $0x8,%esp
  801e9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9e:	6a 00                	push   $0x0
  801ea0:	e8 7c ed ff ff       	call   800c21 <sys_page_unmap>
  801ea5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ea8:	83 ec 08             	sub    $0x8,%esp
  801eab:	ff 75 f4             	pushl  -0xc(%ebp)
  801eae:	6a 00                	push   $0x0
  801eb0:	e8 6c ed ff ff       	call   800c21 <sys_page_unmap>
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801eba:	89 d0                	mov    %edx,%eax
  801ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecc:	50                   	push   %eax
  801ecd:	ff 75 08             	pushl  0x8(%ebp)
  801ed0:	e8 4e ef ff ff       	call   800e23 <fd_lookup>
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 18                	js     801ef4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801edc:	83 ec 0c             	sub    $0xc,%esp
  801edf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee2:	e8 d6 ee ff ff       	call   800dbd <fd2data>
	return _pipeisclosed(fd, p);
  801ee7:	89 c2                	mov    %eax,%edx
  801ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eec:	e8 21 fd ff ff       	call   801c12 <_pipeisclosed>
  801ef1:	83 c4 10             	add    $0x10,%esp
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f06:	68 bf 29 80 00       	push   $0x8029bf
  801f0b:	ff 75 0c             	pushl  0xc(%ebp)
  801f0e:	e8 86 e8 ff ff       	call   800799 <strcpy>
	return 0;
}
  801f13:	b8 00 00 00 00       	mov    $0x0,%eax
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    

00801f1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	57                   	push   %edi
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f26:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f31:	eb 2d                	jmp    801f60 <devcons_write+0x46>
		m = n - tot;
  801f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f36:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f38:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f40:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f43:	83 ec 04             	sub    $0x4,%esp
  801f46:	53                   	push   %ebx
  801f47:	03 45 0c             	add    0xc(%ebp),%eax
  801f4a:	50                   	push   %eax
  801f4b:	57                   	push   %edi
  801f4c:	e8 da e9 ff ff       	call   80092b <memmove>
		sys_cputs(buf, m);
  801f51:	83 c4 08             	add    $0x8,%esp
  801f54:	53                   	push   %ebx
  801f55:	57                   	push   %edi
  801f56:	e8 85 eb ff ff       	call   800ae0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f5b:	01 de                	add    %ebx,%esi
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	89 f0                	mov    %esi,%eax
  801f62:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f65:	72 cc                	jb     801f33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5f                   	pop    %edi
  801f6d:	5d                   	pop    %ebp
  801f6e:	c3                   	ret    

00801f6f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 08             	sub    $0x8,%esp
  801f75:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f7e:	74 2a                	je     801faa <devcons_read+0x3b>
  801f80:	eb 05                	jmp    801f87 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f82:	e8 f6 eb ff ff       	call   800b7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f87:	e8 72 eb ff ff       	call   800afe <sys_cgetc>
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	74 f2                	je     801f82 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f90:	85 c0                	test   %eax,%eax
  801f92:	78 16                	js     801faa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f94:	83 f8 04             	cmp    $0x4,%eax
  801f97:	74 0c                	je     801fa5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f99:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f9c:	88 02                	mov    %al,(%edx)
	return 1;
  801f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa3:	eb 05                	jmp    801faa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fb8:	6a 01                	push   $0x1
  801fba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	e8 1d eb ff ff       	call   800ae0 <sys_cputs>
}
  801fc3:	83 c4 10             	add    $0x10,%esp
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <getchar>:

int
getchar(void)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fce:	6a 01                	push   $0x1
  801fd0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd3:	50                   	push   %eax
  801fd4:	6a 00                	push   $0x0
  801fd6:	e8 ae f0 ff ff       	call   801089 <read>
	if (r < 0)
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	78 0f                	js     801ff1 <getchar+0x29>
		return r;
	if (r < 1)
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	7e 06                	jle    801fec <getchar+0x24>
		return -E_EOF;
	return c;
  801fe6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fea:	eb 05                	jmp    801ff1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    

00801ff3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ff3:	55                   	push   %ebp
  801ff4:	89 e5                	mov    %esp,%ebp
  801ff6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffc:	50                   	push   %eax
  801ffd:	ff 75 08             	pushl  0x8(%ebp)
  802000:	e8 1e ee ff ff       	call   800e23 <fd_lookup>
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 11                	js     80201d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802015:	39 10                	cmp    %edx,(%eax)
  802017:	0f 94 c0             	sete   %al
  80201a:	0f b6 c0             	movzbl %al,%eax
}
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    

0080201f <opencons>:

int
opencons(void)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802028:	50                   	push   %eax
  802029:	e8 a6 ed ff ff       	call   800dd4 <fd_alloc>
  80202e:	83 c4 10             	add    $0x10,%esp
		return r;
  802031:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802033:	85 c0                	test   %eax,%eax
  802035:	78 3e                	js     802075 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802037:	83 ec 04             	sub    $0x4,%esp
  80203a:	68 07 04 00 00       	push   $0x407
  80203f:	ff 75 f4             	pushl  -0xc(%ebp)
  802042:	6a 00                	push   $0x0
  802044:	e8 53 eb ff ff       	call   800b9c <sys_page_alloc>
  802049:	83 c4 10             	add    $0x10,%esp
		return r;
  80204c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80204e:	85 c0                	test   %eax,%eax
  802050:	78 23                	js     802075 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802052:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802060:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802067:	83 ec 0c             	sub    $0xc,%esp
  80206a:	50                   	push   %eax
  80206b:	e8 3d ed ff ff       	call   800dad <fd2num>
  802070:	89 c2                	mov    %eax,%edx
  802072:	83 c4 10             	add    $0x10,%esp
}
  802075:	89 d0                	mov    %edx,%eax
  802077:	c9                   	leave  
  802078:	c3                   	ret    

00802079 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	56                   	push   %esi
  80207d:	53                   	push   %ebx
  80207e:	8b 75 08             	mov    0x8(%ebp),%esi
  802081:	8b 45 0c             	mov    0xc(%ebp),%eax
  802084:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802087:	85 c0                	test   %eax,%eax
  802089:	75 12                	jne    80209d <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80208b:	83 ec 0c             	sub    $0xc,%esp
  80208e:	68 00 00 c0 ee       	push   $0xeec00000
  802093:	e8 b4 ec ff ff       	call   800d4c <sys_ipc_recv>
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	eb 0c                	jmp    8020a9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80209d:	83 ec 0c             	sub    $0xc,%esp
  8020a0:	50                   	push   %eax
  8020a1:	e8 a6 ec ff ff       	call   800d4c <sys_ipc_recv>
  8020a6:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020a9:	85 f6                	test   %esi,%esi
  8020ab:	0f 95 c1             	setne  %cl
  8020ae:	85 db                	test   %ebx,%ebx
  8020b0:	0f 95 c2             	setne  %dl
  8020b3:	84 d1                	test   %dl,%cl
  8020b5:	74 09                	je     8020c0 <ipc_recv+0x47>
  8020b7:	89 c2                	mov    %eax,%edx
  8020b9:	c1 ea 1f             	shr    $0x1f,%edx
  8020bc:	84 d2                	test   %dl,%dl
  8020be:	75 27                	jne    8020e7 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020c0:	85 f6                	test   %esi,%esi
  8020c2:	74 0a                	je     8020ce <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8020c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8020c9:	8b 40 7c             	mov    0x7c(%eax),%eax
  8020cc:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020ce:	85 db                	test   %ebx,%ebx
  8020d0:	74 0d                	je     8020df <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  8020d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8020dd:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020df:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e4:	8b 40 78             	mov    0x78(%eax),%eax
}
  8020e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ea:	5b                   	pop    %ebx
  8020eb:	5e                   	pop    %esi
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 0c             	sub    $0xc,%esp
  8020f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802100:	85 db                	test   %ebx,%ebx
  802102:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802107:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80210a:	ff 75 14             	pushl  0x14(%ebp)
  80210d:	53                   	push   %ebx
  80210e:	56                   	push   %esi
  80210f:	57                   	push   %edi
  802110:	e8 14 ec ff ff       	call   800d29 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802115:	89 c2                	mov    %eax,%edx
  802117:	c1 ea 1f             	shr    $0x1f,%edx
  80211a:	83 c4 10             	add    $0x10,%esp
  80211d:	84 d2                	test   %dl,%dl
  80211f:	74 17                	je     802138 <ipc_send+0x4a>
  802121:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802124:	74 12                	je     802138 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802126:	50                   	push   %eax
  802127:	68 cb 29 80 00       	push   $0x8029cb
  80212c:	6a 47                	push   $0x47
  80212e:	68 d9 29 80 00       	push   $0x8029d9
  802133:	e8 03 e0 ff ff       	call   80013b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802138:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213b:	75 07                	jne    802144 <ipc_send+0x56>
			sys_yield();
  80213d:	e8 3b ea ff ff       	call   800b7d <sys_yield>
  802142:	eb c6                	jmp    80210a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802144:	85 c0                	test   %eax,%eax
  802146:	75 c2                	jne    80210a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80214b:	5b                   	pop    %ebx
  80214c:	5e                   	pop    %esi
  80214d:	5f                   	pop    %edi
  80214e:	5d                   	pop    %ebp
  80214f:	c3                   	ret    

00802150 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802156:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80215b:	89 c2                	mov    %eax,%edx
  80215d:	c1 e2 07             	shl    $0x7,%edx
  802160:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802167:	8b 52 58             	mov    0x58(%edx),%edx
  80216a:	39 ca                	cmp    %ecx,%edx
  80216c:	75 11                	jne    80217f <ipc_find_env+0x2f>
			return envs[i].env_id;
  80216e:	89 c2                	mov    %eax,%edx
  802170:	c1 e2 07             	shl    $0x7,%edx
  802173:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80217a:	8b 40 50             	mov    0x50(%eax),%eax
  80217d:	eb 0f                	jmp    80218e <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80217f:	83 c0 01             	add    $0x1,%eax
  802182:	3d 00 04 00 00       	cmp    $0x400,%eax
  802187:	75 d2                	jne    80215b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802189:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80218e:	5d                   	pop    %ebp
  80218f:	c3                   	ret    

00802190 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802196:	89 d0                	mov    %edx,%eax
  802198:	c1 e8 16             	shr    $0x16,%eax
  80219b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021a2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a7:	f6 c1 01             	test   $0x1,%cl
  8021aa:	74 1d                	je     8021c9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ac:	c1 ea 0c             	shr    $0xc,%edx
  8021af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021b6:	f6 c2 01             	test   $0x1,%dl
  8021b9:	74 0e                	je     8021c9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021bb:	c1 ea 0c             	shr    $0xc,%edx
  8021be:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021c5:	ef 
  8021c6:	0f b7 c0             	movzwl %ax,%eax
}
  8021c9:	5d                   	pop    %ebp
  8021ca:	c3                   	ret    
  8021cb:	66 90                	xchg   %ax,%ax
  8021cd:	66 90                	xchg   %ax,%ax
  8021cf:	90                   	nop

008021d0 <__udivdi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 f6                	test   %esi,%esi
  8021e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ed:	89 ca                	mov    %ecx,%edx
  8021ef:	89 f8                	mov    %edi,%eax
  8021f1:	75 3d                	jne    802230 <__udivdi3+0x60>
  8021f3:	39 cf                	cmp    %ecx,%edi
  8021f5:	0f 87 c5 00 00 00    	ja     8022c0 <__udivdi3+0xf0>
  8021fb:	85 ff                	test   %edi,%edi
  8021fd:	89 fd                	mov    %edi,%ebp
  8021ff:	75 0b                	jne    80220c <__udivdi3+0x3c>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	31 d2                	xor    %edx,%edx
  802208:	f7 f7                	div    %edi
  80220a:	89 c5                	mov    %eax,%ebp
  80220c:	89 c8                	mov    %ecx,%eax
  80220e:	31 d2                	xor    %edx,%edx
  802210:	f7 f5                	div    %ebp
  802212:	89 c1                	mov    %eax,%ecx
  802214:	89 d8                	mov    %ebx,%eax
  802216:	89 cf                	mov    %ecx,%edi
  802218:	f7 f5                	div    %ebp
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	39 ce                	cmp    %ecx,%esi
  802232:	77 74                	ja     8022a8 <__udivdi3+0xd8>
  802234:	0f bd fe             	bsr    %esi,%edi
  802237:	83 f7 1f             	xor    $0x1f,%edi
  80223a:	0f 84 98 00 00 00    	je     8022d8 <__udivdi3+0x108>
  802240:	bb 20 00 00 00       	mov    $0x20,%ebx
  802245:	89 f9                	mov    %edi,%ecx
  802247:	89 c5                	mov    %eax,%ebp
  802249:	29 fb                	sub    %edi,%ebx
  80224b:	d3 e6                	shl    %cl,%esi
  80224d:	89 d9                	mov    %ebx,%ecx
  80224f:	d3 ed                	shr    %cl,%ebp
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e0                	shl    %cl,%eax
  802255:	09 ee                	or     %ebp,%esi
  802257:	89 d9                	mov    %ebx,%ecx
  802259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225d:	89 d5                	mov    %edx,%ebp
  80225f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802263:	d3 ed                	shr    %cl,%ebp
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e2                	shl    %cl,%edx
  802269:	89 d9                	mov    %ebx,%ecx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	09 c2                	or     %eax,%edx
  80226f:	89 d0                	mov    %edx,%eax
  802271:	89 ea                	mov    %ebp,%edx
  802273:	f7 f6                	div    %esi
  802275:	89 d5                	mov    %edx,%ebp
  802277:	89 c3                	mov    %eax,%ebx
  802279:	f7 64 24 0c          	mull   0xc(%esp)
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	72 10                	jb     802291 <__udivdi3+0xc1>
  802281:	8b 74 24 08          	mov    0x8(%esp),%esi
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e6                	shl    %cl,%esi
  802289:	39 c6                	cmp    %eax,%esi
  80228b:	73 07                	jae    802294 <__udivdi3+0xc4>
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	75 03                	jne    802294 <__udivdi3+0xc4>
  802291:	83 eb 01             	sub    $0x1,%ebx
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 d8                	mov    %ebx,%eax
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	31 ff                	xor    %edi,%edi
  8022aa:	31 db                	xor    %ebx,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	f7 f7                	div    %edi
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 fa                	mov    %edi,%edx
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5f                   	pop    %edi
  8022d2:	5d                   	pop    %ebp
  8022d3:	c3                   	ret    
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 ce                	cmp    %ecx,%esi
  8022da:	72 0c                	jb     8022e8 <__udivdi3+0x118>
  8022dc:	31 db                	xor    %ebx,%ebx
  8022de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022e2:	0f 87 34 ff ff ff    	ja     80221c <__udivdi3+0x4c>
  8022e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ed:	e9 2a ff ff ff       	jmp    80221c <__udivdi3+0x4c>
  8022f2:	66 90                	xchg   %ax,%ax
  8022f4:	66 90                	xchg   %ax,%ax
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__umoddi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80230b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80230f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 d2                	test   %edx,%edx
  802319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80231d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802321:	89 f3                	mov    %esi,%ebx
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232a:	75 1c                	jne    802348 <__umoddi3+0x48>
  80232c:	39 f7                	cmp    %esi,%edi
  80232e:	76 50                	jbe    802380 <__umoddi3+0x80>
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	f7 f7                	div    %edi
  802336:	89 d0                	mov    %edx,%eax
  802338:	31 d2                	xor    %edx,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	39 f2                	cmp    %esi,%edx
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	77 52                	ja     8023a0 <__umoddi3+0xa0>
  80234e:	0f bd ea             	bsr    %edx,%ebp
  802351:	83 f5 1f             	xor    $0x1f,%ebp
  802354:	75 5a                	jne    8023b0 <__umoddi3+0xb0>
  802356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80235a:	0f 82 e0 00 00 00    	jb     802440 <__umoddi3+0x140>
  802360:	39 0c 24             	cmp    %ecx,(%esp)
  802363:	0f 86 d7 00 00 00    	jbe    802440 <__umoddi3+0x140>
  802369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80236d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802371:	83 c4 1c             	add    $0x1c,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	85 ff                	test   %edi,%edi
  802382:	89 fd                	mov    %edi,%ebp
  802384:	75 0b                	jne    802391 <__umoddi3+0x91>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp
  802391:	89 f0                	mov    %esi,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
  802397:	89 c8                	mov    %ecx,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	eb 99                	jmp    802338 <__umoddi3+0x38>
  80239f:	90                   	nop
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	83 c4 1c             	add    $0x1c,%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	8b 34 24             	mov    (%esp),%esi
  8023b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	29 ef                	sub    %ebp,%edi
  8023bc:	d3 e0                	shl    %cl,%eax
  8023be:	89 f9                	mov    %edi,%ecx
  8023c0:	89 f2                	mov    %esi,%edx
  8023c2:	d3 ea                	shr    %cl,%edx
  8023c4:	89 e9                	mov    %ebp,%ecx
  8023c6:	09 c2                	or     %eax,%edx
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	89 14 24             	mov    %edx,(%esp)
  8023cd:	89 f2                	mov    %esi,%edx
  8023cf:	d3 e2                	shl    %cl,%edx
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	d3 e3                	shl    %cl,%ebx
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	09 d8                	or     %ebx,%eax
  8023ed:	89 d3                	mov    %edx,%ebx
  8023ef:	89 f2                	mov    %esi,%edx
  8023f1:	f7 34 24             	divl   (%esp)
  8023f4:	89 d6                	mov    %edx,%esi
  8023f6:	d3 e3                	shl    %cl,%ebx
  8023f8:	f7 64 24 04          	mull   0x4(%esp)
  8023fc:	39 d6                	cmp    %edx,%esi
  8023fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 c3                	mov    %eax,%ebx
  802406:	72 08                	jb     802410 <__umoddi3+0x110>
  802408:	75 11                	jne    80241b <__umoddi3+0x11b>
  80240a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80240e:	73 0b                	jae    80241b <__umoddi3+0x11b>
  802410:	2b 44 24 04          	sub    0x4(%esp),%eax
  802414:	1b 14 24             	sbb    (%esp),%edx
  802417:	89 d1                	mov    %edx,%ecx
  802419:	89 c3                	mov    %eax,%ebx
  80241b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80241f:	29 da                	sub    %ebx,%edx
  802421:	19 ce                	sbb    %ecx,%esi
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 f0                	mov    %esi,%eax
  802427:	d3 e0                	shl    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	d3 ea                	shr    %cl,%edx
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	09 d0                	or     %edx,%eax
  802433:	89 f2                	mov    %esi,%edx
  802435:	83 c4 1c             	add    $0x1c,%esp
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	29 f9                	sub    %edi,%ecx
  802442:	19 d6                	sbb    %edx,%esi
  802444:	89 74 24 04          	mov    %esi,0x4(%esp)
  802448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80244c:	e9 18 ff ff ff       	jmp    802369 <__umoddi3+0x69>
