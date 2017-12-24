
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
  80003c:	e8 07 0e 00 00       	call   800e48 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 f4 0a 00 00       	call   800b43 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 e0 21 80 00       	push   $0x8021e0
  800059:	e8 9b 01 00 00       	call   8001f9 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 35 10 00 00       	call   8010a1 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 b0 0f 00 00       	call   80102f <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 ba 0a 00 00       	call   800b43 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 f6 21 80 00       	push   $0x8021f6
  800091:	e8 63 01 00 00       	call   8001f9 <cprintf>
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
  8000a9:	e8 f3 0f 00 00       	call   8010a1 <ipc_send>
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
  8000d1:	e8 6d 0a 00 00       	call   800b43 <sys_getenvid>
  8000d6:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000dc:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8000e1:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000e6:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8000eb:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8000ee:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8000f4:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8000f7:	39 c8                	cmp    %ecx,%eax
  8000f9:	0f 44 fb             	cmove  %ebx,%edi
  8000fc:	b9 01 00 00 00       	mov    $0x1,%ecx
  800101:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800104:	83 c2 01             	add    $0x1,%edx
  800107:	83 c3 7c             	add    $0x7c,%ebx
  80010a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800110:	75 d9                	jne    8000eb <libmain+0x2d>
  800112:	89 f0                	mov    %esi,%eax
  800114:	84 c0                	test   %al,%al
  800116:	74 06                	je     80011e <libmain+0x60>
  800118:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800122:	7e 0a                	jle    80012e <libmain+0x70>
		binaryname = argv[0];
  800124:	8b 45 0c             	mov    0xc(%ebp),%eax
  800127:	8b 00                	mov    (%eax),%eax
  800129:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	ff 75 0c             	pushl  0xc(%ebp)
  800134:	ff 75 08             	pushl  0x8(%ebp)
  800137:	e8 f7 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013c:	e8 0b 00 00 00       	call   80014c <exit>
}
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800152:	e8 b0 11 00 00       	call   801307 <close_all>
	sys_env_destroy(0);
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	6a 00                	push   $0x0
  80015c:	e8 a1 09 00 00       	call   800b02 <sys_env_destroy>
}
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	53                   	push   %ebx
  80016a:	83 ec 04             	sub    $0x4,%esp
  80016d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800170:	8b 13                	mov    (%ebx),%edx
  800172:	8d 42 01             	lea    0x1(%edx),%eax
  800175:	89 03                	mov    %eax,(%ebx)
  800177:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 1a                	jne    80019f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800185:	83 ec 08             	sub    $0x8,%esp
  800188:	68 ff 00 00 00       	push   $0xff
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 2f 09 00 00       	call   800ac5 <sys_cputs>
		b->idx = 0;
  800196:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b8:	00 00 00 
	b.cnt = 0;
  8001bb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c5:	ff 75 0c             	pushl  0xc(%ebp)
  8001c8:	ff 75 08             	pushl  0x8(%ebp)
  8001cb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d1:	50                   	push   %eax
  8001d2:	68 66 01 80 00       	push   $0x800166
  8001d7:	e8 54 01 00 00       	call   800330 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001dc:	83 c4 08             	add    $0x8,%esp
  8001df:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001eb:	50                   	push   %eax
  8001ec:	e8 d4 08 00 00       	call   800ac5 <sys_cputs>

	return b.cnt;
}
  8001f1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ff:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800202:	50                   	push   %eax
  800203:	ff 75 08             	pushl  0x8(%ebp)
  800206:	e8 9d ff ff ff       	call   8001a8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	57                   	push   %edi
  800211:	56                   	push   %esi
  800212:	53                   	push   %ebx
  800213:	83 ec 1c             	sub    $0x1c,%esp
  800216:	89 c7                	mov    %eax,%edi
  800218:	89 d6                	mov    %edx,%esi
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800220:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800223:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800226:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800231:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800234:	39 d3                	cmp    %edx,%ebx
  800236:	72 05                	jb     80023d <printnum+0x30>
  800238:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023b:	77 45                	ja     800282 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023d:	83 ec 0c             	sub    $0xc,%esp
  800240:	ff 75 18             	pushl  0x18(%ebp)
  800243:	8b 45 14             	mov    0x14(%ebp),%eax
  800246:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800249:	53                   	push   %ebx
  80024a:	ff 75 10             	pushl  0x10(%ebp)
  80024d:	83 ec 08             	sub    $0x8,%esp
  800250:	ff 75 e4             	pushl  -0x1c(%ebp)
  800253:	ff 75 e0             	pushl  -0x20(%ebp)
  800256:	ff 75 dc             	pushl  -0x24(%ebp)
  800259:	ff 75 d8             	pushl  -0x28(%ebp)
  80025c:	e8 df 1c 00 00       	call   801f40 <__udivdi3>
  800261:	83 c4 18             	add    $0x18,%esp
  800264:	52                   	push   %edx
  800265:	50                   	push   %eax
  800266:	89 f2                	mov    %esi,%edx
  800268:	89 f8                	mov    %edi,%eax
  80026a:	e8 9e ff ff ff       	call   80020d <printnum>
  80026f:	83 c4 20             	add    $0x20,%esp
  800272:	eb 18                	jmp    80028c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800274:	83 ec 08             	sub    $0x8,%esp
  800277:	56                   	push   %esi
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	ff d7                	call   *%edi
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	eb 03                	jmp    800285 <printnum+0x78>
  800282:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800285:	83 eb 01             	sub    $0x1,%ebx
  800288:	85 db                	test   %ebx,%ebx
  80028a:	7f e8                	jg     800274 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	56                   	push   %esi
  800290:	83 ec 04             	sub    $0x4,%esp
  800293:	ff 75 e4             	pushl  -0x1c(%ebp)
  800296:	ff 75 e0             	pushl  -0x20(%ebp)
  800299:	ff 75 dc             	pushl  -0x24(%ebp)
  80029c:	ff 75 d8             	pushl  -0x28(%ebp)
  80029f:	e8 cc 1d 00 00       	call   802070 <__umoddi3>
  8002a4:	83 c4 14             	add    $0x14,%esp
  8002a7:	0f be 80 13 22 80 00 	movsbl 0x802213(%eax),%eax
  8002ae:	50                   	push   %eax
  8002af:	ff d7                	call   *%edi
}
  8002b1:	83 c4 10             	add    $0x10,%esp
  8002b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bf:	83 fa 01             	cmp    $0x1,%edx
  8002c2:	7e 0e                	jle    8002d2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 02                	mov    (%edx),%eax
  8002cd:	8b 52 04             	mov    0x4(%edx),%edx
  8002d0:	eb 22                	jmp    8002f4 <getuint+0x38>
	else if (lflag)
  8002d2:	85 d2                	test   %edx,%edx
  8002d4:	74 10                	je     8002e6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e4:	eb 0e                	jmp    8002f4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e6:	8b 10                	mov    (%eax),%edx
  8002e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002eb:	89 08                	mov    %ecx,(%eax)
  8002ed:	8b 02                	mov    (%edx),%eax
  8002ef:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800300:	8b 10                	mov    (%eax),%edx
  800302:	3b 50 04             	cmp    0x4(%eax),%edx
  800305:	73 0a                	jae    800311 <sprintputch+0x1b>
		*b->buf++ = ch;
  800307:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 45 08             	mov    0x8(%ebp),%eax
  80030f:	88 02                	mov    %al,(%edx)
}
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800319:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031c:	50                   	push   %eax
  80031d:	ff 75 10             	pushl  0x10(%ebp)
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 05 00 00 00       	call   800330 <vprintfmt>
	va_end(ap);
}
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 2c             	sub    $0x2c,%esp
  800339:	8b 75 08             	mov    0x8(%ebp),%esi
  80033c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800342:	eb 12                	jmp    800356 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800344:	85 c0                	test   %eax,%eax
  800346:	0f 84 89 03 00 00    	je     8006d5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	53                   	push   %ebx
  800350:	50                   	push   %eax
  800351:	ff d6                	call   *%esi
  800353:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800356:	83 c7 01             	add    $0x1,%edi
  800359:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035d:	83 f8 25             	cmp    $0x25,%eax
  800360:	75 e2                	jne    800344 <vprintfmt+0x14>
  800362:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800366:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800374:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
  800380:	eb 07                	jmp    800389 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800385:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8d 47 01             	lea    0x1(%edi),%eax
  80038c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038f:	0f b6 07             	movzbl (%edi),%eax
  800392:	0f b6 c8             	movzbl %al,%ecx
  800395:	83 e8 23             	sub    $0x23,%eax
  800398:	3c 55                	cmp    $0x55,%al
  80039a:	0f 87 1a 03 00 00    	ja     8006ba <vprintfmt+0x38a>
  8003a0:	0f b6 c0             	movzbl %al,%eax
  8003a3:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ad:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b1:	eb d6                	jmp    800389 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003be:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003cb:	83 fa 09             	cmp    $0x9,%edx
  8003ce:	77 39                	ja     800409 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d3:	eb e9                	jmp    8003be <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003db:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003de:	8b 00                	mov    (%eax),%eax
  8003e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e6:	eb 27                	jmp    80040f <vprintfmt+0xdf>
  8003e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f2:	0f 49 c8             	cmovns %eax,%ecx
  8003f5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fb:	eb 8c                	jmp    800389 <vprintfmt+0x59>
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800400:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800407:	eb 80                	jmp    800389 <vprintfmt+0x59>
  800409:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800413:	0f 89 70 ff ff ff    	jns    800389 <vprintfmt+0x59>
				width = precision, precision = -1;
  800419:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800426:	e9 5e ff ff ff       	jmp    800389 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800431:	e9 53 ff ff ff       	jmp    800389 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	53                   	push   %ebx
  800443:	ff 30                	pushl  (%eax)
  800445:	ff d6                	call   *%esi
			break;
  800447:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044d:	e9 04 ff ff ff       	jmp    800356 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	99                   	cltd   
  80045e:	31 d0                	xor    %edx,%eax
  800460:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800462:	83 f8 0f             	cmp    $0xf,%eax
  800465:	7f 0b                	jg     800472 <vprintfmt+0x142>
  800467:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  80046e:	85 d2                	test   %edx,%edx
  800470:	75 18                	jne    80048a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800472:	50                   	push   %eax
  800473:	68 2b 22 80 00       	push   $0x80222b
  800478:	53                   	push   %ebx
  800479:	56                   	push   %esi
  80047a:	e8 94 fe ff ff       	call   800313 <printfmt>
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800485:	e9 cc fe ff ff       	jmp    800356 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048a:	52                   	push   %edx
  80048b:	68 75 26 80 00       	push   $0x802675
  800490:	53                   	push   %ebx
  800491:	56                   	push   %esi
  800492:	e8 7c fe ff ff       	call   800313 <printfmt>
  800497:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049d:	e9 b4 fe ff ff       	jmp    800356 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 50 04             	lea    0x4(%eax),%edx
  8004a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ab:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ad:	85 ff                	test   %edi,%edi
  8004af:	b8 24 22 80 00       	mov    $0x802224,%eax
  8004b4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bb:	0f 8e 94 00 00 00    	jle    800555 <vprintfmt+0x225>
  8004c1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c5:	0f 84 98 00 00 00    	je     800563 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d1:	57                   	push   %edi
  8004d2:	e8 86 02 00 00       	call   80075d <strnlen>
  8004d7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004da:	29 c1                	sub    %eax,%ecx
  8004dc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004df:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ec:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	eb 0f                	jmp    8004ff <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	53                   	push   %ebx
  8004f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	83 ef 01             	sub    $0x1,%edi
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	85 ff                	test   %edi,%edi
  800501:	7f ed                	jg     8004f0 <vprintfmt+0x1c0>
  800503:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800506:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800509:	85 c9                	test   %ecx,%ecx
  80050b:	b8 00 00 00 00       	mov    $0x0,%eax
  800510:	0f 49 c1             	cmovns %ecx,%eax
  800513:	29 c1                	sub    %eax,%ecx
  800515:	89 75 08             	mov    %esi,0x8(%ebp)
  800518:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051e:	89 cb                	mov    %ecx,%ebx
  800520:	eb 4d                	jmp    80056f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800522:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800526:	74 1b                	je     800543 <vprintfmt+0x213>
  800528:	0f be c0             	movsbl %al,%eax
  80052b:	83 e8 20             	sub    $0x20,%eax
  80052e:	83 f8 5e             	cmp    $0x5e,%eax
  800531:	76 10                	jbe    800543 <vprintfmt+0x213>
					putch('?', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	ff 75 0c             	pushl  0xc(%ebp)
  800539:	6a 3f                	push   $0x3f
  80053b:	ff 55 08             	call   *0x8(%ebp)
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	eb 0d                	jmp    800550 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	ff 75 0c             	pushl  0xc(%ebp)
  800549:	52                   	push   %edx
  80054a:	ff 55 08             	call   *0x8(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800550:	83 eb 01             	sub    $0x1,%ebx
  800553:	eb 1a                	jmp    80056f <vprintfmt+0x23f>
  800555:	89 75 08             	mov    %esi,0x8(%ebp)
  800558:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800561:	eb 0c                	jmp    80056f <vprintfmt+0x23f>
  800563:	89 75 08             	mov    %esi,0x8(%ebp)
  800566:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800569:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056f:	83 c7 01             	add    $0x1,%edi
  800572:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800576:	0f be d0             	movsbl %al,%edx
  800579:	85 d2                	test   %edx,%edx
  80057b:	74 23                	je     8005a0 <vprintfmt+0x270>
  80057d:	85 f6                	test   %esi,%esi
  80057f:	78 a1                	js     800522 <vprintfmt+0x1f2>
  800581:	83 ee 01             	sub    $0x1,%esi
  800584:	79 9c                	jns    800522 <vprintfmt+0x1f2>
  800586:	89 df                	mov    %ebx,%edi
  800588:	8b 75 08             	mov    0x8(%ebp),%esi
  80058b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058e:	eb 18                	jmp    8005a8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	53                   	push   %ebx
  800594:	6a 20                	push   $0x20
  800596:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800598:	83 ef 01             	sub    $0x1,%edi
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	eb 08                	jmp    8005a8 <vprintfmt+0x278>
  8005a0:	89 df                	mov    %ebx,%edi
  8005a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a8:	85 ff                	test   %edi,%edi
  8005aa:	7f e4                	jg     800590 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005af:	e9 a2 fd ff ff       	jmp    800356 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b4:	83 fa 01             	cmp    $0x1,%edx
  8005b7:	7e 16                	jle    8005cf <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 08             	lea    0x8(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 50 04             	mov    0x4(%eax),%edx
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cd:	eb 32                	jmp    800601 <vprintfmt+0x2d1>
	else if (lflag)
  8005cf:	85 d2                	test   %edx,%edx
  8005d1:	74 18                	je     8005eb <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 04             	lea    0x4(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e1:	89 c1                	mov    %eax,%ecx
  8005e3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e9:	eb 16                	jmp    800601 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 04             	lea    0x4(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	89 c1                	mov    %eax,%ecx
  8005fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800601:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800604:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800607:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800610:	79 74                	jns    800686 <vprintfmt+0x356>
				putch('-', putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 2d                	push   $0x2d
  800618:	ff d6                	call   *%esi
				num = -(long long) num;
  80061a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800620:	f7 d8                	neg    %eax
  800622:	83 d2 00             	adc    $0x0,%edx
  800625:	f7 da                	neg    %edx
  800627:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062f:	eb 55                	jmp    800686 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800631:	8d 45 14             	lea    0x14(%ebp),%eax
  800634:	e8 83 fc ff ff       	call   8002bc <getuint>
			base = 10;
  800639:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063e:	eb 46                	jmp    800686 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800640:	8d 45 14             	lea    0x14(%ebp),%eax
  800643:	e8 74 fc ff ff       	call   8002bc <getuint>
			base = 8;
  800648:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80064d:	eb 37                	jmp    800686 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 30                	push   $0x30
  800655:	ff d6                	call   *%esi
			putch('x', putdat);
  800657:	83 c4 08             	add    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 78                	push   $0x78
  80065d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800672:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800677:	eb 0d                	jmp    800686 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
  80067c:	e8 3b fc ff ff       	call   8002bc <getuint>
			base = 16;
  800681:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800686:	83 ec 0c             	sub    $0xc,%esp
  800689:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068d:	57                   	push   %edi
  80068e:	ff 75 e0             	pushl  -0x20(%ebp)
  800691:	51                   	push   %ecx
  800692:	52                   	push   %edx
  800693:	50                   	push   %eax
  800694:	89 da                	mov    %ebx,%edx
  800696:	89 f0                	mov    %esi,%eax
  800698:	e8 70 fb ff ff       	call   80020d <printnum>
			break;
  80069d:	83 c4 20             	add    $0x20,%esp
  8006a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a3:	e9 ae fc ff ff       	jmp    800356 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	51                   	push   %ecx
  8006ad:	ff d6                	call   *%esi
			break;
  8006af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b5:	e9 9c fc ff ff       	jmp    800356 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	53                   	push   %ebx
  8006be:	6a 25                	push   $0x25
  8006c0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 03                	jmp    8006ca <vprintfmt+0x39a>
  8006c7:	83 ef 01             	sub    $0x1,%edi
  8006ca:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ce:	75 f7                	jne    8006c7 <vprintfmt+0x397>
  8006d0:	e9 81 fc ff ff       	jmp    800356 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d8:	5b                   	pop    %ebx
  8006d9:	5e                   	pop    %esi
  8006da:	5f                   	pop    %edi
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 18             	sub    $0x18,%esp
  8006e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	74 26                	je     800724 <vsnprintf+0x47>
  8006fe:	85 d2                	test   %edx,%edx
  800700:	7e 22                	jle    800724 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800702:	ff 75 14             	pushl  0x14(%ebp)
  800705:	ff 75 10             	pushl  0x10(%ebp)
  800708:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070b:	50                   	push   %eax
  80070c:	68 f6 02 80 00       	push   $0x8002f6
  800711:	e8 1a fc ff ff       	call   800330 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800716:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800719:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	eb 05                	jmp    800729 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800724:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800734:	50                   	push   %eax
  800735:	ff 75 10             	pushl  0x10(%ebp)
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	ff 75 08             	pushl  0x8(%ebp)
  80073e:	e8 9a ff ff ff       	call   8006dd <vsnprintf>
	va_end(ap);

	return rc;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
  800750:	eb 03                	jmp    800755 <strlen+0x10>
		n++;
  800752:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800755:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800759:	75 f7                	jne    800752 <strlen+0xd>
		n++;
	return n;
}
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800763:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800766:	ba 00 00 00 00       	mov    $0x0,%edx
  80076b:	eb 03                	jmp    800770 <strnlen+0x13>
		n++;
  80076d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800770:	39 c2                	cmp    %eax,%edx
  800772:	74 08                	je     80077c <strnlen+0x1f>
  800774:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800778:	75 f3                	jne    80076d <strnlen+0x10>
  80077a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	53                   	push   %ebx
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800788:	89 c2                	mov    %eax,%edx
  80078a:	83 c2 01             	add    $0x1,%edx
  80078d:	83 c1 01             	add    $0x1,%ecx
  800790:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800794:	88 5a ff             	mov    %bl,-0x1(%edx)
  800797:	84 db                	test   %bl,%bl
  800799:	75 ef                	jne    80078a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079b:	5b                   	pop    %ebx
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	53                   	push   %ebx
  8007a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a5:	53                   	push   %ebx
  8007a6:	e8 9a ff ff ff       	call   800745 <strlen>
  8007ab:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ae:	ff 75 0c             	pushl  0xc(%ebp)
  8007b1:	01 d8                	add    %ebx,%eax
  8007b3:	50                   	push   %eax
  8007b4:	e8 c5 ff ff ff       	call   80077e <strcpy>
	return dst;
}
  8007b9:	89 d8                	mov    %ebx,%eax
  8007bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	56                   	push   %esi
  8007c4:	53                   	push   %ebx
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cb:	89 f3                	mov    %esi,%ebx
  8007cd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	89 f2                	mov    %esi,%edx
  8007d2:	eb 0f                	jmp    8007e3 <strncpy+0x23>
		*dst++ = *src;
  8007d4:	83 c2 01             	add    $0x1,%edx
  8007d7:	0f b6 01             	movzbl (%ecx),%eax
  8007da:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007dd:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e3:	39 da                	cmp    %ebx,%edx
  8007e5:	75 ed                	jne    8007d4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e7:	89 f0                	mov    %esi,%eax
  8007e9:	5b                   	pop    %ebx
  8007ea:	5e                   	pop    %esi
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f8:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fd:	85 d2                	test   %edx,%edx
  8007ff:	74 21                	je     800822 <strlcpy+0x35>
  800801:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800805:	89 f2                	mov    %esi,%edx
  800807:	eb 09                	jmp    800812 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800809:	83 c2 01             	add    $0x1,%edx
  80080c:	83 c1 01             	add    $0x1,%ecx
  80080f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800812:	39 c2                	cmp    %eax,%edx
  800814:	74 09                	je     80081f <strlcpy+0x32>
  800816:	0f b6 19             	movzbl (%ecx),%ebx
  800819:	84 db                	test   %bl,%bl
  80081b:	75 ec                	jne    800809 <strlcpy+0x1c>
  80081d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800822:	29 f0                	sub    %esi,%eax
}
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800831:	eb 06                	jmp    800839 <strcmp+0x11>
		p++, q++;
  800833:	83 c1 01             	add    $0x1,%ecx
  800836:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800839:	0f b6 01             	movzbl (%ecx),%eax
  80083c:	84 c0                	test   %al,%al
  80083e:	74 04                	je     800844 <strcmp+0x1c>
  800840:	3a 02                	cmp    (%edx),%al
  800842:	74 ef                	je     800833 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800844:	0f b6 c0             	movzbl %al,%eax
  800847:	0f b6 12             	movzbl (%edx),%edx
  80084a:	29 d0                	sub    %edx,%eax
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	53                   	push   %ebx
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	8b 55 0c             	mov    0xc(%ebp),%edx
  800858:	89 c3                	mov    %eax,%ebx
  80085a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085d:	eb 06                	jmp    800865 <strncmp+0x17>
		n--, p++, q++;
  80085f:	83 c0 01             	add    $0x1,%eax
  800862:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800865:	39 d8                	cmp    %ebx,%eax
  800867:	74 15                	je     80087e <strncmp+0x30>
  800869:	0f b6 08             	movzbl (%eax),%ecx
  80086c:	84 c9                	test   %cl,%cl
  80086e:	74 04                	je     800874 <strncmp+0x26>
  800870:	3a 0a                	cmp    (%edx),%cl
  800872:	74 eb                	je     80085f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800874:	0f b6 00             	movzbl (%eax),%eax
  800877:	0f b6 12             	movzbl (%edx),%edx
  80087a:	29 d0                	sub    %edx,%eax
  80087c:	eb 05                	jmp    800883 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800883:	5b                   	pop    %ebx
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800890:	eb 07                	jmp    800899 <strchr+0x13>
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 0f                	je     8008a5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	0f b6 10             	movzbl (%eax),%edx
  80089c:	84 d2                	test   %dl,%dl
  80089e:	75 f2                	jne    800892 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b1:	eb 03                	jmp    8008b6 <strfind+0xf>
  8008b3:	83 c0 01             	add    $0x1,%eax
  8008b6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b9:	38 ca                	cmp    %cl,%dl
  8008bb:	74 04                	je     8008c1 <strfind+0x1a>
  8008bd:	84 d2                	test   %dl,%dl
  8008bf:	75 f2                	jne    8008b3 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	57                   	push   %edi
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cf:	85 c9                	test   %ecx,%ecx
  8008d1:	74 36                	je     800909 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d9:	75 28                	jne    800903 <memset+0x40>
  8008db:	f6 c1 03             	test   $0x3,%cl
  8008de:	75 23                	jne    800903 <memset+0x40>
		c &= 0xFF;
  8008e0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e4:	89 d3                	mov    %edx,%ebx
  8008e6:	c1 e3 08             	shl    $0x8,%ebx
  8008e9:	89 d6                	mov    %edx,%esi
  8008eb:	c1 e6 18             	shl    $0x18,%esi
  8008ee:	89 d0                	mov    %edx,%eax
  8008f0:	c1 e0 10             	shl    $0x10,%eax
  8008f3:	09 f0                	or     %esi,%eax
  8008f5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f7:	89 d8                	mov    %ebx,%eax
  8008f9:	09 d0                	or     %edx,%eax
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
  8008fe:	fc                   	cld    
  8008ff:	f3 ab                	rep stos %eax,%es:(%edi)
  800901:	eb 06                	jmp    800909 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800903:	8b 45 0c             	mov    0xc(%ebp),%eax
  800906:	fc                   	cld    
  800907:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800909:	89 f8                	mov    %edi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5f                   	pop    %edi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	57                   	push   %edi
  800914:	56                   	push   %esi
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091e:	39 c6                	cmp    %eax,%esi
  800920:	73 35                	jae    800957 <memmove+0x47>
  800922:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800925:	39 d0                	cmp    %edx,%eax
  800927:	73 2e                	jae    800957 <memmove+0x47>
		s += n;
		d += n;
  800929:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092c:	89 d6                	mov    %edx,%esi
  80092e:	09 fe                	or     %edi,%esi
  800930:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800936:	75 13                	jne    80094b <memmove+0x3b>
  800938:	f6 c1 03             	test   $0x3,%cl
  80093b:	75 0e                	jne    80094b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093d:	83 ef 04             	sub    $0x4,%edi
  800940:	8d 72 fc             	lea    -0x4(%edx),%esi
  800943:	c1 e9 02             	shr    $0x2,%ecx
  800946:	fd                   	std    
  800947:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800949:	eb 09                	jmp    800954 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094b:	83 ef 01             	sub    $0x1,%edi
  80094e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800951:	fd                   	std    
  800952:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800954:	fc                   	cld    
  800955:	eb 1d                	jmp    800974 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800957:	89 f2                	mov    %esi,%edx
  800959:	09 c2                	or     %eax,%edx
  80095b:	f6 c2 03             	test   $0x3,%dl
  80095e:	75 0f                	jne    80096f <memmove+0x5f>
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	75 0a                	jne    80096f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800965:	c1 e9 02             	shr    $0x2,%ecx
  800968:	89 c7                	mov    %eax,%edi
  80096a:	fc                   	cld    
  80096b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096d:	eb 05                	jmp    800974 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096f:	89 c7                	mov    %eax,%edi
  800971:	fc                   	cld    
  800972:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800974:	5e                   	pop    %esi
  800975:	5f                   	pop    %edi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097b:	ff 75 10             	pushl  0x10(%ebp)
  80097e:	ff 75 0c             	pushl  0xc(%ebp)
  800981:	ff 75 08             	pushl  0x8(%ebp)
  800984:	e8 87 ff ff ff       	call   800910 <memmove>
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 55 0c             	mov    0xc(%ebp),%edx
  800996:	89 c6                	mov    %eax,%esi
  800998:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099b:	eb 1a                	jmp    8009b7 <memcmp+0x2c>
		if (*s1 != *s2)
  80099d:	0f b6 08             	movzbl (%eax),%ecx
  8009a0:	0f b6 1a             	movzbl (%edx),%ebx
  8009a3:	38 d9                	cmp    %bl,%cl
  8009a5:	74 0a                	je     8009b1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a7:	0f b6 c1             	movzbl %cl,%eax
  8009aa:	0f b6 db             	movzbl %bl,%ebx
  8009ad:	29 d8                	sub    %ebx,%eax
  8009af:	eb 0f                	jmp    8009c0 <memcmp+0x35>
		s1++, s2++;
  8009b1:	83 c0 01             	add    $0x1,%eax
  8009b4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	39 f0                	cmp    %esi,%eax
  8009b9:	75 e2                	jne    80099d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009cb:	89 c1                	mov    %eax,%ecx
  8009cd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d4:	eb 0a                	jmp    8009e0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d6:	0f b6 10             	movzbl (%eax),%edx
  8009d9:	39 da                	cmp    %ebx,%edx
  8009db:	74 07                	je     8009e4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009dd:	83 c0 01             	add    $0x1,%eax
  8009e0:	39 c8                	cmp    %ecx,%eax
  8009e2:	72 f2                	jb     8009d6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f3:	eb 03                	jmp    8009f8 <strtol+0x11>
		s++;
  8009f5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f8:	0f b6 01             	movzbl (%ecx),%eax
  8009fb:	3c 20                	cmp    $0x20,%al
  8009fd:	74 f6                	je     8009f5 <strtol+0xe>
  8009ff:	3c 09                	cmp    $0x9,%al
  800a01:	74 f2                	je     8009f5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a03:	3c 2b                	cmp    $0x2b,%al
  800a05:	75 0a                	jne    800a11 <strtol+0x2a>
		s++;
  800a07:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0f:	eb 11                	jmp    800a22 <strtol+0x3b>
  800a11:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a16:	3c 2d                	cmp    $0x2d,%al
  800a18:	75 08                	jne    800a22 <strtol+0x3b>
		s++, neg = 1;
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a28:	75 15                	jne    800a3f <strtol+0x58>
  800a2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2d:	75 10                	jne    800a3f <strtol+0x58>
  800a2f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a33:	75 7c                	jne    800ab1 <strtol+0xca>
		s += 2, base = 16;
  800a35:	83 c1 02             	add    $0x2,%ecx
  800a38:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3d:	eb 16                	jmp    800a55 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3f:	85 db                	test   %ebx,%ebx
  800a41:	75 12                	jne    800a55 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a43:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a48:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4b:	75 08                	jne    800a55 <strtol+0x6e>
		s++, base = 8;
  800a4d:	83 c1 01             	add    $0x1,%ecx
  800a50:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5d:	0f b6 11             	movzbl (%ecx),%edx
  800a60:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a63:	89 f3                	mov    %esi,%ebx
  800a65:	80 fb 09             	cmp    $0x9,%bl
  800a68:	77 08                	ja     800a72 <strtol+0x8b>
			dig = *s - '0';
  800a6a:	0f be d2             	movsbl %dl,%edx
  800a6d:	83 ea 30             	sub    $0x30,%edx
  800a70:	eb 22                	jmp    800a94 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a72:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a75:	89 f3                	mov    %esi,%ebx
  800a77:	80 fb 19             	cmp    $0x19,%bl
  800a7a:	77 08                	ja     800a84 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7c:	0f be d2             	movsbl %dl,%edx
  800a7f:	83 ea 57             	sub    $0x57,%edx
  800a82:	eb 10                	jmp    800a94 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a84:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a87:	89 f3                	mov    %esi,%ebx
  800a89:	80 fb 19             	cmp    $0x19,%bl
  800a8c:	77 16                	ja     800aa4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8e:	0f be d2             	movsbl %dl,%edx
  800a91:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a94:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a97:	7d 0b                	jge    800aa4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a99:	83 c1 01             	add    $0x1,%ecx
  800a9c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa2:	eb b9                	jmp    800a5d <strtol+0x76>

	if (endptr)
  800aa4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa8:	74 0d                	je     800ab7 <strtol+0xd0>
		*endptr = (char *) s;
  800aaa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aad:	89 0e                	mov    %ecx,(%esi)
  800aaf:	eb 06                	jmp    800ab7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab1:	85 db                	test   %ebx,%ebx
  800ab3:	74 98                	je     800a4d <strtol+0x66>
  800ab5:	eb 9e                	jmp    800a55 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab7:	89 c2                	mov    %eax,%edx
  800ab9:	f7 da                	neg    %edx
  800abb:	85 ff                	test   %edi,%edi
  800abd:	0f 45 c2             	cmovne %edx,%eax
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad6:	89 c3                	mov    %eax,%ebx
  800ad8:	89 c7                	mov    %eax,%edi
  800ada:	89 c6                	mov    %eax,%esi
  800adc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aee:	b8 01 00 00 00       	mov    $0x1,%eax
  800af3:	89 d1                	mov    %edx,%ecx
  800af5:	89 d3                	mov    %edx,%ebx
  800af7:	89 d7                	mov    %edx,%edi
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b10:	b8 03 00 00 00       	mov    $0x3,%eax
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	89 cb                	mov    %ecx,%ebx
  800b1a:	89 cf                	mov    %ecx,%edi
  800b1c:	89 ce                	mov    %ecx,%esi
  800b1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b20:	85 c0                	test   %eax,%eax
  800b22:	7e 17                	jle    800b3b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	50                   	push   %eax
  800b28:	6a 03                	push   $0x3
  800b2a:	68 1f 25 80 00       	push   $0x80251f
  800b2f:	6a 23                	push   $0x23
  800b31:	68 3c 25 80 00       	push   $0x80253c
  800b36:	e8 eb 12 00 00       	call   801e26 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b53:	89 d1                	mov    %edx,%ecx
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	89 d7                	mov    %edx,%edi
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_yield>:

void
sys_yield(void)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	be 00 00 00 00       	mov    $0x0,%esi
  800b8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9d:	89 f7                	mov    %esi,%edi
  800b9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 04                	push   $0x4
  800bab:	68 1f 25 80 00       	push   $0x80251f
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 3c 25 80 00       	push   $0x80253c
  800bb7:	e8 6a 12 00 00       	call   801e26 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bde:	8b 75 18             	mov    0x18(%ebp),%esi
  800be1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 05                	push   $0x5
  800bed:	68 1f 25 80 00       	push   $0x80251f
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 3c 25 80 00       	push   $0x80253c
  800bf9:	e8 28 12 00 00       	call   801e26 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c14:	b8 06 00 00 00       	mov    $0x6,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 df                	mov    %ebx,%edi
  800c21:	89 de                	mov    %ebx,%esi
  800c23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 06                	push   $0x6
  800c2f:	68 1f 25 80 00       	push   $0x80251f
  800c34:	6a 23                	push   $0x23
  800c36:	68 3c 25 80 00       	push   $0x80253c
  800c3b:	e8 e6 11 00 00       	call   801e26 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 08                	push   $0x8
  800c71:	68 1f 25 80 00       	push   $0x80251f
  800c76:	6a 23                	push   $0x23
  800c78:	68 3c 25 80 00       	push   $0x80253c
  800c7d:	e8 a4 11 00 00       	call   801e26 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 09                	push   $0x9
  800cb3:	68 1f 25 80 00       	push   $0x80251f
  800cb8:	6a 23                	push   $0x23
  800cba:	68 3c 25 80 00       	push   $0x80253c
  800cbf:	e8 62 11 00 00       	call   801e26 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 0a                	push   $0xa
  800cf5:	68 1f 25 80 00       	push   $0x80251f
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 3c 25 80 00       	push   $0x80253c
  800d01:	e8 20 11 00 00       	call   801e26 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	be 00 00 00 00       	mov    $0x0,%esi
  800d19:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 cb                	mov    %ecx,%ebx
  800d49:	89 cf                	mov    %ecx,%edi
  800d4b:	89 ce                	mov    %ecx,%esi
  800d4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 17                	jle    800d6a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 0d                	push   $0xd
  800d59:	68 1f 25 80 00       	push   $0x80251f
  800d5e:	6a 23                	push   $0x23
  800d60:	68 3c 25 80 00       	push   $0x80253c
  800d65:	e8 bc 10 00 00       	call   801e26 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	53                   	push   %ebx
  800d76:	83 ec 04             	sub    $0x4,%esp
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d7c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800d7e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d82:	74 11                	je     800d95 <pgfault+0x23>
  800d84:	89 d8                	mov    %ebx,%eax
  800d86:	c1 e8 0c             	shr    $0xc,%eax
  800d89:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d90:	f6 c4 08             	test   $0x8,%ah
  800d93:	75 14                	jne    800da9 <pgfault+0x37>
		panic("faulting access");
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	68 4a 25 80 00       	push   $0x80254a
  800d9d:	6a 1d                	push   $0x1d
  800d9f:	68 5a 25 80 00       	push   $0x80255a
  800da4:	e8 7d 10 00 00       	call   801e26 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	6a 07                	push   $0x7
  800dae:	68 00 f0 7f 00       	push   $0x7ff000
  800db3:	6a 00                	push   $0x0
  800db5:	e8 c7 fd ff ff       	call   800b81 <sys_page_alloc>
	if (r < 0) {
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	79 12                	jns    800dd3 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dc1:	50                   	push   %eax
  800dc2:	68 65 25 80 00       	push   $0x802565
  800dc7:	6a 2b                	push   $0x2b
  800dc9:	68 5a 25 80 00       	push   $0x80255a
  800dce:	e8 53 10 00 00       	call   801e26 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800dd3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dd9:	83 ec 04             	sub    $0x4,%esp
  800ddc:	68 00 10 00 00       	push   $0x1000
  800de1:	53                   	push   %ebx
  800de2:	68 00 f0 7f 00       	push   $0x7ff000
  800de7:	e8 8c fb ff ff       	call   800978 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800dec:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800df3:	53                   	push   %ebx
  800df4:	6a 00                	push   $0x0
  800df6:	68 00 f0 7f 00       	push   $0x7ff000
  800dfb:	6a 00                	push   $0x0
  800dfd:	e8 c2 fd ff ff       	call   800bc4 <sys_page_map>
	if (r < 0) {
  800e02:	83 c4 20             	add    $0x20,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	79 12                	jns    800e1b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e09:	50                   	push   %eax
  800e0a:	68 65 25 80 00       	push   $0x802565
  800e0f:	6a 32                	push   $0x32
  800e11:	68 5a 25 80 00       	push   $0x80255a
  800e16:	e8 0b 10 00 00       	call   801e26 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e1b:	83 ec 08             	sub    $0x8,%esp
  800e1e:	68 00 f0 7f 00       	push   $0x7ff000
  800e23:	6a 00                	push   $0x0
  800e25:	e8 dc fd ff ff       	call   800c06 <sys_page_unmap>
	if (r < 0) {
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	79 12                	jns    800e43 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e31:	50                   	push   %eax
  800e32:	68 65 25 80 00       	push   $0x802565
  800e37:	6a 36                	push   $0x36
  800e39:	68 5a 25 80 00       	push   $0x80255a
  800e3e:	e8 e3 0f 00 00       	call   801e26 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    

00800e48 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e51:	68 72 0d 80 00       	push   $0x800d72
  800e56:	e8 11 10 00 00       	call   801e6c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e5b:	b8 07 00 00 00       	mov    $0x7,%eax
  800e60:	cd 30                	int    $0x30
  800e62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	79 17                	jns    800e83 <fork+0x3b>
		panic("fork fault %e");
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	68 7e 25 80 00       	push   $0x80257e
  800e74:	68 83 00 00 00       	push   $0x83
  800e79:	68 5a 25 80 00       	push   $0x80255a
  800e7e:	e8 a3 0f 00 00       	call   801e26 <_panic>
  800e83:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800e85:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e89:	75 21                	jne    800eac <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e8b:	e8 b3 fc ff ff       	call   800b43 <sys_getenvid>
  800e90:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e95:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e98:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e9d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	e9 61 01 00 00       	jmp    80100d <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	6a 07                	push   $0x7
  800eb1:	68 00 f0 bf ee       	push   $0xeebff000
  800eb6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800eb9:	e8 c3 fc ff ff       	call   800b81 <sys_page_alloc>
  800ebe:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ec1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ec6:	89 d8                	mov    %ebx,%eax
  800ec8:	c1 e8 16             	shr    $0x16,%eax
  800ecb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed2:	a8 01                	test   $0x1,%al
  800ed4:	0f 84 fc 00 00 00    	je     800fd6 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800eda:	89 d8                	mov    %ebx,%eax
  800edc:	c1 e8 0c             	shr    $0xc,%eax
  800edf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee6:	f6 c2 01             	test   $0x1,%dl
  800ee9:	0f 84 e7 00 00 00    	je     800fd6 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800eef:	89 c6                	mov    %eax,%esi
  800ef1:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800ef4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efb:	f6 c6 04             	test   $0x4,%dh
  800efe:	74 39                	je     800f39 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f00:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f0f:	50                   	push   %eax
  800f10:	56                   	push   %esi
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	6a 00                	push   $0x0
  800f15:	e8 aa fc ff ff       	call   800bc4 <sys_page_map>
		if (r < 0) {
  800f1a:	83 c4 20             	add    $0x20,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	0f 89 b1 00 00 00    	jns    800fd6 <fork+0x18e>
		    	panic("sys page map fault %e");
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	68 8c 25 80 00       	push   $0x80258c
  800f2d:	6a 53                	push   $0x53
  800f2f:	68 5a 25 80 00       	push   $0x80255a
  800f34:	e8 ed 0e 00 00       	call   801e26 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f39:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f40:	f6 c2 02             	test   $0x2,%dl
  800f43:	75 0c                	jne    800f51 <fork+0x109>
  800f45:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4c:	f6 c4 08             	test   $0x8,%ah
  800f4f:	74 5b                	je     800fac <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	68 05 08 00 00       	push   $0x805
  800f59:	56                   	push   %esi
  800f5a:	57                   	push   %edi
  800f5b:	56                   	push   %esi
  800f5c:	6a 00                	push   $0x0
  800f5e:	e8 61 fc ff ff       	call   800bc4 <sys_page_map>
		if (r < 0) {
  800f63:	83 c4 20             	add    $0x20,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	79 14                	jns    800f7e <fork+0x136>
		    	panic("sys page map fault %e");
  800f6a:	83 ec 04             	sub    $0x4,%esp
  800f6d:	68 8c 25 80 00       	push   $0x80258c
  800f72:	6a 5a                	push   $0x5a
  800f74:	68 5a 25 80 00       	push   $0x80255a
  800f79:	e8 a8 0e 00 00       	call   801e26 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	68 05 08 00 00       	push   $0x805
  800f86:	56                   	push   %esi
  800f87:	6a 00                	push   $0x0
  800f89:	56                   	push   %esi
  800f8a:	6a 00                	push   $0x0
  800f8c:	e8 33 fc ff ff       	call   800bc4 <sys_page_map>
		if (r < 0) {
  800f91:	83 c4 20             	add    $0x20,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	79 3e                	jns    800fd6 <fork+0x18e>
		    	panic("sys page map fault %e");
  800f98:	83 ec 04             	sub    $0x4,%esp
  800f9b:	68 8c 25 80 00       	push   $0x80258c
  800fa0:	6a 5e                	push   $0x5e
  800fa2:	68 5a 25 80 00       	push   $0x80255a
  800fa7:	e8 7a 0e 00 00       	call   801e26 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	6a 05                	push   $0x5
  800fb1:	56                   	push   %esi
  800fb2:	57                   	push   %edi
  800fb3:	56                   	push   %esi
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 09 fc ff ff       	call   800bc4 <sys_page_map>
		if (r < 0) {
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	79 14                	jns    800fd6 <fork+0x18e>
		    	panic("sys page map fault %e");
  800fc2:	83 ec 04             	sub    $0x4,%esp
  800fc5:	68 8c 25 80 00       	push   $0x80258c
  800fca:	6a 63                	push   $0x63
  800fcc:	68 5a 25 80 00       	push   $0x80255a
  800fd1:	e8 50 0e 00 00       	call   801e26 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800fd6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fdc:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fe2:	0f 85 de fe ff ff    	jne    800ec6 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800fe8:	a1 04 40 80 00       	mov    0x804004,%eax
  800fed:	8b 40 64             	mov    0x64(%eax),%eax
  800ff0:	83 ec 08             	sub    $0x8,%esp
  800ff3:	50                   	push   %eax
  800ff4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ff7:	57                   	push   %edi
  800ff8:	e8 cf fc ff ff       	call   800ccc <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800ffd:	83 c4 08             	add    $0x8,%esp
  801000:	6a 02                	push   $0x2
  801002:	57                   	push   %edi
  801003:	e8 40 fc ff ff       	call   800c48 <sys_env_set_status>
	
	return envid;
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sfork>:

// Challenge!
int
sfork(void)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80101b:	68 a2 25 80 00       	push   $0x8025a2
  801020:	68 a1 00 00 00       	push   $0xa1
  801025:	68 5a 25 80 00       	push   $0x80255a
  80102a:	e8 f7 0d 00 00       	call   801e26 <_panic>

0080102f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
  801034:	8b 75 08             	mov    0x8(%ebp),%esi
  801037:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80103d:	85 c0                	test   %eax,%eax
  80103f:	75 12                	jne    801053 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	68 00 00 c0 ee       	push   $0xeec00000
  801049:	e8 e3 fc ff ff       	call   800d31 <sys_ipc_recv>
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	eb 0c                	jmp    80105f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	50                   	push   %eax
  801057:	e8 d5 fc ff ff       	call   800d31 <sys_ipc_recv>
  80105c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80105f:	85 f6                	test   %esi,%esi
  801061:	0f 95 c1             	setne  %cl
  801064:	85 db                	test   %ebx,%ebx
  801066:	0f 95 c2             	setne  %dl
  801069:	84 d1                	test   %dl,%cl
  80106b:	74 09                	je     801076 <ipc_recv+0x47>
  80106d:	89 c2                	mov    %eax,%edx
  80106f:	c1 ea 1f             	shr    $0x1f,%edx
  801072:	84 d2                	test   %dl,%dl
  801074:	75 24                	jne    80109a <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801076:	85 f6                	test   %esi,%esi
  801078:	74 0a                	je     801084 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80107a:	a1 04 40 80 00       	mov    0x804004,%eax
  80107f:	8b 40 74             	mov    0x74(%eax),%eax
  801082:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801084:	85 db                	test   %ebx,%ebx
  801086:	74 0a                	je     801092 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801088:	a1 04 40 80 00       	mov    0x804004,%eax
  80108d:	8b 40 78             	mov    0x78(%eax),%eax
  801090:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801092:	a1 04 40 80 00       	mov    0x804004,%eax
  801097:	8b 40 70             	mov    0x70(%eax),%eax
}
  80109a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    

008010a1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	57                   	push   %edi
  8010a5:	56                   	push   %esi
  8010a6:	53                   	push   %ebx
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8010b3:	85 db                	test   %ebx,%ebx
  8010b5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010ba:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8010bd:	ff 75 14             	pushl  0x14(%ebp)
  8010c0:	53                   	push   %ebx
  8010c1:	56                   	push   %esi
  8010c2:	57                   	push   %edi
  8010c3:	e8 46 fc ff ff       	call   800d0e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8010c8:	89 c2                	mov    %eax,%edx
  8010ca:	c1 ea 1f             	shr    $0x1f,%edx
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	84 d2                	test   %dl,%dl
  8010d2:	74 17                	je     8010eb <ipc_send+0x4a>
  8010d4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010d7:	74 12                	je     8010eb <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8010d9:	50                   	push   %eax
  8010da:	68 b8 25 80 00       	push   $0x8025b8
  8010df:	6a 47                	push   $0x47
  8010e1:	68 c6 25 80 00       	push   $0x8025c6
  8010e6:	e8 3b 0d 00 00       	call   801e26 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8010eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010ee:	75 07                	jne    8010f7 <ipc_send+0x56>
			sys_yield();
  8010f0:	e8 6d fa ff ff       	call   800b62 <sys_yield>
  8010f5:	eb c6                	jmp    8010bd <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	75 c2                	jne    8010bd <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8010fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5f                   	pop    %edi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    

00801103 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801109:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80110e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801111:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801117:	8b 52 50             	mov    0x50(%edx),%edx
  80111a:	39 ca                	cmp    %ecx,%edx
  80111c:	75 0d                	jne    80112b <ipc_find_env+0x28>
			return envs[i].env_id;
  80111e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801121:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801126:	8b 40 48             	mov    0x48(%eax),%eax
  801129:	eb 0f                	jmp    80113a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80112b:	83 c0 01             	add    $0x1,%eax
  80112e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801133:	75 d9                	jne    80110e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801135:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80113a:	5d                   	pop    %ebp
  80113b:	c3                   	ret    

0080113c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	05 00 00 00 30       	add    $0x30000000,%eax
  801147:	c1 e8 0c             	shr    $0xc,%eax
}
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    

0080114c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	05 00 00 00 30       	add    $0x30000000,%eax
  801157:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80115c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    

00801163 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801169:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80116e:	89 c2                	mov    %eax,%edx
  801170:	c1 ea 16             	shr    $0x16,%edx
  801173:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117a:	f6 c2 01             	test   $0x1,%dl
  80117d:	74 11                	je     801190 <fd_alloc+0x2d>
  80117f:	89 c2                	mov    %eax,%edx
  801181:	c1 ea 0c             	shr    $0xc,%edx
  801184:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118b:	f6 c2 01             	test   $0x1,%dl
  80118e:	75 09                	jne    801199 <fd_alloc+0x36>
			*fd_store = fd;
  801190:	89 01                	mov    %eax,(%ecx)
			return 0;
  801192:	b8 00 00 00 00       	mov    $0x0,%eax
  801197:	eb 17                	jmp    8011b0 <fd_alloc+0x4d>
  801199:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80119e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a3:	75 c9                	jne    80116e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    

008011b2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b8:	83 f8 1f             	cmp    $0x1f,%eax
  8011bb:	77 36                	ja     8011f3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011bd:	c1 e0 0c             	shl    $0xc,%eax
  8011c0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c5:	89 c2                	mov    %eax,%edx
  8011c7:	c1 ea 16             	shr    $0x16,%edx
  8011ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d1:	f6 c2 01             	test   $0x1,%dl
  8011d4:	74 24                	je     8011fa <fd_lookup+0x48>
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	c1 ea 0c             	shr    $0xc,%edx
  8011db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	74 1a                	je     801201 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ea:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f1:	eb 13                	jmp    801206 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f8:	eb 0c                	jmp    801206 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ff:	eb 05                	jmp    801206 <fd_lookup+0x54>
  801201:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801211:	ba 4c 26 80 00       	mov    $0x80264c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801216:	eb 13                	jmp    80122b <dev_lookup+0x23>
  801218:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80121b:	39 08                	cmp    %ecx,(%eax)
  80121d:	75 0c                	jne    80122b <dev_lookup+0x23>
			*dev = devtab[i];
  80121f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801222:	89 01                	mov    %eax,(%ecx)
			return 0;
  801224:	b8 00 00 00 00       	mov    $0x0,%eax
  801229:	eb 2e                	jmp    801259 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80122b:	8b 02                	mov    (%edx),%eax
  80122d:	85 c0                	test   %eax,%eax
  80122f:	75 e7                	jne    801218 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801231:	a1 04 40 80 00       	mov    0x804004,%eax
  801236:	8b 40 48             	mov    0x48(%eax),%eax
  801239:	83 ec 04             	sub    $0x4,%esp
  80123c:	51                   	push   %ecx
  80123d:	50                   	push   %eax
  80123e:	68 d0 25 80 00       	push   $0x8025d0
  801243:	e8 b1 ef ff ff       	call   8001f9 <cprintf>
	*dev = 0;
  801248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	56                   	push   %esi
  80125f:	53                   	push   %ebx
  801260:	83 ec 10             	sub    $0x10,%esp
  801263:	8b 75 08             	mov    0x8(%ebp),%esi
  801266:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801269:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801273:	c1 e8 0c             	shr    $0xc,%eax
  801276:	50                   	push   %eax
  801277:	e8 36 ff ff ff       	call   8011b2 <fd_lookup>
  80127c:	83 c4 08             	add    $0x8,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 05                	js     801288 <fd_close+0x2d>
	    || fd != fd2)
  801283:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801286:	74 0c                	je     801294 <fd_close+0x39>
		return (must_exist ? r : 0);
  801288:	84 db                	test   %bl,%bl
  80128a:	ba 00 00 00 00       	mov    $0x0,%edx
  80128f:	0f 44 c2             	cmove  %edx,%eax
  801292:	eb 41                	jmp    8012d5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	ff 36                	pushl  (%esi)
  80129d:	e8 66 ff ff ff       	call   801208 <dev_lookup>
  8012a2:	89 c3                	mov    %eax,%ebx
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 1a                	js     8012c5 <fd_close+0x6a>
		if (dev->dev_close)
  8012ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ae:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012b1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	74 0b                	je     8012c5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012ba:	83 ec 0c             	sub    $0xc,%esp
  8012bd:	56                   	push   %esi
  8012be:	ff d0                	call   *%eax
  8012c0:	89 c3                	mov    %eax,%ebx
  8012c2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	56                   	push   %esi
  8012c9:	6a 00                	push   $0x0
  8012cb:	e8 36 f9 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	89 d8                	mov    %ebx,%eax
}
  8012d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	ff 75 08             	pushl  0x8(%ebp)
  8012e9:	e8 c4 fe ff ff       	call   8011b2 <fd_lookup>
  8012ee:	83 c4 08             	add    $0x8,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 10                	js     801305 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	6a 01                	push   $0x1
  8012fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8012fd:	e8 59 ff ff ff       	call   80125b <fd_close>
  801302:	83 c4 10             	add    $0x10,%esp
}
  801305:	c9                   	leave  
  801306:	c3                   	ret    

00801307 <close_all>:

void
close_all(void)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	53                   	push   %ebx
  80130b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80130e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	53                   	push   %ebx
  801317:	e8 c0 ff ff ff       	call   8012dc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80131c:	83 c3 01             	add    $0x1,%ebx
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	83 fb 20             	cmp    $0x20,%ebx
  801325:	75 ec                	jne    801313 <close_all+0xc>
		close(i);
}
  801327:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	57                   	push   %edi
  801330:	56                   	push   %esi
  801331:	53                   	push   %ebx
  801332:	83 ec 2c             	sub    $0x2c,%esp
  801335:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801338:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 75 08             	pushl  0x8(%ebp)
  80133f:	e8 6e fe ff ff       	call   8011b2 <fd_lookup>
  801344:	83 c4 08             	add    $0x8,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	0f 88 c1 00 00 00    	js     801410 <dup+0xe4>
		return r;
	close(newfdnum);
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	56                   	push   %esi
  801353:	e8 84 ff ff ff       	call   8012dc <close>

	newfd = INDEX2FD(newfdnum);
  801358:	89 f3                	mov    %esi,%ebx
  80135a:	c1 e3 0c             	shl    $0xc,%ebx
  80135d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801363:	83 c4 04             	add    $0x4,%esp
  801366:	ff 75 e4             	pushl  -0x1c(%ebp)
  801369:	e8 de fd ff ff       	call   80114c <fd2data>
  80136e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801370:	89 1c 24             	mov    %ebx,(%esp)
  801373:	e8 d4 fd ff ff       	call   80114c <fd2data>
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137e:	89 f8                	mov    %edi,%eax
  801380:	c1 e8 16             	shr    $0x16,%eax
  801383:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80138a:	a8 01                	test   $0x1,%al
  80138c:	74 37                	je     8013c5 <dup+0x99>
  80138e:	89 f8                	mov    %edi,%eax
  801390:	c1 e8 0c             	shr    $0xc,%eax
  801393:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80139a:	f6 c2 01             	test   $0x1,%dl
  80139d:	74 26                	je     8013c5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a6:	83 ec 0c             	sub    $0xc,%esp
  8013a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ae:	50                   	push   %eax
  8013af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b2:	6a 00                	push   $0x0
  8013b4:	57                   	push   %edi
  8013b5:	6a 00                	push   $0x0
  8013b7:	e8 08 f8 ff ff       	call   800bc4 <sys_page_map>
  8013bc:	89 c7                	mov    %eax,%edi
  8013be:	83 c4 20             	add    $0x20,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 2e                	js     8013f3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c8:	89 d0                	mov    %edx,%eax
  8013ca:	c1 e8 0c             	shr    $0xc,%eax
  8013cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d4:	83 ec 0c             	sub    $0xc,%esp
  8013d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8013dc:	50                   	push   %eax
  8013dd:	53                   	push   %ebx
  8013de:	6a 00                	push   $0x0
  8013e0:	52                   	push   %edx
  8013e1:	6a 00                	push   $0x0
  8013e3:	e8 dc f7 ff ff       	call   800bc4 <sys_page_map>
  8013e8:	89 c7                	mov    %eax,%edi
  8013ea:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013ed:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ef:	85 ff                	test   %edi,%edi
  8013f1:	79 1d                	jns    801410 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	53                   	push   %ebx
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 08 f8 ff ff       	call   800c06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fe:	83 c4 08             	add    $0x8,%esp
  801401:	ff 75 d4             	pushl  -0x2c(%ebp)
  801404:	6a 00                	push   $0x0
  801406:	e8 fb f7 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	89 f8                	mov    %edi,%eax
}
  801410:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801413:	5b                   	pop    %ebx
  801414:	5e                   	pop    %esi
  801415:	5f                   	pop    %edi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    

00801418 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	53                   	push   %ebx
  80141c:	83 ec 14             	sub    $0x14,%esp
  80141f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801422:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801425:	50                   	push   %eax
  801426:	53                   	push   %ebx
  801427:	e8 86 fd ff ff       	call   8011b2 <fd_lookup>
  80142c:	83 c4 08             	add    $0x8,%esp
  80142f:	89 c2                	mov    %eax,%edx
  801431:	85 c0                	test   %eax,%eax
  801433:	78 6d                	js     8014a2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143f:	ff 30                	pushl  (%eax)
  801441:	e8 c2 fd ff ff       	call   801208 <dev_lookup>
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 4c                	js     801499 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80144d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801450:	8b 42 08             	mov    0x8(%edx),%eax
  801453:	83 e0 03             	and    $0x3,%eax
  801456:	83 f8 01             	cmp    $0x1,%eax
  801459:	75 21                	jne    80147c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80145b:	a1 04 40 80 00       	mov    0x804004,%eax
  801460:	8b 40 48             	mov    0x48(%eax),%eax
  801463:	83 ec 04             	sub    $0x4,%esp
  801466:	53                   	push   %ebx
  801467:	50                   	push   %eax
  801468:	68 11 26 80 00       	push   $0x802611
  80146d:	e8 87 ed ff ff       	call   8001f9 <cprintf>
		return -E_INVAL;
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147a:	eb 26                	jmp    8014a2 <read+0x8a>
	}
	if (!dev->dev_read)
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	8b 40 08             	mov    0x8(%eax),%eax
  801482:	85 c0                	test   %eax,%eax
  801484:	74 17                	je     80149d <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801486:	83 ec 04             	sub    $0x4,%esp
  801489:	ff 75 10             	pushl  0x10(%ebp)
  80148c:	ff 75 0c             	pushl  0xc(%ebp)
  80148f:	52                   	push   %edx
  801490:	ff d0                	call   *%eax
  801492:	89 c2                	mov    %eax,%edx
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	eb 09                	jmp    8014a2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801499:	89 c2                	mov    %eax,%edx
  80149b:	eb 05                	jmp    8014a2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80149d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014a2:	89 d0                	mov    %edx,%eax
  8014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	57                   	push   %edi
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014bd:	eb 21                	jmp    8014e0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	89 f0                	mov    %esi,%eax
  8014c4:	29 d8                	sub    %ebx,%eax
  8014c6:	50                   	push   %eax
  8014c7:	89 d8                	mov    %ebx,%eax
  8014c9:	03 45 0c             	add    0xc(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	57                   	push   %edi
  8014ce:	e8 45 ff ff ff       	call   801418 <read>
		if (m < 0)
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 10                	js     8014ea <readn+0x41>
			return m;
		if (m == 0)
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	74 0a                	je     8014e8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014de:	01 c3                	add    %eax,%ebx
  8014e0:	39 f3                	cmp    %esi,%ebx
  8014e2:	72 db                	jb     8014bf <readn+0x16>
  8014e4:	89 d8                	mov    %ebx,%eax
  8014e6:	eb 02                	jmp    8014ea <readn+0x41>
  8014e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ed:	5b                   	pop    %ebx
  8014ee:	5e                   	pop    %esi
  8014ef:	5f                   	pop    %edi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 14             	sub    $0x14,%esp
  8014f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	53                   	push   %ebx
  801501:	e8 ac fc ff ff       	call   8011b2 <fd_lookup>
  801506:	83 c4 08             	add    $0x8,%esp
  801509:	89 c2                	mov    %eax,%edx
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 68                	js     801577 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150f:	83 ec 08             	sub    $0x8,%esp
  801512:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801519:	ff 30                	pushl  (%eax)
  80151b:	e8 e8 fc ff ff       	call   801208 <dev_lookup>
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	78 47                	js     80156e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152e:	75 21                	jne    801551 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801530:	a1 04 40 80 00       	mov    0x804004,%eax
  801535:	8b 40 48             	mov    0x48(%eax),%eax
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	53                   	push   %ebx
  80153c:	50                   	push   %eax
  80153d:	68 2d 26 80 00       	push   $0x80262d
  801542:	e8 b2 ec ff ff       	call   8001f9 <cprintf>
		return -E_INVAL;
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154f:	eb 26                	jmp    801577 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801551:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801554:	8b 52 0c             	mov    0xc(%edx),%edx
  801557:	85 d2                	test   %edx,%edx
  801559:	74 17                	je     801572 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	ff 75 10             	pushl  0x10(%ebp)
  801561:	ff 75 0c             	pushl  0xc(%ebp)
  801564:	50                   	push   %eax
  801565:	ff d2                	call   *%edx
  801567:	89 c2                	mov    %eax,%edx
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	eb 09                	jmp    801577 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156e:	89 c2                	mov    %eax,%edx
  801570:	eb 05                	jmp    801577 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801572:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801577:	89 d0                	mov    %edx,%eax
  801579:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <seek>:

int
seek(int fdnum, off_t offset)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801584:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	ff 75 08             	pushl  0x8(%ebp)
  80158b:	e8 22 fc ff ff       	call   8011b2 <fd_lookup>
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 0e                	js     8015a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801597:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80159a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 14             	sub    $0x14,%esp
  8015ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	53                   	push   %ebx
  8015b6:	e8 f7 fb ff ff       	call   8011b2 <fd_lookup>
  8015bb:	83 c4 08             	add    $0x8,%esp
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 65                	js     801629 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c4:	83 ec 08             	sub    $0x8,%esp
  8015c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ce:	ff 30                	pushl  (%eax)
  8015d0:	e8 33 fc ff ff       	call   801208 <dev_lookup>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 44                	js     801620 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e3:	75 21                	jne    801606 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e5:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ea:	8b 40 48             	mov    0x48(%eax),%eax
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	53                   	push   %ebx
  8015f1:	50                   	push   %eax
  8015f2:	68 f0 25 80 00       	push   $0x8025f0
  8015f7:	e8 fd eb ff ff       	call   8001f9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801604:	eb 23                	jmp    801629 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801606:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801609:	8b 52 18             	mov    0x18(%edx),%edx
  80160c:	85 d2                	test   %edx,%edx
  80160e:	74 14                	je     801624 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	ff 75 0c             	pushl  0xc(%ebp)
  801616:	50                   	push   %eax
  801617:	ff d2                	call   *%edx
  801619:	89 c2                	mov    %eax,%edx
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	eb 09                	jmp    801629 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801620:	89 c2                	mov    %eax,%edx
  801622:	eb 05                	jmp    801629 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801624:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801629:	89 d0                	mov    %edx,%eax
  80162b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    

00801630 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 14             	sub    $0x14,%esp
  801637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	ff 75 08             	pushl  0x8(%ebp)
  801641:	e8 6c fb ff ff       	call   8011b2 <fd_lookup>
  801646:	83 c4 08             	add    $0x8,%esp
  801649:	89 c2                	mov    %eax,%edx
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 58                	js     8016a7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164f:	83 ec 08             	sub    $0x8,%esp
  801652:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801659:	ff 30                	pushl  (%eax)
  80165b:	e8 a8 fb ff ff       	call   801208 <dev_lookup>
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	85 c0                	test   %eax,%eax
  801665:	78 37                	js     80169e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801667:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80166e:	74 32                	je     8016a2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801670:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801673:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80167a:	00 00 00 
	stat->st_isdir = 0;
  80167d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801684:	00 00 00 
	stat->st_dev = dev;
  801687:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	53                   	push   %ebx
  801691:	ff 75 f0             	pushl  -0x10(%ebp)
  801694:	ff 50 14             	call   *0x14(%eax)
  801697:	89 c2                	mov    %eax,%edx
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	eb 09                	jmp    8016a7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169e:	89 c2                	mov    %eax,%edx
  8016a0:	eb 05                	jmp    8016a7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a7:	89 d0                	mov    %edx,%eax
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	6a 00                	push   $0x0
  8016b8:	ff 75 08             	pushl  0x8(%ebp)
  8016bb:	e8 e3 01 00 00       	call   8018a3 <open>
  8016c0:	89 c3                	mov    %eax,%ebx
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 1b                	js     8016e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	ff 75 0c             	pushl  0xc(%ebp)
  8016cf:	50                   	push   %eax
  8016d0:	e8 5b ff ff ff       	call   801630 <fstat>
  8016d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d7:	89 1c 24             	mov    %ebx,(%esp)
  8016da:	e8 fd fb ff ff       	call   8012dc <close>
	return r;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	89 f0                	mov    %esi,%eax
}
  8016e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e7:	5b                   	pop    %ebx
  8016e8:	5e                   	pop    %esi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	56                   	push   %esi
  8016ef:	53                   	push   %ebx
  8016f0:	89 c6                	mov    %eax,%esi
  8016f2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016fb:	75 12                	jne    80170f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016fd:	83 ec 0c             	sub    $0xc,%esp
  801700:	6a 01                	push   $0x1
  801702:	e8 fc f9 ff ff       	call   801103 <ipc_find_env>
  801707:	a3 00 40 80 00       	mov    %eax,0x804000
  80170c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80170f:	6a 07                	push   $0x7
  801711:	68 00 50 80 00       	push   $0x805000
  801716:	56                   	push   %esi
  801717:	ff 35 00 40 80 00    	pushl  0x804000
  80171d:	e8 7f f9 ff ff       	call   8010a1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801722:	83 c4 0c             	add    $0xc,%esp
  801725:	6a 00                	push   $0x0
  801727:	53                   	push   %ebx
  801728:	6a 00                	push   $0x0
  80172a:	e8 00 f9 ff ff       	call   80102f <ipc_recv>
}
  80172f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	8b 40 0c             	mov    0xc(%eax),%eax
  801742:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801747:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80174f:	ba 00 00 00 00       	mov    $0x0,%edx
  801754:	b8 02 00 00 00       	mov    $0x2,%eax
  801759:	e8 8d ff ff ff       	call   8016eb <fsipc>
}
  80175e:	c9                   	leave  
  80175f:	c3                   	ret    

00801760 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	8b 40 0c             	mov    0xc(%eax),%eax
  80176c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	b8 06 00 00 00       	mov    $0x6,%eax
  80177b:	e8 6b ff ff ff       	call   8016eb <fsipc>
}
  801780:	c9                   	leave  
  801781:	c3                   	ret    

00801782 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	53                   	push   %ebx
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 40 0c             	mov    0xc(%eax),%eax
  801792:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a1:	e8 45 ff ff ff       	call   8016eb <fsipc>
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 2c                	js     8017d6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	68 00 50 80 00       	push   $0x805000
  8017b2:	53                   	push   %ebx
  8017b3:	e8 c6 ef ff ff       	call   80077e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8017bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c3:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	83 ec 0c             	sub    $0xc,%esp
  8017e1:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e7:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ea:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017f0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017f5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017fa:	0f 47 c2             	cmova  %edx,%eax
  8017fd:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801802:	50                   	push   %eax
  801803:	ff 75 0c             	pushl  0xc(%ebp)
  801806:	68 08 50 80 00       	push   $0x805008
  80180b:	e8 00 f1 ff ff       	call   800910 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 04 00 00 00       	mov    $0x4,%eax
  80181a:	e8 cc fe ff ff       	call   8016eb <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	56                   	push   %esi
  801825:	53                   	push   %ebx
  801826:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	8b 40 0c             	mov    0xc(%eax),%eax
  80182f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801834:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183a:	ba 00 00 00 00       	mov    $0x0,%edx
  80183f:	b8 03 00 00 00       	mov    $0x3,%eax
  801844:	e8 a2 fe ff ff       	call   8016eb <fsipc>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 4b                	js     80189a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80184f:	39 c6                	cmp    %eax,%esi
  801851:	73 16                	jae    801869 <devfile_read+0x48>
  801853:	68 5c 26 80 00       	push   $0x80265c
  801858:	68 63 26 80 00       	push   $0x802663
  80185d:	6a 7c                	push   $0x7c
  80185f:	68 78 26 80 00       	push   $0x802678
  801864:	e8 bd 05 00 00       	call   801e26 <_panic>
	assert(r <= PGSIZE);
  801869:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186e:	7e 16                	jle    801886 <devfile_read+0x65>
  801870:	68 83 26 80 00       	push   $0x802683
  801875:	68 63 26 80 00       	push   $0x802663
  80187a:	6a 7d                	push   $0x7d
  80187c:	68 78 26 80 00       	push   $0x802678
  801881:	e8 a0 05 00 00       	call   801e26 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	50                   	push   %eax
  80188a:	68 00 50 80 00       	push   $0x805000
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	e8 79 f0 ff ff       	call   800910 <memmove>
	return r;
  801897:	83 c4 10             	add    $0x10,%esp
}
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    

008018a3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 20             	sub    $0x20,%esp
  8018aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ad:	53                   	push   %ebx
  8018ae:	e8 92 ee ff ff       	call   800745 <strlen>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018bb:	7f 67                	jg     801924 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018bd:	83 ec 0c             	sub    $0xc,%esp
  8018c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c3:	50                   	push   %eax
  8018c4:	e8 9a f8 ff ff       	call   801163 <fd_alloc>
  8018c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8018cc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 57                	js     801929 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	53                   	push   %ebx
  8018d6:	68 00 50 80 00       	push   $0x805000
  8018db:	e8 9e ee ff ff       	call   80077e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f0:	e8 f6 fd ff ff       	call   8016eb <fsipc>
  8018f5:	89 c3                	mov    %eax,%ebx
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	79 14                	jns    801912 <open+0x6f>
		fd_close(fd, 0);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	6a 00                	push   $0x0
  801903:	ff 75 f4             	pushl  -0xc(%ebp)
  801906:	e8 50 f9 ff ff       	call   80125b <fd_close>
		return r;
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	89 da                	mov    %ebx,%edx
  801910:	eb 17                	jmp    801929 <open+0x86>
	}

	return fd2num(fd);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	ff 75 f4             	pushl  -0xc(%ebp)
  801918:	e8 1f f8 ff ff       	call   80113c <fd2num>
  80191d:	89 c2                	mov    %eax,%edx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	eb 05                	jmp    801929 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801924:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801929:	89 d0                	mov    %edx,%eax
  80192b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801936:	ba 00 00 00 00       	mov    $0x0,%edx
  80193b:	b8 08 00 00 00       	mov    $0x8,%eax
  801940:	e8 a6 fd ff ff       	call   8016eb <fsipc>
}
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff 75 08             	pushl  0x8(%ebp)
  801955:	e8 f2 f7 ff ff       	call   80114c <fd2data>
  80195a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80195c:	83 c4 08             	add    $0x8,%esp
  80195f:	68 8f 26 80 00       	push   $0x80268f
  801964:	53                   	push   %ebx
  801965:	e8 14 ee ff ff       	call   80077e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80196a:	8b 46 04             	mov    0x4(%esi),%eax
  80196d:	2b 06                	sub    (%esi),%eax
  80196f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801975:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80197c:	00 00 00 
	stat->st_dev = &devpipe;
  80197f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801986:	30 80 00 
	return 0;
}
  801989:	b8 00 00 00 00       	mov    $0x0,%eax
  80198e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801991:	5b                   	pop    %ebx
  801992:	5e                   	pop    %esi
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	53                   	push   %ebx
  801999:	83 ec 0c             	sub    $0xc,%esp
  80199c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80199f:	53                   	push   %ebx
  8019a0:	6a 00                	push   $0x0
  8019a2:	e8 5f f2 ff ff       	call   800c06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019a7:	89 1c 24             	mov    %ebx,(%esp)
  8019aa:	e8 9d f7 ff ff       	call   80114c <fd2data>
  8019af:	83 c4 08             	add    $0x8,%esp
  8019b2:	50                   	push   %eax
  8019b3:	6a 00                	push   $0x0
  8019b5:	e8 4c f2 ff ff       	call   800c06 <sys_page_unmap>
}
  8019ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	57                   	push   %edi
  8019c3:	56                   	push   %esi
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 1c             	sub    $0x1c,%esp
  8019c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019cb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8019d2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019d5:	83 ec 0c             	sub    $0xc,%esp
  8019d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8019db:	e8 1b 05 00 00       	call   801efb <pageref>
  8019e0:	89 c3                	mov    %eax,%ebx
  8019e2:	89 3c 24             	mov    %edi,(%esp)
  8019e5:	e8 11 05 00 00       	call   801efb <pageref>
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	39 c3                	cmp    %eax,%ebx
  8019ef:	0f 94 c1             	sete   %cl
  8019f2:	0f b6 c9             	movzbl %cl,%ecx
  8019f5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019f8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019fe:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a01:	39 ce                	cmp    %ecx,%esi
  801a03:	74 1b                	je     801a20 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a05:	39 c3                	cmp    %eax,%ebx
  801a07:	75 c4                	jne    8019cd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a09:	8b 42 58             	mov    0x58(%edx),%eax
  801a0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a0f:	50                   	push   %eax
  801a10:	56                   	push   %esi
  801a11:	68 96 26 80 00       	push   $0x802696
  801a16:	e8 de e7 ff ff       	call   8001f9 <cprintf>
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	eb ad                	jmp    8019cd <_pipeisclosed+0xe>
	}
}
  801a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a26:	5b                   	pop    %ebx
  801a27:	5e                   	pop    %esi
  801a28:	5f                   	pop    %edi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	57                   	push   %edi
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	83 ec 28             	sub    $0x28,%esp
  801a34:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a37:	56                   	push   %esi
  801a38:	e8 0f f7 ff ff       	call   80114c <fd2data>
  801a3d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	bf 00 00 00 00       	mov    $0x0,%edi
  801a47:	eb 4b                	jmp    801a94 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a49:	89 da                	mov    %ebx,%edx
  801a4b:	89 f0                	mov    %esi,%eax
  801a4d:	e8 6d ff ff ff       	call   8019bf <_pipeisclosed>
  801a52:	85 c0                	test   %eax,%eax
  801a54:	75 48                	jne    801a9e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a56:	e8 07 f1 ff ff       	call   800b62 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a5b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a5e:	8b 0b                	mov    (%ebx),%ecx
  801a60:	8d 51 20             	lea    0x20(%ecx),%edx
  801a63:	39 d0                	cmp    %edx,%eax
  801a65:	73 e2                	jae    801a49 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a6e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a71:	89 c2                	mov    %eax,%edx
  801a73:	c1 fa 1f             	sar    $0x1f,%edx
  801a76:	89 d1                	mov    %edx,%ecx
  801a78:	c1 e9 1b             	shr    $0x1b,%ecx
  801a7b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a7e:	83 e2 1f             	and    $0x1f,%edx
  801a81:	29 ca                	sub    %ecx,%edx
  801a83:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a87:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a8b:	83 c0 01             	add    $0x1,%eax
  801a8e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a91:	83 c7 01             	add    $0x1,%edi
  801a94:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a97:	75 c2                	jne    801a5b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a99:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9c:	eb 05                	jmp    801aa3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	57                   	push   %edi
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	83 ec 18             	sub    $0x18,%esp
  801ab4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ab7:	57                   	push   %edi
  801ab8:	e8 8f f6 ff ff       	call   80114c <fd2data>
  801abd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ac7:	eb 3d                	jmp    801b06 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ac9:	85 db                	test   %ebx,%ebx
  801acb:	74 04                	je     801ad1 <devpipe_read+0x26>
				return i;
  801acd:	89 d8                	mov    %ebx,%eax
  801acf:	eb 44                	jmp    801b15 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad1:	89 f2                	mov    %esi,%edx
  801ad3:	89 f8                	mov    %edi,%eax
  801ad5:	e8 e5 fe ff ff       	call   8019bf <_pipeisclosed>
  801ada:	85 c0                	test   %eax,%eax
  801adc:	75 32                	jne    801b10 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ade:	e8 7f f0 ff ff       	call   800b62 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ae3:	8b 06                	mov    (%esi),%eax
  801ae5:	3b 46 04             	cmp    0x4(%esi),%eax
  801ae8:	74 df                	je     801ac9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aea:	99                   	cltd   
  801aeb:	c1 ea 1b             	shr    $0x1b,%edx
  801aee:	01 d0                	add    %edx,%eax
  801af0:	83 e0 1f             	and    $0x1f,%eax
  801af3:	29 d0                	sub    %edx,%eax
  801af5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b00:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b03:	83 c3 01             	add    $0x1,%ebx
  801b06:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b09:	75 d8                	jne    801ae3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b0e:	eb 05                	jmp    801b15 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b18:	5b                   	pop    %ebx
  801b19:	5e                   	pop    %esi
  801b1a:	5f                   	pop    %edi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b28:	50                   	push   %eax
  801b29:	e8 35 f6 ff ff       	call   801163 <fd_alloc>
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	89 c2                	mov    %eax,%edx
  801b33:	85 c0                	test   %eax,%eax
  801b35:	0f 88 2c 01 00 00    	js     801c67 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3b:	83 ec 04             	sub    $0x4,%esp
  801b3e:	68 07 04 00 00       	push   $0x407
  801b43:	ff 75 f4             	pushl  -0xc(%ebp)
  801b46:	6a 00                	push   $0x0
  801b48:	e8 34 f0 ff ff       	call   800b81 <sys_page_alloc>
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	89 c2                	mov    %eax,%edx
  801b52:	85 c0                	test   %eax,%eax
  801b54:	0f 88 0d 01 00 00    	js     801c67 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b5a:	83 ec 0c             	sub    $0xc,%esp
  801b5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b60:	50                   	push   %eax
  801b61:	e8 fd f5 ff ff       	call   801163 <fd_alloc>
  801b66:	89 c3                	mov    %eax,%ebx
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	0f 88 e2 00 00 00    	js     801c55 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b73:	83 ec 04             	sub    $0x4,%esp
  801b76:	68 07 04 00 00       	push   $0x407
  801b7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7e:	6a 00                	push   $0x0
  801b80:	e8 fc ef ff ff       	call   800b81 <sys_page_alloc>
  801b85:	89 c3                	mov    %eax,%ebx
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	0f 88 c3 00 00 00    	js     801c55 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b92:	83 ec 0c             	sub    $0xc,%esp
  801b95:	ff 75 f4             	pushl  -0xc(%ebp)
  801b98:	e8 af f5 ff ff       	call   80114c <fd2data>
  801b9d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9f:	83 c4 0c             	add    $0xc,%esp
  801ba2:	68 07 04 00 00       	push   $0x407
  801ba7:	50                   	push   %eax
  801ba8:	6a 00                	push   $0x0
  801baa:	e8 d2 ef ff ff       	call   800b81 <sys_page_alloc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	0f 88 89 00 00 00    	js     801c45 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc2:	e8 85 f5 ff ff       	call   80114c <fd2data>
  801bc7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bce:	50                   	push   %eax
  801bcf:	6a 00                	push   $0x0
  801bd1:	56                   	push   %esi
  801bd2:	6a 00                	push   $0x0
  801bd4:	e8 eb ef ff ff       	call   800bc4 <sys_page_map>
  801bd9:	89 c3                	mov    %eax,%ebx
  801bdb:	83 c4 20             	add    $0x20,%esp
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 55                	js     801c37 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801be2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801beb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bf7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c00:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c05:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c12:	e8 25 f5 ff ff       	call   80113c <fd2num>
  801c17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c1c:	83 c4 04             	add    $0x4,%esp
  801c1f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c22:	e8 15 f5 ff ff       	call   80113c <fd2num>
  801c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	ba 00 00 00 00       	mov    $0x0,%edx
  801c35:	eb 30                	jmp    801c67 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c37:	83 ec 08             	sub    $0x8,%esp
  801c3a:	56                   	push   %esi
  801c3b:	6a 00                	push   $0x0
  801c3d:	e8 c4 ef ff ff       	call   800c06 <sys_page_unmap>
  801c42:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c45:	83 ec 08             	sub    $0x8,%esp
  801c48:	ff 75 f0             	pushl  -0x10(%ebp)
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 b4 ef ff ff       	call   800c06 <sys_page_unmap>
  801c52:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 a4 ef ff ff       	call   800c06 <sys_page_unmap>
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c67:	89 d0                	mov    %edx,%eax
  801c69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6c:	5b                   	pop    %ebx
  801c6d:	5e                   	pop    %esi
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c79:	50                   	push   %eax
  801c7a:	ff 75 08             	pushl  0x8(%ebp)
  801c7d:	e8 30 f5 ff ff       	call   8011b2 <fd_lookup>
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	85 c0                	test   %eax,%eax
  801c87:	78 18                	js     801ca1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8f:	e8 b8 f4 ff ff       	call   80114c <fd2data>
	return _pipeisclosed(fd, p);
  801c94:	89 c2                	mov    %eax,%edx
  801c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c99:	e8 21 fd ff ff       	call   8019bf <_pipeisclosed>
  801c9e:	83 c4 10             	add    $0x10,%esp
}
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ca6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    

00801cad <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cb3:	68 ae 26 80 00       	push   $0x8026ae
  801cb8:	ff 75 0c             	pushl  0xc(%ebp)
  801cbb:	e8 be ea ff ff       	call   80077e <strcpy>
	return 0;
}
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	57                   	push   %edi
  801ccb:	56                   	push   %esi
  801ccc:	53                   	push   %ebx
  801ccd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cd8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cde:	eb 2d                	jmp    801d0d <devcons_write+0x46>
		m = n - tot;
  801ce0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ce3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ce5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ce8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ced:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf0:	83 ec 04             	sub    $0x4,%esp
  801cf3:	53                   	push   %ebx
  801cf4:	03 45 0c             	add    0xc(%ebp),%eax
  801cf7:	50                   	push   %eax
  801cf8:	57                   	push   %edi
  801cf9:	e8 12 ec ff ff       	call   800910 <memmove>
		sys_cputs(buf, m);
  801cfe:	83 c4 08             	add    $0x8,%esp
  801d01:	53                   	push   %ebx
  801d02:	57                   	push   %edi
  801d03:	e8 bd ed ff ff       	call   800ac5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d08:	01 de                	add    %ebx,%esi
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	89 f0                	mov    %esi,%eax
  801d0f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d12:	72 cc                	jb     801ce0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    

00801d1c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	83 ec 08             	sub    $0x8,%esp
  801d22:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d2b:	74 2a                	je     801d57 <devcons_read+0x3b>
  801d2d:	eb 05                	jmp    801d34 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d2f:	e8 2e ee ff ff       	call   800b62 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d34:	e8 aa ed ff ff       	call   800ae3 <sys_cgetc>
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	74 f2                	je     801d2f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 16                	js     801d57 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d41:	83 f8 04             	cmp    $0x4,%eax
  801d44:	74 0c                	je     801d52 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d49:	88 02                	mov    %al,(%edx)
	return 1;
  801d4b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d50:	eb 05                	jmp    801d57 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d52:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    

00801d59 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d65:	6a 01                	push   $0x1
  801d67:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d6a:	50                   	push   %eax
  801d6b:	e8 55 ed ff ff       	call   800ac5 <sys_cputs>
}
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <getchar>:

int
getchar(void)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d7b:	6a 01                	push   $0x1
  801d7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d80:	50                   	push   %eax
  801d81:	6a 00                	push   $0x0
  801d83:	e8 90 f6 ff ff       	call   801418 <read>
	if (r < 0)
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	78 0f                	js     801d9e <getchar+0x29>
		return r;
	if (r < 1)
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	7e 06                	jle    801d99 <getchar+0x24>
		return -E_EOF;
	return c;
  801d93:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d97:	eb 05                	jmp    801d9e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d99:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da9:	50                   	push   %eax
  801daa:	ff 75 08             	pushl  0x8(%ebp)
  801dad:	e8 00 f4 ff ff       	call   8011b2 <fd_lookup>
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 11                	js     801dca <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dc2:	39 10                	cmp    %edx,(%eax)
  801dc4:	0f 94 c0             	sete   %al
  801dc7:	0f b6 c0             	movzbl %al,%eax
}
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <opencons>:

int
opencons(void)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd5:	50                   	push   %eax
  801dd6:	e8 88 f3 ff ff       	call   801163 <fd_alloc>
  801ddb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dde:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 3e                	js     801e22 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de4:	83 ec 04             	sub    $0x4,%esp
  801de7:	68 07 04 00 00       	push   $0x407
  801dec:	ff 75 f4             	pushl  -0xc(%ebp)
  801def:	6a 00                	push   $0x0
  801df1:	e8 8b ed ff ff       	call   800b81 <sys_page_alloc>
  801df6:	83 c4 10             	add    $0x10,%esp
		return r;
  801df9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 23                	js     801e22 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dff:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e08:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e14:	83 ec 0c             	sub    $0xc,%esp
  801e17:	50                   	push   %eax
  801e18:	e8 1f f3 ff ff       	call   80113c <fd2num>
  801e1d:	89 c2                	mov    %eax,%edx
  801e1f:	83 c4 10             	add    $0x10,%esp
}
  801e22:	89 d0                	mov    %edx,%eax
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    

00801e26 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	56                   	push   %esi
  801e2a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e2b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e2e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e34:	e8 0a ed ff ff       	call   800b43 <sys_getenvid>
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	ff 75 0c             	pushl  0xc(%ebp)
  801e3f:	ff 75 08             	pushl  0x8(%ebp)
  801e42:	56                   	push   %esi
  801e43:	50                   	push   %eax
  801e44:	68 bc 26 80 00       	push   $0x8026bc
  801e49:	e8 ab e3 ff ff       	call   8001f9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e4e:	83 c4 18             	add    $0x18,%esp
  801e51:	53                   	push   %ebx
  801e52:	ff 75 10             	pushl  0x10(%ebp)
  801e55:	e8 4e e3 ff ff       	call   8001a8 <vcprintf>
	cprintf("\n");
  801e5a:	c7 04 24 a7 26 80 00 	movl   $0x8026a7,(%esp)
  801e61:	e8 93 e3 ff ff       	call   8001f9 <cprintf>
  801e66:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e69:	cc                   	int3   
  801e6a:	eb fd                	jmp    801e69 <_panic+0x43>

00801e6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e72:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e79:	75 2a                	jne    801ea5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801e7b:	83 ec 04             	sub    $0x4,%esp
  801e7e:	6a 07                	push   $0x7
  801e80:	68 00 f0 bf ee       	push   $0xeebff000
  801e85:	6a 00                	push   $0x0
  801e87:	e8 f5 ec ff ff       	call   800b81 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	79 12                	jns    801ea5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e93:	50                   	push   %eax
  801e94:	68 e0 26 80 00       	push   $0x8026e0
  801e99:	6a 23                	push   $0x23
  801e9b:	68 e4 26 80 00       	push   $0x8026e4
  801ea0:	e8 81 ff ff ff       	call   801e26 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea8:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	68 d7 1e 80 00       	push   $0x801ed7
  801eb5:	6a 00                	push   $0x0
  801eb7:	e8 10 ee ff ff       	call   800ccc <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	79 12                	jns    801ed5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801ec3:	50                   	push   %eax
  801ec4:	68 e0 26 80 00       	push   $0x8026e0
  801ec9:	6a 2c                	push   $0x2c
  801ecb:	68 e4 26 80 00       	push   $0x8026e4
  801ed0:	e8 51 ff ff ff       	call   801e26 <_panic>
	}
}
  801ed5:	c9                   	leave  
  801ed6:	c3                   	ret    

00801ed7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ed7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ed8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801edd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801edf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801ee2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801ee6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801eeb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801eef:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ef1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ef4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ef5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ef8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ef9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801efa:	c3                   	ret    

00801efb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f01:	89 d0                	mov    %edx,%eax
  801f03:	c1 e8 16             	shr    $0x16,%eax
  801f06:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f0d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f12:	f6 c1 01             	test   $0x1,%cl
  801f15:	74 1d                	je     801f34 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f17:	c1 ea 0c             	shr    $0xc,%edx
  801f1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f21:	f6 c2 01             	test   $0x1,%dl
  801f24:	74 0e                	je     801f34 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f26:	c1 ea 0c             	shr    $0xc,%edx
  801f29:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f30:	ef 
  801f31:	0f b7 c0             	movzwl %ax,%eax
}
  801f34:	5d                   	pop    %ebp
  801f35:	c3                   	ret    
  801f36:	66 90                	xchg   %ax,%ax
  801f38:	66 90                	xchg   %ax,%ax
  801f3a:	66 90                	xchg   %ax,%ax
  801f3c:	66 90                	xchg   %ax,%ax
  801f3e:	66 90                	xchg   %ax,%ax

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f57:	85 f6                	test   %esi,%esi
  801f59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5d:	89 ca                	mov    %ecx,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	75 3d                	jne    801fa0 <__udivdi3+0x60>
  801f63:	39 cf                	cmp    %ecx,%edi
  801f65:	0f 87 c5 00 00 00    	ja     802030 <__udivdi3+0xf0>
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	89 fd                	mov    %edi,%ebp
  801f6f:	75 0b                	jne    801f7c <__udivdi3+0x3c>
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	31 d2                	xor    %edx,%edx
  801f78:	f7 f7                	div    %edi
  801f7a:	89 c5                	mov    %eax,%ebp
  801f7c:	89 c8                	mov    %ecx,%eax
  801f7e:	31 d2                	xor    %edx,%edx
  801f80:	f7 f5                	div    %ebp
  801f82:	89 c1                	mov    %eax,%ecx
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	89 cf                	mov    %ecx,%edi
  801f88:	f7 f5                	div    %ebp
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	39 ce                	cmp    %ecx,%esi
  801fa2:	77 74                	ja     802018 <__udivdi3+0xd8>
  801fa4:	0f bd fe             	bsr    %esi,%edi
  801fa7:	83 f7 1f             	xor    $0x1f,%edi
  801faa:	0f 84 98 00 00 00    	je     802048 <__udivdi3+0x108>
  801fb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	89 c5                	mov    %eax,%ebp
  801fb9:	29 fb                	sub    %edi,%ebx
  801fbb:	d3 e6                	shl    %cl,%esi
  801fbd:	89 d9                	mov    %ebx,%ecx
  801fbf:	d3 ed                	shr    %cl,%ebp
  801fc1:	89 f9                	mov    %edi,%ecx
  801fc3:	d3 e0                	shl    %cl,%eax
  801fc5:	09 ee                	or     %ebp,%esi
  801fc7:	89 d9                	mov    %ebx,%ecx
  801fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcd:	89 d5                	mov    %edx,%ebp
  801fcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fd3:	d3 ed                	shr    %cl,%ebp
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e2                	shl    %cl,%edx
  801fd9:	89 d9                	mov    %ebx,%ecx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	09 c2                	or     %eax,%edx
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	89 ea                	mov    %ebp,%edx
  801fe3:	f7 f6                	div    %esi
  801fe5:	89 d5                	mov    %edx,%ebp
  801fe7:	89 c3                	mov    %eax,%ebx
  801fe9:	f7 64 24 0c          	mull   0xc(%esp)
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	72 10                	jb     802001 <__udivdi3+0xc1>
  801ff1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e6                	shl    %cl,%esi
  801ff9:	39 c6                	cmp    %eax,%esi
  801ffb:	73 07                	jae    802004 <__udivdi3+0xc4>
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	75 03                	jne    802004 <__udivdi3+0xc4>
  802001:	83 eb 01             	sub    $0x1,%ebx
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 d8                	mov    %ebx,%eax
  802008:	89 fa                	mov    %edi,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	31 ff                	xor    %edi,%edi
  80201a:	31 db                	xor    %ebx,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d8                	mov    %ebx,%eax
  802032:	f7 f7                	div    %edi
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 c3                	mov    %eax,%ebx
  802038:	89 d8                	mov    %ebx,%eax
  80203a:	89 fa                	mov    %edi,%edx
  80203c:	83 c4 1c             	add    $0x1c,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	39 ce                	cmp    %ecx,%esi
  80204a:	72 0c                	jb     802058 <__udivdi3+0x118>
  80204c:	31 db                	xor    %ebx,%ebx
  80204e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802052:	0f 87 34 ff ff ff    	ja     801f8c <__udivdi3+0x4c>
  802058:	bb 01 00 00 00       	mov    $0x1,%ebx
  80205d:	e9 2a ff ff ff       	jmp    801f8c <__udivdi3+0x4c>
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 d2                	test   %edx,%edx
  802089:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80208d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802091:	89 f3                	mov    %esi,%ebx
  802093:	89 3c 24             	mov    %edi,(%esp)
  802096:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209a:	75 1c                	jne    8020b8 <__umoddi3+0x48>
  80209c:	39 f7                	cmp    %esi,%edi
  80209e:	76 50                	jbe    8020f0 <__umoddi3+0x80>
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	f7 f7                	div    %edi
  8020a6:	89 d0                	mov    %edx,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	89 d0                	mov    %edx,%eax
  8020bc:	77 52                	ja     802110 <__umoddi3+0xa0>
  8020be:	0f bd ea             	bsr    %edx,%ebp
  8020c1:	83 f5 1f             	xor    $0x1f,%ebp
  8020c4:	75 5a                	jne    802120 <__umoddi3+0xb0>
  8020c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ca:	0f 82 e0 00 00 00    	jb     8021b0 <__umoddi3+0x140>
  8020d0:	39 0c 24             	cmp    %ecx,(%esp)
  8020d3:	0f 86 d7 00 00 00    	jbe    8021b0 <__umoddi3+0x140>
  8020d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020e1:	83 c4 1c             	add    $0x1c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	85 ff                	test   %edi,%edi
  8020f2:	89 fd                	mov    %edi,%ebp
  8020f4:	75 0b                	jne    802101 <__umoddi3+0x91>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f7                	div    %edi
  8020ff:	89 c5                	mov    %eax,%ebp
  802101:	89 f0                	mov    %esi,%eax
  802103:	31 d2                	xor    %edx,%edx
  802105:	f7 f5                	div    %ebp
  802107:	89 c8                	mov    %ecx,%eax
  802109:	f7 f5                	div    %ebp
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	eb 99                	jmp    8020a8 <__umoddi3+0x38>
  80210f:	90                   	nop
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	8b 34 24             	mov    (%esp),%esi
  802123:	bf 20 00 00 00       	mov    $0x20,%edi
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	29 ef                	sub    %ebp,%edi
  80212c:	d3 e0                	shl    %cl,%eax
  80212e:	89 f9                	mov    %edi,%ecx
  802130:	89 f2                	mov    %esi,%edx
  802132:	d3 ea                	shr    %cl,%edx
  802134:	89 e9                	mov    %ebp,%ecx
  802136:	09 c2                	or     %eax,%edx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 14 24             	mov    %edx,(%esp)
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	89 f9                	mov    %edi,%ecx
  802143:	89 54 24 04          	mov    %edx,0x4(%esp)
  802147:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	89 e9                	mov    %ebp,%ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	d3 e3                	shl    %cl,%ebx
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 d0                	mov    %edx,%eax
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	09 d8                	or     %ebx,%eax
  80215d:	89 d3                	mov    %edx,%ebx
  80215f:	89 f2                	mov    %esi,%edx
  802161:	f7 34 24             	divl   (%esp)
  802164:	89 d6                	mov    %edx,%esi
  802166:	d3 e3                	shl    %cl,%ebx
  802168:	f7 64 24 04          	mull   0x4(%esp)
  80216c:	39 d6                	cmp    %edx,%esi
  80216e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802172:	89 d1                	mov    %edx,%ecx
  802174:	89 c3                	mov    %eax,%ebx
  802176:	72 08                	jb     802180 <__umoddi3+0x110>
  802178:	75 11                	jne    80218b <__umoddi3+0x11b>
  80217a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80217e:	73 0b                	jae    80218b <__umoddi3+0x11b>
  802180:	2b 44 24 04          	sub    0x4(%esp),%eax
  802184:	1b 14 24             	sbb    (%esp),%edx
  802187:	89 d1                	mov    %edx,%ecx
  802189:	89 c3                	mov    %eax,%ebx
  80218b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80218f:	29 da                	sub    %ebx,%edx
  802191:	19 ce                	sbb    %ecx,%esi
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 f0                	mov    %esi,%eax
  802197:	d3 e0                	shl    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	09 d0                	or     %edx,%eax
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	83 c4 1c             	add    $0x1c,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	29 f9                	sub    %edi,%ecx
  8021b2:	19 d6                	sbb    %edx,%esi
  8021b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bc:	e9 18 ff ff ff       	jmp    8020d9 <__umoddi3+0x69>
