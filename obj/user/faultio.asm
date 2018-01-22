
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 3c 00 00 00       	call   80006d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 10                	je     800050 <umain+0x1d>
		cprintf("eflags wrong\n");
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	68 80 1e 80 00       	push   $0x801e80
  800048:	e8 73 01 00 00       	call   8001c0 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800050:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800055:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80005a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80005b:	83 ec 0c             	sub    $0xc,%esp
  80005e:	68 8e 1e 80 00       	push   $0x801e8e
  800063:	e8 58 01 00 00       	call   8001c0 <cprintf>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	57                   	push   %edi
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800076:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80007d:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800080:	e8 85 0a 00 00       	call   800b0a <sys_getenvid>
  800085:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	50                   	push   %eax
  80008b:	68 a8 1e 80 00       	push   $0x801ea8
  800090:	e8 2b 01 00 00       	call   8001c0 <cprintf>
  800095:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80009b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000ad:	89 c1                	mov    %eax,%ecx
  8000af:	c1 e1 07             	shl    $0x7,%ecx
  8000b2:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000b9:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000bc:	39 cb                	cmp    %ecx,%ebx
  8000be:	0f 44 fa             	cmove  %edx,%edi
  8000c1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000c6:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000c9:	83 c0 01             	add    $0x1,%eax
  8000cc:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000d2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000d7:	75 d4                	jne    8000ad <libmain+0x40>
  8000d9:	89 f0                	mov    %esi,%eax
  8000db:	84 c0                	test   %al,%al
  8000dd:	74 06                	je     8000e5 <libmain+0x78>
  8000df:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000e9:	7e 0a                	jle    8000f5 <libmain+0x88>
		binaryname = argv[0];
  8000eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ee:	8b 00                	mov    (%eax),%eax
  8000f0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f5:	83 ec 08             	sub    $0x8,%esp
  8000f8:	ff 75 0c             	pushl  0xc(%ebp)
  8000fb:	ff 75 08             	pushl  0x8(%ebp)
  8000fe:	e8 30 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800103:	e8 0b 00 00 00       	call   800113 <exit>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800119:	e8 06 0e 00 00       	call   800f24 <close_all>
	sys_env_destroy(0);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	6a 00                	push   $0x0
  800123:	e8 a1 09 00 00       	call   800ac9 <sys_env_destroy>
}
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	53                   	push   %ebx
  800131:	83 ec 04             	sub    $0x4,%esp
  800134:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800137:	8b 13                	mov    (%ebx),%edx
  800139:	8d 42 01             	lea    0x1(%edx),%eax
  80013c:	89 03                	mov    %eax,(%ebx)
  80013e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800141:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800145:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014a:	75 1a                	jne    800166 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80014c:	83 ec 08             	sub    $0x8,%esp
  80014f:	68 ff 00 00 00       	push   $0xff
  800154:	8d 43 08             	lea    0x8(%ebx),%eax
  800157:	50                   	push   %eax
  800158:	e8 2f 09 00 00       	call   800a8c <sys_cputs>
		b->idx = 0;
  80015d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800163:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800166:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80016a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800178:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017f:	00 00 00 
	b.cnt = 0;
  800182:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800189:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018c:	ff 75 0c             	pushl  0xc(%ebp)
  80018f:	ff 75 08             	pushl  0x8(%ebp)
  800192:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800198:	50                   	push   %eax
  800199:	68 2d 01 80 00       	push   $0x80012d
  80019e:	e8 54 01 00 00       	call   8002f7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a3:	83 c4 08             	add    $0x8,%esp
  8001a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b2:	50                   	push   %eax
  8001b3:	e8 d4 08 00 00       	call   800a8c <sys_cputs>

	return b.cnt;
}
  8001b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c9:	50                   	push   %eax
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	e8 9d ff ff ff       	call   80016f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	57                   	push   %edi
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	83 ec 1c             	sub    $0x1c,%esp
  8001dd:	89 c7                	mov    %eax,%edi
  8001df:	89 d6                	mov    %edx,%esi
  8001e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001fb:	39 d3                	cmp    %edx,%ebx
  8001fd:	72 05                	jb     800204 <printnum+0x30>
  8001ff:	39 45 10             	cmp    %eax,0x10(%ebp)
  800202:	77 45                	ja     800249 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800204:	83 ec 0c             	sub    $0xc,%esp
  800207:	ff 75 18             	pushl  0x18(%ebp)
  80020a:	8b 45 14             	mov    0x14(%ebp),%eax
  80020d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	83 ec 08             	sub    $0x8,%esp
  800217:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021a:	ff 75 e0             	pushl  -0x20(%ebp)
  80021d:	ff 75 dc             	pushl  -0x24(%ebp)
  800220:	ff 75 d8             	pushl  -0x28(%ebp)
  800223:	e8 b8 19 00 00       	call   801be0 <__udivdi3>
  800228:	83 c4 18             	add    $0x18,%esp
  80022b:	52                   	push   %edx
  80022c:	50                   	push   %eax
  80022d:	89 f2                	mov    %esi,%edx
  80022f:	89 f8                	mov    %edi,%eax
  800231:	e8 9e ff ff ff       	call   8001d4 <printnum>
  800236:	83 c4 20             	add    $0x20,%esp
  800239:	eb 18                	jmp    800253 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	ff d7                	call   *%edi
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	eb 03                	jmp    80024c <printnum+0x78>
  800249:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024c:	83 eb 01             	sub    $0x1,%ebx
  80024f:	85 db                	test   %ebx,%ebx
  800251:	7f e8                	jg     80023b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	83 ec 04             	sub    $0x4,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 a5 1a 00 00       	call   801d10 <__umoddi3>
  80026b:	83 c4 14             	add    $0x14,%esp
  80026e:	0f be 80 d1 1e 80 00 	movsbl 0x801ed1(%eax),%eax
  800275:	50                   	push   %eax
  800276:	ff d7                	call   *%edi
}
  800278:	83 c4 10             	add    $0x10,%esp
  80027b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800286:	83 fa 01             	cmp    $0x1,%edx
  800289:	7e 0e                	jle    800299 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028b:	8b 10                	mov    (%eax),%edx
  80028d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800290:	89 08                	mov    %ecx,(%eax)
  800292:	8b 02                	mov    (%edx),%eax
  800294:	8b 52 04             	mov    0x4(%edx),%edx
  800297:	eb 22                	jmp    8002bb <getuint+0x38>
	else if (lflag)
  800299:	85 d2                	test   %edx,%edx
  80029b:	74 10                	je     8002ad <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 02                	mov    (%edx),%eax
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ab:	eb 0e                	jmp    8002bb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cc:	73 0a                	jae    8002d8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ce:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	88 02                	mov    %al,(%edx)
}
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e3:	50                   	push   %eax
  8002e4:	ff 75 10             	pushl  0x10(%ebp)
  8002e7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ea:	ff 75 08             	pushl  0x8(%ebp)
  8002ed:	e8 05 00 00 00       	call   8002f7 <vprintfmt>
	va_end(ap);
}
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
  8002fd:	83 ec 2c             	sub    $0x2c,%esp
  800300:	8b 75 08             	mov    0x8(%ebp),%esi
  800303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800306:	8b 7d 10             	mov    0x10(%ebp),%edi
  800309:	eb 12                	jmp    80031d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030b:	85 c0                	test   %eax,%eax
  80030d:	0f 84 89 03 00 00    	je     80069c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800313:	83 ec 08             	sub    $0x8,%esp
  800316:	53                   	push   %ebx
  800317:	50                   	push   %eax
  800318:	ff d6                	call   *%esi
  80031a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031d:	83 c7 01             	add    $0x1,%edi
  800320:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800324:	83 f8 25             	cmp    $0x25,%eax
  800327:	75 e2                	jne    80030b <vprintfmt+0x14>
  800329:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80032d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800334:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80033b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800342:	ba 00 00 00 00       	mov    $0x0,%edx
  800347:	eb 07                	jmp    800350 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80034c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8d 47 01             	lea    0x1(%edi),%eax
  800353:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800356:	0f b6 07             	movzbl (%edi),%eax
  800359:	0f b6 c8             	movzbl %al,%ecx
  80035c:	83 e8 23             	sub    $0x23,%eax
  80035f:	3c 55                	cmp    $0x55,%al
  800361:	0f 87 1a 03 00 00    	ja     800681 <vprintfmt+0x38a>
  800367:	0f b6 c0             	movzbl %al,%eax
  80036a:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800374:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800378:	eb d6                	jmp    800350 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037d:	b8 00 00 00 00       	mov    $0x0,%eax
  800382:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800385:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800388:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80038c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80038f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800392:	83 fa 09             	cmp    $0x9,%edx
  800395:	77 39                	ja     8003d0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800397:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80039a:	eb e9                	jmp    800385 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039c:	8b 45 14             	mov    0x14(%ebp),%eax
  80039f:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003a5:	8b 00                	mov    (%eax),%eax
  8003a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ad:	eb 27                	jmp    8003d6 <vprintfmt+0xdf>
  8003af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b9:	0f 49 c8             	cmovns %eax,%ecx
  8003bc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c2:	eb 8c                	jmp    800350 <vprintfmt+0x59>
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ce:	eb 80                	jmp    800350 <vprintfmt+0x59>
  8003d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003d3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003da:	0f 89 70 ff ff ff    	jns    800350 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ed:	e9 5e ff ff ff       	jmp    800350 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f8:	e9 53 ff ff ff       	jmp    800350 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 50 04             	lea    0x4(%eax),%edx
  800403:	89 55 14             	mov    %edx,0x14(%ebp)
  800406:	83 ec 08             	sub    $0x8,%esp
  800409:	53                   	push   %ebx
  80040a:	ff 30                	pushl  (%eax)
  80040c:	ff d6                	call   *%esi
			break;
  80040e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800414:	e9 04 ff ff ff       	jmp    80031d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 50 04             	lea    0x4(%eax),%edx
  80041f:	89 55 14             	mov    %edx,0x14(%ebp)
  800422:	8b 00                	mov    (%eax),%eax
  800424:	99                   	cltd   
  800425:	31 d0                	xor    %edx,%eax
  800427:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800429:	83 f8 0f             	cmp    $0xf,%eax
  80042c:	7f 0b                	jg     800439 <vprintfmt+0x142>
  80042e:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  800435:	85 d2                	test   %edx,%edx
  800437:	75 18                	jne    800451 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800439:	50                   	push   %eax
  80043a:	68 e9 1e 80 00       	push   $0x801ee9
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 94 fe ff ff       	call   8002da <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80044c:	e9 cc fe ff ff       	jmp    80031d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800451:	52                   	push   %edx
  800452:	68 b1 22 80 00       	push   $0x8022b1
  800457:	53                   	push   %ebx
  800458:	56                   	push   %esi
  800459:	e8 7c fe ff ff       	call   8002da <printfmt>
  80045e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800464:	e9 b4 fe ff ff       	jmp    80031d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	8d 50 04             	lea    0x4(%eax),%edx
  80046f:	89 55 14             	mov    %edx,0x14(%ebp)
  800472:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800474:	85 ff                	test   %edi,%edi
  800476:	b8 e2 1e 80 00       	mov    $0x801ee2,%eax
  80047b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80047e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800482:	0f 8e 94 00 00 00    	jle    80051c <vprintfmt+0x225>
  800488:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048c:	0f 84 98 00 00 00    	je     80052a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	ff 75 d0             	pushl  -0x30(%ebp)
  800498:	57                   	push   %edi
  800499:	e8 86 02 00 00       	call   800724 <strnlen>
  80049e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a1:	29 c1                	sub    %eax,%ecx
  8004a3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	eb 0f                	jmp    8004c6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	53                   	push   %ebx
  8004bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ef 01             	sub    $0x1,%edi
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 ff                	test   %edi,%edi
  8004c8:	7f ed                	jg     8004b7 <vprintfmt+0x1c0>
  8004ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004cd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	0f 49 c1             	cmovns %ecx,%eax
  8004da:	29 c1                	sub    %eax,%ecx
  8004dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e5:	89 cb                	mov    %ecx,%ebx
  8004e7:	eb 4d                	jmp    800536 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ed:	74 1b                	je     80050a <vprintfmt+0x213>
  8004ef:	0f be c0             	movsbl %al,%eax
  8004f2:	83 e8 20             	sub    $0x20,%eax
  8004f5:	83 f8 5e             	cmp    $0x5e,%eax
  8004f8:	76 10                	jbe    80050a <vprintfmt+0x213>
					putch('?', putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	6a 3f                	push   $0x3f
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	eb 0d                	jmp    800517 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	52                   	push   %edx
  800511:	ff 55 08             	call   *0x8(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800517:	83 eb 01             	sub    $0x1,%ebx
  80051a:	eb 1a                	jmp    800536 <vprintfmt+0x23f>
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800528:	eb 0c                	jmp    800536 <vprintfmt+0x23f>
  80052a:	89 75 08             	mov    %esi,0x8(%ebp)
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800530:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800533:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800536:	83 c7 01             	add    $0x1,%edi
  800539:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053d:	0f be d0             	movsbl %al,%edx
  800540:	85 d2                	test   %edx,%edx
  800542:	74 23                	je     800567 <vprintfmt+0x270>
  800544:	85 f6                	test   %esi,%esi
  800546:	78 a1                	js     8004e9 <vprintfmt+0x1f2>
  800548:	83 ee 01             	sub    $0x1,%esi
  80054b:	79 9c                	jns    8004e9 <vprintfmt+0x1f2>
  80054d:	89 df                	mov    %ebx,%edi
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	eb 18                	jmp    80056f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	53                   	push   %ebx
  80055b:	6a 20                	push   $0x20
  80055d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055f:	83 ef 01             	sub    $0x1,%edi
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	eb 08                	jmp    80056f <vprintfmt+0x278>
  800567:	89 df                	mov    %ebx,%edi
  800569:	8b 75 08             	mov    0x8(%ebp),%esi
  80056c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056f:	85 ff                	test   %edi,%edi
  800571:	7f e4                	jg     800557 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800576:	e9 a2 fd ff ff       	jmp    80031d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80057b:	83 fa 01             	cmp    $0x1,%edx
  80057e:	7e 16                	jle    800596 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 08             	lea    0x8(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 50 04             	mov    0x4(%eax),%edx
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800594:	eb 32                	jmp    8005c8 <vprintfmt+0x2d1>
	else if (lflag)
  800596:	85 d2                	test   %edx,%edx
  800598:	74 18                	je     8005b2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 c1                	mov    %eax,%ecx
  8005aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b0:	eb 16                	jmp    8005c8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 04             	lea    0x4(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 c1                	mov    %eax,%ecx
  8005c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005d3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d7:	79 74                	jns    80064d <vprintfmt+0x356>
				putch('-', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 2d                	push   $0x2d
  8005df:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e7:	f7 d8                	neg    %eax
  8005e9:	83 d2 00             	adc    $0x0,%edx
  8005ec:	f7 da                	neg    %edx
  8005ee:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f6:	eb 55                	jmp    80064d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fb:	e8 83 fc ff ff       	call   800283 <getuint>
			base = 10;
  800600:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800605:	eb 46                	jmp    80064d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800607:	8d 45 14             	lea    0x14(%ebp),%eax
  80060a:	e8 74 fc ff ff       	call   800283 <getuint>
			base = 8;
  80060f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800614:	eb 37                	jmp    80064d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 30                	push   $0x30
  80061c:	ff d6                	call   *%esi
			putch('x', putdat);
  80061e:	83 c4 08             	add    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 78                	push   $0x78
  800624:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800636:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800639:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80063e:	eb 0d                	jmp    80064d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800640:	8d 45 14             	lea    0x14(%ebp),%eax
  800643:	e8 3b fc ff ff       	call   800283 <getuint>
			base = 16;
  800648:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064d:	83 ec 0c             	sub    $0xc,%esp
  800650:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800654:	57                   	push   %edi
  800655:	ff 75 e0             	pushl  -0x20(%ebp)
  800658:	51                   	push   %ecx
  800659:	52                   	push   %edx
  80065a:	50                   	push   %eax
  80065b:	89 da                	mov    %ebx,%edx
  80065d:	89 f0                	mov    %esi,%eax
  80065f:	e8 70 fb ff ff       	call   8001d4 <printnum>
			break;
  800664:	83 c4 20             	add    $0x20,%esp
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066a:	e9 ae fc ff ff       	jmp    80031d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	51                   	push   %ecx
  800674:	ff d6                	call   *%esi
			break;
  800676:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067c:	e9 9c fc ff ff       	jmp    80031d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 25                	push   $0x25
  800687:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	eb 03                	jmp    800691 <vprintfmt+0x39a>
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800695:	75 f7                	jne    80068e <vprintfmt+0x397>
  800697:	e9 81 fc ff ff       	jmp    80031d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80069c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069f:	5b                   	pop    %ebx
  8006a0:	5e                   	pop    %esi
  8006a1:	5f                   	pop    %edi
  8006a2:	5d                   	pop    %ebp
  8006a3:	c3                   	ret    

008006a4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 18             	sub    $0x18,%esp
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	74 26                	je     8006eb <vsnprintf+0x47>
  8006c5:	85 d2                	test   %edx,%edx
  8006c7:	7e 22                	jle    8006eb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c9:	ff 75 14             	pushl  0x14(%ebp)
  8006cc:	ff 75 10             	pushl  0x10(%ebp)
  8006cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	68 bd 02 80 00       	push   $0x8002bd
  8006d8:	e8 1a fc ff ff       	call   8002f7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 05                	jmp    8006f0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fb:	50                   	push   %eax
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	ff 75 08             	pushl  0x8(%ebp)
  800705:	e8 9a ff ff ff       	call   8006a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	eb 03                	jmp    80071c <strlen+0x10>
		n++;
  800719:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800720:	75 f7                	jne    800719 <strlen+0xd>
		n++;
	return n;
}
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	ba 00 00 00 00       	mov    $0x0,%edx
  800732:	eb 03                	jmp    800737 <strnlen+0x13>
		n++;
  800734:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800737:	39 c2                	cmp    %eax,%edx
  800739:	74 08                	je     800743 <strnlen+0x1f>
  80073b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80073f:	75 f3                	jne    800734 <strnlen+0x10>
  800741:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	53                   	push   %ebx
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074f:	89 c2                	mov    %eax,%edx
  800751:	83 c2 01             	add    $0x1,%edx
  800754:	83 c1 01             	add    $0x1,%ecx
  800757:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80075b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80075e:	84 db                	test   %bl,%bl
  800760:	75 ef                	jne    800751 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800762:	5b                   	pop    %ebx
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	53                   	push   %ebx
  800769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076c:	53                   	push   %ebx
  80076d:	e8 9a ff ff ff       	call   80070c <strlen>
  800772:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	01 d8                	add    %ebx,%eax
  80077a:	50                   	push   %eax
  80077b:	e8 c5 ff ff ff       	call   800745 <strcpy>
	return dst;
}
  800780:	89 d8                	mov    %ebx,%eax
  800782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800792:	89 f3                	mov    %esi,%ebx
  800794:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800797:	89 f2                	mov    %esi,%edx
  800799:	eb 0f                	jmp    8007aa <strncpy+0x23>
		*dst++ = *src;
  80079b:	83 c2 01             	add    $0x1,%edx
  80079e:	0f b6 01             	movzbl (%ecx),%eax
  8007a1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007aa:	39 da                	cmp    %ebx,%edx
  8007ac:	75 ed                	jne    80079b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	74 21                	je     8007e9 <strlcpy+0x35>
  8007c8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	eb 09                	jmp    8007d9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	83 c1 01             	add    $0x1,%ecx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d9:	39 c2                	cmp    %eax,%edx
  8007db:	74 09                	je     8007e6 <strlcpy+0x32>
  8007dd:	0f b6 19             	movzbl (%ecx),%ebx
  8007e0:	84 db                	test   %bl,%bl
  8007e2:	75 ec                	jne    8007d0 <strlcpy+0x1c>
  8007e4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e9:	29 f0                	sub    %esi,%eax
}
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strcmp+0x11>
		p++, q++;
  8007fa:	83 c1 01             	add    $0x1,%ecx
  8007fd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800800:	0f b6 01             	movzbl (%ecx),%eax
  800803:	84 c0                	test   %al,%al
  800805:	74 04                	je     80080b <strcmp+0x1c>
  800807:	3a 02                	cmp    (%edx),%al
  800809:	74 ef                	je     8007fa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 c0             	movzbl %al,%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081f:	89 c3                	mov    %eax,%ebx
  800821:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800824:	eb 06                	jmp    80082c <strncmp+0x17>
		n--, p++, q++;
  800826:	83 c0 01             	add    $0x1,%eax
  800829:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082c:	39 d8                	cmp    %ebx,%eax
  80082e:	74 15                	je     800845 <strncmp+0x30>
  800830:	0f b6 08             	movzbl (%eax),%ecx
  800833:	84 c9                	test   %cl,%cl
  800835:	74 04                	je     80083b <strncmp+0x26>
  800837:	3a 0a                	cmp    (%edx),%cl
  800839:	74 eb                	je     800826 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 00             	movzbl (%eax),%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
  800843:	eb 05                	jmp    80084a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084a:	5b                   	pop    %ebx
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800857:	eb 07                	jmp    800860 <strchr+0x13>
		if (*s == c)
  800859:	38 ca                	cmp    %cl,%dl
  80085b:	74 0f                	je     80086c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085d:	83 c0 01             	add    $0x1,%eax
  800860:	0f b6 10             	movzbl (%eax),%edx
  800863:	84 d2                	test   %dl,%dl
  800865:	75 f2                	jne    800859 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800878:	eb 03                	jmp    80087d <strfind+0xf>
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800880:	38 ca                	cmp    %cl,%dl
  800882:	74 04                	je     800888 <strfind+0x1a>
  800884:	84 d2                	test   %dl,%dl
  800886:	75 f2                	jne    80087a <strfind+0xc>
			break;
	return (char *) s;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 7d 08             	mov    0x8(%ebp),%edi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800896:	85 c9                	test   %ecx,%ecx
  800898:	74 36                	je     8008d0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a0:	75 28                	jne    8008ca <memset+0x40>
  8008a2:	f6 c1 03             	test   $0x3,%cl
  8008a5:	75 23                	jne    8008ca <memset+0x40>
		c &= 0xFF;
  8008a7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ab:	89 d3                	mov    %edx,%ebx
  8008ad:	c1 e3 08             	shl    $0x8,%ebx
  8008b0:	89 d6                	mov    %edx,%esi
  8008b2:	c1 e6 18             	shl    $0x18,%esi
  8008b5:	89 d0                	mov    %edx,%eax
  8008b7:	c1 e0 10             	shl    $0x10,%eax
  8008ba:	09 f0                	or     %esi,%eax
  8008bc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	09 d0                	or     %edx,%eax
  8008c2:	c1 e9 02             	shr    $0x2,%ecx
  8008c5:	fc                   	cld    
  8008c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c8:	eb 06                	jmp    8008d0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	fc                   	cld    
  8008ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d0:	89 f8                	mov    %edi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e5:	39 c6                	cmp    %eax,%esi
  8008e7:	73 35                	jae    80091e <memmove+0x47>
  8008e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ec:	39 d0                	cmp    %edx,%eax
  8008ee:	73 2e                	jae    80091e <memmove+0x47>
		s += n;
		d += n;
  8008f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	09 fe                	or     %edi,%esi
  8008f7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fd:	75 13                	jne    800912 <memmove+0x3b>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 0e                	jne    800912 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800904:	83 ef 04             	sub    $0x4,%edi
  800907:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090a:	c1 e9 02             	shr    $0x2,%ecx
  80090d:	fd                   	std    
  80090e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800910:	eb 09                	jmp    80091b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800912:	83 ef 01             	sub    $0x1,%edi
  800915:	8d 72 ff             	lea    -0x1(%edx),%esi
  800918:	fd                   	std    
  800919:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091b:	fc                   	cld    
  80091c:	eb 1d                	jmp    80093b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091e:	89 f2                	mov    %esi,%edx
  800920:	09 c2                	or     %eax,%edx
  800922:	f6 c2 03             	test   $0x3,%dl
  800925:	75 0f                	jne    800936 <memmove+0x5f>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 0a                	jne    800936 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80092c:	c1 e9 02             	shr    $0x2,%ecx
  80092f:	89 c7                	mov    %eax,%edi
  800931:	fc                   	cld    
  800932:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800934:	eb 05                	jmp    80093b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800942:	ff 75 10             	pushl  0x10(%ebp)
  800945:	ff 75 0c             	pushl  0xc(%ebp)
  800948:	ff 75 08             	pushl  0x8(%ebp)
  80094b:	e8 87 ff ff ff       	call   8008d7 <memmove>
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	89 c6                	mov    %eax,%esi
  80095f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800962:	eb 1a                	jmp    80097e <memcmp+0x2c>
		if (*s1 != *s2)
  800964:	0f b6 08             	movzbl (%eax),%ecx
  800967:	0f b6 1a             	movzbl (%edx),%ebx
  80096a:	38 d9                	cmp    %bl,%cl
  80096c:	74 0a                	je     800978 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80096e:	0f b6 c1             	movzbl %cl,%eax
  800971:	0f b6 db             	movzbl %bl,%ebx
  800974:	29 d8                	sub    %ebx,%eax
  800976:	eb 0f                	jmp    800987 <memcmp+0x35>
		s1++, s2++;
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	39 f0                	cmp    %esi,%eax
  800980:	75 e2                	jne    800964 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800992:	89 c1                	mov    %eax,%ecx
  800994:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800997:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099b:	eb 0a                	jmp    8009a7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	39 da                	cmp    %ebx,%edx
  8009a2:	74 07                	je     8009ab <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a4:	83 c0 01             	add    $0x1,%eax
  8009a7:	39 c8                	cmp    %ecx,%eax
  8009a9:	72 f2                	jb     80099d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ab:	5b                   	pop    %ebx
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	57                   	push   %edi
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	eb 03                	jmp    8009bf <strtol+0x11>
		s++;
  8009bc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bf:	0f b6 01             	movzbl (%ecx),%eax
  8009c2:	3c 20                	cmp    $0x20,%al
  8009c4:	74 f6                	je     8009bc <strtol+0xe>
  8009c6:	3c 09                	cmp    $0x9,%al
  8009c8:	74 f2                	je     8009bc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ca:	3c 2b                	cmp    $0x2b,%al
  8009cc:	75 0a                	jne    8009d8 <strtol+0x2a>
		s++;
  8009ce:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d6:	eb 11                	jmp    8009e9 <strtol+0x3b>
  8009d8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009dd:	3c 2d                	cmp    $0x2d,%al
  8009df:	75 08                	jne    8009e9 <strtol+0x3b>
		s++, neg = 1;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ef:	75 15                	jne    800a06 <strtol+0x58>
  8009f1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f4:	75 10                	jne    800a06 <strtol+0x58>
  8009f6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009fa:	75 7c                	jne    800a78 <strtol+0xca>
		s += 2, base = 16;
  8009fc:	83 c1 02             	add    $0x2,%ecx
  8009ff:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a04:	eb 16                	jmp    800a1c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a06:	85 db                	test   %ebx,%ebx
  800a08:	75 12                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a12:	75 08                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a24:	0f b6 11             	movzbl (%ecx),%edx
  800a27:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 09             	cmp    $0x9,%bl
  800a2f:	77 08                	ja     800a39 <strtol+0x8b>
			dig = *s - '0';
  800a31:	0f be d2             	movsbl %dl,%edx
  800a34:	83 ea 30             	sub    $0x30,%edx
  800a37:	eb 22                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a39:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 19             	cmp    $0x19,%bl
  800a41:	77 08                	ja     800a4b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a43:	0f be d2             	movsbl %dl,%edx
  800a46:	83 ea 57             	sub    $0x57,%edx
  800a49:	eb 10                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a4b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	80 fb 19             	cmp    $0x19,%bl
  800a53:	77 16                	ja     800a6b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5e:	7d 0b                	jge    800a6b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a67:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a69:	eb b9                	jmp    800a24 <strtol+0x76>

	if (endptr)
  800a6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6f:	74 0d                	je     800a7e <strtol+0xd0>
		*endptr = (char *) s;
  800a71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a74:	89 0e                	mov    %ecx,(%esi)
  800a76:	eb 06                	jmp    800a7e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	74 98                	je     800a14 <strtol+0x66>
  800a7c:	eb 9e                	jmp    800a1c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a7e:	89 c2                	mov    %eax,%edx
  800a80:	f7 da                	neg    %edx
  800a82:	85 ff                	test   %edi,%edi
  800a84:	0f 45 c2             	cmovne %edx,%eax
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	89 c3                	mov    %eax,%ebx
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	89 c6                	mov    %eax,%esi
  800aa3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_cgetc>:

int
sys_cgetc(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad7:	b8 03 00 00 00       	mov    $0x3,%eax
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	89 cb                	mov    %ecx,%ebx
  800ae1:	89 cf                	mov    %ecx,%edi
  800ae3:	89 ce                	mov    %ecx,%esi
  800ae5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	7e 17                	jle    800b02 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aeb:	83 ec 0c             	sub    $0xc,%esp
  800aee:	50                   	push   %eax
  800aef:	6a 03                	push   $0x3
  800af1:	68 df 21 80 00       	push   $0x8021df
  800af6:	6a 23                	push   $0x23
  800af8:	68 fc 21 80 00       	push   $0x8021fc
  800afd:	e8 41 0f 00 00       	call   801a43 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_yield>:

void
sys_yield(void)
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
  800b2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b39:	89 d1                	mov    %edx,%ecx
  800b3b:	89 d3                	mov    %edx,%ebx
  800b3d:	89 d7                	mov    %edx,%edi
  800b3f:	89 d6                	mov    %edx,%esi
  800b41:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	be 00 00 00 00       	mov    $0x0,%esi
  800b56:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b64:	89 f7                	mov    %esi,%edi
  800b66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7e 17                	jle    800b83 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 04                	push   $0x4
  800b72:	68 df 21 80 00       	push   $0x8021df
  800b77:	6a 23                	push   $0x23
  800b79:	68 fc 21 80 00       	push   $0x8021fc
  800b7e:	e8 c0 0e 00 00       	call   801a43 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	b8 05 00 00 00       	mov    $0x5,%eax
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7e 17                	jle    800bc5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	50                   	push   %eax
  800bb2:	6a 05                	push   $0x5
  800bb4:	68 df 21 80 00       	push   $0x8021df
  800bb9:	6a 23                	push   $0x23
  800bbb:	68 fc 21 80 00       	push   $0x8021fc
  800bc0:	e8 7e 0e 00 00       	call   801a43 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bdb:	b8 06 00 00 00       	mov    $0x6,%eax
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	89 df                	mov    %ebx,%edi
  800be8:	89 de                	mov    %ebx,%esi
  800bea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	7e 17                	jle    800c07 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 06                	push   $0x6
  800bf6:	68 df 21 80 00       	push   $0x8021df
  800bfb:	6a 23                	push   $0x23
  800bfd:	68 fc 21 80 00       	push   $0x8021fc
  800c02:	e8 3c 0e 00 00       	call   801a43 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	89 df                	mov    %ebx,%edi
  800c2a:	89 de                	mov    %ebx,%esi
  800c2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 08                	push   $0x8
  800c38:	68 df 21 80 00       	push   $0x8021df
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 fc 21 80 00       	push   $0x8021fc
  800c44:	e8 fa 0d 00 00       	call   801a43 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	89 df                	mov    %ebx,%edi
  800c6c:	89 de                	mov    %ebx,%esi
  800c6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 09                	push   $0x9
  800c7a:	68 df 21 80 00       	push   $0x8021df
  800c7f:	6a 23                	push   $0x23
  800c81:	68 fc 21 80 00       	push   $0x8021fc
  800c86:	e8 b8 0d 00 00       	call   801a43 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 17                	jle    800ccd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 0a                	push   $0xa
  800cbc:	68 df 21 80 00       	push   $0x8021df
  800cc1:	6a 23                	push   $0x23
  800cc3:	68 fc 21 80 00       	push   $0x8021fc
  800cc8:	e8 76 0d 00 00       	call   801a43 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	be 00 00 00 00       	mov    $0x0,%esi
  800ce0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d06:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	89 cb                	mov    %ecx,%ebx
  800d10:	89 cf                	mov    %ecx,%edi
  800d12:	89 ce                	mov    %ecx,%esi
  800d14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 17                	jle    800d31 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 0d                	push   $0xd
  800d20:	68 df 21 80 00       	push   $0x8021df
  800d25:	6a 23                	push   $0x23
  800d27:	68 fc 21 80 00       	push   $0x8021fc
  800d2c:	e8 12 0d 00 00       	call   801a43 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d44:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 cb                	mov    %ecx,%ebx
  800d4e:	89 cf                	mov    %ecx,%edi
  800d50:	89 ce                	mov    %ecx,%esi
  800d52:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	05 00 00 00 30       	add    $0x30000000,%eax
  800d64:	c1 e8 0c             	shr    $0xc,%eax
}
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	05 00 00 00 30       	add    $0x30000000,%eax
  800d74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d79:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d86:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d8b:	89 c2                	mov    %eax,%edx
  800d8d:	c1 ea 16             	shr    $0x16,%edx
  800d90:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d97:	f6 c2 01             	test   $0x1,%dl
  800d9a:	74 11                	je     800dad <fd_alloc+0x2d>
  800d9c:	89 c2                	mov    %eax,%edx
  800d9e:	c1 ea 0c             	shr    $0xc,%edx
  800da1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da8:	f6 c2 01             	test   $0x1,%dl
  800dab:	75 09                	jne    800db6 <fd_alloc+0x36>
			*fd_store = fd;
  800dad:	89 01                	mov    %eax,(%ecx)
			return 0;
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
  800db4:	eb 17                	jmp    800dcd <fd_alloc+0x4d>
  800db6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dbb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dc0:	75 c9                	jne    800d8b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dc2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dc8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dd5:	83 f8 1f             	cmp    $0x1f,%eax
  800dd8:	77 36                	ja     800e10 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dda:	c1 e0 0c             	shl    $0xc,%eax
  800ddd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800de2:	89 c2                	mov    %eax,%edx
  800de4:	c1 ea 16             	shr    $0x16,%edx
  800de7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dee:	f6 c2 01             	test   $0x1,%dl
  800df1:	74 24                	je     800e17 <fd_lookup+0x48>
  800df3:	89 c2                	mov    %eax,%edx
  800df5:	c1 ea 0c             	shr    $0xc,%edx
  800df8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dff:	f6 c2 01             	test   $0x1,%dl
  800e02:	74 1a                	je     800e1e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e07:	89 02                	mov    %eax,(%edx)
	return 0;
  800e09:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0e:	eb 13                	jmp    800e23 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e15:	eb 0c                	jmp    800e23 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1c:	eb 05                	jmp    800e23 <fd_lookup+0x54>
  800e1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2e:	ba 88 22 80 00       	mov    $0x802288,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e33:	eb 13                	jmp    800e48 <dev_lookup+0x23>
  800e35:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e38:	39 08                	cmp    %ecx,(%eax)
  800e3a:	75 0c                	jne    800e48 <dev_lookup+0x23>
			*dev = devtab[i];
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
  800e46:	eb 2e                	jmp    800e76 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e48:	8b 02                	mov    (%edx),%eax
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	75 e7                	jne    800e35 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e4e:	a1 04 40 80 00       	mov    0x804004,%eax
  800e53:	8b 40 50             	mov    0x50(%eax),%eax
  800e56:	83 ec 04             	sub    $0x4,%esp
  800e59:	51                   	push   %ecx
  800e5a:	50                   	push   %eax
  800e5b:	68 0c 22 80 00       	push   $0x80220c
  800e60:	e8 5b f3 ff ff       	call   8001c0 <cprintf>
	*dev = 0;
  800e65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 10             	sub    $0x10,%esp
  800e80:	8b 75 08             	mov    0x8(%ebp),%esi
  800e83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e89:	50                   	push   %eax
  800e8a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e90:	c1 e8 0c             	shr    $0xc,%eax
  800e93:	50                   	push   %eax
  800e94:	e8 36 ff ff ff       	call   800dcf <fd_lookup>
  800e99:	83 c4 08             	add    $0x8,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	78 05                	js     800ea5 <fd_close+0x2d>
	    || fd != fd2)
  800ea0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ea3:	74 0c                	je     800eb1 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ea5:	84 db                	test   %bl,%bl
  800ea7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eac:	0f 44 c2             	cmove  %edx,%eax
  800eaf:	eb 41                	jmp    800ef2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eb7:	50                   	push   %eax
  800eb8:	ff 36                	pushl  (%esi)
  800eba:	e8 66 ff ff ff       	call   800e25 <dev_lookup>
  800ebf:	89 c3                	mov    %eax,%ebx
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	78 1a                	js     800ee2 <fd_close+0x6a>
		if (dev->dev_close)
  800ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ecb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ece:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	74 0b                	je     800ee2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ed7:	83 ec 0c             	sub    $0xc,%esp
  800eda:	56                   	push   %esi
  800edb:	ff d0                	call   *%eax
  800edd:	89 c3                	mov    %eax,%ebx
  800edf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ee2:	83 ec 08             	sub    $0x8,%esp
  800ee5:	56                   	push   %esi
  800ee6:	6a 00                	push   $0x0
  800ee8:	e8 e0 fc ff ff       	call   800bcd <sys_page_unmap>
	return r;
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	89 d8                	mov    %ebx,%eax
}
  800ef2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f02:	50                   	push   %eax
  800f03:	ff 75 08             	pushl  0x8(%ebp)
  800f06:	e8 c4 fe ff ff       	call   800dcf <fd_lookup>
  800f0b:	83 c4 08             	add    $0x8,%esp
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	78 10                	js     800f22 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f12:	83 ec 08             	sub    $0x8,%esp
  800f15:	6a 01                	push   $0x1
  800f17:	ff 75 f4             	pushl  -0xc(%ebp)
  800f1a:	e8 59 ff ff ff       	call   800e78 <fd_close>
  800f1f:	83 c4 10             	add    $0x10,%esp
}
  800f22:	c9                   	leave  
  800f23:	c3                   	ret    

00800f24 <close_all>:

void
close_all(void)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	53                   	push   %ebx
  800f28:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	53                   	push   %ebx
  800f34:	e8 c0 ff ff ff       	call   800ef9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f39:	83 c3 01             	add    $0x1,%ebx
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	83 fb 20             	cmp    $0x20,%ebx
  800f42:	75 ec                	jne    800f30 <close_all+0xc>
		close(i);
}
  800f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    

00800f49 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	53                   	push   %ebx
  800f4f:	83 ec 2c             	sub    $0x2c,%esp
  800f52:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f55:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f58:	50                   	push   %eax
  800f59:	ff 75 08             	pushl  0x8(%ebp)
  800f5c:	e8 6e fe ff ff       	call   800dcf <fd_lookup>
  800f61:	83 c4 08             	add    $0x8,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	0f 88 c1 00 00 00    	js     80102d <dup+0xe4>
		return r;
	close(newfdnum);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	56                   	push   %esi
  800f70:	e8 84 ff ff ff       	call   800ef9 <close>

	newfd = INDEX2FD(newfdnum);
  800f75:	89 f3                	mov    %esi,%ebx
  800f77:	c1 e3 0c             	shl    $0xc,%ebx
  800f7a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f80:	83 c4 04             	add    $0x4,%esp
  800f83:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f86:	e8 de fd ff ff       	call   800d69 <fd2data>
  800f8b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f8d:	89 1c 24             	mov    %ebx,(%esp)
  800f90:	e8 d4 fd ff ff       	call   800d69 <fd2data>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f9b:	89 f8                	mov    %edi,%eax
  800f9d:	c1 e8 16             	shr    $0x16,%eax
  800fa0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa7:	a8 01                	test   $0x1,%al
  800fa9:	74 37                	je     800fe2 <dup+0x99>
  800fab:	89 f8                	mov    %edi,%eax
  800fad:	c1 e8 0c             	shr    $0xc,%eax
  800fb0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb7:	f6 c2 01             	test   $0x1,%dl
  800fba:	74 26                	je     800fe2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fcb:	50                   	push   %eax
  800fcc:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fcf:	6a 00                	push   $0x0
  800fd1:	57                   	push   %edi
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 b2 fb ff ff       	call   800b8b <sys_page_map>
  800fd9:	89 c7                	mov    %eax,%edi
  800fdb:	83 c4 20             	add    $0x20,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 2e                	js     801010 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fe5:	89 d0                	mov    %edx,%eax
  800fe7:	c1 e8 0c             	shr    $0xc,%eax
  800fea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff9:	50                   	push   %eax
  800ffa:	53                   	push   %ebx
  800ffb:	6a 00                	push   $0x0
  800ffd:	52                   	push   %edx
  800ffe:	6a 00                	push   $0x0
  801000:	e8 86 fb ff ff       	call   800b8b <sys_page_map>
  801005:	89 c7                	mov    %eax,%edi
  801007:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80100a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80100c:	85 ff                	test   %edi,%edi
  80100e:	79 1d                	jns    80102d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801010:	83 ec 08             	sub    $0x8,%esp
  801013:	53                   	push   %ebx
  801014:	6a 00                	push   $0x0
  801016:	e8 b2 fb ff ff       	call   800bcd <sys_page_unmap>
	sys_page_unmap(0, nva);
  80101b:	83 c4 08             	add    $0x8,%esp
  80101e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801021:	6a 00                	push   $0x0
  801023:	e8 a5 fb ff ff       	call   800bcd <sys_page_unmap>
	return r;
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	89 f8                	mov    %edi,%eax
}
  80102d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	53                   	push   %ebx
  801039:	83 ec 14             	sub    $0x14,%esp
  80103c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80103f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801042:	50                   	push   %eax
  801043:	53                   	push   %ebx
  801044:	e8 86 fd ff ff       	call   800dcf <fd_lookup>
  801049:	83 c4 08             	add    $0x8,%esp
  80104c:	89 c2                	mov    %eax,%edx
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 6d                	js     8010bf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801052:	83 ec 08             	sub    $0x8,%esp
  801055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801058:	50                   	push   %eax
  801059:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105c:	ff 30                	pushl  (%eax)
  80105e:	e8 c2 fd ff ff       	call   800e25 <dev_lookup>
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	78 4c                	js     8010b6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80106a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80106d:	8b 42 08             	mov    0x8(%edx),%eax
  801070:	83 e0 03             	and    $0x3,%eax
  801073:	83 f8 01             	cmp    $0x1,%eax
  801076:	75 21                	jne    801099 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801078:	a1 04 40 80 00       	mov    0x804004,%eax
  80107d:	8b 40 50             	mov    0x50(%eax),%eax
  801080:	83 ec 04             	sub    $0x4,%esp
  801083:	53                   	push   %ebx
  801084:	50                   	push   %eax
  801085:	68 4d 22 80 00       	push   $0x80224d
  80108a:	e8 31 f1 ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801097:	eb 26                	jmp    8010bf <read+0x8a>
	}
	if (!dev->dev_read)
  801099:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109c:	8b 40 08             	mov    0x8(%eax),%eax
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	74 17                	je     8010ba <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	ff 75 10             	pushl  0x10(%ebp)
  8010a9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ac:	52                   	push   %edx
  8010ad:	ff d0                	call   *%eax
  8010af:	89 c2                	mov    %eax,%edx
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	eb 09                	jmp    8010bf <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b6:	89 c2                	mov    %eax,%edx
  8010b8:	eb 05                	jmp    8010bf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8010bf:	89 d0                	mov    %edx,%eax
  8010c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	57                   	push   %edi
  8010ca:	56                   	push   %esi
  8010cb:	53                   	push   %ebx
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010d2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010da:	eb 21                	jmp    8010fd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010dc:	83 ec 04             	sub    $0x4,%esp
  8010df:	89 f0                	mov    %esi,%eax
  8010e1:	29 d8                	sub    %ebx,%eax
  8010e3:	50                   	push   %eax
  8010e4:	89 d8                	mov    %ebx,%eax
  8010e6:	03 45 0c             	add    0xc(%ebp),%eax
  8010e9:	50                   	push   %eax
  8010ea:	57                   	push   %edi
  8010eb:	e8 45 ff ff ff       	call   801035 <read>
		if (m < 0)
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 10                	js     801107 <readn+0x41>
			return m;
		if (m == 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	74 0a                	je     801105 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010fb:	01 c3                	add    %eax,%ebx
  8010fd:	39 f3                	cmp    %esi,%ebx
  8010ff:	72 db                	jb     8010dc <readn+0x16>
  801101:	89 d8                	mov    %ebx,%eax
  801103:	eb 02                	jmp    801107 <readn+0x41>
  801105:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110a:	5b                   	pop    %ebx
  80110b:	5e                   	pop    %esi
  80110c:	5f                   	pop    %edi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	53                   	push   %ebx
  801113:	83 ec 14             	sub    $0x14,%esp
  801116:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801119:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111c:	50                   	push   %eax
  80111d:	53                   	push   %ebx
  80111e:	e8 ac fc ff ff       	call   800dcf <fd_lookup>
  801123:	83 c4 08             	add    $0x8,%esp
  801126:	89 c2                	mov    %eax,%edx
  801128:	85 c0                	test   %eax,%eax
  80112a:	78 68                	js     801194 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801132:	50                   	push   %eax
  801133:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801136:	ff 30                	pushl  (%eax)
  801138:	e8 e8 fc ff ff       	call   800e25 <dev_lookup>
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	78 47                	js     80118b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801144:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801147:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80114b:	75 21                	jne    80116e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80114d:	a1 04 40 80 00       	mov    0x804004,%eax
  801152:	8b 40 50             	mov    0x50(%eax),%eax
  801155:	83 ec 04             	sub    $0x4,%esp
  801158:	53                   	push   %ebx
  801159:	50                   	push   %eax
  80115a:	68 69 22 80 00       	push   $0x802269
  80115f:	e8 5c f0 ff ff       	call   8001c0 <cprintf>
		return -E_INVAL;
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116c:	eb 26                	jmp    801194 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80116e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801171:	8b 52 0c             	mov    0xc(%edx),%edx
  801174:	85 d2                	test   %edx,%edx
  801176:	74 17                	je     80118f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	ff 75 10             	pushl  0x10(%ebp)
  80117e:	ff 75 0c             	pushl  0xc(%ebp)
  801181:	50                   	push   %eax
  801182:	ff d2                	call   *%edx
  801184:	89 c2                	mov    %eax,%edx
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	eb 09                	jmp    801194 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	eb 05                	jmp    801194 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80118f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801194:	89 d0                	mov    %edx,%eax
  801196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <seek>:

int
seek(int fdnum, off_t offset)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011a1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011a4:	50                   	push   %eax
  8011a5:	ff 75 08             	pushl  0x8(%ebp)
  8011a8:	e8 22 fc ff ff       	call   800dcf <fd_lookup>
  8011ad:	83 c4 08             	add    $0x8,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 0e                	js     8011c2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c2:	c9                   	leave  
  8011c3:	c3                   	ret    

008011c4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
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
  8011d3:	e8 f7 fb ff ff       	call   800dcf <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 65                	js     801246 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011eb:	ff 30                	pushl  (%eax)
  8011ed:	e8 33 fc ff ff       	call   800e25 <dev_lookup>
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 44                	js     80123d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801200:	75 21                	jne    801223 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801202:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801207:	8b 40 50             	mov    0x50(%eax),%eax
  80120a:	83 ec 04             	sub    $0x4,%esp
  80120d:	53                   	push   %ebx
  80120e:	50                   	push   %eax
  80120f:	68 2c 22 80 00       	push   $0x80222c
  801214:	e8 a7 ef ff ff       	call   8001c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801221:	eb 23                	jmp    801246 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801223:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801226:	8b 52 18             	mov    0x18(%edx),%edx
  801229:	85 d2                	test   %edx,%edx
  80122b:	74 14                	je     801241 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80122d:	83 ec 08             	sub    $0x8,%esp
  801230:	ff 75 0c             	pushl  0xc(%ebp)
  801233:	50                   	push   %eax
  801234:	ff d2                	call   *%edx
  801236:	89 c2                	mov    %eax,%edx
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	eb 09                	jmp    801246 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123d:	89 c2                	mov    %eax,%edx
  80123f:	eb 05                	jmp    801246 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801241:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801246:	89 d0                	mov    %edx,%eax
  801248:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    

0080124d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	53                   	push   %ebx
  801251:	83 ec 14             	sub    $0x14,%esp
  801254:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801257:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 75 08             	pushl  0x8(%ebp)
  80125e:	e8 6c fb ff ff       	call   800dcf <fd_lookup>
  801263:	83 c4 08             	add    $0x8,%esp
  801266:	89 c2                	mov    %eax,%edx
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 58                	js     8012c4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126c:	83 ec 08             	sub    $0x8,%esp
  80126f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801276:	ff 30                	pushl  (%eax)
  801278:	e8 a8 fb ff ff       	call   800e25 <dev_lookup>
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	85 c0                	test   %eax,%eax
  801282:	78 37                	js     8012bb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801284:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801287:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80128b:	74 32                	je     8012bf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80128d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801290:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801297:	00 00 00 
	stat->st_isdir = 0;
  80129a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a1:	00 00 00 
	stat->st_dev = dev;
  8012a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	53                   	push   %ebx
  8012ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b1:	ff 50 14             	call   *0x14(%eax)
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	eb 09                	jmp    8012c4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bb:	89 c2                	mov    %eax,%edx
  8012bd:	eb 05                	jmp    8012c4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012bf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012c4:	89 d0                	mov    %edx,%eax
  8012c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c9:	c9                   	leave  
  8012ca:	c3                   	ret    

008012cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	56                   	push   %esi
  8012cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	6a 00                	push   $0x0
  8012d5:	ff 75 08             	pushl  0x8(%ebp)
  8012d8:	e8 e3 01 00 00       	call   8014c0 <open>
  8012dd:	89 c3                	mov    %eax,%ebx
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 1b                	js     801301 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	ff 75 0c             	pushl  0xc(%ebp)
  8012ec:	50                   	push   %eax
  8012ed:	e8 5b ff ff ff       	call   80124d <fstat>
  8012f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8012f4:	89 1c 24             	mov    %ebx,(%esp)
  8012f7:	e8 fd fb ff ff       	call   800ef9 <close>
	return r;
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	89 f0                	mov    %esi,%eax
}
  801301:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801304:	5b                   	pop    %ebx
  801305:	5e                   	pop    %esi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
  80130d:	89 c6                	mov    %eax,%esi
  80130f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801311:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801318:	75 12                	jne    80132c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80131a:	83 ec 0c             	sub    $0xc,%esp
  80131d:	6a 01                	push   $0x1
  80131f:	e8 3c 08 00 00       	call   801b60 <ipc_find_env>
  801324:	a3 00 40 80 00       	mov    %eax,0x804000
  801329:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80132c:	6a 07                	push   $0x7
  80132e:	68 00 50 80 00       	push   $0x805000
  801333:	56                   	push   %esi
  801334:	ff 35 00 40 80 00    	pushl  0x804000
  80133a:	e8 bf 07 00 00       	call   801afe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80133f:	83 c4 0c             	add    $0xc,%esp
  801342:	6a 00                	push   $0x0
  801344:	53                   	push   %ebx
  801345:	6a 00                	push   $0x0
  801347:	e8 3d 07 00 00       	call   801a89 <ipc_recv>
}
  80134c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134f:	5b                   	pop    %ebx
  801350:	5e                   	pop    %esi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	8b 40 0c             	mov    0xc(%eax),%eax
  80135f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801364:	8b 45 0c             	mov    0xc(%ebp),%eax
  801367:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80136c:	ba 00 00 00 00       	mov    $0x0,%edx
  801371:	b8 02 00 00 00       	mov    $0x2,%eax
  801376:	e8 8d ff ff ff       	call   801308 <fsipc>
}
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801383:	8b 45 08             	mov    0x8(%ebp),%eax
  801386:	8b 40 0c             	mov    0xc(%eax),%eax
  801389:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80138e:	ba 00 00 00 00       	mov    $0x0,%edx
  801393:	b8 06 00 00 00       	mov    $0x6,%eax
  801398:	e8 6b ff ff ff       	call   801308 <fsipc>
}
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 04             	sub    $0x4,%esp
  8013a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8013af:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013be:	e8 45 ff ff ff       	call   801308 <fsipc>
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 2c                	js     8013f3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	68 00 50 80 00       	push   $0x805000
  8013cf:	53                   	push   %ebx
  8013d0:	e8 70 f3 ff ff       	call   800745 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d5:	a1 80 50 80 00       	mov    0x805080,%eax
  8013da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013e0:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 0c             	sub    $0xc,%esp
  8013fe:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801401:	8b 55 08             	mov    0x8(%ebp),%edx
  801404:	8b 52 0c             	mov    0xc(%edx),%edx
  801407:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80140d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801412:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801417:	0f 47 c2             	cmova  %edx,%eax
  80141a:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80141f:	50                   	push   %eax
  801420:	ff 75 0c             	pushl  0xc(%ebp)
  801423:	68 08 50 80 00       	push   $0x805008
  801428:	e8 aa f4 ff ff       	call   8008d7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80142d:	ba 00 00 00 00       	mov    $0x0,%edx
  801432:	b8 04 00 00 00       	mov    $0x4,%eax
  801437:	e8 cc fe ff ff       	call   801308 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	56                   	push   %esi
  801442:	53                   	push   %ebx
  801443:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801446:	8b 45 08             	mov    0x8(%ebp),%eax
  801449:	8b 40 0c             	mov    0xc(%eax),%eax
  80144c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801451:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801457:	ba 00 00 00 00       	mov    $0x0,%edx
  80145c:	b8 03 00 00 00       	mov    $0x3,%eax
  801461:	e8 a2 fe ff ff       	call   801308 <fsipc>
  801466:	89 c3                	mov    %eax,%ebx
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 4b                	js     8014b7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80146c:	39 c6                	cmp    %eax,%esi
  80146e:	73 16                	jae    801486 <devfile_read+0x48>
  801470:	68 98 22 80 00       	push   $0x802298
  801475:	68 9f 22 80 00       	push   $0x80229f
  80147a:	6a 7c                	push   $0x7c
  80147c:	68 b4 22 80 00       	push   $0x8022b4
  801481:	e8 bd 05 00 00       	call   801a43 <_panic>
	assert(r <= PGSIZE);
  801486:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80148b:	7e 16                	jle    8014a3 <devfile_read+0x65>
  80148d:	68 bf 22 80 00       	push   $0x8022bf
  801492:	68 9f 22 80 00       	push   $0x80229f
  801497:	6a 7d                	push   $0x7d
  801499:	68 b4 22 80 00       	push   $0x8022b4
  80149e:	e8 a0 05 00 00       	call   801a43 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014a3:	83 ec 04             	sub    $0x4,%esp
  8014a6:	50                   	push   %eax
  8014a7:	68 00 50 80 00       	push   $0x805000
  8014ac:	ff 75 0c             	pushl  0xc(%ebp)
  8014af:	e8 23 f4 ff ff       	call   8008d7 <memmove>
	return r;
  8014b4:	83 c4 10             	add    $0x10,%esp
}
  8014b7:	89 d8                	mov    %ebx,%eax
  8014b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bc:	5b                   	pop    %ebx
  8014bd:	5e                   	pop    %esi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 20             	sub    $0x20,%esp
  8014c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014ca:	53                   	push   %ebx
  8014cb:	e8 3c f2 ff ff       	call   80070c <strlen>
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d8:	7f 67                	jg     801541 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014da:	83 ec 0c             	sub    $0xc,%esp
  8014dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	e8 9a f8 ff ff       	call   800d80 <fd_alloc>
  8014e6:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 57                	js     801546 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	53                   	push   %ebx
  8014f3:	68 00 50 80 00       	push   $0x805000
  8014f8:	e8 48 f2 ff ff       	call   800745 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801500:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801505:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801508:	b8 01 00 00 00       	mov    $0x1,%eax
  80150d:	e8 f6 fd ff ff       	call   801308 <fsipc>
  801512:	89 c3                	mov    %eax,%ebx
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	79 14                	jns    80152f <open+0x6f>
		fd_close(fd, 0);
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	6a 00                	push   $0x0
  801520:	ff 75 f4             	pushl  -0xc(%ebp)
  801523:	e8 50 f9 ff ff       	call   800e78 <fd_close>
		return r;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	89 da                	mov    %ebx,%edx
  80152d:	eb 17                	jmp    801546 <open+0x86>
	}

	return fd2num(fd);
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	ff 75 f4             	pushl  -0xc(%ebp)
  801535:	e8 1f f8 ff ff       	call   800d59 <fd2num>
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	eb 05                	jmp    801546 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801541:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801546:	89 d0                	mov    %edx,%eax
  801548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801553:	ba 00 00 00 00       	mov    $0x0,%edx
  801558:	b8 08 00 00 00       	mov    $0x8,%eax
  80155d:	e8 a6 fd ff ff       	call   801308 <fsipc>
}
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	ff 75 08             	pushl  0x8(%ebp)
  801572:	e8 f2 f7 ff ff       	call   800d69 <fd2data>
  801577:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801579:	83 c4 08             	add    $0x8,%esp
  80157c:	68 cb 22 80 00       	push   $0x8022cb
  801581:	53                   	push   %ebx
  801582:	e8 be f1 ff ff       	call   800745 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801587:	8b 46 04             	mov    0x4(%esi),%eax
  80158a:	2b 06                	sub    (%esi),%eax
  80158c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801592:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801599:	00 00 00 
	stat->st_dev = &devpipe;
  80159c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015a3:	30 80 00 
	return 0;
}
  8015a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	5d                   	pop    %ebp
  8015b1:	c3                   	ret    

008015b2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 0c             	sub    $0xc,%esp
  8015b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015bc:	53                   	push   %ebx
  8015bd:	6a 00                	push   $0x0
  8015bf:	e8 09 f6 ff ff       	call   800bcd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015c4:	89 1c 24             	mov    %ebx,(%esp)
  8015c7:	e8 9d f7 ff ff       	call   800d69 <fd2data>
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	50                   	push   %eax
  8015d0:	6a 00                	push   $0x0
  8015d2:	e8 f6 f5 ff ff       	call   800bcd <sys_page_unmap>
}
  8015d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	57                   	push   %edi
  8015e0:	56                   	push   %esi
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 1c             	sub    $0x1c,%esp
  8015e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015e8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ef:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f8:	e8 a3 05 00 00       	call   801ba0 <pageref>
  8015fd:	89 c3                	mov    %eax,%ebx
  8015ff:	89 3c 24             	mov    %edi,(%esp)
  801602:	e8 99 05 00 00       	call   801ba0 <pageref>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	39 c3                	cmp    %eax,%ebx
  80160c:	0f 94 c1             	sete   %cl
  80160f:	0f b6 c9             	movzbl %cl,%ecx
  801612:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801615:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80161b:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  80161e:	39 ce                	cmp    %ecx,%esi
  801620:	74 1b                	je     80163d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801622:	39 c3                	cmp    %eax,%ebx
  801624:	75 c4                	jne    8015ea <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801626:	8b 42 60             	mov    0x60(%edx),%eax
  801629:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162c:	50                   	push   %eax
  80162d:	56                   	push   %esi
  80162e:	68 d2 22 80 00       	push   $0x8022d2
  801633:	e8 88 eb ff ff       	call   8001c0 <cprintf>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	eb ad                	jmp    8015ea <_pipeisclosed+0xe>
	}
}
  80163d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801640:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5f                   	pop    %edi
  801646:	5d                   	pop    %ebp
  801647:	c3                   	ret    

00801648 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	57                   	push   %edi
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	83 ec 28             	sub    $0x28,%esp
  801651:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801654:	56                   	push   %esi
  801655:	e8 0f f7 ff ff       	call   800d69 <fd2data>
  80165a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	bf 00 00 00 00       	mov    $0x0,%edi
  801664:	eb 4b                	jmp    8016b1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801666:	89 da                	mov    %ebx,%edx
  801668:	89 f0                	mov    %esi,%eax
  80166a:	e8 6d ff ff ff       	call   8015dc <_pipeisclosed>
  80166f:	85 c0                	test   %eax,%eax
  801671:	75 48                	jne    8016bb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801673:	e8 b1 f4 ff ff       	call   800b29 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801678:	8b 43 04             	mov    0x4(%ebx),%eax
  80167b:	8b 0b                	mov    (%ebx),%ecx
  80167d:	8d 51 20             	lea    0x20(%ecx),%edx
  801680:	39 d0                	cmp    %edx,%eax
  801682:	73 e2                	jae    801666 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801684:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801687:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80168b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80168e:	89 c2                	mov    %eax,%edx
  801690:	c1 fa 1f             	sar    $0x1f,%edx
  801693:	89 d1                	mov    %edx,%ecx
  801695:	c1 e9 1b             	shr    $0x1b,%ecx
  801698:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80169b:	83 e2 1f             	and    $0x1f,%edx
  80169e:	29 ca                	sub    %ecx,%edx
  8016a0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016a8:	83 c0 01             	add    $0x1,%eax
  8016ab:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ae:	83 c7 01             	add    $0x1,%edi
  8016b1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016b4:	75 c2                	jne    801678 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b9:	eb 05                	jmp    8016c0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016bb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5f                   	pop    %edi
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	57                   	push   %edi
  8016cc:	56                   	push   %esi
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 18             	sub    $0x18,%esp
  8016d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016d4:	57                   	push   %edi
  8016d5:	e8 8f f6 ff ff       	call   800d69 <fd2data>
  8016da:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e4:	eb 3d                	jmp    801723 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016e6:	85 db                	test   %ebx,%ebx
  8016e8:	74 04                	je     8016ee <devpipe_read+0x26>
				return i;
  8016ea:	89 d8                	mov    %ebx,%eax
  8016ec:	eb 44                	jmp    801732 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016ee:	89 f2                	mov    %esi,%edx
  8016f0:	89 f8                	mov    %edi,%eax
  8016f2:	e8 e5 fe ff ff       	call   8015dc <_pipeisclosed>
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	75 32                	jne    80172d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016fb:	e8 29 f4 ff ff       	call   800b29 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801700:	8b 06                	mov    (%esi),%eax
  801702:	3b 46 04             	cmp    0x4(%esi),%eax
  801705:	74 df                	je     8016e6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801707:	99                   	cltd   
  801708:	c1 ea 1b             	shr    $0x1b,%edx
  80170b:	01 d0                	add    %edx,%eax
  80170d:	83 e0 1f             	and    $0x1f,%eax
  801710:	29 d0                	sub    %edx,%eax
  801712:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80171d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801720:	83 c3 01             	add    $0x1,%ebx
  801723:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801726:	75 d8                	jne    801700 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801728:	8b 45 10             	mov    0x10(%ebp),%eax
  80172b:	eb 05                	jmp    801732 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80172d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801732:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	5f                   	pop    %edi
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	e8 35 f6 ff ff       	call   800d80 <fd_alloc>
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	89 c2                	mov    %eax,%edx
  801750:	85 c0                	test   %eax,%eax
  801752:	0f 88 2c 01 00 00    	js     801884 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801758:	83 ec 04             	sub    $0x4,%esp
  80175b:	68 07 04 00 00       	push   $0x407
  801760:	ff 75 f4             	pushl  -0xc(%ebp)
  801763:	6a 00                	push   $0x0
  801765:	e8 de f3 ff ff       	call   800b48 <sys_page_alloc>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	89 c2                	mov    %eax,%edx
  80176f:	85 c0                	test   %eax,%eax
  801771:	0f 88 0d 01 00 00    	js     801884 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177d:	50                   	push   %eax
  80177e:	e8 fd f5 ff ff       	call   800d80 <fd_alloc>
  801783:	89 c3                	mov    %eax,%ebx
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	85 c0                	test   %eax,%eax
  80178a:	0f 88 e2 00 00 00    	js     801872 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801790:	83 ec 04             	sub    $0x4,%esp
  801793:	68 07 04 00 00       	push   $0x407
  801798:	ff 75 f0             	pushl  -0x10(%ebp)
  80179b:	6a 00                	push   $0x0
  80179d:	e8 a6 f3 ff ff       	call   800b48 <sys_page_alloc>
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	0f 88 c3 00 00 00    	js     801872 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b5:	e8 af f5 ff ff       	call   800d69 <fd2data>
  8017ba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017bc:	83 c4 0c             	add    $0xc,%esp
  8017bf:	68 07 04 00 00       	push   $0x407
  8017c4:	50                   	push   %eax
  8017c5:	6a 00                	push   $0x0
  8017c7:	e8 7c f3 ff ff       	call   800b48 <sys_page_alloc>
  8017cc:	89 c3                	mov    %eax,%ebx
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	0f 88 89 00 00 00    	js     801862 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8017df:	e8 85 f5 ff ff       	call   800d69 <fd2data>
  8017e4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017eb:	50                   	push   %eax
  8017ec:	6a 00                	push   $0x0
  8017ee:	56                   	push   %esi
  8017ef:	6a 00                	push   $0x0
  8017f1:	e8 95 f3 ff ff       	call   800b8b <sys_page_map>
  8017f6:	89 c3                	mov    %eax,%ebx
  8017f8:	83 c4 20             	add    $0x20,%esp
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 55                	js     801854 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017ff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801805:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801808:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80180a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801814:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80181a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80181f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801822:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801829:	83 ec 0c             	sub    $0xc,%esp
  80182c:	ff 75 f4             	pushl  -0xc(%ebp)
  80182f:	e8 25 f5 ff ff       	call   800d59 <fd2num>
  801834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801837:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801839:	83 c4 04             	add    $0x4,%esp
  80183c:	ff 75 f0             	pushl  -0x10(%ebp)
  80183f:	e8 15 f5 ff ff       	call   800d59 <fd2num>
  801844:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801847:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	eb 30                	jmp    801884 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	56                   	push   %esi
  801858:	6a 00                	push   $0x0
  80185a:	e8 6e f3 ff ff       	call   800bcd <sys_page_unmap>
  80185f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	ff 75 f0             	pushl  -0x10(%ebp)
  801868:	6a 00                	push   $0x0
  80186a:	e8 5e f3 ff ff       	call   800bcd <sys_page_unmap>
  80186f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801872:	83 ec 08             	sub    $0x8,%esp
  801875:	ff 75 f4             	pushl  -0xc(%ebp)
  801878:	6a 00                	push   $0x0
  80187a:	e8 4e f3 ff ff       	call   800bcd <sys_page_unmap>
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801884:	89 d0                	mov    %edx,%eax
  801886:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801889:	5b                   	pop    %ebx
  80188a:	5e                   	pop    %esi
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801893:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801896:	50                   	push   %eax
  801897:	ff 75 08             	pushl  0x8(%ebp)
  80189a:	e8 30 f5 ff ff       	call   800dcf <fd_lookup>
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 18                	js     8018be <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018a6:	83 ec 0c             	sub    $0xc,%esp
  8018a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ac:	e8 b8 f4 ff ff       	call   800d69 <fd2data>
	return _pipeisclosed(fd, p);
  8018b1:	89 c2                	mov    %eax,%edx
  8018b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b6:	e8 21 fd ff ff       	call   8015dc <_pipeisclosed>
  8018bb:	83 c4 10             	add    $0x10,%esp
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018d0:	68 ea 22 80 00       	push   $0x8022ea
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	e8 68 ee ff ff       	call   800745 <strcpy>
	return 0;
}
  8018dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	57                   	push   %edi
  8018e8:	56                   	push   %esi
  8018e9:	53                   	push   %ebx
  8018ea:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018f5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018fb:	eb 2d                	jmp    80192a <devcons_write+0x46>
		m = n - tot;
  8018fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801900:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801902:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801905:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80190a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80190d:	83 ec 04             	sub    $0x4,%esp
  801910:	53                   	push   %ebx
  801911:	03 45 0c             	add    0xc(%ebp),%eax
  801914:	50                   	push   %eax
  801915:	57                   	push   %edi
  801916:	e8 bc ef ff ff       	call   8008d7 <memmove>
		sys_cputs(buf, m);
  80191b:	83 c4 08             	add    $0x8,%esp
  80191e:	53                   	push   %ebx
  80191f:	57                   	push   %edi
  801920:	e8 67 f1 ff ff       	call   800a8c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801925:	01 de                	add    %ebx,%esi
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	89 f0                	mov    %esi,%eax
  80192c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80192f:	72 cc                	jb     8018fd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801931:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801934:	5b                   	pop    %ebx
  801935:	5e                   	pop    %esi
  801936:	5f                   	pop    %edi
  801937:	5d                   	pop    %ebp
  801938:	c3                   	ret    

00801939 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801944:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801948:	74 2a                	je     801974 <devcons_read+0x3b>
  80194a:	eb 05                	jmp    801951 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80194c:	e8 d8 f1 ff ff       	call   800b29 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801951:	e8 54 f1 ff ff       	call   800aaa <sys_cgetc>
  801956:	85 c0                	test   %eax,%eax
  801958:	74 f2                	je     80194c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 16                	js     801974 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80195e:	83 f8 04             	cmp    $0x4,%eax
  801961:	74 0c                	je     80196f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801963:	8b 55 0c             	mov    0xc(%ebp),%edx
  801966:	88 02                	mov    %al,(%edx)
	return 1;
  801968:	b8 01 00 00 00       	mov    $0x1,%eax
  80196d:	eb 05                	jmp    801974 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80196f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801982:	6a 01                	push   $0x1
  801984:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801987:	50                   	push   %eax
  801988:	e8 ff f0 ff ff       	call   800a8c <sys_cputs>
}
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <getchar>:

int
getchar(void)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801998:	6a 01                	push   $0x1
  80199a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80199d:	50                   	push   %eax
  80199e:	6a 00                	push   $0x0
  8019a0:	e8 90 f6 ff ff       	call   801035 <read>
	if (r < 0)
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	78 0f                	js     8019bb <getchar+0x29>
		return r;
	if (r < 1)
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	7e 06                	jle    8019b6 <getchar+0x24>
		return -E_EOF;
	return c;
  8019b0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019b4:	eb 05                	jmp    8019bb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019b6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c6:	50                   	push   %eax
  8019c7:	ff 75 08             	pushl  0x8(%ebp)
  8019ca:	e8 00 f4 ff ff       	call   800dcf <fd_lookup>
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	78 11                	js     8019e7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019df:	39 10                	cmp    %edx,(%eax)
  8019e1:	0f 94 c0             	sete   %al
  8019e4:	0f b6 c0             	movzbl %al,%eax
}
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <opencons>:

int
opencons(void)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f2:	50                   	push   %eax
  8019f3:	e8 88 f3 ff ff       	call   800d80 <fd_alloc>
  8019f8:	83 c4 10             	add    $0x10,%esp
		return r;
  8019fb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 3e                	js     801a3f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a01:	83 ec 04             	sub    $0x4,%esp
  801a04:	68 07 04 00 00       	push   $0x407
  801a09:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0c:	6a 00                	push   $0x0
  801a0e:	e8 35 f1 ff ff       	call   800b48 <sys_page_alloc>
  801a13:	83 c4 10             	add    $0x10,%esp
		return r;
  801a16:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	78 23                	js     801a3f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a1c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a25:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a31:	83 ec 0c             	sub    $0xc,%esp
  801a34:	50                   	push   %eax
  801a35:	e8 1f f3 ff ff       	call   800d59 <fd2num>
  801a3a:	89 c2                	mov    %eax,%edx
  801a3c:	83 c4 10             	add    $0x10,%esp
}
  801a3f:	89 d0                	mov    %edx,%eax
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a48:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a4b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a51:	e8 b4 f0 ff ff       	call   800b0a <sys_getenvid>
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	ff 75 0c             	pushl  0xc(%ebp)
  801a5c:	ff 75 08             	pushl  0x8(%ebp)
  801a5f:	56                   	push   %esi
  801a60:	50                   	push   %eax
  801a61:	68 f8 22 80 00       	push   $0x8022f8
  801a66:	e8 55 e7 ff ff       	call   8001c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a6b:	83 c4 18             	add    $0x18,%esp
  801a6e:	53                   	push   %ebx
  801a6f:	ff 75 10             	pushl  0x10(%ebp)
  801a72:	e8 f8 e6 ff ff       	call   80016f <vcprintf>
	cprintf("\n");
  801a77:	c7 04 24 e3 22 80 00 	movl   $0x8022e3,(%esp)
  801a7e:	e8 3d e7 ff ff       	call   8001c0 <cprintf>
  801a83:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a86:	cc                   	int3   
  801a87:	eb fd                	jmp    801a86 <_panic+0x43>

00801a89 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a97:	85 c0                	test   %eax,%eax
  801a99:	75 12                	jne    801aad <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	68 00 00 c0 ee       	push   $0xeec00000
  801aa3:	e8 50 f2 ff ff       	call   800cf8 <sys_ipc_recv>
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	eb 0c                	jmp    801ab9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	50                   	push   %eax
  801ab1:	e8 42 f2 ff ff       	call   800cf8 <sys_ipc_recv>
  801ab6:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ab9:	85 f6                	test   %esi,%esi
  801abb:	0f 95 c1             	setne  %cl
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	0f 95 c2             	setne  %dl
  801ac3:	84 d1                	test   %dl,%cl
  801ac5:	74 09                	je     801ad0 <ipc_recv+0x47>
  801ac7:	89 c2                	mov    %eax,%edx
  801ac9:	c1 ea 1f             	shr    $0x1f,%edx
  801acc:	84 d2                	test   %dl,%dl
  801ace:	75 27                	jne    801af7 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ad0:	85 f6                	test   %esi,%esi
  801ad2:	74 0a                	je     801ade <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801ad4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad9:	8b 40 7c             	mov    0x7c(%eax),%eax
  801adc:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ade:	85 db                	test   %ebx,%ebx
  801ae0:	74 0d                	je     801aef <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ae2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801aed:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801aef:	a1 04 40 80 00       	mov    0x804004,%eax
  801af4:	8b 40 78             	mov    0x78(%eax),%eax
}
  801af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afa:	5b                   	pop    %ebx
  801afb:	5e                   	pop    %esi
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    

00801afe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 0c             	sub    $0xc,%esp
  801b07:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b10:	85 db                	test   %ebx,%ebx
  801b12:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b17:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b1a:	ff 75 14             	pushl  0x14(%ebp)
  801b1d:	53                   	push   %ebx
  801b1e:	56                   	push   %esi
  801b1f:	57                   	push   %edi
  801b20:	e8 b0 f1 ff ff       	call   800cd5 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b25:	89 c2                	mov    %eax,%edx
  801b27:	c1 ea 1f             	shr    $0x1f,%edx
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	84 d2                	test   %dl,%dl
  801b2f:	74 17                	je     801b48 <ipc_send+0x4a>
  801b31:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b34:	74 12                	je     801b48 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b36:	50                   	push   %eax
  801b37:	68 1c 23 80 00       	push   $0x80231c
  801b3c:	6a 47                	push   $0x47
  801b3e:	68 2a 23 80 00       	push   $0x80232a
  801b43:	e8 fb fe ff ff       	call   801a43 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b48:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b4b:	75 07                	jne    801b54 <ipc_send+0x56>
			sys_yield();
  801b4d:	e8 d7 ef ff ff       	call   800b29 <sys_yield>
  801b52:	eb c6                	jmp    801b1a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b54:	85 c0                	test   %eax,%eax
  801b56:	75 c2                	jne    801b1a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b6b:	89 c2                	mov    %eax,%edx
  801b6d:	c1 e2 07             	shl    $0x7,%edx
  801b70:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b77:	8b 52 58             	mov    0x58(%edx),%edx
  801b7a:	39 ca                	cmp    %ecx,%edx
  801b7c:	75 11                	jne    801b8f <ipc_find_env+0x2f>
			return envs[i].env_id;
  801b7e:	89 c2                	mov    %eax,%edx
  801b80:	c1 e2 07             	shl    $0x7,%edx
  801b83:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801b8a:	8b 40 50             	mov    0x50(%eax),%eax
  801b8d:	eb 0f                	jmp    801b9e <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b8f:	83 c0 01             	add    $0x1,%eax
  801b92:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b97:	75 d2                	jne    801b6b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba6:	89 d0                	mov    %edx,%eax
  801ba8:	c1 e8 16             	shr    $0x16,%eax
  801bab:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bb2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb7:	f6 c1 01             	test   $0x1,%cl
  801bba:	74 1d                	je     801bd9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bbc:	c1 ea 0c             	shr    $0xc,%edx
  801bbf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bc6:	f6 c2 01             	test   $0x1,%dl
  801bc9:	74 0e                	je     801bd9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bcb:	c1 ea 0c             	shr    $0xc,%edx
  801bce:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bd5:	ef 
  801bd6:	0f b7 c0             	movzwl %ax,%eax
}
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    
  801bdb:	66 90                	xchg   %ax,%ax
  801bdd:	66 90                	xchg   %ax,%ax
  801bdf:	90                   	nop

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
  801be7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801beb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bf7:	85 f6                	test   %esi,%esi
  801bf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bfd:	89 ca                	mov    %ecx,%edx
  801bff:	89 f8                	mov    %edi,%eax
  801c01:	75 3d                	jne    801c40 <__udivdi3+0x60>
  801c03:	39 cf                	cmp    %ecx,%edi
  801c05:	0f 87 c5 00 00 00    	ja     801cd0 <__udivdi3+0xf0>
  801c0b:	85 ff                	test   %edi,%edi
  801c0d:	89 fd                	mov    %edi,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f7                	div    %edi
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 c8                	mov    %ecx,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c1                	mov    %eax,%ecx
  801c24:	89 d8                	mov    %ebx,%eax
  801c26:	89 cf                	mov    %ecx,%edi
  801c28:	f7 f5                	div    %ebp
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	89 fa                	mov    %edi,%edx
  801c30:	83 c4 1c             	add    $0x1c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
  801c38:	90                   	nop
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	39 ce                	cmp    %ecx,%esi
  801c42:	77 74                	ja     801cb8 <__udivdi3+0xd8>
  801c44:	0f bd fe             	bsr    %esi,%edi
  801c47:	83 f7 1f             	xor    $0x1f,%edi
  801c4a:	0f 84 98 00 00 00    	je     801ce8 <__udivdi3+0x108>
  801c50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	89 c5                	mov    %eax,%ebp
  801c59:	29 fb                	sub    %edi,%ebx
  801c5b:	d3 e6                	shl    %cl,%esi
  801c5d:	89 d9                	mov    %ebx,%ecx
  801c5f:	d3 ed                	shr    %cl,%ebp
  801c61:	89 f9                	mov    %edi,%ecx
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	09 ee                	or     %ebp,%esi
  801c67:	89 d9                	mov    %ebx,%ecx
  801c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6d:	89 d5                	mov    %edx,%ebp
  801c6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c73:	d3 ed                	shr    %cl,%ebp
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e2                	shl    %cl,%edx
  801c79:	89 d9                	mov    %ebx,%ecx
  801c7b:	d3 e8                	shr    %cl,%eax
  801c7d:	09 c2                	or     %eax,%edx
  801c7f:	89 d0                	mov    %edx,%eax
  801c81:	89 ea                	mov    %ebp,%edx
  801c83:	f7 f6                	div    %esi
  801c85:	89 d5                	mov    %edx,%ebp
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	f7 64 24 0c          	mull   0xc(%esp)
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	72 10                	jb     801ca1 <__udivdi3+0xc1>
  801c91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 e6                	shl    %cl,%esi
  801c99:	39 c6                	cmp    %eax,%esi
  801c9b:	73 07                	jae    801ca4 <__udivdi3+0xc4>
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	75 03                	jne    801ca4 <__udivdi3+0xc4>
  801ca1:	83 eb 01             	sub    $0x1,%ebx
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	89 fa                	mov    %edi,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	31 ff                	xor    %edi,%edi
  801cba:	31 db                	xor    %ebx,%ebx
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
  801cd0:	89 d8                	mov    %ebx,%eax
  801cd2:	f7 f7                	div    %edi
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 c3                	mov    %eax,%ebx
  801cd8:	89 d8                	mov    %ebx,%eax
  801cda:	89 fa                	mov    %edi,%edx
  801cdc:	83 c4 1c             	add    $0x1c,%esp
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	39 ce                	cmp    %ecx,%esi
  801cea:	72 0c                	jb     801cf8 <__udivdi3+0x118>
  801cec:	31 db                	xor    %ebx,%ebx
  801cee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cf2:	0f 87 34 ff ff ff    	ja     801c2c <__udivdi3+0x4c>
  801cf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cfd:	e9 2a ff ff ff       	jmp    801c2c <__udivdi3+0x4c>
  801d02:	66 90                	xchg   %ax,%ax
  801d04:	66 90                	xchg   %ax,%ax
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 1c             	sub    $0x1c,%esp
  801d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d27:	85 d2                	test   %edx,%edx
  801d29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d31:	89 f3                	mov    %esi,%ebx
  801d33:	89 3c 24             	mov    %edi,(%esp)
  801d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3a:	75 1c                	jne    801d58 <__umoddi3+0x48>
  801d3c:	39 f7                	cmp    %esi,%edi
  801d3e:	76 50                	jbe    801d90 <__umoddi3+0x80>
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	f7 f7                	div    %edi
  801d46:	89 d0                	mov    %edx,%eax
  801d48:	31 d2                	xor    %edx,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	39 f2                	cmp    %esi,%edx
  801d5a:	89 d0                	mov    %edx,%eax
  801d5c:	77 52                	ja     801db0 <__umoddi3+0xa0>
  801d5e:	0f bd ea             	bsr    %edx,%ebp
  801d61:	83 f5 1f             	xor    $0x1f,%ebp
  801d64:	75 5a                	jne    801dc0 <__umoddi3+0xb0>
  801d66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d6a:	0f 82 e0 00 00 00    	jb     801e50 <__umoddi3+0x140>
  801d70:	39 0c 24             	cmp    %ecx,(%esp)
  801d73:	0f 86 d7 00 00 00    	jbe    801e50 <__umoddi3+0x140>
  801d79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d81:	83 c4 1c             	add    $0x1c,%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	85 ff                	test   %edi,%edi
  801d92:	89 fd                	mov    %edi,%ebp
  801d94:	75 0b                	jne    801da1 <__umoddi3+0x91>
  801d96:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f7                	div    %edi
  801d9f:	89 c5                	mov    %eax,%ebp
  801da1:	89 f0                	mov    %esi,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f5                	div    %ebp
  801da7:	89 c8                	mov    %ecx,%eax
  801da9:	f7 f5                	div    %ebp
  801dab:	89 d0                	mov    %edx,%eax
  801dad:	eb 99                	jmp    801d48 <__umoddi3+0x38>
  801daf:	90                   	nop
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	83 c4 1c             	add    $0x1c,%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5f                   	pop    %edi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    
  801dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	8b 34 24             	mov    (%esp),%esi
  801dc3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dc8:	89 e9                	mov    %ebp,%ecx
  801dca:	29 ef                	sub    %ebp,%edi
  801dcc:	d3 e0                	shl    %cl,%eax
  801dce:	89 f9                	mov    %edi,%ecx
  801dd0:	89 f2                	mov    %esi,%edx
  801dd2:	d3 ea                	shr    %cl,%edx
  801dd4:	89 e9                	mov    %ebp,%ecx
  801dd6:	09 c2                	or     %eax,%edx
  801dd8:	89 d8                	mov    %ebx,%eax
  801dda:	89 14 24             	mov    %edx,(%esp)
  801ddd:	89 f2                	mov    %esi,%edx
  801ddf:	d3 e2                	shl    %cl,%edx
  801de1:	89 f9                	mov    %edi,%ecx
  801de3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801de7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	89 c6                	mov    %eax,%esi
  801df1:	d3 e3                	shl    %cl,%ebx
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 d0                	mov    %edx,%eax
  801df7:	d3 e8                	shr    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	09 d8                	or     %ebx,%eax
  801dfd:	89 d3                	mov    %edx,%ebx
  801dff:	89 f2                	mov    %esi,%edx
  801e01:	f7 34 24             	divl   (%esp)
  801e04:	89 d6                	mov    %edx,%esi
  801e06:	d3 e3                	shl    %cl,%ebx
  801e08:	f7 64 24 04          	mull   0x4(%esp)
  801e0c:	39 d6                	cmp    %edx,%esi
  801e0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e12:	89 d1                	mov    %edx,%ecx
  801e14:	89 c3                	mov    %eax,%ebx
  801e16:	72 08                	jb     801e20 <__umoddi3+0x110>
  801e18:	75 11                	jne    801e2b <__umoddi3+0x11b>
  801e1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e1e:	73 0b                	jae    801e2b <__umoddi3+0x11b>
  801e20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e24:	1b 14 24             	sbb    (%esp),%edx
  801e27:	89 d1                	mov    %edx,%ecx
  801e29:	89 c3                	mov    %eax,%ebx
  801e2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e2f:	29 da                	sub    %ebx,%edx
  801e31:	19 ce                	sbb    %ecx,%esi
  801e33:	89 f9                	mov    %edi,%ecx
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	d3 e0                	shl    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	d3 ea                	shr    %cl,%edx
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	d3 ee                	shr    %cl,%esi
  801e41:	09 d0                	or     %edx,%eax
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	83 c4 1c             	add    $0x1c,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi
  801e50:	29 f9                	sub    %edi,%ecx
  801e52:	19 d6                	sbb    %edx,%esi
  801e54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e5c:	e9 18 ff ff ff       	jmp    801d79 <__umoddi3+0x69>
