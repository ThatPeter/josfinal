
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 fe 0a 00 00       	call   800b3e <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 84 	cmpl   $0xeec00084,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 2f 0d 00 00       	call   800d8d <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 a0 1e 80 00       	push   $0x801ea0
  80006a:	e8 85 01 00 00       	call   8001f4 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 d4 00 c0 ee       	mov    0xeec000d4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 b1 1e 80 00       	push   $0x801eb1
  800083:	e8 6c 01 00 00       	call   8001f4 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 d4 00 c0 ee       	mov    0xeec000d4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 66 0d 00 00       	call   800e02 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000aa:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000b1:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000b4:	e8 85 0a 00 00       	call   800b3e <sys_getenvid>
  8000b9:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	50                   	push   %eax
  8000bf:	68 c8 1e 80 00       	push   $0x801ec8
  8000c4:	e8 2b 01 00 00       	call   8001f4 <cprintf>
  8000c9:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000cf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000dc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000e1:	89 c1                	mov    %eax,%ecx
  8000e3:	c1 e1 07             	shl    $0x7,%ecx
  8000e6:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8000ed:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8000f0:	39 cb                	cmp    %ecx,%ebx
  8000f2:	0f 44 fa             	cmove  %edx,%edi
  8000f5:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000fa:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000fd:	83 c0 01             	add    $0x1,%eax
  800100:	81 c2 84 00 00 00    	add    $0x84,%edx
  800106:	3d 00 04 00 00       	cmp    $0x400,%eax
  80010b:	75 d4                	jne    8000e1 <libmain+0x40>
  80010d:	89 f0                	mov    %esi,%eax
  80010f:	84 c0                	test   %al,%al
  800111:	74 06                	je     800119 <libmain+0x78>
  800113:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80011d:	7e 0a                	jle    800129 <libmain+0x88>
		binaryname = argv[0];
  80011f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800122:	8b 00                	mov    (%eax),%eax
  800124:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	ff 75 08             	pushl  0x8(%ebp)
  800132:	e8 fc fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800137:	e8 0b 00 00 00       	call   800147 <exit>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014d:	e8 1d 0f 00 00       	call   80106f <close_all>
	sys_env_destroy(0);
  800152:	83 ec 0c             	sub    $0xc,%esp
  800155:	6a 00                	push   $0x0
  800157:	e8 a1 09 00 00       	call   800afd <sys_env_destroy>
}
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	53                   	push   %ebx
  800165:	83 ec 04             	sub    $0x4,%esp
  800168:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016b:	8b 13                	mov    (%ebx),%edx
  80016d:	8d 42 01             	lea    0x1(%edx),%eax
  800170:	89 03                	mov    %eax,(%ebx)
  800172:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800175:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800179:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017e:	75 1a                	jne    80019a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800180:	83 ec 08             	sub    $0x8,%esp
  800183:	68 ff 00 00 00       	push   $0xff
  800188:	8d 43 08             	lea    0x8(%ebx),%eax
  80018b:	50                   	push   %eax
  80018c:	e8 2f 09 00 00       	call   800ac0 <sys_cputs>
		b->idx = 0;
  800191:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800197:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	ff 75 0c             	pushl  0xc(%ebp)
  8001c3:	ff 75 08             	pushl  0x8(%ebp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	50                   	push   %eax
  8001cd:	68 61 01 80 00       	push   $0x800161
  8001d2:	e8 54 01 00 00       	call   80032b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d7:	83 c4 08             	add    $0x8,%esp
  8001da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e6:	50                   	push   %eax
  8001e7:	e8 d4 08 00 00       	call   800ac0 <sys_cputs>

	return b.cnt;
}
  8001ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fd:	50                   	push   %eax
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	e8 9d ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	83 ec 1c             	sub    $0x1c,%esp
  800211:	89 c7                	mov    %eax,%edi
  800213:	89 d6                	mov    %edx,%esi
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800221:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800224:	bb 00 00 00 00       	mov    $0x0,%ebx
  800229:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022f:	39 d3                	cmp    %edx,%ebx
  800231:	72 05                	jb     800238 <printnum+0x30>
  800233:	39 45 10             	cmp    %eax,0x10(%ebp)
  800236:	77 45                	ja     80027d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	8b 45 14             	mov    0x14(%ebp),%eax
  800241:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800244:	53                   	push   %ebx
  800245:	ff 75 10             	pushl  0x10(%ebp)
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 b4 19 00 00       	call   801c10 <__udivdi3>
  80025c:	83 c4 18             	add    $0x18,%esp
  80025f:	52                   	push   %edx
  800260:	50                   	push   %eax
  800261:	89 f2                	mov    %esi,%edx
  800263:	89 f8                	mov    %edi,%eax
  800265:	e8 9e ff ff ff       	call   800208 <printnum>
  80026a:	83 c4 20             	add    $0x20,%esp
  80026d:	eb 18                	jmp    800287 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	56                   	push   %esi
  800273:	ff 75 18             	pushl  0x18(%ebp)
  800276:	ff d7                	call   *%edi
  800278:	83 c4 10             	add    $0x10,%esp
  80027b:	eb 03                	jmp    800280 <printnum+0x78>
  80027d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800280:	83 eb 01             	sub    $0x1,%ebx
  800283:	85 db                	test   %ebx,%ebx
  800285:	7f e8                	jg     80026f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	56                   	push   %esi
  80028b:	83 ec 04             	sub    $0x4,%esp
  80028e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800291:	ff 75 e0             	pushl  -0x20(%ebp)
  800294:	ff 75 dc             	pushl  -0x24(%ebp)
  800297:	ff 75 d8             	pushl  -0x28(%ebp)
  80029a:	e8 a1 1a 00 00       	call   801d40 <__umoddi3>
  80029f:	83 c4 14             	add    $0x14,%esp
  8002a2:	0f be 80 f1 1e 80 00 	movsbl 0x801ef1(%eax),%eax
  8002a9:	50                   	push   %eax
  8002aa:	ff d7                	call   *%edi
}
  8002ac:	83 c4 10             	add    $0x10,%esp
  8002af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	5f                   	pop    %edi
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    

008002b7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ba:	83 fa 01             	cmp    $0x1,%edx
  8002bd:	7e 0e                	jle    8002cd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	8b 52 04             	mov    0x4(%edx),%edx
  8002cb:	eb 22                	jmp    8002ef <getuint+0x38>
	else if (lflag)
  8002cd:	85 d2                	test   %edx,%edx
  8002cf:	74 10                	je     8002e1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	ba 00 00 00 00       	mov    $0x0,%edx
  8002df:	eb 0e                	jmp    8002ef <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e6:	89 08                	mov    %ecx,(%eax)
  8002e8:	8b 02                	mov    (%edx),%eax
  8002ea:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fb:	8b 10                	mov    (%eax),%edx
  8002fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800300:	73 0a                	jae    80030c <sprintputch+0x1b>
		*b->buf++ = ch;
  800302:	8d 4a 01             	lea    0x1(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	88 02                	mov    %al,(%edx)
}
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800314:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800317:	50                   	push   %eax
  800318:	ff 75 10             	pushl  0x10(%ebp)
  80031b:	ff 75 0c             	pushl  0xc(%ebp)
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 05 00 00 00       	call   80032b <vprintfmt>
	va_end(ap);
}
  800326:	83 c4 10             	add    $0x10,%esp
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	57                   	push   %edi
  80032f:	56                   	push   %esi
  800330:	53                   	push   %ebx
  800331:	83 ec 2c             	sub    $0x2c,%esp
  800334:	8b 75 08             	mov    0x8(%ebp),%esi
  800337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033d:	eb 12                	jmp    800351 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033f:	85 c0                	test   %eax,%eax
  800341:	0f 84 89 03 00 00    	je     8006d0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800347:	83 ec 08             	sub    $0x8,%esp
  80034a:	53                   	push   %ebx
  80034b:	50                   	push   %eax
  80034c:	ff d6                	call   *%esi
  80034e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800351:	83 c7 01             	add    $0x1,%edi
  800354:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800358:	83 f8 25             	cmp    $0x25,%eax
  80035b:	75 e2                	jne    80033f <vprintfmt+0x14>
  80035d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800361:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800368:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
  80037b:	eb 07                	jmp    800384 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800380:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8d 47 01             	lea    0x1(%edi),%eax
  800387:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038a:	0f b6 07             	movzbl (%edi),%eax
  80038d:	0f b6 c8             	movzbl %al,%ecx
  800390:	83 e8 23             	sub    $0x23,%eax
  800393:	3c 55                	cmp    $0x55,%al
  800395:	0f 87 1a 03 00 00    	ja     8006b5 <vprintfmt+0x38a>
  80039b:	0f b6 c0             	movzbl %al,%eax
  80039e:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ac:	eb d6                	jmp    800384 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c6:	83 fa 09             	cmp    $0x9,%edx
  8003c9:	77 39                	ja     800404 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ce:	eb e9                	jmp    8003b9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d9:	8b 00                	mov    (%eax),%eax
  8003db:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e1:	eb 27                	jmp    80040a <vprintfmt+0xdf>
  8003e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ed:	0f 49 c8             	cmovns %eax,%ecx
  8003f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f6:	eb 8c                	jmp    800384 <vprintfmt+0x59>
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800402:	eb 80                	jmp    800384 <vprintfmt+0x59>
  800404:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800407:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040e:	0f 89 70 ff ff ff    	jns    800384 <vprintfmt+0x59>
				width = precision, precision = -1;
  800414:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800417:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800421:	e9 5e ff ff ff       	jmp    800384 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800426:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042c:	e9 53 ff ff ff       	jmp    800384 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 50 04             	lea    0x4(%eax),%edx
  800437:	89 55 14             	mov    %edx,0x14(%ebp)
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	ff 30                	pushl  (%eax)
  800440:	ff d6                	call   *%esi
			break;
  800442:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800448:	e9 04 ff ff ff       	jmp    800351 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	8b 00                	mov    (%eax),%eax
  800458:	99                   	cltd   
  800459:	31 d0                	xor    %edx,%eax
  80045b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045d:	83 f8 0f             	cmp    $0xf,%eax
  800460:	7f 0b                	jg     80046d <vprintfmt+0x142>
  800462:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  800469:	85 d2                	test   %edx,%edx
  80046b:	75 18                	jne    800485 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046d:	50                   	push   %eax
  80046e:	68 09 1f 80 00       	push   $0x801f09
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	e8 94 fe ff ff       	call   80030e <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800480:	e9 cc fe ff ff       	jmp    800351 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800485:	52                   	push   %edx
  800486:	68 e9 22 80 00       	push   $0x8022e9
  80048b:	53                   	push   %ebx
  80048c:	56                   	push   %esi
  80048d:	e8 7c fe ff ff       	call   80030e <printfmt>
  800492:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800498:	e9 b4 fe ff ff       	jmp    800351 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a8:	85 ff                	test   %edi,%edi
  8004aa:	b8 02 1f 80 00       	mov    $0x801f02,%eax
  8004af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b6:	0f 8e 94 00 00 00    	jle    800550 <vprintfmt+0x225>
  8004bc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c0:	0f 84 98 00 00 00    	je     80055e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004cc:	57                   	push   %edi
  8004cd:	e8 86 02 00 00       	call   800758 <strnlen>
  8004d2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d5:	29 c1                	sub    %eax,%ecx
  8004d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004da:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004dd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	eb 0f                	jmp    8004fa <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	83 ef 01             	sub    $0x1,%edi
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	85 ff                	test   %edi,%edi
  8004fc:	7f ed                	jg     8004eb <vprintfmt+0x1c0>
  8004fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800501:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800504:	85 c9                	test   %ecx,%ecx
  800506:	b8 00 00 00 00       	mov    $0x0,%eax
  80050b:	0f 49 c1             	cmovns %ecx,%eax
  80050e:	29 c1                	sub    %eax,%ecx
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	89 cb                	mov    %ecx,%ebx
  80051b:	eb 4d                	jmp    80056a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800521:	74 1b                	je     80053e <vprintfmt+0x213>
  800523:	0f be c0             	movsbl %al,%eax
  800526:	83 e8 20             	sub    $0x20,%eax
  800529:	83 f8 5e             	cmp    $0x5e,%eax
  80052c:	76 10                	jbe    80053e <vprintfmt+0x213>
					putch('?', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	ff 75 0c             	pushl  0xc(%ebp)
  800534:	6a 3f                	push   $0x3f
  800536:	ff 55 08             	call   *0x8(%ebp)
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb 0d                	jmp    80054b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	52                   	push   %edx
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054b:	83 eb 01             	sub    $0x1,%ebx
  80054e:	eb 1a                	jmp    80056a <vprintfmt+0x23f>
  800550:	89 75 08             	mov    %esi,0x8(%ebp)
  800553:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800556:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800559:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055c:	eb 0c                	jmp    80056a <vprintfmt+0x23f>
  80055e:	89 75 08             	mov    %esi,0x8(%ebp)
  800561:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800564:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800567:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056a:	83 c7 01             	add    $0x1,%edi
  80056d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800571:	0f be d0             	movsbl %al,%edx
  800574:	85 d2                	test   %edx,%edx
  800576:	74 23                	je     80059b <vprintfmt+0x270>
  800578:	85 f6                	test   %esi,%esi
  80057a:	78 a1                	js     80051d <vprintfmt+0x1f2>
  80057c:	83 ee 01             	sub    $0x1,%esi
  80057f:	79 9c                	jns    80051d <vprintfmt+0x1f2>
  800581:	89 df                	mov    %ebx,%edi
  800583:	8b 75 08             	mov    0x8(%ebp),%esi
  800586:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800589:	eb 18                	jmp    8005a3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	53                   	push   %ebx
  80058f:	6a 20                	push   $0x20
  800591:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800593:	83 ef 01             	sub    $0x1,%edi
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	eb 08                	jmp    8005a3 <vprintfmt+0x278>
  80059b:	89 df                	mov    %ebx,%edi
  80059d:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a3:	85 ff                	test   %edi,%edi
  8005a5:	7f e4                	jg     80058b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005aa:	e9 a2 fd ff ff       	jmp    800351 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005af:	83 fa 01             	cmp    $0x1,%edx
  8005b2:	7e 16                	jle    8005ca <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 50 04             	mov    0x4(%eax),%edx
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c8:	eb 32                	jmp    8005fc <vprintfmt+0x2d1>
	else if (lflag)
  8005ca:	85 d2                	test   %edx,%edx
  8005cc:	74 18                	je     8005e6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 04             	lea    0x4(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dc:	89 c1                	mov    %eax,%ecx
  8005de:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e4:	eb 16                	jmp    8005fc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 c1                	mov    %eax,%ecx
  8005f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800602:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800607:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060b:	79 74                	jns    800681 <vprintfmt+0x356>
				putch('-', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 2d                	push   $0x2d
  800613:	ff d6                	call   *%esi
				num = -(long long) num;
  800615:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800618:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061b:	f7 d8                	neg    %eax
  80061d:	83 d2 00             	adc    $0x0,%edx
  800620:	f7 da                	neg    %edx
  800622:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800625:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062a:	eb 55                	jmp    800681 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062c:	8d 45 14             	lea    0x14(%ebp),%eax
  80062f:	e8 83 fc ff ff       	call   8002b7 <getuint>
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800639:	eb 46                	jmp    800681 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 74 fc ff ff       	call   8002b7 <getuint>
			base = 8;
  800643:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800648:	eb 37                	jmp    800681 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 30                	push   $0x30
  800650:	ff d6                	call   *%esi
			putch('x', putdat);
  800652:	83 c4 08             	add    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 78                	push   $0x78
  800658:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800672:	eb 0d                	jmp    800681 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 3b fc ff ff       	call   8002b7 <getuint>
			base = 16;
  80067c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800681:	83 ec 0c             	sub    $0xc,%esp
  800684:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800688:	57                   	push   %edi
  800689:	ff 75 e0             	pushl  -0x20(%ebp)
  80068c:	51                   	push   %ecx
  80068d:	52                   	push   %edx
  80068e:	50                   	push   %eax
  80068f:	89 da                	mov    %ebx,%edx
  800691:	89 f0                	mov    %esi,%eax
  800693:	e8 70 fb ff ff       	call   800208 <printnum>
			break;
  800698:	83 c4 20             	add    $0x20,%esp
  80069b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069e:	e9 ae fc ff ff       	jmp    800351 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	51                   	push   %ecx
  8006a8:	ff d6                	call   *%esi
			break;
  8006aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b0:	e9 9c fc ff ff       	jmp    800351 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 25                	push   $0x25
  8006bb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 03                	jmp    8006c5 <vprintfmt+0x39a>
  8006c2:	83 ef 01             	sub    $0x1,%edi
  8006c5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c9:	75 f7                	jne    8006c2 <vprintfmt+0x397>
  8006cb:	e9 81 fc ff ff       	jmp    800351 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5f                   	pop    %edi
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	83 ec 18             	sub    $0x18,%esp
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006eb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 26                	je     80071f <vsnprintf+0x47>
  8006f9:	85 d2                	test   %edx,%edx
  8006fb:	7e 22                	jle    80071f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fd:	ff 75 14             	pushl  0x14(%ebp)
  800700:	ff 75 10             	pushl  0x10(%ebp)
  800703:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	68 f1 02 80 00       	push   $0x8002f1
  80070c:	e8 1a fc ff ff       	call   80032b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800711:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800714:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	eb 05                	jmp    800724 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072f:	50                   	push   %eax
  800730:	ff 75 10             	pushl  0x10(%ebp)
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	ff 75 08             	pushl  0x8(%ebp)
  800739:	e8 9a ff ff ff       	call   8006d8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	eb 03                	jmp    800750 <strlen+0x10>
		n++;
  80074d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800750:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800754:	75 f7                	jne    80074d <strlen+0xd>
		n++;
	return n;
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800761:	ba 00 00 00 00       	mov    $0x0,%edx
  800766:	eb 03                	jmp    80076b <strnlen+0x13>
		n++;
  800768:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	39 c2                	cmp    %eax,%edx
  80076d:	74 08                	je     800777 <strnlen+0x1f>
  80076f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800773:	75 f3                	jne    800768 <strnlen+0x10>
  800775:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	53                   	push   %ebx
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800783:	89 c2                	mov    %eax,%edx
  800785:	83 c2 01             	add    $0x1,%edx
  800788:	83 c1 01             	add    $0x1,%ecx
  80078b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800792:	84 db                	test   %bl,%bl
  800794:	75 ef                	jne    800785 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800796:	5b                   	pop    %ebx
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	53                   	push   %ebx
  80079d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a0:	53                   	push   %ebx
  8007a1:	e8 9a ff ff ff       	call   800740 <strlen>
  8007a6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ac:	01 d8                	add    %ebx,%eax
  8007ae:	50                   	push   %eax
  8007af:	e8 c5 ff ff ff       	call   800779 <strcpy>
	return dst;
}
  8007b4:	89 d8                	mov    %ebx,%eax
  8007b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c6:	89 f3                	mov    %esi,%ebx
  8007c8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cb:	89 f2                	mov    %esi,%edx
  8007cd:	eb 0f                	jmp    8007de <strncpy+0x23>
		*dst++ = *src;
  8007cf:	83 c2 01             	add    $0x1,%edx
  8007d2:	0f b6 01             	movzbl (%ecx),%eax
  8007d5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007db:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007de:	39 da                	cmp    %ebx,%edx
  8007e0:	75 ed                	jne    8007cf <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e2:	89 f0                	mov    %esi,%eax
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f8:	85 d2                	test   %edx,%edx
  8007fa:	74 21                	je     80081d <strlcpy+0x35>
  8007fc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800800:	89 f2                	mov    %esi,%edx
  800802:	eb 09                	jmp    80080d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800804:	83 c2 01             	add    $0x1,%edx
  800807:	83 c1 01             	add    $0x1,%ecx
  80080a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080d:	39 c2                	cmp    %eax,%edx
  80080f:	74 09                	je     80081a <strlcpy+0x32>
  800811:	0f b6 19             	movzbl (%ecx),%ebx
  800814:	84 db                	test   %bl,%bl
  800816:	75 ec                	jne    800804 <strlcpy+0x1c>
  800818:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081d:	29 f0                	sub    %esi,%eax
}
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082c:	eb 06                	jmp    800834 <strcmp+0x11>
		p++, q++;
  80082e:	83 c1 01             	add    $0x1,%ecx
  800831:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800834:	0f b6 01             	movzbl (%ecx),%eax
  800837:	84 c0                	test   %al,%al
  800839:	74 04                	je     80083f <strcmp+0x1c>
  80083b:	3a 02                	cmp    (%edx),%al
  80083d:	74 ef                	je     80082e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083f:	0f b6 c0             	movzbl %al,%eax
  800842:	0f b6 12             	movzbl (%edx),%edx
  800845:	29 d0                	sub    %edx,%eax
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	89 c3                	mov    %eax,%ebx
  800855:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800858:	eb 06                	jmp    800860 <strncmp+0x17>
		n--, p++, q++;
  80085a:	83 c0 01             	add    $0x1,%eax
  80085d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800860:	39 d8                	cmp    %ebx,%eax
  800862:	74 15                	je     800879 <strncmp+0x30>
  800864:	0f b6 08             	movzbl (%eax),%ecx
  800867:	84 c9                	test   %cl,%cl
  800869:	74 04                	je     80086f <strncmp+0x26>
  80086b:	3a 0a                	cmp    (%edx),%cl
  80086d:	74 eb                	je     80085a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086f:	0f b6 00             	movzbl (%eax),%eax
  800872:	0f b6 12             	movzbl (%edx),%edx
  800875:	29 d0                	sub    %edx,%eax
  800877:	eb 05                	jmp    80087e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087e:	5b                   	pop    %ebx
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088b:	eb 07                	jmp    800894 <strchr+0x13>
		if (*s == c)
  80088d:	38 ca                	cmp    %cl,%dl
  80088f:	74 0f                	je     8008a0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800891:	83 c0 01             	add    $0x1,%eax
  800894:	0f b6 10             	movzbl (%eax),%edx
  800897:	84 d2                	test   %dl,%dl
  800899:	75 f2                	jne    80088d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ac:	eb 03                	jmp    8008b1 <strfind+0xf>
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 04                	je     8008bc <strfind+0x1a>
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	75 f2                	jne    8008ae <strfind+0xc>
			break;
	return (char *) s;
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	57                   	push   %edi
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ca:	85 c9                	test   %ecx,%ecx
  8008cc:	74 36                	je     800904 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d4:	75 28                	jne    8008fe <memset+0x40>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 23                	jne    8008fe <memset+0x40>
		c &= 0xFF;
  8008db:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008df:	89 d3                	mov    %edx,%ebx
  8008e1:	c1 e3 08             	shl    $0x8,%ebx
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	c1 e6 18             	shl    $0x18,%esi
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	c1 e0 10             	shl    $0x10,%eax
  8008ee:	09 f0                	or     %esi,%eax
  8008f0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f2:	89 d8                	mov    %ebx,%eax
  8008f4:	09 d0                	or     %edx,%eax
  8008f6:	c1 e9 02             	shr    $0x2,%ecx
  8008f9:	fc                   	cld    
  8008fa:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fc:	eb 06                	jmp    800904 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800901:	fc                   	cld    
  800902:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800904:	89 f8                	mov    %edi,%eax
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	57                   	push   %edi
  80090f:	56                   	push   %esi
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 75 0c             	mov    0xc(%ebp),%esi
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800919:	39 c6                	cmp    %eax,%esi
  80091b:	73 35                	jae    800952 <memmove+0x47>
  80091d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800920:	39 d0                	cmp    %edx,%eax
  800922:	73 2e                	jae    800952 <memmove+0x47>
		s += n;
		d += n;
  800924:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800927:	89 d6                	mov    %edx,%esi
  800929:	09 fe                	or     %edi,%esi
  80092b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800931:	75 13                	jne    800946 <memmove+0x3b>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 0e                	jne    800946 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800938:	83 ef 04             	sub    $0x4,%edi
  80093b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093e:	c1 e9 02             	shr    $0x2,%ecx
  800941:	fd                   	std    
  800942:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800944:	eb 09                	jmp    80094f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800946:	83 ef 01             	sub    $0x1,%edi
  800949:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094c:	fd                   	std    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094f:	fc                   	cld    
  800950:	eb 1d                	jmp    80096f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	89 f2                	mov    %esi,%edx
  800954:	09 c2                	or     %eax,%edx
  800956:	f6 c2 03             	test   $0x3,%dl
  800959:	75 0f                	jne    80096a <memmove+0x5f>
  80095b:	f6 c1 03             	test   $0x3,%cl
  80095e:	75 0a                	jne    80096a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800960:	c1 e9 02             	shr    $0x2,%ecx
  800963:	89 c7                	mov    %eax,%edi
  800965:	fc                   	cld    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb 05                	jmp    80096f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800976:	ff 75 10             	pushl  0x10(%ebp)
  800979:	ff 75 0c             	pushl  0xc(%ebp)
  80097c:	ff 75 08             	pushl  0x8(%ebp)
  80097f:	e8 87 ff ff ff       	call   80090b <memmove>
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	89 c6                	mov    %eax,%esi
  800993:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800996:	eb 1a                	jmp    8009b2 <memcmp+0x2c>
		if (*s1 != *s2)
  800998:	0f b6 08             	movzbl (%eax),%ecx
  80099b:	0f b6 1a             	movzbl (%edx),%ebx
  80099e:	38 d9                	cmp    %bl,%cl
  8009a0:	74 0a                	je     8009ac <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a2:	0f b6 c1             	movzbl %cl,%eax
  8009a5:	0f b6 db             	movzbl %bl,%ebx
  8009a8:	29 d8                	sub    %ebx,%eax
  8009aa:	eb 0f                	jmp    8009bb <memcmp+0x35>
		s1++, s2++;
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b2:	39 f0                	cmp    %esi,%eax
  8009b4:	75 e2                	jne    800998 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c6:	89 c1                	mov    %eax,%ecx
  8009c8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cf:	eb 0a                	jmp    8009db <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d1:	0f b6 10             	movzbl (%eax),%edx
  8009d4:	39 da                	cmp    %ebx,%edx
  8009d6:	74 07                	je     8009df <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	39 c8                	cmp    %ecx,%eax
  8009dd:	72 f2                	jb     8009d1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	eb 03                	jmp    8009f3 <strtol+0x11>
		s++;
  8009f0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f3:	0f b6 01             	movzbl (%ecx),%eax
  8009f6:	3c 20                	cmp    $0x20,%al
  8009f8:	74 f6                	je     8009f0 <strtol+0xe>
  8009fa:	3c 09                	cmp    $0x9,%al
  8009fc:	74 f2                	je     8009f0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fe:	3c 2b                	cmp    $0x2b,%al
  800a00:	75 0a                	jne    800a0c <strtol+0x2a>
		s++;
  800a02:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a05:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0a:	eb 11                	jmp    800a1d <strtol+0x3b>
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a11:	3c 2d                	cmp    $0x2d,%al
  800a13:	75 08                	jne    800a1d <strtol+0x3b>
		s++, neg = 1;
  800a15:	83 c1 01             	add    $0x1,%ecx
  800a18:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a23:	75 15                	jne    800a3a <strtol+0x58>
  800a25:	80 39 30             	cmpb   $0x30,(%ecx)
  800a28:	75 10                	jne    800a3a <strtol+0x58>
  800a2a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2e:	75 7c                	jne    800aac <strtol+0xca>
		s += 2, base = 16;
  800a30:	83 c1 02             	add    $0x2,%ecx
  800a33:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a38:	eb 16                	jmp    800a50 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	75 12                	jne    800a50 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a43:	80 39 30             	cmpb   $0x30,(%ecx)
  800a46:	75 08                	jne    800a50 <strtol+0x6e>
		s++, base = 8;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a58:	0f b6 11             	movzbl (%ecx),%edx
  800a5b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5e:	89 f3                	mov    %esi,%ebx
  800a60:	80 fb 09             	cmp    $0x9,%bl
  800a63:	77 08                	ja     800a6d <strtol+0x8b>
			dig = *s - '0';
  800a65:	0f be d2             	movsbl %dl,%edx
  800a68:	83 ea 30             	sub    $0x30,%edx
  800a6b:	eb 22                	jmp    800a8f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a70:	89 f3                	mov    %esi,%ebx
  800a72:	80 fb 19             	cmp    $0x19,%bl
  800a75:	77 08                	ja     800a7f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a77:	0f be d2             	movsbl %dl,%edx
  800a7a:	83 ea 57             	sub    $0x57,%edx
  800a7d:	eb 10                	jmp    800a8f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a82:	89 f3                	mov    %esi,%ebx
  800a84:	80 fb 19             	cmp    $0x19,%bl
  800a87:	77 16                	ja     800a9f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a89:	0f be d2             	movsbl %dl,%edx
  800a8c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a92:	7d 0b                	jge    800a9f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9d:	eb b9                	jmp    800a58 <strtol+0x76>

	if (endptr)
  800a9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa3:	74 0d                	je     800ab2 <strtol+0xd0>
		*endptr = (char *) s;
  800aa5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa8:	89 0e                	mov    %ecx,(%esi)
  800aaa:	eb 06                	jmp    800ab2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	74 98                	je     800a48 <strtol+0x66>
  800ab0:	eb 9e                	jmp    800a50 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	f7 da                	neg    %edx
  800ab6:	85 ff                	test   %edi,%edi
  800ab8:	0f 45 c2             	cmovne %edx,%eax
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	89 c6                	mov    %eax,%esi
  800ad7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cgetc>:

int
sys_cgetc(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
  800b13:	89 cb                	mov    %ecx,%ebx
  800b15:	89 cf                	mov    %ecx,%edi
  800b17:	89 ce                	mov    %ecx,%esi
  800b19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 03                	push   $0x3
  800b25:	68 ff 21 80 00       	push   $0x8021ff
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 1c 22 80 00       	push   $0x80221c
  800b31:	e8 58 10 00 00       	call   801b8e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_yield>:

void
sys_yield(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	be 00 00 00 00       	mov    $0x0,%esi
  800b8a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b98:	89 f7                	mov    %esi,%edi
  800b9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 17                	jle    800bb7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 04                	push   $0x4
  800ba6:	68 ff 21 80 00       	push   $0x8021ff
  800bab:	6a 23                	push   $0x23
  800bad:	68 1c 22 80 00       	push   $0x80221c
  800bb2:	e8 d7 0f 00 00       	call   801b8e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7e 17                	jle    800bf9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 05                	push   $0x5
  800be8:	68 ff 21 80 00       	push   $0x8021ff
  800bed:	6a 23                	push   $0x23
  800bef:	68 1c 22 80 00       	push   $0x80221c
  800bf4:	e8 95 0f 00 00       	call   801b8e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 df                	mov    %ebx,%edi
  800c1c:	89 de                	mov    %ebx,%esi
  800c1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 06                	push   $0x6
  800c2a:	68 ff 21 80 00       	push   $0x8021ff
  800c2f:	6a 23                	push   $0x23
  800c31:	68 1c 22 80 00       	push   $0x80221c
  800c36:	e8 53 0f 00 00       	call   801b8e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c51:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c64:	7e 17                	jle    800c7d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 08                	push   $0x8
  800c6c:	68 ff 21 80 00       	push   $0x8021ff
  800c71:	6a 23                	push   $0x23
  800c73:	68 1c 22 80 00       	push   $0x80221c
  800c78:	e8 11 0f 00 00       	call   801b8e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c93:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800ca6:	7e 17                	jle    800cbf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 09                	push   $0x9
  800cae:	68 ff 21 80 00       	push   $0x8021ff
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 1c 22 80 00       	push   $0x80221c
  800cba:	e8 cf 0e 00 00       	call   801b8e <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800cd5:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800ce8:	7e 17                	jle    800d01 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	50                   	push   %eax
  800cee:	6a 0a                	push   $0xa
  800cf0:	68 ff 21 80 00       	push   $0x8021ff
  800cf5:	6a 23                	push   $0x23
  800cf7:	68 1c 22 80 00       	push   $0x80221c
  800cfc:	e8 8d 0e 00 00       	call   801b8e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	be 00 00 00 00       	mov    $0x0,%esi
  800d14:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d25:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 cb                	mov    %ecx,%ebx
  800d44:	89 cf                	mov    %ecx,%edi
  800d46:	89 ce                	mov    %ecx,%esi
  800d48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 17                	jle    800d65 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 0d                	push   $0xd
  800d54:	68 ff 21 80 00       	push   $0x8021ff
  800d59:	6a 23                	push   $0x23
  800d5b:	68 1c 22 80 00       	push   $0x80221c
  800d60:	e8 29 0e 00 00       	call   801b8e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d78:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 cb                	mov    %ecx,%ebx
  800d82:	89 cf                	mov    %ecx,%edi
  800d84:	89 ce                	mov    %ecx,%esi
  800d86:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	8b 75 08             	mov    0x8(%ebp),%esi
  800d95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	75 12                	jne    800db1 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	68 00 00 c0 ee       	push   $0xeec00000
  800da7:	e8 80 ff ff ff       	call   800d2c <sys_ipc_recv>
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	eb 0c                	jmp    800dbd <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	e8 72 ff ff ff       	call   800d2c <sys_ipc_recv>
  800dba:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  800dbd:	85 f6                	test   %esi,%esi
  800dbf:	0f 95 c1             	setne  %cl
  800dc2:	85 db                	test   %ebx,%ebx
  800dc4:	0f 95 c2             	setne  %dl
  800dc7:	84 d1                	test   %dl,%cl
  800dc9:	74 09                	je     800dd4 <ipc_recv+0x47>
  800dcb:	89 c2                	mov    %eax,%edx
  800dcd:	c1 ea 1f             	shr    $0x1f,%edx
  800dd0:	84 d2                	test   %dl,%dl
  800dd2:	75 27                	jne    800dfb <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  800dd4:	85 f6                	test   %esi,%esi
  800dd6:	74 0a                	je     800de2 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  800dd8:	a1 04 40 80 00       	mov    0x804004,%eax
  800ddd:	8b 40 7c             	mov    0x7c(%eax),%eax
  800de0:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  800de2:	85 db                	test   %ebx,%ebx
  800de4:	74 0d                	je     800df3 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  800de6:	a1 04 40 80 00       	mov    0x804004,%eax
  800deb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800df1:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  800df3:	a1 04 40 80 00       	mov    0x804004,%eax
  800df8:	8b 40 78             	mov    0x78(%eax),%eax
}
  800dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  800e14:	85 db                	test   %ebx,%ebx
  800e16:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800e1b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800e1e:	ff 75 14             	pushl  0x14(%ebp)
  800e21:	53                   	push   %ebx
  800e22:	56                   	push   %esi
  800e23:	57                   	push   %edi
  800e24:	e8 e0 fe ff ff       	call   800d09 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  800e29:	89 c2                	mov    %eax,%edx
  800e2b:	c1 ea 1f             	shr    $0x1f,%edx
  800e2e:	83 c4 10             	add    $0x10,%esp
  800e31:	84 d2                	test   %dl,%dl
  800e33:	74 17                	je     800e4c <ipc_send+0x4a>
  800e35:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e38:	74 12                	je     800e4c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  800e3a:	50                   	push   %eax
  800e3b:	68 2a 22 80 00       	push   $0x80222a
  800e40:	6a 47                	push   $0x47
  800e42:	68 38 22 80 00       	push   $0x802238
  800e47:	e8 42 0d 00 00       	call   801b8e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  800e4c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e4f:	75 07                	jne    800e58 <ipc_send+0x56>
			sys_yield();
  800e51:	e8 07 fd ff ff       	call   800b5d <sys_yield>
  800e56:	eb c6                	jmp    800e1e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	75 c2                	jne    800e1e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  800e5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e6a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e6f:	89 c2                	mov    %eax,%edx
  800e71:	c1 e2 07             	shl    $0x7,%edx
  800e74:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  800e7b:	8b 52 58             	mov    0x58(%edx),%edx
  800e7e:	39 ca                	cmp    %ecx,%edx
  800e80:	75 11                	jne    800e93 <ipc_find_env+0x2f>
			return envs[i].env_id;
  800e82:	89 c2                	mov    %eax,%edx
  800e84:	c1 e2 07             	shl    $0x7,%edx
  800e87:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800e8e:	8b 40 50             	mov    0x50(%eax),%eax
  800e91:	eb 0f                	jmp    800ea2 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e93:	83 c0 01             	add    $0x1,%eax
  800e96:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e9b:	75 d2                	jne    800e6f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaa:	05 00 00 00 30       	add    $0x30000000,%eax
  800eaf:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	05 00 00 00 30       	add    $0x30000000,%eax
  800ebf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	c1 ea 16             	shr    $0x16,%edx
  800edb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	74 11                	je     800ef8 <fd_alloc+0x2d>
  800ee7:	89 c2                	mov    %eax,%edx
  800ee9:	c1 ea 0c             	shr    $0xc,%edx
  800eec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef3:	f6 c2 01             	test   $0x1,%dl
  800ef6:	75 09                	jne    800f01 <fd_alloc+0x36>
			*fd_store = fd;
  800ef8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	eb 17                	jmp    800f18 <fd_alloc+0x4d>
  800f01:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f06:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f0b:	75 c9                	jne    800ed6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f0d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f13:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f20:	83 f8 1f             	cmp    $0x1f,%eax
  800f23:	77 36                	ja     800f5b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f25:	c1 e0 0c             	shl    $0xc,%eax
  800f28:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2d:	89 c2                	mov    %eax,%edx
  800f2f:	c1 ea 16             	shr    $0x16,%edx
  800f32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f39:	f6 c2 01             	test   $0x1,%dl
  800f3c:	74 24                	je     800f62 <fd_lookup+0x48>
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	c1 ea 0c             	shr    $0xc,%edx
  800f43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4a:	f6 c2 01             	test   $0x1,%dl
  800f4d:	74 1a                	je     800f69 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f52:	89 02                	mov    %eax,(%edx)
	return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
  800f59:	eb 13                	jmp    800f6e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f60:	eb 0c                	jmp    800f6e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f67:	eb 05                	jmp    800f6e <fd_lookup+0x54>
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 08             	sub    $0x8,%esp
  800f76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f79:	ba c0 22 80 00       	mov    $0x8022c0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f7e:	eb 13                	jmp    800f93 <dev_lookup+0x23>
  800f80:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f83:	39 08                	cmp    %ecx,(%eax)
  800f85:	75 0c                	jne    800f93 <dev_lookup+0x23>
			*dev = devtab[i];
  800f87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f91:	eb 2e                	jmp    800fc1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f93:	8b 02                	mov    (%edx),%eax
  800f95:	85 c0                	test   %eax,%eax
  800f97:	75 e7                	jne    800f80 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f99:	a1 04 40 80 00       	mov    0x804004,%eax
  800f9e:	8b 40 50             	mov    0x50(%eax),%eax
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	51                   	push   %ecx
  800fa5:	50                   	push   %eax
  800fa6:	68 44 22 80 00       	push   $0x802244
  800fab:	e8 44 f2 ff ff       	call   8001f4 <cprintf>
	*dev = 0;
  800fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 10             	sub    $0x10,%esp
  800fcb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd4:	50                   	push   %eax
  800fd5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fdb:	c1 e8 0c             	shr    $0xc,%eax
  800fde:	50                   	push   %eax
  800fdf:	e8 36 ff ff ff       	call   800f1a <fd_lookup>
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 05                	js     800ff0 <fd_close+0x2d>
	    || fd != fd2)
  800feb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fee:	74 0c                	je     800ffc <fd_close+0x39>
		return (must_exist ? r : 0);
  800ff0:	84 db                	test   %bl,%bl
  800ff2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff7:	0f 44 c2             	cmove  %edx,%eax
  800ffa:	eb 41                	jmp    80103d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ffc:	83 ec 08             	sub    $0x8,%esp
  800fff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	ff 36                	pushl  (%esi)
  801005:	e8 66 ff ff ff       	call   800f70 <dev_lookup>
  80100a:	89 c3                	mov    %eax,%ebx
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 1a                	js     80102d <fd_close+0x6a>
		if (dev->dev_close)
  801013:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801016:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801019:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80101e:	85 c0                	test   %eax,%eax
  801020:	74 0b                	je     80102d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	56                   	push   %esi
  801026:	ff d0                	call   *%eax
  801028:	89 c3                	mov    %eax,%ebx
  80102a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80102d:	83 ec 08             	sub    $0x8,%esp
  801030:	56                   	push   %esi
  801031:	6a 00                	push   $0x0
  801033:	e8 c9 fb ff ff       	call   800c01 <sys_page_unmap>
	return r;
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	89 d8                	mov    %ebx,%eax
}
  80103d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80104a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104d:	50                   	push   %eax
  80104e:	ff 75 08             	pushl  0x8(%ebp)
  801051:	e8 c4 fe ff ff       	call   800f1a <fd_lookup>
  801056:	83 c4 08             	add    $0x8,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 10                	js     80106d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80105d:	83 ec 08             	sub    $0x8,%esp
  801060:	6a 01                	push   $0x1
  801062:	ff 75 f4             	pushl  -0xc(%ebp)
  801065:	e8 59 ff ff ff       	call   800fc3 <fd_close>
  80106a:	83 c4 10             	add    $0x10,%esp
}
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <close_all>:

void
close_all(void)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	53                   	push   %ebx
  801073:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801076:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	53                   	push   %ebx
  80107f:	e8 c0 ff ff ff       	call   801044 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801084:	83 c3 01             	add    $0x1,%ebx
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	83 fb 20             	cmp    $0x20,%ebx
  80108d:	75 ec                	jne    80107b <close_all+0xc>
		close(i);
}
  80108f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
  80109a:	83 ec 2c             	sub    $0x2c,%esp
  80109d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 08             	pushl  0x8(%ebp)
  8010a7:	e8 6e fe ff ff       	call   800f1a <fd_lookup>
  8010ac:	83 c4 08             	add    $0x8,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	0f 88 c1 00 00 00    	js     801178 <dup+0xe4>
		return r;
	close(newfdnum);
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	56                   	push   %esi
  8010bb:	e8 84 ff ff ff       	call   801044 <close>

	newfd = INDEX2FD(newfdnum);
  8010c0:	89 f3                	mov    %esi,%ebx
  8010c2:	c1 e3 0c             	shl    $0xc,%ebx
  8010c5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010cb:	83 c4 04             	add    $0x4,%esp
  8010ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d1:	e8 de fd ff ff       	call   800eb4 <fd2data>
  8010d6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010d8:	89 1c 24             	mov    %ebx,(%esp)
  8010db:	e8 d4 fd ff ff       	call   800eb4 <fd2data>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e6:	89 f8                	mov    %edi,%eax
  8010e8:	c1 e8 16             	shr    $0x16,%eax
  8010eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f2:	a8 01                	test   $0x1,%al
  8010f4:	74 37                	je     80112d <dup+0x99>
  8010f6:	89 f8                	mov    %edi,%eax
  8010f8:	c1 e8 0c             	shr    $0xc,%eax
  8010fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801102:	f6 c2 01             	test   $0x1,%dl
  801105:	74 26                	je     80112d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801107:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	25 07 0e 00 00       	and    $0xe07,%eax
  801116:	50                   	push   %eax
  801117:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111a:	6a 00                	push   $0x0
  80111c:	57                   	push   %edi
  80111d:	6a 00                	push   $0x0
  80111f:	e8 9b fa ff ff       	call   800bbf <sys_page_map>
  801124:	89 c7                	mov    %eax,%edi
  801126:	83 c4 20             	add    $0x20,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 2e                	js     80115b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80112d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801130:	89 d0                	mov    %edx,%eax
  801132:	c1 e8 0c             	shr    $0xc,%eax
  801135:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	25 07 0e 00 00       	and    $0xe07,%eax
  801144:	50                   	push   %eax
  801145:	53                   	push   %ebx
  801146:	6a 00                	push   $0x0
  801148:	52                   	push   %edx
  801149:	6a 00                	push   $0x0
  80114b:	e8 6f fa ff ff       	call   800bbf <sys_page_map>
  801150:	89 c7                	mov    %eax,%edi
  801152:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801155:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801157:	85 ff                	test   %edi,%edi
  801159:	79 1d                	jns    801178 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	53                   	push   %ebx
  80115f:	6a 00                	push   $0x0
  801161:	e8 9b fa ff ff       	call   800c01 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801166:	83 c4 08             	add    $0x8,%esp
  801169:	ff 75 d4             	pushl  -0x2c(%ebp)
  80116c:	6a 00                	push   $0x0
  80116e:	e8 8e fa ff ff       	call   800c01 <sys_page_unmap>
	return r;
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	89 f8                	mov    %edi,%eax
}
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 14             	sub    $0x14,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	53                   	push   %ebx
  80118f:	e8 86 fd ff ff       	call   800f1a <fd_lookup>
  801194:	83 c4 08             	add    $0x8,%esp
  801197:	89 c2                	mov    %eax,%edx
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 6d                	js     80120a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a3:	50                   	push   %eax
  8011a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a7:	ff 30                	pushl  (%eax)
  8011a9:	e8 c2 fd ff ff       	call   800f70 <dev_lookup>
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	78 4c                	js     801201 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011b8:	8b 42 08             	mov    0x8(%edx),%eax
  8011bb:	83 e0 03             	and    $0x3,%eax
  8011be:	83 f8 01             	cmp    $0x1,%eax
  8011c1:	75 21                	jne    8011e4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c8:	8b 40 50             	mov    0x50(%eax),%eax
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	53                   	push   %ebx
  8011cf:	50                   	push   %eax
  8011d0:	68 85 22 80 00       	push   $0x802285
  8011d5:	e8 1a f0 ff ff       	call   8001f4 <cprintf>
		return -E_INVAL;
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e2:	eb 26                	jmp    80120a <read+0x8a>
	}
	if (!dev->dev_read)
  8011e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e7:	8b 40 08             	mov    0x8(%eax),%eax
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 17                	je     801205 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	ff 75 10             	pushl  0x10(%ebp)
  8011f4:	ff 75 0c             	pushl  0xc(%ebp)
  8011f7:	52                   	push   %edx
  8011f8:	ff d0                	call   *%eax
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	eb 09                	jmp    80120a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801201:	89 c2                	mov    %eax,%edx
  801203:	eb 05                	jmp    80120a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801205:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80120a:	89 d0                	mov    %edx,%eax
  80120c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 0c             	sub    $0xc,%esp
  80121a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801220:	bb 00 00 00 00       	mov    $0x0,%ebx
  801225:	eb 21                	jmp    801248 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	89 f0                	mov    %esi,%eax
  80122c:	29 d8                	sub    %ebx,%eax
  80122e:	50                   	push   %eax
  80122f:	89 d8                	mov    %ebx,%eax
  801231:	03 45 0c             	add    0xc(%ebp),%eax
  801234:	50                   	push   %eax
  801235:	57                   	push   %edi
  801236:	e8 45 ff ff ff       	call   801180 <read>
		if (m < 0)
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 10                	js     801252 <readn+0x41>
			return m;
		if (m == 0)
  801242:	85 c0                	test   %eax,%eax
  801244:	74 0a                	je     801250 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801246:	01 c3                	add    %eax,%ebx
  801248:	39 f3                	cmp    %esi,%ebx
  80124a:	72 db                	jb     801227 <readn+0x16>
  80124c:	89 d8                	mov    %ebx,%eax
  80124e:	eb 02                	jmp    801252 <readn+0x41>
  801250:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	53                   	push   %ebx
  80125e:	83 ec 14             	sub    $0x14,%esp
  801261:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	50                   	push   %eax
  801268:	53                   	push   %ebx
  801269:	e8 ac fc ff ff       	call   800f1a <fd_lookup>
  80126e:	83 c4 08             	add    $0x8,%esp
  801271:	89 c2                	mov    %eax,%edx
  801273:	85 c0                	test   %eax,%eax
  801275:	78 68                	js     8012df <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	ff 30                	pushl  (%eax)
  801283:	e8 e8 fc ff ff       	call   800f70 <dev_lookup>
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 47                	js     8012d6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801292:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801296:	75 21                	jne    8012b9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801298:	a1 04 40 80 00       	mov    0x804004,%eax
  80129d:	8b 40 50             	mov    0x50(%eax),%eax
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	53                   	push   %ebx
  8012a4:	50                   	push   %eax
  8012a5:	68 a1 22 80 00       	push   $0x8022a1
  8012aa:	e8 45 ef ff ff       	call   8001f4 <cprintf>
		return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b7:	eb 26                	jmp    8012df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8012bf:	85 d2                	test   %edx,%edx
  8012c1:	74 17                	je     8012da <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	ff 75 10             	pushl  0x10(%ebp)
  8012c9:	ff 75 0c             	pushl  0xc(%ebp)
  8012cc:	50                   	push   %eax
  8012cd:	ff d2                	call   *%edx
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	eb 09                	jmp    8012df <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	eb 05                	jmp    8012df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012df:	89 d0                	mov    %edx,%eax
  8012e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	ff 75 08             	pushl  0x8(%ebp)
  8012f3:	e8 22 fc ff ff       	call   800f1a <fd_lookup>
  8012f8:	83 c4 08             	add    $0x8,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 0e                	js     80130d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801302:	8b 55 0c             	mov    0xc(%ebp),%edx
  801305:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 14             	sub    $0x14,%esp
  801316:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801319:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	53                   	push   %ebx
  80131e:	e8 f7 fb ff ff       	call   800f1a <fd_lookup>
  801323:	83 c4 08             	add    $0x8,%esp
  801326:	89 c2                	mov    %eax,%edx
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 65                	js     801391 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801336:	ff 30                	pushl  (%eax)
  801338:	e8 33 fc ff ff       	call   800f70 <dev_lookup>
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	78 44                	js     801388 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801347:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80134b:	75 21                	jne    80136e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80134d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801352:	8b 40 50             	mov    0x50(%eax),%eax
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	53                   	push   %ebx
  801359:	50                   	push   %eax
  80135a:	68 64 22 80 00       	push   $0x802264
  80135f:	e8 90 ee ff ff       	call   8001f4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80136c:	eb 23                	jmp    801391 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80136e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801371:	8b 52 18             	mov    0x18(%edx),%edx
  801374:	85 d2                	test   %edx,%edx
  801376:	74 14                	je     80138c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	ff 75 0c             	pushl  0xc(%ebp)
  80137e:	50                   	push   %eax
  80137f:	ff d2                	call   *%edx
  801381:	89 c2                	mov    %eax,%edx
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	eb 09                	jmp    801391 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801388:	89 c2                	mov    %eax,%edx
  80138a:	eb 05                	jmp    801391 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80138c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801391:	89 d0                	mov    %edx,%eax
  801393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 14             	sub    $0x14,%esp
  80139f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	ff 75 08             	pushl  0x8(%ebp)
  8013a9:	e8 6c fb ff ff       	call   800f1a <fd_lookup>
  8013ae:	83 c4 08             	add    $0x8,%esp
  8013b1:	89 c2                	mov    %eax,%edx
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 58                	js     80140f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c1:	ff 30                	pushl  (%eax)
  8013c3:	e8 a8 fb ff ff       	call   800f70 <dev_lookup>
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 37                	js     801406 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013d6:	74 32                	je     80140a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013db:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e2:	00 00 00 
	stat->st_isdir = 0;
  8013e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ec:	00 00 00 
	stat->st_dev = dev;
  8013ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	53                   	push   %ebx
  8013f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8013fc:	ff 50 14             	call   *0x14(%eax)
  8013ff:	89 c2                	mov    %eax,%edx
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	eb 09                	jmp    80140f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801406:	89 c2                	mov    %eax,%edx
  801408:	eb 05                	jmp    80140f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80140a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80140f:	89 d0                	mov    %edx,%eax
  801411:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	6a 00                	push   $0x0
  801420:	ff 75 08             	pushl  0x8(%ebp)
  801423:	e8 e3 01 00 00       	call   80160b <open>
  801428:	89 c3                	mov    %eax,%ebx
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 1b                	js     80144c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	50                   	push   %eax
  801438:	e8 5b ff ff ff       	call   801398 <fstat>
  80143d:	89 c6                	mov    %eax,%esi
	close(fd);
  80143f:	89 1c 24             	mov    %ebx,(%esp)
  801442:	e8 fd fb ff ff       	call   801044 <close>
	return r;
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	89 f0                	mov    %esi,%eax
}
  80144c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	56                   	push   %esi
  801457:	53                   	push   %ebx
  801458:	89 c6                	mov    %eax,%esi
  80145a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80145c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801463:	75 12                	jne    801477 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	6a 01                	push   $0x1
  80146a:	e8 f5 f9 ff ff       	call   800e64 <ipc_find_env>
  80146f:	a3 00 40 80 00       	mov    %eax,0x804000
  801474:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801477:	6a 07                	push   $0x7
  801479:	68 00 50 80 00       	push   $0x805000
  80147e:	56                   	push   %esi
  80147f:	ff 35 00 40 80 00    	pushl  0x804000
  801485:	e8 78 f9 ff ff       	call   800e02 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80148a:	83 c4 0c             	add    $0xc,%esp
  80148d:	6a 00                	push   $0x0
  80148f:	53                   	push   %ebx
  801490:	6a 00                	push   $0x0
  801492:	e8 f6 f8 ff ff       	call   800d8d <ipc_recv>
}
  801497:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c1:	e8 8d ff ff ff       	call   801453 <fsipc>
}
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e3:	e8 6b ff ff ff       	call   801453 <fsipc>
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	53                   	push   %ebx
  8014ee:	83 ec 04             	sub    $0x4,%esp
  8014f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801504:	b8 05 00 00 00       	mov    $0x5,%eax
  801509:	e8 45 ff ff ff       	call   801453 <fsipc>
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 2c                	js     80153e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	68 00 50 80 00       	push   $0x805000
  80151a:	53                   	push   %ebx
  80151b:	e8 59 f2 ff ff       	call   800779 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801520:	a1 80 50 80 00       	mov    0x805080,%eax
  801525:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80152b:	a1 84 50 80 00       	mov    0x805084,%eax
  801530:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80154c:	8b 55 08             	mov    0x8(%ebp),%edx
  80154f:	8b 52 0c             	mov    0xc(%edx),%edx
  801552:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801558:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80155d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801562:	0f 47 c2             	cmova  %edx,%eax
  801565:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80156a:	50                   	push   %eax
  80156b:	ff 75 0c             	pushl  0xc(%ebp)
  80156e:	68 08 50 80 00       	push   $0x805008
  801573:	e8 93 f3 ff ff       	call   80090b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801578:	ba 00 00 00 00       	mov    $0x0,%edx
  80157d:	b8 04 00 00 00       	mov    $0x4,%eax
  801582:	e8 cc fe ff ff       	call   801453 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801587:	c9                   	leave  
  801588:	c3                   	ret    

00801589 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801591:	8b 45 08             	mov    0x8(%ebp),%eax
  801594:	8b 40 0c             	mov    0xc(%eax),%eax
  801597:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80159c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ac:	e8 a2 fe ff ff       	call   801453 <fsipc>
  8015b1:	89 c3                	mov    %eax,%ebx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 4b                	js     801602 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015b7:	39 c6                	cmp    %eax,%esi
  8015b9:	73 16                	jae    8015d1 <devfile_read+0x48>
  8015bb:	68 d0 22 80 00       	push   $0x8022d0
  8015c0:	68 d7 22 80 00       	push   $0x8022d7
  8015c5:	6a 7c                	push   $0x7c
  8015c7:	68 ec 22 80 00       	push   $0x8022ec
  8015cc:	e8 bd 05 00 00       	call   801b8e <_panic>
	assert(r <= PGSIZE);
  8015d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015d6:	7e 16                	jle    8015ee <devfile_read+0x65>
  8015d8:	68 f7 22 80 00       	push   $0x8022f7
  8015dd:	68 d7 22 80 00       	push   $0x8022d7
  8015e2:	6a 7d                	push   $0x7d
  8015e4:	68 ec 22 80 00       	push   $0x8022ec
  8015e9:	e8 a0 05 00 00       	call   801b8e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ee:	83 ec 04             	sub    $0x4,%esp
  8015f1:	50                   	push   %eax
  8015f2:	68 00 50 80 00       	push   $0x805000
  8015f7:	ff 75 0c             	pushl  0xc(%ebp)
  8015fa:	e8 0c f3 ff ff       	call   80090b <memmove>
	return r;
  8015ff:	83 c4 10             	add    $0x10,%esp
}
  801602:	89 d8                	mov    %ebx,%eax
  801604:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801607:	5b                   	pop    %ebx
  801608:	5e                   	pop    %esi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	53                   	push   %ebx
  80160f:	83 ec 20             	sub    $0x20,%esp
  801612:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801615:	53                   	push   %ebx
  801616:	e8 25 f1 ff ff       	call   800740 <strlen>
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801623:	7f 67                	jg     80168c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801625:	83 ec 0c             	sub    $0xc,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	e8 9a f8 ff ff       	call   800ecb <fd_alloc>
  801631:	83 c4 10             	add    $0x10,%esp
		return r;
  801634:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801636:	85 c0                	test   %eax,%eax
  801638:	78 57                	js     801691 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	53                   	push   %ebx
  80163e:	68 00 50 80 00       	push   $0x805000
  801643:	e8 31 f1 ff ff       	call   800779 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801648:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801650:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801653:	b8 01 00 00 00       	mov    $0x1,%eax
  801658:	e8 f6 fd ff ff       	call   801453 <fsipc>
  80165d:	89 c3                	mov    %eax,%ebx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	79 14                	jns    80167a <open+0x6f>
		fd_close(fd, 0);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	6a 00                	push   $0x0
  80166b:	ff 75 f4             	pushl  -0xc(%ebp)
  80166e:	e8 50 f9 ff ff       	call   800fc3 <fd_close>
		return r;
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	89 da                	mov    %ebx,%edx
  801678:	eb 17                	jmp    801691 <open+0x86>
	}

	return fd2num(fd);
  80167a:	83 ec 0c             	sub    $0xc,%esp
  80167d:	ff 75 f4             	pushl  -0xc(%ebp)
  801680:	e8 1f f8 ff ff       	call   800ea4 <fd2num>
  801685:	89 c2                	mov    %eax,%edx
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	eb 05                	jmp    801691 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80168c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801691:	89 d0                	mov    %edx,%eax
  801693:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a8:	e8 a6 fd ff ff       	call   801453 <fsipc>
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016b7:	83 ec 0c             	sub    $0xc,%esp
  8016ba:	ff 75 08             	pushl  0x8(%ebp)
  8016bd:	e8 f2 f7 ff ff       	call   800eb4 <fd2data>
  8016c2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016c4:	83 c4 08             	add    $0x8,%esp
  8016c7:	68 03 23 80 00       	push   $0x802303
  8016cc:	53                   	push   %ebx
  8016cd:	e8 a7 f0 ff ff       	call   800779 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016d2:	8b 46 04             	mov    0x4(%esi),%eax
  8016d5:	2b 06                	sub    (%esi),%eax
  8016d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e4:	00 00 00 
	stat->st_dev = &devpipe;
  8016e7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016ee:	30 80 00 
	return 0;
}
  8016f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f9:	5b                   	pop    %ebx
  8016fa:	5e                   	pop    %esi
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	53                   	push   %ebx
  801701:	83 ec 0c             	sub    $0xc,%esp
  801704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801707:	53                   	push   %ebx
  801708:	6a 00                	push   $0x0
  80170a:	e8 f2 f4 ff ff       	call   800c01 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80170f:	89 1c 24             	mov    %ebx,(%esp)
  801712:	e8 9d f7 ff ff       	call   800eb4 <fd2data>
  801717:	83 c4 08             	add    $0x8,%esp
  80171a:	50                   	push   %eax
  80171b:	6a 00                	push   $0x0
  80171d:	e8 df f4 ff ff       	call   800c01 <sys_page_unmap>
}
  801722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	57                   	push   %edi
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 1c             	sub    $0x1c,%esp
  801730:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801733:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801735:	a1 04 40 80 00       	mov    0x804004,%eax
  80173a:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	ff 75 e0             	pushl  -0x20(%ebp)
  801743:	e8 8c 04 00 00       	call   801bd4 <pageref>
  801748:	89 c3                	mov    %eax,%ebx
  80174a:	89 3c 24             	mov    %edi,(%esp)
  80174d:	e8 82 04 00 00       	call   801bd4 <pageref>
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	39 c3                	cmp    %eax,%ebx
  801757:	0f 94 c1             	sete   %cl
  80175a:	0f b6 c9             	movzbl %cl,%ecx
  80175d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801760:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801766:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801769:	39 ce                	cmp    %ecx,%esi
  80176b:	74 1b                	je     801788 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80176d:	39 c3                	cmp    %eax,%ebx
  80176f:	75 c4                	jne    801735 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801771:	8b 42 60             	mov    0x60(%edx),%eax
  801774:	ff 75 e4             	pushl  -0x1c(%ebp)
  801777:	50                   	push   %eax
  801778:	56                   	push   %esi
  801779:	68 0a 23 80 00       	push   $0x80230a
  80177e:	e8 71 ea ff ff       	call   8001f4 <cprintf>
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	eb ad                	jmp    801735 <_pipeisclosed+0xe>
	}
}
  801788:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80178b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178e:	5b                   	pop    %ebx
  80178f:	5e                   	pop    %esi
  801790:	5f                   	pop    %edi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	57                   	push   %edi
  801797:	56                   	push   %esi
  801798:	53                   	push   %ebx
  801799:	83 ec 28             	sub    $0x28,%esp
  80179c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80179f:	56                   	push   %esi
  8017a0:	e8 0f f7 ff ff       	call   800eb4 <fd2data>
  8017a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8017af:	eb 4b                	jmp    8017fc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017b1:	89 da                	mov    %ebx,%edx
  8017b3:	89 f0                	mov    %esi,%eax
  8017b5:	e8 6d ff ff ff       	call   801727 <_pipeisclosed>
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	75 48                	jne    801806 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017be:	e8 9a f3 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8017c6:	8b 0b                	mov    (%ebx),%ecx
  8017c8:	8d 51 20             	lea    0x20(%ecx),%edx
  8017cb:	39 d0                	cmp    %edx,%eax
  8017cd:	73 e2                	jae    8017b1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017d6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017d9:	89 c2                	mov    %eax,%edx
  8017db:	c1 fa 1f             	sar    $0x1f,%edx
  8017de:	89 d1                	mov    %edx,%ecx
  8017e0:	c1 e9 1b             	shr    $0x1b,%ecx
  8017e3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017e6:	83 e2 1f             	and    $0x1f,%edx
  8017e9:	29 ca                	sub    %ecx,%edx
  8017eb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017f3:	83 c0 01             	add    $0x1,%eax
  8017f6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f9:	83 c7 01             	add    $0x1,%edi
  8017fc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017ff:	75 c2                	jne    8017c3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801801:	8b 45 10             	mov    0x10(%ebp),%eax
  801804:	eb 05                	jmp    80180b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801806:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80180b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80180e:	5b                   	pop    %ebx
  80180f:	5e                   	pop    %esi
  801810:	5f                   	pop    %edi
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	57                   	push   %edi
  801817:	56                   	push   %esi
  801818:	53                   	push   %ebx
  801819:	83 ec 18             	sub    $0x18,%esp
  80181c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80181f:	57                   	push   %edi
  801820:	e8 8f f6 ff ff       	call   800eb4 <fd2data>
  801825:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80182f:	eb 3d                	jmp    80186e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801831:	85 db                	test   %ebx,%ebx
  801833:	74 04                	je     801839 <devpipe_read+0x26>
				return i;
  801835:	89 d8                	mov    %ebx,%eax
  801837:	eb 44                	jmp    80187d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801839:	89 f2                	mov    %esi,%edx
  80183b:	89 f8                	mov    %edi,%eax
  80183d:	e8 e5 fe ff ff       	call   801727 <_pipeisclosed>
  801842:	85 c0                	test   %eax,%eax
  801844:	75 32                	jne    801878 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801846:	e8 12 f3 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80184b:	8b 06                	mov    (%esi),%eax
  80184d:	3b 46 04             	cmp    0x4(%esi),%eax
  801850:	74 df                	je     801831 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801852:	99                   	cltd   
  801853:	c1 ea 1b             	shr    $0x1b,%edx
  801856:	01 d0                	add    %edx,%eax
  801858:	83 e0 1f             	and    $0x1f,%eax
  80185b:	29 d0                	sub    %edx,%eax
  80185d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801865:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801868:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80186b:	83 c3 01             	add    $0x1,%ebx
  80186e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801871:	75 d8                	jne    80184b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801873:	8b 45 10             	mov    0x10(%ebp),%eax
  801876:	eb 05                	jmp    80187d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801878:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80187d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801880:	5b                   	pop    %ebx
  801881:	5e                   	pop    %esi
  801882:	5f                   	pop    %edi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	56                   	push   %esi
  801889:	53                   	push   %ebx
  80188a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80188d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801890:	50                   	push   %eax
  801891:	e8 35 f6 ff ff       	call   800ecb <fd_alloc>
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	89 c2                	mov    %eax,%edx
  80189b:	85 c0                	test   %eax,%eax
  80189d:	0f 88 2c 01 00 00    	js     8019cf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a3:	83 ec 04             	sub    $0x4,%esp
  8018a6:	68 07 04 00 00       	push   $0x407
  8018ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ae:	6a 00                	push   $0x0
  8018b0:	e8 c7 f2 ff ff       	call   800b7c <sys_page_alloc>
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	89 c2                	mov    %eax,%edx
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	0f 88 0d 01 00 00    	js     8019cf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018c2:	83 ec 0c             	sub    $0xc,%esp
  8018c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c8:	50                   	push   %eax
  8018c9:	e8 fd f5 ff ff       	call   800ecb <fd_alloc>
  8018ce:	89 c3                	mov    %eax,%ebx
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	0f 88 e2 00 00 00    	js     8019bd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018db:	83 ec 04             	sub    $0x4,%esp
  8018de:	68 07 04 00 00       	push   $0x407
  8018e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e6:	6a 00                	push   $0x0
  8018e8:	e8 8f f2 ff ff       	call   800b7c <sys_page_alloc>
  8018ed:	89 c3                	mov    %eax,%ebx
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	0f 88 c3 00 00 00    	js     8019bd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801900:	e8 af f5 ff ff       	call   800eb4 <fd2data>
  801905:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801907:	83 c4 0c             	add    $0xc,%esp
  80190a:	68 07 04 00 00       	push   $0x407
  80190f:	50                   	push   %eax
  801910:	6a 00                	push   $0x0
  801912:	e8 65 f2 ff ff       	call   800b7c <sys_page_alloc>
  801917:	89 c3                	mov    %eax,%ebx
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	85 c0                	test   %eax,%eax
  80191e:	0f 88 89 00 00 00    	js     8019ad <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	ff 75 f0             	pushl  -0x10(%ebp)
  80192a:	e8 85 f5 ff ff       	call   800eb4 <fd2data>
  80192f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801936:	50                   	push   %eax
  801937:	6a 00                	push   $0x0
  801939:	56                   	push   %esi
  80193a:	6a 00                	push   $0x0
  80193c:	e8 7e f2 ff ff       	call   800bbf <sys_page_map>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	83 c4 20             	add    $0x20,%esp
  801946:	85 c0                	test   %eax,%eax
  801948:	78 55                	js     80199f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80194a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801953:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801955:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801958:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80195f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801965:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801968:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80196a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	ff 75 f4             	pushl  -0xc(%ebp)
  80197a:	e8 25 f5 ff ff       	call   800ea4 <fd2num>
  80197f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801982:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801984:	83 c4 04             	add    $0x4,%esp
  801987:	ff 75 f0             	pushl  -0x10(%ebp)
  80198a:	e8 15 f5 ff ff       	call   800ea4 <fd2num>
  80198f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801992:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	ba 00 00 00 00       	mov    $0x0,%edx
  80199d:	eb 30                	jmp    8019cf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80199f:	83 ec 08             	sub    $0x8,%esp
  8019a2:	56                   	push   %esi
  8019a3:	6a 00                	push   $0x0
  8019a5:	e8 57 f2 ff ff       	call   800c01 <sys_page_unmap>
  8019aa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019ad:	83 ec 08             	sub    $0x8,%esp
  8019b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b3:	6a 00                	push   $0x0
  8019b5:	e8 47 f2 ff ff       	call   800c01 <sys_page_unmap>
  8019ba:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019bd:	83 ec 08             	sub    $0x8,%esp
  8019c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 37 f2 ff ff       	call   800c01 <sys_page_unmap>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019cf:	89 d0                	mov    %edx,%eax
  8019d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e1:	50                   	push   %eax
  8019e2:	ff 75 08             	pushl  0x8(%ebp)
  8019e5:	e8 30 f5 ff ff       	call   800f1a <fd_lookup>
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	78 18                	js     801a09 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019f1:	83 ec 0c             	sub    $0xc,%esp
  8019f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f7:	e8 b8 f4 ff ff       	call   800eb4 <fd2data>
	return _pipeisclosed(fd, p);
  8019fc:	89 c2                	mov    %eax,%edx
  8019fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a01:	e8 21 fd ff ff       	call   801727 <_pipeisclosed>
  801a06:	83 c4 10             	add    $0x10,%esp
}
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a1b:	68 22 23 80 00       	push   $0x802322
  801a20:	ff 75 0c             	pushl  0xc(%ebp)
  801a23:	e8 51 ed ff ff       	call   800779 <strcpy>
	return 0;
}
  801a28:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	57                   	push   %edi
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a3b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a40:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a46:	eb 2d                	jmp    801a75 <devcons_write+0x46>
		m = n - tot;
  801a48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a4b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a4d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a50:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a55:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a58:	83 ec 04             	sub    $0x4,%esp
  801a5b:	53                   	push   %ebx
  801a5c:	03 45 0c             	add    0xc(%ebp),%eax
  801a5f:	50                   	push   %eax
  801a60:	57                   	push   %edi
  801a61:	e8 a5 ee ff ff       	call   80090b <memmove>
		sys_cputs(buf, m);
  801a66:	83 c4 08             	add    $0x8,%esp
  801a69:	53                   	push   %ebx
  801a6a:	57                   	push   %edi
  801a6b:	e8 50 f0 ff ff       	call   800ac0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a70:	01 de                	add    %ebx,%esi
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	89 f0                	mov    %esi,%eax
  801a77:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a7a:	72 cc                	jb     801a48 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 08             	sub    $0x8,%esp
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a93:	74 2a                	je     801abf <devcons_read+0x3b>
  801a95:	eb 05                	jmp    801a9c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a97:	e8 c1 f0 ff ff       	call   800b5d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a9c:	e8 3d f0 ff ff       	call   800ade <sys_cgetc>
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	74 f2                	je     801a97 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 16                	js     801abf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801aa9:	83 f8 04             	cmp    $0x4,%eax
  801aac:	74 0c                	je     801aba <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab1:	88 02                	mov    %al,(%edx)
	return 1;
  801ab3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab8:	eb 05                	jmp    801abf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aba:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    

00801ac1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801acd:	6a 01                	push   $0x1
  801acf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ad2:	50                   	push   %eax
  801ad3:	e8 e8 ef ff ff       	call   800ac0 <sys_cputs>
}
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <getchar>:

int
getchar(void)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ae3:	6a 01                	push   $0x1
  801ae5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ae8:	50                   	push   %eax
  801ae9:	6a 00                	push   $0x0
  801aeb:	e8 90 f6 ff ff       	call   801180 <read>
	if (r < 0)
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	78 0f                	js     801b06 <getchar+0x29>
		return r;
	if (r < 1)
  801af7:	85 c0                	test   %eax,%eax
  801af9:	7e 06                	jle    801b01 <getchar+0x24>
		return -E_EOF;
	return c;
  801afb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801aff:	eb 05                	jmp    801b06 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b01:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b11:	50                   	push   %eax
  801b12:	ff 75 08             	pushl  0x8(%ebp)
  801b15:	e8 00 f4 ff ff       	call   800f1a <fd_lookup>
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	78 11                	js     801b32 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b24:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b2a:	39 10                	cmp    %edx,(%eax)
  801b2c:	0f 94 c0             	sete   %al
  801b2f:	0f b6 c0             	movzbl %al,%eax
}
  801b32:	c9                   	leave  
  801b33:	c3                   	ret    

00801b34 <opencons>:

int
opencons(void)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3d:	50                   	push   %eax
  801b3e:	e8 88 f3 ff ff       	call   800ecb <fd_alloc>
  801b43:	83 c4 10             	add    $0x10,%esp
		return r;
  801b46:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	78 3e                	js     801b8a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b4c:	83 ec 04             	sub    $0x4,%esp
  801b4f:	68 07 04 00 00       	push   $0x407
  801b54:	ff 75 f4             	pushl  -0xc(%ebp)
  801b57:	6a 00                	push   $0x0
  801b59:	e8 1e f0 ff ff       	call   800b7c <sys_page_alloc>
  801b5e:	83 c4 10             	add    $0x10,%esp
		return r;
  801b61:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 23                	js     801b8a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b67:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b70:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b75:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b7c:	83 ec 0c             	sub    $0xc,%esp
  801b7f:	50                   	push   %eax
  801b80:	e8 1f f3 ff ff       	call   800ea4 <fd2num>
  801b85:	89 c2                	mov    %eax,%edx
  801b87:	83 c4 10             	add    $0x10,%esp
}
  801b8a:	89 d0                	mov    %edx,%eax
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b93:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b96:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b9c:	e8 9d ef ff ff       	call   800b3e <sys_getenvid>
  801ba1:	83 ec 0c             	sub    $0xc,%esp
  801ba4:	ff 75 0c             	pushl  0xc(%ebp)
  801ba7:	ff 75 08             	pushl  0x8(%ebp)
  801baa:	56                   	push   %esi
  801bab:	50                   	push   %eax
  801bac:	68 30 23 80 00       	push   $0x802330
  801bb1:	e8 3e e6 ff ff       	call   8001f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bb6:	83 c4 18             	add    $0x18,%esp
  801bb9:	53                   	push   %ebx
  801bba:	ff 75 10             	pushl  0x10(%ebp)
  801bbd:	e8 e1 e5 ff ff       	call   8001a3 <vcprintf>
	cprintf("\n");
  801bc2:	c7 04 24 1b 23 80 00 	movl   $0x80231b,(%esp)
  801bc9:	e8 26 e6 ff ff       	call   8001f4 <cprintf>
  801bce:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801bd1:	cc                   	int3   
  801bd2:	eb fd                	jmp    801bd1 <_panic+0x43>

00801bd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bda:	89 d0                	mov    %edx,%eax
  801bdc:	c1 e8 16             	shr    $0x16,%eax
  801bdf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801beb:	f6 c1 01             	test   $0x1,%cl
  801bee:	74 1d                	je     801c0d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bf0:	c1 ea 0c             	shr    $0xc,%edx
  801bf3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bfa:	f6 c2 01             	test   $0x1,%dl
  801bfd:	74 0e                	je     801c0d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bff:	c1 ea 0c             	shr    $0xc,%edx
  801c02:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c09:	ef 
  801c0a:	0f b7 c0             	movzwl %ax,%eax
}
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    
  801c0f:	90                   	nop

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
