
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
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 20 24 80 00       	push   $0x802420
  800047:	e8 b0 01 00 00       	call   8001fc <cprintf>
	if ((r = spawnl("faultio", "faultio", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 3e 24 80 00       	push   $0x80243e
  800056:	68 3e 24 80 00       	push   $0x80243e
  80005b:	e8 8f 1a 00 00       	call   801aef <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(faultio) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 46 24 80 00       	push   $0x802446
  80006d:	6a 09                	push   $0x9
  80006f:	68 60 24 80 00       	push   $0x802460
  800074:	e8 aa 00 00 00       	call   800123 <_panic>
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
  80008e:	e8 b3 0a 00 00       	call   800b46 <sys_getenvid>
  800093:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800099:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80009e:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000a3:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8000a8:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8000ab:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8000b1:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8000b4:	39 c8                	cmp    %ecx,%eax
  8000b6:	0f 44 fb             	cmove  %ebx,%edi
  8000b9:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000be:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000c1:	83 c2 01             	add    $0x1,%edx
  8000c4:	83 c3 7c             	add    $0x7c,%ebx
  8000c7:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000cd:	75 d9                	jne    8000a8 <libmain+0x2d>
  8000cf:	89 f0                	mov    %esi,%eax
  8000d1:	84 c0                	test   %al,%al
  8000d3:	74 06                	je     8000db <libmain+0x60>
  8000d5:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000df:	7e 0a                	jle    8000eb <libmain+0x70>
		binaryname = argv[0];
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	8b 00                	mov    (%eax),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	ff 75 0c             	pushl  0xc(%ebp)
  8000f1:	ff 75 08             	pushl  0x8(%ebp)
  8000f4:	e8 3a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f9:	e8 0b 00 00 00       	call   800109 <exit>
}
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    

00800109 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010f:	e8 2c 0e 00 00       	call   800f40 <close_all>
	sys_env_destroy(0);
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	6a 00                	push   $0x0
  800119:	e8 e7 09 00 00       	call   800b05 <sys_env_destroy>
}
  80011e:	83 c4 10             	add    $0x10,%esp
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800128:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800131:	e8 10 0a 00 00       	call   800b46 <sys_getenvid>
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	ff 75 0c             	pushl  0xc(%ebp)
  80013c:	ff 75 08             	pushl  0x8(%ebp)
  80013f:	56                   	push   %esi
  800140:	50                   	push   %eax
  800141:	68 80 24 80 00       	push   $0x802480
  800146:	e8 b1 00 00 00       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014b:	83 c4 18             	add    $0x18,%esp
  80014e:	53                   	push   %ebx
  80014f:	ff 75 10             	pushl  0x10(%ebp)
  800152:	e8 54 00 00 00       	call   8001ab <vcprintf>
	cprintf("\n");
  800157:	c7 04 24 58 29 80 00 	movl   $0x802958,(%esp)
  80015e:	e8 99 00 00 00       	call   8001fc <cprintf>
  800163:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800166:	cc                   	int3   
  800167:	eb fd                	jmp    800166 <_panic+0x43>

00800169 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	53                   	push   %ebx
  80016d:	83 ec 04             	sub    $0x4,%esp
  800170:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800173:	8b 13                	mov    (%ebx),%edx
  800175:	8d 42 01             	lea    0x1(%edx),%eax
  800178:	89 03                	mov    %eax,(%ebx)
  80017a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800181:	3d ff 00 00 00       	cmp    $0xff,%eax
  800186:	75 1a                	jne    8001a2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800188:	83 ec 08             	sub    $0x8,%esp
  80018b:	68 ff 00 00 00       	push   $0xff
  800190:	8d 43 08             	lea    0x8(%ebx),%eax
  800193:	50                   	push   %eax
  800194:	e8 2f 09 00 00       	call   800ac8 <sys_cputs>
		b->idx = 0;
  800199:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bb:	00 00 00 
	b.cnt = 0;
  8001be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c8:	ff 75 0c             	pushl  0xc(%ebp)
  8001cb:	ff 75 08             	pushl  0x8(%ebp)
  8001ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d4:	50                   	push   %eax
  8001d5:	68 69 01 80 00       	push   $0x800169
  8001da:	e8 54 01 00 00       	call   800333 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001df:	83 c4 08             	add    $0x8,%esp
  8001e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ee:	50                   	push   %eax
  8001ef:	e8 d4 08 00 00       	call   800ac8 <sys_cputs>

	return b.cnt;
}
  8001f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	50                   	push   %eax
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 9d ff ff ff       	call   8001ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 1c             	sub    $0x1c,%esp
  800219:	89 c7                	mov    %eax,%edi
  80021b:	89 d6                	mov    %edx,%esi
  80021d:	8b 45 08             	mov    0x8(%ebp),%eax
  800220:	8b 55 0c             	mov    0xc(%ebp),%edx
  800223:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800226:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800229:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800234:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800237:	39 d3                	cmp    %edx,%ebx
  800239:	72 05                	jb     800240 <printnum+0x30>
  80023b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023e:	77 45                	ja     800285 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 18             	pushl  0x18(%ebp)
  800246:	8b 45 14             	mov    0x14(%ebp),%eax
  800249:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024c:	53                   	push   %ebx
  80024d:	ff 75 10             	pushl  0x10(%ebp)
  800250:	83 ec 08             	sub    $0x8,%esp
  800253:	ff 75 e4             	pushl  -0x1c(%ebp)
  800256:	ff 75 e0             	pushl  -0x20(%ebp)
  800259:	ff 75 dc             	pushl  -0x24(%ebp)
  80025c:	ff 75 d8             	pushl  -0x28(%ebp)
  80025f:	e8 2c 1f 00 00       	call   802190 <__udivdi3>
  800264:	83 c4 18             	add    $0x18,%esp
  800267:	52                   	push   %edx
  800268:	50                   	push   %eax
  800269:	89 f2                	mov    %esi,%edx
  80026b:	89 f8                	mov    %edi,%eax
  80026d:	e8 9e ff ff ff       	call   800210 <printnum>
  800272:	83 c4 20             	add    $0x20,%esp
  800275:	eb 18                	jmp    80028f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	56                   	push   %esi
  80027b:	ff 75 18             	pushl  0x18(%ebp)
  80027e:	ff d7                	call   *%edi
  800280:	83 c4 10             	add    $0x10,%esp
  800283:	eb 03                	jmp    800288 <printnum+0x78>
  800285:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800288:	83 eb 01             	sub    $0x1,%ebx
  80028b:	85 db                	test   %ebx,%ebx
  80028d:	7f e8                	jg     800277 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	83 ec 04             	sub    $0x4,%esp
  800296:	ff 75 e4             	pushl  -0x1c(%ebp)
  800299:	ff 75 e0             	pushl  -0x20(%ebp)
  80029c:	ff 75 dc             	pushl  -0x24(%ebp)
  80029f:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a2:	e8 19 20 00 00       	call   8022c0 <__umoddi3>
  8002a7:	83 c4 14             	add    $0x14,%esp
  8002aa:	0f be 80 a3 24 80 00 	movsbl 0x8024a3(%eax),%eax
  8002b1:	50                   	push   %eax
  8002b2:	ff d7                	call   *%edi
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5f                   	pop    %edi
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c2:	83 fa 01             	cmp    $0x1,%edx
  8002c5:	7e 0e                	jle    8002d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 02                	mov    (%edx),%eax
  8002d0:	8b 52 04             	mov    0x4(%edx),%edx
  8002d3:	eb 22                	jmp    8002f7 <getuint+0x38>
	else if (lflag)
  8002d5:	85 d2                	test   %edx,%edx
  8002d7:	74 10                	je     8002e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e7:	eb 0e                	jmp    8002f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800303:	8b 10                	mov    (%eax),%edx
  800305:	3b 50 04             	cmp    0x4(%eax),%edx
  800308:	73 0a                	jae    800314 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 45 08             	mov    0x8(%ebp),%eax
  800312:	88 02                	mov    %al,(%edx)
}
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031f:	50                   	push   %eax
  800320:	ff 75 10             	pushl  0x10(%ebp)
  800323:	ff 75 0c             	pushl  0xc(%ebp)
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	e8 05 00 00 00       	call   800333 <vprintfmt>
	va_end(ap);
}
  80032e:	83 c4 10             	add    $0x10,%esp
  800331:	c9                   	leave  
  800332:	c3                   	ret    

00800333 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	57                   	push   %edi
  800337:	56                   	push   %esi
  800338:	53                   	push   %ebx
  800339:	83 ec 2c             	sub    $0x2c,%esp
  80033c:	8b 75 08             	mov    0x8(%ebp),%esi
  80033f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800342:	8b 7d 10             	mov    0x10(%ebp),%edi
  800345:	eb 12                	jmp    800359 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800347:	85 c0                	test   %eax,%eax
  800349:	0f 84 89 03 00 00    	je     8006d8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80034f:	83 ec 08             	sub    $0x8,%esp
  800352:	53                   	push   %ebx
  800353:	50                   	push   %eax
  800354:	ff d6                	call   *%esi
  800356:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	83 c7 01             	add    $0x1,%edi
  80035c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800360:	83 f8 25             	cmp    $0x25,%eax
  800363:	75 e2                	jne    800347 <vprintfmt+0x14>
  800365:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800369:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800370:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800377:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037e:	ba 00 00 00 00       	mov    $0x0,%edx
  800383:	eb 07                	jmp    80038c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800388:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8d 47 01             	lea    0x1(%edi),%eax
  80038f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800392:	0f b6 07             	movzbl (%edi),%eax
  800395:	0f b6 c8             	movzbl %al,%ecx
  800398:	83 e8 23             	sub    $0x23,%eax
  80039b:	3c 55                	cmp    $0x55,%al
  80039d:	0f 87 1a 03 00 00    	ja     8006bd <vprintfmt+0x38a>
  8003a3:	0f b6 c0             	movzbl %al,%eax
  8003a6:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b4:	eb d6                	jmp    80038c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003cb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ce:	83 fa 09             	cmp    $0x9,%edx
  8003d1:	77 39                	ja     80040c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d6:	eb e9                	jmp    8003c1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 48 04             	lea    0x4(%eax),%ecx
  8003de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e9:	eb 27                	jmp    800412 <vprintfmt+0xdf>
  8003eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ee:	85 c0                	test   %eax,%eax
  8003f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f5:	0f 49 c8             	cmovns %eax,%ecx
  8003f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fe:	eb 8c                	jmp    80038c <vprintfmt+0x59>
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800403:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040a:	eb 80                	jmp    80038c <vprintfmt+0x59>
  80040c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800412:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800416:	0f 89 70 ff ff ff    	jns    80038c <vprintfmt+0x59>
				width = precision, precision = -1;
  80041c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800422:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800429:	e9 5e ff ff ff       	jmp    80038c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800434:	e9 53 ff ff ff       	jmp    80038c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	89 55 14             	mov    %edx,0x14(%ebp)
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	53                   	push   %ebx
  800446:	ff 30                	pushl  (%eax)
  800448:	ff d6                	call   *%esi
			break;
  80044a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800450:	e9 04 ff ff ff       	jmp    800359 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	99                   	cltd   
  800461:	31 d0                	xor    %edx,%eax
  800463:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800465:	83 f8 0f             	cmp    $0xf,%eax
  800468:	7f 0b                	jg     800475 <vprintfmt+0x142>
  80046a:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800471:	85 d2                	test   %edx,%edx
  800473:	75 18                	jne    80048d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800475:	50                   	push   %eax
  800476:	68 bb 24 80 00       	push   $0x8024bb
  80047b:	53                   	push   %ebx
  80047c:	56                   	push   %esi
  80047d:	e8 94 fe ff ff       	call   800316 <printfmt>
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800488:	e9 cc fe ff ff       	jmp    800359 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048d:	52                   	push   %edx
  80048e:	68 71 28 80 00       	push   $0x802871
  800493:	53                   	push   %ebx
  800494:	56                   	push   %esi
  800495:	e8 7c fe ff ff       	call   800316 <printfmt>
  80049a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a0:	e9 b4 fe ff ff       	jmp    800359 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b0:	85 ff                	test   %edi,%edi
  8004b2:	b8 b4 24 80 00       	mov    $0x8024b4,%eax
  8004b7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004be:	0f 8e 94 00 00 00    	jle    800558 <vprintfmt+0x225>
  8004c4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c8:	0f 84 98 00 00 00    	je     800566 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d4:	57                   	push   %edi
  8004d5:	e8 86 02 00 00       	call   800760 <strnlen>
  8004da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004dd:	29 c1                	sub    %eax,%ecx
  8004df:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ef:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	eb 0f                	jmp    800502 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	83 ef 01             	sub    $0x1,%edi
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	85 ff                	test   %edi,%edi
  800504:	7f ed                	jg     8004f3 <vprintfmt+0x1c0>
  800506:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800509:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80050c:	85 c9                	test   %ecx,%ecx
  80050e:	b8 00 00 00 00       	mov    $0x0,%eax
  800513:	0f 49 c1             	cmovns %ecx,%eax
  800516:	29 c1                	sub    %eax,%ecx
  800518:	89 75 08             	mov    %esi,0x8(%ebp)
  80051b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800521:	89 cb                	mov    %ecx,%ebx
  800523:	eb 4d                	jmp    800572 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800525:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800529:	74 1b                	je     800546 <vprintfmt+0x213>
  80052b:	0f be c0             	movsbl %al,%eax
  80052e:	83 e8 20             	sub    $0x20,%eax
  800531:	83 f8 5e             	cmp    $0x5e,%eax
  800534:	76 10                	jbe    800546 <vprintfmt+0x213>
					putch('?', putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	ff 75 0c             	pushl  0xc(%ebp)
  80053c:	6a 3f                	push   $0x3f
  80053e:	ff 55 08             	call   *0x8(%ebp)
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	eb 0d                	jmp    800553 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	ff 75 0c             	pushl  0xc(%ebp)
  80054c:	52                   	push   %edx
  80054d:	ff 55 08             	call   *0x8(%ebp)
  800550:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800553:	83 eb 01             	sub    $0x1,%ebx
  800556:	eb 1a                	jmp    800572 <vprintfmt+0x23f>
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	eb 0c                	jmp    800572 <vprintfmt+0x23f>
  800566:	89 75 08             	mov    %esi,0x8(%ebp)
  800569:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800572:	83 c7 01             	add    $0x1,%edi
  800575:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800579:	0f be d0             	movsbl %al,%edx
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 23                	je     8005a3 <vprintfmt+0x270>
  800580:	85 f6                	test   %esi,%esi
  800582:	78 a1                	js     800525 <vprintfmt+0x1f2>
  800584:	83 ee 01             	sub    $0x1,%esi
  800587:	79 9c                	jns    800525 <vprintfmt+0x1f2>
  800589:	89 df                	mov    %ebx,%edi
  80058b:	8b 75 08             	mov    0x8(%ebp),%esi
  80058e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800591:	eb 18                	jmp    8005ab <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	53                   	push   %ebx
  800597:	6a 20                	push   $0x20
  800599:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059b:	83 ef 01             	sub    $0x1,%edi
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	eb 08                	jmp    8005ab <vprintfmt+0x278>
  8005a3:	89 df                	mov    %ebx,%edi
  8005a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ab:	85 ff                	test   %edi,%edi
  8005ad:	7f e4                	jg     800593 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b2:	e9 a2 fd ff ff       	jmp    800359 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b7:	83 fa 01             	cmp    $0x1,%edx
  8005ba:	7e 16                	jle    8005d2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 08             	lea    0x8(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 50 04             	mov    0x4(%eax),%edx
  8005c8:	8b 00                	mov    (%eax),%eax
  8005ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d0:	eb 32                	jmp    800604 <vprintfmt+0x2d1>
	else if (lflag)
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	74 18                	je     8005ee <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e4:	89 c1                	mov    %eax,%ecx
  8005e6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ec:	eb 16                	jmp    800604 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 c1                	mov    %eax,%ecx
  8005fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800601:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800604:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800607:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800613:	79 74                	jns    800689 <vprintfmt+0x356>
				putch('-', putdat);
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	53                   	push   %ebx
  800619:	6a 2d                	push   $0x2d
  80061b:	ff d6                	call   *%esi
				num = -(long long) num;
  80061d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800620:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800623:	f7 d8                	neg    %eax
  800625:	83 d2 00             	adc    $0x0,%edx
  800628:	f7 da                	neg    %edx
  80062a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800632:	eb 55                	jmp    800689 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 83 fc ff ff       	call   8002bf <getuint>
			base = 10;
  80063c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800641:	eb 46                	jmp    800689 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800643:	8d 45 14             	lea    0x14(%ebp),%eax
  800646:	e8 74 fc ff ff       	call   8002bf <getuint>
			base = 8;
  80064b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800650:	eb 37                	jmp    800689 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 30                	push   $0x30
  800658:	ff d6                	call   *%esi
			putch('x', putdat);
  80065a:	83 c4 08             	add    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 78                	push   $0x78
  800660:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 50 04             	lea    0x4(%eax),%edx
  800668:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066b:	8b 00                	mov    (%eax),%eax
  80066d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800672:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800675:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80067a:	eb 0d                	jmp    800689 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067c:	8d 45 14             	lea    0x14(%ebp),%eax
  80067f:	e8 3b fc ff ff       	call   8002bf <getuint>
			base = 16;
  800684:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800689:	83 ec 0c             	sub    $0xc,%esp
  80068c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800690:	57                   	push   %edi
  800691:	ff 75 e0             	pushl  -0x20(%ebp)
  800694:	51                   	push   %ecx
  800695:	52                   	push   %edx
  800696:	50                   	push   %eax
  800697:	89 da                	mov    %ebx,%edx
  800699:	89 f0                	mov    %esi,%eax
  80069b:	e8 70 fb ff ff       	call   800210 <printnum>
			break;
  8006a0:	83 c4 20             	add    $0x20,%esp
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a6:	e9 ae fc ff ff       	jmp    800359 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	51                   	push   %ecx
  8006b0:	ff d6                	call   *%esi
			break;
  8006b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b8:	e9 9c fc ff ff       	jmp    800359 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	6a 25                	push   $0x25
  8006c3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	eb 03                	jmp    8006cd <vprintfmt+0x39a>
  8006ca:	83 ef 01             	sub    $0x1,%edi
  8006cd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d1:	75 f7                	jne    8006ca <vprintfmt+0x397>
  8006d3:	e9 81 fc ff ff       	jmp    800359 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006db:	5b                   	pop    %ebx
  8006dc:	5e                   	pop    %esi
  8006dd:	5f                   	pop    %edi
  8006de:	5d                   	pop    %ebp
  8006df:	c3                   	ret    

008006e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	83 ec 18             	sub    $0x18,%esp
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	74 26                	je     800727 <vsnprintf+0x47>
  800701:	85 d2                	test   %edx,%edx
  800703:	7e 22                	jle    800727 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800705:	ff 75 14             	pushl  0x14(%ebp)
  800708:	ff 75 10             	pushl  0x10(%ebp)
  80070b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	68 f9 02 80 00       	push   $0x8002f9
  800714:	e8 1a fc ff ff       	call   800333 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800719:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	eb 05                	jmp    80072c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800727:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072c:	c9                   	leave  
  80072d:	c3                   	ret    

0080072e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800734:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800737:	50                   	push   %eax
  800738:	ff 75 10             	pushl  0x10(%ebp)
  80073b:	ff 75 0c             	pushl  0xc(%ebp)
  80073e:	ff 75 08             	pushl  0x8(%ebp)
  800741:	e8 9a ff ff ff       	call   8006e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800746:	c9                   	leave  
  800747:	c3                   	ret    

00800748 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	eb 03                	jmp    800758 <strlen+0x10>
		n++;
  800755:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800758:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075c:	75 f7                	jne    800755 <strlen+0xd>
		n++;
	return n;
}
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800766:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800769:	ba 00 00 00 00       	mov    $0x0,%edx
  80076e:	eb 03                	jmp    800773 <strnlen+0x13>
		n++;
  800770:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800773:	39 c2                	cmp    %eax,%edx
  800775:	74 08                	je     80077f <strnlen+0x1f>
  800777:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077b:	75 f3                	jne    800770 <strnlen+0x10>
  80077d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	53                   	push   %ebx
  800785:	8b 45 08             	mov    0x8(%ebp),%eax
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078b:	89 c2                	mov    %eax,%edx
  80078d:	83 c2 01             	add    $0x1,%edx
  800790:	83 c1 01             	add    $0x1,%ecx
  800793:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800797:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079a:	84 db                	test   %bl,%bl
  80079c:	75 ef                	jne    80078d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079e:	5b                   	pop    %ebx
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	53                   	push   %ebx
  8007a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a8:	53                   	push   %ebx
  8007a9:	e8 9a ff ff ff       	call   800748 <strlen>
  8007ae:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b1:	ff 75 0c             	pushl  0xc(%ebp)
  8007b4:	01 d8                	add    %ebx,%eax
  8007b6:	50                   	push   %eax
  8007b7:	e8 c5 ff ff ff       	call   800781 <strcpy>
	return dst;
}
  8007bc:	89 d8                	mov    %ebx,%eax
  8007be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	56                   	push   %esi
  8007c7:	53                   	push   %ebx
  8007c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ce:	89 f3                	mov    %esi,%ebx
  8007d0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d3:	89 f2                	mov    %esi,%edx
  8007d5:	eb 0f                	jmp    8007e6 <strncpy+0x23>
		*dst++ = *src;
  8007d7:	83 c2 01             	add    $0x1,%edx
  8007da:	0f b6 01             	movzbl (%ecx),%eax
  8007dd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e6:	39 da                	cmp    %ebx,%edx
  8007e8:	75 ed                	jne    8007d7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ea:	89 f0                	mov    %esi,%eax
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fb:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800800:	85 d2                	test   %edx,%edx
  800802:	74 21                	je     800825 <strlcpy+0x35>
  800804:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800808:	89 f2                	mov    %esi,%edx
  80080a:	eb 09                	jmp    800815 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	83 c1 01             	add    $0x1,%ecx
  800812:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800815:	39 c2                	cmp    %eax,%edx
  800817:	74 09                	je     800822 <strlcpy+0x32>
  800819:	0f b6 19             	movzbl (%ecx),%ebx
  80081c:	84 db                	test   %bl,%bl
  80081e:	75 ec                	jne    80080c <strlcpy+0x1c>
  800820:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800822:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800825:	29 f0                	sub    %esi,%eax
}
  800827:	5b                   	pop    %ebx
  800828:	5e                   	pop    %esi
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800834:	eb 06                	jmp    80083c <strcmp+0x11>
		p++, q++;
  800836:	83 c1 01             	add    $0x1,%ecx
  800839:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083c:	0f b6 01             	movzbl (%ecx),%eax
  80083f:	84 c0                	test   %al,%al
  800841:	74 04                	je     800847 <strcmp+0x1c>
  800843:	3a 02                	cmp    (%edx),%al
  800845:	74 ef                	je     800836 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800847:	0f b6 c0             	movzbl %al,%eax
  80084a:	0f b6 12             	movzbl (%edx),%edx
  80084d:	29 d0                	sub    %edx,%eax
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085b:	89 c3                	mov    %eax,%ebx
  80085d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800860:	eb 06                	jmp    800868 <strncmp+0x17>
		n--, p++, q++;
  800862:	83 c0 01             	add    $0x1,%eax
  800865:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800868:	39 d8                	cmp    %ebx,%eax
  80086a:	74 15                	je     800881 <strncmp+0x30>
  80086c:	0f b6 08             	movzbl (%eax),%ecx
  80086f:	84 c9                	test   %cl,%cl
  800871:	74 04                	je     800877 <strncmp+0x26>
  800873:	3a 0a                	cmp    (%edx),%cl
  800875:	74 eb                	je     800862 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 00             	movzbl (%eax),%eax
  80087a:	0f b6 12             	movzbl (%edx),%edx
  80087d:	29 d0                	sub    %edx,%eax
  80087f:	eb 05                	jmp    800886 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800886:	5b                   	pop    %ebx
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800893:	eb 07                	jmp    80089c <strchr+0x13>
		if (*s == c)
  800895:	38 ca                	cmp    %cl,%dl
  800897:	74 0f                	je     8008a8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	0f b6 10             	movzbl (%eax),%edx
  80089f:	84 d2                	test   %dl,%dl
  8008a1:	75 f2                	jne    800895 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b4:	eb 03                	jmp    8008b9 <strfind+0xf>
  8008b6:	83 c0 01             	add    $0x1,%eax
  8008b9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	74 04                	je     8008c4 <strfind+0x1a>
  8008c0:	84 d2                	test   %dl,%dl
  8008c2:	75 f2                	jne    8008b6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	57                   	push   %edi
  8008ca:	56                   	push   %esi
  8008cb:	53                   	push   %ebx
  8008cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d2:	85 c9                	test   %ecx,%ecx
  8008d4:	74 36                	je     80090c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008dc:	75 28                	jne    800906 <memset+0x40>
  8008de:	f6 c1 03             	test   $0x3,%cl
  8008e1:	75 23                	jne    800906 <memset+0x40>
		c &= 0xFF;
  8008e3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e7:	89 d3                	mov    %edx,%ebx
  8008e9:	c1 e3 08             	shl    $0x8,%ebx
  8008ec:	89 d6                	mov    %edx,%esi
  8008ee:	c1 e6 18             	shl    $0x18,%esi
  8008f1:	89 d0                	mov    %edx,%eax
  8008f3:	c1 e0 10             	shl    $0x10,%eax
  8008f6:	09 f0                	or     %esi,%eax
  8008f8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008fa:	89 d8                	mov    %ebx,%eax
  8008fc:	09 d0                	or     %edx,%eax
  8008fe:	c1 e9 02             	shr    $0x2,%ecx
  800901:	fc                   	cld    
  800902:	f3 ab                	rep stos %eax,%es:(%edi)
  800904:	eb 06                	jmp    80090c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
  800909:	fc                   	cld    
  80090a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090c:	89 f8                	mov    %edi,%eax
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5f                   	pop    %edi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	57                   	push   %edi
  800917:	56                   	push   %esi
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800921:	39 c6                	cmp    %eax,%esi
  800923:	73 35                	jae    80095a <memmove+0x47>
  800925:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800928:	39 d0                	cmp    %edx,%eax
  80092a:	73 2e                	jae    80095a <memmove+0x47>
		s += n;
		d += n;
  80092c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092f:	89 d6                	mov    %edx,%esi
  800931:	09 fe                	or     %edi,%esi
  800933:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800939:	75 13                	jne    80094e <memmove+0x3b>
  80093b:	f6 c1 03             	test   $0x3,%cl
  80093e:	75 0e                	jne    80094e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800940:	83 ef 04             	sub    $0x4,%edi
  800943:	8d 72 fc             	lea    -0x4(%edx),%esi
  800946:	c1 e9 02             	shr    $0x2,%ecx
  800949:	fd                   	std    
  80094a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094c:	eb 09                	jmp    800957 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094e:	83 ef 01             	sub    $0x1,%edi
  800951:	8d 72 ff             	lea    -0x1(%edx),%esi
  800954:	fd                   	std    
  800955:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800957:	fc                   	cld    
  800958:	eb 1d                	jmp    800977 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095a:	89 f2                	mov    %esi,%edx
  80095c:	09 c2                	or     %eax,%edx
  80095e:	f6 c2 03             	test   $0x3,%dl
  800961:	75 0f                	jne    800972 <memmove+0x5f>
  800963:	f6 c1 03             	test   $0x3,%cl
  800966:	75 0a                	jne    800972 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800968:	c1 e9 02             	shr    $0x2,%ecx
  80096b:	89 c7                	mov    %eax,%edi
  80096d:	fc                   	cld    
  80096e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800970:	eb 05                	jmp    800977 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097e:	ff 75 10             	pushl  0x10(%ebp)
  800981:	ff 75 0c             	pushl  0xc(%ebp)
  800984:	ff 75 08             	pushl  0x8(%ebp)
  800987:	e8 87 ff ff ff       	call   800913 <memmove>
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	56                   	push   %esi
  800992:	53                   	push   %ebx
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 55 0c             	mov    0xc(%ebp),%edx
  800999:	89 c6                	mov    %eax,%esi
  80099b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099e:	eb 1a                	jmp    8009ba <memcmp+0x2c>
		if (*s1 != *s2)
  8009a0:	0f b6 08             	movzbl (%eax),%ecx
  8009a3:	0f b6 1a             	movzbl (%edx),%ebx
  8009a6:	38 d9                	cmp    %bl,%cl
  8009a8:	74 0a                	je     8009b4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009aa:	0f b6 c1             	movzbl %cl,%eax
  8009ad:	0f b6 db             	movzbl %bl,%ebx
  8009b0:	29 d8                	sub    %ebx,%eax
  8009b2:	eb 0f                	jmp    8009c3 <memcmp+0x35>
		s1++, s2++;
  8009b4:	83 c0 01             	add    $0x1,%eax
  8009b7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ba:	39 f0                	cmp    %esi,%eax
  8009bc:	75 e2                	jne    8009a0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	53                   	push   %ebx
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ce:	89 c1                	mov    %eax,%ecx
  8009d0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d7:	eb 0a                	jmp    8009e3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d9:	0f b6 10             	movzbl (%eax),%edx
  8009dc:	39 da                	cmp    %ebx,%edx
  8009de:	74 07                	je     8009e7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e0:	83 c0 01             	add    $0x1,%eax
  8009e3:	39 c8                	cmp    %ecx,%eax
  8009e5:	72 f2                	jb     8009d9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	57                   	push   %edi
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f6:	eb 03                	jmp    8009fb <strtol+0x11>
		s++;
  8009f8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fb:	0f b6 01             	movzbl (%ecx),%eax
  8009fe:	3c 20                	cmp    $0x20,%al
  800a00:	74 f6                	je     8009f8 <strtol+0xe>
  800a02:	3c 09                	cmp    $0x9,%al
  800a04:	74 f2                	je     8009f8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a06:	3c 2b                	cmp    $0x2b,%al
  800a08:	75 0a                	jne    800a14 <strtol+0x2a>
		s++;
  800a0a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a12:	eb 11                	jmp    800a25 <strtol+0x3b>
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a19:	3c 2d                	cmp    $0x2d,%al
  800a1b:	75 08                	jne    800a25 <strtol+0x3b>
		s++, neg = 1;
  800a1d:	83 c1 01             	add    $0x1,%ecx
  800a20:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a25:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2b:	75 15                	jne    800a42 <strtol+0x58>
  800a2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a30:	75 10                	jne    800a42 <strtol+0x58>
  800a32:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a36:	75 7c                	jne    800ab4 <strtol+0xca>
		s += 2, base = 16;
  800a38:	83 c1 02             	add    $0x2,%ecx
  800a3b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a40:	eb 16                	jmp    800a58 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	75 12                	jne    800a58 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a46:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4e:	75 08                	jne    800a58 <strtol+0x6e>
		s++, base = 8;
  800a50:	83 c1 01             	add    $0x1,%ecx
  800a53:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a60:	0f b6 11             	movzbl (%ecx),%edx
  800a63:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 09             	cmp    $0x9,%bl
  800a6b:	77 08                	ja     800a75 <strtol+0x8b>
			dig = *s - '0';
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 30             	sub    $0x30,%edx
  800a73:	eb 22                	jmp    800a97 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a75:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 19             	cmp    $0x19,%bl
  800a7d:	77 08                	ja     800a87 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 57             	sub    $0x57,%edx
  800a85:	eb 10                	jmp    800a97 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a87:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8a:	89 f3                	mov    %esi,%ebx
  800a8c:	80 fb 19             	cmp    $0x19,%bl
  800a8f:	77 16                	ja     800aa7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a91:	0f be d2             	movsbl %dl,%edx
  800a94:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a97:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9a:	7d 0b                	jge    800aa7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a9c:	83 c1 01             	add    $0x1,%ecx
  800a9f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa5:	eb b9                	jmp    800a60 <strtol+0x76>

	if (endptr)
  800aa7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aab:	74 0d                	je     800aba <strtol+0xd0>
		*endptr = (char *) s;
  800aad:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab0:	89 0e                	mov    %ecx,(%esi)
  800ab2:	eb 06                	jmp    800aba <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab4:	85 db                	test   %ebx,%ebx
  800ab6:	74 98                	je     800a50 <strtol+0x66>
  800ab8:	eb 9e                	jmp    800a58 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	f7 da                	neg    %edx
  800abe:	85 ff                	test   %edi,%edi
  800ac0:	0f 45 c2             	cmovne %edx,%eax
}
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad9:	89 c3                	mov    %eax,%ebx
  800adb:	89 c7                	mov    %eax,%edi
  800add:	89 c6                	mov    %eax,%esi
  800adf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	ba 00 00 00 00       	mov    $0x0,%edx
  800af1:	b8 01 00 00 00       	mov    $0x1,%eax
  800af6:	89 d1                	mov    %edx,%ecx
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	89 d7                	mov    %edx,%edi
  800afc:	89 d6                	mov    %edx,%esi
  800afe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b13:	b8 03 00 00 00       	mov    $0x3,%eax
  800b18:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1b:	89 cb                	mov    %ecx,%ebx
  800b1d:	89 cf                	mov    %ecx,%edi
  800b1f:	89 ce                	mov    %ecx,%esi
  800b21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b23:	85 c0                	test   %eax,%eax
  800b25:	7e 17                	jle    800b3e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b27:	83 ec 0c             	sub    $0xc,%esp
  800b2a:	50                   	push   %eax
  800b2b:	6a 03                	push   $0x3
  800b2d:	68 9f 27 80 00       	push   $0x80279f
  800b32:	6a 23                	push   $0x23
  800b34:	68 bc 27 80 00       	push   $0x8027bc
  800b39:	e8 e5 f5 ff ff       	call   800123 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 02 00 00 00       	mov    $0x2,%eax
  800b56:	89 d1                	mov    %edx,%ecx
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_yield>:

void
sys_yield(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b75:	89 d1                	mov    %edx,%ecx
  800b77:	89 d3                	mov    %edx,%ebx
  800b79:	89 d7                	mov    %edx,%edi
  800b7b:	89 d6                	mov    %edx,%esi
  800b7d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	be 00 00 00 00       	mov    $0x0,%esi
  800b92:	b8 04 00 00 00       	mov    $0x4,%eax
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba0:	89 f7                	mov    %esi,%edi
  800ba2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba4:	85 c0                	test   %eax,%eax
  800ba6:	7e 17                	jle    800bbf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	50                   	push   %eax
  800bac:	6a 04                	push   $0x4
  800bae:	68 9f 27 80 00       	push   $0x80279f
  800bb3:	6a 23                	push   $0x23
  800bb5:	68 bc 27 80 00       	push   $0x8027bc
  800bba:	e8 64 f5 ff ff       	call   800123 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be1:	8b 75 18             	mov    0x18(%ebp),%esi
  800be4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	7e 17                	jle    800c01 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	50                   	push   %eax
  800bee:	6a 05                	push   $0x5
  800bf0:	68 9f 27 80 00       	push   $0x80279f
  800bf5:	6a 23                	push   $0x23
  800bf7:	68 bc 27 80 00       	push   $0x8027bc
  800bfc:	e8 22 f5 ff ff       	call   800123 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c17:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c22:	89 df                	mov    %ebx,%edi
  800c24:	89 de                	mov    %ebx,%esi
  800c26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7e 17                	jle    800c43 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 06                	push   $0x6
  800c32:	68 9f 27 80 00       	push   $0x80279f
  800c37:	6a 23                	push   $0x23
  800c39:	68 bc 27 80 00       	push   $0x8027bc
  800c3e:	e8 e0 f4 ff ff       	call   800123 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c59:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	89 df                	mov    %ebx,%edi
  800c66:	89 de                	mov    %ebx,%esi
  800c68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7e 17                	jle    800c85 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 08                	push   $0x8
  800c74:	68 9f 27 80 00       	push   $0x80279f
  800c79:	6a 23                	push   $0x23
  800c7b:	68 bc 27 80 00       	push   $0x8027bc
  800c80:	e8 9e f4 ff ff       	call   800123 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7e 17                	jle    800cc7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 09                	push   $0x9
  800cb6:	68 9f 27 80 00       	push   $0x80279f
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 bc 27 80 00       	push   $0x8027bc
  800cc2:	e8 5c f4 ff ff       	call   800123 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7e 17                	jle    800d09 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 0a                	push   $0xa
  800cf8:	68 9f 27 80 00       	push   $0x80279f
  800cfd:	6a 23                	push   $0x23
  800cff:	68 bc 27 80 00       	push   $0x8027bc
  800d04:	e8 1a f4 ff ff       	call   800123 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	be 00 00 00 00       	mov    $0x0,%esi
  800d1c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d42:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 cb                	mov    %ecx,%ebx
  800d4c:	89 cf                	mov    %ecx,%edi
  800d4e:	89 ce                	mov    %ecx,%esi
  800d50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 17                	jle    800d6d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 0d                	push   $0xd
  800d5c:	68 9f 27 80 00       	push   $0x80279f
  800d61:	6a 23                	push   $0x23
  800d63:	68 bc 27 80 00       	push   $0x8027bc
  800d68:	e8 b6 f3 ff ff       	call   800123 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d80:	c1 e8 0c             	shr    $0xc,%eax
}
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d95:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da7:	89 c2                	mov    %eax,%edx
  800da9:	c1 ea 16             	shr    $0x16,%edx
  800dac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db3:	f6 c2 01             	test   $0x1,%dl
  800db6:	74 11                	je     800dc9 <fd_alloc+0x2d>
  800db8:	89 c2                	mov    %eax,%edx
  800dba:	c1 ea 0c             	shr    $0xc,%edx
  800dbd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc4:	f6 c2 01             	test   $0x1,%dl
  800dc7:	75 09                	jne    800dd2 <fd_alloc+0x36>
			*fd_store = fd;
  800dc9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd0:	eb 17                	jmp    800de9 <fd_alloc+0x4d>
  800dd2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ddc:	75 c9                	jne    800da7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dde:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800de4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df1:	83 f8 1f             	cmp    $0x1f,%eax
  800df4:	77 36                	ja     800e2c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df6:	c1 e0 0c             	shl    $0xc,%eax
  800df9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dfe:	89 c2                	mov    %eax,%edx
  800e00:	c1 ea 16             	shr    $0x16,%edx
  800e03:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0a:	f6 c2 01             	test   $0x1,%dl
  800e0d:	74 24                	je     800e33 <fd_lookup+0x48>
  800e0f:	89 c2                	mov    %eax,%edx
  800e11:	c1 ea 0c             	shr    $0xc,%edx
  800e14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1b:	f6 c2 01             	test   $0x1,%dl
  800e1e:	74 1a                	je     800e3a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e23:	89 02                	mov    %eax,(%edx)
	return 0;
  800e25:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2a:	eb 13                	jmp    800e3f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e31:	eb 0c                	jmp    800e3f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e38:	eb 05                	jmp    800e3f <fd_lookup+0x54>
  800e3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4a:	ba 48 28 80 00       	mov    $0x802848,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e4f:	eb 13                	jmp    800e64 <dev_lookup+0x23>
  800e51:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e54:	39 08                	cmp    %ecx,(%eax)
  800e56:	75 0c                	jne    800e64 <dev_lookup+0x23>
			*dev = devtab[i];
  800e58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e62:	eb 2e                	jmp    800e92 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e64:	8b 02                	mov    (%edx),%eax
  800e66:	85 c0                	test   %eax,%eax
  800e68:	75 e7                	jne    800e51 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6a:	a1 04 40 80 00       	mov    0x804004,%eax
  800e6f:	8b 40 48             	mov    0x48(%eax),%eax
  800e72:	83 ec 04             	sub    $0x4,%esp
  800e75:	51                   	push   %ecx
  800e76:	50                   	push   %eax
  800e77:	68 cc 27 80 00       	push   $0x8027cc
  800e7c:	e8 7b f3 ff ff       	call   8001fc <cprintf>
	*dev = 0;
  800e81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e8a:	83 c4 10             	add    $0x10,%esp
  800e8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
  800e99:	83 ec 10             	sub    $0x10,%esp
  800e9c:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea5:	50                   	push   %eax
  800ea6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eac:	c1 e8 0c             	shr    $0xc,%eax
  800eaf:	50                   	push   %eax
  800eb0:	e8 36 ff ff ff       	call   800deb <fd_lookup>
  800eb5:	83 c4 08             	add    $0x8,%esp
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	78 05                	js     800ec1 <fd_close+0x2d>
	    || fd != fd2)
  800ebc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ebf:	74 0c                	je     800ecd <fd_close+0x39>
		return (must_exist ? r : 0);
  800ec1:	84 db                	test   %bl,%bl
  800ec3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec8:	0f 44 c2             	cmove  %edx,%eax
  800ecb:	eb 41                	jmp    800f0e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ecd:	83 ec 08             	sub    $0x8,%esp
  800ed0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed3:	50                   	push   %eax
  800ed4:	ff 36                	pushl  (%esi)
  800ed6:	e8 66 ff ff ff       	call   800e41 <dev_lookup>
  800edb:	89 c3                	mov    %eax,%ebx
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	78 1a                	js     800efe <fd_close+0x6a>
		if (dev->dev_close)
  800ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eea:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	74 0b                	je     800efe <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	56                   	push   %esi
  800ef7:	ff d0                	call   *%eax
  800ef9:	89 c3                	mov    %eax,%ebx
  800efb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	56                   	push   %esi
  800f02:	6a 00                	push   $0x0
  800f04:	e8 00 fd ff ff       	call   800c09 <sys_page_unmap>
	return r;
  800f09:	83 c4 10             	add    $0x10,%esp
  800f0c:	89 d8                	mov    %ebx,%eax
}
  800f0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1e:	50                   	push   %eax
  800f1f:	ff 75 08             	pushl  0x8(%ebp)
  800f22:	e8 c4 fe ff ff       	call   800deb <fd_lookup>
  800f27:	83 c4 08             	add    $0x8,%esp
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	78 10                	js     800f3e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f2e:	83 ec 08             	sub    $0x8,%esp
  800f31:	6a 01                	push   $0x1
  800f33:	ff 75 f4             	pushl  -0xc(%ebp)
  800f36:	e8 59 ff ff ff       	call   800e94 <fd_close>
  800f3b:	83 c4 10             	add    $0x10,%esp
}
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    

00800f40 <close_all>:

void
close_all(void)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	53                   	push   %ebx
  800f44:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f47:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	53                   	push   %ebx
  800f50:	e8 c0 ff ff ff       	call   800f15 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f55:	83 c3 01             	add    $0x1,%ebx
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	83 fb 20             	cmp    $0x20,%ebx
  800f5e:	75 ec                	jne    800f4c <close_all+0xc>
		close(i);
}
  800f60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
  800f6b:	83 ec 2c             	sub    $0x2c,%esp
  800f6e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	ff 75 08             	pushl  0x8(%ebp)
  800f78:	e8 6e fe ff ff       	call   800deb <fd_lookup>
  800f7d:	83 c4 08             	add    $0x8,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	0f 88 c1 00 00 00    	js     801049 <dup+0xe4>
		return r;
	close(newfdnum);
  800f88:	83 ec 0c             	sub    $0xc,%esp
  800f8b:	56                   	push   %esi
  800f8c:	e8 84 ff ff ff       	call   800f15 <close>

	newfd = INDEX2FD(newfdnum);
  800f91:	89 f3                	mov    %esi,%ebx
  800f93:	c1 e3 0c             	shl    $0xc,%ebx
  800f96:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f9c:	83 c4 04             	add    $0x4,%esp
  800f9f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa2:	e8 de fd ff ff       	call   800d85 <fd2data>
  800fa7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fa9:	89 1c 24             	mov    %ebx,(%esp)
  800fac:	e8 d4 fd ff ff       	call   800d85 <fd2data>
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb7:	89 f8                	mov    %edi,%eax
  800fb9:	c1 e8 16             	shr    $0x16,%eax
  800fbc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc3:	a8 01                	test   $0x1,%al
  800fc5:	74 37                	je     800ffe <dup+0x99>
  800fc7:	89 f8                	mov    %edi,%eax
  800fc9:	c1 e8 0c             	shr    $0xc,%eax
  800fcc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd3:	f6 c2 01             	test   $0x1,%dl
  800fd6:	74 26                	je     800ffe <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fd8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe7:	50                   	push   %eax
  800fe8:	ff 75 d4             	pushl  -0x2c(%ebp)
  800feb:	6a 00                	push   $0x0
  800fed:	57                   	push   %edi
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 d2 fb ff ff       	call   800bc7 <sys_page_map>
  800ff5:	89 c7                	mov    %eax,%edi
  800ff7:	83 c4 20             	add    $0x20,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	78 2e                	js     80102c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ffe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801001:	89 d0                	mov    %edx,%eax
  801003:	c1 e8 0c             	shr    $0xc,%eax
  801006:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	25 07 0e 00 00       	and    $0xe07,%eax
  801015:	50                   	push   %eax
  801016:	53                   	push   %ebx
  801017:	6a 00                	push   $0x0
  801019:	52                   	push   %edx
  80101a:	6a 00                	push   $0x0
  80101c:	e8 a6 fb ff ff       	call   800bc7 <sys_page_map>
  801021:	89 c7                	mov    %eax,%edi
  801023:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801026:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801028:	85 ff                	test   %edi,%edi
  80102a:	79 1d                	jns    801049 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	53                   	push   %ebx
  801030:	6a 00                	push   $0x0
  801032:	e8 d2 fb ff ff       	call   800c09 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801037:	83 c4 08             	add    $0x8,%esp
  80103a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103d:	6a 00                	push   $0x0
  80103f:	e8 c5 fb ff ff       	call   800c09 <sys_page_unmap>
	return r;
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	89 f8                	mov    %edi,%eax
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	53                   	push   %ebx
  801055:	83 ec 14             	sub    $0x14,%esp
  801058:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80105b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80105e:	50                   	push   %eax
  80105f:	53                   	push   %ebx
  801060:	e8 86 fd ff ff       	call   800deb <fd_lookup>
  801065:	83 c4 08             	add    $0x8,%esp
  801068:	89 c2                	mov    %eax,%edx
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 6d                	js     8010db <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106e:	83 ec 08             	sub    $0x8,%esp
  801071:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801074:	50                   	push   %eax
  801075:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801078:	ff 30                	pushl  (%eax)
  80107a:	e8 c2 fd ff ff       	call   800e41 <dev_lookup>
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	78 4c                	js     8010d2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801086:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801089:	8b 42 08             	mov    0x8(%edx),%eax
  80108c:	83 e0 03             	and    $0x3,%eax
  80108f:	83 f8 01             	cmp    $0x1,%eax
  801092:	75 21                	jne    8010b5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801094:	a1 04 40 80 00       	mov    0x804004,%eax
  801099:	8b 40 48             	mov    0x48(%eax),%eax
  80109c:	83 ec 04             	sub    $0x4,%esp
  80109f:	53                   	push   %ebx
  8010a0:	50                   	push   %eax
  8010a1:	68 0d 28 80 00       	push   $0x80280d
  8010a6:	e8 51 f1 ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010b3:	eb 26                	jmp    8010db <read+0x8a>
	}
	if (!dev->dev_read)
  8010b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b8:	8b 40 08             	mov    0x8(%eax),%eax
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	74 17                	je     8010d6 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8010bf:	83 ec 04             	sub    $0x4,%esp
  8010c2:	ff 75 10             	pushl  0x10(%ebp)
  8010c5:	ff 75 0c             	pushl  0xc(%ebp)
  8010c8:	52                   	push   %edx
  8010c9:	ff d0                	call   *%eax
  8010cb:	89 c2                	mov    %eax,%edx
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	eb 09                	jmp    8010db <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d2:	89 c2                	mov    %eax,%edx
  8010d4:	eb 05                	jmp    8010db <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010db:	89 d0                	mov    %edx,%eax
  8010dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f6:	eb 21                	jmp    801119 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f8:	83 ec 04             	sub    $0x4,%esp
  8010fb:	89 f0                	mov    %esi,%eax
  8010fd:	29 d8                	sub    %ebx,%eax
  8010ff:	50                   	push   %eax
  801100:	89 d8                	mov    %ebx,%eax
  801102:	03 45 0c             	add    0xc(%ebp),%eax
  801105:	50                   	push   %eax
  801106:	57                   	push   %edi
  801107:	e8 45 ff ff ff       	call   801051 <read>
		if (m < 0)
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 10                	js     801123 <readn+0x41>
			return m;
		if (m == 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	74 0a                	je     801121 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801117:	01 c3                	add    %eax,%ebx
  801119:	39 f3                	cmp    %esi,%ebx
  80111b:	72 db                	jb     8010f8 <readn+0x16>
  80111d:	89 d8                	mov    %ebx,%eax
  80111f:	eb 02                	jmp    801123 <readn+0x41>
  801121:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	53                   	push   %ebx
  80112f:	83 ec 14             	sub    $0x14,%esp
  801132:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801135:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801138:	50                   	push   %eax
  801139:	53                   	push   %ebx
  80113a:	e8 ac fc ff ff       	call   800deb <fd_lookup>
  80113f:	83 c4 08             	add    $0x8,%esp
  801142:	89 c2                	mov    %eax,%edx
  801144:	85 c0                	test   %eax,%eax
  801146:	78 68                	js     8011b0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801148:	83 ec 08             	sub    $0x8,%esp
  80114b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114e:	50                   	push   %eax
  80114f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801152:	ff 30                	pushl  (%eax)
  801154:	e8 e8 fc ff ff       	call   800e41 <dev_lookup>
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 47                	js     8011a7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801160:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801163:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801167:	75 21                	jne    80118a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801169:	a1 04 40 80 00       	mov    0x804004,%eax
  80116e:	8b 40 48             	mov    0x48(%eax),%eax
  801171:	83 ec 04             	sub    $0x4,%esp
  801174:	53                   	push   %ebx
  801175:	50                   	push   %eax
  801176:	68 29 28 80 00       	push   $0x802829
  80117b:	e8 7c f0 ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801188:	eb 26                	jmp    8011b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80118a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80118d:	8b 52 0c             	mov    0xc(%edx),%edx
  801190:	85 d2                	test   %edx,%edx
  801192:	74 17                	je     8011ab <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	ff 75 10             	pushl  0x10(%ebp)
  80119a:	ff 75 0c             	pushl  0xc(%ebp)
  80119d:	50                   	push   %eax
  80119e:	ff d2                	call   *%edx
  8011a0:	89 c2                	mov    %eax,%edx
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	eb 09                	jmp    8011b0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	eb 05                	jmp    8011b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011b0:	89 d0                	mov    %edx,%eax
  8011b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	ff 75 08             	pushl  0x8(%ebp)
  8011c4:	e8 22 fc ff ff       	call   800deb <fd_lookup>
  8011c9:	83 c4 08             	add    $0x8,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	78 0e                	js     8011de <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    

008011e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 14             	sub    $0x14,%esp
  8011e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	53                   	push   %ebx
  8011ef:	e8 f7 fb ff ff       	call   800deb <fd_lookup>
  8011f4:	83 c4 08             	add    $0x8,%esp
  8011f7:	89 c2                	mov    %eax,%edx
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 65                	js     801262 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fd:	83 ec 08             	sub    $0x8,%esp
  801200:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801203:	50                   	push   %eax
  801204:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801207:	ff 30                	pushl  (%eax)
  801209:	e8 33 fc ff ff       	call   800e41 <dev_lookup>
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 44                	js     801259 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801215:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801218:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121c:	75 21                	jne    80123f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80121e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801223:	8b 40 48             	mov    0x48(%eax),%eax
  801226:	83 ec 04             	sub    $0x4,%esp
  801229:	53                   	push   %ebx
  80122a:	50                   	push   %eax
  80122b:	68 ec 27 80 00       	push   $0x8027ec
  801230:	e8 c7 ef ff ff       	call   8001fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80123d:	eb 23                	jmp    801262 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80123f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801242:	8b 52 18             	mov    0x18(%edx),%edx
  801245:	85 d2                	test   %edx,%edx
  801247:	74 14                	je     80125d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	ff 75 0c             	pushl  0xc(%ebp)
  80124f:	50                   	push   %eax
  801250:	ff d2                	call   *%edx
  801252:	89 c2                	mov    %eax,%edx
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	eb 09                	jmp    801262 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801259:	89 c2                	mov    %eax,%edx
  80125b:	eb 05                	jmp    801262 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80125d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801262:	89 d0                	mov    %edx,%eax
  801264:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	53                   	push   %ebx
  80126d:	83 ec 14             	sub    $0x14,%esp
  801270:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801273:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801276:	50                   	push   %eax
  801277:	ff 75 08             	pushl  0x8(%ebp)
  80127a:	e8 6c fb ff ff       	call   800deb <fd_lookup>
  80127f:	83 c4 08             	add    $0x8,%esp
  801282:	89 c2                	mov    %eax,%edx
  801284:	85 c0                	test   %eax,%eax
  801286:	78 58                	js     8012e0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128e:	50                   	push   %eax
  80128f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801292:	ff 30                	pushl  (%eax)
  801294:	e8 a8 fb ff ff       	call   800e41 <dev_lookup>
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 37                	js     8012d7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a7:	74 32                	je     8012db <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b3:	00 00 00 
	stat->st_isdir = 0;
  8012b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012bd:	00 00 00 
	stat->st_dev = dev;
  8012c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	53                   	push   %ebx
  8012ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8012cd:	ff 50 14             	call   *0x14(%eax)
  8012d0:	89 c2                	mov    %eax,%edx
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	eb 09                	jmp    8012e0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d7:	89 c2                	mov    %eax,%edx
  8012d9:	eb 05                	jmp    8012e0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012e0:	89 d0                	mov    %edx,%eax
  8012e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e5:	c9                   	leave  
  8012e6:	c3                   	ret    

008012e7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	56                   	push   %esi
  8012eb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	6a 00                	push   $0x0
  8012f1:	ff 75 08             	pushl  0x8(%ebp)
  8012f4:	e8 e3 01 00 00       	call   8014dc <open>
  8012f9:	89 c3                	mov    %eax,%ebx
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 1b                	js     80131d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	ff 75 0c             	pushl  0xc(%ebp)
  801308:	50                   	push   %eax
  801309:	e8 5b ff ff ff       	call   801269 <fstat>
  80130e:	89 c6                	mov    %eax,%esi
	close(fd);
  801310:	89 1c 24             	mov    %ebx,(%esp)
  801313:	e8 fd fb ff ff       	call   800f15 <close>
	return r;
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	89 f0                	mov    %esi,%eax
}
  80131d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	89 c6                	mov    %eax,%esi
  80132b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80132d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801334:	75 12                	jne    801348 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801336:	83 ec 0c             	sub    $0xc,%esp
  801339:	6a 01                	push   $0x1
  80133b:	e8 d5 0d 00 00       	call   802115 <ipc_find_env>
  801340:	a3 00 40 80 00       	mov    %eax,0x804000
  801345:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801348:	6a 07                	push   $0x7
  80134a:	68 00 50 80 00       	push   $0x805000
  80134f:	56                   	push   %esi
  801350:	ff 35 00 40 80 00    	pushl  0x804000
  801356:	e8 58 0d 00 00       	call   8020b3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80135b:	83 c4 0c             	add    $0xc,%esp
  80135e:	6a 00                	push   $0x0
  801360:	53                   	push   %ebx
  801361:	6a 00                	push   $0x0
  801363:	e8 d9 0c 00 00       	call   802041 <ipc_recv>
}
  801368:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136b:	5b                   	pop    %ebx
  80136c:	5e                   	pop    %esi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801375:	8b 45 08             	mov    0x8(%ebp),%eax
  801378:	8b 40 0c             	mov    0xc(%eax),%eax
  80137b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801380:	8b 45 0c             	mov    0xc(%ebp),%eax
  801383:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801388:	ba 00 00 00 00       	mov    $0x0,%edx
  80138d:	b8 02 00 00 00       	mov    $0x2,%eax
  801392:	e8 8d ff ff ff       	call   801324 <fsipc>
}
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80139f:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8013af:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b4:	e8 6b ff ff ff       	call   801324 <fsipc>
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	53                   	push   %ebx
  8013bf:	83 ec 04             	sub    $0x4,%esp
  8013c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8013da:	e8 45 ff ff ff       	call   801324 <fsipc>
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 2c                	js     80140f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	68 00 50 80 00       	push   $0x805000
  8013eb:	53                   	push   %ebx
  8013ec:	e8 90 f3 ff ff       	call   800781 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f1:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013fc:	a1 84 50 80 00       	mov    0x805084,%eax
  801401:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	83 ec 0c             	sub    $0xc,%esp
  80141a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80141d:	8b 55 08             	mov    0x8(%ebp),%edx
  801420:	8b 52 0c             	mov    0xc(%edx),%edx
  801423:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801429:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80142e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801433:	0f 47 c2             	cmova  %edx,%eax
  801436:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80143b:	50                   	push   %eax
  80143c:	ff 75 0c             	pushl  0xc(%ebp)
  80143f:	68 08 50 80 00       	push   $0x805008
  801444:	e8 ca f4 ff ff       	call   800913 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801449:	ba 00 00 00 00       	mov    $0x0,%edx
  80144e:	b8 04 00 00 00       	mov    $0x4,%eax
  801453:	e8 cc fe ff ff       	call   801324 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	56                   	push   %esi
  80145e:	53                   	push   %ebx
  80145f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801462:	8b 45 08             	mov    0x8(%ebp),%eax
  801465:	8b 40 0c             	mov    0xc(%eax),%eax
  801468:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80146d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801473:	ba 00 00 00 00       	mov    $0x0,%edx
  801478:	b8 03 00 00 00       	mov    $0x3,%eax
  80147d:	e8 a2 fe ff ff       	call   801324 <fsipc>
  801482:	89 c3                	mov    %eax,%ebx
  801484:	85 c0                	test   %eax,%eax
  801486:	78 4b                	js     8014d3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801488:	39 c6                	cmp    %eax,%esi
  80148a:	73 16                	jae    8014a2 <devfile_read+0x48>
  80148c:	68 58 28 80 00       	push   $0x802858
  801491:	68 5f 28 80 00       	push   $0x80285f
  801496:	6a 7c                	push   $0x7c
  801498:	68 74 28 80 00       	push   $0x802874
  80149d:	e8 81 ec ff ff       	call   800123 <_panic>
	assert(r <= PGSIZE);
  8014a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014a7:	7e 16                	jle    8014bf <devfile_read+0x65>
  8014a9:	68 7f 28 80 00       	push   $0x80287f
  8014ae:	68 5f 28 80 00       	push   $0x80285f
  8014b3:	6a 7d                	push   $0x7d
  8014b5:	68 74 28 80 00       	push   $0x802874
  8014ba:	e8 64 ec ff ff       	call   800123 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	50                   	push   %eax
  8014c3:	68 00 50 80 00       	push   $0x805000
  8014c8:	ff 75 0c             	pushl  0xc(%ebp)
  8014cb:	e8 43 f4 ff ff       	call   800913 <memmove>
	return r;
  8014d0:	83 c4 10             	add    $0x10,%esp
}
  8014d3:	89 d8                	mov    %ebx,%eax
  8014d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 20             	sub    $0x20,%esp
  8014e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014e6:	53                   	push   %ebx
  8014e7:	e8 5c f2 ff ff       	call   800748 <strlen>
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014f4:	7f 67                	jg     80155d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	e8 9a f8 ff ff       	call   800d9c <fd_alloc>
  801502:	83 c4 10             	add    $0x10,%esp
		return r;
  801505:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801507:	85 c0                	test   %eax,%eax
  801509:	78 57                	js     801562 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	53                   	push   %ebx
  80150f:	68 00 50 80 00       	push   $0x805000
  801514:	e8 68 f2 ff ff       	call   800781 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801519:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801521:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801524:	b8 01 00 00 00       	mov    $0x1,%eax
  801529:	e8 f6 fd ff ff       	call   801324 <fsipc>
  80152e:	89 c3                	mov    %eax,%ebx
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	85 c0                	test   %eax,%eax
  801535:	79 14                	jns    80154b <open+0x6f>
		fd_close(fd, 0);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	6a 00                	push   $0x0
  80153c:	ff 75 f4             	pushl  -0xc(%ebp)
  80153f:	e8 50 f9 ff ff       	call   800e94 <fd_close>
		return r;
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	89 da                	mov    %ebx,%edx
  801549:	eb 17                	jmp    801562 <open+0x86>
	}

	return fd2num(fd);
  80154b:	83 ec 0c             	sub    $0xc,%esp
  80154e:	ff 75 f4             	pushl  -0xc(%ebp)
  801551:	e8 1f f8 ff ff       	call   800d75 <fd2num>
  801556:	89 c2                	mov    %eax,%edx
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	eb 05                	jmp    801562 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80155d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801562:	89 d0                	mov    %edx,%eax
  801564:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801567:	c9                   	leave  
  801568:	c3                   	ret    

00801569 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80156f:	ba 00 00 00 00       	mov    $0x0,%edx
  801574:	b8 08 00 00 00       	mov    $0x8,%eax
  801579:	e8 a6 fd ff ff       	call   801324 <fsipc>
}
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	57                   	push   %edi
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80158c:	6a 00                	push   $0x0
  80158e:	ff 75 08             	pushl  0x8(%ebp)
  801591:	e8 46 ff ff ff       	call   8014dc <open>
  801596:	89 c7                	mov    %eax,%edi
  801598:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	0f 88 89 04 00 00    	js     801a32 <spawn+0x4b2>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	68 00 02 00 00       	push   $0x200
  8015b1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015b7:	50                   	push   %eax
  8015b8:	57                   	push   %edi
  8015b9:	e8 24 fb ff ff       	call   8010e2 <readn>
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015c6:	75 0c                	jne    8015d4 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8015c8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015cf:	45 4c 46 
  8015d2:	74 33                	je     801607 <spawn+0x87>
		close(fd);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8015dd:	e8 33 f9 ff ff       	call   800f15 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015e2:	83 c4 0c             	add    $0xc,%esp
  8015e5:	68 7f 45 4c 46       	push   $0x464c457f
  8015ea:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8015f0:	68 8b 28 80 00       	push   $0x80288b
  8015f5:	e8 02 ec ff ff       	call   8001fc <cprintf>
		return -E_NOT_EXEC;
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801602:	e9 de 04 00 00       	jmp    801ae5 <spawn+0x565>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801607:	b8 07 00 00 00       	mov    $0x7,%eax
  80160c:	cd 30                	int    $0x30
  80160e:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801614:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80161a:	85 c0                	test   %eax,%eax
  80161c:	0f 88 1b 04 00 00    	js     801a3d <spawn+0x4bd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801622:	89 c6                	mov    %eax,%esi
  801624:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80162a:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80162d:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801633:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801639:	b9 11 00 00 00       	mov    $0x11,%ecx
  80163e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801640:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801646:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80164c:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801651:	be 00 00 00 00       	mov    $0x0,%esi
  801656:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801659:	eb 13                	jmp    80166e <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80165b:	83 ec 0c             	sub    $0xc,%esp
  80165e:	50                   	push   %eax
  80165f:	e8 e4 f0 ff ff       	call   800748 <strlen>
  801664:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801668:	83 c3 01             	add    $0x1,%ebx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801675:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801678:	85 c0                	test   %eax,%eax
  80167a:	75 df                	jne    80165b <spawn+0xdb>
  80167c:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801682:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801688:	bf 00 10 40 00       	mov    $0x401000,%edi
  80168d:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80168f:	89 fa                	mov    %edi,%edx
  801691:	83 e2 fc             	and    $0xfffffffc,%edx
  801694:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80169b:	29 c2                	sub    %eax,%edx
  80169d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016a3:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016a6:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016ab:	0f 86 a2 03 00 00    	jbe    801a53 <spawn+0x4d3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016b1:	83 ec 04             	sub    $0x4,%esp
  8016b4:	6a 07                	push   $0x7
  8016b6:	68 00 00 40 00       	push   $0x400000
  8016bb:	6a 00                	push   $0x0
  8016bd:	e8 c2 f4 ff ff       	call   800b84 <sys_page_alloc>
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	0f 88 90 03 00 00    	js     801a5d <spawn+0x4dd>
  8016cd:	be 00 00 00 00       	mov    $0x0,%esi
  8016d2:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8016d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016db:	eb 30                	jmp    80170d <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8016dd:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8016e3:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8016e9:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016f2:	57                   	push   %edi
  8016f3:	e8 89 f0 ff ff       	call   800781 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8016f8:	83 c4 04             	add    $0x4,%esp
  8016fb:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016fe:	e8 45 f0 ff ff       	call   800748 <strlen>
  801703:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801707:	83 c6 01             	add    $0x1,%esi
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801713:	7f c8                	jg     8016dd <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801715:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80171b:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801721:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801728:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80172e:	74 19                	je     801749 <spawn+0x1c9>
  801730:	68 18 29 80 00       	push   $0x802918
  801735:	68 5f 28 80 00       	push   $0x80285f
  80173a:	68 f2 00 00 00       	push   $0xf2
  80173f:	68 a5 28 80 00       	push   $0x8028a5
  801744:	e8 da e9 ff ff       	call   800123 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801749:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80174f:	89 f8                	mov    %edi,%eax
  801751:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801756:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801759:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80175f:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801762:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801768:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	6a 07                	push   $0x7
  801773:	68 00 d0 bf ee       	push   $0xeebfd000
  801778:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80177e:	68 00 00 40 00       	push   $0x400000
  801783:	6a 00                	push   $0x0
  801785:	e8 3d f4 ff ff       	call   800bc7 <sys_page_map>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	83 c4 20             	add    $0x20,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	0f 88 3c 03 00 00    	js     801ad3 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801797:	83 ec 08             	sub    $0x8,%esp
  80179a:	68 00 00 40 00       	push   $0x400000
  80179f:	6a 00                	push   $0x0
  8017a1:	e8 63 f4 ff ff       	call   800c09 <sys_page_unmap>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	0f 88 20 03 00 00    	js     801ad3 <spawn+0x553>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017b3:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017b9:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017c0:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017c6:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8017cd:	00 00 00 
  8017d0:	e9 88 01 00 00       	jmp    80195d <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8017d5:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8017db:	83 38 01             	cmpl   $0x1,(%eax)
  8017de:	0f 85 6b 01 00 00    	jne    80194f <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	8b 40 18             	mov    0x18(%eax),%eax
  8017e9:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8017ef:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8017f2:	83 f8 01             	cmp    $0x1,%eax
  8017f5:	19 c0                	sbb    %eax,%eax
  8017f7:	83 e0 fe             	and    $0xfffffffe,%eax
  8017fa:	83 c0 07             	add    $0x7,%eax
  8017fd:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801803:	89 d0                	mov    %edx,%eax
  801805:	8b 7a 04             	mov    0x4(%edx),%edi
  801808:	89 f9                	mov    %edi,%ecx
  80180a:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801810:	8b 7a 10             	mov    0x10(%edx),%edi
  801813:	8b 52 14             	mov    0x14(%edx),%edx
  801816:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  80181c:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80181f:	89 f0                	mov    %esi,%eax
  801821:	25 ff 0f 00 00       	and    $0xfff,%eax
  801826:	74 14                	je     80183c <spawn+0x2bc>
		va -= i;
  801828:	29 c6                	sub    %eax,%esi
		memsz += i;
  80182a:	01 c2                	add    %eax,%edx
  80182c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801832:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801834:	29 c1                	sub    %eax,%ecx
  801836:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80183c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801841:	e9 f7 00 00 00       	jmp    80193d <spawn+0x3bd>
		if (i >= filesz) {
  801846:	39 fb                	cmp    %edi,%ebx
  801848:	72 27                	jb     801871 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80184a:	83 ec 04             	sub    $0x4,%esp
  80184d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801853:	56                   	push   %esi
  801854:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80185a:	e8 25 f3 ff ff       	call   800b84 <sys_page_alloc>
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	0f 89 c7 00 00 00    	jns    801931 <spawn+0x3b1>
  80186a:	89 c3                	mov    %eax,%ebx
  80186c:	e9 fd 01 00 00       	jmp    801a6e <spawn+0x4ee>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	6a 07                	push   $0x7
  801876:	68 00 00 40 00       	push   $0x400000
  80187b:	6a 00                	push   $0x0
  80187d:	e8 02 f3 ff ff       	call   800b84 <sys_page_alloc>
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 88 d7 01 00 00    	js     801a64 <spawn+0x4e4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80188d:	83 ec 08             	sub    $0x8,%esp
  801890:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801896:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80189c:	50                   	push   %eax
  80189d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018a3:	e8 0f f9 ff ff       	call   8011b7 <seek>
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	0f 88 b5 01 00 00    	js     801a68 <spawn+0x4e8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018b3:	83 ec 04             	sub    $0x4,%esp
  8018b6:	89 f8                	mov    %edi,%eax
  8018b8:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018be:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c3:	ba 00 10 00 00       	mov    $0x1000,%edx
  8018c8:	0f 47 c2             	cmova  %edx,%eax
  8018cb:	50                   	push   %eax
  8018cc:	68 00 00 40 00       	push   $0x400000
  8018d1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018d7:	e8 06 f8 ff ff       	call   8010e2 <readn>
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	0f 88 85 01 00 00    	js     801a6c <spawn+0x4ec>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018f0:	56                   	push   %esi
  8018f1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018f7:	68 00 00 40 00       	push   $0x400000
  8018fc:	6a 00                	push   $0x0
  8018fe:	e8 c4 f2 ff ff       	call   800bc7 <sys_page_map>
  801903:	83 c4 20             	add    $0x20,%esp
  801906:	85 c0                	test   %eax,%eax
  801908:	79 15                	jns    80191f <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  80190a:	50                   	push   %eax
  80190b:	68 b1 28 80 00       	push   $0x8028b1
  801910:	68 25 01 00 00       	push   $0x125
  801915:	68 a5 28 80 00       	push   $0x8028a5
  80191a:	e8 04 e8 ff ff       	call   800123 <_panic>
			sys_page_unmap(0, UTEMP);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	68 00 00 40 00       	push   $0x400000
  801927:	6a 00                	push   $0x0
  801929:	e8 db f2 ff ff       	call   800c09 <sys_page_unmap>
  80192e:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801931:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801937:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80193d:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801943:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801949:	0f 82 f7 fe ff ff    	jb     801846 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80194f:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801956:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  80195d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801964:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80196a:	0f 8c 65 fe ff ff    	jl     8017d5 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801970:	83 ec 0c             	sub    $0xc,%esp
  801973:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801979:	e8 97 f5 ff ff       	call   800f15 <close>
  80197e:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  801981:	bb 00 00 00 00       	mov    $0x0,%ebx
  801986:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  80198c:	89 d8                	mov    %ebx,%eax
  80198e:	c1 e8 16             	shr    $0x16,%eax
  801991:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801998:	a8 01                	test   $0x1,%al
  80199a:	74 42                	je     8019de <spawn+0x45e>
  80199c:	89 d8                	mov    %ebx,%eax
  80199e:	c1 e8 0c             	shr    $0xc,%eax
  8019a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019a8:	f6 c2 01             	test   $0x1,%dl
  8019ab:	74 31                	je     8019de <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
  8019ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
		if (((uvpd[PDX(i)] & PTE_P) == PTE_P) && ((uvpt[PGNUM(i)] & PTE_P) == PTE_P) &&
  8019b4:	f6 c6 04             	test   $0x4,%dh
  8019b7:	74 25                	je     8019de <spawn+0x45e>
			((uvpt[PGNUM(i)] & PTE_SHARE) == PTE_SHARE)) {
			r = sys_page_map(0, (void*)i, child, (void*)i, uvpt[PGNUM(i)]&PTE_SYSCALL);
  8019b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019c0:	83 ec 0c             	sub    $0xc,%esp
  8019c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8019c8:	50                   	push   %eax
  8019c9:	53                   	push   %ebx
  8019ca:	56                   	push   %esi
  8019cb:	53                   	push   %ebx
  8019cc:	6a 00                	push   $0x0
  8019ce:	e8 f4 f1 ff ff       	call   800bc7 <sys_page_map>
			if (r < 0) {
  8019d3:	83 c4 20             	add    $0x20,%esp
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	0f 88 b1 00 00 00    	js     801a8f <spawn+0x50f>
{
	// LAB 5: Your code here.
	size_t i;
	int r;
	
	for (i = 0; i != UTOP; i += PGSIZE) {
  8019de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019e4:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8019ea:	75 a0                	jne    80198c <spawn+0x40c>
  8019ec:	e9 b3 00 00 00       	jmp    801aa4 <spawn+0x524>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8019f1:	50                   	push   %eax
  8019f2:	68 ce 28 80 00       	push   $0x8028ce
  8019f7:	68 86 00 00 00       	push   $0x86
  8019fc:	68 a5 28 80 00       	push   $0x8028a5
  801a01:	e8 1d e7 ff ff       	call   800123 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a06:	83 ec 08             	sub    $0x8,%esp
  801a09:	6a 02                	push   $0x2
  801a0b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a11:	e8 35 f2 ff ff       	call   800c4b <sys_env_set_status>
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	79 2b                	jns    801a48 <spawn+0x4c8>
		panic("sys_env_set_status: %e", r);
  801a1d:	50                   	push   %eax
  801a1e:	68 e8 28 80 00       	push   $0x8028e8
  801a23:	68 89 00 00 00       	push   $0x89
  801a28:	68 a5 28 80 00       	push   $0x8028a5
  801a2d:	e8 f1 e6 ff ff       	call   800123 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a32:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a38:	e9 a8 00 00 00       	jmp    801ae5 <spawn+0x565>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a3d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a43:	e9 9d 00 00 00       	jmp    801ae5 <spawn+0x565>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a48:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a4e:	e9 92 00 00 00       	jmp    801ae5 <spawn+0x565>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a53:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a58:	e9 88 00 00 00       	jmp    801ae5 <spawn+0x565>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a5d:	89 c3                	mov    %eax,%ebx
  801a5f:	e9 81 00 00 00       	jmp    801ae5 <spawn+0x565>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a64:	89 c3                	mov    %eax,%ebx
  801a66:	eb 06                	jmp    801a6e <spawn+0x4ee>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a68:	89 c3                	mov    %eax,%ebx
  801a6a:	eb 02                	jmp    801a6e <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a6c:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a77:	e8 89 f0 ff ff       	call   800b05 <sys_env_destroy>
	close(fd);
  801a7c:	83 c4 04             	add    $0x4,%esp
  801a7f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a85:	e8 8b f4 ff ff       	call   800f15 <close>
	return r;
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	eb 56                	jmp    801ae5 <spawn+0x565>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801a8f:	50                   	push   %eax
  801a90:	68 ff 28 80 00       	push   $0x8028ff
  801a95:	68 82 00 00 00       	push   $0x82
  801a9a:	68 a5 28 80 00       	push   $0x8028a5
  801a9f:	e8 7f e6 ff ff       	call   800123 <_panic>

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801aa4:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801aab:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801abe:	e8 ca f1 ff ff       	call   800c8d <sys_env_set_trapframe>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	0f 89 38 ff ff ff    	jns    801a06 <spawn+0x486>
  801ace:	e9 1e ff ff ff       	jmp    8019f1 <spawn+0x471>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ad3:	83 ec 08             	sub    $0x8,%esp
  801ad6:	68 00 00 40 00       	push   $0x400000
  801adb:	6a 00                	push   $0x0
  801add:	e8 27 f1 ff ff       	call   800c09 <sys_page_unmap>
  801ae2:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ae5:	89 d8                	mov    %ebx,%eax
  801ae7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5f                   	pop    %edi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801af4:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801afc:	eb 03                	jmp    801b01 <spawnl+0x12>
		argc++;
  801afe:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b01:	83 c2 04             	add    $0x4,%edx
  801b04:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b08:	75 f4                	jne    801afe <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b0a:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b11:	83 e2 f0             	and    $0xfffffff0,%edx
  801b14:	29 d4                	sub    %edx,%esp
  801b16:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b1a:	c1 ea 02             	shr    $0x2,%edx
  801b1d:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b24:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b29:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b30:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b37:	00 
  801b38:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3f:	eb 0a                	jmp    801b4b <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b41:	83 c0 01             	add    $0x1,%eax
  801b44:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b48:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b4b:	39 d0                	cmp    %edx,%eax
  801b4d:	75 f2                	jne    801b41 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b4f:	83 ec 08             	sub    $0x8,%esp
  801b52:	56                   	push   %esi
  801b53:	ff 75 08             	pushl  0x8(%ebp)
  801b56:	e8 25 fa ff ff       	call   801580 <spawn>
}
  801b5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5e:	5b                   	pop    %ebx
  801b5f:	5e                   	pop    %esi
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	56                   	push   %esi
  801b66:	53                   	push   %ebx
  801b67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b6a:	83 ec 0c             	sub    $0xc,%esp
  801b6d:	ff 75 08             	pushl  0x8(%ebp)
  801b70:	e8 10 f2 ff ff       	call   800d85 <fd2data>
  801b75:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b77:	83 c4 08             	add    $0x8,%esp
  801b7a:	68 40 29 80 00       	push   $0x802940
  801b7f:	53                   	push   %ebx
  801b80:	e8 fc eb ff ff       	call   800781 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b85:	8b 46 04             	mov    0x4(%esi),%eax
  801b88:	2b 06                	sub    (%esi),%eax
  801b8a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b90:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b97:	00 00 00 
	stat->st_dev = &devpipe;
  801b9a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ba1:	30 80 00 
	return 0;
}
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bac:	5b                   	pop    %ebx
  801bad:	5e                   	pop    %esi
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    

00801bb0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 0c             	sub    $0xc,%esp
  801bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bba:	53                   	push   %ebx
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 47 f0 ff ff       	call   800c09 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc2:	89 1c 24             	mov    %ebx,(%esp)
  801bc5:	e8 bb f1 ff ff       	call   800d85 <fd2data>
  801bca:	83 c4 08             	add    $0x8,%esp
  801bcd:	50                   	push   %eax
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 34 f0 ff ff       	call   800c09 <sys_page_unmap>
}
  801bd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	57                   	push   %edi
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 1c             	sub    $0x1c,%esp
  801be3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801be6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801be8:	a1 04 40 80 00       	mov    0x804004,%eax
  801bed:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	ff 75 e0             	pushl  -0x20(%ebp)
  801bf6:	e8 53 05 00 00       	call   80214e <pageref>
  801bfb:	89 c3                	mov    %eax,%ebx
  801bfd:	89 3c 24             	mov    %edi,(%esp)
  801c00:	e8 49 05 00 00       	call   80214e <pageref>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	39 c3                	cmp    %eax,%ebx
  801c0a:	0f 94 c1             	sete   %cl
  801c0d:	0f b6 c9             	movzbl %cl,%ecx
  801c10:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c13:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c19:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c1c:	39 ce                	cmp    %ecx,%esi
  801c1e:	74 1b                	je     801c3b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c20:	39 c3                	cmp    %eax,%ebx
  801c22:	75 c4                	jne    801be8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c24:	8b 42 58             	mov    0x58(%edx),%eax
  801c27:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c2a:	50                   	push   %eax
  801c2b:	56                   	push   %esi
  801c2c:	68 47 29 80 00       	push   $0x802947
  801c31:	e8 c6 e5 ff ff       	call   8001fc <cprintf>
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	eb ad                	jmp    801be8 <_pipeisclosed+0xe>
	}
}
  801c3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	57                   	push   %edi
  801c4a:	56                   	push   %esi
  801c4b:	53                   	push   %ebx
  801c4c:	83 ec 28             	sub    $0x28,%esp
  801c4f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c52:	56                   	push   %esi
  801c53:	e8 2d f1 ff ff       	call   800d85 <fd2data>
  801c58:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	bf 00 00 00 00       	mov    $0x0,%edi
  801c62:	eb 4b                	jmp    801caf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c64:	89 da                	mov    %ebx,%edx
  801c66:	89 f0                	mov    %esi,%eax
  801c68:	e8 6d ff ff ff       	call   801bda <_pipeisclosed>
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	75 48                	jne    801cb9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c71:	e8 ef ee ff ff       	call   800b65 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c76:	8b 43 04             	mov    0x4(%ebx),%eax
  801c79:	8b 0b                	mov    (%ebx),%ecx
  801c7b:	8d 51 20             	lea    0x20(%ecx),%edx
  801c7e:	39 d0                	cmp    %edx,%eax
  801c80:	73 e2                	jae    801c64 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c85:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c89:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c8c:	89 c2                	mov    %eax,%edx
  801c8e:	c1 fa 1f             	sar    $0x1f,%edx
  801c91:	89 d1                	mov    %edx,%ecx
  801c93:	c1 e9 1b             	shr    $0x1b,%ecx
  801c96:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c99:	83 e2 1f             	and    $0x1f,%edx
  801c9c:	29 ca                	sub    %ecx,%edx
  801c9e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ca2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca6:	83 c0 01             	add    $0x1,%eax
  801ca9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cac:	83 c7 01             	add    $0x1,%edi
  801caf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cb2:	75 c2                	jne    801c76 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cb4:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb7:	eb 05                	jmp    801cbe <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc1:	5b                   	pop    %ebx
  801cc2:	5e                   	pop    %esi
  801cc3:	5f                   	pop    %edi
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	57                   	push   %edi
  801cca:	56                   	push   %esi
  801ccb:	53                   	push   %ebx
  801ccc:	83 ec 18             	sub    $0x18,%esp
  801ccf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cd2:	57                   	push   %edi
  801cd3:	e8 ad f0 ff ff       	call   800d85 <fd2data>
  801cd8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce2:	eb 3d                	jmp    801d21 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ce4:	85 db                	test   %ebx,%ebx
  801ce6:	74 04                	je     801cec <devpipe_read+0x26>
				return i;
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	eb 44                	jmp    801d30 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cec:	89 f2                	mov    %esi,%edx
  801cee:	89 f8                	mov    %edi,%eax
  801cf0:	e8 e5 fe ff ff       	call   801bda <_pipeisclosed>
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	75 32                	jne    801d2b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cf9:	e8 67 ee ff ff       	call   800b65 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cfe:	8b 06                	mov    (%esi),%eax
  801d00:	3b 46 04             	cmp    0x4(%esi),%eax
  801d03:	74 df                	je     801ce4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d05:	99                   	cltd   
  801d06:	c1 ea 1b             	shr    $0x1b,%edx
  801d09:	01 d0                	add    %edx,%eax
  801d0b:	83 e0 1f             	and    $0x1f,%eax
  801d0e:	29 d0                	sub    %edx,%eax
  801d10:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d18:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d1b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d1e:	83 c3 01             	add    $0x1,%ebx
  801d21:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d24:	75 d8                	jne    801cfe <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d26:	8b 45 10             	mov    0x10(%ebp),%eax
  801d29:	eb 05                	jmp    801d30 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d2b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	56                   	push   %esi
  801d3c:	53                   	push   %ebx
  801d3d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d43:	50                   	push   %eax
  801d44:	e8 53 f0 ff ff       	call   800d9c <fd_alloc>
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	89 c2                	mov    %eax,%edx
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	0f 88 2c 01 00 00    	js     801e82 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d56:	83 ec 04             	sub    $0x4,%esp
  801d59:	68 07 04 00 00       	push   $0x407
  801d5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d61:	6a 00                	push   $0x0
  801d63:	e8 1c ee ff ff       	call   800b84 <sys_page_alloc>
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	89 c2                	mov    %eax,%edx
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	0f 88 0d 01 00 00    	js     801e82 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d75:	83 ec 0c             	sub    $0xc,%esp
  801d78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d7b:	50                   	push   %eax
  801d7c:	e8 1b f0 ff ff       	call   800d9c <fd_alloc>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	85 c0                	test   %eax,%eax
  801d88:	0f 88 e2 00 00 00    	js     801e70 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8e:	83 ec 04             	sub    $0x4,%esp
  801d91:	68 07 04 00 00       	push   $0x407
  801d96:	ff 75 f0             	pushl  -0x10(%ebp)
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 e4 ed ff ff       	call   800b84 <sys_page_alloc>
  801da0:	89 c3                	mov    %eax,%ebx
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	0f 88 c3 00 00 00    	js     801e70 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dad:	83 ec 0c             	sub    $0xc,%esp
  801db0:	ff 75 f4             	pushl  -0xc(%ebp)
  801db3:	e8 cd ef ff ff       	call   800d85 <fd2data>
  801db8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dba:	83 c4 0c             	add    $0xc,%esp
  801dbd:	68 07 04 00 00       	push   $0x407
  801dc2:	50                   	push   %eax
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 ba ed ff ff       	call   800b84 <sys_page_alloc>
  801dca:	89 c3                	mov    %eax,%ebx
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	0f 88 89 00 00 00    	js     801e60 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd7:	83 ec 0c             	sub    $0xc,%esp
  801dda:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddd:	e8 a3 ef ff ff       	call   800d85 <fd2data>
  801de2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801de9:	50                   	push   %eax
  801dea:	6a 00                	push   $0x0
  801dec:	56                   	push   %esi
  801ded:	6a 00                	push   $0x0
  801def:	e8 d3 ed ff ff       	call   800bc7 <sys_page_map>
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	83 c4 20             	add    $0x20,%esp
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	78 55                	js     801e52 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dfd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e06:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e12:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e20:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e27:	83 ec 0c             	sub    $0xc,%esp
  801e2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2d:	e8 43 ef ff ff       	call   800d75 <fd2num>
  801e32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e35:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e37:	83 c4 04             	add    $0x4,%esp
  801e3a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3d:	e8 33 ef ff ff       	call   800d75 <fd2num>
  801e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e45:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e50:	eb 30                	jmp    801e82 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e52:	83 ec 08             	sub    $0x8,%esp
  801e55:	56                   	push   %esi
  801e56:	6a 00                	push   $0x0
  801e58:	e8 ac ed ff ff       	call   800c09 <sys_page_unmap>
  801e5d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e60:	83 ec 08             	sub    $0x8,%esp
  801e63:	ff 75 f0             	pushl  -0x10(%ebp)
  801e66:	6a 00                	push   $0x0
  801e68:	e8 9c ed ff ff       	call   800c09 <sys_page_unmap>
  801e6d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e70:	83 ec 08             	sub    $0x8,%esp
  801e73:	ff 75 f4             	pushl  -0xc(%ebp)
  801e76:	6a 00                	push   $0x0
  801e78:	e8 8c ed ff ff       	call   800c09 <sys_page_unmap>
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e82:	89 d0                	mov    %edx,%eax
  801e84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e87:	5b                   	pop    %ebx
  801e88:	5e                   	pop    %esi
  801e89:	5d                   	pop    %ebp
  801e8a:	c3                   	ret    

00801e8b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e94:	50                   	push   %eax
  801e95:	ff 75 08             	pushl  0x8(%ebp)
  801e98:	e8 4e ef ff ff       	call   800deb <fd_lookup>
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	78 18                	js     801ebc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ea4:	83 ec 0c             	sub    $0xc,%esp
  801ea7:	ff 75 f4             	pushl  -0xc(%ebp)
  801eaa:	e8 d6 ee ff ff       	call   800d85 <fd2data>
	return _pipeisclosed(fd, p);
  801eaf:	89 c2                	mov    %eax,%edx
  801eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb4:	e8 21 fd ff ff       	call   801bda <_pipeisclosed>
  801eb9:	83 c4 10             	add    $0x10,%esp
}
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ece:	68 5f 29 80 00       	push   $0x80295f
  801ed3:	ff 75 0c             	pushl  0xc(%ebp)
  801ed6:	e8 a6 e8 ff ff       	call   800781 <strcpy>
	return 0;
}
  801edb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	57                   	push   %edi
  801ee6:	56                   	push   %esi
  801ee7:	53                   	push   %ebx
  801ee8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eee:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef9:	eb 2d                	jmp    801f28 <devcons_write+0x46>
		m = n - tot;
  801efb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801efe:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f00:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f03:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f08:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f0b:	83 ec 04             	sub    $0x4,%esp
  801f0e:	53                   	push   %ebx
  801f0f:	03 45 0c             	add    0xc(%ebp),%eax
  801f12:	50                   	push   %eax
  801f13:	57                   	push   %edi
  801f14:	e8 fa e9 ff ff       	call   800913 <memmove>
		sys_cputs(buf, m);
  801f19:	83 c4 08             	add    $0x8,%esp
  801f1c:	53                   	push   %ebx
  801f1d:	57                   	push   %edi
  801f1e:	e8 a5 eb ff ff       	call   800ac8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f23:	01 de                	add    %ebx,%esi
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	89 f0                	mov    %esi,%eax
  801f2a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f2d:	72 cc                	jb     801efb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f32:	5b                   	pop    %ebx
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 08             	sub    $0x8,%esp
  801f3d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f46:	74 2a                	je     801f72 <devcons_read+0x3b>
  801f48:	eb 05                	jmp    801f4f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f4a:	e8 16 ec ff ff       	call   800b65 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f4f:	e8 92 eb ff ff       	call   800ae6 <sys_cgetc>
  801f54:	85 c0                	test   %eax,%eax
  801f56:	74 f2                	je     801f4a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	78 16                	js     801f72 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f5c:	83 f8 04             	cmp    $0x4,%eax
  801f5f:	74 0c                	je     801f6d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f61:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f64:	88 02                	mov    %al,(%edx)
	return 1;
  801f66:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6b:	eb 05                	jmp    801f72 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f6d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f72:	c9                   	leave  
  801f73:	c3                   	ret    

00801f74 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f80:	6a 01                	push   $0x1
  801f82:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f85:	50                   	push   %eax
  801f86:	e8 3d eb ff ff       	call   800ac8 <sys_cputs>
}
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	c9                   	leave  
  801f8f:	c3                   	ret    

00801f90 <getchar>:

int
getchar(void)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f96:	6a 01                	push   $0x1
  801f98:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f9b:	50                   	push   %eax
  801f9c:	6a 00                	push   $0x0
  801f9e:	e8 ae f0 ff ff       	call   801051 <read>
	if (r < 0)
  801fa3:	83 c4 10             	add    $0x10,%esp
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	78 0f                	js     801fb9 <getchar+0x29>
		return r;
	if (r < 1)
  801faa:	85 c0                	test   %eax,%eax
  801fac:	7e 06                	jle    801fb4 <getchar+0x24>
		return -E_EOF;
	return c;
  801fae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fb2:	eb 05                	jmp    801fb9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fb4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fb9:	c9                   	leave  
  801fba:	c3                   	ret    

00801fbb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc4:	50                   	push   %eax
  801fc5:	ff 75 08             	pushl  0x8(%ebp)
  801fc8:	e8 1e ee ff ff       	call   800deb <fd_lookup>
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	78 11                	js     801fe5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fdd:	39 10                	cmp    %edx,(%eax)
  801fdf:	0f 94 c0             	sete   %al
  801fe2:	0f b6 c0             	movzbl %al,%eax
}
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    

00801fe7 <opencons>:

int
opencons(void)
{
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff0:	50                   	push   %eax
  801ff1:	e8 a6 ed ff ff       	call   800d9c <fd_alloc>
  801ff6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	78 3e                	js     80203d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fff:	83 ec 04             	sub    $0x4,%esp
  802002:	68 07 04 00 00       	push   $0x407
  802007:	ff 75 f4             	pushl  -0xc(%ebp)
  80200a:	6a 00                	push   $0x0
  80200c:	e8 73 eb ff ff       	call   800b84 <sys_page_alloc>
  802011:	83 c4 10             	add    $0x10,%esp
		return r;
  802014:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802016:	85 c0                	test   %eax,%eax
  802018:	78 23                	js     80203d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80201a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802023:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802028:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80202f:	83 ec 0c             	sub    $0xc,%esp
  802032:	50                   	push   %eax
  802033:	e8 3d ed ff ff       	call   800d75 <fd2num>
  802038:	89 c2                	mov    %eax,%edx
  80203a:	83 c4 10             	add    $0x10,%esp
}
  80203d:	89 d0                	mov    %edx,%eax
  80203f:	c9                   	leave  
  802040:	c3                   	ret    

00802041 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	56                   	push   %esi
  802045:	53                   	push   %ebx
  802046:	8b 75 08             	mov    0x8(%ebp),%esi
  802049:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80204f:	85 c0                	test   %eax,%eax
  802051:	75 12                	jne    802065 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802053:	83 ec 0c             	sub    $0xc,%esp
  802056:	68 00 00 c0 ee       	push   $0xeec00000
  80205b:	e8 d4 ec ff ff       	call   800d34 <sys_ipc_recv>
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	eb 0c                	jmp    802071 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802065:	83 ec 0c             	sub    $0xc,%esp
  802068:	50                   	push   %eax
  802069:	e8 c6 ec ff ff       	call   800d34 <sys_ipc_recv>
  80206e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802071:	85 f6                	test   %esi,%esi
  802073:	0f 95 c1             	setne  %cl
  802076:	85 db                	test   %ebx,%ebx
  802078:	0f 95 c2             	setne  %dl
  80207b:	84 d1                	test   %dl,%cl
  80207d:	74 09                	je     802088 <ipc_recv+0x47>
  80207f:	89 c2                	mov    %eax,%edx
  802081:	c1 ea 1f             	shr    $0x1f,%edx
  802084:	84 d2                	test   %dl,%dl
  802086:	75 24                	jne    8020ac <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802088:	85 f6                	test   %esi,%esi
  80208a:	74 0a                	je     802096 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80208c:	a1 04 40 80 00       	mov    0x804004,%eax
  802091:	8b 40 74             	mov    0x74(%eax),%eax
  802094:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802096:	85 db                	test   %ebx,%ebx
  802098:	74 0a                	je     8020a4 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  80209a:	a1 04 40 80 00       	mov    0x804004,%eax
  80209f:	8b 40 78             	mov    0x78(%eax),%eax
  8020a2:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a9:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    

008020b3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	57                   	push   %edi
  8020b7:	56                   	push   %esi
  8020b8:	53                   	push   %ebx
  8020b9:	83 ec 0c             	sub    $0xc,%esp
  8020bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020c5:	85 db                	test   %ebx,%ebx
  8020c7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020cc:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020cf:	ff 75 14             	pushl  0x14(%ebp)
  8020d2:	53                   	push   %ebx
  8020d3:	56                   	push   %esi
  8020d4:	57                   	push   %edi
  8020d5:	e8 37 ec ff ff       	call   800d11 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020da:	89 c2                	mov    %eax,%edx
  8020dc:	c1 ea 1f             	shr    $0x1f,%edx
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	84 d2                	test   %dl,%dl
  8020e4:	74 17                	je     8020fd <ipc_send+0x4a>
  8020e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020e9:	74 12                	je     8020fd <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020eb:	50                   	push   %eax
  8020ec:	68 6b 29 80 00       	push   $0x80296b
  8020f1:	6a 47                	push   $0x47
  8020f3:	68 79 29 80 00       	push   $0x802979
  8020f8:	e8 26 e0 ff ff       	call   800123 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020fd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802100:	75 07                	jne    802109 <ipc_send+0x56>
			sys_yield();
  802102:	e8 5e ea ff ff       	call   800b65 <sys_yield>
  802107:	eb c6                	jmp    8020cf <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802109:	85 c0                	test   %eax,%eax
  80210b:	75 c2                	jne    8020cf <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80210d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802110:	5b                   	pop    %ebx
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    

00802115 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80211b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802120:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802123:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802129:	8b 52 50             	mov    0x50(%edx),%edx
  80212c:	39 ca                	cmp    %ecx,%edx
  80212e:	75 0d                	jne    80213d <ipc_find_env+0x28>
			return envs[i].env_id;
  802130:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802133:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802138:	8b 40 48             	mov    0x48(%eax),%eax
  80213b:	eb 0f                	jmp    80214c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80213d:	83 c0 01             	add    $0x1,%eax
  802140:	3d 00 04 00 00       	cmp    $0x400,%eax
  802145:	75 d9                	jne    802120 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802147:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    

0080214e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802154:	89 d0                	mov    %edx,%eax
  802156:	c1 e8 16             	shr    $0x16,%eax
  802159:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802160:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802165:	f6 c1 01             	test   $0x1,%cl
  802168:	74 1d                	je     802187 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80216a:	c1 ea 0c             	shr    $0xc,%edx
  80216d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802174:	f6 c2 01             	test   $0x1,%dl
  802177:	74 0e                	je     802187 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802179:	c1 ea 0c             	shr    $0xc,%edx
  80217c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802183:	ef 
  802184:	0f b7 c0             	movzwl %ax,%eax
}
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	66 90                	xchg   %ax,%ax
  80218b:	66 90                	xchg   %ax,%ax
  80218d:	66 90                	xchg   %ax,%ax
  80218f:	90                   	nop

00802190 <__udivdi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80219b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80219f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 f6                	test   %esi,%esi
  8021a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ad:	89 ca                	mov    %ecx,%edx
  8021af:	89 f8                	mov    %edi,%eax
  8021b1:	75 3d                	jne    8021f0 <__udivdi3+0x60>
  8021b3:	39 cf                	cmp    %ecx,%edi
  8021b5:	0f 87 c5 00 00 00    	ja     802280 <__udivdi3+0xf0>
  8021bb:	85 ff                	test   %edi,%edi
  8021bd:	89 fd                	mov    %edi,%ebp
  8021bf:	75 0b                	jne    8021cc <__udivdi3+0x3c>
  8021c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c6:	31 d2                	xor    %edx,%edx
  8021c8:	f7 f7                	div    %edi
  8021ca:	89 c5                	mov    %eax,%ebp
  8021cc:	89 c8                	mov    %ecx,%eax
  8021ce:	31 d2                	xor    %edx,%edx
  8021d0:	f7 f5                	div    %ebp
  8021d2:	89 c1                	mov    %eax,%ecx
  8021d4:	89 d8                	mov    %ebx,%eax
  8021d6:	89 cf                	mov    %ecx,%edi
  8021d8:	f7 f5                	div    %ebp
  8021da:	89 c3                	mov    %eax,%ebx
  8021dc:	89 d8                	mov    %ebx,%eax
  8021de:	89 fa                	mov    %edi,%edx
  8021e0:	83 c4 1c             	add    $0x1c,%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5f                   	pop    %edi
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
  8021e8:	90                   	nop
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	39 ce                	cmp    %ecx,%esi
  8021f2:	77 74                	ja     802268 <__udivdi3+0xd8>
  8021f4:	0f bd fe             	bsr    %esi,%edi
  8021f7:	83 f7 1f             	xor    $0x1f,%edi
  8021fa:	0f 84 98 00 00 00    	je     802298 <__udivdi3+0x108>
  802200:	bb 20 00 00 00       	mov    $0x20,%ebx
  802205:	89 f9                	mov    %edi,%ecx
  802207:	89 c5                	mov    %eax,%ebp
  802209:	29 fb                	sub    %edi,%ebx
  80220b:	d3 e6                	shl    %cl,%esi
  80220d:	89 d9                	mov    %ebx,%ecx
  80220f:	d3 ed                	shr    %cl,%ebp
  802211:	89 f9                	mov    %edi,%ecx
  802213:	d3 e0                	shl    %cl,%eax
  802215:	09 ee                	or     %ebp,%esi
  802217:	89 d9                	mov    %ebx,%ecx
  802219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80221d:	89 d5                	mov    %edx,%ebp
  80221f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802223:	d3 ed                	shr    %cl,%ebp
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e2                	shl    %cl,%edx
  802229:	89 d9                	mov    %ebx,%ecx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	09 c2                	or     %eax,%edx
  80222f:	89 d0                	mov    %edx,%eax
  802231:	89 ea                	mov    %ebp,%edx
  802233:	f7 f6                	div    %esi
  802235:	89 d5                	mov    %edx,%ebp
  802237:	89 c3                	mov    %eax,%ebx
  802239:	f7 64 24 0c          	mull   0xc(%esp)
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	72 10                	jb     802251 <__udivdi3+0xc1>
  802241:	8b 74 24 08          	mov    0x8(%esp),%esi
  802245:	89 f9                	mov    %edi,%ecx
  802247:	d3 e6                	shl    %cl,%esi
  802249:	39 c6                	cmp    %eax,%esi
  80224b:	73 07                	jae    802254 <__udivdi3+0xc4>
  80224d:	39 d5                	cmp    %edx,%ebp
  80224f:	75 03                	jne    802254 <__udivdi3+0xc4>
  802251:	83 eb 01             	sub    $0x1,%ebx
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 d8                	mov    %ebx,%eax
  802258:	89 fa                	mov    %edi,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	31 ff                	xor    %edi,%edi
  80226a:	31 db                	xor    %ebx,%ebx
  80226c:	89 d8                	mov    %ebx,%eax
  80226e:	89 fa                	mov    %edi,%edx
  802270:	83 c4 1c             	add    $0x1c,%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	90                   	nop
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	89 d8                	mov    %ebx,%eax
  802282:	f7 f7                	div    %edi
  802284:	31 ff                	xor    %edi,%edi
  802286:	89 c3                	mov    %eax,%ebx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 fa                	mov    %edi,%edx
  80228c:	83 c4 1c             	add    $0x1c,%esp
  80228f:	5b                   	pop    %ebx
  802290:	5e                   	pop    %esi
  802291:	5f                   	pop    %edi
  802292:	5d                   	pop    %ebp
  802293:	c3                   	ret    
  802294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802298:	39 ce                	cmp    %ecx,%esi
  80229a:	72 0c                	jb     8022a8 <__udivdi3+0x118>
  80229c:	31 db                	xor    %ebx,%ebx
  80229e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022a2:	0f 87 34 ff ff ff    	ja     8021dc <__udivdi3+0x4c>
  8022a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ad:	e9 2a ff ff ff       	jmp    8021dc <__udivdi3+0x4c>
  8022b2:	66 90                	xchg   %ax,%ax
  8022b4:	66 90                	xchg   %ax,%ax
  8022b6:	66 90                	xchg   %ax,%ax
  8022b8:	66 90                	xchg   %ax,%ax
  8022ba:	66 90                	xchg   %ax,%ax
  8022bc:	66 90                	xchg   %ax,%ax
  8022be:	66 90                	xchg   %ax,%ax

008022c0 <__umoddi3>:
  8022c0:	55                   	push   %ebp
  8022c1:	57                   	push   %edi
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	83 ec 1c             	sub    $0x1c,%esp
  8022c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022d7:	85 d2                	test   %edx,%edx
  8022d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022e1:	89 f3                	mov    %esi,%ebx
  8022e3:	89 3c 24             	mov    %edi,(%esp)
  8022e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ea:	75 1c                	jne    802308 <__umoddi3+0x48>
  8022ec:	39 f7                	cmp    %esi,%edi
  8022ee:	76 50                	jbe    802340 <__umoddi3+0x80>
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	f7 f7                	div    %edi
  8022f6:	89 d0                	mov    %edx,%eax
  8022f8:	31 d2                	xor    %edx,%edx
  8022fa:	83 c4 1c             	add    $0x1c,%esp
  8022fd:	5b                   	pop    %ebx
  8022fe:	5e                   	pop    %esi
  8022ff:	5f                   	pop    %edi
  802300:	5d                   	pop    %ebp
  802301:	c3                   	ret    
  802302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802308:	39 f2                	cmp    %esi,%edx
  80230a:	89 d0                	mov    %edx,%eax
  80230c:	77 52                	ja     802360 <__umoddi3+0xa0>
  80230e:	0f bd ea             	bsr    %edx,%ebp
  802311:	83 f5 1f             	xor    $0x1f,%ebp
  802314:	75 5a                	jne    802370 <__umoddi3+0xb0>
  802316:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80231a:	0f 82 e0 00 00 00    	jb     802400 <__umoddi3+0x140>
  802320:	39 0c 24             	cmp    %ecx,(%esp)
  802323:	0f 86 d7 00 00 00    	jbe    802400 <__umoddi3+0x140>
  802329:	8b 44 24 08          	mov    0x8(%esp),%eax
  80232d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802331:	83 c4 1c             	add    $0x1c,%esp
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5f                   	pop    %edi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	85 ff                	test   %edi,%edi
  802342:	89 fd                	mov    %edi,%ebp
  802344:	75 0b                	jne    802351 <__umoddi3+0x91>
  802346:	b8 01 00 00 00       	mov    $0x1,%eax
  80234b:	31 d2                	xor    %edx,%edx
  80234d:	f7 f7                	div    %edi
  80234f:	89 c5                	mov    %eax,%ebp
  802351:	89 f0                	mov    %esi,%eax
  802353:	31 d2                	xor    %edx,%edx
  802355:	f7 f5                	div    %ebp
  802357:	89 c8                	mov    %ecx,%eax
  802359:	f7 f5                	div    %ebp
  80235b:	89 d0                	mov    %edx,%eax
  80235d:	eb 99                	jmp    8022f8 <__umoddi3+0x38>
  80235f:	90                   	nop
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	83 c4 1c             	add    $0x1c,%esp
  802367:	5b                   	pop    %ebx
  802368:	5e                   	pop    %esi
  802369:	5f                   	pop    %edi
  80236a:	5d                   	pop    %ebp
  80236b:	c3                   	ret    
  80236c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802370:	8b 34 24             	mov    (%esp),%esi
  802373:	bf 20 00 00 00       	mov    $0x20,%edi
  802378:	89 e9                	mov    %ebp,%ecx
  80237a:	29 ef                	sub    %ebp,%edi
  80237c:	d3 e0                	shl    %cl,%eax
  80237e:	89 f9                	mov    %edi,%ecx
  802380:	89 f2                	mov    %esi,%edx
  802382:	d3 ea                	shr    %cl,%edx
  802384:	89 e9                	mov    %ebp,%ecx
  802386:	09 c2                	or     %eax,%edx
  802388:	89 d8                	mov    %ebx,%eax
  80238a:	89 14 24             	mov    %edx,(%esp)
  80238d:	89 f2                	mov    %esi,%edx
  80238f:	d3 e2                	shl    %cl,%edx
  802391:	89 f9                	mov    %edi,%ecx
  802393:	89 54 24 04          	mov    %edx,0x4(%esp)
  802397:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	89 e9                	mov    %ebp,%ecx
  80239f:	89 c6                	mov    %eax,%esi
  8023a1:	d3 e3                	shl    %cl,%ebx
  8023a3:	89 f9                	mov    %edi,%ecx
  8023a5:	89 d0                	mov    %edx,%eax
  8023a7:	d3 e8                	shr    %cl,%eax
  8023a9:	89 e9                	mov    %ebp,%ecx
  8023ab:	09 d8                	or     %ebx,%eax
  8023ad:	89 d3                	mov    %edx,%ebx
  8023af:	89 f2                	mov    %esi,%edx
  8023b1:	f7 34 24             	divl   (%esp)
  8023b4:	89 d6                	mov    %edx,%esi
  8023b6:	d3 e3                	shl    %cl,%ebx
  8023b8:	f7 64 24 04          	mull   0x4(%esp)
  8023bc:	39 d6                	cmp    %edx,%esi
  8023be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023c2:	89 d1                	mov    %edx,%ecx
  8023c4:	89 c3                	mov    %eax,%ebx
  8023c6:	72 08                	jb     8023d0 <__umoddi3+0x110>
  8023c8:	75 11                	jne    8023db <__umoddi3+0x11b>
  8023ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ce:	73 0b                	jae    8023db <__umoddi3+0x11b>
  8023d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023d4:	1b 14 24             	sbb    (%esp),%edx
  8023d7:	89 d1                	mov    %edx,%ecx
  8023d9:	89 c3                	mov    %eax,%ebx
  8023db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023df:	29 da                	sub    %ebx,%edx
  8023e1:	19 ce                	sbb    %ecx,%esi
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 f0                	mov    %esi,%eax
  8023e7:	d3 e0                	shl    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	d3 ea                	shr    %cl,%edx
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	d3 ee                	shr    %cl,%esi
  8023f1:	09 d0                	or     %edx,%eax
  8023f3:	89 f2                	mov    %esi,%edx
  8023f5:	83 c4 1c             	add    $0x1c,%esp
  8023f8:	5b                   	pop    %ebx
  8023f9:	5e                   	pop    %esi
  8023fa:	5f                   	pop    %edi
  8023fb:	5d                   	pop    %ebp
  8023fc:	c3                   	ret    
  8023fd:	8d 76 00             	lea    0x0(%esi),%esi
  802400:	29 f9                	sub    %edi,%ecx
  802402:	19 d6                	sbb    %edx,%esi
  802404:	89 74 24 04          	mov    %esi,0x4(%esp)
  802408:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80240c:	e9 18 ff ff ff       	jmp    802329 <__umoddi3+0x69>
