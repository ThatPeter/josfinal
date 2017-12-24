
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 24 0b 00 00       	call   800b66 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 00 22 80 00       	push   $0x802200
  80004c:	e8 cb 01 00 00       	call   80021c <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 e5 06 00 00       	call   800768 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 11 22 80 00       	push   $0x802211
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 a9 06 00 00       	call   80074e <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 be 0d 00 00       	call   800e6b <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 ad 00 00 00       	call   80016f <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 10 22 80 00       	push   $0x802210
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ea:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000f1:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000f4:	e8 6d 0a 00 00       	call   800b66 <sys_getenvid>
  8000f9:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000ff:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800104:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800109:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80010e:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800111:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800117:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  80011a:	39 c8                	cmp    %ecx,%eax
  80011c:	0f 44 fb             	cmove  %ebx,%edi
  80011f:	b9 01 00 00 00       	mov    $0x1,%ecx
  800124:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800127:	83 c2 01             	add    $0x1,%edx
  80012a:	83 c3 7c             	add    $0x7c,%ebx
  80012d:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800133:	75 d9                	jne    80010e <libmain+0x2d>
  800135:	89 f0                	mov    %esi,%eax
  800137:	84 c0                	test   %al,%al
  800139:	74 06                	je     800141 <libmain+0x60>
  80013b:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800141:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800145:	7e 0a                	jle    800151 <libmain+0x70>
		binaryname = argv[0];
  800147:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014a:	8b 00                	mov    (%eax),%eax
  80014c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800151:	83 ec 08             	sub    $0x8,%esp
  800154:	ff 75 0c             	pushl  0xc(%ebp)
  800157:	ff 75 08             	pushl  0x8(%ebp)
  80015a:	e8 6d ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  80015f:	e8 0b 00 00 00       	call   80016f <exit>
}
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800175:	e8 a3 10 00 00       	call   80121d <close_all>
	sys_env_destroy(0);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	6a 00                	push   $0x0
  80017f:	e8 a1 09 00 00       	call   800b25 <sys_env_destroy>
}
  800184:	83 c4 10             	add    $0x10,%esp
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	53                   	push   %ebx
  80018d:	83 ec 04             	sub    $0x4,%esp
  800190:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800193:	8b 13                	mov    (%ebx),%edx
  800195:	8d 42 01             	lea    0x1(%edx),%eax
  800198:	89 03                	mov    %eax,(%ebx)
  80019a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a6:	75 1a                	jne    8001c2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a8:	83 ec 08             	sub    $0x8,%esp
  8001ab:	68 ff 00 00 00       	push   $0xff
  8001b0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b3:	50                   	push   %eax
  8001b4:	e8 2f 09 00 00       	call   800ae8 <sys_cputs>
		b->idx = 0;
  8001b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bf:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001db:	00 00 00 
	b.cnt = 0;
  8001de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e8:	ff 75 0c             	pushl  0xc(%ebp)
  8001eb:	ff 75 08             	pushl  0x8(%ebp)
  8001ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f4:	50                   	push   %eax
  8001f5:	68 89 01 80 00       	push   $0x800189
  8001fa:	e8 54 01 00 00       	call   800353 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ff:	83 c4 08             	add    $0x8,%esp
  800202:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800208:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020e:	50                   	push   %eax
  80020f:	e8 d4 08 00 00       	call   800ae8 <sys_cputs>

	return b.cnt;
}
  800214:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800222:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800225:	50                   	push   %eax
  800226:	ff 75 08             	pushl  0x8(%ebp)
  800229:	e8 9d ff ff ff       	call   8001cb <vcprintf>
	va_end(ap);

	return cnt;
}
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 1c             	sub    $0x1c,%esp
  800239:	89 c7                	mov    %eax,%edi
  80023b:	89 d6                	mov    %edx,%esi
  80023d:	8b 45 08             	mov    0x8(%ebp),%eax
  800240:	8b 55 0c             	mov    0xc(%ebp),%edx
  800243:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800246:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800249:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800251:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800254:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800257:	39 d3                	cmp    %edx,%ebx
  800259:	72 05                	jb     800260 <printnum+0x30>
  80025b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025e:	77 45                	ja     8002a5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800260:	83 ec 0c             	sub    $0xc,%esp
  800263:	ff 75 18             	pushl  0x18(%ebp)
  800266:	8b 45 14             	mov    0x14(%ebp),%eax
  800269:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026c:	53                   	push   %ebx
  80026d:	ff 75 10             	pushl  0x10(%ebp)
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	ff 75 e4             	pushl  -0x1c(%ebp)
  800276:	ff 75 e0             	pushl  -0x20(%ebp)
  800279:	ff 75 dc             	pushl  -0x24(%ebp)
  80027c:	ff 75 d8             	pushl  -0x28(%ebp)
  80027f:	e8 dc 1c 00 00       	call   801f60 <__udivdi3>
  800284:	83 c4 18             	add    $0x18,%esp
  800287:	52                   	push   %edx
  800288:	50                   	push   %eax
  800289:	89 f2                	mov    %esi,%edx
  80028b:	89 f8                	mov    %edi,%eax
  80028d:	e8 9e ff ff ff       	call   800230 <printnum>
  800292:	83 c4 20             	add    $0x20,%esp
  800295:	eb 18                	jmp    8002af <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800297:	83 ec 08             	sub    $0x8,%esp
  80029a:	56                   	push   %esi
  80029b:	ff 75 18             	pushl  0x18(%ebp)
  80029e:	ff d7                	call   *%edi
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 03                	jmp    8002a8 <printnum+0x78>
  8002a5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a8:	83 eb 01             	sub    $0x1,%ebx
  8002ab:	85 db                	test   %ebx,%ebx
  8002ad:	7f e8                	jg     800297 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002af:	83 ec 08             	sub    $0x8,%esp
  8002b2:	56                   	push   %esi
  8002b3:	83 ec 04             	sub    $0x4,%esp
  8002b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c2:	e8 c9 1d 00 00       	call   802090 <__umoddi3>
  8002c7:	83 c4 14             	add    $0x14,%esp
  8002ca:	0f be 80 20 22 80 00 	movsbl 0x802220(%eax),%eax
  8002d1:	50                   	push   %eax
  8002d2:	ff d7                	call   *%edi
}
  8002d4:	83 c4 10             	add    $0x10,%esp
  8002d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002da:	5b                   	pop    %ebx
  8002db:	5e                   	pop    %esi
  8002dc:	5f                   	pop    %edi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e2:	83 fa 01             	cmp    $0x1,%edx
  8002e5:	7e 0e                	jle    8002f5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e7:	8b 10                	mov    (%eax),%edx
  8002e9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ec:	89 08                	mov    %ecx,(%eax)
  8002ee:	8b 02                	mov    (%edx),%eax
  8002f0:	8b 52 04             	mov    0x4(%edx),%edx
  8002f3:	eb 22                	jmp    800317 <getuint+0x38>
	else if (lflag)
  8002f5:	85 d2                	test   %edx,%edx
  8002f7:	74 10                	je     800309 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 02                	mov    (%edx),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
  800307:	eb 0e                	jmp    800317 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030e:	89 08                	mov    %ecx,(%eax)
  800310:	8b 02                	mov    (%edx),%eax
  800312:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800323:	8b 10                	mov    (%eax),%edx
  800325:	3b 50 04             	cmp    0x4(%eax),%edx
  800328:	73 0a                	jae    800334 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032d:	89 08                	mov    %ecx,(%eax)
  80032f:	8b 45 08             	mov    0x8(%ebp),%eax
  800332:	88 02                	mov    %al,(%edx)
}
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033f:	50                   	push   %eax
  800340:	ff 75 10             	pushl  0x10(%ebp)
  800343:	ff 75 0c             	pushl  0xc(%ebp)
  800346:	ff 75 08             	pushl  0x8(%ebp)
  800349:	e8 05 00 00 00       	call   800353 <vprintfmt>
	va_end(ap);
}
  80034e:	83 c4 10             	add    $0x10,%esp
  800351:	c9                   	leave  
  800352:	c3                   	ret    

00800353 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	57                   	push   %edi
  800357:	56                   	push   %esi
  800358:	53                   	push   %ebx
  800359:	83 ec 2c             	sub    $0x2c,%esp
  80035c:	8b 75 08             	mov    0x8(%ebp),%esi
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800362:	8b 7d 10             	mov    0x10(%ebp),%edi
  800365:	eb 12                	jmp    800379 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800367:	85 c0                	test   %eax,%eax
  800369:	0f 84 89 03 00 00    	je     8006f8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	53                   	push   %ebx
  800373:	50                   	push   %eax
  800374:	ff d6                	call   *%esi
  800376:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800379:	83 c7 01             	add    $0x1,%edi
  80037c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800380:	83 f8 25             	cmp    $0x25,%eax
  800383:	75 e2                	jne    800367 <vprintfmt+0x14>
  800385:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800389:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800390:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800397:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039e:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a3:	eb 07                	jmp    8003ac <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8d 47 01             	lea    0x1(%edi),%eax
  8003af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b2:	0f b6 07             	movzbl (%edi),%eax
  8003b5:	0f b6 c8             	movzbl %al,%ecx
  8003b8:	83 e8 23             	sub    $0x23,%eax
  8003bb:	3c 55                	cmp    $0x55,%al
  8003bd:	0f 87 1a 03 00 00    	ja     8006dd <vprintfmt+0x38a>
  8003c3:	0f b6 c0             	movzbl %al,%eax
  8003c6:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d4:	eb d6                	jmp    8003ac <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003eb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ee:	83 fa 09             	cmp    $0x9,%edx
  8003f1:	77 39                	ja     80042c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f6:	eb e9                	jmp    8003e1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800409:	eb 27                	jmp    800432 <vprintfmt+0xdf>
  80040b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040e:	85 c0                	test   %eax,%eax
  800410:	b9 00 00 00 00       	mov    $0x0,%ecx
  800415:	0f 49 c8             	cmovns %eax,%ecx
  800418:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041e:	eb 8c                	jmp    8003ac <vprintfmt+0x59>
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800423:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042a:	eb 80                	jmp    8003ac <vprintfmt+0x59>
  80042c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800432:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800436:	0f 89 70 ff ff ff    	jns    8003ac <vprintfmt+0x59>
				width = precision, precision = -1;
  80043c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800442:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800449:	e9 5e ff ff ff       	jmp    8003ac <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800454:	e9 53 ff ff ff       	jmp    8003ac <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	ff 30                	pushl  (%eax)
  800468:	ff d6                	call   *%esi
			break;
  80046a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800470:	e9 04 ff ff ff       	jmp    800379 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 50 04             	lea    0x4(%eax),%edx
  80047b:	89 55 14             	mov    %edx,0x14(%ebp)
  80047e:	8b 00                	mov    (%eax),%eax
  800480:	99                   	cltd   
  800481:	31 d0                	xor    %edx,%eax
  800483:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800485:	83 f8 0f             	cmp    $0xf,%eax
  800488:	7f 0b                	jg     800495 <vprintfmt+0x142>
  80048a:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  800491:	85 d2                	test   %edx,%edx
  800493:	75 18                	jne    8004ad <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800495:	50                   	push   %eax
  800496:	68 38 22 80 00       	push   $0x802238
  80049b:	53                   	push   %ebx
  80049c:	56                   	push   %esi
  80049d:	e8 94 fe ff ff       	call   800336 <printfmt>
  8004a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a8:	e9 cc fe ff ff       	jmp    800379 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ad:	52                   	push   %edx
  8004ae:	68 5d 26 80 00       	push   $0x80265d
  8004b3:	53                   	push   %ebx
  8004b4:	56                   	push   %esi
  8004b5:	e8 7c fe ff ff       	call   800336 <printfmt>
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c0:	e9 b4 fe ff ff       	jmp    800379 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d0:	85 ff                	test   %edi,%edi
  8004d2:	b8 31 22 80 00       	mov    $0x802231,%eax
  8004d7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004de:	0f 8e 94 00 00 00    	jle    800578 <vprintfmt+0x225>
  8004e4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e8:	0f 84 98 00 00 00    	je     800586 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f4:	57                   	push   %edi
  8004f5:	e8 86 02 00 00       	call   800780 <strnlen>
  8004fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fd:	29 c1                	sub    %eax,%ecx
  8004ff:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800502:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800505:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800509:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	eb 0f                	jmp    800522 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	53                   	push   %ebx
  800517:	ff 75 e0             	pushl  -0x20(%ebp)
  80051a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	83 ef 01             	sub    $0x1,%edi
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	85 ff                	test   %edi,%edi
  800524:	7f ed                	jg     800513 <vprintfmt+0x1c0>
  800526:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800529:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80052c:	85 c9                	test   %ecx,%ecx
  80052e:	b8 00 00 00 00       	mov    $0x0,%eax
  800533:	0f 49 c1             	cmovns %ecx,%eax
  800536:	29 c1                	sub    %eax,%ecx
  800538:	89 75 08             	mov    %esi,0x8(%ebp)
  80053b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800541:	89 cb                	mov    %ecx,%ebx
  800543:	eb 4d                	jmp    800592 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800545:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800549:	74 1b                	je     800566 <vprintfmt+0x213>
  80054b:	0f be c0             	movsbl %al,%eax
  80054e:	83 e8 20             	sub    $0x20,%eax
  800551:	83 f8 5e             	cmp    $0x5e,%eax
  800554:	76 10                	jbe    800566 <vprintfmt+0x213>
					putch('?', putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	ff 75 0c             	pushl  0xc(%ebp)
  80055c:	6a 3f                	push   $0x3f
  80055e:	ff 55 08             	call   *0x8(%ebp)
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	eb 0d                	jmp    800573 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	ff 75 0c             	pushl  0xc(%ebp)
  80056c:	52                   	push   %edx
  80056d:	ff 55 08             	call   *0x8(%ebp)
  800570:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800573:	83 eb 01             	sub    $0x1,%ebx
  800576:	eb 1a                	jmp    800592 <vprintfmt+0x23f>
  800578:	89 75 08             	mov    %esi,0x8(%ebp)
  80057b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800581:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800584:	eb 0c                	jmp    800592 <vprintfmt+0x23f>
  800586:	89 75 08             	mov    %esi,0x8(%ebp)
  800589:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800592:	83 c7 01             	add    $0x1,%edi
  800595:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800599:	0f be d0             	movsbl %al,%edx
  80059c:	85 d2                	test   %edx,%edx
  80059e:	74 23                	je     8005c3 <vprintfmt+0x270>
  8005a0:	85 f6                	test   %esi,%esi
  8005a2:	78 a1                	js     800545 <vprintfmt+0x1f2>
  8005a4:	83 ee 01             	sub    $0x1,%esi
  8005a7:	79 9c                	jns    800545 <vprintfmt+0x1f2>
  8005a9:	89 df                	mov    %ebx,%edi
  8005ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b1:	eb 18                	jmp    8005cb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	53                   	push   %ebx
  8005b7:	6a 20                	push   $0x20
  8005b9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bb:	83 ef 01             	sub    $0x1,%edi
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	eb 08                	jmp    8005cb <vprintfmt+0x278>
  8005c3:	89 df                	mov    %ebx,%edi
  8005c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cb:	85 ff                	test   %edi,%edi
  8005cd:	7f e4                	jg     8005b3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d2:	e9 a2 fd ff ff       	jmp    800379 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d7:	83 fa 01             	cmp    $0x1,%edx
  8005da:	7e 16                	jle    8005f2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 08             	lea    0x8(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 50 04             	mov    0x4(%eax),%edx
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f0:	eb 32                	jmp    800624 <vprintfmt+0x2d1>
	else if (lflag)
  8005f2:	85 d2                	test   %edx,%edx
  8005f4:	74 18                	je     80060e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 50 04             	lea    0x4(%eax),%edx
  8005fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	89 c1                	mov    %eax,%ecx
  800606:	c1 f9 1f             	sar    $0x1f,%ecx
  800609:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060c:	eb 16                	jmp    800624 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	89 c1                	mov    %eax,%ecx
  80061e:	c1 f9 1f             	sar    $0x1f,%ecx
  800621:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800624:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800627:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800633:	79 74                	jns    8006a9 <vprintfmt+0x356>
				putch('-', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	6a 2d                	push   $0x2d
  80063b:	ff d6                	call   *%esi
				num = -(long long) num;
  80063d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800640:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800643:	f7 d8                	neg    %eax
  800645:	83 d2 00             	adc    $0x0,%edx
  800648:	f7 da                	neg    %edx
  80064a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800652:	eb 55                	jmp    8006a9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800654:	8d 45 14             	lea    0x14(%ebp),%eax
  800657:	e8 83 fc ff ff       	call   8002df <getuint>
			base = 10;
  80065c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800661:	eb 46                	jmp    8006a9 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 74 fc ff ff       	call   8002df <getuint>
			base = 8;
  80066b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800670:	eb 37                	jmp    8006a9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 30                	push   $0x30
  800678:	ff d6                	call   *%esi
			putch('x', putdat);
  80067a:	83 c4 08             	add    $0x8,%esp
  80067d:	53                   	push   %ebx
  80067e:	6a 78                	push   $0x78
  800680:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800692:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800695:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069a:	eb 0d                	jmp    8006a9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069c:	8d 45 14             	lea    0x14(%ebp),%eax
  80069f:	e8 3b fc ff ff       	call   8002df <getuint>
			base = 16;
  8006a4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a9:	83 ec 0c             	sub    $0xc,%esp
  8006ac:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b0:	57                   	push   %edi
  8006b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b4:	51                   	push   %ecx
  8006b5:	52                   	push   %edx
  8006b6:	50                   	push   %eax
  8006b7:	89 da                	mov    %ebx,%edx
  8006b9:	89 f0                	mov    %esi,%eax
  8006bb:	e8 70 fb ff ff       	call   800230 <printnum>
			break;
  8006c0:	83 c4 20             	add    $0x20,%esp
  8006c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c6:	e9 ae fc ff ff       	jmp    800379 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	51                   	push   %ecx
  8006d0:	ff d6                	call   *%esi
			break;
  8006d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d8:	e9 9c fc ff ff       	jmp    800379 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	6a 25                	push   $0x25
  8006e3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 03                	jmp    8006ed <vprintfmt+0x39a>
  8006ea:	83 ef 01             	sub    $0x1,%edi
  8006ed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f1:	75 f7                	jne    8006ea <vprintfmt+0x397>
  8006f3:	e9 81 fc ff ff       	jmp    800379 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fb:	5b                   	pop    %ebx
  8006fc:	5e                   	pop    %esi
  8006fd:	5f                   	pop    %edi
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 18             	sub    $0x18,%esp
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800713:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071d:	85 c0                	test   %eax,%eax
  80071f:	74 26                	je     800747 <vsnprintf+0x47>
  800721:	85 d2                	test   %edx,%edx
  800723:	7e 22                	jle    800747 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800725:	ff 75 14             	pushl  0x14(%ebp)
  800728:	ff 75 10             	pushl  0x10(%ebp)
  80072b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072e:	50                   	push   %eax
  80072f:	68 19 03 80 00       	push   $0x800319
  800734:	e8 1a fc ff ff       	call   800353 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800739:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 05                	jmp    80074c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800747:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    

0080074e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800754:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800757:	50                   	push   %eax
  800758:	ff 75 10             	pushl  0x10(%ebp)
  80075b:	ff 75 0c             	pushl  0xc(%ebp)
  80075e:	ff 75 08             	pushl  0x8(%ebp)
  800761:	e8 9a ff ff ff       	call   800700 <vsnprintf>
	va_end(ap);

	return rc;
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	b8 00 00 00 00       	mov    $0x0,%eax
  800773:	eb 03                	jmp    800778 <strlen+0x10>
		n++;
  800775:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800778:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077c:	75 f7                	jne    800775 <strlen+0xd>
		n++;
	return n;
}
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800786:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800789:	ba 00 00 00 00       	mov    $0x0,%edx
  80078e:	eb 03                	jmp    800793 <strnlen+0x13>
		n++;
  800790:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	39 c2                	cmp    %eax,%edx
  800795:	74 08                	je     80079f <strnlen+0x1f>
  800797:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80079b:	75 f3                	jne    800790 <strnlen+0x10>
  80079d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	53                   	push   %ebx
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ab:	89 c2                	mov    %eax,%edx
  8007ad:	83 c2 01             	add    $0x1,%edx
  8007b0:	83 c1 01             	add    $0x1,%ecx
  8007b3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ba:	84 db                	test   %bl,%bl
  8007bc:	75 ef                	jne    8007ad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c8:	53                   	push   %ebx
  8007c9:	e8 9a ff ff ff       	call   800768 <strlen>
  8007ce:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d1:	ff 75 0c             	pushl  0xc(%ebp)
  8007d4:	01 d8                	add    %ebx,%eax
  8007d6:	50                   	push   %eax
  8007d7:	e8 c5 ff ff ff       	call   8007a1 <strcpy>
	return dst;
}
  8007dc:	89 d8                	mov    %ebx,%eax
  8007de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	56                   	push   %esi
  8007e7:	53                   	push   %ebx
  8007e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ee:	89 f3                	mov    %esi,%ebx
  8007f0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f3:	89 f2                	mov    %esi,%edx
  8007f5:	eb 0f                	jmp    800806 <strncpy+0x23>
		*dst++ = *src;
  8007f7:	83 c2 01             	add    $0x1,%edx
  8007fa:	0f b6 01             	movzbl (%ecx),%eax
  8007fd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800800:	80 39 01             	cmpb   $0x1,(%ecx)
  800803:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800806:	39 da                	cmp    %ebx,%edx
  800808:	75 ed                	jne    8007f7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080a:	89 f0                	mov    %esi,%eax
  80080c:	5b                   	pop    %ebx
  80080d:	5e                   	pop    %esi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	56                   	push   %esi
  800814:	53                   	push   %ebx
  800815:	8b 75 08             	mov    0x8(%ebp),%esi
  800818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081b:	8b 55 10             	mov    0x10(%ebp),%edx
  80081e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800820:	85 d2                	test   %edx,%edx
  800822:	74 21                	je     800845 <strlcpy+0x35>
  800824:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800828:	89 f2                	mov    %esi,%edx
  80082a:	eb 09                	jmp    800835 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082c:	83 c2 01             	add    $0x1,%edx
  80082f:	83 c1 01             	add    $0x1,%ecx
  800832:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800835:	39 c2                	cmp    %eax,%edx
  800837:	74 09                	je     800842 <strlcpy+0x32>
  800839:	0f b6 19             	movzbl (%ecx),%ebx
  80083c:	84 db                	test   %bl,%bl
  80083e:	75 ec                	jne    80082c <strlcpy+0x1c>
  800840:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800842:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800845:	29 f0                	sub    %esi,%eax
}
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800851:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800854:	eb 06                	jmp    80085c <strcmp+0x11>
		p++, q++;
  800856:	83 c1 01             	add    $0x1,%ecx
  800859:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085c:	0f b6 01             	movzbl (%ecx),%eax
  80085f:	84 c0                	test   %al,%al
  800861:	74 04                	je     800867 <strcmp+0x1c>
  800863:	3a 02                	cmp    (%edx),%al
  800865:	74 ef                	je     800856 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800867:	0f b6 c0             	movzbl %al,%eax
  80086a:	0f b6 12             	movzbl (%edx),%edx
  80086d:	29 d0                	sub    %edx,%eax
}
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087b:	89 c3                	mov    %eax,%ebx
  80087d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800880:	eb 06                	jmp    800888 <strncmp+0x17>
		n--, p++, q++;
  800882:	83 c0 01             	add    $0x1,%eax
  800885:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800888:	39 d8                	cmp    %ebx,%eax
  80088a:	74 15                	je     8008a1 <strncmp+0x30>
  80088c:	0f b6 08             	movzbl (%eax),%ecx
  80088f:	84 c9                	test   %cl,%cl
  800891:	74 04                	je     800897 <strncmp+0x26>
  800893:	3a 0a                	cmp    (%edx),%cl
  800895:	74 eb                	je     800882 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 00             	movzbl (%eax),%eax
  80089a:	0f b6 12             	movzbl (%edx),%edx
  80089d:	29 d0                	sub    %edx,%eax
  80089f:	eb 05                	jmp    8008a6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b3:	eb 07                	jmp    8008bc <strchr+0x13>
		if (*s == c)
  8008b5:	38 ca                	cmp    %cl,%dl
  8008b7:	74 0f                	je     8008c8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	0f b6 10             	movzbl (%eax),%edx
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f2                	jne    8008b5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d4:	eb 03                	jmp    8008d9 <strfind+0xf>
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008dc:	38 ca                	cmp    %cl,%dl
  8008de:	74 04                	je     8008e4 <strfind+0x1a>
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	75 f2                	jne    8008d6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	57                   	push   %edi
  8008ea:	56                   	push   %esi
  8008eb:	53                   	push   %ebx
  8008ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f2:	85 c9                	test   %ecx,%ecx
  8008f4:	74 36                	je     80092c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fc:	75 28                	jne    800926 <memset+0x40>
  8008fe:	f6 c1 03             	test   $0x3,%cl
  800901:	75 23                	jne    800926 <memset+0x40>
		c &= 0xFF;
  800903:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800907:	89 d3                	mov    %edx,%ebx
  800909:	c1 e3 08             	shl    $0x8,%ebx
  80090c:	89 d6                	mov    %edx,%esi
  80090e:	c1 e6 18             	shl    $0x18,%esi
  800911:	89 d0                	mov    %edx,%eax
  800913:	c1 e0 10             	shl    $0x10,%eax
  800916:	09 f0                	or     %esi,%eax
  800918:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80091a:	89 d8                	mov    %ebx,%eax
  80091c:	09 d0                	or     %edx,%eax
  80091e:	c1 e9 02             	shr    $0x2,%ecx
  800921:	fc                   	cld    
  800922:	f3 ab                	rep stos %eax,%es:(%edi)
  800924:	eb 06                	jmp    80092c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800926:	8b 45 0c             	mov    0xc(%ebp),%eax
  800929:	fc                   	cld    
  80092a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092c:	89 f8                	mov    %edi,%eax
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	57                   	push   %edi
  800937:	56                   	push   %esi
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800941:	39 c6                	cmp    %eax,%esi
  800943:	73 35                	jae    80097a <memmove+0x47>
  800945:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800948:	39 d0                	cmp    %edx,%eax
  80094a:	73 2e                	jae    80097a <memmove+0x47>
		s += n;
		d += n;
  80094c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094f:	89 d6                	mov    %edx,%esi
  800951:	09 fe                	or     %edi,%esi
  800953:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800959:	75 13                	jne    80096e <memmove+0x3b>
  80095b:	f6 c1 03             	test   $0x3,%cl
  80095e:	75 0e                	jne    80096e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800960:	83 ef 04             	sub    $0x4,%edi
  800963:	8d 72 fc             	lea    -0x4(%edx),%esi
  800966:	c1 e9 02             	shr    $0x2,%ecx
  800969:	fd                   	std    
  80096a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096c:	eb 09                	jmp    800977 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096e:	83 ef 01             	sub    $0x1,%edi
  800971:	8d 72 ff             	lea    -0x1(%edx),%esi
  800974:	fd                   	std    
  800975:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800977:	fc                   	cld    
  800978:	eb 1d                	jmp    800997 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097a:	89 f2                	mov    %esi,%edx
  80097c:	09 c2                	or     %eax,%edx
  80097e:	f6 c2 03             	test   $0x3,%dl
  800981:	75 0f                	jne    800992 <memmove+0x5f>
  800983:	f6 c1 03             	test   $0x3,%cl
  800986:	75 0a                	jne    800992 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800988:	c1 e9 02             	shr    $0x2,%ecx
  80098b:	89 c7                	mov    %eax,%edi
  80098d:	fc                   	cld    
  80098e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800990:	eb 05                	jmp    800997 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800992:	89 c7                	mov    %eax,%edi
  800994:	fc                   	cld    
  800995:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800997:	5e                   	pop    %esi
  800998:	5f                   	pop    %edi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80099e:	ff 75 10             	pushl  0x10(%ebp)
  8009a1:	ff 75 0c             	pushl  0xc(%ebp)
  8009a4:	ff 75 08             	pushl  0x8(%ebp)
  8009a7:	e8 87 ff ff ff       	call   800933 <memmove>
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b9:	89 c6                	mov    %eax,%esi
  8009bb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009be:	eb 1a                	jmp    8009da <memcmp+0x2c>
		if (*s1 != *s2)
  8009c0:	0f b6 08             	movzbl (%eax),%ecx
  8009c3:	0f b6 1a             	movzbl (%edx),%ebx
  8009c6:	38 d9                	cmp    %bl,%cl
  8009c8:	74 0a                	je     8009d4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ca:	0f b6 c1             	movzbl %cl,%eax
  8009cd:	0f b6 db             	movzbl %bl,%ebx
  8009d0:	29 d8                	sub    %ebx,%eax
  8009d2:	eb 0f                	jmp    8009e3 <memcmp+0x35>
		s1++, s2++;
  8009d4:	83 c0 01             	add    $0x1,%eax
  8009d7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009da:	39 f0                	cmp    %esi,%eax
  8009dc:	75 e2                	jne    8009c0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e3:	5b                   	pop    %ebx
  8009e4:	5e                   	pop    %esi
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	53                   	push   %ebx
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ee:	89 c1                	mov    %eax,%ecx
  8009f0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f7:	eb 0a                	jmp    800a03 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f9:	0f b6 10             	movzbl (%eax),%edx
  8009fc:	39 da                	cmp    %ebx,%edx
  8009fe:	74 07                	je     800a07 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a00:	83 c0 01             	add    $0x1,%eax
  800a03:	39 c8                	cmp    %ecx,%eax
  800a05:	72 f2                	jb     8009f9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a07:	5b                   	pop    %ebx
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	57                   	push   %edi
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a16:	eb 03                	jmp    800a1b <strtol+0x11>
		s++;
  800a18:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1b:	0f b6 01             	movzbl (%ecx),%eax
  800a1e:	3c 20                	cmp    $0x20,%al
  800a20:	74 f6                	je     800a18 <strtol+0xe>
  800a22:	3c 09                	cmp    $0x9,%al
  800a24:	74 f2                	je     800a18 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a26:	3c 2b                	cmp    $0x2b,%al
  800a28:	75 0a                	jne    800a34 <strtol+0x2a>
		s++;
  800a2a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a32:	eb 11                	jmp    800a45 <strtol+0x3b>
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	75 08                	jne    800a45 <strtol+0x3b>
		s++, neg = 1;
  800a3d:	83 c1 01             	add    $0x1,%ecx
  800a40:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a45:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4b:	75 15                	jne    800a62 <strtol+0x58>
  800a4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a50:	75 10                	jne    800a62 <strtol+0x58>
  800a52:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a56:	75 7c                	jne    800ad4 <strtol+0xca>
		s += 2, base = 16;
  800a58:	83 c1 02             	add    $0x2,%ecx
  800a5b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a60:	eb 16                	jmp    800a78 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a62:	85 db                	test   %ebx,%ebx
  800a64:	75 12                	jne    800a78 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a66:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6e:	75 08                	jne    800a78 <strtol+0x6e>
		s++, base = 8;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a80:	0f b6 11             	movzbl (%ecx),%edx
  800a83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 09             	cmp    $0x9,%bl
  800a8b:	77 08                	ja     800a95 <strtol+0x8b>
			dig = *s - '0';
  800a8d:	0f be d2             	movsbl %dl,%edx
  800a90:	83 ea 30             	sub    $0x30,%edx
  800a93:	eb 22                	jmp    800ab7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a95:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 19             	cmp    $0x19,%bl
  800a9d:	77 08                	ja     800aa7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a9f:	0f be d2             	movsbl %dl,%edx
  800aa2:	83 ea 57             	sub    $0x57,%edx
  800aa5:	eb 10                	jmp    800ab7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 19             	cmp    $0x19,%bl
  800aaf:	77 16                	ja     800ac7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab1:	0f be d2             	movsbl %dl,%edx
  800ab4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aba:	7d 0b                	jge    800ac7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800abc:	83 c1 01             	add    $0x1,%ecx
  800abf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac5:	eb b9                	jmp    800a80 <strtol+0x76>

	if (endptr)
  800ac7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acb:	74 0d                	je     800ada <strtol+0xd0>
		*endptr = (char *) s;
  800acd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad0:	89 0e                	mov    %ecx,(%esi)
  800ad2:	eb 06                	jmp    800ada <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad4:	85 db                	test   %ebx,%ebx
  800ad6:	74 98                	je     800a70 <strtol+0x66>
  800ad8:	eb 9e                	jmp    800a78 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ada:	89 c2                	mov    %eax,%edx
  800adc:	f7 da                	neg    %edx
  800ade:	85 ff                	test   %edi,%edi
  800ae0:	0f 45 c2             	cmovne %edx,%eax
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
  800af3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af6:	8b 55 08             	mov    0x8(%ebp),%edx
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	89 c7                	mov    %eax,%edi
  800afd:	89 c6                	mov    %eax,%esi
  800aff:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b11:	b8 01 00 00 00       	mov    $0x1,%eax
  800b16:	89 d1                	mov    %edx,%ecx
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b33:	b8 03 00 00 00       	mov    $0x3,%eax
  800b38:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3b:	89 cb                	mov    %ecx,%ebx
  800b3d:	89 cf                	mov    %ecx,%edi
  800b3f:	89 ce                	mov    %ecx,%esi
  800b41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	7e 17                	jle    800b5e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	50                   	push   %eax
  800b4b:	6a 03                	push   $0x3
  800b4d:	68 1f 25 80 00       	push   $0x80251f
  800b52:	6a 23                	push   $0x23
  800b54:	68 3c 25 80 00       	push   $0x80253c
  800b59:	e8 de 11 00 00       	call   801d3c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 02 00 00 00       	mov    $0x2,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_yield>:

void
sys_yield(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	be 00 00 00 00       	mov    $0x0,%esi
  800bb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc0:	89 f7                	mov    %esi,%edi
  800bc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 04                	push   $0x4
  800bce:	68 1f 25 80 00       	push   $0x80251f
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 3c 25 80 00       	push   $0x80253c
  800bda:	e8 5d 11 00 00       	call   801d3c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c01:	8b 75 18             	mov    0x18(%ebp),%esi
  800c04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 17                	jle    800c21 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 05                	push   $0x5
  800c10:	68 1f 25 80 00       	push   $0x80251f
  800c15:	6a 23                	push   $0x23
  800c17:	68 3c 25 80 00       	push   $0x80253c
  800c1c:	e8 1b 11 00 00       	call   801d3c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c37:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	89 df                	mov    %ebx,%edi
  800c44:	89 de                	mov    %ebx,%esi
  800c46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 17                	jle    800c63 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 06                	push   $0x6
  800c52:	68 1f 25 80 00       	push   $0x80251f
  800c57:	6a 23                	push   $0x23
  800c59:	68 3c 25 80 00       	push   $0x80253c
  800c5e:	e8 d9 10 00 00       	call   801d3c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 17                	jle    800ca5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 08                	push   $0x8
  800c94:	68 1f 25 80 00       	push   $0x80251f
  800c99:	6a 23                	push   $0x23
  800c9b:	68 3c 25 80 00       	push   $0x80253c
  800ca0:	e8 97 10 00 00       	call   801d3c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	89 df                	mov    %ebx,%edi
  800cc8:	89 de                	mov    %ebx,%esi
  800cca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 17                	jle    800ce7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 09                	push   $0x9
  800cd6:	68 1f 25 80 00       	push   $0x80251f
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 3c 25 80 00       	push   $0x80253c
  800ce2:	e8 55 10 00 00       	call   801d3c <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	89 df                	mov    %ebx,%edi
  800d0a:	89 de                	mov    %ebx,%esi
  800d0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 17                	jle    800d29 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	50                   	push   %eax
  800d16:	6a 0a                	push   $0xa
  800d18:	68 1f 25 80 00       	push   $0x80251f
  800d1d:	6a 23                	push   $0x23
  800d1f:	68 3c 25 80 00       	push   $0x80253c
  800d24:	e8 13 10 00 00       	call   801d3c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	be 00 00 00 00       	mov    $0x0,%esi
  800d3c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d62:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	89 cb                	mov    %ecx,%ebx
  800d6c:	89 cf                	mov    %ecx,%edi
  800d6e:	89 ce                	mov    %ecx,%esi
  800d70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 17                	jle    800d8d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	50                   	push   %eax
  800d7a:	6a 0d                	push   $0xd
  800d7c:	68 1f 25 80 00       	push   $0x80251f
  800d81:	6a 23                	push   $0x23
  800d83:	68 3c 25 80 00       	push   $0x80253c
  800d88:	e8 af 0f 00 00       	call   801d3c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	53                   	push   %ebx
  800d99:	83 ec 04             	sub    $0x4,%esp
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d9f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800da1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800da5:	74 11                	je     800db8 <pgfault+0x23>
  800da7:	89 d8                	mov    %ebx,%eax
  800da9:	c1 e8 0c             	shr    $0xc,%eax
  800dac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800db3:	f6 c4 08             	test   $0x8,%ah
  800db6:	75 14                	jne    800dcc <pgfault+0x37>
		panic("faulting access");
  800db8:	83 ec 04             	sub    $0x4,%esp
  800dbb:	68 4a 25 80 00       	push   $0x80254a
  800dc0:	6a 1d                	push   $0x1d
  800dc2:	68 5a 25 80 00       	push   $0x80255a
  800dc7:	e8 70 0f 00 00       	call   801d3c <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	6a 07                	push   $0x7
  800dd1:	68 00 f0 7f 00       	push   $0x7ff000
  800dd6:	6a 00                	push   $0x0
  800dd8:	e8 c7 fd ff ff       	call   800ba4 <sys_page_alloc>
	if (r < 0) {
  800ddd:	83 c4 10             	add    $0x10,%esp
  800de0:	85 c0                	test   %eax,%eax
  800de2:	79 12                	jns    800df6 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800de4:	50                   	push   %eax
  800de5:	68 65 25 80 00       	push   $0x802565
  800dea:	6a 2b                	push   $0x2b
  800dec:	68 5a 25 80 00       	push   $0x80255a
  800df1:	e8 46 0f 00 00       	call   801d3c <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800df6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800dfc:	83 ec 04             	sub    $0x4,%esp
  800dff:	68 00 10 00 00       	push   $0x1000
  800e04:	53                   	push   %ebx
  800e05:	68 00 f0 7f 00       	push   $0x7ff000
  800e0a:	e8 8c fb ff ff       	call   80099b <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e0f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e16:	53                   	push   %ebx
  800e17:	6a 00                	push   $0x0
  800e19:	68 00 f0 7f 00       	push   $0x7ff000
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 c2 fd ff ff       	call   800be7 <sys_page_map>
	if (r < 0) {
  800e25:	83 c4 20             	add    $0x20,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	79 12                	jns    800e3e <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e2c:	50                   	push   %eax
  800e2d:	68 65 25 80 00       	push   $0x802565
  800e32:	6a 32                	push   $0x32
  800e34:	68 5a 25 80 00       	push   $0x80255a
  800e39:	e8 fe 0e 00 00       	call   801d3c <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e3e:	83 ec 08             	sub    $0x8,%esp
  800e41:	68 00 f0 7f 00       	push   $0x7ff000
  800e46:	6a 00                	push   $0x0
  800e48:	e8 dc fd ff ff       	call   800c29 <sys_page_unmap>
	if (r < 0) {
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 12                	jns    800e66 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e54:	50                   	push   %eax
  800e55:	68 65 25 80 00       	push   $0x802565
  800e5a:	6a 36                	push   $0x36
  800e5c:	68 5a 25 80 00       	push   $0x80255a
  800e61:	e8 d6 0e 00 00       	call   801d3c <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e74:	68 95 0d 80 00       	push   $0x800d95
  800e79:	e8 04 0f 00 00       	call   801d82 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e7e:	b8 07 00 00 00       	mov    $0x7,%eax
  800e83:	cd 30                	int    $0x30
  800e85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	79 17                	jns    800ea6 <fork+0x3b>
		panic("fork fault %e");
  800e8f:	83 ec 04             	sub    $0x4,%esp
  800e92:	68 7e 25 80 00       	push   $0x80257e
  800e97:	68 83 00 00 00       	push   $0x83
  800e9c:	68 5a 25 80 00       	push   $0x80255a
  800ea1:	e8 96 0e 00 00       	call   801d3c <_panic>
  800ea6:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ea8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eac:	75 21                	jne    800ecf <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eae:	e8 b3 fc ff ff       	call   800b66 <sys_getenvid>
  800eb3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ebb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ec0:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	e9 61 01 00 00       	jmp    801030 <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	6a 07                	push   $0x7
  800ed4:	68 00 f0 bf ee       	push   $0xeebff000
  800ed9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800edc:	e8 c3 fc ff ff       	call   800ba4 <sys_page_alloc>
  800ee1:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ee4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800ee9:	89 d8                	mov    %ebx,%eax
  800eeb:	c1 e8 16             	shr    $0x16,%eax
  800eee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef5:	a8 01                	test   $0x1,%al
  800ef7:	0f 84 fc 00 00 00    	je     800ff9 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	c1 e8 0c             	shr    $0xc,%eax
  800f02:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f09:	f6 c2 01             	test   $0x1,%dl
  800f0c:	0f 84 e7 00 00 00    	je     800ff9 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f12:	89 c6                	mov    %eax,%esi
  800f14:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f17:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1e:	f6 c6 04             	test   $0x4,%dh
  800f21:	74 39                	je     800f5c <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f23:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f32:	50                   	push   %eax
  800f33:	56                   	push   %esi
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	6a 00                	push   $0x0
  800f38:	e8 aa fc ff ff       	call   800be7 <sys_page_map>
		if (r < 0) {
  800f3d:	83 c4 20             	add    $0x20,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	0f 89 b1 00 00 00    	jns    800ff9 <fork+0x18e>
		    	panic("sys page map fault %e");
  800f48:	83 ec 04             	sub    $0x4,%esp
  800f4b:	68 8c 25 80 00       	push   $0x80258c
  800f50:	6a 53                	push   $0x53
  800f52:	68 5a 25 80 00       	push   $0x80255a
  800f57:	e8 e0 0d 00 00       	call   801d3c <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f5c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f63:	f6 c2 02             	test   $0x2,%dl
  800f66:	75 0c                	jne    800f74 <fork+0x109>
  800f68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6f:	f6 c4 08             	test   $0x8,%ah
  800f72:	74 5b                	je     800fcf <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	68 05 08 00 00       	push   $0x805
  800f7c:	56                   	push   %esi
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 61 fc ff ff       	call   800be7 <sys_page_map>
		if (r < 0) {
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	79 14                	jns    800fa1 <fork+0x136>
		    	panic("sys page map fault %e");
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	68 8c 25 80 00       	push   $0x80258c
  800f95:	6a 5a                	push   $0x5a
  800f97:	68 5a 25 80 00       	push   $0x80255a
  800f9c:	e8 9b 0d 00 00       	call   801d3c <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	68 05 08 00 00       	push   $0x805
  800fa9:	56                   	push   %esi
  800faa:	6a 00                	push   $0x0
  800fac:	56                   	push   %esi
  800fad:	6a 00                	push   $0x0
  800faf:	e8 33 fc ff ff       	call   800be7 <sys_page_map>
		if (r < 0) {
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	79 3e                	jns    800ff9 <fork+0x18e>
		    	panic("sys page map fault %e");
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	68 8c 25 80 00       	push   $0x80258c
  800fc3:	6a 5e                	push   $0x5e
  800fc5:	68 5a 25 80 00       	push   $0x80255a
  800fca:	e8 6d 0d 00 00       	call   801d3c <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	6a 05                	push   $0x5
  800fd4:	56                   	push   %esi
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 09 fc ff ff       	call   800be7 <sys_page_map>
		if (r < 0) {
  800fde:	83 c4 20             	add    $0x20,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 14                	jns    800ff9 <fork+0x18e>
		    	panic("sys page map fault %e");
  800fe5:	83 ec 04             	sub    $0x4,%esp
  800fe8:	68 8c 25 80 00       	push   $0x80258c
  800fed:	6a 63                	push   $0x63
  800fef:	68 5a 25 80 00       	push   $0x80255a
  800ff4:	e8 43 0d 00 00       	call   801d3c <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800ff9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fff:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801005:	0f 85 de fe ff ff    	jne    800ee9 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80100b:	a1 04 40 80 00       	mov    0x804004,%eax
  801010:	8b 40 64             	mov    0x64(%eax),%eax
  801013:	83 ec 08             	sub    $0x8,%esp
  801016:	50                   	push   %eax
  801017:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80101a:	57                   	push   %edi
  80101b:	e8 cf fc ff ff       	call   800cef <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801020:	83 c4 08             	add    $0x8,%esp
  801023:	6a 02                	push   $0x2
  801025:	57                   	push   %edi
  801026:	e8 40 fc ff ff       	call   800c6b <sys_env_set_status>
	
	return envid;
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801030:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <sfork>:

// Challenge!
int
sfork(void)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80103e:	68 a2 25 80 00       	push   $0x8025a2
  801043:	68 a1 00 00 00       	push   $0xa1
  801048:	68 5a 25 80 00       	push   $0x80255a
  80104d:	e8 ea 0c 00 00       	call   801d3c <_panic>

00801052 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801055:	8b 45 08             	mov    0x8(%ebp),%eax
  801058:	05 00 00 00 30       	add    $0x30000000,%eax
  80105d:	c1 e8 0c             	shr    $0xc,%eax
}
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801065:	8b 45 08             	mov    0x8(%ebp),%eax
  801068:	05 00 00 00 30       	add    $0x30000000,%eax
  80106d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801072:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801084:	89 c2                	mov    %eax,%edx
  801086:	c1 ea 16             	shr    $0x16,%edx
  801089:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801090:	f6 c2 01             	test   $0x1,%dl
  801093:	74 11                	je     8010a6 <fd_alloc+0x2d>
  801095:	89 c2                	mov    %eax,%edx
  801097:	c1 ea 0c             	shr    $0xc,%edx
  80109a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a1:	f6 c2 01             	test   $0x1,%dl
  8010a4:	75 09                	jne    8010af <fd_alloc+0x36>
			*fd_store = fd;
  8010a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ad:	eb 17                	jmp    8010c6 <fd_alloc+0x4d>
  8010af:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010b9:	75 c9                	jne    801084 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010bb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010c1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010ce:	83 f8 1f             	cmp    $0x1f,%eax
  8010d1:	77 36                	ja     801109 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d3:	c1 e0 0c             	shl    $0xc,%eax
  8010d6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	c1 ea 16             	shr    $0x16,%edx
  8010e0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e7:	f6 c2 01             	test   $0x1,%dl
  8010ea:	74 24                	je     801110 <fd_lookup+0x48>
  8010ec:	89 c2                	mov    %eax,%edx
  8010ee:	c1 ea 0c             	shr    $0xc,%edx
  8010f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f8:	f6 c2 01             	test   $0x1,%dl
  8010fb:	74 1a                	je     801117 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801100:	89 02                	mov    %eax,(%edx)
	return 0;
  801102:	b8 00 00 00 00       	mov    $0x0,%eax
  801107:	eb 13                	jmp    80111c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801109:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110e:	eb 0c                	jmp    80111c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801110:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801115:	eb 05                	jmp    80111c <fd_lookup+0x54>
  801117:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 08             	sub    $0x8,%esp
  801124:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801127:	ba 34 26 80 00       	mov    $0x802634,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80112c:	eb 13                	jmp    801141 <dev_lookup+0x23>
  80112e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801131:	39 08                	cmp    %ecx,(%eax)
  801133:	75 0c                	jne    801141 <dev_lookup+0x23>
			*dev = devtab[i];
  801135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801138:	89 01                	mov    %eax,(%ecx)
			return 0;
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
  80113f:	eb 2e                	jmp    80116f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801141:	8b 02                	mov    (%edx),%eax
  801143:	85 c0                	test   %eax,%eax
  801145:	75 e7                	jne    80112e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801147:	a1 04 40 80 00       	mov    0x804004,%eax
  80114c:	8b 40 48             	mov    0x48(%eax),%eax
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	51                   	push   %ecx
  801153:	50                   	push   %eax
  801154:	68 b8 25 80 00       	push   $0x8025b8
  801159:	e8 be f0 ff ff       	call   80021c <cprintf>
	*dev = 0;
  80115e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801161:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 10             	sub    $0x10,%esp
  801179:	8b 75 08             	mov    0x8(%ebp),%esi
  80117c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80117f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801182:	50                   	push   %eax
  801183:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801189:	c1 e8 0c             	shr    $0xc,%eax
  80118c:	50                   	push   %eax
  80118d:	e8 36 ff ff ff       	call   8010c8 <fd_lookup>
  801192:	83 c4 08             	add    $0x8,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 05                	js     80119e <fd_close+0x2d>
	    || fd != fd2)
  801199:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80119c:	74 0c                	je     8011aa <fd_close+0x39>
		return (must_exist ? r : 0);
  80119e:	84 db                	test   %bl,%bl
  8011a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a5:	0f 44 c2             	cmove  %edx,%eax
  8011a8:	eb 41                	jmp    8011eb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b0:	50                   	push   %eax
  8011b1:	ff 36                	pushl  (%esi)
  8011b3:	e8 66 ff ff ff       	call   80111e <dev_lookup>
  8011b8:	89 c3                	mov    %eax,%ebx
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 1a                	js     8011db <fd_close+0x6a>
		if (dev->dev_close)
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	74 0b                	je     8011db <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011d0:	83 ec 0c             	sub    $0xc,%esp
  8011d3:	56                   	push   %esi
  8011d4:	ff d0                	call   *%eax
  8011d6:	89 c3                	mov    %eax,%ebx
  8011d8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	56                   	push   %esi
  8011df:	6a 00                	push   $0x0
  8011e1:	e8 43 fa ff ff       	call   800c29 <sys_page_unmap>
	return r;
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	89 d8                	mov    %ebx,%eax
}
  8011eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	ff 75 08             	pushl  0x8(%ebp)
  8011ff:	e8 c4 fe ff ff       	call   8010c8 <fd_lookup>
  801204:	83 c4 08             	add    $0x8,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 10                	js     80121b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	6a 01                	push   $0x1
  801210:	ff 75 f4             	pushl  -0xc(%ebp)
  801213:	e8 59 ff ff ff       	call   801171 <fd_close>
  801218:	83 c4 10             	add    $0x10,%esp
}
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <close_all>:

void
close_all(void)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	53                   	push   %ebx
  801221:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801224:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801229:	83 ec 0c             	sub    $0xc,%esp
  80122c:	53                   	push   %ebx
  80122d:	e8 c0 ff ff ff       	call   8011f2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801232:	83 c3 01             	add    $0x1,%ebx
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	83 fb 20             	cmp    $0x20,%ebx
  80123b:	75 ec                	jne    801229 <close_all+0xc>
		close(i);
}
  80123d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	57                   	push   %edi
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	83 ec 2c             	sub    $0x2c,%esp
  80124b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80124e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	ff 75 08             	pushl  0x8(%ebp)
  801255:	e8 6e fe ff ff       	call   8010c8 <fd_lookup>
  80125a:	83 c4 08             	add    $0x8,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	0f 88 c1 00 00 00    	js     801326 <dup+0xe4>
		return r;
	close(newfdnum);
  801265:	83 ec 0c             	sub    $0xc,%esp
  801268:	56                   	push   %esi
  801269:	e8 84 ff ff ff       	call   8011f2 <close>

	newfd = INDEX2FD(newfdnum);
  80126e:	89 f3                	mov    %esi,%ebx
  801270:	c1 e3 0c             	shl    $0xc,%ebx
  801273:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801279:	83 c4 04             	add    $0x4,%esp
  80127c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80127f:	e8 de fd ff ff       	call   801062 <fd2data>
  801284:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801286:	89 1c 24             	mov    %ebx,(%esp)
  801289:	e8 d4 fd ff ff       	call   801062 <fd2data>
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801294:	89 f8                	mov    %edi,%eax
  801296:	c1 e8 16             	shr    $0x16,%eax
  801299:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a0:	a8 01                	test   $0x1,%al
  8012a2:	74 37                	je     8012db <dup+0x99>
  8012a4:	89 f8                	mov    %edi,%eax
  8012a6:	c1 e8 0c             	shr    $0xc,%eax
  8012a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012b0:	f6 c2 01             	test   $0x1,%dl
  8012b3:	74 26                	je     8012db <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012bc:	83 ec 0c             	sub    $0xc,%esp
  8012bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c4:	50                   	push   %eax
  8012c5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012c8:	6a 00                	push   $0x0
  8012ca:	57                   	push   %edi
  8012cb:	6a 00                	push   $0x0
  8012cd:	e8 15 f9 ff ff       	call   800be7 <sys_page_map>
  8012d2:	89 c7                	mov    %eax,%edi
  8012d4:	83 c4 20             	add    $0x20,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 2e                	js     801309 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012de:	89 d0                	mov    %edx,%eax
  8012e0:	c1 e8 0c             	shr    $0xc,%eax
  8012e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ea:	83 ec 0c             	sub    $0xc,%esp
  8012ed:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f2:	50                   	push   %eax
  8012f3:	53                   	push   %ebx
  8012f4:	6a 00                	push   $0x0
  8012f6:	52                   	push   %edx
  8012f7:	6a 00                	push   $0x0
  8012f9:	e8 e9 f8 ff ff       	call   800be7 <sys_page_map>
  8012fe:	89 c7                	mov    %eax,%edi
  801300:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801303:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801305:	85 ff                	test   %edi,%edi
  801307:	79 1d                	jns    801326 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	53                   	push   %ebx
  80130d:	6a 00                	push   $0x0
  80130f:	e8 15 f9 ff ff       	call   800c29 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801314:	83 c4 08             	add    $0x8,%esp
  801317:	ff 75 d4             	pushl  -0x2c(%ebp)
  80131a:	6a 00                	push   $0x0
  80131c:	e8 08 f9 ff ff       	call   800c29 <sys_page_unmap>
	return r;
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	89 f8                	mov    %edi,%eax
}
  801326:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801329:	5b                   	pop    %ebx
  80132a:	5e                   	pop    %esi
  80132b:	5f                   	pop    %edi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	53                   	push   %ebx
  801332:	83 ec 14             	sub    $0x14,%esp
  801335:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801338:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	53                   	push   %ebx
  80133d:	e8 86 fd ff ff       	call   8010c8 <fd_lookup>
  801342:	83 c4 08             	add    $0x8,%esp
  801345:	89 c2                	mov    %eax,%edx
  801347:	85 c0                	test   %eax,%eax
  801349:	78 6d                	js     8013b8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801351:	50                   	push   %eax
  801352:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801355:	ff 30                	pushl  (%eax)
  801357:	e8 c2 fd ff ff       	call   80111e <dev_lookup>
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 4c                	js     8013af <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801363:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801366:	8b 42 08             	mov    0x8(%edx),%eax
  801369:	83 e0 03             	and    $0x3,%eax
  80136c:	83 f8 01             	cmp    $0x1,%eax
  80136f:	75 21                	jne    801392 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801371:	a1 04 40 80 00       	mov    0x804004,%eax
  801376:	8b 40 48             	mov    0x48(%eax),%eax
  801379:	83 ec 04             	sub    $0x4,%esp
  80137c:	53                   	push   %ebx
  80137d:	50                   	push   %eax
  80137e:	68 f9 25 80 00       	push   $0x8025f9
  801383:	e8 94 ee ff ff       	call   80021c <cprintf>
		return -E_INVAL;
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801390:	eb 26                	jmp    8013b8 <read+0x8a>
	}
	if (!dev->dev_read)
  801392:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801395:	8b 40 08             	mov    0x8(%eax),%eax
  801398:	85 c0                	test   %eax,%eax
  80139a:	74 17                	je     8013b3 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	ff 75 10             	pushl  0x10(%ebp)
  8013a2:	ff 75 0c             	pushl  0xc(%ebp)
  8013a5:	52                   	push   %edx
  8013a6:	ff d0                	call   *%eax
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	eb 09                	jmp    8013b8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013af:	89 c2                	mov    %eax,%edx
  8013b1:	eb 05                	jmp    8013b8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8013b8:	89 d0                	mov    %edx,%eax
  8013ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bd:	c9                   	leave  
  8013be:	c3                   	ret    

008013bf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	57                   	push   %edi
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d3:	eb 21                	jmp    8013f6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013d5:	83 ec 04             	sub    $0x4,%esp
  8013d8:	89 f0                	mov    %esi,%eax
  8013da:	29 d8                	sub    %ebx,%eax
  8013dc:	50                   	push   %eax
  8013dd:	89 d8                	mov    %ebx,%eax
  8013df:	03 45 0c             	add    0xc(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	57                   	push   %edi
  8013e4:	e8 45 ff ff ff       	call   80132e <read>
		if (m < 0)
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 10                	js     801400 <readn+0x41>
			return m;
		if (m == 0)
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	74 0a                	je     8013fe <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f4:	01 c3                	add    %eax,%ebx
  8013f6:	39 f3                	cmp    %esi,%ebx
  8013f8:	72 db                	jb     8013d5 <readn+0x16>
  8013fa:	89 d8                	mov    %ebx,%eax
  8013fc:	eb 02                	jmp    801400 <readn+0x41>
  8013fe:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801400:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	5f                   	pop    %edi
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	53                   	push   %ebx
  80140c:	83 ec 14             	sub    $0x14,%esp
  80140f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801412:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	53                   	push   %ebx
  801417:	e8 ac fc ff ff       	call   8010c8 <fd_lookup>
  80141c:	83 c4 08             	add    $0x8,%esp
  80141f:	89 c2                	mov    %eax,%edx
  801421:	85 c0                	test   %eax,%eax
  801423:	78 68                	js     80148d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142f:	ff 30                	pushl  (%eax)
  801431:	e8 e8 fc ff ff       	call   80111e <dev_lookup>
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 47                	js     801484 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801440:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801444:	75 21                	jne    801467 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801446:	a1 04 40 80 00       	mov    0x804004,%eax
  80144b:	8b 40 48             	mov    0x48(%eax),%eax
  80144e:	83 ec 04             	sub    $0x4,%esp
  801451:	53                   	push   %ebx
  801452:	50                   	push   %eax
  801453:	68 15 26 80 00       	push   $0x802615
  801458:	e8 bf ed ff ff       	call   80021c <cprintf>
		return -E_INVAL;
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801465:	eb 26                	jmp    80148d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801467:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80146a:	8b 52 0c             	mov    0xc(%edx),%edx
  80146d:	85 d2                	test   %edx,%edx
  80146f:	74 17                	je     801488 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801471:	83 ec 04             	sub    $0x4,%esp
  801474:	ff 75 10             	pushl  0x10(%ebp)
  801477:	ff 75 0c             	pushl  0xc(%ebp)
  80147a:	50                   	push   %eax
  80147b:	ff d2                	call   *%edx
  80147d:	89 c2                	mov    %eax,%edx
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	eb 09                	jmp    80148d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801484:	89 c2                	mov    %eax,%edx
  801486:	eb 05                	jmp    80148d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801488:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80148d:	89 d0                	mov    %edx,%eax
  80148f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <seek>:

int
seek(int fdnum, off_t offset)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80149a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	ff 75 08             	pushl  0x8(%ebp)
  8014a1:	e8 22 fc ff ff       	call   8010c8 <fd_lookup>
  8014a6:	83 c4 08             	add    $0x8,%esp
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 0e                	js     8014bb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 14             	sub    $0x14,%esp
  8014c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ca:	50                   	push   %eax
  8014cb:	53                   	push   %ebx
  8014cc:	e8 f7 fb ff ff       	call   8010c8 <fd_lookup>
  8014d1:	83 c4 08             	add    $0x8,%esp
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 65                	js     80153f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e4:	ff 30                	pushl  (%eax)
  8014e6:	e8 33 fc ff ff       	call   80111e <dev_lookup>
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 44                	js     801536 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f9:	75 21                	jne    80151c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014fb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801500:	8b 40 48             	mov    0x48(%eax),%eax
  801503:	83 ec 04             	sub    $0x4,%esp
  801506:	53                   	push   %ebx
  801507:	50                   	push   %eax
  801508:	68 d8 25 80 00       	push   $0x8025d8
  80150d:	e8 0a ed ff ff       	call   80021c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151a:	eb 23                	jmp    80153f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80151c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151f:	8b 52 18             	mov    0x18(%edx),%edx
  801522:	85 d2                	test   %edx,%edx
  801524:	74 14                	je     80153a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	ff 75 0c             	pushl  0xc(%ebp)
  80152c:	50                   	push   %eax
  80152d:	ff d2                	call   *%edx
  80152f:	89 c2                	mov    %eax,%edx
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	eb 09                	jmp    80153f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801536:	89 c2                	mov    %eax,%edx
  801538:	eb 05                	jmp    80153f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80153a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80153f:	89 d0                	mov    %edx,%eax
  801541:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801544:	c9                   	leave  
  801545:	c3                   	ret    

00801546 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	53                   	push   %ebx
  80154a:	83 ec 14             	sub    $0x14,%esp
  80154d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801550:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	ff 75 08             	pushl  0x8(%ebp)
  801557:	e8 6c fb ff ff       	call   8010c8 <fd_lookup>
  80155c:	83 c4 08             	add    $0x8,%esp
  80155f:	89 c2                	mov    %eax,%edx
  801561:	85 c0                	test   %eax,%eax
  801563:	78 58                	js     8015bd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801565:	83 ec 08             	sub    $0x8,%esp
  801568:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156f:	ff 30                	pushl  (%eax)
  801571:	e8 a8 fb ff ff       	call   80111e <dev_lookup>
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 37                	js     8015b4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80157d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801580:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801584:	74 32                	je     8015b8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801586:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801589:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801590:	00 00 00 
	stat->st_isdir = 0;
  801593:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80159a:	00 00 00 
	stat->st_dev = dev;
  80159d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8015aa:	ff 50 14             	call   *0x14(%eax)
  8015ad:	89 c2                	mov    %eax,%edx
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	eb 09                	jmp    8015bd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b4:	89 c2                	mov    %eax,%edx
  8015b6:	eb 05                	jmp    8015bd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015bd:	89 d0                	mov    %edx,%eax
  8015bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	6a 00                	push   $0x0
  8015ce:	ff 75 08             	pushl  0x8(%ebp)
  8015d1:	e8 e3 01 00 00       	call   8017b9 <open>
  8015d6:	89 c3                	mov    %eax,%ebx
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 1b                	js     8015fa <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	ff 75 0c             	pushl  0xc(%ebp)
  8015e5:	50                   	push   %eax
  8015e6:	e8 5b ff ff ff       	call   801546 <fstat>
  8015eb:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ed:	89 1c 24             	mov    %ebx,(%esp)
  8015f0:	e8 fd fb ff ff       	call   8011f2 <close>
	return r;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	89 f0                	mov    %esi,%eax
}
  8015fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fd:	5b                   	pop    %ebx
  8015fe:	5e                   	pop    %esi
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	56                   	push   %esi
  801605:	53                   	push   %ebx
  801606:	89 c6                	mov    %eax,%esi
  801608:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80160a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801611:	75 12                	jne    801625 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801613:	83 ec 0c             	sub    $0xc,%esp
  801616:	6a 01                	push   $0x1
  801618:	e8 c8 08 00 00       	call   801ee5 <ipc_find_env>
  80161d:	a3 00 40 80 00       	mov    %eax,0x804000
  801622:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801625:	6a 07                	push   $0x7
  801627:	68 00 50 80 00       	push   $0x805000
  80162c:	56                   	push   %esi
  80162d:	ff 35 00 40 80 00    	pushl  0x804000
  801633:	e8 4b 08 00 00       	call   801e83 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801638:	83 c4 0c             	add    $0xc,%esp
  80163b:	6a 00                	push   $0x0
  80163d:	53                   	push   %ebx
  80163e:	6a 00                	push   $0x0
  801640:	e8 cc 07 00 00       	call   801e11 <ipc_recv>
}
  801645:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801648:	5b                   	pop    %ebx
  801649:	5e                   	pop    %esi
  80164a:	5d                   	pop    %ebp
  80164b:	c3                   	ret    

0080164c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801652:	8b 45 08             	mov    0x8(%ebp),%eax
  801655:	8b 40 0c             	mov    0xc(%eax),%eax
  801658:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80165d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801660:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801665:	ba 00 00 00 00       	mov    $0x0,%edx
  80166a:	b8 02 00 00 00       	mov    $0x2,%eax
  80166f:	e8 8d ff ff ff       	call   801601 <fsipc>
}
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80167c:	8b 45 08             	mov    0x8(%ebp),%eax
  80167f:	8b 40 0c             	mov    0xc(%eax),%eax
  801682:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801687:	ba 00 00 00 00       	mov    $0x0,%edx
  80168c:	b8 06 00 00 00       	mov    $0x6,%eax
  801691:	e8 6b ff ff ff       	call   801601 <fsipc>
}
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	53                   	push   %ebx
  80169c:	83 ec 04             	sub    $0x4,%esp
  80169f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b7:	e8 45 ff ff ff       	call   801601 <fsipc>
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 2c                	js     8016ec <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	68 00 50 80 00       	push   $0x805000
  8016c8:	53                   	push   %ebx
  8016c9:	e8 d3 f0 ff ff       	call   8007a1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016ce:	a1 80 50 80 00       	mov    0x805080,%eax
  8016d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d9:	a1 84 50 80 00       	mov    0x805084,%eax
  8016de:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	83 ec 0c             	sub    $0xc,%esp
  8016f7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8016fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801700:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801706:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80170b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801710:	0f 47 c2             	cmova  %edx,%eax
  801713:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801718:	50                   	push   %eax
  801719:	ff 75 0c             	pushl  0xc(%ebp)
  80171c:	68 08 50 80 00       	push   $0x805008
  801721:	e8 0d f2 ff ff       	call   800933 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801726:	ba 00 00 00 00       	mov    $0x0,%edx
  80172b:	b8 04 00 00 00       	mov    $0x4,%eax
  801730:	e8 cc fe ff ff       	call   801601 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	8b 40 0c             	mov    0xc(%eax),%eax
  801745:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80174a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801750:	ba 00 00 00 00       	mov    $0x0,%edx
  801755:	b8 03 00 00 00       	mov    $0x3,%eax
  80175a:	e8 a2 fe ff ff       	call   801601 <fsipc>
  80175f:	89 c3                	mov    %eax,%ebx
  801761:	85 c0                	test   %eax,%eax
  801763:	78 4b                	js     8017b0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801765:	39 c6                	cmp    %eax,%esi
  801767:	73 16                	jae    80177f <devfile_read+0x48>
  801769:	68 44 26 80 00       	push   $0x802644
  80176e:	68 4b 26 80 00       	push   $0x80264b
  801773:	6a 7c                	push   $0x7c
  801775:	68 60 26 80 00       	push   $0x802660
  80177a:	e8 bd 05 00 00       	call   801d3c <_panic>
	assert(r <= PGSIZE);
  80177f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801784:	7e 16                	jle    80179c <devfile_read+0x65>
  801786:	68 6b 26 80 00       	push   $0x80266b
  80178b:	68 4b 26 80 00       	push   $0x80264b
  801790:	6a 7d                	push   $0x7d
  801792:	68 60 26 80 00       	push   $0x802660
  801797:	e8 a0 05 00 00       	call   801d3c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80179c:	83 ec 04             	sub    $0x4,%esp
  80179f:	50                   	push   %eax
  8017a0:	68 00 50 80 00       	push   $0x805000
  8017a5:	ff 75 0c             	pushl  0xc(%ebp)
  8017a8:	e8 86 f1 ff ff       	call   800933 <memmove>
	return r;
  8017ad:	83 c4 10             	add    $0x10,%esp
}
  8017b0:	89 d8                	mov    %ebx,%eax
  8017b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	5d                   	pop    %ebp
  8017b8:	c3                   	ret    

008017b9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	53                   	push   %ebx
  8017bd:	83 ec 20             	sub    $0x20,%esp
  8017c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017c3:	53                   	push   %ebx
  8017c4:	e8 9f ef ff ff       	call   800768 <strlen>
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017d1:	7f 67                	jg     80183a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d3:	83 ec 0c             	sub    $0xc,%esp
  8017d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d9:	50                   	push   %eax
  8017da:	e8 9a f8 ff ff       	call   801079 <fd_alloc>
  8017df:	83 c4 10             	add    $0x10,%esp
		return r;
  8017e2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 57                	js     80183f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	53                   	push   %ebx
  8017ec:	68 00 50 80 00       	push   $0x805000
  8017f1:	e8 ab ef ff ff       	call   8007a1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801801:	b8 01 00 00 00       	mov    $0x1,%eax
  801806:	e8 f6 fd ff ff       	call   801601 <fsipc>
  80180b:	89 c3                	mov    %eax,%ebx
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	79 14                	jns    801828 <open+0x6f>
		fd_close(fd, 0);
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	6a 00                	push   $0x0
  801819:	ff 75 f4             	pushl  -0xc(%ebp)
  80181c:	e8 50 f9 ff ff       	call   801171 <fd_close>
		return r;
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	89 da                	mov    %ebx,%edx
  801826:	eb 17                	jmp    80183f <open+0x86>
	}

	return fd2num(fd);
  801828:	83 ec 0c             	sub    $0xc,%esp
  80182b:	ff 75 f4             	pushl  -0xc(%ebp)
  80182e:	e8 1f f8 ff ff       	call   801052 <fd2num>
  801833:	89 c2                	mov    %eax,%edx
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	eb 05                	jmp    80183f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80183a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80183f:	89 d0                	mov    %edx,%eax
  801841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80184c:	ba 00 00 00 00       	mov    $0x0,%edx
  801851:	b8 08 00 00 00       	mov    $0x8,%eax
  801856:	e8 a6 fd ff ff       	call   801601 <fsipc>
}
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	56                   	push   %esi
  801861:	53                   	push   %ebx
  801862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801865:	83 ec 0c             	sub    $0xc,%esp
  801868:	ff 75 08             	pushl  0x8(%ebp)
  80186b:	e8 f2 f7 ff ff       	call   801062 <fd2data>
  801870:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801872:	83 c4 08             	add    $0x8,%esp
  801875:	68 77 26 80 00       	push   $0x802677
  80187a:	53                   	push   %ebx
  80187b:	e8 21 ef ff ff       	call   8007a1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801880:	8b 46 04             	mov    0x4(%esi),%eax
  801883:	2b 06                	sub    (%esi),%eax
  801885:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80188b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801892:	00 00 00 
	stat->st_dev = &devpipe;
  801895:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80189c:	30 80 00 
	return 0;
}
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a7:	5b                   	pop    %ebx
  8018a8:	5e                   	pop    %esi
  8018a9:	5d                   	pop    %ebp
  8018aa:	c3                   	ret    

008018ab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	53                   	push   %ebx
  8018af:	83 ec 0c             	sub    $0xc,%esp
  8018b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018b5:	53                   	push   %ebx
  8018b6:	6a 00                	push   $0x0
  8018b8:	e8 6c f3 ff ff       	call   800c29 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018bd:	89 1c 24             	mov    %ebx,(%esp)
  8018c0:	e8 9d f7 ff ff       	call   801062 <fd2data>
  8018c5:	83 c4 08             	add    $0x8,%esp
  8018c8:	50                   	push   %eax
  8018c9:	6a 00                	push   $0x0
  8018cb:	e8 59 f3 ff ff       	call   800c29 <sys_page_unmap>
}
  8018d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	57                   	push   %edi
  8018d9:	56                   	push   %esi
  8018da:	53                   	push   %ebx
  8018db:	83 ec 1c             	sub    $0x1c,%esp
  8018de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018e1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8018f1:	e8 28 06 00 00       	call   801f1e <pageref>
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	89 3c 24             	mov    %edi,(%esp)
  8018fb:	e8 1e 06 00 00       	call   801f1e <pageref>
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	39 c3                	cmp    %eax,%ebx
  801905:	0f 94 c1             	sete   %cl
  801908:	0f b6 c9             	movzbl %cl,%ecx
  80190b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80190e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801914:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801917:	39 ce                	cmp    %ecx,%esi
  801919:	74 1b                	je     801936 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80191b:	39 c3                	cmp    %eax,%ebx
  80191d:	75 c4                	jne    8018e3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80191f:	8b 42 58             	mov    0x58(%edx),%eax
  801922:	ff 75 e4             	pushl  -0x1c(%ebp)
  801925:	50                   	push   %eax
  801926:	56                   	push   %esi
  801927:	68 7e 26 80 00       	push   $0x80267e
  80192c:	e8 eb e8 ff ff       	call   80021c <cprintf>
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	eb ad                	jmp    8018e3 <_pipeisclosed+0xe>
	}
}
  801936:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801939:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193c:	5b                   	pop    %ebx
  80193d:	5e                   	pop    %esi
  80193e:	5f                   	pop    %edi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	57                   	push   %edi
  801945:	56                   	push   %esi
  801946:	53                   	push   %ebx
  801947:	83 ec 28             	sub    $0x28,%esp
  80194a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80194d:	56                   	push   %esi
  80194e:	e8 0f f7 ff ff       	call   801062 <fd2data>
  801953:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	bf 00 00 00 00       	mov    $0x0,%edi
  80195d:	eb 4b                	jmp    8019aa <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80195f:	89 da                	mov    %ebx,%edx
  801961:	89 f0                	mov    %esi,%eax
  801963:	e8 6d ff ff ff       	call   8018d5 <_pipeisclosed>
  801968:	85 c0                	test   %eax,%eax
  80196a:	75 48                	jne    8019b4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80196c:	e8 14 f2 ff ff       	call   800b85 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801971:	8b 43 04             	mov    0x4(%ebx),%eax
  801974:	8b 0b                	mov    (%ebx),%ecx
  801976:	8d 51 20             	lea    0x20(%ecx),%edx
  801979:	39 d0                	cmp    %edx,%eax
  80197b:	73 e2                	jae    80195f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80197d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801980:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801984:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801987:	89 c2                	mov    %eax,%edx
  801989:	c1 fa 1f             	sar    $0x1f,%edx
  80198c:	89 d1                	mov    %edx,%ecx
  80198e:	c1 e9 1b             	shr    $0x1b,%ecx
  801991:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801994:	83 e2 1f             	and    $0x1f,%edx
  801997:	29 ca                	sub    %ecx,%edx
  801999:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80199d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019a1:	83 c0 01             	add    $0x1,%eax
  8019a4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a7:	83 c7 01             	add    $0x1,%edi
  8019aa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019ad:	75 c2                	jne    801971 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019af:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b2:	eb 05                	jmp    8019b9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019bc:	5b                   	pop    %ebx
  8019bd:	5e                   	pop    %esi
  8019be:	5f                   	pop    %edi
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	57                   	push   %edi
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 18             	sub    $0x18,%esp
  8019ca:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019cd:	57                   	push   %edi
  8019ce:	e8 8f f6 ff ff       	call   801062 <fd2data>
  8019d3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019dd:	eb 3d                	jmp    801a1c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019df:	85 db                	test   %ebx,%ebx
  8019e1:	74 04                	je     8019e7 <devpipe_read+0x26>
				return i;
  8019e3:	89 d8                	mov    %ebx,%eax
  8019e5:	eb 44                	jmp    801a2b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019e7:	89 f2                	mov    %esi,%edx
  8019e9:	89 f8                	mov    %edi,%eax
  8019eb:	e8 e5 fe ff ff       	call   8018d5 <_pipeisclosed>
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	75 32                	jne    801a26 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019f4:	e8 8c f1 ff ff       	call   800b85 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019f9:	8b 06                	mov    (%esi),%eax
  8019fb:	3b 46 04             	cmp    0x4(%esi),%eax
  8019fe:	74 df                	je     8019df <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a00:	99                   	cltd   
  801a01:	c1 ea 1b             	shr    $0x1b,%edx
  801a04:	01 d0                	add    %edx,%eax
  801a06:	83 e0 1f             	and    $0x1f,%eax
  801a09:	29 d0                	sub    %edx,%eax
  801a0b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a13:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a16:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a19:	83 c3 01             	add    $0x1,%ebx
  801a1c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a1f:	75 d8                	jne    8019f9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a21:	8b 45 10             	mov    0x10(%ebp),%eax
  801a24:	eb 05                	jmp    801a2b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a26:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5f                   	pop    %edi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
  801a38:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3e:	50                   	push   %eax
  801a3f:	e8 35 f6 ff ff       	call   801079 <fd_alloc>
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	89 c2                	mov    %eax,%edx
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	0f 88 2c 01 00 00    	js     801b7d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a51:	83 ec 04             	sub    $0x4,%esp
  801a54:	68 07 04 00 00       	push   $0x407
  801a59:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5c:	6a 00                	push   $0x0
  801a5e:	e8 41 f1 ff ff       	call   800ba4 <sys_page_alloc>
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	89 c2                	mov    %eax,%edx
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	0f 88 0d 01 00 00    	js     801b7d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a76:	50                   	push   %eax
  801a77:	e8 fd f5 ff ff       	call   801079 <fd_alloc>
  801a7c:	89 c3                	mov    %eax,%ebx
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	0f 88 e2 00 00 00    	js     801b6b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a89:	83 ec 04             	sub    $0x4,%esp
  801a8c:	68 07 04 00 00       	push   $0x407
  801a91:	ff 75 f0             	pushl  -0x10(%ebp)
  801a94:	6a 00                	push   $0x0
  801a96:	e8 09 f1 ff ff       	call   800ba4 <sys_page_alloc>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	0f 88 c3 00 00 00    	js     801b6b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	e8 af f5 ff ff       	call   801062 <fd2data>
  801ab3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab5:	83 c4 0c             	add    $0xc,%esp
  801ab8:	68 07 04 00 00       	push   $0x407
  801abd:	50                   	push   %eax
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 df f0 ff ff       	call   800ba4 <sys_page_alloc>
  801ac5:	89 c3                	mov    %eax,%ebx
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	0f 88 89 00 00 00    	js     801b5b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad2:	83 ec 0c             	sub    $0xc,%esp
  801ad5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad8:	e8 85 f5 ff ff       	call   801062 <fd2data>
  801add:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ae4:	50                   	push   %eax
  801ae5:	6a 00                	push   $0x0
  801ae7:	56                   	push   %esi
  801ae8:	6a 00                	push   $0x0
  801aea:	e8 f8 f0 ff ff       	call   800be7 <sys_page_map>
  801aef:	89 c3                	mov    %eax,%ebx
  801af1:	83 c4 20             	add    $0x20,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 55                	js     801b4d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801af8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b01:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b06:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b16:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	ff 75 f4             	pushl  -0xc(%ebp)
  801b28:	e8 25 f5 ff ff       	call   801052 <fd2num>
  801b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b30:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b32:	83 c4 04             	add    $0x4,%esp
  801b35:	ff 75 f0             	pushl  -0x10(%ebp)
  801b38:	e8 15 f5 ff ff       	call   801052 <fd2num>
  801b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b40:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4b:	eb 30                	jmp    801b7d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b4d:	83 ec 08             	sub    $0x8,%esp
  801b50:	56                   	push   %esi
  801b51:	6a 00                	push   $0x0
  801b53:	e8 d1 f0 ff ff       	call   800c29 <sys_page_unmap>
  801b58:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b5b:	83 ec 08             	sub    $0x8,%esp
  801b5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801b61:	6a 00                	push   $0x0
  801b63:	e8 c1 f0 ff ff       	call   800c29 <sys_page_unmap>
  801b68:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b6b:	83 ec 08             	sub    $0x8,%esp
  801b6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b71:	6a 00                	push   $0x0
  801b73:	e8 b1 f0 ff ff       	call   800c29 <sys_page_unmap>
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b7d:	89 d0                	mov    %edx,%eax
  801b7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8f:	50                   	push   %eax
  801b90:	ff 75 08             	pushl  0x8(%ebp)
  801b93:	e8 30 f5 ff ff       	call   8010c8 <fd_lookup>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 18                	js     801bb7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba5:	e8 b8 f4 ff ff       	call   801062 <fd2data>
	return _pipeisclosed(fd, p);
  801baa:	89 c2                	mov    %eax,%edx
  801bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801baf:	e8 21 fd ff ff       	call   8018d5 <_pipeisclosed>
  801bb4:	83 c4 10             	add    $0x10,%esp
}
  801bb7:	c9                   	leave  
  801bb8:	c3                   	ret    

00801bb9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bc9:	68 96 26 80 00       	push   $0x802696
  801bce:	ff 75 0c             	pushl  0xc(%ebp)
  801bd1:	e8 cb eb ff ff       	call   8007a1 <strcpy>
	return 0;
}
  801bd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	57                   	push   %edi
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bee:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf4:	eb 2d                	jmp    801c23 <devcons_write+0x46>
		m = n - tot;
  801bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bf9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bfb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bfe:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c03:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c06:	83 ec 04             	sub    $0x4,%esp
  801c09:	53                   	push   %ebx
  801c0a:	03 45 0c             	add    0xc(%ebp),%eax
  801c0d:	50                   	push   %eax
  801c0e:	57                   	push   %edi
  801c0f:	e8 1f ed ff ff       	call   800933 <memmove>
		sys_cputs(buf, m);
  801c14:	83 c4 08             	add    $0x8,%esp
  801c17:	53                   	push   %ebx
  801c18:	57                   	push   %edi
  801c19:	e8 ca ee ff ff       	call   800ae8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c1e:	01 de                	add    %ebx,%esi
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	89 f0                	mov    %esi,%eax
  801c25:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c28:	72 cc                	jb     801bf6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	83 ec 08             	sub    $0x8,%esp
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c41:	74 2a                	je     801c6d <devcons_read+0x3b>
  801c43:	eb 05                	jmp    801c4a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c45:	e8 3b ef ff ff       	call   800b85 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c4a:	e8 b7 ee ff ff       	call   800b06 <sys_cgetc>
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	74 f2                	je     801c45 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 16                	js     801c6d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c57:	83 f8 04             	cmp    $0x4,%eax
  801c5a:	74 0c                	je     801c68 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5f:	88 02                	mov    %al,(%edx)
	return 1;
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	eb 05                	jmp    801c6d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c75:	8b 45 08             	mov    0x8(%ebp),%eax
  801c78:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c7b:	6a 01                	push   $0x1
  801c7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c80:	50                   	push   %eax
  801c81:	e8 62 ee ff ff       	call   800ae8 <sys_cputs>
}
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <getchar>:

int
getchar(void)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c91:	6a 01                	push   $0x1
  801c93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c96:	50                   	push   %eax
  801c97:	6a 00                	push   $0x0
  801c99:	e8 90 f6 ff ff       	call   80132e <read>
	if (r < 0)
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	78 0f                	js     801cb4 <getchar+0x29>
		return r;
	if (r < 1)
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	7e 06                	jle    801caf <getchar+0x24>
		return -E_EOF;
	return c;
  801ca9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cad:	eb 05                	jmp    801cb4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801caf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbf:	50                   	push   %eax
  801cc0:	ff 75 08             	pushl  0x8(%ebp)
  801cc3:	e8 00 f4 ff ff       	call   8010c8 <fd_lookup>
  801cc8:	83 c4 10             	add    $0x10,%esp
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 11                	js     801ce0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cd8:	39 10                	cmp    %edx,(%eax)
  801cda:	0f 94 c0             	sete   %al
  801cdd:	0f b6 c0             	movzbl %al,%eax
}
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <opencons>:

int
opencons(void)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	e8 88 f3 ff ff       	call   801079 <fd_alloc>
  801cf1:	83 c4 10             	add    $0x10,%esp
		return r;
  801cf4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 3e                	js     801d38 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cfa:	83 ec 04             	sub    $0x4,%esp
  801cfd:	68 07 04 00 00       	push   $0x407
  801d02:	ff 75 f4             	pushl  -0xc(%ebp)
  801d05:	6a 00                	push   $0x0
  801d07:	e8 98 ee ff ff       	call   800ba4 <sys_page_alloc>
  801d0c:	83 c4 10             	add    $0x10,%esp
		return r;
  801d0f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d11:	85 c0                	test   %eax,%eax
  801d13:	78 23                	js     801d38 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d15:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d23:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d2a:	83 ec 0c             	sub    $0xc,%esp
  801d2d:	50                   	push   %eax
  801d2e:	e8 1f f3 ff ff       	call   801052 <fd2num>
  801d33:	89 c2                	mov    %eax,%edx
  801d35:	83 c4 10             	add    $0x10,%esp
}
  801d38:	89 d0                	mov    %edx,%eax
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d41:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d44:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d4a:	e8 17 ee ff ff       	call   800b66 <sys_getenvid>
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	ff 75 0c             	pushl  0xc(%ebp)
  801d55:	ff 75 08             	pushl  0x8(%ebp)
  801d58:	56                   	push   %esi
  801d59:	50                   	push   %eax
  801d5a:	68 a4 26 80 00       	push   $0x8026a4
  801d5f:	e8 b8 e4 ff ff       	call   80021c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d64:	83 c4 18             	add    $0x18,%esp
  801d67:	53                   	push   %ebx
  801d68:	ff 75 10             	pushl  0x10(%ebp)
  801d6b:	e8 5b e4 ff ff       	call   8001cb <vcprintf>
	cprintf("\n");
  801d70:	c7 04 24 0f 22 80 00 	movl   $0x80220f,(%esp)
  801d77:	e8 a0 e4 ff ff       	call   80021c <cprintf>
  801d7c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d7f:	cc                   	int3   
  801d80:	eb fd                	jmp    801d7f <_panic+0x43>

00801d82 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d88:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d8f:	75 2a                	jne    801dbb <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d91:	83 ec 04             	sub    $0x4,%esp
  801d94:	6a 07                	push   $0x7
  801d96:	68 00 f0 bf ee       	push   $0xeebff000
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 02 ee ff ff       	call   800ba4 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	79 12                	jns    801dbb <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801da9:	50                   	push   %eax
  801daa:	68 c8 26 80 00       	push   $0x8026c8
  801daf:	6a 23                	push   $0x23
  801db1:	68 cc 26 80 00       	push   $0x8026cc
  801db6:	e8 81 ff ff ff       	call   801d3c <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dc3:	83 ec 08             	sub    $0x8,%esp
  801dc6:	68 ed 1d 80 00       	push   $0x801ded
  801dcb:	6a 00                	push   $0x0
  801dcd:	e8 1d ef ff ff       	call   800cef <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	79 12                	jns    801deb <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dd9:	50                   	push   %eax
  801dda:	68 c8 26 80 00       	push   $0x8026c8
  801ddf:	6a 2c                	push   $0x2c
  801de1:	68 cc 26 80 00       	push   $0x8026cc
  801de6:	e8 51 ff ff ff       	call   801d3c <_panic>
	}
}
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    

00801ded <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ded:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dee:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801df3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801df5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801df8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dfc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e01:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e05:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e07:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e0a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e0b:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e0e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e0f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e10:	c3                   	ret    

00801e11 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	56                   	push   %esi
  801e15:	53                   	push   %ebx
  801e16:	8b 75 08             	mov    0x8(%ebp),%esi
  801e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	75 12                	jne    801e35 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e23:	83 ec 0c             	sub    $0xc,%esp
  801e26:	68 00 00 c0 ee       	push   $0xeec00000
  801e2b:	e8 24 ef ff ff       	call   800d54 <sys_ipc_recv>
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	eb 0c                	jmp    801e41 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	50                   	push   %eax
  801e39:	e8 16 ef ff ff       	call   800d54 <sys_ipc_recv>
  801e3e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e41:	85 f6                	test   %esi,%esi
  801e43:	0f 95 c1             	setne  %cl
  801e46:	85 db                	test   %ebx,%ebx
  801e48:	0f 95 c2             	setne  %dl
  801e4b:	84 d1                	test   %dl,%cl
  801e4d:	74 09                	je     801e58 <ipc_recv+0x47>
  801e4f:	89 c2                	mov    %eax,%edx
  801e51:	c1 ea 1f             	shr    $0x1f,%edx
  801e54:	84 d2                	test   %dl,%dl
  801e56:	75 24                	jne    801e7c <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e58:	85 f6                	test   %esi,%esi
  801e5a:	74 0a                	je     801e66 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801e5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e61:	8b 40 74             	mov    0x74(%eax),%eax
  801e64:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e66:	85 db                	test   %ebx,%ebx
  801e68:	74 0a                	je     801e74 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801e6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6f:	8b 40 78             	mov    0x78(%eax),%eax
  801e72:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e74:	a1 04 40 80 00       	mov    0x804004,%eax
  801e79:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e7f:	5b                   	pop    %ebx
  801e80:	5e                   	pop    %esi
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    

00801e83 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	57                   	push   %edi
  801e87:	56                   	push   %esi
  801e88:	53                   	push   %ebx
  801e89:	83 ec 0c             	sub    $0xc,%esp
  801e8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e95:	85 db                	test   %ebx,%ebx
  801e97:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e9c:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e9f:	ff 75 14             	pushl  0x14(%ebp)
  801ea2:	53                   	push   %ebx
  801ea3:	56                   	push   %esi
  801ea4:	57                   	push   %edi
  801ea5:	e8 87 ee ff ff       	call   800d31 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801eaa:	89 c2                	mov    %eax,%edx
  801eac:	c1 ea 1f             	shr    $0x1f,%edx
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	84 d2                	test   %dl,%dl
  801eb4:	74 17                	je     801ecd <ipc_send+0x4a>
  801eb6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eb9:	74 12                	je     801ecd <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ebb:	50                   	push   %eax
  801ebc:	68 da 26 80 00       	push   $0x8026da
  801ec1:	6a 47                	push   $0x47
  801ec3:	68 e8 26 80 00       	push   $0x8026e8
  801ec8:	e8 6f fe ff ff       	call   801d3c <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ecd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed0:	75 07                	jne    801ed9 <ipc_send+0x56>
			sys_yield();
  801ed2:	e8 ae ec ff ff       	call   800b85 <sys_yield>
  801ed7:	eb c6                	jmp    801e9f <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	75 c2                	jne    801e9f <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801edd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee0:	5b                   	pop    %ebx
  801ee1:	5e                   	pop    %esi
  801ee2:	5f                   	pop    %edi
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    

00801ee5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eeb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ef0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ef3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ef9:	8b 52 50             	mov    0x50(%edx),%edx
  801efc:	39 ca                	cmp    %ecx,%edx
  801efe:	75 0d                	jne    801f0d <ipc_find_env+0x28>
			return envs[i].env_id;
  801f00:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f03:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f08:	8b 40 48             	mov    0x48(%eax),%eax
  801f0b:	eb 0f                	jmp    801f1c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f0d:	83 c0 01             	add    $0x1,%eax
  801f10:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f15:	75 d9                	jne    801ef0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f24:	89 d0                	mov    %edx,%eax
  801f26:	c1 e8 16             	shr    $0x16,%eax
  801f29:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f30:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f35:	f6 c1 01             	test   $0x1,%cl
  801f38:	74 1d                	je     801f57 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f3a:	c1 ea 0c             	shr    $0xc,%edx
  801f3d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f44:	f6 c2 01             	test   $0x1,%dl
  801f47:	74 0e                	je     801f57 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f49:	c1 ea 0c             	shr    $0xc,%edx
  801f4c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f53:	ef 
  801f54:	0f b7 c0             	movzwl %ax,%eax
}
  801f57:	5d                   	pop    %ebp
  801f58:	c3                   	ret    
  801f59:	66 90                	xchg   %ax,%ax
  801f5b:	66 90                	xchg   %ax,%ax
  801f5d:	66 90                	xchg   %ax,%ax
  801f5f:	90                   	nop

00801f60 <__udivdi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 1c             	sub    $0x1c,%esp
  801f67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f77:	85 f6                	test   %esi,%esi
  801f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f7d:	89 ca                	mov    %ecx,%edx
  801f7f:	89 f8                	mov    %edi,%eax
  801f81:	75 3d                	jne    801fc0 <__udivdi3+0x60>
  801f83:	39 cf                	cmp    %ecx,%edi
  801f85:	0f 87 c5 00 00 00    	ja     802050 <__udivdi3+0xf0>
  801f8b:	85 ff                	test   %edi,%edi
  801f8d:	89 fd                	mov    %edi,%ebp
  801f8f:	75 0b                	jne    801f9c <__udivdi3+0x3c>
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
  801f96:	31 d2                	xor    %edx,%edx
  801f98:	f7 f7                	div    %edi
  801f9a:	89 c5                	mov    %eax,%ebp
  801f9c:	89 c8                	mov    %ecx,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	f7 f5                	div    %ebp
  801fa2:	89 c1                	mov    %eax,%ecx
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	89 cf                	mov    %ecx,%edi
  801fa8:	f7 f5                	div    %ebp
  801faa:	89 c3                	mov    %eax,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	39 ce                	cmp    %ecx,%esi
  801fc2:	77 74                	ja     802038 <__udivdi3+0xd8>
  801fc4:	0f bd fe             	bsr    %esi,%edi
  801fc7:	83 f7 1f             	xor    $0x1f,%edi
  801fca:	0f 84 98 00 00 00    	je     802068 <__udivdi3+0x108>
  801fd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	89 c5                	mov    %eax,%ebp
  801fd9:	29 fb                	sub    %edi,%ebx
  801fdb:	d3 e6                	shl    %cl,%esi
  801fdd:	89 d9                	mov    %ebx,%ecx
  801fdf:	d3 ed                	shr    %cl,%ebp
  801fe1:	89 f9                	mov    %edi,%ecx
  801fe3:	d3 e0                	shl    %cl,%eax
  801fe5:	09 ee                	or     %ebp,%esi
  801fe7:	89 d9                	mov    %ebx,%ecx
  801fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fed:	89 d5                	mov    %edx,%ebp
  801fef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ff3:	d3 ed                	shr    %cl,%ebp
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e2                	shl    %cl,%edx
  801ff9:	89 d9                	mov    %ebx,%ecx
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	09 c2                	or     %eax,%edx
  801fff:	89 d0                	mov    %edx,%eax
  802001:	89 ea                	mov    %ebp,%edx
  802003:	f7 f6                	div    %esi
  802005:	89 d5                	mov    %edx,%ebp
  802007:	89 c3                	mov    %eax,%ebx
  802009:	f7 64 24 0c          	mull   0xc(%esp)
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	72 10                	jb     802021 <__udivdi3+0xc1>
  802011:	8b 74 24 08          	mov    0x8(%esp),%esi
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e6                	shl    %cl,%esi
  802019:	39 c6                	cmp    %eax,%esi
  80201b:	73 07                	jae    802024 <__udivdi3+0xc4>
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	75 03                	jne    802024 <__udivdi3+0xc4>
  802021:	83 eb 01             	sub    $0x1,%ebx
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 d8                	mov    %ebx,%eax
  802028:	89 fa                	mov    %edi,%edx
  80202a:	83 c4 1c             	add    $0x1c,%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    
  802032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802038:	31 ff                	xor    %edi,%edi
  80203a:	31 db                	xor    %ebx,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d8                	mov    %ebx,%eax
  802052:	f7 f7                	div    %edi
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 c3                	mov    %eax,%ebx
  802058:	89 d8                	mov    %ebx,%eax
  80205a:	89 fa                	mov    %edi,%edx
  80205c:	83 c4 1c             	add    $0x1c,%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    
  802064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802068:	39 ce                	cmp    %ecx,%esi
  80206a:	72 0c                	jb     802078 <__udivdi3+0x118>
  80206c:	31 db                	xor    %ebx,%ebx
  80206e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802072:	0f 87 34 ff ff ff    	ja     801fac <__udivdi3+0x4c>
  802078:	bb 01 00 00 00       	mov    $0x1,%ebx
  80207d:	e9 2a ff ff ff       	jmp    801fac <__udivdi3+0x4c>
  802082:	66 90                	xchg   %ax,%ax
  802084:	66 90                	xchg   %ax,%ax
  802086:	66 90                	xchg   %ax,%ax
  802088:	66 90                	xchg   %ax,%ax
  80208a:	66 90                	xchg   %ax,%ax
  80208c:	66 90                	xchg   %ax,%ax
  80208e:	66 90                	xchg   %ax,%ax

00802090 <__umoddi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80209b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80209f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 d2                	test   %edx,%edx
  8020a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f3                	mov    %esi,%ebx
  8020b3:	89 3c 24             	mov    %edi,(%esp)
  8020b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ba:	75 1c                	jne    8020d8 <__umoddi3+0x48>
  8020bc:	39 f7                	cmp    %esi,%edi
  8020be:	76 50                	jbe    802110 <__umoddi3+0x80>
  8020c0:	89 c8                	mov    %ecx,%eax
  8020c2:	89 f2                	mov    %esi,%edx
  8020c4:	f7 f7                	div    %edi
  8020c6:	89 d0                	mov    %edx,%eax
  8020c8:	31 d2                	xor    %edx,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	89 d0                	mov    %edx,%eax
  8020dc:	77 52                	ja     802130 <__umoddi3+0xa0>
  8020de:	0f bd ea             	bsr    %edx,%ebp
  8020e1:	83 f5 1f             	xor    $0x1f,%ebp
  8020e4:	75 5a                	jne    802140 <__umoddi3+0xb0>
  8020e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ea:	0f 82 e0 00 00 00    	jb     8021d0 <__umoddi3+0x140>
  8020f0:	39 0c 24             	cmp    %ecx,(%esp)
  8020f3:	0f 86 d7 00 00 00    	jbe    8021d0 <__umoddi3+0x140>
  8020f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802101:	83 c4 1c             	add    $0x1c,%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5f                   	pop    %edi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	85 ff                	test   %edi,%edi
  802112:	89 fd                	mov    %edi,%ebp
  802114:	75 0b                	jne    802121 <__umoddi3+0x91>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f7                	div    %edi
  80211f:	89 c5                	mov    %eax,%ebp
  802121:	89 f0                	mov    %esi,%eax
  802123:	31 d2                	xor    %edx,%edx
  802125:	f7 f5                	div    %ebp
  802127:	89 c8                	mov    %ecx,%eax
  802129:	f7 f5                	div    %ebp
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	eb 99                	jmp    8020c8 <__umoddi3+0x38>
  80212f:	90                   	nop
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	83 c4 1c             	add    $0x1c,%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	8b 34 24             	mov    (%esp),%esi
  802143:	bf 20 00 00 00       	mov    $0x20,%edi
  802148:	89 e9                	mov    %ebp,%ecx
  80214a:	29 ef                	sub    %ebp,%edi
  80214c:	d3 e0                	shl    %cl,%eax
  80214e:	89 f9                	mov    %edi,%ecx
  802150:	89 f2                	mov    %esi,%edx
  802152:	d3 ea                	shr    %cl,%edx
  802154:	89 e9                	mov    %ebp,%ecx
  802156:	09 c2                	or     %eax,%edx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 14 24             	mov    %edx,(%esp)
  80215d:	89 f2                	mov    %esi,%edx
  80215f:	d3 e2                	shl    %cl,%edx
  802161:	89 f9                	mov    %edi,%ecx
  802163:	89 54 24 04          	mov    %edx,0x4(%esp)
  802167:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	89 c6                	mov    %eax,%esi
  802171:	d3 e3                	shl    %cl,%ebx
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 d0                	mov    %edx,%eax
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	09 d8                	or     %ebx,%eax
  80217d:	89 d3                	mov    %edx,%ebx
  80217f:	89 f2                	mov    %esi,%edx
  802181:	f7 34 24             	divl   (%esp)
  802184:	89 d6                	mov    %edx,%esi
  802186:	d3 e3                	shl    %cl,%ebx
  802188:	f7 64 24 04          	mull   0x4(%esp)
  80218c:	39 d6                	cmp    %edx,%esi
  80218e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802192:	89 d1                	mov    %edx,%ecx
  802194:	89 c3                	mov    %eax,%ebx
  802196:	72 08                	jb     8021a0 <__umoddi3+0x110>
  802198:	75 11                	jne    8021ab <__umoddi3+0x11b>
  80219a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80219e:	73 0b                	jae    8021ab <__umoddi3+0x11b>
  8021a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021a4:	1b 14 24             	sbb    (%esp),%edx
  8021a7:	89 d1                	mov    %edx,%ecx
  8021a9:	89 c3                	mov    %eax,%ebx
  8021ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021af:	29 da                	sub    %ebx,%edx
  8021b1:	19 ce                	sbb    %ecx,%esi
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	d3 e0                	shl    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	d3 ea                	shr    %cl,%edx
  8021bd:	89 e9                	mov    %ebp,%ecx
  8021bf:	d3 ee                	shr    %cl,%esi
  8021c1:	09 d0                	or     %edx,%eax
  8021c3:	89 f2                	mov    %esi,%edx
  8021c5:	83 c4 1c             	add    $0x1c,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5f                   	pop    %edi
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
  8021d0:	29 f9                	sub    %edi,%ecx
  8021d2:	19 d6                	sbb    %edx,%esi
  8021d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021dc:	e9 18 ff ff ff       	jmp    8020f9 <__umoddi3+0x69>
