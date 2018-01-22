
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 4b 00 00 00       	call   80007c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <func>:

//TESTING THREADS CUZ I CANT DO MAKEFILES


void func()
{	
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i;
	for(i = 0; i < 10; i++)
	{
		cprintf("HI \n");	
  80003f:	83 ec 0c             	sub    $0xc,%esp
  800042:	68 00 22 80 00       	push   $0x802200
  800047:	e8 83 01 00 00       	call   8001cf <cprintf>


void func()
{	
	int i;
	for(i = 0; i < 10; i++)
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	83 eb 01             	sub    $0x1,%ebx
  800052:	75 eb                	jne    80003f <func+0xc>
	{
		cprintf("HI \n");	
	}
}
  800054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <umain>:


void
umain(int argc, char **argv)
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	83 ec 14             	sub    $0x14,%esp
	envid_t id = thread_create(func);
  80005f:	68 33 00 80 00       	push   $0x800033
  800064:	e8 b0 0f 00 00       	call   801019 <thread_create>
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id);
  800069:	83 c4 08             	add    $0x8,%esp
  80006c:	50                   	push   %eax
  80006d:	68 05 22 80 00       	push   $0x802205
  800072:	e8 58 01 00 00       	call   8001cf <cprintf>
	//exit();
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	c9                   	leave  
  80007b:	c3                   	ret    

0080007c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	57                   	push   %edi
  800080:	56                   	push   %esi
  800081:	53                   	push   %ebx
  800082:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800085:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80008c:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80008f:	e8 85 0a 00 00       	call   800b19 <sys_getenvid>
  800094:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	50                   	push   %eax
  80009a:	68 24 22 80 00       	push   $0x802224
  80009f:	e8 2b 01 00 00       	call   8001cf <cprintf>
  8000a4:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000aa:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000b7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000bc:	89 c1                	mov    %eax,%ecx
  8000be:	c1 e1 07             	shl    $0x7,%ecx
  8000c1:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000c8:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000cb:	39 cb                	cmp    %ecx,%ebx
  8000cd:	0f 44 fa             	cmove  %edx,%edi
  8000d0:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000d5:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000d8:	83 c0 01             	add    $0x1,%eax
  8000db:	81 c2 84 00 00 00    	add    $0x84,%edx
  8000e1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8000e6:	75 d4                	jne    8000bc <libmain+0x40>
  8000e8:	89 f0                	mov    %esi,%eax
  8000ea:	84 c0                	test   %al,%al
  8000ec:	74 06                	je     8000f4 <libmain+0x78>
  8000ee:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000f8:	7e 0a                	jle    800104 <libmain+0x88>
		binaryname = argv[0];
  8000fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fd:	8b 00                	mov    (%eax),%eax
  8000ff:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800104:	83 ec 08             	sub    $0x8,%esp
  800107:	ff 75 0c             	pushl  0xc(%ebp)
  80010a:	ff 75 08             	pushl  0x8(%ebp)
  80010d:	e8 47 ff ff ff       	call   800059 <umain>

	// exit gracefully
	exit();
  800112:	e8 0b 00 00 00       	call   800122 <exit>
}
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011d:	5b                   	pop    %ebx
  80011e:	5e                   	pop    %esi
  80011f:	5f                   	pop    %edi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 ee 10 00 00       	call   80121b <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 a1 09 00 00       	call   800ad8 <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	53                   	push   %ebx
  800140:	83 ec 04             	sub    $0x4,%esp
  800143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800146:	8b 13                	mov    (%ebx),%edx
  800148:	8d 42 01             	lea    0x1(%edx),%eax
  80014b:	89 03                	mov    %eax,(%ebx)
  80014d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800150:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800154:	3d ff 00 00 00       	cmp    $0xff,%eax
  800159:	75 1a                	jne    800175 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80015b:	83 ec 08             	sub    $0x8,%esp
  80015e:	68 ff 00 00 00       	push   $0xff
  800163:	8d 43 08             	lea    0x8(%ebx),%eax
  800166:	50                   	push   %eax
  800167:	e8 2f 09 00 00       	call   800a9b <sys_cputs>
		b->idx = 0;
  80016c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800172:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800175:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800179:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    

0080017e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800187:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018e:	00 00 00 
	b.cnt = 0;
  800191:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800198:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019b:	ff 75 0c             	pushl  0xc(%ebp)
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a7:	50                   	push   %eax
  8001a8:	68 3c 01 80 00       	push   $0x80013c
  8001ad:	e8 54 01 00 00       	call   800306 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b2:	83 c4 08             	add    $0x8,%esp
  8001b5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001bb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c1:	50                   	push   %eax
  8001c2:	e8 d4 08 00 00       	call   800a9b <sys_cputs>

	return b.cnt;
}
  8001c7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d8:	50                   	push   %eax
  8001d9:	ff 75 08             	pushl  0x8(%ebp)
  8001dc:	e8 9d ff ff ff       	call   80017e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 1c             	sub    $0x1c,%esp
  8001ec:	89 c7                	mov    %eax,%edi
  8001ee:	89 d6                	mov    %edx,%esi
  8001f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800204:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800207:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020a:	39 d3                	cmp    %edx,%ebx
  80020c:	72 05                	jb     800213 <printnum+0x30>
  80020e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800211:	77 45                	ja     800258 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	ff 75 18             	pushl  0x18(%ebp)
  800219:	8b 45 14             	mov    0x14(%ebp),%eax
  80021c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021f:	53                   	push   %ebx
  800220:	ff 75 10             	pushl  0x10(%ebp)
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	ff 75 e4             	pushl  -0x1c(%ebp)
  800229:	ff 75 e0             	pushl  -0x20(%ebp)
  80022c:	ff 75 dc             	pushl  -0x24(%ebp)
  80022f:	ff 75 d8             	pushl  -0x28(%ebp)
  800232:	e8 39 1d 00 00       	call   801f70 <__udivdi3>
  800237:	83 c4 18             	add    $0x18,%esp
  80023a:	52                   	push   %edx
  80023b:	50                   	push   %eax
  80023c:	89 f2                	mov    %esi,%edx
  80023e:	89 f8                	mov    %edi,%eax
  800240:	e8 9e ff ff ff       	call   8001e3 <printnum>
  800245:	83 c4 20             	add    $0x20,%esp
  800248:	eb 18                	jmp    800262 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	56                   	push   %esi
  80024e:	ff 75 18             	pushl  0x18(%ebp)
  800251:	ff d7                	call   *%edi
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	eb 03                	jmp    80025b <printnum+0x78>
  800258:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025b:	83 eb 01             	sub    $0x1,%ebx
  80025e:	85 db                	test   %ebx,%ebx
  800260:	7f e8                	jg     80024a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	56                   	push   %esi
  800266:	83 ec 04             	sub    $0x4,%esp
  800269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026c:	ff 75 e0             	pushl  -0x20(%ebp)
  80026f:	ff 75 dc             	pushl  -0x24(%ebp)
  800272:	ff 75 d8             	pushl  -0x28(%ebp)
  800275:	e8 26 1e 00 00       	call   8020a0 <__umoddi3>
  80027a:	83 c4 14             	add    $0x14,%esp
  80027d:	0f be 80 4d 22 80 00 	movsbl 0x80224d(%eax),%eax
  800284:	50                   	push   %eax
  800285:	ff d7                	call   *%edi
}
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800295:	83 fa 01             	cmp    $0x1,%edx
  800298:	7e 0e                	jle    8002a8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	eb 22                	jmp    8002ca <getuint+0x38>
	else if (lflag)
  8002a8:	85 d2                	test   %edx,%edx
  8002aa:	74 10                	je     8002bc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ba:	eb 0e                	jmp    8002ca <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002db:	73 0a                	jae    8002e7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	88 02                	mov    %al,(%edx)
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f2:	50                   	push   %eax
  8002f3:	ff 75 10             	pushl  0x10(%ebp)
  8002f6:	ff 75 0c             	pushl  0xc(%ebp)
  8002f9:	ff 75 08             	pushl  0x8(%ebp)
  8002fc:	e8 05 00 00 00       	call   800306 <vprintfmt>
	va_end(ap);
}
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 2c             	sub    $0x2c,%esp
  80030f:	8b 75 08             	mov    0x8(%ebp),%esi
  800312:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800315:	8b 7d 10             	mov    0x10(%ebp),%edi
  800318:	eb 12                	jmp    80032c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031a:	85 c0                	test   %eax,%eax
  80031c:	0f 84 89 03 00 00    	je     8006ab <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	53                   	push   %ebx
  800326:	50                   	push   %eax
  800327:	ff d6                	call   *%esi
  800329:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032c:	83 c7 01             	add    $0x1,%edi
  80032f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800333:	83 f8 25             	cmp    $0x25,%eax
  800336:	75 e2                	jne    80031a <vprintfmt+0x14>
  800338:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80033c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800343:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	eb 07                	jmp    80035f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8d 47 01             	lea    0x1(%edi),%eax
  800362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800365:	0f b6 07             	movzbl (%edi),%eax
  800368:	0f b6 c8             	movzbl %al,%ecx
  80036b:	83 e8 23             	sub    $0x23,%eax
  80036e:	3c 55                	cmp    $0x55,%al
  800370:	0f 87 1a 03 00 00    	ja     800690 <vprintfmt+0x38a>
  800376:	0f b6 c0             	movzbl %al,%eax
  800379:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800383:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800387:	eb d6                	jmp    80035f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038c:	b8 00 00 00 00       	mov    $0x0,%eax
  800391:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800394:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800397:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80039b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80039e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a1:	83 fa 09             	cmp    $0x9,%edx
  8003a4:	77 39                	ja     8003df <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a9:	eb e9                	jmp    800394 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b4:	8b 00                	mov    (%eax),%eax
  8003b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003bc:	eb 27                	jmp    8003e5 <vprintfmt+0xdf>
  8003be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c8:	0f 49 c8             	cmovns %eax,%ecx
  8003cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d1:	eb 8c                	jmp    80035f <vprintfmt+0x59>
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003dd:	eb 80                	jmp    80035f <vprintfmt+0x59>
  8003df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e9:	0f 89 70 ff ff ff    	jns    80035f <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fc:	e9 5e ff ff ff       	jmp    80035f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800401:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800407:	e9 53 ff ff ff       	jmp    80035f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	53                   	push   %ebx
  800419:	ff 30                	pushl  (%eax)
  80041b:	ff d6                	call   *%esi
			break;
  80041d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800423:	e9 04 ff ff ff       	jmp    80032c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	89 55 14             	mov    %edx,0x14(%ebp)
  800431:	8b 00                	mov    (%eax),%eax
  800433:	99                   	cltd   
  800434:	31 d0                	xor    %edx,%eax
  800436:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800438:	83 f8 0f             	cmp    $0xf,%eax
  80043b:	7f 0b                	jg     800448 <vprintfmt+0x142>
  80043d:	8b 14 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%edx
  800444:	85 d2                	test   %edx,%edx
  800446:	75 18                	jne    800460 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800448:	50                   	push   %eax
  800449:	68 65 22 80 00       	push   $0x802265
  80044e:	53                   	push   %ebx
  80044f:	56                   	push   %esi
  800450:	e8 94 fe ff ff       	call   8002e9 <printfmt>
  800455:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 cc fe ff ff       	jmp    80032c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	52                   	push   %edx
  800461:	68 8d 26 80 00       	push   $0x80268d
  800466:	53                   	push   %ebx
  800467:	56                   	push   %esi
  800468:	e8 7c fe ff ff       	call   8002e9 <printfmt>
  80046d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800473:	e9 b4 fe ff ff       	jmp    80032c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800483:	85 ff                	test   %edi,%edi
  800485:	b8 5e 22 80 00       	mov    $0x80225e,%eax
  80048a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80048d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800491:	0f 8e 94 00 00 00    	jle    80052b <vprintfmt+0x225>
  800497:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049b:	0f 84 98 00 00 00    	je     800539 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a7:	57                   	push   %edi
  8004a8:	e8 86 02 00 00       	call   800733 <strnlen>
  8004ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b0:	29 c1                	sub    %eax,%ecx
  8004b2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c4:	eb 0f                	jmp    8004d5 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	53                   	push   %ebx
  8004ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	83 ef 01             	sub    $0x1,%edi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 ff                	test   %edi,%edi
  8004d7:	7f ed                	jg     8004c6 <vprintfmt+0x1c0>
  8004d9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004dc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004df:	85 c9                	test   %ecx,%ecx
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	0f 49 c1             	cmovns %ecx,%eax
  8004e9:	29 c1                	sub    %eax,%ecx
  8004eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f4:	89 cb                	mov    %ecx,%ebx
  8004f6:	eb 4d                	jmp    800545 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fc:	74 1b                	je     800519 <vprintfmt+0x213>
  8004fe:	0f be c0             	movsbl %al,%eax
  800501:	83 e8 20             	sub    $0x20,%eax
  800504:	83 f8 5e             	cmp    $0x5e,%eax
  800507:	76 10                	jbe    800519 <vprintfmt+0x213>
					putch('?', putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	ff 75 0c             	pushl  0xc(%ebp)
  80050f:	6a 3f                	push   $0x3f
  800511:	ff 55 08             	call   *0x8(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	eb 0d                	jmp    800526 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	ff 75 0c             	pushl  0xc(%ebp)
  80051f:	52                   	push   %edx
  800520:	ff 55 08             	call   *0x8(%ebp)
  800523:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800526:	83 eb 01             	sub    $0x1,%ebx
  800529:	eb 1a                	jmp    800545 <vprintfmt+0x23f>
  80052b:	89 75 08             	mov    %esi,0x8(%ebp)
  80052e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800531:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800534:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800537:	eb 0c                	jmp    800545 <vprintfmt+0x23f>
  800539:	89 75 08             	mov    %esi,0x8(%ebp)
  80053c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800542:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800545:	83 c7 01             	add    $0x1,%edi
  800548:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054c:	0f be d0             	movsbl %al,%edx
  80054f:	85 d2                	test   %edx,%edx
  800551:	74 23                	je     800576 <vprintfmt+0x270>
  800553:	85 f6                	test   %esi,%esi
  800555:	78 a1                	js     8004f8 <vprintfmt+0x1f2>
  800557:	83 ee 01             	sub    $0x1,%esi
  80055a:	79 9c                	jns    8004f8 <vprintfmt+0x1f2>
  80055c:	89 df                	mov    %ebx,%edi
  80055e:	8b 75 08             	mov    0x8(%ebp),%esi
  800561:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800564:	eb 18                	jmp    80057e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	53                   	push   %ebx
  80056a:	6a 20                	push   $0x20
  80056c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056e:	83 ef 01             	sub    $0x1,%edi
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	eb 08                	jmp    80057e <vprintfmt+0x278>
  800576:	89 df                	mov    %ebx,%edi
  800578:	8b 75 08             	mov    0x8(%ebp),%esi
  80057b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057e:	85 ff                	test   %edi,%edi
  800580:	7f e4                	jg     800566 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800585:	e9 a2 fd ff ff       	jmp    80032c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058a:	83 fa 01             	cmp    $0x1,%edx
  80058d:	7e 16                	jle    8005a5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 50 08             	lea    0x8(%eax),%edx
  800595:	89 55 14             	mov    %edx,0x14(%ebp)
  800598:	8b 50 04             	mov    0x4(%eax),%edx
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a3:	eb 32                	jmp    8005d7 <vprintfmt+0x2d1>
	else if (lflag)
  8005a5:	85 d2                	test   %edx,%edx
  8005a7:	74 18                	je     8005c1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b7:	89 c1                	mov    %eax,%ecx
  8005b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005bf:	eb 16                	jmp    8005d7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 04             	lea    0x4(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cf:	89 c1                	mov    %eax,%ecx
  8005d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005da:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e6:	79 74                	jns    80065c <vprintfmt+0x356>
				putch('-', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	6a 2d                	push   $0x2d
  8005ee:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f6:	f7 d8                	neg    %eax
  8005f8:	83 d2 00             	adc    $0x0,%edx
  8005fb:	f7 da                	neg    %edx
  8005fd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800600:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800605:	eb 55                	jmp    80065c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800607:	8d 45 14             	lea    0x14(%ebp),%eax
  80060a:	e8 83 fc ff ff       	call   800292 <getuint>
			base = 10;
  80060f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800614:	eb 46                	jmp    80065c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 74 fc ff ff       	call   800292 <getuint>
			base = 8;
  80061e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800623:	eb 37                	jmp    80065c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 30                	push   $0x30
  80062b:	ff d6                	call   *%esi
			putch('x', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 78                	push   $0x78
  800633:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 50 04             	lea    0x4(%eax),%edx
  80063b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800645:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800648:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80064d:	eb 0d                	jmp    80065c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 3b fc ff ff       	call   800292 <getuint>
			base = 16;
  800657:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065c:	83 ec 0c             	sub    $0xc,%esp
  80065f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800663:	57                   	push   %edi
  800664:	ff 75 e0             	pushl  -0x20(%ebp)
  800667:	51                   	push   %ecx
  800668:	52                   	push   %edx
  800669:	50                   	push   %eax
  80066a:	89 da                	mov    %ebx,%edx
  80066c:	89 f0                	mov    %esi,%eax
  80066e:	e8 70 fb ff ff       	call   8001e3 <printnum>
			break;
  800673:	83 c4 20             	add    $0x20,%esp
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800679:	e9 ae fc ff ff       	jmp    80032c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	51                   	push   %ecx
  800683:	ff d6                	call   *%esi
			break;
  800685:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068b:	e9 9c fc ff ff       	jmp    80032c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 25                	push   $0x25
  800696:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	eb 03                	jmp    8006a0 <vprintfmt+0x39a>
  80069d:	83 ef 01             	sub    $0x1,%edi
  8006a0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a4:	75 f7                	jne    80069d <vprintfmt+0x397>
  8006a6:	e9 81 fc ff ff       	jmp    80032c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ae:	5b                   	pop    %ebx
  8006af:	5e                   	pop    %esi
  8006b0:	5f                   	pop    %edi
  8006b1:	5d                   	pop    %ebp
  8006b2:	c3                   	ret    

008006b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	83 ec 18             	sub    $0x18,%esp
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 26                	je     8006fa <vsnprintf+0x47>
  8006d4:	85 d2                	test   %edx,%edx
  8006d6:	7e 22                	jle    8006fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d8:	ff 75 14             	pushl  0x14(%ebp)
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e1:	50                   	push   %eax
  8006e2:	68 cc 02 80 00       	push   $0x8002cc
  8006e7:	e8 1a fc ff ff       	call   800306 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	eb 05                	jmp    8006ff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    

00800701 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070a:	50                   	push   %eax
  80070b:	ff 75 10             	pushl  0x10(%ebp)
  80070e:	ff 75 0c             	pushl  0xc(%ebp)
  800711:	ff 75 08             	pushl  0x8(%ebp)
  800714:	e8 9a ff ff ff       	call   8006b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800719:	c9                   	leave  
  80071a:	c3                   	ret    

0080071b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800721:	b8 00 00 00 00       	mov    $0x0,%eax
  800726:	eb 03                	jmp    80072b <strlen+0x10>
		n++;
  800728:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072f:	75 f7                	jne    800728 <strlen+0xd>
		n++;
	return n;
}
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800739:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073c:	ba 00 00 00 00       	mov    $0x0,%edx
  800741:	eb 03                	jmp    800746 <strnlen+0x13>
		n++;
  800743:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800746:	39 c2                	cmp    %eax,%edx
  800748:	74 08                	je     800752 <strnlen+0x1f>
  80074a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80074e:	75 f3                	jne    800743 <strnlen+0x10>
  800750:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	53                   	push   %ebx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075e:	89 c2                	mov    %eax,%edx
  800760:	83 c2 01             	add    $0x1,%edx
  800763:	83 c1 01             	add    $0x1,%ecx
  800766:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076d:	84 db                	test   %bl,%bl
  80076f:	75 ef                	jne    800760 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800771:	5b                   	pop    %ebx
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077b:	53                   	push   %ebx
  80077c:	e8 9a ff ff ff       	call   80071b <strlen>
  800781:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800784:	ff 75 0c             	pushl  0xc(%ebp)
  800787:	01 d8                	add    %ebx,%eax
  800789:	50                   	push   %eax
  80078a:	e8 c5 ff ff ff       	call   800754 <strcpy>
	return dst;
}
  80078f:	89 d8                	mov    %ebx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
  80079b:	8b 75 08             	mov    0x8(%ebp),%esi
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a1:	89 f3                	mov    %esi,%ebx
  8007a3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a6:	89 f2                	mov    %esi,%edx
  8007a8:	eb 0f                	jmp    8007b9 <strncpy+0x23>
		*dst++ = *src;
  8007aa:	83 c2 01             	add    $0x1,%edx
  8007ad:	0f b6 01             	movzbl (%ecx),%eax
  8007b0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	39 da                	cmp    %ebx,%edx
  8007bb:	75 ed                	jne    8007aa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007bd:	89 f0                	mov    %esi,%eax
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	56                   	push   %esi
  8007c7:	53                   	push   %ebx
  8007c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ce:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 21                	je     8007f8 <strlcpy+0x35>
  8007d7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007db:	89 f2                	mov    %esi,%edx
  8007dd:	eb 09                	jmp    8007e8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007df:	83 c2 01             	add    $0x1,%edx
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e8:	39 c2                	cmp    %eax,%edx
  8007ea:	74 09                	je     8007f5 <strlcpy+0x32>
  8007ec:	0f b6 19             	movzbl (%ecx),%ebx
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	75 ec                	jne    8007df <strlcpy+0x1c>
  8007f3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f8:	29 f0                	sub    %esi,%eax
}
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800807:	eb 06                	jmp    80080f <strcmp+0x11>
		p++, q++;
  800809:	83 c1 01             	add    $0x1,%ecx
  80080c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	84 c0                	test   %al,%al
  800814:	74 04                	je     80081a <strcmp+0x1c>
  800816:	3a 02                	cmp    (%edx),%al
  800818:	74 ef                	je     800809 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081a:	0f b6 c0             	movzbl %al,%eax
  80081d:	0f b6 12             	movzbl (%edx),%edx
  800820:	29 d0                	sub    %edx,%eax
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 c3                	mov    %eax,%ebx
  800830:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800833:	eb 06                	jmp    80083b <strncmp+0x17>
		n--, p++, q++;
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083b:	39 d8                	cmp    %ebx,%eax
  80083d:	74 15                	je     800854 <strncmp+0x30>
  80083f:	0f b6 08             	movzbl (%eax),%ecx
  800842:	84 c9                	test   %cl,%cl
  800844:	74 04                	je     80084a <strncmp+0x26>
  800846:	3a 0a                	cmp    (%edx),%cl
  800848:	74 eb                	je     800835 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084a:	0f b6 00             	movzbl (%eax),%eax
  80084d:	0f b6 12             	movzbl (%edx),%edx
  800850:	29 d0                	sub    %edx,%eax
  800852:	eb 05                	jmp    800859 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800859:	5b                   	pop    %ebx
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800866:	eb 07                	jmp    80086f <strchr+0x13>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 0f                	je     80087b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	0f b6 10             	movzbl (%eax),%edx
  800872:	84 d2                	test   %dl,%dl
  800874:	75 f2                	jne    800868 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800887:	eb 03                	jmp    80088c <strfind+0xf>
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80088f:	38 ca                	cmp    %cl,%dl
  800891:	74 04                	je     800897 <strfind+0x1a>
  800893:	84 d2                	test   %dl,%dl
  800895:	75 f2                	jne    800889 <strfind+0xc>
			break;
	return (char *) s;
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	57                   	push   %edi
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
  80089f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a5:	85 c9                	test   %ecx,%ecx
  8008a7:	74 36                	je     8008df <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008af:	75 28                	jne    8008d9 <memset+0x40>
  8008b1:	f6 c1 03             	test   $0x3,%cl
  8008b4:	75 23                	jne    8008d9 <memset+0x40>
		c &= 0xFF;
  8008b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ba:	89 d3                	mov    %edx,%ebx
  8008bc:	c1 e3 08             	shl    $0x8,%ebx
  8008bf:	89 d6                	mov    %edx,%esi
  8008c1:	c1 e6 18             	shl    $0x18,%esi
  8008c4:	89 d0                	mov    %edx,%eax
  8008c6:	c1 e0 10             	shl    $0x10,%eax
  8008c9:	09 f0                	or     %esi,%eax
  8008cb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008cd:	89 d8                	mov    %ebx,%eax
  8008cf:	09 d0                	or     %edx,%eax
  8008d1:	c1 e9 02             	shr    $0x2,%ecx
  8008d4:	fc                   	cld    
  8008d5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d7:	eb 06                	jmp    8008df <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dc:	fc                   	cld    
  8008dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008df:	89 f8                	mov    %edi,%eax
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5f                   	pop    %edi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	57                   	push   %edi
  8008ea:	56                   	push   %esi
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f4:	39 c6                	cmp    %eax,%esi
  8008f6:	73 35                	jae    80092d <memmove+0x47>
  8008f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fb:	39 d0                	cmp    %edx,%eax
  8008fd:	73 2e                	jae    80092d <memmove+0x47>
		s += n;
		d += n;
  8008ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800902:	89 d6                	mov    %edx,%esi
  800904:	09 fe                	or     %edi,%esi
  800906:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090c:	75 13                	jne    800921 <memmove+0x3b>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 0e                	jne    800921 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800913:	83 ef 04             	sub    $0x4,%edi
  800916:	8d 72 fc             	lea    -0x4(%edx),%esi
  800919:	c1 e9 02             	shr    $0x2,%ecx
  80091c:	fd                   	std    
  80091d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091f:	eb 09                	jmp    80092a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800921:	83 ef 01             	sub    $0x1,%edi
  800924:	8d 72 ff             	lea    -0x1(%edx),%esi
  800927:	fd                   	std    
  800928:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092a:	fc                   	cld    
  80092b:	eb 1d                	jmp    80094a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092d:	89 f2                	mov    %esi,%edx
  80092f:	09 c2                	or     %eax,%edx
  800931:	f6 c2 03             	test   $0x3,%dl
  800934:	75 0f                	jne    800945 <memmove+0x5f>
  800936:	f6 c1 03             	test   $0x3,%cl
  800939:	75 0a                	jne    800945 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	89 c7                	mov    %eax,%edi
  800940:	fc                   	cld    
  800941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800943:	eb 05                	jmp    80094a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800951:	ff 75 10             	pushl  0x10(%ebp)
  800954:	ff 75 0c             	pushl  0xc(%ebp)
  800957:	ff 75 08             	pushl  0x8(%ebp)
  80095a:	e8 87 ff ff ff       	call   8008e6 <memmove>
}
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 c6                	mov    %eax,%esi
  80096e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800971:	eb 1a                	jmp    80098d <memcmp+0x2c>
		if (*s1 != *s2)
  800973:	0f b6 08             	movzbl (%eax),%ecx
  800976:	0f b6 1a             	movzbl (%edx),%ebx
  800979:	38 d9                	cmp    %bl,%cl
  80097b:	74 0a                	je     800987 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80097d:	0f b6 c1             	movzbl %cl,%eax
  800980:	0f b6 db             	movzbl %bl,%ebx
  800983:	29 d8                	sub    %ebx,%eax
  800985:	eb 0f                	jmp    800996 <memcmp+0x35>
		s1++, s2++;
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098d:	39 f0                	cmp    %esi,%eax
  80098f:	75 e2                	jne    800973 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a1:	89 c1                	mov    %eax,%ecx
  8009a3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009aa:	eb 0a                	jmp    8009b6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ac:	0f b6 10             	movzbl (%eax),%edx
  8009af:	39 da                	cmp    %ebx,%edx
  8009b1:	74 07                	je     8009ba <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	39 c8                	cmp    %ecx,%eax
  8009b8:	72 f2                	jb     8009ac <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c9:	eb 03                	jmp    8009ce <strtol+0x11>
		s++;
  8009cb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	3c 20                	cmp    $0x20,%al
  8009d3:	74 f6                	je     8009cb <strtol+0xe>
  8009d5:	3c 09                	cmp    $0x9,%al
  8009d7:	74 f2                	je     8009cb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d9:	3c 2b                	cmp    $0x2b,%al
  8009db:	75 0a                	jne    8009e7 <strtol+0x2a>
		s++;
  8009dd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e5:	eb 11                	jmp    8009f8 <strtol+0x3b>
  8009e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ec:	3c 2d                	cmp    $0x2d,%al
  8009ee:	75 08                	jne    8009f8 <strtol+0x3b>
		s++, neg = 1;
  8009f0:	83 c1 01             	add    $0x1,%ecx
  8009f3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fe:	75 15                	jne    800a15 <strtol+0x58>
  800a00:	80 39 30             	cmpb   $0x30,(%ecx)
  800a03:	75 10                	jne    800a15 <strtol+0x58>
  800a05:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a09:	75 7c                	jne    800a87 <strtol+0xca>
		s += 2, base = 16;
  800a0b:	83 c1 02             	add    $0x2,%ecx
  800a0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a13:	eb 16                	jmp    800a2b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a15:	85 db                	test   %ebx,%ebx
  800a17:	75 12                	jne    800a2b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a19:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a21:	75 08                	jne    800a2b <strtol+0x6e>
		s++, base = 8;
  800a23:	83 c1 01             	add    $0x1,%ecx
  800a26:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a33:	0f b6 11             	movzbl (%ecx),%edx
  800a36:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a39:	89 f3                	mov    %esi,%ebx
  800a3b:	80 fb 09             	cmp    $0x9,%bl
  800a3e:	77 08                	ja     800a48 <strtol+0x8b>
			dig = *s - '0';
  800a40:	0f be d2             	movsbl %dl,%edx
  800a43:	83 ea 30             	sub    $0x30,%edx
  800a46:	eb 22                	jmp    800a6a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a48:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4b:	89 f3                	mov    %esi,%ebx
  800a4d:	80 fb 19             	cmp    $0x19,%bl
  800a50:	77 08                	ja     800a5a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a52:	0f be d2             	movsbl %dl,%edx
  800a55:	83 ea 57             	sub    $0x57,%edx
  800a58:	eb 10                	jmp    800a6a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a5d:	89 f3                	mov    %esi,%ebx
  800a5f:	80 fb 19             	cmp    $0x19,%bl
  800a62:	77 16                	ja     800a7a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a64:	0f be d2             	movsbl %dl,%edx
  800a67:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a6d:	7d 0b                	jge    800a7a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a6f:	83 c1 01             	add    $0x1,%ecx
  800a72:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a76:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a78:	eb b9                	jmp    800a33 <strtol+0x76>

	if (endptr)
  800a7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7e:	74 0d                	je     800a8d <strtol+0xd0>
		*endptr = (char *) s;
  800a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a83:	89 0e                	mov    %ecx,(%esi)
  800a85:	eb 06                	jmp    800a8d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a87:	85 db                	test   %ebx,%ebx
  800a89:	74 98                	je     800a23 <strtol+0x66>
  800a8b:	eb 9e                	jmp    800a2b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	f7 da                	neg    %edx
  800a91:	85 ff                	test   %edi,%edi
  800a93:	0f 45 c2             	cmovne %edx,%eax
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	89 c7                	mov    %eax,%edi
  800ab0:	89 c6                	mov    %eax,%esi
  800ab2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac9:	89 d1                	mov    %edx,%ecx
  800acb:	89 d3                	mov    %edx,%ebx
  800acd:	89 d7                	mov    %edx,%edi
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae6:	b8 03 00 00 00       	mov    $0x3,%eax
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	89 cb                	mov    %ecx,%ebx
  800af0:	89 cf                	mov    %ecx,%edi
  800af2:	89 ce                	mov    %ecx,%esi
  800af4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af6:	85 c0                	test   %eax,%eax
  800af8:	7e 17                	jle    800b11 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afa:	83 ec 0c             	sub    $0xc,%esp
  800afd:	50                   	push   %eax
  800afe:	6a 03                	push   $0x3
  800b00:	68 3f 25 80 00       	push   $0x80253f
  800b05:	6a 23                	push   $0x23
  800b07:	68 5c 25 80 00       	push   $0x80255c
  800b0c:	e8 29 12 00 00       	call   801d3a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b24:	b8 02 00 00 00       	mov    $0x2,%eax
  800b29:	89 d1                	mov    %edx,%ecx
  800b2b:	89 d3                	mov    %edx,%ebx
  800b2d:	89 d7                	mov    %edx,%edi
  800b2f:	89 d6                	mov    %edx,%esi
  800b31:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_yield>:

void
sys_yield(void)
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
  800b43:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b60:	be 00 00 00 00       	mov    $0x0,%esi
  800b65:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	89 f7                	mov    %esi,%edi
  800b75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 04                	push   $0x4
  800b81:	68 3f 25 80 00       	push   $0x80253f
  800b86:	6a 23                	push   $0x23
  800b88:	68 5c 25 80 00       	push   $0x80255c
  800b8d:	e8 a8 11 00 00       	call   801d3a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bab:	8b 55 08             	mov    0x8(%ebp),%edx
  800bae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb4:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 05                	push   $0x5
  800bc3:	68 3f 25 80 00       	push   $0x80253f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 5c 25 80 00       	push   $0x80255c
  800bcf:	e8 66 11 00 00       	call   801d3a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 06 00 00 00       	mov    $0x6,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 06                	push   $0x6
  800c05:	68 3f 25 80 00       	push   $0x80253f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 5c 25 80 00       	push   $0x80255c
  800c11:	e8 24 11 00 00       	call   801d3a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 08                	push   $0x8
  800c47:	68 3f 25 80 00       	push   $0x80253f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 5c 25 80 00       	push   $0x80255c
  800c53:	e8 e2 10 00 00       	call   801d3a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 09                	push   $0x9
  800c89:	68 3f 25 80 00       	push   $0x80253f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 5c 25 80 00       	push   $0x80255c
  800c95:	e8 a0 10 00 00       	call   801d3a <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 0a                	push   $0xa
  800ccb:	68 3f 25 80 00       	push   $0x80253f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 5c 25 80 00       	push   $0x80255c
  800cd7:	e8 5e 10 00 00       	call   801d3a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	be 00 00 00 00       	mov    $0x0,%esi
  800cef:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d00:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d15:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 cb                	mov    %ecx,%ebx
  800d1f:	89 cf                	mov    %ecx,%edi
  800d21:	89 ce                	mov    %ecx,%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 0d                	push   $0xd
  800d2f:	68 3f 25 80 00       	push   $0x80253f
  800d34:	6a 23                	push   $0x23
  800d36:	68 5c 25 80 00       	push   $0x80255c
  800d3b:	e8 fa 0f 00 00       	call   801d3a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d53:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	89 cb                	mov    %ecx,%ebx
  800d5d:	89 cf                	mov    %ecx,%edi
  800d5f:	89 ce                	mov    %ecx,%esi
  800d61:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 04             	sub    $0x4,%esp
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d72:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d78:	74 11                	je     800d8b <pgfault+0x23>
  800d7a:	89 d8                	mov    %ebx,%eax
  800d7c:	c1 e8 0c             	shr    $0xc,%eax
  800d7f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d86:	f6 c4 08             	test   $0x8,%ah
  800d89:	75 14                	jne    800d9f <pgfault+0x37>
		panic("faulting access");
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	68 6a 25 80 00       	push   $0x80256a
  800d93:	6a 1d                	push   $0x1d
  800d95:	68 7a 25 80 00       	push   $0x80257a
  800d9a:	e8 9b 0f 00 00       	call   801d3a <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	6a 07                	push   $0x7
  800da4:	68 00 f0 7f 00       	push   $0x7ff000
  800da9:	6a 00                	push   $0x0
  800dab:	e8 a7 fd ff ff       	call   800b57 <sys_page_alloc>
	if (r < 0) {
  800db0:	83 c4 10             	add    $0x10,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	79 12                	jns    800dc9 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800db7:	50                   	push   %eax
  800db8:	68 85 25 80 00       	push   $0x802585
  800dbd:	6a 2b                	push   $0x2b
  800dbf:	68 7a 25 80 00       	push   $0x80257a
  800dc4:	e8 71 0f 00 00       	call   801d3a <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dc9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	68 00 10 00 00       	push   $0x1000
  800dd7:	53                   	push   %ebx
  800dd8:	68 00 f0 7f 00       	push   $0x7ff000
  800ddd:	e8 6c fb ff ff       	call   80094e <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800de2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800de9:	53                   	push   %ebx
  800dea:	6a 00                	push   $0x0
  800dec:	68 00 f0 7f 00       	push   $0x7ff000
  800df1:	6a 00                	push   $0x0
  800df3:	e8 a2 fd ff ff       	call   800b9a <sys_page_map>
	if (r < 0) {
  800df8:	83 c4 20             	add    $0x20,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	79 12                	jns    800e11 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800dff:	50                   	push   %eax
  800e00:	68 85 25 80 00       	push   $0x802585
  800e05:	6a 32                	push   $0x32
  800e07:	68 7a 25 80 00       	push   $0x80257a
  800e0c:	e8 29 0f 00 00       	call   801d3a <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e11:	83 ec 08             	sub    $0x8,%esp
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 bc fd ff ff       	call   800bdc <sys_page_unmap>
	if (r < 0) {
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 12                	jns    800e39 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e27:	50                   	push   %eax
  800e28:	68 85 25 80 00       	push   $0x802585
  800e2d:	6a 36                	push   $0x36
  800e2f:	68 7a 25 80 00       	push   $0x80257a
  800e34:	e8 01 0f 00 00       	call   801d3a <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3c:	c9                   	leave  
  800e3d:	c3                   	ret    

00800e3e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e47:	68 68 0d 80 00       	push   $0x800d68
  800e4c:	e8 2f 0f 00 00       	call   801d80 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e51:	b8 07 00 00 00       	mov    $0x7,%eax
  800e56:	cd 30                	int    $0x30
  800e58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e5b:	83 c4 10             	add    $0x10,%esp
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	79 17                	jns    800e79 <fork+0x3b>
		panic("fork fault %e");
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	68 9e 25 80 00       	push   $0x80259e
  800e6a:	68 83 00 00 00       	push   $0x83
  800e6f:	68 7a 25 80 00       	push   $0x80257a
  800e74:	e8 c1 0e 00 00       	call   801d3a <_panic>
  800e79:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e7f:	75 25                	jne    800ea6 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e81:	e8 93 fc ff ff       	call   800b19 <sys_getenvid>
  800e86:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e8b:	89 c2                	mov    %eax,%edx
  800e8d:	c1 e2 07             	shl    $0x7,%edx
  800e90:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800e97:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800e9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea1:	e9 61 01 00 00       	jmp    801007 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ea6:	83 ec 04             	sub    $0x4,%esp
  800ea9:	6a 07                	push   $0x7
  800eab:	68 00 f0 bf ee       	push   $0xeebff000
  800eb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eb3:	e8 9f fc ff ff       	call   800b57 <sys_page_alloc>
  800eb8:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ec0:	89 d8                	mov    %ebx,%eax
  800ec2:	c1 e8 16             	shr    $0x16,%eax
  800ec5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ecc:	a8 01                	test   $0x1,%al
  800ece:	0f 84 fc 00 00 00    	je     800fd0 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800ed4:	89 d8                	mov    %ebx,%eax
  800ed6:	c1 e8 0c             	shr    $0xc,%eax
  800ed9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee0:	f6 c2 01             	test   $0x1,%dl
  800ee3:	0f 84 e7 00 00 00    	je     800fd0 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800ee9:	89 c6                	mov    %eax,%esi
  800eeb:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800eee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef5:	f6 c6 04             	test   $0x4,%dh
  800ef8:	74 39                	je     800f33 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800efa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	25 07 0e 00 00       	and    $0xe07,%eax
  800f09:	50                   	push   %eax
  800f0a:	56                   	push   %esi
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 86 fc ff ff       	call   800b9a <sys_page_map>
		if (r < 0) {
  800f14:	83 c4 20             	add    $0x20,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	0f 89 b1 00 00 00    	jns    800fd0 <fork+0x192>
		    	panic("sys page map fault %e");
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	68 ac 25 80 00       	push   $0x8025ac
  800f27:	6a 53                	push   $0x53
  800f29:	68 7a 25 80 00       	push   $0x80257a
  800f2e:	e8 07 0e 00 00       	call   801d3a <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f33:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3a:	f6 c2 02             	test   $0x2,%dl
  800f3d:	75 0c                	jne    800f4b <fork+0x10d>
  800f3f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f46:	f6 c4 08             	test   $0x8,%ah
  800f49:	74 5b                	je     800fa6 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	68 05 08 00 00       	push   $0x805
  800f53:	56                   	push   %esi
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	6a 00                	push   $0x0
  800f58:	e8 3d fc ff ff       	call   800b9a <sys_page_map>
		if (r < 0) {
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	79 14                	jns    800f78 <fork+0x13a>
		    	panic("sys page map fault %e");
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 ac 25 80 00       	push   $0x8025ac
  800f6c:	6a 5a                	push   $0x5a
  800f6e:	68 7a 25 80 00       	push   $0x80257a
  800f73:	e8 c2 0d 00 00       	call   801d3a <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	68 05 08 00 00       	push   $0x805
  800f80:	56                   	push   %esi
  800f81:	6a 00                	push   $0x0
  800f83:	56                   	push   %esi
  800f84:	6a 00                	push   $0x0
  800f86:	e8 0f fc ff ff       	call   800b9a <sys_page_map>
		if (r < 0) {
  800f8b:	83 c4 20             	add    $0x20,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	79 3e                	jns    800fd0 <fork+0x192>
		    	panic("sys page map fault %e");
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	68 ac 25 80 00       	push   $0x8025ac
  800f9a:	6a 5e                	push   $0x5e
  800f9c:	68 7a 25 80 00       	push   $0x80257a
  800fa1:	e8 94 0d 00 00       	call   801d3a <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fa6:	83 ec 0c             	sub    $0xc,%esp
  800fa9:	6a 05                	push   $0x5
  800fab:	56                   	push   %esi
  800fac:	57                   	push   %edi
  800fad:	56                   	push   %esi
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 e5 fb ff ff       	call   800b9a <sys_page_map>
		if (r < 0) {
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 14                	jns    800fd0 <fork+0x192>
		    	panic("sys page map fault %e");
  800fbc:	83 ec 04             	sub    $0x4,%esp
  800fbf:	68 ac 25 80 00       	push   $0x8025ac
  800fc4:	6a 63                	push   $0x63
  800fc6:	68 7a 25 80 00       	push   $0x80257a
  800fcb:	e8 6a 0d 00 00       	call   801d3a <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fd0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fdc:	0f 85 de fe ff ff    	jne    800ec0 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fe2:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe7:	8b 40 6c             	mov    0x6c(%eax),%eax
  800fea:	83 ec 08             	sub    $0x8,%esp
  800fed:	50                   	push   %eax
  800fee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ff1:	57                   	push   %edi
  800ff2:	e8 ab fc ff ff       	call   800ca2 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800ff7:	83 c4 08             	add    $0x8,%esp
  800ffa:	6a 02                	push   $0x2
  800ffc:	57                   	push   %edi
  800ffd:	e8 1c fc ff ff       	call   800c1e <sys_env_set_status>
	
	return envid;
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100a:	5b                   	pop    %ebx
  80100b:	5e                   	pop    %esi
  80100c:	5f                   	pop    %edi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    

0080100f <sfork>:

envid_t
sfork(void)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801012:	b8 00 00 00 00       	mov    $0x0,%eax
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	56                   	push   %esi
  80101d:	53                   	push   %ebx
  80101e:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  801021:	83 ec 08             	sub    $0x8,%esp
  801024:	53                   	push   %ebx
  801025:	68 c4 25 80 00       	push   $0x8025c4
  80102a:	e8 a0 f1 ff ff       	call   8001cf <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  80102f:	89 1c 24             	mov    %ebx,(%esp)
  801032:	e8 11 fd ff ff       	call   800d48 <sys_thread_create>
  801037:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	53                   	push   %ebx
  80103d:	68 c4 25 80 00       	push   $0x8025c4
  801042:	e8 88 f1 ff ff       	call   8001cf <cprintf>
	return id;
}
  801047:	89 f0                	mov    %esi,%eax
  801049:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	05 00 00 00 30       	add    $0x30000000,%eax
  80105b:	c1 e8 0c             	shr    $0xc,%eax
}
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
  80106b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801070:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801082:	89 c2                	mov    %eax,%edx
  801084:	c1 ea 16             	shr    $0x16,%edx
  801087:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108e:	f6 c2 01             	test   $0x1,%dl
  801091:	74 11                	je     8010a4 <fd_alloc+0x2d>
  801093:	89 c2                	mov    %eax,%edx
  801095:	c1 ea 0c             	shr    $0xc,%edx
  801098:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109f:	f6 c2 01             	test   $0x1,%dl
  8010a2:	75 09                	jne    8010ad <fd_alloc+0x36>
			*fd_store = fd;
  8010a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ab:	eb 17                	jmp    8010c4 <fd_alloc+0x4d>
  8010ad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b7:	75 c9                	jne    801082 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010b9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010bf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010cc:	83 f8 1f             	cmp    $0x1f,%eax
  8010cf:	77 36                	ja     801107 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d1:	c1 e0 0c             	shl    $0xc,%eax
  8010d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010d9:	89 c2                	mov    %eax,%edx
  8010db:	c1 ea 16             	shr    $0x16,%edx
  8010de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e5:	f6 c2 01             	test   $0x1,%dl
  8010e8:	74 24                	je     80110e <fd_lookup+0x48>
  8010ea:	89 c2                	mov    %eax,%edx
  8010ec:	c1 ea 0c             	shr    $0xc,%edx
  8010ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f6:	f6 c2 01             	test   $0x1,%dl
  8010f9:	74 1a                	je     801115 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801100:	b8 00 00 00 00       	mov    $0x0,%eax
  801105:	eb 13                	jmp    80111a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801107:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110c:	eb 0c                	jmp    80111a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80110e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801113:	eb 05                	jmp    80111a <fd_lookup+0x54>
  801115:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 08             	sub    $0x8,%esp
  801122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801125:	ba 64 26 80 00       	mov    $0x802664,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80112a:	eb 13                	jmp    80113f <dev_lookup+0x23>
  80112c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80112f:	39 08                	cmp    %ecx,(%eax)
  801131:	75 0c                	jne    80113f <dev_lookup+0x23>
			*dev = devtab[i];
  801133:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801136:	89 01                	mov    %eax,(%ecx)
			return 0;
  801138:	b8 00 00 00 00       	mov    $0x0,%eax
  80113d:	eb 2e                	jmp    80116d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80113f:	8b 02                	mov    (%edx),%eax
  801141:	85 c0                	test   %eax,%eax
  801143:	75 e7                	jne    80112c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801145:	a1 04 40 80 00       	mov    0x804004,%eax
  80114a:	8b 40 50             	mov    0x50(%eax),%eax
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	51                   	push   %ecx
  801151:	50                   	push   %eax
  801152:	68 e8 25 80 00       	push   $0x8025e8
  801157:	e8 73 f0 ff ff       	call   8001cf <cprintf>
	*dev = 0;
  80115c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 10             	sub    $0x10,%esp
  801177:	8b 75 08             	mov    0x8(%ebp),%esi
  80117a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801187:	c1 e8 0c             	shr    $0xc,%eax
  80118a:	50                   	push   %eax
  80118b:	e8 36 ff ff ff       	call   8010c6 <fd_lookup>
  801190:	83 c4 08             	add    $0x8,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	78 05                	js     80119c <fd_close+0x2d>
	    || fd != fd2)
  801197:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80119a:	74 0c                	je     8011a8 <fd_close+0x39>
		return (must_exist ? r : 0);
  80119c:	84 db                	test   %bl,%bl
  80119e:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a3:	0f 44 c2             	cmove  %edx,%eax
  8011a6:	eb 41                	jmp    8011e9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ae:	50                   	push   %eax
  8011af:	ff 36                	pushl  (%esi)
  8011b1:	e8 66 ff ff ff       	call   80111c <dev_lookup>
  8011b6:	89 c3                	mov    %eax,%ebx
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 1a                	js     8011d9 <fd_close+0x6a>
		if (dev->dev_close)
  8011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	74 0b                	je     8011d9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	56                   	push   %esi
  8011d2:	ff d0                	call   *%eax
  8011d4:	89 c3                	mov    %eax,%ebx
  8011d6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	56                   	push   %esi
  8011dd:	6a 00                	push   $0x0
  8011df:	e8 f8 f9 ff ff       	call   800bdc <sys_page_unmap>
	return r;
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	89 d8                	mov    %ebx,%eax
}
  8011e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	ff 75 08             	pushl  0x8(%ebp)
  8011fd:	e8 c4 fe ff ff       	call   8010c6 <fd_lookup>
  801202:	83 c4 08             	add    $0x8,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	78 10                	js     801219 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801209:	83 ec 08             	sub    $0x8,%esp
  80120c:	6a 01                	push   $0x1
  80120e:	ff 75 f4             	pushl  -0xc(%ebp)
  801211:	e8 59 ff ff ff       	call   80116f <fd_close>
  801216:	83 c4 10             	add    $0x10,%esp
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <close_all>:

void
close_all(void)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	53                   	push   %ebx
  80121f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801222:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801227:	83 ec 0c             	sub    $0xc,%esp
  80122a:	53                   	push   %ebx
  80122b:	e8 c0 ff ff ff       	call   8011f0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801230:	83 c3 01             	add    $0x1,%ebx
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	83 fb 20             	cmp    $0x20,%ebx
  801239:	75 ec                	jne    801227 <close_all+0xc>
		close(i);
}
  80123b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123e:	c9                   	leave  
  80123f:	c3                   	ret    

00801240 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 2c             	sub    $0x2c,%esp
  801249:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80124c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	ff 75 08             	pushl  0x8(%ebp)
  801253:	e8 6e fe ff ff       	call   8010c6 <fd_lookup>
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	0f 88 c1 00 00 00    	js     801324 <dup+0xe4>
		return r;
	close(newfdnum);
  801263:	83 ec 0c             	sub    $0xc,%esp
  801266:	56                   	push   %esi
  801267:	e8 84 ff ff ff       	call   8011f0 <close>

	newfd = INDEX2FD(newfdnum);
  80126c:	89 f3                	mov    %esi,%ebx
  80126e:	c1 e3 0c             	shl    $0xc,%ebx
  801271:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801277:	83 c4 04             	add    $0x4,%esp
  80127a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80127d:	e8 de fd ff ff       	call   801060 <fd2data>
  801282:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801284:	89 1c 24             	mov    %ebx,(%esp)
  801287:	e8 d4 fd ff ff       	call   801060 <fd2data>
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801292:	89 f8                	mov    %edi,%eax
  801294:	c1 e8 16             	shr    $0x16,%eax
  801297:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80129e:	a8 01                	test   $0x1,%al
  8012a0:	74 37                	je     8012d9 <dup+0x99>
  8012a2:	89 f8                	mov    %edi,%eax
  8012a4:	c1 e8 0c             	shr    $0xc,%eax
  8012a7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ae:	f6 c2 01             	test   $0x1,%dl
  8012b1:	74 26                	je     8012d9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ba:	83 ec 0c             	sub    $0xc,%esp
  8012bd:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c2:	50                   	push   %eax
  8012c3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012c6:	6a 00                	push   $0x0
  8012c8:	57                   	push   %edi
  8012c9:	6a 00                	push   $0x0
  8012cb:	e8 ca f8 ff ff       	call   800b9a <sys_page_map>
  8012d0:	89 c7                	mov    %eax,%edi
  8012d2:	83 c4 20             	add    $0x20,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 2e                	js     801307 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012dc:	89 d0                	mov    %edx,%eax
  8012de:	c1 e8 0c             	shr    $0xc,%eax
  8012e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e8:	83 ec 0c             	sub    $0xc,%esp
  8012eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f0:	50                   	push   %eax
  8012f1:	53                   	push   %ebx
  8012f2:	6a 00                	push   $0x0
  8012f4:	52                   	push   %edx
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 9e f8 ff ff       	call   800b9a <sys_page_map>
  8012fc:	89 c7                	mov    %eax,%edi
  8012fe:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801301:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801303:	85 ff                	test   %edi,%edi
  801305:	79 1d                	jns    801324 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	53                   	push   %ebx
  80130b:	6a 00                	push   $0x0
  80130d:	e8 ca f8 ff ff       	call   800bdc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	ff 75 d4             	pushl  -0x2c(%ebp)
  801318:	6a 00                	push   $0x0
  80131a:	e8 bd f8 ff ff       	call   800bdc <sys_page_unmap>
	return r;
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	89 f8                	mov    %edi,%eax
}
  801324:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801327:	5b                   	pop    %ebx
  801328:	5e                   	pop    %esi
  801329:	5f                   	pop    %edi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	53                   	push   %ebx
  801330:	83 ec 14             	sub    $0x14,%esp
  801333:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801336:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	53                   	push   %ebx
  80133b:	e8 86 fd ff ff       	call   8010c6 <fd_lookup>
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	89 c2                	mov    %eax,%edx
  801345:	85 c0                	test   %eax,%eax
  801347:	78 6d                	js     8013b6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	ff 30                	pushl  (%eax)
  801355:	e8 c2 fd ff ff       	call   80111c <dev_lookup>
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 4c                	js     8013ad <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801361:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801364:	8b 42 08             	mov    0x8(%edx),%eax
  801367:	83 e0 03             	and    $0x3,%eax
  80136a:	83 f8 01             	cmp    $0x1,%eax
  80136d:	75 21                	jne    801390 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80136f:	a1 04 40 80 00       	mov    0x804004,%eax
  801374:	8b 40 50             	mov    0x50(%eax),%eax
  801377:	83 ec 04             	sub    $0x4,%esp
  80137a:	53                   	push   %ebx
  80137b:	50                   	push   %eax
  80137c:	68 29 26 80 00       	push   $0x802629
  801381:	e8 49 ee ff ff       	call   8001cf <cprintf>
		return -E_INVAL;
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80138e:	eb 26                	jmp    8013b6 <read+0x8a>
	}
	if (!dev->dev_read)
  801390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801393:	8b 40 08             	mov    0x8(%eax),%eax
  801396:	85 c0                	test   %eax,%eax
  801398:	74 17                	je     8013b1 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80139a:	83 ec 04             	sub    $0x4,%esp
  80139d:	ff 75 10             	pushl  0x10(%ebp)
  8013a0:	ff 75 0c             	pushl  0xc(%ebp)
  8013a3:	52                   	push   %edx
  8013a4:	ff d0                	call   *%eax
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	eb 09                	jmp    8013b6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ad:	89 c2                	mov    %eax,%edx
  8013af:	eb 05                	jmp    8013b6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013b6:	89 d0                	mov    %edx,%eax
  8013b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	57                   	push   %edi
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d1:	eb 21                	jmp    8013f4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d3:	83 ec 04             	sub    $0x4,%esp
  8013d6:	89 f0                	mov    %esi,%eax
  8013d8:	29 d8                	sub    %ebx,%eax
  8013da:	50                   	push   %eax
  8013db:	89 d8                	mov    %ebx,%eax
  8013dd:	03 45 0c             	add    0xc(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	57                   	push   %edi
  8013e2:	e8 45 ff ff ff       	call   80132c <read>
		if (m < 0)
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 10                	js     8013fe <readn+0x41>
			return m;
		if (m == 0)
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	74 0a                	je     8013fc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f2:	01 c3                	add    %eax,%ebx
  8013f4:	39 f3                	cmp    %esi,%ebx
  8013f6:	72 db                	jb     8013d3 <readn+0x16>
  8013f8:	89 d8                	mov    %ebx,%eax
  8013fa:	eb 02                	jmp    8013fe <readn+0x41>
  8013fc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801401:	5b                   	pop    %ebx
  801402:	5e                   	pop    %esi
  801403:	5f                   	pop    %edi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	53                   	push   %ebx
  80140a:	83 ec 14             	sub    $0x14,%esp
  80140d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801410:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	53                   	push   %ebx
  801415:	e8 ac fc ff ff       	call   8010c6 <fd_lookup>
  80141a:	83 c4 08             	add    $0x8,%esp
  80141d:	89 c2                	mov    %eax,%edx
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 68                	js     80148b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801429:	50                   	push   %eax
  80142a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142d:	ff 30                	pushl  (%eax)
  80142f:	e8 e8 fc ff ff       	call   80111c <dev_lookup>
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	78 47                	js     801482 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801442:	75 21                	jne    801465 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801444:	a1 04 40 80 00       	mov    0x804004,%eax
  801449:	8b 40 50             	mov    0x50(%eax),%eax
  80144c:	83 ec 04             	sub    $0x4,%esp
  80144f:	53                   	push   %ebx
  801450:	50                   	push   %eax
  801451:	68 45 26 80 00       	push   $0x802645
  801456:	e8 74 ed ff ff       	call   8001cf <cprintf>
		return -E_INVAL;
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801463:	eb 26                	jmp    80148b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801465:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801468:	8b 52 0c             	mov    0xc(%edx),%edx
  80146b:	85 d2                	test   %edx,%edx
  80146d:	74 17                	je     801486 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80146f:	83 ec 04             	sub    $0x4,%esp
  801472:	ff 75 10             	pushl  0x10(%ebp)
  801475:	ff 75 0c             	pushl  0xc(%ebp)
  801478:	50                   	push   %eax
  801479:	ff d2                	call   *%edx
  80147b:	89 c2                	mov    %eax,%edx
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	eb 09                	jmp    80148b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801482:	89 c2                	mov    %eax,%edx
  801484:	eb 05                	jmp    80148b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801486:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80148b:	89 d0                	mov    %edx,%eax
  80148d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801490:	c9                   	leave  
  801491:	c3                   	ret    

00801492 <seek>:

int
seek(int fdnum, off_t offset)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801498:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	ff 75 08             	pushl  0x8(%ebp)
  80149f:	e8 22 fc ff ff       	call   8010c6 <fd_lookup>
  8014a4:	83 c4 08             	add    $0x8,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 0e                	js     8014b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 14             	sub    $0x14,%esp
  8014c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c8:	50                   	push   %eax
  8014c9:	53                   	push   %ebx
  8014ca:	e8 f7 fb ff ff       	call   8010c6 <fd_lookup>
  8014cf:	83 c4 08             	add    $0x8,%esp
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 65                	js     80153d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014de:	50                   	push   %eax
  8014df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e2:	ff 30                	pushl  (%eax)
  8014e4:	e8 33 fc ff ff       	call   80111c <dev_lookup>
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 44                	js     801534 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f7:	75 21                	jne    80151a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014f9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014fe:	8b 40 50             	mov    0x50(%eax),%eax
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	53                   	push   %ebx
  801505:	50                   	push   %eax
  801506:	68 08 26 80 00       	push   $0x802608
  80150b:	e8 bf ec ff ff       	call   8001cf <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801518:	eb 23                	jmp    80153d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151d:	8b 52 18             	mov    0x18(%edx),%edx
  801520:	85 d2                	test   %edx,%edx
  801522:	74 14                	je     801538 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	ff 75 0c             	pushl  0xc(%ebp)
  80152a:	50                   	push   %eax
  80152b:	ff d2                	call   *%edx
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	eb 09                	jmp    80153d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801534:	89 c2                	mov    %eax,%edx
  801536:	eb 05                	jmp    80153d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801538:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80153d:	89 d0                	mov    %edx,%eax
  80153f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	53                   	push   %ebx
  801548:	83 ec 14             	sub    $0x14,%esp
  80154b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801551:	50                   	push   %eax
  801552:	ff 75 08             	pushl  0x8(%ebp)
  801555:	e8 6c fb ff ff       	call   8010c6 <fd_lookup>
  80155a:	83 c4 08             	add    $0x8,%esp
  80155d:	89 c2                	mov    %eax,%edx
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 58                	js     8015bb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156d:	ff 30                	pushl  (%eax)
  80156f:	e8 a8 fb ff ff       	call   80111c <dev_lookup>
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 37                	js     8015b2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80157b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801582:	74 32                	je     8015b6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801584:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801587:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80158e:	00 00 00 
	stat->st_isdir = 0;
  801591:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801598:	00 00 00 
	stat->st_dev = dev;
  80159b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a8:	ff 50 14             	call   *0x14(%eax)
  8015ab:	89 c2                	mov    %eax,%edx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	eb 09                	jmp    8015bb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b2:	89 c2                	mov    %eax,%edx
  8015b4:	eb 05                	jmp    8015bb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015bb:	89 d0                	mov    %edx,%eax
  8015bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	56                   	push   %esi
  8015c6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	6a 00                	push   $0x0
  8015cc:	ff 75 08             	pushl  0x8(%ebp)
  8015cf:	e8 e3 01 00 00       	call   8017b7 <open>
  8015d4:	89 c3                	mov    %eax,%ebx
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 1b                	js     8015f8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	ff 75 0c             	pushl  0xc(%ebp)
  8015e3:	50                   	push   %eax
  8015e4:	e8 5b ff ff ff       	call   801544 <fstat>
  8015e9:	89 c6                	mov    %eax,%esi
	close(fd);
  8015eb:	89 1c 24             	mov    %ebx,(%esp)
  8015ee:	e8 fd fb ff ff       	call   8011f0 <close>
	return r;
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	89 f0                	mov    %esi,%eax
}
  8015f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fb:	5b                   	pop    %ebx
  8015fc:	5e                   	pop    %esi
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	56                   	push   %esi
  801603:	53                   	push   %ebx
  801604:	89 c6                	mov    %eax,%esi
  801606:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801608:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80160f:	75 12                	jne    801623 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	6a 01                	push   $0x1
  801616:	e8 cb 08 00 00       	call   801ee6 <ipc_find_env>
  80161b:	a3 00 40 80 00       	mov    %eax,0x804000
  801620:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801623:	6a 07                	push   $0x7
  801625:	68 00 50 80 00       	push   $0x805000
  80162a:	56                   	push   %esi
  80162b:	ff 35 00 40 80 00    	pushl  0x804000
  801631:	e8 4e 08 00 00       	call   801e84 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801636:	83 c4 0c             	add    $0xc,%esp
  801639:	6a 00                	push   $0x0
  80163b:	53                   	push   %ebx
  80163c:	6a 00                	push   $0x0
  80163e:	e8 cc 07 00 00       	call   801e0f <ipc_recv>
}
  801643:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801646:	5b                   	pop    %ebx
  801647:	5e                   	pop    %esi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801650:	8b 45 08             	mov    0x8(%ebp),%eax
  801653:	8b 40 0c             	mov    0xc(%eax),%eax
  801656:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80165b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801663:	ba 00 00 00 00       	mov    $0x0,%edx
  801668:	b8 02 00 00 00       	mov    $0x2,%eax
  80166d:	e8 8d ff ff ff       	call   8015ff <fsipc>
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80167a:	8b 45 08             	mov    0x8(%ebp),%eax
  80167d:	8b 40 0c             	mov    0xc(%eax),%eax
  801680:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801685:	ba 00 00 00 00       	mov    $0x0,%edx
  80168a:	b8 06 00 00 00       	mov    $0x6,%eax
  80168f:	e8 6b ff ff ff       	call   8015ff <fsipc>
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b5:	e8 45 ff ff ff       	call   8015ff <fsipc>
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 2c                	js     8016ea <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	68 00 50 80 00       	push   $0x805000
  8016c6:	53                   	push   %ebx
  8016c7:	e8 88 f0 ff ff       	call   800754 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016cc:	a1 80 50 80 00       	mov    0x805080,%eax
  8016d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d7:	a1 84 50 80 00       	mov    0x805084,%eax
  8016dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	83 ec 0c             	sub    $0xc,%esp
  8016f5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016fb:	8b 52 0c             	mov    0xc(%edx),%edx
  8016fe:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801704:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801709:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80170e:	0f 47 c2             	cmova  %edx,%eax
  801711:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801716:	50                   	push   %eax
  801717:	ff 75 0c             	pushl  0xc(%ebp)
  80171a:	68 08 50 80 00       	push   $0x805008
  80171f:	e8 c2 f1 ff ff       	call   8008e6 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801724:	ba 00 00 00 00       	mov    $0x0,%edx
  801729:	b8 04 00 00 00       	mov    $0x4,%eax
  80172e:	e8 cc fe ff ff       	call   8015ff <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	8b 40 0c             	mov    0xc(%eax),%eax
  801743:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801748:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80174e:	ba 00 00 00 00       	mov    $0x0,%edx
  801753:	b8 03 00 00 00       	mov    $0x3,%eax
  801758:	e8 a2 fe ff ff       	call   8015ff <fsipc>
  80175d:	89 c3                	mov    %eax,%ebx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 4b                	js     8017ae <devfile_read+0x79>
		return r;
	assert(r <= n);
  801763:	39 c6                	cmp    %eax,%esi
  801765:	73 16                	jae    80177d <devfile_read+0x48>
  801767:	68 74 26 80 00       	push   $0x802674
  80176c:	68 7b 26 80 00       	push   $0x80267b
  801771:	6a 7c                	push   $0x7c
  801773:	68 90 26 80 00       	push   $0x802690
  801778:	e8 bd 05 00 00       	call   801d3a <_panic>
	assert(r <= PGSIZE);
  80177d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801782:	7e 16                	jle    80179a <devfile_read+0x65>
  801784:	68 9b 26 80 00       	push   $0x80269b
  801789:	68 7b 26 80 00       	push   $0x80267b
  80178e:	6a 7d                	push   $0x7d
  801790:	68 90 26 80 00       	push   $0x802690
  801795:	e8 a0 05 00 00       	call   801d3a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	50                   	push   %eax
  80179e:	68 00 50 80 00       	push   $0x805000
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	e8 3b f1 ff ff       	call   8008e6 <memmove>
	return r;
  8017ab:	83 c4 10             	add    $0x10,%esp
}
  8017ae:	89 d8                	mov    %ebx,%eax
  8017b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 20             	sub    $0x20,%esp
  8017be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017c1:	53                   	push   %ebx
  8017c2:	e8 54 ef ff ff       	call   80071b <strlen>
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017cf:	7f 67                	jg     801838 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d7:	50                   	push   %eax
  8017d8:	e8 9a f8 ff ff       	call   801077 <fd_alloc>
  8017dd:	83 c4 10             	add    $0x10,%esp
		return r;
  8017e0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 57                	js     80183d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017e6:	83 ec 08             	sub    $0x8,%esp
  8017e9:	53                   	push   %ebx
  8017ea:	68 00 50 80 00       	push   $0x805000
  8017ef:	e8 60 ef ff ff       	call   800754 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801804:	e8 f6 fd ff ff       	call   8015ff <fsipc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	79 14                	jns    801826 <open+0x6f>
		fd_close(fd, 0);
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	6a 00                	push   $0x0
  801817:	ff 75 f4             	pushl  -0xc(%ebp)
  80181a:	e8 50 f9 ff ff       	call   80116f <fd_close>
		return r;
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	89 da                	mov    %ebx,%edx
  801824:	eb 17                	jmp    80183d <open+0x86>
	}

	return fd2num(fd);
  801826:	83 ec 0c             	sub    $0xc,%esp
  801829:	ff 75 f4             	pushl  -0xc(%ebp)
  80182c:	e8 1f f8 ff ff       	call   801050 <fd2num>
  801831:	89 c2                	mov    %eax,%edx
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	eb 05                	jmp    80183d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801838:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80183d:	89 d0                	mov    %edx,%eax
  80183f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801842:	c9                   	leave  
  801843:	c3                   	ret    

00801844 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80184a:	ba 00 00 00 00       	mov    $0x0,%edx
  80184f:	b8 08 00 00 00       	mov    $0x8,%eax
  801854:	e8 a6 fd ff ff       	call   8015ff <fsipc>
}
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	56                   	push   %esi
  80185f:	53                   	push   %ebx
  801860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801863:	83 ec 0c             	sub    $0xc,%esp
  801866:	ff 75 08             	pushl  0x8(%ebp)
  801869:	e8 f2 f7 ff ff       	call   801060 <fd2data>
  80186e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801870:	83 c4 08             	add    $0x8,%esp
  801873:	68 a7 26 80 00       	push   $0x8026a7
  801878:	53                   	push   %ebx
  801879:	e8 d6 ee ff ff       	call   800754 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80187e:	8b 46 04             	mov    0x4(%esi),%eax
  801881:	2b 06                	sub    (%esi),%eax
  801883:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801889:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801890:	00 00 00 
	stat->st_dev = &devpipe;
  801893:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80189a:	30 80 00 
	return 0;
}
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 0c             	sub    $0xc,%esp
  8018b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018b3:	53                   	push   %ebx
  8018b4:	6a 00                	push   $0x0
  8018b6:	e8 21 f3 ff ff       	call   800bdc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018bb:	89 1c 24             	mov    %ebx,(%esp)
  8018be:	e8 9d f7 ff ff       	call   801060 <fd2data>
  8018c3:	83 c4 08             	add    $0x8,%esp
  8018c6:	50                   	push   %eax
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 0e f3 ff ff       	call   800bdc <sys_page_unmap>
}
  8018ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	57                   	push   %edi
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	83 ec 1c             	sub    $0x1c,%esp
  8018dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018df:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e6:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018e9:	83 ec 0c             	sub    $0xc,%esp
  8018ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ef:	e8 32 06 00 00       	call   801f26 <pageref>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	89 3c 24             	mov    %edi,(%esp)
  8018f9:	e8 28 06 00 00       	call   801f26 <pageref>
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	39 c3                	cmp    %eax,%ebx
  801903:	0f 94 c1             	sete   %cl
  801906:	0f b6 c9             	movzbl %cl,%ecx
  801909:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80190c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801912:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801915:	39 ce                	cmp    %ecx,%esi
  801917:	74 1b                	je     801934 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801919:	39 c3                	cmp    %eax,%ebx
  80191b:	75 c4                	jne    8018e1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80191d:	8b 42 60             	mov    0x60(%edx),%eax
  801920:	ff 75 e4             	pushl  -0x1c(%ebp)
  801923:	50                   	push   %eax
  801924:	56                   	push   %esi
  801925:	68 ae 26 80 00       	push   $0x8026ae
  80192a:	e8 a0 e8 ff ff       	call   8001cf <cprintf>
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	eb ad                	jmp    8018e1 <_pipeisclosed+0xe>
	}
}
  801934:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801937:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5f                   	pop    %edi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	57                   	push   %edi
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	83 ec 28             	sub    $0x28,%esp
  801948:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80194b:	56                   	push   %esi
  80194c:	e8 0f f7 ff ff       	call   801060 <fd2data>
  801951:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	bf 00 00 00 00       	mov    $0x0,%edi
  80195b:	eb 4b                	jmp    8019a8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80195d:	89 da                	mov    %ebx,%edx
  80195f:	89 f0                	mov    %esi,%eax
  801961:	e8 6d ff ff ff       	call   8018d3 <_pipeisclosed>
  801966:	85 c0                	test   %eax,%eax
  801968:	75 48                	jne    8019b2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80196a:	e8 c9 f1 ff ff       	call   800b38 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80196f:	8b 43 04             	mov    0x4(%ebx),%eax
  801972:	8b 0b                	mov    (%ebx),%ecx
  801974:	8d 51 20             	lea    0x20(%ecx),%edx
  801977:	39 d0                	cmp    %edx,%eax
  801979:	73 e2                	jae    80195d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80197b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801982:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801985:	89 c2                	mov    %eax,%edx
  801987:	c1 fa 1f             	sar    $0x1f,%edx
  80198a:	89 d1                	mov    %edx,%ecx
  80198c:	c1 e9 1b             	shr    $0x1b,%ecx
  80198f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801992:	83 e2 1f             	and    $0x1f,%edx
  801995:	29 ca                	sub    %ecx,%edx
  801997:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80199b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80199f:	83 c0 01             	add    $0x1,%eax
  8019a2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a5:	83 c7 01             	add    $0x1,%edi
  8019a8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019ab:	75 c2                	jne    80196f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b0:	eb 05                	jmp    8019b7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5f                   	pop    %edi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    

008019bf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	57                   	push   %edi
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 18             	sub    $0x18,%esp
  8019c8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019cb:	57                   	push   %edi
  8019cc:	e8 8f f6 ff ff       	call   801060 <fd2data>
  8019d1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019db:	eb 3d                	jmp    801a1a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019dd:	85 db                	test   %ebx,%ebx
  8019df:	74 04                	je     8019e5 <devpipe_read+0x26>
				return i;
  8019e1:	89 d8                	mov    %ebx,%eax
  8019e3:	eb 44                	jmp    801a29 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019e5:	89 f2                	mov    %esi,%edx
  8019e7:	89 f8                	mov    %edi,%eax
  8019e9:	e8 e5 fe ff ff       	call   8018d3 <_pipeisclosed>
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	75 32                	jne    801a24 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019f2:	e8 41 f1 ff ff       	call   800b38 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019f7:	8b 06                	mov    (%esi),%eax
  8019f9:	3b 46 04             	cmp    0x4(%esi),%eax
  8019fc:	74 df                	je     8019dd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019fe:	99                   	cltd   
  8019ff:	c1 ea 1b             	shr    $0x1b,%edx
  801a02:	01 d0                	add    %edx,%eax
  801a04:	83 e0 1f             	and    $0x1f,%eax
  801a07:	29 d0                	sub    %edx,%eax
  801a09:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a11:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a14:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a17:	83 c3 01             	add    $0x1,%ebx
  801a1a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a1d:	75 d8                	jne    8019f7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801a22:	eb 05                	jmp    801a29 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a24:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5f                   	pop    %edi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3c:	50                   	push   %eax
  801a3d:	e8 35 f6 ff ff       	call   801077 <fd_alloc>
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	89 c2                	mov    %eax,%edx
  801a47:	85 c0                	test   %eax,%eax
  801a49:	0f 88 2c 01 00 00    	js     801b7b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4f:	83 ec 04             	sub    $0x4,%esp
  801a52:	68 07 04 00 00       	push   $0x407
  801a57:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5a:	6a 00                	push   $0x0
  801a5c:	e8 f6 f0 ff ff       	call   800b57 <sys_page_alloc>
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	89 c2                	mov    %eax,%edx
  801a66:	85 c0                	test   %eax,%eax
  801a68:	0f 88 0d 01 00 00    	js     801b7b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a74:	50                   	push   %eax
  801a75:	e8 fd f5 ff ff       	call   801077 <fd_alloc>
  801a7a:	89 c3                	mov    %eax,%ebx
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	0f 88 e2 00 00 00    	js     801b69 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a87:	83 ec 04             	sub    $0x4,%esp
  801a8a:	68 07 04 00 00       	push   $0x407
  801a8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a92:	6a 00                	push   $0x0
  801a94:	e8 be f0 ff ff       	call   800b57 <sys_page_alloc>
  801a99:	89 c3                	mov    %eax,%ebx
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	0f 88 c3 00 00 00    	js     801b69 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	ff 75 f4             	pushl  -0xc(%ebp)
  801aac:	e8 af f5 ff ff       	call   801060 <fd2data>
  801ab1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab3:	83 c4 0c             	add    $0xc,%esp
  801ab6:	68 07 04 00 00       	push   $0x407
  801abb:	50                   	push   %eax
  801abc:	6a 00                	push   $0x0
  801abe:	e8 94 f0 ff ff       	call   800b57 <sys_page_alloc>
  801ac3:	89 c3                	mov    %eax,%ebx
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	0f 88 89 00 00 00    	js     801b59 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad6:	e8 85 f5 ff ff       	call   801060 <fd2data>
  801adb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ae2:	50                   	push   %eax
  801ae3:	6a 00                	push   $0x0
  801ae5:	56                   	push   %esi
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 ad f0 ff ff       	call   800b9a <sys_page_map>
  801aed:	89 c3                	mov    %eax,%ebx
  801aef:	83 c4 20             	add    $0x20,%esp
  801af2:	85 c0                	test   %eax,%eax
  801af4:	78 55                	js     801b4b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801af6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aff:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b04:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b0b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b14:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b19:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b20:	83 ec 0c             	sub    $0xc,%esp
  801b23:	ff 75 f4             	pushl  -0xc(%ebp)
  801b26:	e8 25 f5 ff ff       	call   801050 <fd2num>
  801b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b30:	83 c4 04             	add    $0x4,%esp
  801b33:	ff 75 f0             	pushl  -0x10(%ebp)
  801b36:	e8 15 f5 ff ff       	call   801050 <fd2num>
  801b3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b3e:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	ba 00 00 00 00       	mov    $0x0,%edx
  801b49:	eb 30                	jmp    801b7b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b4b:	83 ec 08             	sub    $0x8,%esp
  801b4e:	56                   	push   %esi
  801b4f:	6a 00                	push   $0x0
  801b51:	e8 86 f0 ff ff       	call   800bdc <sys_page_unmap>
  801b56:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b59:	83 ec 08             	sub    $0x8,%esp
  801b5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5f:	6a 00                	push   $0x0
  801b61:	e8 76 f0 ff ff       	call   800bdc <sys_page_unmap>
  801b66:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b69:	83 ec 08             	sub    $0x8,%esp
  801b6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6f:	6a 00                	push   $0x0
  801b71:	e8 66 f0 ff ff       	call   800bdc <sys_page_unmap>
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b80:	5b                   	pop    %ebx
  801b81:	5e                   	pop    %esi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8d:	50                   	push   %eax
  801b8e:	ff 75 08             	pushl  0x8(%ebp)
  801b91:	e8 30 f5 ff ff       	call   8010c6 <fd_lookup>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 18                	js     801bb5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba3:	e8 b8 f4 ff ff       	call   801060 <fd2data>
	return _pipeisclosed(fd, p);
  801ba8:	89 c2                	mov    %eax,%edx
  801baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bad:	e8 21 fd ff ff       	call   8018d3 <_pipeisclosed>
  801bb2:	83 c4 10             	add    $0x10,%esp
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bba:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bc7:	68 c6 26 80 00       	push   $0x8026c6
  801bcc:	ff 75 0c             	pushl  0xc(%ebp)
  801bcf:	e8 80 eb ff ff       	call   800754 <strcpy>
	return 0;
}
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	57                   	push   %edi
  801bdf:	56                   	push   %esi
  801be0:	53                   	push   %ebx
  801be1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bec:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf2:	eb 2d                	jmp    801c21 <devcons_write+0x46>
		m = n - tot;
  801bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bf7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bf9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bfc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c01:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	53                   	push   %ebx
  801c08:	03 45 0c             	add    0xc(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	57                   	push   %edi
  801c0d:	e8 d4 ec ff ff       	call   8008e6 <memmove>
		sys_cputs(buf, m);
  801c12:	83 c4 08             	add    $0x8,%esp
  801c15:	53                   	push   %ebx
  801c16:	57                   	push   %edi
  801c17:	e8 7f ee ff ff       	call   800a9b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c1c:	01 de                	add    %ebx,%esi
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	89 f0                	mov    %esi,%eax
  801c23:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c26:	72 cc                	jb     801bf4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5f                   	pop    %edi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 08             	sub    $0x8,%esp
  801c36:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c3f:	74 2a                	je     801c6b <devcons_read+0x3b>
  801c41:	eb 05                	jmp    801c48 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c43:	e8 f0 ee ff ff       	call   800b38 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c48:	e8 6c ee ff ff       	call   800ab9 <sys_cgetc>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	74 f2                	je     801c43 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 16                	js     801c6b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c55:	83 f8 04             	cmp    $0x4,%eax
  801c58:	74 0c                	je     801c66 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5d:	88 02                	mov    %al,(%edx)
	return 1;
  801c5f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c64:	eb 05                	jmp    801c6b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c66:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c79:	6a 01                	push   $0x1
  801c7b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	e8 17 ee ff ff       	call   800a9b <sys_cputs>
}
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <getchar>:

int
getchar(void)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c8f:	6a 01                	push   $0x1
  801c91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	6a 00                	push   $0x0
  801c97:	e8 90 f6 ff ff       	call   80132c <read>
	if (r < 0)
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 0f                	js     801cb2 <getchar+0x29>
		return r;
	if (r < 1)
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	7e 06                	jle    801cad <getchar+0x24>
		return -E_EOF;
	return c;
  801ca7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cab:	eb 05                	jmp    801cb2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cad:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbd:	50                   	push   %eax
  801cbe:	ff 75 08             	pushl  0x8(%ebp)
  801cc1:	e8 00 f4 ff ff       	call   8010c6 <fd_lookup>
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 11                	js     801cde <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd6:	39 10                	cmp    %edx,(%eax)
  801cd8:	0f 94 c0             	sete   %al
  801cdb:	0f b6 c0             	movzbl %al,%eax
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <opencons>:

int
opencons(void)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce9:	50                   	push   %eax
  801cea:	e8 88 f3 ff ff       	call   801077 <fd_alloc>
  801cef:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf4:	85 c0                	test   %eax,%eax
  801cf6:	78 3e                	js     801d36 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cf8:	83 ec 04             	sub    $0x4,%esp
  801cfb:	68 07 04 00 00       	push   $0x407
  801d00:	ff 75 f4             	pushl  -0xc(%ebp)
  801d03:	6a 00                	push   $0x0
  801d05:	e8 4d ee ff ff       	call   800b57 <sys_page_alloc>
  801d0a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d0d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 23                	js     801d36 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d13:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d21:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d28:	83 ec 0c             	sub    $0xc,%esp
  801d2b:	50                   	push   %eax
  801d2c:	e8 1f f3 ff ff       	call   801050 <fd2num>
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	83 c4 10             	add    $0x10,%esp
}
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	56                   	push   %esi
  801d3e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d3f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d42:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d48:	e8 cc ed ff ff       	call   800b19 <sys_getenvid>
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	ff 75 0c             	pushl  0xc(%ebp)
  801d53:	ff 75 08             	pushl  0x8(%ebp)
  801d56:	56                   	push   %esi
  801d57:	50                   	push   %eax
  801d58:	68 d4 26 80 00       	push   $0x8026d4
  801d5d:	e8 6d e4 ff ff       	call   8001cf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d62:	83 c4 18             	add    $0x18,%esp
  801d65:	53                   	push   %ebx
  801d66:	ff 75 10             	pushl  0x10(%ebp)
  801d69:	e8 10 e4 ff ff       	call   80017e <vcprintf>
	cprintf("\n");
  801d6e:	c7 04 24 21 22 80 00 	movl   $0x802221,(%esp)
  801d75:	e8 55 e4 ff ff       	call   8001cf <cprintf>
  801d7a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d7d:	cc                   	int3   
  801d7e:	eb fd                	jmp    801d7d <_panic+0x43>

00801d80 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d86:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d8d:	75 2a                	jne    801db9 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d8f:	83 ec 04             	sub    $0x4,%esp
  801d92:	6a 07                	push   $0x7
  801d94:	68 00 f0 bf ee       	push   $0xeebff000
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 b7 ed ff ff       	call   800b57 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	85 c0                	test   %eax,%eax
  801da5:	79 12                	jns    801db9 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801da7:	50                   	push   %eax
  801da8:	68 f8 26 80 00       	push   $0x8026f8
  801dad:	6a 23                	push   $0x23
  801daf:	68 fc 26 80 00       	push   $0x8026fc
  801db4:	e8 81 ff ff ff       	call   801d3a <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dc1:	83 ec 08             	sub    $0x8,%esp
  801dc4:	68 eb 1d 80 00       	push   $0x801deb
  801dc9:	6a 00                	push   $0x0
  801dcb:	e8 d2 ee ff ff       	call   800ca2 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	79 12                	jns    801de9 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dd7:	50                   	push   %eax
  801dd8:	68 f8 26 80 00       	push   $0x8026f8
  801ddd:	6a 2c                	push   $0x2c
  801ddf:	68 fc 26 80 00       	push   $0x8026fc
  801de4:	e8 51 ff ff ff       	call   801d3a <_panic>
	}
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801deb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dec:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801df1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801df3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801df6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dfa:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dff:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e03:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e05:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e08:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e09:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e0c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e0d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e0e:	c3                   	ret    

00801e0f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	56                   	push   %esi
  801e13:	53                   	push   %ebx
  801e14:	8b 75 08             	mov    0x8(%ebp),%esi
  801e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	75 12                	jne    801e33 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e21:	83 ec 0c             	sub    $0xc,%esp
  801e24:	68 00 00 c0 ee       	push   $0xeec00000
  801e29:	e8 d9 ee ff ff       	call   800d07 <sys_ipc_recv>
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	eb 0c                	jmp    801e3f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e33:	83 ec 0c             	sub    $0xc,%esp
  801e36:	50                   	push   %eax
  801e37:	e8 cb ee ff ff       	call   800d07 <sys_ipc_recv>
  801e3c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e3f:	85 f6                	test   %esi,%esi
  801e41:	0f 95 c1             	setne  %cl
  801e44:	85 db                	test   %ebx,%ebx
  801e46:	0f 95 c2             	setne  %dl
  801e49:	84 d1                	test   %dl,%cl
  801e4b:	74 09                	je     801e56 <ipc_recv+0x47>
  801e4d:	89 c2                	mov    %eax,%edx
  801e4f:	c1 ea 1f             	shr    $0x1f,%edx
  801e52:	84 d2                	test   %dl,%dl
  801e54:	75 27                	jne    801e7d <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e56:	85 f6                	test   %esi,%esi
  801e58:	74 0a                	je     801e64 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801e5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e5f:	8b 40 7c             	mov    0x7c(%eax),%eax
  801e62:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e64:	85 db                	test   %ebx,%ebx
  801e66:	74 0d                	je     801e75 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801e68:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e73:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e75:	a1 04 40 80 00       	mov    0x804004,%eax
  801e7a:	8b 40 78             	mov    0x78(%eax),%eax
}
  801e7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5d                   	pop    %ebp
  801e83:	c3                   	ret    

00801e84 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	57                   	push   %edi
  801e88:	56                   	push   %esi
  801e89:	53                   	push   %ebx
  801e8a:	83 ec 0c             	sub    $0xc,%esp
  801e8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e90:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e96:	85 db                	test   %ebx,%ebx
  801e98:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e9d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ea0:	ff 75 14             	pushl  0x14(%ebp)
  801ea3:	53                   	push   %ebx
  801ea4:	56                   	push   %esi
  801ea5:	57                   	push   %edi
  801ea6:	e8 39 ee ff ff       	call   800ce4 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801eab:	89 c2                	mov    %eax,%edx
  801ead:	c1 ea 1f             	shr    $0x1f,%edx
  801eb0:	83 c4 10             	add    $0x10,%esp
  801eb3:	84 d2                	test   %dl,%dl
  801eb5:	74 17                	je     801ece <ipc_send+0x4a>
  801eb7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eba:	74 12                	je     801ece <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ebc:	50                   	push   %eax
  801ebd:	68 0a 27 80 00       	push   $0x80270a
  801ec2:	6a 47                	push   $0x47
  801ec4:	68 18 27 80 00       	push   $0x802718
  801ec9:	e8 6c fe ff ff       	call   801d3a <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ece:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed1:	75 07                	jne    801eda <ipc_send+0x56>
			sys_yield();
  801ed3:	e8 60 ec ff ff       	call   800b38 <sys_yield>
  801ed8:	eb c6                	jmp    801ea0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801eda:	85 c0                	test   %eax,%eax
  801edc:	75 c2                	jne    801ea0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee1:	5b                   	pop    %ebx
  801ee2:	5e                   	pop    %esi
  801ee3:	5f                   	pop    %edi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    

00801ee6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eec:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ef1:	89 c2                	mov    %eax,%edx
  801ef3:	c1 e2 07             	shl    $0x7,%edx
  801ef6:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801efd:	8b 52 58             	mov    0x58(%edx),%edx
  801f00:	39 ca                	cmp    %ecx,%edx
  801f02:	75 11                	jne    801f15 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f04:	89 c2                	mov    %eax,%edx
  801f06:	c1 e2 07             	shl    $0x7,%edx
  801f09:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801f10:	8b 40 50             	mov    0x50(%eax),%eax
  801f13:	eb 0f                	jmp    801f24 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f15:	83 c0 01             	add    $0x1,%eax
  801f18:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f1d:	75 d2                	jne    801ef1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    

00801f26 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f2c:	89 d0                	mov    %edx,%eax
  801f2e:	c1 e8 16             	shr    $0x16,%eax
  801f31:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f38:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3d:	f6 c1 01             	test   $0x1,%cl
  801f40:	74 1d                	je     801f5f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f42:	c1 ea 0c             	shr    $0xc,%edx
  801f45:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f4c:	f6 c2 01             	test   $0x1,%dl
  801f4f:	74 0e                	je     801f5f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f51:	c1 ea 0c             	shr    $0xc,%edx
  801f54:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f5b:	ef 
  801f5c:	0f b7 c0             	movzwl %ax,%eax
}
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    
  801f61:	66 90                	xchg   %ax,%ax
  801f63:	66 90                	xchg   %ax,%ax
  801f65:	66 90                	xchg   %ax,%ax
  801f67:	66 90                	xchg   %ax,%ax
  801f69:	66 90                	xchg   %ax,%ax
  801f6b:	66 90                	xchg   %ax,%ax
  801f6d:	66 90                	xchg   %ax,%ax
  801f6f:	90                   	nop

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
