
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 3f 0e 00 00       	call   800e80 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 0c 0b 00 00       	call   800b5b <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 40 22 80 00       	push   $0x802240
  800059:	e8 b3 01 00 00       	call   800211 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 9b 10 00 00       	call   801107 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 13 10 00 00       	call   801092 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 d2 0a 00 00       	call   800b5b <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 56 22 80 00       	push   $0x802256
  800091:	e8 7b 01 00 00       	call   800211 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 59 10 00 00       	call   801107 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000c7:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000ce:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000d1:	e8 85 0a 00 00       	call   800b5b <sys_getenvid>
  8000d6:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	50                   	push   %eax
  8000dc:	68 6c 22 80 00       	push   $0x80226c
  8000e1:	e8 2b 01 00 00       	call   800211 <cprintf>
  8000e6:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000ec:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000f9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8000fe:	89 c1                	mov    %eax,%ecx
  800100:	c1 e1 07             	shl    $0x7,%ecx
  800103:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80010a:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  80010d:	39 cb                	cmp    %ecx,%ebx
  80010f:	0f 44 fa             	cmove  %edx,%edi
  800112:	b9 01 00 00 00       	mov    $0x1,%ecx
  800117:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80011a:	83 c0 01             	add    $0x1,%eax
  80011d:	81 c2 84 00 00 00    	add    $0x84,%edx
  800123:	3d 00 04 00 00       	cmp    $0x400,%eax
  800128:	75 d4                	jne    8000fe <libmain+0x40>
  80012a:	89 f0                	mov    %esi,%eax
  80012c:	84 c0                	test   %al,%al
  80012e:	74 06                	je     800136 <libmain+0x78>
  800130:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80013a:	7e 0a                	jle    800146 <libmain+0x88>
		binaryname = argv[0];
  80013c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013f:	8b 00                	mov    (%eax),%eax
  800141:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800146:	83 ec 08             	sub    $0x8,%esp
  800149:	ff 75 0c             	pushl  0xc(%ebp)
  80014c:	ff 75 08             	pushl  0x8(%ebp)
  80014f:	e8 df fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800154:	e8 0b 00 00 00       	call   800164 <exit>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5f                   	pop    %edi
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80016a:	e8 05 12 00 00       	call   801374 <close_all>
	sys_env_destroy(0);
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	6a 00                	push   $0x0
  800174:	e8 a1 09 00 00       	call   800b1a <sys_env_destroy>
}
  800179:	83 c4 10             	add    $0x10,%esp
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    

0080017e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	53                   	push   %ebx
  800182:	83 ec 04             	sub    $0x4,%esp
  800185:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800188:	8b 13                	mov    (%ebx),%edx
  80018a:	8d 42 01             	lea    0x1(%edx),%eax
  80018d:	89 03                	mov    %eax,(%ebx)
  80018f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800192:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800196:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019b:	75 1a                	jne    8001b7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	68 ff 00 00 00       	push   $0xff
  8001a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 2f 09 00 00       	call   800add <sys_cputs>
		b->idx = 0;
  8001ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d0:	00 00 00 
	b.cnt = 0;
  8001d3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dd:	ff 75 0c             	pushl  0xc(%ebp)
  8001e0:	ff 75 08             	pushl  0x8(%ebp)
  8001e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e9:	50                   	push   %eax
  8001ea:	68 7e 01 80 00       	push   $0x80017e
  8001ef:	e8 54 01 00 00       	call   800348 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f4:	83 c4 08             	add    $0x8,%esp
  8001f7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800203:	50                   	push   %eax
  800204:	e8 d4 08 00 00       	call   800add <sys_cputs>

	return b.cnt;
}
  800209:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800217:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021a:	50                   	push   %eax
  80021b:	ff 75 08             	pushl  0x8(%ebp)
  80021e:	e8 9d ff ff ff       	call   8001c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 1c             	sub    $0x1c,%esp
  80022e:	89 c7                	mov    %eax,%edi
  800230:	89 d6                	mov    %edx,%esi
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	8b 55 0c             	mov    0xc(%ebp),%edx
  800238:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800241:	bb 00 00 00 00       	mov    $0x0,%ebx
  800246:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800249:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024c:	39 d3                	cmp    %edx,%ebx
  80024e:	72 05                	jb     800255 <printnum+0x30>
  800250:	39 45 10             	cmp    %eax,0x10(%ebp)
  800253:	77 45                	ja     80029a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	ff 75 18             	pushl  0x18(%ebp)
  80025b:	8b 45 14             	mov    0x14(%ebp),%eax
  80025e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026b:	ff 75 e0             	pushl  -0x20(%ebp)
  80026e:	ff 75 dc             	pushl  -0x24(%ebp)
  800271:	ff 75 d8             	pushl  -0x28(%ebp)
  800274:	e8 37 1d 00 00       	call   801fb0 <__udivdi3>
  800279:	83 c4 18             	add    $0x18,%esp
  80027c:	52                   	push   %edx
  80027d:	50                   	push   %eax
  80027e:	89 f2                	mov    %esi,%edx
  800280:	89 f8                	mov    %edi,%eax
  800282:	e8 9e ff ff ff       	call   800225 <printnum>
  800287:	83 c4 20             	add    $0x20,%esp
  80028a:	eb 18                	jmp    8002a4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	56                   	push   %esi
  800290:	ff 75 18             	pushl  0x18(%ebp)
  800293:	ff d7                	call   *%edi
  800295:	83 c4 10             	add    $0x10,%esp
  800298:	eb 03                	jmp    80029d <printnum+0x78>
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029d:	83 eb 01             	sub    $0x1,%ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f e8                	jg     80028c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	83 ec 04             	sub    $0x4,%esp
  8002ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b7:	e8 24 1e 00 00       	call   8020e0 <__umoddi3>
  8002bc:	83 c4 14             	add    $0x14,%esp
  8002bf:	0f be 80 95 22 80 00 	movsbl 0x802295(%eax),%eax
  8002c6:	50                   	push   %eax
  8002c7:	ff d7                	call   *%edi
}
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d7:	83 fa 01             	cmp    $0x1,%edx
  8002da:	7e 0e                	jle    8002ea <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	8b 52 04             	mov    0x4(%edx),%edx
  8002e8:	eb 22                	jmp    80030c <getuint+0x38>
	else if (lflag)
  8002ea:	85 d2                	test   %edx,%edx
  8002ec:	74 10                	je     8002fe <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fc:	eb 0e                	jmp    80030c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 04             	lea    0x4(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800314:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	3b 50 04             	cmp    0x4(%eax),%edx
  80031d:	73 0a                	jae    800329 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 45 08             	mov    0x8(%ebp),%eax
  800327:	88 02                	mov    %al,(%edx)
}
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800331:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800334:	50                   	push   %eax
  800335:	ff 75 10             	pushl  0x10(%ebp)
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	e8 05 00 00 00       	call   800348 <vprintfmt>
	va_end(ap);
}
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	57                   	push   %edi
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
  80034e:	83 ec 2c             	sub    $0x2c,%esp
  800351:	8b 75 08             	mov    0x8(%ebp),%esi
  800354:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800357:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035a:	eb 12                	jmp    80036e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035c:	85 c0                	test   %eax,%eax
  80035e:	0f 84 89 03 00 00    	je     8006ed <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	53                   	push   %ebx
  800368:	50                   	push   %eax
  800369:	ff d6                	call   *%esi
  80036b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036e:	83 c7 01             	add    $0x1,%edi
  800371:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800375:	83 f8 25             	cmp    $0x25,%eax
  800378:	75 e2                	jne    80035c <vprintfmt+0x14>
  80037a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80037e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800385:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800393:	ba 00 00 00 00       	mov    $0x0,%edx
  800398:	eb 07                	jmp    8003a1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8d 47 01             	lea    0x1(%edi),%eax
  8003a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a7:	0f b6 07             	movzbl (%edi),%eax
  8003aa:	0f b6 c8             	movzbl %al,%ecx
  8003ad:	83 e8 23             	sub    $0x23,%eax
  8003b0:	3c 55                	cmp    $0x55,%al
  8003b2:	0f 87 1a 03 00 00    	ja     8006d2 <vprintfmt+0x38a>
  8003b8:	0f b6 c0             	movzbl %al,%eax
  8003bb:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c9:	eb d6                	jmp    8003a1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003dd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e3:	83 fa 09             	cmp    $0x9,%edx
  8003e6:	77 39                	ja     800421 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003eb:	eb e9                	jmp    8003d6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fe:	eb 27                	jmp    800427 <vprintfmt+0xdf>
  800400:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040a:	0f 49 c8             	cmovns %eax,%ecx
  80040d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800413:	eb 8c                	jmp    8003a1 <vprintfmt+0x59>
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800418:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80041f:	eb 80                	jmp    8003a1 <vprintfmt+0x59>
  800421:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800424:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800427:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042b:	0f 89 70 ff ff ff    	jns    8003a1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800431:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800434:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800437:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043e:	e9 5e ff ff ff       	jmp    8003a1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800443:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800449:	e9 53 ff ff ff       	jmp    8003a1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 50 04             	lea    0x4(%eax),%edx
  800454:	89 55 14             	mov    %edx,0x14(%ebp)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	ff 30                	pushl  (%eax)
  80045d:	ff d6                	call   *%esi
			break;
  80045f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800465:	e9 04 ff ff ff       	jmp    80036e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	99                   	cltd   
  800476:	31 d0                	xor    %edx,%eax
  800478:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047a:	83 f8 0f             	cmp    $0xf,%eax
  80047d:	7f 0b                	jg     80048a <vprintfmt+0x142>
  80047f:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	75 18                	jne    8004a2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048a:	50                   	push   %eax
  80048b:	68 ad 22 80 00       	push   $0x8022ad
  800490:	53                   	push   %ebx
  800491:	56                   	push   %esi
  800492:	e8 94 fe ff ff       	call   80032b <printfmt>
  800497:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80049d:	e9 cc fe ff ff       	jmp    80036e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a2:	52                   	push   %edx
  8004a3:	68 05 27 80 00       	push   $0x802705
  8004a8:	53                   	push   %ebx
  8004a9:	56                   	push   %esi
  8004aa:	e8 7c fe ff ff       	call   80032b <printfmt>
  8004af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b5:	e9 b4 fe ff ff       	jmp    80036e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 50 04             	lea    0x4(%eax),%edx
  8004c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c5:	85 ff                	test   %edi,%edi
  8004c7:	b8 a6 22 80 00       	mov    $0x8022a6,%eax
  8004cc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d3:	0f 8e 94 00 00 00    	jle    80056d <vprintfmt+0x225>
  8004d9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004dd:	0f 84 98 00 00 00    	je     80057b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004e9:	57                   	push   %edi
  8004ea:	e8 86 02 00 00       	call   800775 <strnlen>
  8004ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f2:	29 c1                	sub    %eax,%ecx
  8004f4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800501:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800504:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	eb 0f                	jmp    800517 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	ff 75 e0             	pushl  -0x20(%ebp)
  80050f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ef 01             	sub    $0x1,%edi
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	85 ff                	test   %edi,%edi
  800519:	7f ed                	jg     800508 <vprintfmt+0x1c0>
  80051b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800521:	85 c9                	test   %ecx,%ecx
  800523:	b8 00 00 00 00       	mov    $0x0,%eax
  800528:	0f 49 c1             	cmovns %ecx,%eax
  80052b:	29 c1                	sub    %eax,%ecx
  80052d:	89 75 08             	mov    %esi,0x8(%ebp)
  800530:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800533:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800536:	89 cb                	mov    %ecx,%ebx
  800538:	eb 4d                	jmp    800587 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053e:	74 1b                	je     80055b <vprintfmt+0x213>
  800540:	0f be c0             	movsbl %al,%eax
  800543:	83 e8 20             	sub    $0x20,%eax
  800546:	83 f8 5e             	cmp    $0x5e,%eax
  800549:	76 10                	jbe    80055b <vprintfmt+0x213>
					putch('?', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	ff 75 0c             	pushl  0xc(%ebp)
  800551:	6a 3f                	push   $0x3f
  800553:	ff 55 08             	call   *0x8(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 0d                	jmp    800568 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	52                   	push   %edx
  800562:	ff 55 08             	call   *0x8(%ebp)
  800565:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800568:	83 eb 01             	sub    $0x1,%ebx
  80056b:	eb 1a                	jmp    800587 <vprintfmt+0x23f>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	eb 0c                	jmp    800587 <vprintfmt+0x23f>
  80057b:	89 75 08             	mov    %esi,0x8(%ebp)
  80057e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800581:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800584:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800587:	83 c7 01             	add    $0x1,%edi
  80058a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058e:	0f be d0             	movsbl %al,%edx
  800591:	85 d2                	test   %edx,%edx
  800593:	74 23                	je     8005b8 <vprintfmt+0x270>
  800595:	85 f6                	test   %esi,%esi
  800597:	78 a1                	js     80053a <vprintfmt+0x1f2>
  800599:	83 ee 01             	sub    $0x1,%esi
  80059c:	79 9c                	jns    80053a <vprintfmt+0x1f2>
  80059e:	89 df                	mov    %ebx,%edi
  8005a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a6:	eb 18                	jmp    8005c0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	6a 20                	push   $0x20
  8005ae:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b0:	83 ef 01             	sub    $0x1,%edi
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	eb 08                	jmp    8005c0 <vprintfmt+0x278>
  8005b8:	89 df                	mov    %ebx,%edi
  8005ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c0:	85 ff                	test   %edi,%edi
  8005c2:	7f e4                	jg     8005a8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c7:	e9 a2 fd ff ff       	jmp    80036e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cc:	83 fa 01             	cmp    $0x1,%edx
  8005cf:	7e 16                	jle    8005e7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 08             	lea    0x8(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 50 04             	mov    0x4(%eax),%edx
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e5:	eb 32                	jmp    800619 <vprintfmt+0x2d1>
	else if (lflag)
  8005e7:	85 d2                	test   %edx,%edx
  8005e9:	74 18                	je     800603 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 04             	lea    0x4(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	89 c1                	mov    %eax,%ecx
  8005fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800601:	eb 16                	jmp    800619 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	89 c1                	mov    %eax,%ecx
  800613:	c1 f9 1f             	sar    $0x1f,%ecx
  800616:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800619:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800624:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800628:	79 74                	jns    80069e <vprintfmt+0x356>
				putch('-', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 2d                	push   $0x2d
  800630:	ff d6                	call   *%esi
				num = -(long long) num;
  800632:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800635:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800638:	f7 d8                	neg    %eax
  80063a:	83 d2 00             	adc    $0x0,%edx
  80063d:	f7 da                	neg    %edx
  80063f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800642:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800647:	eb 55                	jmp    80069e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800649:	8d 45 14             	lea    0x14(%ebp),%eax
  80064c:	e8 83 fc ff ff       	call   8002d4 <getuint>
			base = 10;
  800651:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800656:	eb 46                	jmp    80069e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800658:	8d 45 14             	lea    0x14(%ebp),%eax
  80065b:	e8 74 fc ff ff       	call   8002d4 <getuint>
			base = 8;
  800660:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800665:	eb 37                	jmp    80069e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 30                	push   $0x30
  80066d:	ff d6                	call   *%esi
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 78                	push   $0x78
  800675:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 04             	lea    0x4(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800680:	8b 00                	mov    (%eax),%eax
  800682:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800687:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068f:	eb 0d                	jmp    80069e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800691:	8d 45 14             	lea    0x14(%ebp),%eax
  800694:	e8 3b fc ff ff       	call   8002d4 <getuint>
			base = 16;
  800699:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069e:	83 ec 0c             	sub    $0xc,%esp
  8006a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a5:	57                   	push   %edi
  8006a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a9:	51                   	push   %ecx
  8006aa:	52                   	push   %edx
  8006ab:	50                   	push   %eax
  8006ac:	89 da                	mov    %ebx,%edx
  8006ae:	89 f0                	mov    %esi,%eax
  8006b0:	e8 70 fb ff ff       	call   800225 <printnum>
			break;
  8006b5:	83 c4 20             	add    $0x20,%esp
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bb:	e9 ae fc ff ff       	jmp    80036e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	51                   	push   %ecx
  8006c5:	ff d6                	call   *%esi
			break;
  8006c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cd:	e9 9c fc ff ff       	jmp    80036e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 25                	push   $0x25
  8006d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 03                	jmp    8006e2 <vprintfmt+0x39a>
  8006df:	83 ef 01             	sub    $0x1,%edi
  8006e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e6:	75 f7                	jne    8006df <vprintfmt+0x397>
  8006e8:	e9 81 fc ff ff       	jmp    80036e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800712:	85 c0                	test   %eax,%eax
  800714:	74 26                	je     80073c <vsnprintf+0x47>
  800716:	85 d2                	test   %edx,%edx
  800718:	7e 22                	jle    80073c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071a:	ff 75 14             	pushl  0x14(%ebp)
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	68 0e 03 80 00       	push   $0x80030e
  800729:	e8 1a fc ff ff       	call   800348 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb 05                	jmp    800741 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800741:	c9                   	leave  
  800742:	c3                   	ret    

00800743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074c:	50                   	push   %eax
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	ff 75 08             	pushl  0x8(%ebp)
  800756:	e8 9a ff ff ff       	call   8006f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	eb 03                	jmp    80076d <strlen+0x10>
		n++;
  80076a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800771:	75 f7                	jne    80076a <strlen+0xd>
		n++;
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	ba 00 00 00 00       	mov    $0x0,%edx
  800783:	eb 03                	jmp    800788 <strnlen+0x13>
		n++;
  800785:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800788:	39 c2                	cmp    %eax,%edx
  80078a:	74 08                	je     800794 <strnlen+0x1f>
  80078c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800790:	75 f3                	jne    800785 <strnlen+0x10>
  800792:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	83 c2 01             	add    $0x1,%edx
  8007a5:	83 c1 01             	add    $0x1,%ecx
  8007a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007af:	84 db                	test   %bl,%bl
  8007b1:	75 ef                	jne    8007a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b3:	5b                   	pop    %ebx
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bd:	53                   	push   %ebx
  8007be:	e8 9a ff ff ff       	call   80075d <strlen>
  8007c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c6:	ff 75 0c             	pushl  0xc(%ebp)
  8007c9:	01 d8                	add    %ebx,%eax
  8007cb:	50                   	push   %eax
  8007cc:	e8 c5 ff ff ff       	call   800796 <strcpy>
	return dst;
}
  8007d1:	89 d8                	mov    %ebx,%eax
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	56                   	push   %esi
  8007dc:	53                   	push   %ebx
  8007dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e3:	89 f3                	mov    %esi,%ebx
  8007e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	89 f2                	mov    %esi,%edx
  8007ea:	eb 0f                	jmp    8007fb <strncpy+0x23>
		*dst++ = *src;
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	0f b6 01             	movzbl (%ecx),%eax
  8007f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	39 da                	cmp    %ebx,%edx
  8007fd:	75 ed                	jne    8007ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ff:	89 f0                	mov    %esi,%eax
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	8b 75 08             	mov    0x8(%ebp),%esi
  80080d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800810:	8b 55 10             	mov    0x10(%ebp),%edx
  800813:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800815:	85 d2                	test   %edx,%edx
  800817:	74 21                	je     80083a <strlcpy+0x35>
  800819:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081d:	89 f2                	mov    %esi,%edx
  80081f:	eb 09                	jmp    80082a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800821:	83 c2 01             	add    $0x1,%edx
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082a:	39 c2                	cmp    %eax,%edx
  80082c:	74 09                	je     800837 <strlcpy+0x32>
  80082e:	0f b6 19             	movzbl (%ecx),%ebx
  800831:	84 db                	test   %bl,%bl
  800833:	75 ec                	jne    800821 <strlcpy+0x1c>
  800835:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800837:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083a:	29 f0                	sub    %esi,%eax
}
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800849:	eb 06                	jmp    800851 <strcmp+0x11>
		p++, q++;
  80084b:	83 c1 01             	add    $0x1,%ecx
  80084e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800851:	0f b6 01             	movzbl (%ecx),%eax
  800854:	84 c0                	test   %al,%al
  800856:	74 04                	je     80085c <strcmp+0x1c>
  800858:	3a 02                	cmp    (%edx),%al
  80085a:	74 ef                	je     80084b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085c:	0f b6 c0             	movzbl %al,%eax
  80085f:	0f b6 12             	movzbl (%edx),%edx
  800862:	29 d0                	sub    %edx,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800870:	89 c3                	mov    %eax,%ebx
  800872:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800875:	eb 06                	jmp    80087d <strncmp+0x17>
		n--, p++, q++;
  800877:	83 c0 01             	add    $0x1,%eax
  80087a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087d:	39 d8                	cmp    %ebx,%eax
  80087f:	74 15                	je     800896 <strncmp+0x30>
  800881:	0f b6 08             	movzbl (%eax),%ecx
  800884:	84 c9                	test   %cl,%cl
  800886:	74 04                	je     80088c <strncmp+0x26>
  800888:	3a 0a                	cmp    (%edx),%cl
  80088a:	74 eb                	je     800877 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 00             	movzbl (%eax),%eax
  80088f:	0f b6 12             	movzbl (%edx),%edx
  800892:	29 d0                	sub    %edx,%eax
  800894:	eb 05                	jmp    80089b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089b:	5b                   	pop    %ebx
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a8:	eb 07                	jmp    8008b1 <strchr+0x13>
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 0f                	je     8008bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	0f b6 10             	movzbl (%eax),%edx
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	75 f2                	jne    8008aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c9:	eb 03                	jmp    8008ce <strfind+0xf>
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 04                	je     8008d9 <strfind+0x1a>
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	75 f2                	jne    8008cb <strfind+0xc>
			break;
	return (char *) s;
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	57                   	push   %edi
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e7:	85 c9                	test   %ecx,%ecx
  8008e9:	74 36                	je     800921 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f1:	75 28                	jne    80091b <memset+0x40>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 23                	jne    80091b <memset+0x40>
		c &= 0xFF;
  8008f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fc:	89 d3                	mov    %edx,%ebx
  8008fe:	c1 e3 08             	shl    $0x8,%ebx
  800901:	89 d6                	mov    %edx,%esi
  800903:	c1 e6 18             	shl    $0x18,%esi
  800906:	89 d0                	mov    %edx,%eax
  800908:	c1 e0 10             	shl    $0x10,%eax
  80090b:	09 f0                	or     %esi,%eax
  80090d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090f:	89 d8                	mov    %ebx,%eax
  800911:	09 d0                	or     %edx,%eax
  800913:	c1 e9 02             	shr    $0x2,%ecx
  800916:	fc                   	cld    
  800917:	f3 ab                	rep stos %eax,%es:(%edi)
  800919:	eb 06                	jmp    800921 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800936:	39 c6                	cmp    %eax,%esi
  800938:	73 35                	jae    80096f <memmove+0x47>
  80093a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093d:	39 d0                	cmp    %edx,%eax
  80093f:	73 2e                	jae    80096f <memmove+0x47>
		s += n;
		d += n;
  800941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	89 d6                	mov    %edx,%esi
  800946:	09 fe                	or     %edi,%esi
  800948:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094e:	75 13                	jne    800963 <memmove+0x3b>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 0e                	jne    800963 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800955:	83 ef 04             	sub    $0x4,%edi
  800958:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095b:	c1 e9 02             	shr    $0x2,%ecx
  80095e:	fd                   	std    
  80095f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800961:	eb 09                	jmp    80096c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800963:	83 ef 01             	sub    $0x1,%edi
  800966:	8d 72 ff             	lea    -0x1(%edx),%esi
  800969:	fd                   	std    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096c:	fc                   	cld    
  80096d:	eb 1d                	jmp    80098c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	89 f2                	mov    %esi,%edx
  800971:	09 c2                	or     %eax,%edx
  800973:	f6 c2 03             	test   $0x3,%dl
  800976:	75 0f                	jne    800987 <memmove+0x5f>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 0a                	jne    800987 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	89 c7                	mov    %eax,%edi
  800982:	fc                   	cld    
  800983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800985:	eb 05                	jmp    80098c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800987:	89 c7                	mov    %eax,%edi
  800989:	fc                   	cld    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800993:	ff 75 10             	pushl  0x10(%ebp)
  800996:	ff 75 0c             	pushl  0xc(%ebp)
  800999:	ff 75 08             	pushl  0x8(%ebp)
  80099c:	e8 87 ff ff ff       	call   800928 <memmove>
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ae:	89 c6                	mov    %eax,%esi
  8009b0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	eb 1a                	jmp    8009cf <memcmp+0x2c>
		if (*s1 != *s2)
  8009b5:	0f b6 08             	movzbl (%eax),%ecx
  8009b8:	0f b6 1a             	movzbl (%edx),%ebx
  8009bb:	38 d9                	cmp    %bl,%cl
  8009bd:	74 0a                	je     8009c9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bf:	0f b6 c1             	movzbl %cl,%eax
  8009c2:	0f b6 db             	movzbl %bl,%ebx
  8009c5:	29 d8                	sub    %ebx,%eax
  8009c7:	eb 0f                	jmp    8009d8 <memcmp+0x35>
		s1++, s2++;
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cf:	39 f0                	cmp    %esi,%eax
  8009d1:	75 e2                	jne    8009b5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	53                   	push   %ebx
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e3:	89 c1                	mov    %eax,%ecx
  8009e5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ec:	eb 0a                	jmp    8009f8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ee:	0f b6 10             	movzbl (%eax),%edx
  8009f1:	39 da                	cmp    %ebx,%edx
  8009f3:	74 07                	je     8009fc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	39 c8                	cmp    %ecx,%eax
  8009fa:	72 f2                	jb     8009ee <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0b:	eb 03                	jmp    800a10 <strtol+0x11>
		s++;
  800a0d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a10:	0f b6 01             	movzbl (%ecx),%eax
  800a13:	3c 20                	cmp    $0x20,%al
  800a15:	74 f6                	je     800a0d <strtol+0xe>
  800a17:	3c 09                	cmp    $0x9,%al
  800a19:	74 f2                	je     800a0d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1b:	3c 2b                	cmp    $0x2b,%al
  800a1d:	75 0a                	jne    800a29 <strtol+0x2a>
		s++;
  800a1f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a22:	bf 00 00 00 00       	mov    $0x0,%edi
  800a27:	eb 11                	jmp    800a3a <strtol+0x3b>
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2e:	3c 2d                	cmp    $0x2d,%al
  800a30:	75 08                	jne    800a3a <strtol+0x3b>
		s++, neg = 1;
  800a32:	83 c1 01             	add    $0x1,%ecx
  800a35:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a40:	75 15                	jne    800a57 <strtol+0x58>
  800a42:	80 39 30             	cmpb   $0x30,(%ecx)
  800a45:	75 10                	jne    800a57 <strtol+0x58>
  800a47:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4b:	75 7c                	jne    800ac9 <strtol+0xca>
		s += 2, base = 16;
  800a4d:	83 c1 02             	add    $0x2,%ecx
  800a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a55:	eb 16                	jmp    800a6d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a57:	85 db                	test   %ebx,%ebx
  800a59:	75 12                	jne    800a6d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a60:	80 39 30             	cmpb   $0x30,(%ecx)
  800a63:	75 08                	jne    800a6d <strtol+0x6e>
		s++, base = 8;
  800a65:	83 c1 01             	add    $0x1,%ecx
  800a68:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a75:	0f b6 11             	movzbl (%ecx),%edx
  800a78:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7b:	89 f3                	mov    %esi,%ebx
  800a7d:	80 fb 09             	cmp    $0x9,%bl
  800a80:	77 08                	ja     800a8a <strtol+0x8b>
			dig = *s - '0';
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 30             	sub    $0x30,%edx
  800a88:	eb 22                	jmp    800aac <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 19             	cmp    $0x19,%bl
  800a92:	77 08                	ja     800a9c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a94:	0f be d2             	movsbl %dl,%edx
  800a97:	83 ea 57             	sub    $0x57,%edx
  800a9a:	eb 10                	jmp    800aac <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 16                	ja     800abc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aac:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaf:	7d 0b                	jge    800abc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aba:	eb b9                	jmp    800a75 <strtol+0x76>

	if (endptr)
  800abc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac0:	74 0d                	je     800acf <strtol+0xd0>
		*endptr = (char *) s;
  800ac2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac5:	89 0e                	mov    %ecx,(%esi)
  800ac7:	eb 06                	jmp    800acf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	74 98                	je     800a65 <strtol+0x66>
  800acd:	eb 9e                	jmp    800a6d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	f7 da                	neg    %edx
  800ad3:	85 ff                	test   %edi,%edi
  800ad5:	0f 45 c2             	cmovne %edx,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	89 c3                	mov    %eax,%ebx
  800af0:	89 c7                	mov    %eax,%edi
  800af2:	89 c6                	mov    %eax,%esi
  800af4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_cgetc>:

int
sys_cgetc(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
  800b20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b28:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	89 cb                	mov    %ecx,%ebx
  800b32:	89 cf                	mov    %ecx,%edi
  800b34:	89 ce                	mov    %ecx,%esi
  800b36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	7e 17                	jle    800b53 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3c:	83 ec 0c             	sub    $0xc,%esp
  800b3f:	50                   	push   %eax
  800b40:	6a 03                	push   $0x3
  800b42:	68 9f 25 80 00       	push   $0x80259f
  800b47:	6a 23                	push   $0x23
  800b49:	68 bc 25 80 00       	push   $0x8025bc
  800b4e:	e8 40 13 00 00       	call   801e93 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_yield>:

void
sys_yield(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	be 00 00 00 00       	mov    $0x0,%esi
  800ba7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb5:	89 f7                	mov    %esi,%edi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 04                	push   $0x4
  800bc3:	68 9f 25 80 00       	push   $0x80259f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 bc 25 80 00       	push   $0x8025bc
  800bcf:	e8 bf 12 00 00       	call   801e93 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800be5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf6:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 05                	push   $0x5
  800c05:	68 9f 25 80 00       	push   $0x80259f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 bc 25 80 00       	push   $0x8025bc
  800c11:	e8 7d 12 00 00       	call   801e93 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c2c:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c3f:	7e 17                	jle    800c58 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 06                	push   $0x6
  800c47:	68 9f 25 80 00       	push   $0x80259f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 bc 25 80 00       	push   $0x8025bc
  800c53:	e8 3b 12 00 00       	call   801e93 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c6e:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c81:	7e 17                	jle    800c9a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 08                	push   $0x8
  800c89:	68 9f 25 80 00       	push   $0x80259f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 bc 25 80 00       	push   $0x8025bc
  800c95:	e8 f9 11 00 00       	call   801e93 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800cb0:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800cc3:	7e 17                	jle    800cdc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 09                	push   $0x9
  800ccb:	68 9f 25 80 00       	push   $0x80259f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 bc 25 80 00       	push   $0x8025bc
  800cd7:	e8 b7 11 00 00       	call   801e93 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 0a                	push   $0xa
  800d0d:	68 9f 25 80 00       	push   $0x80259f
  800d12:	6a 23                	push   $0x23
  800d14:	68 bc 25 80 00       	push   $0x8025bc
  800d19:	e8 75 11 00 00       	call   801e93 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	be 00 00 00 00       	mov    $0x0,%esi
  800d31:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d42:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 cb                	mov    %ecx,%ebx
  800d61:	89 cf                	mov    %ecx,%edi
  800d63:	89 ce                	mov    %ecx,%esi
  800d65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 0d                	push   $0xd
  800d71:	68 9f 25 80 00       	push   $0x80259f
  800d76:	6a 23                	push   $0x23
  800d78:	68 bc 25 80 00       	push   $0x8025bc
  800d7d:	e8 11 11 00 00       	call   801e93 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 cb                	mov    %ecx,%ebx
  800d9f:	89 cf                	mov    %ecx,%edi
  800da1:	89 ce                	mov    %ecx,%esi
  800da3:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	53                   	push   %ebx
  800dae:	83 ec 04             	sub    $0x4,%esp
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800db6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dba:	74 11                	je     800dcd <pgfault+0x23>
  800dbc:	89 d8                	mov    %ebx,%eax
  800dbe:	c1 e8 0c             	shr    $0xc,%eax
  800dc1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dc8:	f6 c4 08             	test   $0x8,%ah
  800dcb:	75 14                	jne    800de1 <pgfault+0x37>
		panic("faulting access");
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	68 ca 25 80 00       	push   $0x8025ca
  800dd5:	6a 1d                	push   $0x1d
  800dd7:	68 da 25 80 00       	push   $0x8025da
  800ddc:	e8 b2 10 00 00       	call   801e93 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800de1:	83 ec 04             	sub    $0x4,%esp
  800de4:	6a 07                	push   $0x7
  800de6:	68 00 f0 7f 00       	push   $0x7ff000
  800deb:	6a 00                	push   $0x0
  800ded:	e8 a7 fd ff ff       	call   800b99 <sys_page_alloc>
	if (r < 0) {
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	85 c0                	test   %eax,%eax
  800df7:	79 12                	jns    800e0b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800df9:	50                   	push   %eax
  800dfa:	68 e5 25 80 00       	push   $0x8025e5
  800dff:	6a 2b                	push   $0x2b
  800e01:	68 da 25 80 00       	push   $0x8025da
  800e06:	e8 88 10 00 00       	call   801e93 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e0b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	68 00 10 00 00       	push   $0x1000
  800e19:	53                   	push   %ebx
  800e1a:	68 00 f0 7f 00       	push   $0x7ff000
  800e1f:	e8 6c fb ff ff       	call   800990 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e24:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e2b:	53                   	push   %ebx
  800e2c:	6a 00                	push   $0x0
  800e2e:	68 00 f0 7f 00       	push   $0x7ff000
  800e33:	6a 00                	push   $0x0
  800e35:	e8 a2 fd ff ff       	call   800bdc <sys_page_map>
	if (r < 0) {
  800e3a:	83 c4 20             	add    $0x20,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	79 12                	jns    800e53 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e41:	50                   	push   %eax
  800e42:	68 e5 25 80 00       	push   $0x8025e5
  800e47:	6a 32                	push   $0x32
  800e49:	68 da 25 80 00       	push   $0x8025da
  800e4e:	e8 40 10 00 00       	call   801e93 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	68 00 f0 7f 00       	push   $0x7ff000
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 bc fd ff ff       	call   800c1e <sys_page_unmap>
	if (r < 0) {
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	79 12                	jns    800e7b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e69:	50                   	push   %eax
  800e6a:	68 e5 25 80 00       	push   $0x8025e5
  800e6f:	6a 36                	push   $0x36
  800e71:	68 da 25 80 00       	push   $0x8025da
  800e76:	e8 18 10 00 00       	call   801e93 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e89:	68 aa 0d 80 00       	push   $0x800daa
  800e8e:	e8 46 10 00 00       	call   801ed9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e93:	b8 07 00 00 00       	mov    $0x7,%eax
  800e98:	cd 30                	int    $0x30
  800e9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	79 17                	jns    800ebb <fork+0x3b>
		panic("fork fault %e");
  800ea4:	83 ec 04             	sub    $0x4,%esp
  800ea7:	68 fe 25 80 00       	push   $0x8025fe
  800eac:	68 83 00 00 00       	push   $0x83
  800eb1:	68 da 25 80 00       	push   $0x8025da
  800eb6:	e8 d8 0f 00 00       	call   801e93 <_panic>
  800ebb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ebd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec1:	75 25                	jne    800ee8 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec3:	e8 93 fc ff ff       	call   800b5b <sys_getenvid>
  800ec8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ecd:	89 c2                	mov    %eax,%edx
  800ecf:	c1 e2 07             	shl    $0x7,%edx
  800ed2:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800ed9:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	e9 61 01 00 00       	jmp    801049 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ee8:	83 ec 04             	sub    $0x4,%esp
  800eeb:	6a 07                	push   $0x7
  800eed:	68 00 f0 bf ee       	push   $0xeebff000
  800ef2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef5:	e8 9f fc ff ff       	call   800b99 <sys_page_alloc>
  800efa:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800efd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f02:	89 d8                	mov    %ebx,%eax
  800f04:	c1 e8 16             	shr    $0x16,%eax
  800f07:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f0e:	a8 01                	test   $0x1,%al
  800f10:	0f 84 fc 00 00 00    	je     801012 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f16:	89 d8                	mov    %ebx,%eax
  800f18:	c1 e8 0c             	shr    $0xc,%eax
  800f1b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f22:	f6 c2 01             	test   $0x1,%dl
  800f25:	0f 84 e7 00 00 00    	je     801012 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f2b:	89 c6                	mov    %eax,%esi
  800f2d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f30:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f37:	f6 c6 04             	test   $0x4,%dh
  800f3a:	74 39                	je     800f75 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f3c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	25 07 0e 00 00       	and    $0xe07,%eax
  800f4b:	50                   	push   %eax
  800f4c:	56                   	push   %esi
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	6a 00                	push   $0x0
  800f51:	e8 86 fc ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  800f56:	83 c4 20             	add    $0x20,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	0f 89 b1 00 00 00    	jns    801012 <fork+0x192>
		    	panic("sys page map fault %e");
  800f61:	83 ec 04             	sub    $0x4,%esp
  800f64:	68 0c 26 80 00       	push   $0x80260c
  800f69:	6a 53                	push   $0x53
  800f6b:	68 da 25 80 00       	push   $0x8025da
  800f70:	e8 1e 0f 00 00       	call   801e93 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f75:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f7c:	f6 c2 02             	test   $0x2,%dl
  800f7f:	75 0c                	jne    800f8d <fork+0x10d>
  800f81:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f88:	f6 c4 08             	test   $0x8,%ah
  800f8b:	74 5b                	je     800fe8 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	68 05 08 00 00       	push   $0x805
  800f95:	56                   	push   %esi
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	6a 00                	push   $0x0
  800f9a:	e8 3d fc ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  800f9f:	83 c4 20             	add    $0x20,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	79 14                	jns    800fba <fork+0x13a>
		    	panic("sys page map fault %e");
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	68 0c 26 80 00       	push   $0x80260c
  800fae:	6a 5a                	push   $0x5a
  800fb0:	68 da 25 80 00       	push   $0x8025da
  800fb5:	e8 d9 0e 00 00       	call   801e93 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	68 05 08 00 00       	push   $0x805
  800fc2:	56                   	push   %esi
  800fc3:	6a 00                	push   $0x0
  800fc5:	56                   	push   %esi
  800fc6:	6a 00                	push   $0x0
  800fc8:	e8 0f fc ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  800fcd:	83 c4 20             	add    $0x20,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 3e                	jns    801012 <fork+0x192>
		    	panic("sys page map fault %e");
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	68 0c 26 80 00       	push   $0x80260c
  800fdc:	6a 5e                	push   $0x5e
  800fde:	68 da 25 80 00       	push   $0x8025da
  800fe3:	e8 ab 0e 00 00       	call   801e93 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	6a 05                	push   $0x5
  800fed:	56                   	push   %esi
  800fee:	57                   	push   %edi
  800fef:	56                   	push   %esi
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 e5 fb ff ff       	call   800bdc <sys_page_map>
		if (r < 0) {
  800ff7:	83 c4 20             	add    $0x20,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	79 14                	jns    801012 <fork+0x192>
		    	panic("sys page map fault %e");
  800ffe:	83 ec 04             	sub    $0x4,%esp
  801001:	68 0c 26 80 00       	push   $0x80260c
  801006:	6a 63                	push   $0x63
  801008:	68 da 25 80 00       	push   $0x8025da
  80100d:	e8 81 0e 00 00       	call   801e93 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801012:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801018:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80101e:	0f 85 de fe ff ff    	jne    800f02 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801024:	a1 04 40 80 00       	mov    0x804004,%eax
  801029:	8b 40 6c             	mov    0x6c(%eax),%eax
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	50                   	push   %eax
  801030:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801033:	57                   	push   %edi
  801034:	e8 ab fc ff ff       	call   800ce4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	6a 02                	push   $0x2
  80103e:	57                   	push   %edi
  80103f:	e8 1c fc ff ff       	call   800c60 <sys_env_set_status>
	
	return envid;
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <sfork>:

envid_t
sfork(void)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801054:	b8 00 00 00 00       	mov    $0x0,%eax
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	53                   	push   %ebx
  801067:	68 24 26 80 00       	push   $0x802624
  80106c:	e8 a0 f1 ff ff       	call   800211 <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  801071:	89 1c 24             	mov    %ebx,(%esp)
  801074:	e8 11 fd ff ff       	call   800d8a <sys_thread_create>
  801079:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80107b:	83 c4 08             	add    $0x8,%esp
  80107e:	53                   	push   %ebx
  80107f:	68 24 26 80 00       	push   $0x802624
  801084:	e8 88 f1 ff ff       	call   800211 <cprintf>
	return id;
}
  801089:	89 f0                	mov    %esi,%eax
  80108b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	8b 75 08             	mov    0x8(%ebp),%esi
  80109a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80109d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	75 12                	jne    8010b6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	68 00 00 c0 ee       	push   $0xeec00000
  8010ac:	e8 98 fc ff ff       	call   800d49 <sys_ipc_recv>
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	eb 0c                	jmp    8010c2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	50                   	push   %eax
  8010ba:	e8 8a fc ff ff       	call   800d49 <sys_ipc_recv>
  8010bf:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8010c2:	85 f6                	test   %esi,%esi
  8010c4:	0f 95 c1             	setne  %cl
  8010c7:	85 db                	test   %ebx,%ebx
  8010c9:	0f 95 c2             	setne  %dl
  8010cc:	84 d1                	test   %dl,%cl
  8010ce:	74 09                	je     8010d9 <ipc_recv+0x47>
  8010d0:	89 c2                	mov    %eax,%edx
  8010d2:	c1 ea 1f             	shr    $0x1f,%edx
  8010d5:	84 d2                	test   %dl,%dl
  8010d7:	75 27                	jne    801100 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8010d9:	85 f6                	test   %esi,%esi
  8010db:	74 0a                	je     8010e7 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  8010dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e2:	8b 40 7c             	mov    0x7c(%eax),%eax
  8010e5:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8010e7:	85 db                	test   %ebx,%ebx
  8010e9:	74 0d                	je     8010f8 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  8010eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8010f6:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8010f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fd:	8b 40 78             	mov    0x78(%eax),%eax
}
  801100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801103:	5b                   	pop    %ebx
  801104:	5e                   	pop    %esi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	8b 7d 08             	mov    0x8(%ebp),%edi
  801113:	8b 75 0c             	mov    0xc(%ebp),%esi
  801116:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801119:	85 db                	test   %ebx,%ebx
  80111b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801120:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801123:	ff 75 14             	pushl  0x14(%ebp)
  801126:	53                   	push   %ebx
  801127:	56                   	push   %esi
  801128:	57                   	push   %edi
  801129:	e8 f8 fb ff ff       	call   800d26 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80112e:	89 c2                	mov    %eax,%edx
  801130:	c1 ea 1f             	shr    $0x1f,%edx
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	84 d2                	test   %dl,%dl
  801138:	74 17                	je     801151 <ipc_send+0x4a>
  80113a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80113d:	74 12                	je     801151 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80113f:	50                   	push   %eax
  801140:	68 47 26 80 00       	push   $0x802647
  801145:	6a 47                	push   $0x47
  801147:	68 55 26 80 00       	push   $0x802655
  80114c:	e8 42 0d 00 00       	call   801e93 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801151:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801154:	75 07                	jne    80115d <ipc_send+0x56>
			sys_yield();
  801156:	e8 1f fa ff ff       	call   800b7a <sys_yield>
  80115b:	eb c6                	jmp    801123 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80115d:	85 c0                	test   %eax,%eax
  80115f:	75 c2                	jne    801123 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801161:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80116f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801174:	89 c2                	mov    %eax,%edx
  801176:	c1 e2 07             	shl    $0x7,%edx
  801179:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801180:	8b 52 58             	mov    0x58(%edx),%edx
  801183:	39 ca                	cmp    %ecx,%edx
  801185:	75 11                	jne    801198 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801187:	89 c2                	mov    %eax,%edx
  801189:	c1 e2 07             	shl    $0x7,%edx
  80118c:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801193:	8b 40 50             	mov    0x50(%eax),%eax
  801196:	eb 0f                	jmp    8011a7 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801198:	83 c0 01             	add    $0x1,%eax
  80119b:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011a0:	75 d2                	jne    801174 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8011af:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b4:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bf:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011c9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	c1 ea 16             	shr    $0x16,%edx
  8011e0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e7:	f6 c2 01             	test   $0x1,%dl
  8011ea:	74 11                	je     8011fd <fd_alloc+0x2d>
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	c1 ea 0c             	shr    $0xc,%edx
  8011f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f8:	f6 c2 01             	test   $0x1,%dl
  8011fb:	75 09                	jne    801206 <fd_alloc+0x36>
			*fd_store = fd;
  8011fd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801204:	eb 17                	jmp    80121d <fd_alloc+0x4d>
  801206:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80120b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801210:	75 c9                	jne    8011db <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801212:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801218:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801225:	83 f8 1f             	cmp    $0x1f,%eax
  801228:	77 36                	ja     801260 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80122a:	c1 e0 0c             	shl    $0xc,%eax
  80122d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 16             	shr    $0x16,%edx
  801237:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123e:	f6 c2 01             	test   $0x1,%dl
  801241:	74 24                	je     801267 <fd_lookup+0x48>
  801243:	89 c2                	mov    %eax,%edx
  801245:	c1 ea 0c             	shr    $0xc,%edx
  801248:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124f:	f6 c2 01             	test   $0x1,%dl
  801252:	74 1a                	je     80126e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801254:	8b 55 0c             	mov    0xc(%ebp),%edx
  801257:	89 02                	mov    %eax,(%edx)
	return 0;
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
  80125e:	eb 13                	jmp    801273 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801260:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801265:	eb 0c                	jmp    801273 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801267:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126c:	eb 05                	jmp    801273 <fd_lookup+0x54>
  80126e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127e:	ba dc 26 80 00       	mov    $0x8026dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801283:	eb 13                	jmp    801298 <dev_lookup+0x23>
  801285:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801288:	39 08                	cmp    %ecx,(%eax)
  80128a:	75 0c                	jne    801298 <dev_lookup+0x23>
			*dev = devtab[i];
  80128c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	eb 2e                	jmp    8012c6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801298:	8b 02                	mov    (%edx),%eax
  80129a:	85 c0                	test   %eax,%eax
  80129c:	75 e7                	jne    801285 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80129e:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a3:	8b 40 50             	mov    0x50(%eax),%eax
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	51                   	push   %ecx
  8012aa:	50                   	push   %eax
  8012ab:	68 60 26 80 00       	push   $0x802660
  8012b0:	e8 5c ef ff ff       	call   800211 <cprintf>
	*dev = 0;
  8012b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012c6:	c9                   	leave  
  8012c7:	c3                   	ret    

008012c8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	56                   	push   %esi
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 10             	sub    $0x10,%esp
  8012d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d9:	50                   	push   %eax
  8012da:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e0:	c1 e8 0c             	shr    $0xc,%eax
  8012e3:	50                   	push   %eax
  8012e4:	e8 36 ff ff ff       	call   80121f <fd_lookup>
  8012e9:	83 c4 08             	add    $0x8,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 05                	js     8012f5 <fd_close+0x2d>
	    || fd != fd2)
  8012f0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012f3:	74 0c                	je     801301 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012f5:	84 db                	test   %bl,%bl
  8012f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fc:	0f 44 c2             	cmove  %edx,%eax
  8012ff:	eb 41                	jmp    801342 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	ff 36                	pushl  (%esi)
  80130a:	e8 66 ff ff ff       	call   801275 <dev_lookup>
  80130f:	89 c3                	mov    %eax,%ebx
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	78 1a                	js     801332 <fd_close+0x6a>
		if (dev->dev_close)
  801318:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80131e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801323:	85 c0                	test   %eax,%eax
  801325:	74 0b                	je     801332 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	56                   	push   %esi
  80132b:	ff d0                	call   *%eax
  80132d:	89 c3                	mov    %eax,%ebx
  80132f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801332:	83 ec 08             	sub    $0x8,%esp
  801335:	56                   	push   %esi
  801336:	6a 00                	push   $0x0
  801338:	e8 e1 f8 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	89 d8                	mov    %ebx,%eax
}
  801342:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801345:	5b                   	pop    %ebx
  801346:	5e                   	pop    %esi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 75 08             	pushl  0x8(%ebp)
  801356:	e8 c4 fe ff ff       	call   80121f <fd_lookup>
  80135b:	83 c4 08             	add    $0x8,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 10                	js     801372 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	6a 01                	push   $0x1
  801367:	ff 75 f4             	pushl  -0xc(%ebp)
  80136a:	e8 59 ff ff ff       	call   8012c8 <fd_close>
  80136f:	83 c4 10             	add    $0x10,%esp
}
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <close_all>:

void
close_all(void)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	53                   	push   %ebx
  801378:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80137b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801380:	83 ec 0c             	sub    $0xc,%esp
  801383:	53                   	push   %ebx
  801384:	e8 c0 ff ff ff       	call   801349 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801389:	83 c3 01             	add    $0x1,%ebx
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	83 fb 20             	cmp    $0x20,%ebx
  801392:	75 ec                	jne    801380 <close_all+0xc>
		close(i);
}
  801394:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	57                   	push   %edi
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
  80139f:	83 ec 2c             	sub    $0x2c,%esp
  8013a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	ff 75 08             	pushl  0x8(%ebp)
  8013ac:	e8 6e fe ff ff       	call   80121f <fd_lookup>
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	0f 88 c1 00 00 00    	js     80147d <dup+0xe4>
		return r;
	close(newfdnum);
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	56                   	push   %esi
  8013c0:	e8 84 ff ff ff       	call   801349 <close>

	newfd = INDEX2FD(newfdnum);
  8013c5:	89 f3                	mov    %esi,%ebx
  8013c7:	c1 e3 0c             	shl    $0xc,%ebx
  8013ca:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013d0:	83 c4 04             	add    $0x4,%esp
  8013d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013d6:	e8 de fd ff ff       	call   8011b9 <fd2data>
  8013db:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013dd:	89 1c 24             	mov    %ebx,(%esp)
  8013e0:	e8 d4 fd ff ff       	call   8011b9 <fd2data>
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013eb:	89 f8                	mov    %edi,%eax
  8013ed:	c1 e8 16             	shr    $0x16,%eax
  8013f0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f7:	a8 01                	test   $0x1,%al
  8013f9:	74 37                	je     801432 <dup+0x99>
  8013fb:	89 f8                	mov    %edi,%eax
  8013fd:	c1 e8 0c             	shr    $0xc,%eax
  801400:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801407:	f6 c2 01             	test   $0x1,%dl
  80140a:	74 26                	je     801432 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80140c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801413:	83 ec 0c             	sub    $0xc,%esp
  801416:	25 07 0e 00 00       	and    $0xe07,%eax
  80141b:	50                   	push   %eax
  80141c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80141f:	6a 00                	push   $0x0
  801421:	57                   	push   %edi
  801422:	6a 00                	push   $0x0
  801424:	e8 b3 f7 ff ff       	call   800bdc <sys_page_map>
  801429:	89 c7                	mov    %eax,%edi
  80142b:	83 c4 20             	add    $0x20,%esp
  80142e:	85 c0                	test   %eax,%eax
  801430:	78 2e                	js     801460 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801432:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801435:	89 d0                	mov    %edx,%eax
  801437:	c1 e8 0c             	shr    $0xc,%eax
  80143a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801441:	83 ec 0c             	sub    $0xc,%esp
  801444:	25 07 0e 00 00       	and    $0xe07,%eax
  801449:	50                   	push   %eax
  80144a:	53                   	push   %ebx
  80144b:	6a 00                	push   $0x0
  80144d:	52                   	push   %edx
  80144e:	6a 00                	push   $0x0
  801450:	e8 87 f7 ff ff       	call   800bdc <sys_page_map>
  801455:	89 c7                	mov    %eax,%edi
  801457:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80145a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145c:	85 ff                	test   %edi,%edi
  80145e:	79 1d                	jns    80147d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	53                   	push   %ebx
  801464:	6a 00                	push   $0x0
  801466:	e8 b3 f7 ff ff       	call   800c1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80146b:	83 c4 08             	add    $0x8,%esp
  80146e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801471:	6a 00                	push   $0x0
  801473:	e8 a6 f7 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	89 f8                	mov    %edi,%eax
}
  80147d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801480:	5b                   	pop    %ebx
  801481:	5e                   	pop    %esi
  801482:	5f                   	pop    %edi
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    

00801485 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	53                   	push   %ebx
  801489:	83 ec 14             	sub    $0x14,%esp
  80148c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801492:	50                   	push   %eax
  801493:	53                   	push   %ebx
  801494:	e8 86 fd ff ff       	call   80121f <fd_lookup>
  801499:	83 c4 08             	add    $0x8,%esp
  80149c:	89 c2                	mov    %eax,%edx
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 6d                	js     80150f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ac:	ff 30                	pushl  (%eax)
  8014ae:	e8 c2 fd ff ff       	call   801275 <dev_lookup>
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	78 4c                	js     801506 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014bd:	8b 42 08             	mov    0x8(%edx),%eax
  8014c0:	83 e0 03             	and    $0x3,%eax
  8014c3:	83 f8 01             	cmp    $0x1,%eax
  8014c6:	75 21                	jne    8014e9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8014cd:	8b 40 50             	mov    0x50(%eax),%eax
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	53                   	push   %ebx
  8014d4:	50                   	push   %eax
  8014d5:	68 a1 26 80 00       	push   $0x8026a1
  8014da:	e8 32 ed ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e7:	eb 26                	jmp    80150f <read+0x8a>
	}
	if (!dev->dev_read)
  8014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ec:	8b 40 08             	mov    0x8(%eax),%eax
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	74 17                	je     80150a <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014f3:	83 ec 04             	sub    $0x4,%esp
  8014f6:	ff 75 10             	pushl  0x10(%ebp)
  8014f9:	ff 75 0c             	pushl  0xc(%ebp)
  8014fc:	52                   	push   %edx
  8014fd:	ff d0                	call   *%eax
  8014ff:	89 c2                	mov    %eax,%edx
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	eb 09                	jmp    80150f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801506:	89 c2                	mov    %eax,%edx
  801508:	eb 05                	jmp    80150f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80150a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80150f:	89 d0                	mov    %edx,%eax
  801511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	57                   	push   %edi
  80151a:	56                   	push   %esi
  80151b:	53                   	push   %ebx
  80151c:	83 ec 0c             	sub    $0xc,%esp
  80151f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801522:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801525:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152a:	eb 21                	jmp    80154d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	89 f0                	mov    %esi,%eax
  801531:	29 d8                	sub    %ebx,%eax
  801533:	50                   	push   %eax
  801534:	89 d8                	mov    %ebx,%eax
  801536:	03 45 0c             	add    0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	57                   	push   %edi
  80153b:	e8 45 ff ff ff       	call   801485 <read>
		if (m < 0)
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	85 c0                	test   %eax,%eax
  801545:	78 10                	js     801557 <readn+0x41>
			return m;
		if (m == 0)
  801547:	85 c0                	test   %eax,%eax
  801549:	74 0a                	je     801555 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154b:	01 c3                	add    %eax,%ebx
  80154d:	39 f3                	cmp    %esi,%ebx
  80154f:	72 db                	jb     80152c <readn+0x16>
  801551:	89 d8                	mov    %ebx,%eax
  801553:	eb 02                	jmp    801557 <readn+0x41>
  801555:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801557:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	5f                   	pop    %edi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    

0080155f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	53                   	push   %ebx
  801563:	83 ec 14             	sub    $0x14,%esp
  801566:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801569:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156c:	50                   	push   %eax
  80156d:	53                   	push   %ebx
  80156e:	e8 ac fc ff ff       	call   80121f <fd_lookup>
  801573:	83 c4 08             	add    $0x8,%esp
  801576:	89 c2                	mov    %eax,%edx
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 68                	js     8015e4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	ff 30                	pushl  (%eax)
  801588:	e8 e8 fc ff ff       	call   801275 <dev_lookup>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 47                	js     8015db <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801594:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801597:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159b:	75 21                	jne    8015be <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80159d:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a2:	8b 40 50             	mov    0x50(%eax),%eax
  8015a5:	83 ec 04             	sub    $0x4,%esp
  8015a8:	53                   	push   %ebx
  8015a9:	50                   	push   %eax
  8015aa:	68 bd 26 80 00       	push   $0x8026bd
  8015af:	e8 5d ec ff ff       	call   800211 <cprintf>
		return -E_INVAL;
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015bc:	eb 26                	jmp    8015e4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c1:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c4:	85 d2                	test   %edx,%edx
  8015c6:	74 17                	je     8015df <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015c8:	83 ec 04             	sub    $0x4,%esp
  8015cb:	ff 75 10             	pushl  0x10(%ebp)
  8015ce:	ff 75 0c             	pushl  0xc(%ebp)
  8015d1:	50                   	push   %eax
  8015d2:	ff d2                	call   *%edx
  8015d4:	89 c2                	mov    %eax,%edx
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	eb 09                	jmp    8015e4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015db:	89 c2                	mov    %eax,%edx
  8015dd:	eb 05                	jmp    8015e4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015e4:	89 d0                	mov    %edx,%eax
  8015e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <seek>:

int
seek(int fdnum, off_t offset)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	ff 75 08             	pushl  0x8(%ebp)
  8015f8:	e8 22 fc ff ff       	call   80121f <fd_lookup>
  8015fd:	83 c4 08             	add    $0x8,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	78 0e                	js     801612 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801604:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801607:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80160d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	83 ec 14             	sub    $0x14,%esp
  80161b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801621:	50                   	push   %eax
  801622:	53                   	push   %ebx
  801623:	e8 f7 fb ff ff       	call   80121f <fd_lookup>
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	89 c2                	mov    %eax,%edx
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 65                	js     801696 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801637:	50                   	push   %eax
  801638:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163b:	ff 30                	pushl  (%eax)
  80163d:	e8 33 fc ff ff       	call   801275 <dev_lookup>
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	85 c0                	test   %eax,%eax
  801647:	78 44                	js     80168d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801649:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801650:	75 21                	jne    801673 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801652:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801657:	8b 40 50             	mov    0x50(%eax),%eax
  80165a:	83 ec 04             	sub    $0x4,%esp
  80165d:	53                   	push   %ebx
  80165e:	50                   	push   %eax
  80165f:	68 80 26 80 00       	push   $0x802680
  801664:	e8 a8 eb ff ff       	call   800211 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801671:	eb 23                	jmp    801696 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801673:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801676:	8b 52 18             	mov    0x18(%edx),%edx
  801679:	85 d2                	test   %edx,%edx
  80167b:	74 14                	je     801691 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	ff 75 0c             	pushl  0xc(%ebp)
  801683:	50                   	push   %eax
  801684:	ff d2                	call   *%edx
  801686:	89 c2                	mov    %eax,%edx
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	eb 09                	jmp    801696 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168d:	89 c2                	mov    %eax,%edx
  80168f:	eb 05                	jmp    801696 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801691:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801696:	89 d0                	mov    %edx,%eax
  801698:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169b:	c9                   	leave  
  80169c:	c3                   	ret    

0080169d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 14             	sub    $0x14,%esp
  8016a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	ff 75 08             	pushl  0x8(%ebp)
  8016ae:	e8 6c fb ff ff       	call   80121f <fd_lookup>
  8016b3:	83 c4 08             	add    $0x8,%esp
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 58                	js     801714 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c2:	50                   	push   %eax
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	ff 30                	pushl  (%eax)
  8016c8:	e8 a8 fb ff ff       	call   801275 <dev_lookup>
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 37                	js     80170b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016db:	74 32                	je     80170f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016e7:	00 00 00 
	stat->st_isdir = 0;
  8016ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f1:	00 00 00 
	stat->st_dev = dev;
  8016f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	53                   	push   %ebx
  8016fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801701:	ff 50 14             	call   *0x14(%eax)
  801704:	89 c2                	mov    %eax,%edx
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	eb 09                	jmp    801714 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170b:	89 c2                	mov    %eax,%edx
  80170d:	eb 05                	jmp    801714 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80170f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801714:	89 d0                	mov    %edx,%eax
  801716:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801719:	c9                   	leave  
  80171a:	c3                   	ret    

0080171b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	56                   	push   %esi
  80171f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	6a 00                	push   $0x0
  801725:	ff 75 08             	pushl  0x8(%ebp)
  801728:	e8 e3 01 00 00       	call   801910 <open>
  80172d:	89 c3                	mov    %eax,%ebx
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	85 c0                	test   %eax,%eax
  801734:	78 1b                	js     801751 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801736:	83 ec 08             	sub    $0x8,%esp
  801739:	ff 75 0c             	pushl  0xc(%ebp)
  80173c:	50                   	push   %eax
  80173d:	e8 5b ff ff ff       	call   80169d <fstat>
  801742:	89 c6                	mov    %eax,%esi
	close(fd);
  801744:	89 1c 24             	mov    %ebx,(%esp)
  801747:	e8 fd fb ff ff       	call   801349 <close>
	return r;
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	89 f0                	mov    %esi,%eax
}
  801751:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801754:	5b                   	pop    %ebx
  801755:	5e                   	pop    %esi
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    

00801758 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	56                   	push   %esi
  80175c:	53                   	push   %ebx
  80175d:	89 c6                	mov    %eax,%esi
  80175f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801761:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801768:	75 12                	jne    80177c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80176a:	83 ec 0c             	sub    $0xc,%esp
  80176d:	6a 01                	push   $0x1
  80176f:	e8 f5 f9 ff ff       	call   801169 <ipc_find_env>
  801774:	a3 00 40 80 00       	mov    %eax,0x804000
  801779:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80177c:	6a 07                	push   $0x7
  80177e:	68 00 50 80 00       	push   $0x805000
  801783:	56                   	push   %esi
  801784:	ff 35 00 40 80 00    	pushl  0x804000
  80178a:	e8 78 f9 ff ff       	call   801107 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80178f:	83 c4 0c             	add    $0xc,%esp
  801792:	6a 00                	push   $0x0
  801794:	53                   	push   %ebx
  801795:	6a 00                	push   $0x0
  801797:	e8 f6 f8 ff ff       	call   801092 <ipc_recv>
}
  80179c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8017af:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c1:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c6:	e8 8d ff ff ff       	call   801758 <fsipc>
}
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	b8 06 00 00 00       	mov    $0x6,%eax
  8017e8:	e8 6b ff ff ff       	call   801758 <fsipc>
}
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 04             	sub    $0x4,%esp
  8017f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ff:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801804:	ba 00 00 00 00       	mov    $0x0,%edx
  801809:	b8 05 00 00 00       	mov    $0x5,%eax
  80180e:	e8 45 ff ff ff       	call   801758 <fsipc>
  801813:	85 c0                	test   %eax,%eax
  801815:	78 2c                	js     801843 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	68 00 50 80 00       	push   $0x805000
  80181f:	53                   	push   %ebx
  801820:	e8 71 ef ff ff       	call   800796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801825:	a1 80 50 80 00       	mov    0x805080,%eax
  80182a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801830:	a1 84 50 80 00       	mov    0x805084,%eax
  801835:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 0c             	sub    $0xc,%esp
  80184e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801851:	8b 55 08             	mov    0x8(%ebp),%edx
  801854:	8b 52 0c             	mov    0xc(%edx),%edx
  801857:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80185d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801862:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801867:	0f 47 c2             	cmova  %edx,%eax
  80186a:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80186f:	50                   	push   %eax
  801870:	ff 75 0c             	pushl  0xc(%ebp)
  801873:	68 08 50 80 00       	push   $0x805008
  801878:	e8 ab f0 ff ff       	call   800928 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80187d:	ba 00 00 00 00       	mov    $0x0,%edx
  801882:	b8 04 00 00 00       	mov    $0x4,%eax
  801887:	e8 cc fe ff ff       	call   801758 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
  801893:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801896:	8b 45 08             	mov    0x8(%ebp),%eax
  801899:	8b 40 0c             	mov    0xc(%eax),%eax
  80189c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ac:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b1:	e8 a2 fe ff ff       	call   801758 <fsipc>
  8018b6:	89 c3                	mov    %eax,%ebx
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 4b                	js     801907 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018bc:	39 c6                	cmp    %eax,%esi
  8018be:	73 16                	jae    8018d6 <devfile_read+0x48>
  8018c0:	68 ec 26 80 00       	push   $0x8026ec
  8018c5:	68 f3 26 80 00       	push   $0x8026f3
  8018ca:	6a 7c                	push   $0x7c
  8018cc:	68 08 27 80 00       	push   $0x802708
  8018d1:	e8 bd 05 00 00       	call   801e93 <_panic>
	assert(r <= PGSIZE);
  8018d6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018db:	7e 16                	jle    8018f3 <devfile_read+0x65>
  8018dd:	68 13 27 80 00       	push   $0x802713
  8018e2:	68 f3 26 80 00       	push   $0x8026f3
  8018e7:	6a 7d                	push   $0x7d
  8018e9:	68 08 27 80 00       	push   $0x802708
  8018ee:	e8 a0 05 00 00       	call   801e93 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018f3:	83 ec 04             	sub    $0x4,%esp
  8018f6:	50                   	push   %eax
  8018f7:	68 00 50 80 00       	push   $0x805000
  8018fc:	ff 75 0c             	pushl  0xc(%ebp)
  8018ff:	e8 24 f0 ff ff       	call   800928 <memmove>
	return r;
  801904:	83 c4 10             	add    $0x10,%esp
}
  801907:	89 d8                	mov    %ebx,%eax
  801909:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	53                   	push   %ebx
  801914:	83 ec 20             	sub    $0x20,%esp
  801917:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80191a:	53                   	push   %ebx
  80191b:	e8 3d ee ff ff       	call   80075d <strlen>
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801928:	7f 67                	jg     801991 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801930:	50                   	push   %eax
  801931:	e8 9a f8 ff ff       	call   8011d0 <fd_alloc>
  801936:	83 c4 10             	add    $0x10,%esp
		return r;
  801939:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 57                	js     801996 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	53                   	push   %ebx
  801943:	68 00 50 80 00       	push   $0x805000
  801948:	e8 49 ee ff ff       	call   800796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80194d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801950:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801955:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801958:	b8 01 00 00 00       	mov    $0x1,%eax
  80195d:	e8 f6 fd ff ff       	call   801758 <fsipc>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	79 14                	jns    80197f <open+0x6f>
		fd_close(fd, 0);
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	6a 00                	push   $0x0
  801970:	ff 75 f4             	pushl  -0xc(%ebp)
  801973:	e8 50 f9 ff ff       	call   8012c8 <fd_close>
		return r;
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	89 da                	mov    %ebx,%edx
  80197d:	eb 17                	jmp    801996 <open+0x86>
	}

	return fd2num(fd);
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	ff 75 f4             	pushl  -0xc(%ebp)
  801985:	e8 1f f8 ff ff       	call   8011a9 <fd2num>
  80198a:	89 c2                	mov    %eax,%edx
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	eb 05                	jmp    801996 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801991:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801996:	89 d0                	mov    %edx,%eax
  801998:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    

0080199d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ad:	e8 a6 fd ff ff       	call   801758 <fsipc>
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
  8019b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019bc:	83 ec 0c             	sub    $0xc,%esp
  8019bf:	ff 75 08             	pushl  0x8(%ebp)
  8019c2:	e8 f2 f7 ff ff       	call   8011b9 <fd2data>
  8019c7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019c9:	83 c4 08             	add    $0x8,%esp
  8019cc:	68 1f 27 80 00       	push   $0x80271f
  8019d1:	53                   	push   %ebx
  8019d2:	e8 bf ed ff ff       	call   800796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019d7:	8b 46 04             	mov    0x4(%esi),%eax
  8019da:	2b 06                	sub    (%esi),%eax
  8019dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019e9:	00 00 00 
	stat->st_dev = &devpipe;
  8019ec:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019f3:	30 80 00 
	return 0;
}
  8019f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5d                   	pop    %ebp
  801a01:	c3                   	ret    

00801a02 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	53                   	push   %ebx
  801a06:	83 ec 0c             	sub    $0xc,%esp
  801a09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a0c:	53                   	push   %ebx
  801a0d:	6a 00                	push   $0x0
  801a0f:	e8 0a f2 ff ff       	call   800c1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a14:	89 1c 24             	mov    %ebx,(%esp)
  801a17:	e8 9d f7 ff ff       	call   8011b9 <fd2data>
  801a1c:	83 c4 08             	add    $0x8,%esp
  801a1f:	50                   	push   %eax
  801a20:	6a 00                	push   $0x0
  801a22:	e8 f7 f1 ff ff       	call   800c1e <sys_page_unmap>
}
  801a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	57                   	push   %edi
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	83 ec 1c             	sub    $0x1c,%esp
  801a35:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a38:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a3a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3f:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	ff 75 e0             	pushl  -0x20(%ebp)
  801a48:	e8 1b 05 00 00       	call   801f68 <pageref>
  801a4d:	89 c3                	mov    %eax,%ebx
  801a4f:	89 3c 24             	mov    %edi,(%esp)
  801a52:	e8 11 05 00 00       	call   801f68 <pageref>
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	39 c3                	cmp    %eax,%ebx
  801a5c:	0f 94 c1             	sete   %cl
  801a5f:	0f b6 c9             	movzbl %cl,%ecx
  801a62:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a65:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a6b:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801a6e:	39 ce                	cmp    %ecx,%esi
  801a70:	74 1b                	je     801a8d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a72:	39 c3                	cmp    %eax,%ebx
  801a74:	75 c4                	jne    801a3a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a76:	8b 42 60             	mov    0x60(%edx),%eax
  801a79:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a7c:	50                   	push   %eax
  801a7d:	56                   	push   %esi
  801a7e:	68 26 27 80 00       	push   $0x802726
  801a83:	e8 89 e7 ff ff       	call   800211 <cprintf>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	eb ad                	jmp    801a3a <_pipeisclosed+0xe>
	}
}
  801a8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5f                   	pop    %edi
  801a96:	5d                   	pop    %ebp
  801a97:	c3                   	ret    

00801a98 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 28             	sub    $0x28,%esp
  801aa1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aa4:	56                   	push   %esi
  801aa5:	e8 0f f7 ff ff       	call   8011b9 <fd2data>
  801aaa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab4:	eb 4b                	jmp    801b01 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ab6:	89 da                	mov    %ebx,%edx
  801ab8:	89 f0                	mov    %esi,%eax
  801aba:	e8 6d ff ff ff       	call   801a2c <_pipeisclosed>
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	75 48                	jne    801b0b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ac3:	e8 b2 f0 ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac8:	8b 43 04             	mov    0x4(%ebx),%eax
  801acb:	8b 0b                	mov    (%ebx),%ecx
  801acd:	8d 51 20             	lea    0x20(%ecx),%edx
  801ad0:	39 d0                	cmp    %edx,%eax
  801ad2:	73 e2                	jae    801ab6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801adb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ade:	89 c2                	mov    %eax,%edx
  801ae0:	c1 fa 1f             	sar    $0x1f,%edx
  801ae3:	89 d1                	mov    %edx,%ecx
  801ae5:	c1 e9 1b             	shr    $0x1b,%ecx
  801ae8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aeb:	83 e2 1f             	and    $0x1f,%edx
  801aee:	29 ca                	sub    %ecx,%edx
  801af0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801af4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801af8:	83 c0 01             	add    $0x1,%eax
  801afb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afe:	83 c7 01             	add    $0x1,%edi
  801b01:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b04:	75 c2                	jne    801ac8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b06:	8b 45 10             	mov    0x10(%ebp),%eax
  801b09:	eb 05                	jmp    801b10 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5f                   	pop    %edi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	57                   	push   %edi
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 18             	sub    $0x18,%esp
  801b21:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b24:	57                   	push   %edi
  801b25:	e8 8f f6 ff ff       	call   8011b9 <fd2data>
  801b2a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b34:	eb 3d                	jmp    801b73 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b36:	85 db                	test   %ebx,%ebx
  801b38:	74 04                	je     801b3e <devpipe_read+0x26>
				return i;
  801b3a:	89 d8                	mov    %ebx,%eax
  801b3c:	eb 44                	jmp    801b82 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b3e:	89 f2                	mov    %esi,%edx
  801b40:	89 f8                	mov    %edi,%eax
  801b42:	e8 e5 fe ff ff       	call   801a2c <_pipeisclosed>
  801b47:	85 c0                	test   %eax,%eax
  801b49:	75 32                	jne    801b7d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b4b:	e8 2a f0 ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b50:	8b 06                	mov    (%esi),%eax
  801b52:	3b 46 04             	cmp    0x4(%esi),%eax
  801b55:	74 df                	je     801b36 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b57:	99                   	cltd   
  801b58:	c1 ea 1b             	shr    $0x1b,%edx
  801b5b:	01 d0                	add    %edx,%eax
  801b5d:	83 e0 1f             	and    $0x1f,%eax
  801b60:	29 d0                	sub    %edx,%eax
  801b62:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b6a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b6d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b70:	83 c3 01             	add    $0x1,%ebx
  801b73:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b76:	75 d8                	jne    801b50 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b78:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7b:	eb 05                	jmp    801b82 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b7d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	56                   	push   %esi
  801b8e:	53                   	push   %ebx
  801b8f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b95:	50                   	push   %eax
  801b96:	e8 35 f6 ff ff       	call   8011d0 <fd_alloc>
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	89 c2                	mov    %eax,%edx
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	0f 88 2c 01 00 00    	js     801cd4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba8:	83 ec 04             	sub    $0x4,%esp
  801bab:	68 07 04 00 00       	push   $0x407
  801bb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb3:	6a 00                	push   $0x0
  801bb5:	e8 df ef ff ff       	call   800b99 <sys_page_alloc>
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	89 c2                	mov    %eax,%edx
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	0f 88 0d 01 00 00    	js     801cd4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bc7:	83 ec 0c             	sub    $0xc,%esp
  801bca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bcd:	50                   	push   %eax
  801bce:	e8 fd f5 ff ff       	call   8011d0 <fd_alloc>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 e2 00 00 00    	js     801cc2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be0:	83 ec 04             	sub    $0x4,%esp
  801be3:	68 07 04 00 00       	push   $0x407
  801be8:	ff 75 f0             	pushl  -0x10(%ebp)
  801beb:	6a 00                	push   $0x0
  801bed:	e8 a7 ef ff ff       	call   800b99 <sys_page_alloc>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	0f 88 c3 00 00 00    	js     801cc2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	ff 75 f4             	pushl  -0xc(%ebp)
  801c05:	e8 af f5 ff ff       	call   8011b9 <fd2data>
  801c0a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	83 c4 0c             	add    $0xc,%esp
  801c0f:	68 07 04 00 00       	push   $0x407
  801c14:	50                   	push   %eax
  801c15:	6a 00                	push   $0x0
  801c17:	e8 7d ef ff ff       	call   800b99 <sys_page_alloc>
  801c1c:	89 c3                	mov    %eax,%ebx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	85 c0                	test   %eax,%eax
  801c23:	0f 88 89 00 00 00    	js     801cb2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2f:	e8 85 f5 ff ff       	call   8011b9 <fd2data>
  801c34:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c3b:	50                   	push   %eax
  801c3c:	6a 00                	push   $0x0
  801c3e:	56                   	push   %esi
  801c3f:	6a 00                	push   $0x0
  801c41:	e8 96 ef ff ff       	call   800bdc <sys_page_map>
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	83 c4 20             	add    $0x20,%esp
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	78 55                	js     801ca4 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c4f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c58:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c64:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c72:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7f:	e8 25 f5 ff ff       	call   8011a9 <fd2num>
  801c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c87:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c89:	83 c4 04             	add    $0x4,%esp
  801c8c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8f:	e8 15 f5 ff ff       	call   8011a9 <fd2num>
  801c94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c97:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca2:	eb 30                	jmp    801cd4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	56                   	push   %esi
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 6f ef ff ff       	call   800c1e <sys_page_unmap>
  801caf:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cb2:	83 ec 08             	sub    $0x8,%esp
  801cb5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb8:	6a 00                	push   $0x0
  801cba:	e8 5f ef ff ff       	call   800c1e <sys_page_unmap>
  801cbf:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cc2:	83 ec 08             	sub    $0x8,%esp
  801cc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc8:	6a 00                	push   $0x0
  801cca:	e8 4f ef ff ff       	call   800c1e <sys_page_unmap>
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cd4:	89 d0                	mov    %edx,%eax
  801cd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd9:	5b                   	pop    %ebx
  801cda:	5e                   	pop    %esi
  801cdb:	5d                   	pop    %ebp
  801cdc:	c3                   	ret    

00801cdd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce6:	50                   	push   %eax
  801ce7:	ff 75 08             	pushl  0x8(%ebp)
  801cea:	e8 30 f5 ff ff       	call   80121f <fd_lookup>
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	78 18                	js     801d0e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfc:	e8 b8 f4 ff ff       	call   8011b9 <fd2data>
	return _pipeisclosed(fd, p);
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d06:	e8 21 fd ff ff       	call   801a2c <_pipeisclosed>
  801d0b:	83 c4 10             	add    $0x10,%esp
}
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d20:	68 3e 27 80 00       	push   $0x80273e
  801d25:	ff 75 0c             	pushl  0xc(%ebp)
  801d28:	e8 69 ea ff ff       	call   800796 <strcpy>
	return 0;
}
  801d2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	57                   	push   %edi
  801d38:	56                   	push   %esi
  801d39:	53                   	push   %ebx
  801d3a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d40:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d45:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4b:	eb 2d                	jmp    801d7a <devcons_write+0x46>
		m = n - tot;
  801d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d50:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d52:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d55:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d5a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5d:	83 ec 04             	sub    $0x4,%esp
  801d60:	53                   	push   %ebx
  801d61:	03 45 0c             	add    0xc(%ebp),%eax
  801d64:	50                   	push   %eax
  801d65:	57                   	push   %edi
  801d66:	e8 bd eb ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  801d6b:	83 c4 08             	add    $0x8,%esp
  801d6e:	53                   	push   %ebx
  801d6f:	57                   	push   %edi
  801d70:	e8 68 ed ff ff       	call   800add <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d75:	01 de                	add    %ebx,%esi
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	89 f0                	mov    %esi,%eax
  801d7c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d7f:	72 cc                	jb     801d4d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5f                   	pop    %edi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    

00801d89 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	83 ec 08             	sub    $0x8,%esp
  801d8f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d98:	74 2a                	je     801dc4 <devcons_read+0x3b>
  801d9a:	eb 05                	jmp    801da1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d9c:	e8 d9 ed ff ff       	call   800b7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801da1:	e8 55 ed ff ff       	call   800afb <sys_cgetc>
  801da6:	85 c0                	test   %eax,%eax
  801da8:	74 f2                	je     801d9c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801daa:	85 c0                	test   %eax,%eax
  801dac:	78 16                	js     801dc4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dae:	83 f8 04             	cmp    $0x4,%eax
  801db1:	74 0c                	je     801dbf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801db3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db6:	88 02                	mov    %al,(%edx)
	return 1;
  801db8:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbd:	eb 05                	jmp    801dc4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dd2:	6a 01                	push   $0x1
  801dd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd7:	50                   	push   %eax
  801dd8:	e8 00 ed ff ff       	call   800add <sys_cputs>
}
  801ddd:	83 c4 10             	add    $0x10,%esp
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <getchar>:

int
getchar(void)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801de8:	6a 01                	push   $0x1
  801dea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ded:	50                   	push   %eax
  801dee:	6a 00                	push   $0x0
  801df0:	e8 90 f6 ff ff       	call   801485 <read>
	if (r < 0)
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 0f                	js     801e0b <getchar+0x29>
		return r;
	if (r < 1)
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	7e 06                	jle    801e06 <getchar+0x24>
		return -E_EOF;
	return c;
  801e00:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e04:	eb 05                	jmp    801e0b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e06:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e0b:	c9                   	leave  
  801e0c:	c3                   	ret    

00801e0d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e16:	50                   	push   %eax
  801e17:	ff 75 08             	pushl  0x8(%ebp)
  801e1a:	e8 00 f4 ff ff       	call   80121f <fd_lookup>
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 11                	js     801e37 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e29:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e2f:	39 10                	cmp    %edx,(%eax)
  801e31:	0f 94 c0             	sete   %al
  801e34:	0f b6 c0             	movzbl %al,%eax
}
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    

00801e39 <opencons>:

int
opencons(void)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e42:	50                   	push   %eax
  801e43:	e8 88 f3 ff ff       	call   8011d0 <fd_alloc>
  801e48:	83 c4 10             	add    $0x10,%esp
		return r;
  801e4b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 3e                	js     801e8f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e51:	83 ec 04             	sub    $0x4,%esp
  801e54:	68 07 04 00 00       	push   $0x407
  801e59:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5c:	6a 00                	push   $0x0
  801e5e:	e8 36 ed ff ff       	call   800b99 <sys_page_alloc>
  801e63:	83 c4 10             	add    $0x10,%esp
		return r;
  801e66:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 23                	js     801e8f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e6c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e75:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e81:	83 ec 0c             	sub    $0xc,%esp
  801e84:	50                   	push   %eax
  801e85:	e8 1f f3 ff ff       	call   8011a9 <fd2num>
  801e8a:	89 c2                	mov    %eax,%edx
  801e8c:	83 c4 10             	add    $0x10,%esp
}
  801e8f:	89 d0                	mov    %edx,%eax
  801e91:	c9                   	leave  
  801e92:	c3                   	ret    

00801e93 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	56                   	push   %esi
  801e97:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e98:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e9b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ea1:	e8 b5 ec ff ff       	call   800b5b <sys_getenvid>
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	ff 75 0c             	pushl  0xc(%ebp)
  801eac:	ff 75 08             	pushl  0x8(%ebp)
  801eaf:	56                   	push   %esi
  801eb0:	50                   	push   %eax
  801eb1:	68 4c 27 80 00       	push   $0x80274c
  801eb6:	e8 56 e3 ff ff       	call   800211 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ebb:	83 c4 18             	add    $0x18,%esp
  801ebe:	53                   	push   %ebx
  801ebf:	ff 75 10             	pushl  0x10(%ebp)
  801ec2:	e8 f9 e2 ff ff       	call   8001c0 <vcprintf>
	cprintf("\n");
  801ec7:	c7 04 24 37 27 80 00 	movl   $0x802737,(%esp)
  801ece:	e8 3e e3 ff ff       	call   800211 <cprintf>
  801ed3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ed6:	cc                   	int3   
  801ed7:	eb fd                	jmp    801ed6 <_panic+0x43>

00801ed9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801edf:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ee6:	75 2a                	jne    801f12 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	6a 07                	push   $0x7
  801eed:	68 00 f0 bf ee       	push   $0xeebff000
  801ef2:	6a 00                	push   $0x0
  801ef4:	e8 a0 ec ff ff       	call   800b99 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	79 12                	jns    801f12 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f00:	50                   	push   %eax
  801f01:	68 70 27 80 00       	push   $0x802770
  801f06:	6a 23                	push   $0x23
  801f08:	68 74 27 80 00       	push   $0x802774
  801f0d:	e8 81 ff ff ff       	call   801e93 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f12:	8b 45 08             	mov    0x8(%ebp),%eax
  801f15:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	68 44 1f 80 00       	push   $0x801f44
  801f22:	6a 00                	push   $0x0
  801f24:	e8 bb ed ff ff       	call   800ce4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	79 12                	jns    801f42 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f30:	50                   	push   %eax
  801f31:	68 70 27 80 00       	push   $0x802770
  801f36:	6a 2c                	push   $0x2c
  801f38:	68 74 27 80 00       	push   $0x802774
  801f3d:	e8 51 ff ff ff       	call   801e93 <_panic>
	}
}
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f44:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f45:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f4a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f4c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f4f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f53:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f58:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f5c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f5e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f61:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f62:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f65:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f66:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f67:	c3                   	ret    

00801f68 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6e:	89 d0                	mov    %edx,%eax
  801f70:	c1 e8 16             	shr    $0x16,%eax
  801f73:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f7a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7f:	f6 c1 01             	test   $0x1,%cl
  801f82:	74 1d                	je     801fa1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f84:	c1 ea 0c             	shr    $0xc,%edx
  801f87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f8e:	f6 c2 01             	test   $0x1,%dl
  801f91:	74 0e                	je     801fa1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f93:	c1 ea 0c             	shr    $0xc,%edx
  801f96:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f9d:	ef 
  801f9e:	0f b7 c0             	movzwl %ax,%eax
}
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    
  801fa3:	66 90                	xchg   %ax,%ax
  801fa5:	66 90                	xchg   %ax,%ax
  801fa7:	66 90                	xchg   %ax,%ax
  801fa9:	66 90                	xchg   %ax,%ax
  801fab:	66 90                	xchg   %ax,%ax
  801fad:	66 90                	xchg   %ax,%ax
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
