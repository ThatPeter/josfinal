
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
  80003d:	e8 3c 0b 00 00       	call   800b7e <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 22 80 00       	push   $0x802260
  80004c:	e8 e3 01 00 00       	call   800234 <cprintf>

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
  80007e:	e8 fd 06 00 00       	call   800780 <strlen>
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
  800095:	68 71 22 80 00       	push   $0x802271
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 c1 06 00 00       	call   800766 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 f6 0d 00 00       	call   800ea3 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 c5 00 00 00       	call   800187 <exit>
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
  8000d2:	68 70 22 80 00       	push   $0x802270
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
  8000f4:	e8 85 0a 00 00       	call   800b7e <sys_getenvid>
  8000f9:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8000fb:	83 ec 08             	sub    $0x8,%esp
  8000fe:	50                   	push   %eax
  8000ff:	68 78 22 80 00       	push   $0x802278
  800104:	e8 2b 01 00 00       	call   800234 <cprintf>
  800109:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80010f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  800121:	89 c1                	mov    %eax,%ecx
  800123:	c1 e1 07             	shl    $0x7,%ecx
  800126:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  80012d:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  800130:	39 cb                	cmp    %ecx,%ebx
  800132:	0f 44 fa             	cmove  %edx,%edi
  800135:	b9 01 00 00 00       	mov    $0x1,%ecx
  80013a:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  80013d:	83 c0 01             	add    $0x1,%eax
  800140:	81 c2 84 00 00 00    	add    $0x84,%edx
  800146:	3d 00 04 00 00       	cmp    $0x400,%eax
  80014b:	75 d4                	jne    800121 <libmain+0x40>
  80014d:	89 f0                	mov    %esi,%eax
  80014f:	84 c0                	test   %al,%al
  800151:	74 06                	je     800159 <libmain+0x78>
  800153:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800159:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80015d:	7e 0a                	jle    800169 <libmain+0x88>
		binaryname = argv[0];
  80015f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800162:	8b 00                	mov    (%eax),%eax
  800164:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800169:	83 ec 08             	sub    $0x8,%esp
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	e8 55 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800177:	e8 0b 00 00 00       	call   800187 <exit>
}
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80018d:	e8 ee 10 00 00       	call   801280 <close_all>
	sys_env_destroy(0);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	6a 00                	push   $0x0
  800197:	e8 a1 09 00 00       	call   800b3d <sys_env_destroy>
}
  80019c:	83 c4 10             	add    $0x10,%esp
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 04             	sub    $0x4,%esp
  8001a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ab:	8b 13                	mov    (%ebx),%edx
  8001ad:	8d 42 01             	lea    0x1(%edx),%eax
  8001b0:	89 03                	mov    %eax,(%ebx)
  8001b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001be:	75 1a                	jne    8001da <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c0:	83 ec 08             	sub    $0x8,%esp
  8001c3:	68 ff 00 00 00       	push   $0xff
  8001c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cb:	50                   	push   %eax
  8001cc:	e8 2f 09 00 00       	call   800b00 <sys_cputs>
		b->idx = 0;
  8001d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001da:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	ff 75 0c             	pushl  0xc(%ebp)
  800203:	ff 75 08             	pushl  0x8(%ebp)
  800206:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	68 a1 01 80 00       	push   $0x8001a1
  800212:	e8 54 01 00 00       	call   80036b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800217:	83 c4 08             	add    $0x8,%esp
  80021a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800220:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800226:	50                   	push   %eax
  800227:	e8 d4 08 00 00       	call   800b00 <sys_cputs>

	return b.cnt;
}
  80022c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023d:	50                   	push   %eax
  80023e:	ff 75 08             	pushl  0x8(%ebp)
  800241:	e8 9d ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 1c             	sub    $0x1c,%esp
  800251:	89 c7                	mov    %eax,%edi
  800253:	89 d6                	mov    %edx,%esi
  800255:	8b 45 08             	mov    0x8(%ebp),%eax
  800258:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800261:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026f:	39 d3                	cmp    %edx,%ebx
  800271:	72 05                	jb     800278 <printnum+0x30>
  800273:	39 45 10             	cmp    %eax,0x10(%ebp)
  800276:	77 45                	ja     8002bd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	ff 75 18             	pushl  0x18(%ebp)
  80027e:	8b 45 14             	mov    0x14(%ebp),%eax
  800281:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800284:	53                   	push   %ebx
  800285:	ff 75 10             	pushl  0x10(%ebp)
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 34 1d 00 00       	call   801fd0 <__udivdi3>
  80029c:	83 c4 18             	add    $0x18,%esp
  80029f:	52                   	push   %edx
  8002a0:	50                   	push   %eax
  8002a1:	89 f2                	mov    %esi,%edx
  8002a3:	89 f8                	mov    %edi,%eax
  8002a5:	e8 9e ff ff ff       	call   800248 <printnum>
  8002aa:	83 c4 20             	add    $0x20,%esp
  8002ad:	eb 18                	jmp    8002c7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002af:	83 ec 08             	sub    $0x8,%esp
  8002b2:	56                   	push   %esi
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	ff d7                	call   *%edi
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	eb 03                	jmp    8002c0 <printnum+0x78>
  8002bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c0:	83 eb 01             	sub    $0x1,%ebx
  8002c3:	85 db                	test   %ebx,%ebx
  8002c5:	7f e8                	jg     8002af <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c7:	83 ec 08             	sub    $0x8,%esp
  8002ca:	56                   	push   %esi
  8002cb:	83 ec 04             	sub    $0x4,%esp
  8002ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002da:	e8 21 1e 00 00       	call   802100 <__umoddi3>
  8002df:	83 c4 14             	add    $0x14,%esp
  8002e2:	0f be 80 a1 22 80 00 	movsbl 0x8022a1(%eax),%eax
  8002e9:	50                   	push   %eax
  8002ea:	ff d7                	call   *%edi
}
  8002ec:	83 c4 10             	add    $0x10,%esp
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fa:	83 fa 01             	cmp    $0x1,%edx
  8002fd:	7e 0e                	jle    80030d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 08             	lea    0x8(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	8b 52 04             	mov    0x4(%edx),%edx
  80030b:	eb 22                	jmp    80032f <getuint+0x38>
	else if (lflag)
  80030d:	85 d2                	test   %edx,%edx
  80030f:	74 10                	je     800321 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800311:	8b 10                	mov    (%eax),%edx
  800313:	8d 4a 04             	lea    0x4(%edx),%ecx
  800316:	89 08                	mov    %ecx,(%eax)
  800318:	8b 02                	mov    (%edx),%eax
  80031a:	ba 00 00 00 00       	mov    $0x0,%edx
  80031f:	eb 0e                	jmp    80032f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800321:	8b 10                	mov    (%eax),%edx
  800323:	8d 4a 04             	lea    0x4(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 02                	mov    (%edx),%eax
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800337:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	3b 50 04             	cmp    0x4(%eax),%edx
  800340:	73 0a                	jae    80034c <sprintputch+0x1b>
		*b->buf++ = ch;
  800342:	8d 4a 01             	lea    0x1(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	88 02                	mov    %al,(%edx)
}
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800354:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800357:	50                   	push   %eax
  800358:	ff 75 10             	pushl  0x10(%ebp)
  80035b:	ff 75 0c             	pushl  0xc(%ebp)
  80035e:	ff 75 08             	pushl  0x8(%ebp)
  800361:	e8 05 00 00 00       	call   80036b <vprintfmt>
	va_end(ap);
}
  800366:	83 c4 10             	add    $0x10,%esp
  800369:	c9                   	leave  
  80036a:	c3                   	ret    

0080036b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	57                   	push   %edi
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
  800371:	83 ec 2c             	sub    $0x2c,%esp
  800374:	8b 75 08             	mov    0x8(%ebp),%esi
  800377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037d:	eb 12                	jmp    800391 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037f:	85 c0                	test   %eax,%eax
  800381:	0f 84 89 03 00 00    	je     800710 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	53                   	push   %ebx
  80038b:	50                   	push   %eax
  80038c:	ff d6                	call   *%esi
  80038e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800391:	83 c7 01             	add    $0x1,%edi
  800394:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800398:	83 f8 25             	cmp    $0x25,%eax
  80039b:	75 e2                	jne    80037f <vprintfmt+0x14>
  80039d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003af:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bb:	eb 07                	jmp    8003c4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8d 47 01             	lea    0x1(%edi),%eax
  8003c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ca:	0f b6 07             	movzbl (%edi),%eax
  8003cd:	0f b6 c8             	movzbl %al,%ecx
  8003d0:	83 e8 23             	sub    $0x23,%eax
  8003d3:	3c 55                	cmp    $0x55,%al
  8003d5:	0f 87 1a 03 00 00    	ja     8006f5 <vprintfmt+0x38a>
  8003db:	0f b6 c0             	movzbl %al,%eax
  8003de:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ec:	eb d6                	jmp    8003c4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800400:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800403:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800406:	83 fa 09             	cmp    $0x9,%edx
  800409:	77 39                	ja     800444 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040e:	eb e9                	jmp    8003f9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 48 04             	lea    0x4(%eax),%ecx
  800416:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800421:	eb 27                	jmp    80044a <vprintfmt+0xdf>
  800423:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800426:	85 c0                	test   %eax,%eax
  800428:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042d:	0f 49 c8             	cmovns %eax,%ecx
  800430:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800436:	eb 8c                	jmp    8003c4 <vprintfmt+0x59>
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800442:	eb 80                	jmp    8003c4 <vprintfmt+0x59>
  800444:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800447:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044e:	0f 89 70 ff ff ff    	jns    8003c4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800454:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800461:	e9 5e ff ff ff       	jmp    8003c4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800466:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046c:	e9 53 ff ff ff       	jmp    8003c4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	89 55 14             	mov    %edx,0x14(%ebp)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	ff 30                	pushl  (%eax)
  800480:	ff d6                	call   *%esi
			break;
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800488:	e9 04 ff ff ff       	jmp    800391 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 50 04             	lea    0x4(%eax),%edx
  800493:	89 55 14             	mov    %edx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	99                   	cltd   
  800499:	31 d0                	xor    %edx,%eax
  80049b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049d:	83 f8 0f             	cmp    $0xf,%eax
  8004a0:	7f 0b                	jg     8004ad <vprintfmt+0x142>
  8004a2:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	75 18                	jne    8004c5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ad:	50                   	push   %eax
  8004ae:	68 b9 22 80 00       	push   $0x8022b9
  8004b3:	53                   	push   %ebx
  8004b4:	56                   	push   %esi
  8004b5:	e8 94 fe ff ff       	call   80034e <printfmt>
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c0:	e9 cc fe ff ff       	jmp    800391 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c5:	52                   	push   %edx
  8004c6:	68 ed 26 80 00       	push   $0x8026ed
  8004cb:	53                   	push   %ebx
  8004cc:	56                   	push   %esi
  8004cd:	e8 7c fe ff ff       	call   80034e <printfmt>
  8004d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d8:	e9 b4 fe ff ff       	jmp    800391 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e8:	85 ff                	test   %edi,%edi
  8004ea:	b8 b2 22 80 00       	mov    $0x8022b2,%eax
  8004ef:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f6:	0f 8e 94 00 00 00    	jle    800590 <vprintfmt+0x225>
  8004fc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800500:	0f 84 98 00 00 00    	je     80059e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 d0             	pushl  -0x30(%ebp)
  80050c:	57                   	push   %edi
  80050d:	e8 86 02 00 00       	call   800798 <strnlen>
  800512:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800515:	29 c1                	sub    %eax,%ecx
  800517:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800521:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800524:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800527:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	eb 0f                	jmp    80053a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	ff 75 e0             	pushl  -0x20(%ebp)
  800532:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	83 ef 01             	sub    $0x1,%edi
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	85 ff                	test   %edi,%edi
  80053c:	7f ed                	jg     80052b <vprintfmt+0x1c0>
  80053e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800541:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800544:	85 c9                	test   %ecx,%ecx
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	0f 49 c1             	cmovns %ecx,%eax
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 75 08             	mov    %esi,0x8(%ebp)
  800553:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800556:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800559:	89 cb                	mov    %ecx,%ebx
  80055b:	eb 4d                	jmp    8005aa <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800561:	74 1b                	je     80057e <vprintfmt+0x213>
  800563:	0f be c0             	movsbl %al,%eax
  800566:	83 e8 20             	sub    $0x20,%eax
  800569:	83 f8 5e             	cmp    $0x5e,%eax
  80056c:	76 10                	jbe    80057e <vprintfmt+0x213>
					putch('?', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	6a 3f                	push   $0x3f
  800576:	ff 55 08             	call   *0x8(%ebp)
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	eb 0d                	jmp    80058b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	52                   	push   %edx
  800585:	ff 55 08             	call   *0x8(%ebp)
  800588:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058b:	83 eb 01             	sub    $0x1,%ebx
  80058e:	eb 1a                	jmp    8005aa <vprintfmt+0x23f>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	eb 0c                	jmp    8005aa <vprintfmt+0x23f>
  80059e:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005aa:	83 c7 01             	add    $0x1,%edi
  8005ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b1:	0f be d0             	movsbl %al,%edx
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	74 23                	je     8005db <vprintfmt+0x270>
  8005b8:	85 f6                	test   %esi,%esi
  8005ba:	78 a1                	js     80055d <vprintfmt+0x1f2>
  8005bc:	83 ee 01             	sub    $0x1,%esi
  8005bf:	79 9c                	jns    80055d <vprintfmt+0x1f2>
  8005c1:	89 df                	mov    %ebx,%edi
  8005c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c9:	eb 18                	jmp    8005e3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 20                	push   $0x20
  8005d1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d3:	83 ef 01             	sub    $0x1,%edi
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	eb 08                	jmp    8005e3 <vprintfmt+0x278>
  8005db:	89 df                	mov    %ebx,%edi
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	85 ff                	test   %edi,%edi
  8005e5:	7f e4                	jg     8005cb <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ea:	e9 a2 fd ff ff       	jmp    800391 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ef:	83 fa 01             	cmp    $0x1,%edx
  8005f2:	7e 16                	jle    80060a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 08             	lea    0x8(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 50 04             	mov    0x4(%eax),%edx
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800608:	eb 32                	jmp    80063c <vprintfmt+0x2d1>
	else if (lflag)
  80060a:	85 d2                	test   %edx,%edx
  80060c:	74 18                	je     800626 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	89 c1                	mov    %eax,%ecx
  80061e:	c1 f9 1f             	sar    $0x1f,%ecx
  800621:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800624:	eb 16                	jmp    80063c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800634:	89 c1                	mov    %eax,%ecx
  800636:	c1 f9 1f             	sar    $0x1f,%ecx
  800639:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800642:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800647:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064b:	79 74                	jns    8006c1 <vprintfmt+0x356>
				putch('-', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 2d                	push   $0x2d
  800653:	ff d6                	call   *%esi
				num = -(long long) num;
  800655:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800658:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065b:	f7 d8                	neg    %eax
  80065d:	83 d2 00             	adc    $0x0,%edx
  800660:	f7 da                	neg    %edx
  800662:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800665:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066a:	eb 55                	jmp    8006c1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	e8 83 fc ff ff       	call   8002f7 <getuint>
			base = 10;
  800674:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800679:	eb 46                	jmp    8006c1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 74 fc ff ff       	call   8002f7 <getuint>
			base = 8;
  800683:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800688:	eb 37                	jmp    8006c1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 30                	push   $0x30
  800690:	ff d6                	call   *%esi
			putch('x', putdat);
  800692:	83 c4 08             	add    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 78                	push   $0x78
  800698:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006aa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ad:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b2:	eb 0d                	jmp    8006c1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b7:	e8 3b fc ff ff       	call   8002f7 <getuint>
			base = 16;
  8006bc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c1:	83 ec 0c             	sub    $0xc,%esp
  8006c4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c8:	57                   	push   %edi
  8006c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cc:	51                   	push   %ecx
  8006cd:	52                   	push   %edx
  8006ce:	50                   	push   %eax
  8006cf:	89 da                	mov    %ebx,%edx
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	e8 70 fb ff ff       	call   800248 <printnum>
			break;
  8006d8:	83 c4 20             	add    $0x20,%esp
  8006db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006de:	e9 ae fc ff ff       	jmp    800391 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	51                   	push   %ecx
  8006e8:	ff d6                	call   *%esi
			break;
  8006ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f0:	e9 9c fc ff ff       	jmp    800391 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 25                	push   $0x25
  8006fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb 03                	jmp    800705 <vprintfmt+0x39a>
  800702:	83 ef 01             	sub    $0x1,%edi
  800705:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800709:	75 f7                	jne    800702 <vprintfmt+0x397>
  80070b:	e9 81 fc ff ff       	jmp    800391 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800710:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 18             	sub    $0x18,%esp
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800724:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800727:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800735:	85 c0                	test   %eax,%eax
  800737:	74 26                	je     80075f <vsnprintf+0x47>
  800739:	85 d2                	test   %edx,%edx
  80073b:	7e 22                	jle    80075f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073d:	ff 75 14             	pushl  0x14(%ebp)
  800740:	ff 75 10             	pushl  0x10(%ebp)
  800743:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	68 31 03 80 00       	push   $0x800331
  80074c:	e8 1a fc ff ff       	call   80036b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800751:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800754:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800757:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	eb 05                	jmp    800764 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076f:	50                   	push   %eax
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	ff 75 08             	pushl  0x8(%ebp)
  800779:	e8 9a ff ff ff       	call   800718 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 03                	jmp    800790 <strlen+0x10>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800794:	75 f7                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a6:	eb 03                	jmp    8007ab <strnlen+0x13>
		n++;
  8007a8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	39 c2                	cmp    %eax,%edx
  8007ad:	74 08                	je     8007b7 <strnlen+0x1f>
  8007af:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b3:	75 f3                	jne    8007a8 <strnlen+0x10>
  8007b5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	83 c1 01             	add    $0x1,%ecx
  8007cb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d2:	84 db                	test   %bl,%bl
  8007d4:	75 ef                	jne    8007c5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e0:	53                   	push   %ebx
  8007e1:	e8 9a ff ff ff       	call   800780 <strlen>
  8007e6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	01 d8                	add    %ebx,%eax
  8007ee:	50                   	push   %eax
  8007ef:	e8 c5 ff ff ff       	call   8007b9 <strcpy>
	return dst;
}
  8007f4:	89 d8                	mov    %ebx,%eax
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800806:	89 f3                	mov    %esi,%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080b:	89 f2                	mov    %esi,%edx
  80080d:	eb 0f                	jmp    80081e <strncpy+0x23>
		*dst++ = *src;
  80080f:	83 c2 01             	add    $0x1,%edx
  800812:	0f b6 01             	movzbl (%ecx),%eax
  800815:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800818:	80 39 01             	cmpb   $0x1,(%ecx)
  80081b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	39 da                	cmp    %ebx,%edx
  800820:	75 ed                	jne    80080f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800822:	89 f0                	mov    %esi,%eax
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800833:	8b 55 10             	mov    0x10(%ebp),%edx
  800836:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 21                	je     80085d <strlcpy+0x35>
  80083c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800840:	89 f2                	mov    %esi,%edx
  800842:	eb 09                	jmp    80084d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800844:	83 c2 01             	add    $0x1,%edx
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084d:	39 c2                	cmp    %eax,%edx
  80084f:	74 09                	je     80085a <strlcpy+0x32>
  800851:	0f b6 19             	movzbl (%ecx),%ebx
  800854:	84 db                	test   %bl,%bl
  800856:	75 ec                	jne    800844 <strlcpy+0x1c>
  800858:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085d:	29 f0                	sub    %esi,%eax
}
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086c:	eb 06                	jmp    800874 <strcmp+0x11>
		p++, q++;
  80086e:	83 c1 01             	add    $0x1,%ecx
  800871:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800874:	0f b6 01             	movzbl (%ecx),%eax
  800877:	84 c0                	test   %al,%al
  800879:	74 04                	je     80087f <strcmp+0x1c>
  80087b:	3a 02                	cmp    (%edx),%al
  80087d:	74 ef                	je     80086e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 c0             	movzbl %al,%eax
  800882:	0f b6 12             	movzbl (%edx),%edx
  800885:	29 d0                	sub    %edx,%eax
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	89 c3                	mov    %eax,%ebx
  800895:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800898:	eb 06                	jmp    8008a0 <strncmp+0x17>
		n--, p++, q++;
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a0:	39 d8                	cmp    %ebx,%eax
  8008a2:	74 15                	je     8008b9 <strncmp+0x30>
  8008a4:	0f b6 08             	movzbl (%eax),%ecx
  8008a7:	84 c9                	test   %cl,%cl
  8008a9:	74 04                	je     8008af <strncmp+0x26>
  8008ab:	3a 0a                	cmp    (%edx),%cl
  8008ad:	74 eb                	je     80089a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 00             	movzbl (%eax),%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
  8008b7:	eb 05                	jmp    8008be <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	eb 07                	jmp    8008d4 <strchr+0x13>
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 0f                	je     8008e0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	0f b6 10             	movzbl (%eax),%edx
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f2                	jne    8008cd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ec:	eb 03                	jmp    8008f1 <strfind+0xf>
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 04                	je     8008fc <strfind+0x1a>
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 f2                	jne    8008ee <strfind+0xc>
			break;
	return (char *) s;
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	57                   	push   %edi
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 7d 08             	mov    0x8(%ebp),%edi
  800907:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090a:	85 c9                	test   %ecx,%ecx
  80090c:	74 36                	je     800944 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800914:	75 28                	jne    80093e <memset+0x40>
  800916:	f6 c1 03             	test   $0x3,%cl
  800919:	75 23                	jne    80093e <memset+0x40>
		c &= 0xFF;
  80091b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091f:	89 d3                	mov    %edx,%ebx
  800921:	c1 e3 08             	shl    $0x8,%ebx
  800924:	89 d6                	mov    %edx,%esi
  800926:	c1 e6 18             	shl    $0x18,%esi
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e0 10             	shl    $0x10,%eax
  80092e:	09 f0                	or     %esi,%eax
  800930:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800932:	89 d8                	mov    %ebx,%eax
  800934:	09 d0                	or     %edx,%eax
  800936:	c1 e9 02             	shr    $0x2,%ecx
  800939:	fc                   	cld    
  80093a:	f3 ab                	rep stos %eax,%es:(%edi)
  80093c:	eb 06                	jmp    800944 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	fc                   	cld    
  800942:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800944:	89 f8                	mov    %edi,%eax
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800959:	39 c6                	cmp    %eax,%esi
  80095b:	73 35                	jae    800992 <memmove+0x47>
  80095d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800960:	39 d0                	cmp    %edx,%eax
  800962:	73 2e                	jae    800992 <memmove+0x47>
		s += n;
		d += n;
  800964:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	89 d6                	mov    %edx,%esi
  800969:	09 fe                	or     %edi,%esi
  80096b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800971:	75 13                	jne    800986 <memmove+0x3b>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 0e                	jne    800986 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800978:	83 ef 04             	sub    $0x4,%edi
  80097b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097e:	c1 e9 02             	shr    $0x2,%ecx
  800981:	fd                   	std    
  800982:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800984:	eb 09                	jmp    80098f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800986:	83 ef 01             	sub    $0x1,%edi
  800989:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098c:	fd                   	std    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098f:	fc                   	cld    
  800990:	eb 1d                	jmp    8009af <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800992:	89 f2                	mov    %esi,%edx
  800994:	09 c2                	or     %eax,%edx
  800996:	f6 c2 03             	test   $0x3,%dl
  800999:	75 0f                	jne    8009aa <memmove+0x5f>
  80099b:	f6 c1 03             	test   $0x3,%cl
  80099e:	75 0a                	jne    8009aa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
  8009a3:	89 c7                	mov    %eax,%edi
  8009a5:	fc                   	cld    
  8009a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a8:	eb 05                	jmp    8009af <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009af:	5e                   	pop    %esi
  8009b0:	5f                   	pop    %edi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b6:	ff 75 10             	pushl  0x10(%ebp)
  8009b9:	ff 75 0c             	pushl  0xc(%ebp)
  8009bc:	ff 75 08             	pushl  0x8(%ebp)
  8009bf:	e8 87 ff ff ff       	call   80094b <memmove>
}
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d1:	89 c6                	mov    %eax,%esi
  8009d3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d6:	eb 1a                	jmp    8009f2 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d8:	0f b6 08             	movzbl (%eax),%ecx
  8009db:	0f b6 1a             	movzbl (%edx),%ebx
  8009de:	38 d9                	cmp    %bl,%cl
  8009e0:	74 0a                	je     8009ec <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e2:	0f b6 c1             	movzbl %cl,%eax
  8009e5:	0f b6 db             	movzbl %bl,%ebx
  8009e8:	29 d8                	sub    %ebx,%eax
  8009ea:	eb 0f                	jmp    8009fb <memcmp+0x35>
		s1++, s2++;
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f2:	39 f0                	cmp    %esi,%eax
  8009f4:	75 e2                	jne    8009d8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a06:	89 c1                	mov    %eax,%ecx
  800a08:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0f:	eb 0a                	jmp    800a1b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	39 da                	cmp    %ebx,%edx
  800a16:	74 07                	je     800a1f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a18:	83 c0 01             	add    $0x1,%eax
  800a1b:	39 c8                	cmp    %ecx,%eax
  800a1d:	72 f2                	jb     800a11 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1f:	5b                   	pop    %ebx
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2e:	eb 03                	jmp    800a33 <strtol+0x11>
		s++;
  800a30:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a33:	0f b6 01             	movzbl (%ecx),%eax
  800a36:	3c 20                	cmp    $0x20,%al
  800a38:	74 f6                	je     800a30 <strtol+0xe>
  800a3a:	3c 09                	cmp    $0x9,%al
  800a3c:	74 f2                	je     800a30 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3e:	3c 2b                	cmp    $0x2b,%al
  800a40:	75 0a                	jne    800a4c <strtol+0x2a>
		s++;
  800a42:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a45:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4a:	eb 11                	jmp    800a5d <strtol+0x3b>
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a51:	3c 2d                	cmp    $0x2d,%al
  800a53:	75 08                	jne    800a5d <strtol+0x3b>
		s++, neg = 1;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a63:	75 15                	jne    800a7a <strtol+0x58>
  800a65:	80 39 30             	cmpb   $0x30,(%ecx)
  800a68:	75 10                	jne    800a7a <strtol+0x58>
  800a6a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6e:	75 7c                	jne    800aec <strtol+0xca>
		s += 2, base = 16;
  800a70:	83 c1 02             	add    $0x2,%ecx
  800a73:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a78:	eb 16                	jmp    800a90 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7a:	85 db                	test   %ebx,%ebx
  800a7c:	75 12                	jne    800a90 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a83:	80 39 30             	cmpb   $0x30,(%ecx)
  800a86:	75 08                	jne    800a90 <strtol+0x6e>
		s++, base = 8;
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
  800a95:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a98:	0f b6 11             	movzbl (%ecx),%edx
  800a9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 09             	cmp    $0x9,%bl
  800aa3:	77 08                	ja     800aad <strtol+0x8b>
			dig = *s - '0';
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 30             	sub    $0x30,%edx
  800aab:	eb 22                	jmp    800acf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aad:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 08                	ja     800abf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab7:	0f be d2             	movsbl %dl,%edx
  800aba:	83 ea 57             	sub    $0x57,%edx
  800abd:	eb 10                	jmp    800acf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	80 fb 19             	cmp    $0x19,%bl
  800ac7:	77 16                	ja     800adf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac9:	0f be d2             	movsbl %dl,%edx
  800acc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad2:	7d 0b                	jge    800adf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad4:	83 c1 01             	add    $0x1,%ecx
  800ad7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800add:	eb b9                	jmp    800a98 <strtol+0x76>

	if (endptr)
  800adf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae3:	74 0d                	je     800af2 <strtol+0xd0>
		*endptr = (char *) s;
  800ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae8:	89 0e                	mov    %ecx,(%esi)
  800aea:	eb 06                	jmp    800af2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	74 98                	je     800a88 <strtol+0x66>
  800af0:	eb 9e                	jmp    800a90 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af2:	89 c2                	mov    %eax,%edx
  800af4:	f7 da                	neg    %edx
  800af6:	85 ff                	test   %edi,%edi
  800af8:	0f 45 c2             	cmovne %edx,%eax
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	89 c3                	mov    %eax,%ebx
  800b13:	89 c7                	mov    %eax,%edi
  800b15:	89 c6                	mov    %eax,%esi
  800b17:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	89 cb                	mov    %ecx,%ebx
  800b55:	89 cf                	mov    %ecx,%edi
  800b57:	89 ce                	mov    %ecx,%esi
  800b59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	7e 17                	jle    800b76 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	50                   	push   %eax
  800b63:	6a 03                	push   $0x3
  800b65:	68 9f 25 80 00       	push   $0x80259f
  800b6a:	6a 23                	push   $0x23
  800b6c:	68 bc 25 80 00       	push   $0x8025bc
  800b71:	e8 29 12 00 00       	call   801d9f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8e:	89 d1                	mov    %edx,%ecx
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	89 d7                	mov    %edx,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_yield>:

void
sys_yield(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	be 00 00 00 00       	mov    $0x0,%esi
  800bca:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd8:	89 f7                	mov    %esi,%edi
  800bda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 04                	push   $0x4
  800be6:	68 9f 25 80 00       	push   $0x80259f
  800beb:	6a 23                	push   $0x23
  800bed:	68 bc 25 80 00       	push   $0x8025bc
  800bf2:	e8 a8 11 00 00       	call   801d9f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	8b 55 08             	mov    0x8(%ebp),%edx
  800c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c16:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c19:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 05                	push   $0x5
  800c28:	68 9f 25 80 00       	push   $0x80259f
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 bc 25 80 00       	push   $0x8025bc
  800c34:	e8 66 11 00 00       	call   801d9f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	89 de                	mov    %ebx,%esi
  800c5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 06                	push   $0x6
  800c6a:	68 9f 25 80 00       	push   $0x80259f
  800c6f:	6a 23                	push   $0x23
  800c71:	68 bc 25 80 00       	push   $0x8025bc
  800c76:	e8 24 11 00 00       	call   801d9f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 08 00 00 00       	mov    $0x8,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 08                	push   $0x8
  800cac:	68 9f 25 80 00       	push   $0x80259f
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 bc 25 80 00       	push   $0x8025bc
  800cb8:	e8 e2 10 00 00       	call   801d9f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 df                	mov    %ebx,%edi
  800ce0:	89 de                	mov    %ebx,%esi
  800ce2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 09                	push   $0x9
  800cee:	68 9f 25 80 00       	push   $0x80259f
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 bc 25 80 00       	push   $0x8025bc
  800cfa:	e8 a0 10 00 00       	call   801d9f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 0a                	push   $0xa
  800d30:	68 9f 25 80 00       	push   $0x80259f
  800d35:	6a 23                	push   $0x23
  800d37:	68 bc 25 80 00       	push   $0x8025bc
  800d3c:	e8 5e 10 00 00       	call   801d9f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	be 00 00 00 00       	mov    $0x0,%esi
  800d54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d65:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	89 cb                	mov    %ecx,%ebx
  800d84:	89 cf                	mov    %ecx,%edi
  800d86:	89 ce                	mov    %ecx,%esi
  800d88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	7e 17                	jle    800da5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	50                   	push   %eax
  800d92:	6a 0d                	push   $0xd
  800d94:	68 9f 25 80 00       	push   $0x80259f
  800d99:	6a 23                	push   $0x23
  800d9b:	68 bc 25 80 00       	push   $0x8025bc
  800da0:	e8 fa 0f 00 00       	call   801d9f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	89 cb                	mov    %ecx,%ebx
  800dc2:	89 cf                	mov    %ecx,%edi
  800dc4:	89 ce                	mov    %ecx,%esi
  800dc6:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd7:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dd9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ddd:	74 11                	je     800df0 <pgfault+0x23>
  800ddf:	89 d8                	mov    %ebx,%eax
  800de1:	c1 e8 0c             	shr    $0xc,%eax
  800de4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800deb:	f6 c4 08             	test   $0x8,%ah
  800dee:	75 14                	jne    800e04 <pgfault+0x37>
		panic("faulting access");
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	68 ca 25 80 00       	push   $0x8025ca
  800df8:	6a 1d                	push   $0x1d
  800dfa:	68 da 25 80 00       	push   $0x8025da
  800dff:	e8 9b 0f 00 00       	call   801d9f <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	6a 07                	push   $0x7
  800e09:	68 00 f0 7f 00       	push   $0x7ff000
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 a7 fd ff ff       	call   800bbc <sys_page_alloc>
	if (r < 0) {
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	79 12                	jns    800e2e <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e1c:	50                   	push   %eax
  800e1d:	68 e5 25 80 00       	push   $0x8025e5
  800e22:	6a 2b                	push   $0x2b
  800e24:	68 da 25 80 00       	push   $0x8025da
  800e29:	e8 71 0f 00 00       	call   801d9f <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e2e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e34:	83 ec 04             	sub    $0x4,%esp
  800e37:	68 00 10 00 00       	push   $0x1000
  800e3c:	53                   	push   %ebx
  800e3d:	68 00 f0 7f 00       	push   $0x7ff000
  800e42:	e8 6c fb ff ff       	call   8009b3 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e47:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e4e:	53                   	push   %ebx
  800e4f:	6a 00                	push   $0x0
  800e51:	68 00 f0 7f 00       	push   $0x7ff000
  800e56:	6a 00                	push   $0x0
  800e58:	e8 a2 fd ff ff       	call   800bff <sys_page_map>
	if (r < 0) {
  800e5d:	83 c4 20             	add    $0x20,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	79 12                	jns    800e76 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e64:	50                   	push   %eax
  800e65:	68 e5 25 80 00       	push   $0x8025e5
  800e6a:	6a 32                	push   $0x32
  800e6c:	68 da 25 80 00       	push   $0x8025da
  800e71:	e8 29 0f 00 00       	call   801d9f <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e76:	83 ec 08             	sub    $0x8,%esp
  800e79:	68 00 f0 7f 00       	push   $0x7ff000
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 bc fd ff ff       	call   800c41 <sys_page_unmap>
	if (r < 0) {
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	79 12                	jns    800e9e <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e8c:	50                   	push   %eax
  800e8d:	68 e5 25 80 00       	push   $0x8025e5
  800e92:	6a 36                	push   $0x36
  800e94:	68 da 25 80 00       	push   $0x8025da
  800e99:	e8 01 0f 00 00       	call   801d9f <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800eac:	68 cd 0d 80 00       	push   $0x800dcd
  800eb1:	e8 2f 0f 00 00       	call   801de5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb6:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebb:	cd 30                	int    $0x30
  800ebd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	79 17                	jns    800ede <fork+0x3b>
		panic("fork fault %e");
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	68 fe 25 80 00       	push   $0x8025fe
  800ecf:	68 83 00 00 00       	push   $0x83
  800ed4:	68 da 25 80 00       	push   $0x8025da
  800ed9:	e8 c1 0e 00 00       	call   801d9f <_panic>
  800ede:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ee0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ee4:	75 25                	jne    800f0b <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ee6:	e8 93 fc ff ff       	call   800b7e <sys_getenvid>
  800eeb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef0:	89 c2                	mov    %eax,%edx
  800ef2:	c1 e2 07             	shl    $0x7,%edx
  800ef5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800efc:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	e9 61 01 00 00       	jmp    80106c <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	6a 07                	push   $0x7
  800f10:	68 00 f0 bf ee       	push   $0xeebff000
  800f15:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f18:	e8 9f fc ff ff       	call   800bbc <sys_page_alloc>
  800f1d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f20:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f25:	89 d8                	mov    %ebx,%eax
  800f27:	c1 e8 16             	shr    $0x16,%eax
  800f2a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f31:	a8 01                	test   $0x1,%al
  800f33:	0f 84 fc 00 00 00    	je     801035 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f39:	89 d8                	mov    %ebx,%eax
  800f3b:	c1 e8 0c             	shr    $0xc,%eax
  800f3e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f45:	f6 c2 01             	test   $0x1,%dl
  800f48:	0f 84 e7 00 00 00    	je     801035 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f4e:	89 c6                	mov    %eax,%esi
  800f50:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f53:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5a:	f6 c6 04             	test   $0x4,%dh
  800f5d:	74 39                	je     800f98 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f5f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f66:	83 ec 0c             	sub    $0xc,%esp
  800f69:	25 07 0e 00 00       	and    $0xe07,%eax
  800f6e:	50                   	push   %eax
  800f6f:	56                   	push   %esi
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	6a 00                	push   $0x0
  800f74:	e8 86 fc ff ff       	call   800bff <sys_page_map>
		if (r < 0) {
  800f79:	83 c4 20             	add    $0x20,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	0f 89 b1 00 00 00    	jns    801035 <fork+0x192>
		    	panic("sys page map fault %e");
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	68 0c 26 80 00       	push   $0x80260c
  800f8c:	6a 53                	push   $0x53
  800f8e:	68 da 25 80 00       	push   $0x8025da
  800f93:	e8 07 0e 00 00       	call   801d9f <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f98:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9f:	f6 c2 02             	test   $0x2,%dl
  800fa2:	75 0c                	jne    800fb0 <fork+0x10d>
  800fa4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fab:	f6 c4 08             	test   $0x8,%ah
  800fae:	74 5b                	je     80100b <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	68 05 08 00 00       	push   $0x805
  800fb8:	56                   	push   %esi
  800fb9:	57                   	push   %edi
  800fba:	56                   	push   %esi
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 3d fc ff ff       	call   800bff <sys_page_map>
		if (r < 0) {
  800fc2:	83 c4 20             	add    $0x20,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	79 14                	jns    800fdd <fork+0x13a>
		    	panic("sys page map fault %e");
  800fc9:	83 ec 04             	sub    $0x4,%esp
  800fcc:	68 0c 26 80 00       	push   $0x80260c
  800fd1:	6a 5a                	push   $0x5a
  800fd3:	68 da 25 80 00       	push   $0x8025da
  800fd8:	e8 c2 0d 00 00       	call   801d9f <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fdd:	83 ec 0c             	sub    $0xc,%esp
  800fe0:	68 05 08 00 00       	push   $0x805
  800fe5:	56                   	push   %esi
  800fe6:	6a 00                	push   $0x0
  800fe8:	56                   	push   %esi
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 0f fc ff ff       	call   800bff <sys_page_map>
		if (r < 0) {
  800ff0:	83 c4 20             	add    $0x20,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	79 3e                	jns    801035 <fork+0x192>
		    	panic("sys page map fault %e");
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	68 0c 26 80 00       	push   $0x80260c
  800fff:	6a 5e                	push   $0x5e
  801001:	68 da 25 80 00       	push   $0x8025da
  801006:	e8 94 0d 00 00       	call   801d9f <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	6a 05                	push   $0x5
  801010:	56                   	push   %esi
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	6a 00                	push   $0x0
  801015:	e8 e5 fb ff ff       	call   800bff <sys_page_map>
		if (r < 0) {
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	79 14                	jns    801035 <fork+0x192>
		    	panic("sys page map fault %e");
  801021:	83 ec 04             	sub    $0x4,%esp
  801024:	68 0c 26 80 00       	push   $0x80260c
  801029:	6a 63                	push   $0x63
  80102b:	68 da 25 80 00       	push   $0x8025da
  801030:	e8 6a 0d 00 00       	call   801d9f <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801035:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80103b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801041:	0f 85 de fe ff ff    	jne    800f25 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801047:	a1 04 40 80 00       	mov    0x804004,%eax
  80104c:	8b 40 6c             	mov    0x6c(%eax),%eax
  80104f:	83 ec 08             	sub    $0x8,%esp
  801052:	50                   	push   %eax
  801053:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801056:	57                   	push   %edi
  801057:	e8 ab fc ff ff       	call   800d07 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80105c:	83 c4 08             	add    $0x8,%esp
  80105f:	6a 02                	push   $0x2
  801061:	57                   	push   %edi
  801062:	e8 1c fc ff ff       	call   800c83 <sys_env_set_status>
	
	return envid;
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80106c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106f:	5b                   	pop    %ebx
  801070:	5e                   	pop    %esi
  801071:	5f                   	pop    %edi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <sfork>:

envid_t
sfork(void)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801077:	b8 00 00 00 00       	mov    $0x0,%eax
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("in fork.c thread create. func: %x\n", func);
  801086:	83 ec 08             	sub    $0x8,%esp
  801089:	53                   	push   %ebx
  80108a:	68 24 26 80 00       	push   $0x802624
  80108f:	e8 a0 f1 ff ff       	call   800234 <cprintf>
	envid_t id = sys_thread_create((uintptr_t )func);
  801094:	89 1c 24             	mov    %ebx,(%esp)
  801097:	e8 11 fd ff ff       	call   800dad <sys_thread_create>
  80109c:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80109e:	83 c4 08             	add    $0x8,%esp
  8010a1:	53                   	push   %ebx
  8010a2:	68 24 26 80 00       	push   $0x802624
  8010a7:	e8 88 f1 ff ff       	call   800234 <cprintf>
	return id;
}
  8010ac:	89 f0                	mov    %esi,%eax
  8010ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bb:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c0:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cb:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010e7:	89 c2                	mov    %eax,%edx
  8010e9:	c1 ea 16             	shr    $0x16,%edx
  8010ec:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f3:	f6 c2 01             	test   $0x1,%dl
  8010f6:	74 11                	je     801109 <fd_alloc+0x2d>
  8010f8:	89 c2                	mov    %eax,%edx
  8010fa:	c1 ea 0c             	shr    $0xc,%edx
  8010fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801104:	f6 c2 01             	test   $0x1,%dl
  801107:	75 09                	jne    801112 <fd_alloc+0x36>
			*fd_store = fd;
  801109:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110b:	b8 00 00 00 00       	mov    $0x0,%eax
  801110:	eb 17                	jmp    801129 <fd_alloc+0x4d>
  801112:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801117:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80111c:	75 c9                	jne    8010e7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80111e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801124:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801131:	83 f8 1f             	cmp    $0x1f,%eax
  801134:	77 36                	ja     80116c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801136:	c1 e0 0c             	shl    $0xc,%eax
  801139:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80113e:	89 c2                	mov    %eax,%edx
  801140:	c1 ea 16             	shr    $0x16,%edx
  801143:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114a:	f6 c2 01             	test   $0x1,%dl
  80114d:	74 24                	je     801173 <fd_lookup+0x48>
  80114f:	89 c2                	mov    %eax,%edx
  801151:	c1 ea 0c             	shr    $0xc,%edx
  801154:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115b:	f6 c2 01             	test   $0x1,%dl
  80115e:	74 1a                	je     80117a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801160:	8b 55 0c             	mov    0xc(%ebp),%edx
  801163:	89 02                	mov    %eax,(%edx)
	return 0;
  801165:	b8 00 00 00 00       	mov    $0x0,%eax
  80116a:	eb 13                	jmp    80117f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80116c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801171:	eb 0c                	jmp    80117f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801178:	eb 05                	jmp    80117f <fd_lookup+0x54>
  80117a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118a:	ba c4 26 80 00       	mov    $0x8026c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80118f:	eb 13                	jmp    8011a4 <dev_lookup+0x23>
  801191:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801194:	39 08                	cmp    %ecx,(%eax)
  801196:	75 0c                	jne    8011a4 <dev_lookup+0x23>
			*dev = devtab[i];
  801198:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119d:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a2:	eb 2e                	jmp    8011d2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a4:	8b 02                	mov    (%edx),%eax
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	75 e7                	jne    801191 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8011af:	8b 40 50             	mov    0x50(%eax),%eax
  8011b2:	83 ec 04             	sub    $0x4,%esp
  8011b5:	51                   	push   %ecx
  8011b6:	50                   	push   %eax
  8011b7:	68 48 26 80 00       	push   $0x802648
  8011bc:	e8 73 f0 ff ff       	call   800234 <cprintf>
	*dev = 0;
  8011c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 10             	sub    $0x10,%esp
  8011dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8011df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ec:	c1 e8 0c             	shr    $0xc,%eax
  8011ef:	50                   	push   %eax
  8011f0:	e8 36 ff ff ff       	call   80112b <fd_lookup>
  8011f5:	83 c4 08             	add    $0x8,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 05                	js     801201 <fd_close+0x2d>
	    || fd != fd2)
  8011fc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ff:	74 0c                	je     80120d <fd_close+0x39>
		return (must_exist ? r : 0);
  801201:	84 db                	test   %bl,%bl
  801203:	ba 00 00 00 00       	mov    $0x0,%edx
  801208:	0f 44 c2             	cmove  %edx,%eax
  80120b:	eb 41                	jmp    80124e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	ff 36                	pushl  (%esi)
  801216:	e8 66 ff ff ff       	call   801181 <dev_lookup>
  80121b:	89 c3                	mov    %eax,%ebx
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 1a                	js     80123e <fd_close+0x6a>
		if (dev->dev_close)
  801224:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801227:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80122a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80122f:	85 c0                	test   %eax,%eax
  801231:	74 0b                	je     80123e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	56                   	push   %esi
  801237:	ff d0                	call   *%eax
  801239:	89 c3                	mov    %eax,%ebx
  80123b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80123e:	83 ec 08             	sub    $0x8,%esp
  801241:	56                   	push   %esi
  801242:	6a 00                	push   $0x0
  801244:	e8 f8 f9 ff ff       	call   800c41 <sys_page_unmap>
	return r;
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	89 d8                	mov    %ebx,%eax
}
  80124e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	ff 75 08             	pushl  0x8(%ebp)
  801262:	e8 c4 fe ff ff       	call   80112b <fd_lookup>
  801267:	83 c4 08             	add    $0x8,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 10                	js     80127e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	6a 01                	push   $0x1
  801273:	ff 75 f4             	pushl  -0xc(%ebp)
  801276:	e8 59 ff ff ff       	call   8011d4 <fd_close>
  80127b:	83 c4 10             	add    $0x10,%esp
}
  80127e:	c9                   	leave  
  80127f:	c3                   	ret    

00801280 <close_all>:

void
close_all(void)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	53                   	push   %ebx
  801284:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801287:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80128c:	83 ec 0c             	sub    $0xc,%esp
  80128f:	53                   	push   %ebx
  801290:	e8 c0 ff ff ff       	call   801255 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801295:	83 c3 01             	add    $0x1,%ebx
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	83 fb 20             	cmp    $0x20,%ebx
  80129e:	75 ec                	jne    80128c <close_all+0xc>
		close(i);
}
  8012a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a3:	c9                   	leave  
  8012a4:	c3                   	ret    

008012a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	57                   	push   %edi
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 2c             	sub    $0x2c,%esp
  8012ae:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b4:	50                   	push   %eax
  8012b5:	ff 75 08             	pushl  0x8(%ebp)
  8012b8:	e8 6e fe ff ff       	call   80112b <fd_lookup>
  8012bd:	83 c4 08             	add    $0x8,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	0f 88 c1 00 00 00    	js     801389 <dup+0xe4>
		return r;
	close(newfdnum);
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	56                   	push   %esi
  8012cc:	e8 84 ff ff ff       	call   801255 <close>

	newfd = INDEX2FD(newfdnum);
  8012d1:	89 f3                	mov    %esi,%ebx
  8012d3:	c1 e3 0c             	shl    $0xc,%ebx
  8012d6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012dc:	83 c4 04             	add    $0x4,%esp
  8012df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012e2:	e8 de fd ff ff       	call   8010c5 <fd2data>
  8012e7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012e9:	89 1c 24             	mov    %ebx,(%esp)
  8012ec:	e8 d4 fd ff ff       	call   8010c5 <fd2data>
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012f7:	89 f8                	mov    %edi,%eax
  8012f9:	c1 e8 16             	shr    $0x16,%eax
  8012fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801303:	a8 01                	test   $0x1,%al
  801305:	74 37                	je     80133e <dup+0x99>
  801307:	89 f8                	mov    %edi,%eax
  801309:	c1 e8 0c             	shr    $0xc,%eax
  80130c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801313:	f6 c2 01             	test   $0x1,%dl
  801316:	74 26                	je     80133e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801318:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	25 07 0e 00 00       	and    $0xe07,%eax
  801327:	50                   	push   %eax
  801328:	ff 75 d4             	pushl  -0x2c(%ebp)
  80132b:	6a 00                	push   $0x0
  80132d:	57                   	push   %edi
  80132e:	6a 00                	push   $0x0
  801330:	e8 ca f8 ff ff       	call   800bff <sys_page_map>
  801335:	89 c7                	mov    %eax,%edi
  801337:	83 c4 20             	add    $0x20,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 2e                	js     80136c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801341:	89 d0                	mov    %edx,%eax
  801343:	c1 e8 0c             	shr    $0xc,%eax
  801346:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80134d:	83 ec 0c             	sub    $0xc,%esp
  801350:	25 07 0e 00 00       	and    $0xe07,%eax
  801355:	50                   	push   %eax
  801356:	53                   	push   %ebx
  801357:	6a 00                	push   $0x0
  801359:	52                   	push   %edx
  80135a:	6a 00                	push   $0x0
  80135c:	e8 9e f8 ff ff       	call   800bff <sys_page_map>
  801361:	89 c7                	mov    %eax,%edi
  801363:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801366:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801368:	85 ff                	test   %edi,%edi
  80136a:	79 1d                	jns    801389 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80136c:	83 ec 08             	sub    $0x8,%esp
  80136f:	53                   	push   %ebx
  801370:	6a 00                	push   $0x0
  801372:	e8 ca f8 ff ff       	call   800c41 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801377:	83 c4 08             	add    $0x8,%esp
  80137a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80137d:	6a 00                	push   $0x0
  80137f:	e8 bd f8 ff ff       	call   800c41 <sys_page_unmap>
	return r;
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	89 f8                	mov    %edi,%eax
}
  801389:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138c:	5b                   	pop    %ebx
  80138d:	5e                   	pop    %esi
  80138e:	5f                   	pop    %edi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	53                   	push   %ebx
  801395:	83 ec 14             	sub    $0x14,%esp
  801398:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139e:	50                   	push   %eax
  80139f:	53                   	push   %ebx
  8013a0:	e8 86 fd ff ff       	call   80112b <fd_lookup>
  8013a5:	83 c4 08             	add    $0x8,%esp
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 6d                	js     80141b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ae:	83 ec 08             	sub    $0x8,%esp
  8013b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b8:	ff 30                	pushl  (%eax)
  8013ba:	e8 c2 fd ff ff       	call   801181 <dev_lookup>
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 4c                	js     801412 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c9:	8b 42 08             	mov    0x8(%edx),%eax
  8013cc:	83 e0 03             	and    $0x3,%eax
  8013cf:	83 f8 01             	cmp    $0x1,%eax
  8013d2:	75 21                	jne    8013f5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d9:	8b 40 50             	mov    0x50(%eax),%eax
  8013dc:	83 ec 04             	sub    $0x4,%esp
  8013df:	53                   	push   %ebx
  8013e0:	50                   	push   %eax
  8013e1:	68 89 26 80 00       	push   $0x802689
  8013e6:	e8 49 ee ff ff       	call   800234 <cprintf>
		return -E_INVAL;
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f3:	eb 26                	jmp    80141b <read+0x8a>
	}
	if (!dev->dev_read)
  8013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f8:	8b 40 08             	mov    0x8(%eax),%eax
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	74 17                	je     801416 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013ff:	83 ec 04             	sub    $0x4,%esp
  801402:	ff 75 10             	pushl  0x10(%ebp)
  801405:	ff 75 0c             	pushl  0xc(%ebp)
  801408:	52                   	push   %edx
  801409:	ff d0                	call   *%eax
  80140b:	89 c2                	mov    %eax,%edx
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	eb 09                	jmp    80141b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801412:	89 c2                	mov    %eax,%edx
  801414:	eb 05                	jmp    80141b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801416:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80141b:	89 d0                	mov    %edx,%eax
  80141d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	57                   	push   %edi
  801426:	56                   	push   %esi
  801427:	53                   	push   %ebx
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80142e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801431:	bb 00 00 00 00       	mov    $0x0,%ebx
  801436:	eb 21                	jmp    801459 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801438:	83 ec 04             	sub    $0x4,%esp
  80143b:	89 f0                	mov    %esi,%eax
  80143d:	29 d8                	sub    %ebx,%eax
  80143f:	50                   	push   %eax
  801440:	89 d8                	mov    %ebx,%eax
  801442:	03 45 0c             	add    0xc(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	57                   	push   %edi
  801447:	e8 45 ff ff ff       	call   801391 <read>
		if (m < 0)
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 10                	js     801463 <readn+0x41>
			return m;
		if (m == 0)
  801453:	85 c0                	test   %eax,%eax
  801455:	74 0a                	je     801461 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801457:	01 c3                	add    %eax,%ebx
  801459:	39 f3                	cmp    %esi,%ebx
  80145b:	72 db                	jb     801438 <readn+0x16>
  80145d:	89 d8                	mov    %ebx,%eax
  80145f:	eb 02                	jmp    801463 <readn+0x41>
  801461:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801463:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801466:	5b                   	pop    %ebx
  801467:	5e                   	pop    %esi
  801468:	5f                   	pop    %edi
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    

0080146b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	53                   	push   %ebx
  80146f:	83 ec 14             	sub    $0x14,%esp
  801472:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801475:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801478:	50                   	push   %eax
  801479:	53                   	push   %ebx
  80147a:	e8 ac fc ff ff       	call   80112b <fd_lookup>
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	89 c2                	mov    %eax,%edx
  801484:	85 c0                	test   %eax,%eax
  801486:	78 68                	js     8014f0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	ff 30                	pushl  (%eax)
  801494:	e8 e8 fc ff ff       	call   801181 <dev_lookup>
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 47                	js     8014e7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a7:	75 21                	jne    8014ca <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ae:	8b 40 50             	mov    0x50(%eax),%eax
  8014b1:	83 ec 04             	sub    $0x4,%esp
  8014b4:	53                   	push   %ebx
  8014b5:	50                   	push   %eax
  8014b6:	68 a5 26 80 00       	push   $0x8026a5
  8014bb:	e8 74 ed ff ff       	call   800234 <cprintf>
		return -E_INVAL;
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c8:	eb 26                	jmp    8014f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d0:	85 d2                	test   %edx,%edx
  8014d2:	74 17                	je     8014eb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d4:	83 ec 04             	sub    $0x4,%esp
  8014d7:	ff 75 10             	pushl  0x10(%ebp)
  8014da:	ff 75 0c             	pushl  0xc(%ebp)
  8014dd:	50                   	push   %eax
  8014de:	ff d2                	call   *%edx
  8014e0:	89 c2                	mov    %eax,%edx
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	eb 09                	jmp    8014f0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e7:	89 c2                	mov    %eax,%edx
  8014e9:	eb 05                	jmp    8014f0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014f0:	89 d0                	mov    %edx,%eax
  8014f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f5:	c9                   	leave  
  8014f6:	c3                   	ret    

008014f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801500:	50                   	push   %eax
  801501:	ff 75 08             	pushl  0x8(%ebp)
  801504:	e8 22 fc ff ff       	call   80112b <fd_lookup>
  801509:	83 c4 08             	add    $0x8,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 0e                	js     80151e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801510:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801513:	8b 55 0c             	mov    0xc(%ebp),%edx
  801516:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801519:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	53                   	push   %ebx
  801524:	83 ec 14             	sub    $0x14,%esp
  801527:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152d:	50                   	push   %eax
  80152e:	53                   	push   %ebx
  80152f:	e8 f7 fb ff ff       	call   80112b <fd_lookup>
  801534:	83 c4 08             	add    $0x8,%esp
  801537:	89 c2                	mov    %eax,%edx
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 65                	js     8015a2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153d:	83 ec 08             	sub    $0x8,%esp
  801540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801547:	ff 30                	pushl  (%eax)
  801549:	e8 33 fc ff ff       	call   801181 <dev_lookup>
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	85 c0                	test   %eax,%eax
  801553:	78 44                	js     801599 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801558:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155c:	75 21                	jne    80157f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80155e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801563:	8b 40 50             	mov    0x50(%eax),%eax
  801566:	83 ec 04             	sub    $0x4,%esp
  801569:	53                   	push   %ebx
  80156a:	50                   	push   %eax
  80156b:	68 68 26 80 00       	push   $0x802668
  801570:	e8 bf ec ff ff       	call   800234 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157d:	eb 23                	jmp    8015a2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80157f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801582:	8b 52 18             	mov    0x18(%edx),%edx
  801585:	85 d2                	test   %edx,%edx
  801587:	74 14                	je     80159d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	ff 75 0c             	pushl  0xc(%ebp)
  80158f:	50                   	push   %eax
  801590:	ff d2                	call   *%edx
  801592:	89 c2                	mov    %eax,%edx
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	eb 09                	jmp    8015a2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801599:	89 c2                	mov    %eax,%edx
  80159b:	eb 05                	jmp    8015a2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80159d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015a2:	89 d0                	mov    %edx,%eax
  8015a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 14             	sub    $0x14,%esp
  8015b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	ff 75 08             	pushl  0x8(%ebp)
  8015ba:	e8 6c fb ff ff       	call   80112b <fd_lookup>
  8015bf:	83 c4 08             	add    $0x8,%esp
  8015c2:	89 c2                	mov    %eax,%edx
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 58                	js     801620 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ce:	50                   	push   %eax
  8015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d2:	ff 30                	pushl  (%eax)
  8015d4:	e8 a8 fb ff ff       	call   801181 <dev_lookup>
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 37                	js     801617 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015e7:	74 32                	je     80161b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f3:	00 00 00 
	stat->st_isdir = 0;
  8015f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015fd:	00 00 00 
	stat->st_dev = dev;
  801600:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	53                   	push   %ebx
  80160a:	ff 75 f0             	pushl  -0x10(%ebp)
  80160d:	ff 50 14             	call   *0x14(%eax)
  801610:	89 c2                	mov    %eax,%edx
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	eb 09                	jmp    801620 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	89 c2                	mov    %eax,%edx
  801619:	eb 05                	jmp    801620 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80161b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801620:	89 d0                	mov    %edx,%eax
  801622:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	56                   	push   %esi
  80162b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	6a 00                	push   $0x0
  801631:	ff 75 08             	pushl  0x8(%ebp)
  801634:	e8 e3 01 00 00       	call   80181c <open>
  801639:	89 c3                	mov    %eax,%ebx
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 1b                	js     80165d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	ff 75 0c             	pushl  0xc(%ebp)
  801648:	50                   	push   %eax
  801649:	e8 5b ff ff ff       	call   8015a9 <fstat>
  80164e:	89 c6                	mov    %eax,%esi
	close(fd);
  801650:	89 1c 24             	mov    %ebx,(%esp)
  801653:	e8 fd fb ff ff       	call   801255 <close>
	return r;
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	89 f0                	mov    %esi,%eax
}
  80165d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801660:	5b                   	pop    %ebx
  801661:	5e                   	pop    %esi
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    

00801664 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	56                   	push   %esi
  801668:	53                   	push   %ebx
  801669:	89 c6                	mov    %eax,%esi
  80166b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80166d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801674:	75 12                	jne    801688 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801676:	83 ec 0c             	sub    $0xc,%esp
  801679:	6a 01                	push   $0x1
  80167b:	e8 cb 08 00 00       	call   801f4b <ipc_find_env>
  801680:	a3 00 40 80 00       	mov    %eax,0x804000
  801685:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801688:	6a 07                	push   $0x7
  80168a:	68 00 50 80 00       	push   $0x805000
  80168f:	56                   	push   %esi
  801690:	ff 35 00 40 80 00    	pushl  0x804000
  801696:	e8 4e 08 00 00       	call   801ee9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169b:	83 c4 0c             	add    $0xc,%esp
  80169e:	6a 00                	push   $0x0
  8016a0:	53                   	push   %ebx
  8016a1:	6a 00                	push   $0x0
  8016a3:	e8 cc 07 00 00       	call   801e74 <ipc_recv>
}
  8016a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cd:	b8 02 00 00 00       	mov    $0x2,%eax
  8016d2:	e8 8d ff ff ff       	call   801664 <fsipc>
}
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f4:	e8 6b ff ff ff       	call   801664 <fsipc>
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	53                   	push   %ebx
  8016ff:	83 ec 04             	sub    $0x4,%esp
  801702:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801705:	8b 45 08             	mov    0x8(%ebp),%eax
  801708:	8b 40 0c             	mov    0xc(%eax),%eax
  80170b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801710:	ba 00 00 00 00       	mov    $0x0,%edx
  801715:	b8 05 00 00 00       	mov    $0x5,%eax
  80171a:	e8 45 ff ff ff       	call   801664 <fsipc>
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 2c                	js     80174f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	68 00 50 80 00       	push   $0x805000
  80172b:	53                   	push   %ebx
  80172c:	e8 88 f0 ff ff       	call   8007b9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801731:	a1 80 50 80 00       	mov    0x805080,%eax
  801736:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173c:	a1 84 50 80 00       	mov    0x805084,%eax
  801741:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80174f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80175d:	8b 55 08             	mov    0x8(%ebp),%edx
  801760:	8b 52 0c             	mov    0xc(%edx),%edx
  801763:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801769:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80176e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801773:	0f 47 c2             	cmova  %edx,%eax
  801776:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80177b:	50                   	push   %eax
  80177c:	ff 75 0c             	pushl  0xc(%ebp)
  80177f:	68 08 50 80 00       	push   $0x805008
  801784:	e8 c2 f1 ff ff       	call   80094b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 04 00 00 00       	mov    $0x4,%eax
  801793:	e8 cc fe ff ff       	call   801664 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	56                   	push   %esi
  80179e:	53                   	push   %ebx
  80179f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ad:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b8:	b8 03 00 00 00       	mov    $0x3,%eax
  8017bd:	e8 a2 fe ff ff       	call   801664 <fsipc>
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 4b                	js     801813 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017c8:	39 c6                	cmp    %eax,%esi
  8017ca:	73 16                	jae    8017e2 <devfile_read+0x48>
  8017cc:	68 d4 26 80 00       	push   $0x8026d4
  8017d1:	68 db 26 80 00       	push   $0x8026db
  8017d6:	6a 7c                	push   $0x7c
  8017d8:	68 f0 26 80 00       	push   $0x8026f0
  8017dd:	e8 bd 05 00 00       	call   801d9f <_panic>
	assert(r <= PGSIZE);
  8017e2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e7:	7e 16                	jle    8017ff <devfile_read+0x65>
  8017e9:	68 fb 26 80 00       	push   $0x8026fb
  8017ee:	68 db 26 80 00       	push   $0x8026db
  8017f3:	6a 7d                	push   $0x7d
  8017f5:	68 f0 26 80 00       	push   $0x8026f0
  8017fa:	e8 a0 05 00 00       	call   801d9f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ff:	83 ec 04             	sub    $0x4,%esp
  801802:	50                   	push   %eax
  801803:	68 00 50 80 00       	push   $0x805000
  801808:	ff 75 0c             	pushl  0xc(%ebp)
  80180b:	e8 3b f1 ff ff       	call   80094b <memmove>
	return r;
  801810:	83 c4 10             	add    $0x10,%esp
}
  801813:	89 d8                	mov    %ebx,%eax
  801815:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	53                   	push   %ebx
  801820:	83 ec 20             	sub    $0x20,%esp
  801823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801826:	53                   	push   %ebx
  801827:	e8 54 ef ff ff       	call   800780 <strlen>
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801834:	7f 67                	jg     80189d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183c:	50                   	push   %eax
  80183d:	e8 9a f8 ff ff       	call   8010dc <fd_alloc>
  801842:	83 c4 10             	add    $0x10,%esp
		return r;
  801845:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801847:	85 c0                	test   %eax,%eax
  801849:	78 57                	js     8018a2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80184b:	83 ec 08             	sub    $0x8,%esp
  80184e:	53                   	push   %ebx
  80184f:	68 00 50 80 00       	push   $0x805000
  801854:	e8 60 ef ff ff       	call   8007b9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801861:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801864:	b8 01 00 00 00       	mov    $0x1,%eax
  801869:	e8 f6 fd ff ff       	call   801664 <fsipc>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	85 c0                	test   %eax,%eax
  801875:	79 14                	jns    80188b <open+0x6f>
		fd_close(fd, 0);
  801877:	83 ec 08             	sub    $0x8,%esp
  80187a:	6a 00                	push   $0x0
  80187c:	ff 75 f4             	pushl  -0xc(%ebp)
  80187f:	e8 50 f9 ff ff       	call   8011d4 <fd_close>
		return r;
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	89 da                	mov    %ebx,%edx
  801889:	eb 17                	jmp    8018a2 <open+0x86>
	}

	return fd2num(fd);
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	ff 75 f4             	pushl  -0xc(%ebp)
  801891:	e8 1f f8 ff ff       	call   8010b5 <fd2num>
  801896:	89 c2                	mov    %eax,%edx
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	eb 05                	jmp    8018a2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80189d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018a2:	89 d0                	mov    %edx,%eax
  8018a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018af:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b4:	b8 08 00 00 00       	mov    $0x8,%eax
  8018b9:	e8 a6 fd ff ff       	call   801664 <fsipc>
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	56                   	push   %esi
  8018c4:	53                   	push   %ebx
  8018c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	ff 75 08             	pushl  0x8(%ebp)
  8018ce:	e8 f2 f7 ff ff       	call   8010c5 <fd2data>
  8018d3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018d5:	83 c4 08             	add    $0x8,%esp
  8018d8:	68 07 27 80 00       	push   $0x802707
  8018dd:	53                   	push   %ebx
  8018de:	e8 d6 ee ff ff       	call   8007b9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018e3:	8b 46 04             	mov    0x4(%esi),%eax
  8018e6:	2b 06                	sub    (%esi),%eax
  8018e8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f5:	00 00 00 
	stat->st_dev = &devpipe;
  8018f8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018ff:	30 80 00 
	return 0;
}
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
  801907:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801918:	53                   	push   %ebx
  801919:	6a 00                	push   $0x0
  80191b:	e8 21 f3 ff ff       	call   800c41 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801920:	89 1c 24             	mov    %ebx,(%esp)
  801923:	e8 9d f7 ff ff       	call   8010c5 <fd2data>
  801928:	83 c4 08             	add    $0x8,%esp
  80192b:	50                   	push   %eax
  80192c:	6a 00                	push   $0x0
  80192e:	e8 0e f3 ff ff       	call   800c41 <sys_page_unmap>
}
  801933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	57                   	push   %edi
  80193c:	56                   	push   %esi
  80193d:	53                   	push   %ebx
  80193e:	83 ec 1c             	sub    $0x1c,%esp
  801941:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801944:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801946:	a1 04 40 80 00       	mov    0x804004,%eax
  80194b:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80194e:	83 ec 0c             	sub    $0xc,%esp
  801951:	ff 75 e0             	pushl  -0x20(%ebp)
  801954:	e8 32 06 00 00       	call   801f8b <pageref>
  801959:	89 c3                	mov    %eax,%ebx
  80195b:	89 3c 24             	mov    %edi,(%esp)
  80195e:	e8 28 06 00 00       	call   801f8b <pageref>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	39 c3                	cmp    %eax,%ebx
  801968:	0f 94 c1             	sete   %cl
  80196b:	0f b6 c9             	movzbl %cl,%ecx
  80196e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801971:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801977:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  80197a:	39 ce                	cmp    %ecx,%esi
  80197c:	74 1b                	je     801999 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80197e:	39 c3                	cmp    %eax,%ebx
  801980:	75 c4                	jne    801946 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801982:	8b 42 60             	mov    0x60(%edx),%eax
  801985:	ff 75 e4             	pushl  -0x1c(%ebp)
  801988:	50                   	push   %eax
  801989:	56                   	push   %esi
  80198a:	68 0e 27 80 00       	push   $0x80270e
  80198f:	e8 a0 e8 ff ff       	call   800234 <cprintf>
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	eb ad                	jmp    801946 <_pipeisclosed+0xe>
	}
}
  801999:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80199c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5f                   	pop    %edi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	57                   	push   %edi
  8019a8:	56                   	push   %esi
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 28             	sub    $0x28,%esp
  8019ad:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019b0:	56                   	push   %esi
  8019b1:	e8 0f f7 ff ff       	call   8010c5 <fd2data>
  8019b6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8019c0:	eb 4b                	jmp    801a0d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019c2:	89 da                	mov    %ebx,%edx
  8019c4:	89 f0                	mov    %esi,%eax
  8019c6:	e8 6d ff ff ff       	call   801938 <_pipeisclosed>
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	75 48                	jne    801a17 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019cf:	e8 c9 f1 ff ff       	call   800b9d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019d4:	8b 43 04             	mov    0x4(%ebx),%eax
  8019d7:	8b 0b                	mov    (%ebx),%ecx
  8019d9:	8d 51 20             	lea    0x20(%ecx),%edx
  8019dc:	39 d0                	cmp    %edx,%eax
  8019de:	73 e2                	jae    8019c2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019e7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019ea:	89 c2                	mov    %eax,%edx
  8019ec:	c1 fa 1f             	sar    $0x1f,%edx
  8019ef:	89 d1                	mov    %edx,%ecx
  8019f1:	c1 e9 1b             	shr    $0x1b,%ecx
  8019f4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019f7:	83 e2 1f             	and    $0x1f,%edx
  8019fa:	29 ca                	sub    %ecx,%edx
  8019fc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a00:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a04:	83 c0 01             	add    $0x1,%eax
  801a07:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0a:	83 c7 01             	add    $0x1,%edi
  801a0d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a10:	75 c2                	jne    8019d4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a12:	8b 45 10             	mov    0x10(%ebp),%eax
  801a15:	eb 05                	jmp    801a1c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a17:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1f:	5b                   	pop    %ebx
  801a20:	5e                   	pop    %esi
  801a21:	5f                   	pop    %edi
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	57                   	push   %edi
  801a28:	56                   	push   %esi
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 18             	sub    $0x18,%esp
  801a2d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a30:	57                   	push   %edi
  801a31:	e8 8f f6 ff ff       	call   8010c5 <fd2data>
  801a36:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a40:	eb 3d                	jmp    801a7f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a42:	85 db                	test   %ebx,%ebx
  801a44:	74 04                	je     801a4a <devpipe_read+0x26>
				return i;
  801a46:	89 d8                	mov    %ebx,%eax
  801a48:	eb 44                	jmp    801a8e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a4a:	89 f2                	mov    %esi,%edx
  801a4c:	89 f8                	mov    %edi,%eax
  801a4e:	e8 e5 fe ff ff       	call   801938 <_pipeisclosed>
  801a53:	85 c0                	test   %eax,%eax
  801a55:	75 32                	jne    801a89 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a57:	e8 41 f1 ff ff       	call   800b9d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a5c:	8b 06                	mov    (%esi),%eax
  801a5e:	3b 46 04             	cmp    0x4(%esi),%eax
  801a61:	74 df                	je     801a42 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a63:	99                   	cltd   
  801a64:	c1 ea 1b             	shr    $0x1b,%edx
  801a67:	01 d0                	add    %edx,%eax
  801a69:	83 e0 1f             	and    $0x1f,%eax
  801a6c:	29 d0                	sub    %edx,%eax
  801a6e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a76:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a79:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7c:	83 c3 01             	add    $0x1,%ebx
  801a7f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a82:	75 d8                	jne    801a5c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a84:	8b 45 10             	mov    0x10(%ebp),%eax
  801a87:	eb 05                	jmp    801a8e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a89:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5f                   	pop    %edi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    

00801a96 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa1:	50                   	push   %eax
  801aa2:	e8 35 f6 ff ff       	call   8010dc <fd_alloc>
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	89 c2                	mov    %eax,%edx
  801aac:	85 c0                	test   %eax,%eax
  801aae:	0f 88 2c 01 00 00    	js     801be0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab4:	83 ec 04             	sub    $0x4,%esp
  801ab7:	68 07 04 00 00       	push   $0x407
  801abc:	ff 75 f4             	pushl  -0xc(%ebp)
  801abf:	6a 00                	push   $0x0
  801ac1:	e8 f6 f0 ff ff       	call   800bbc <sys_page_alloc>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	89 c2                	mov    %eax,%edx
  801acb:	85 c0                	test   %eax,%eax
  801acd:	0f 88 0d 01 00 00    	js     801be0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ad9:	50                   	push   %eax
  801ada:	e8 fd f5 ff ff       	call   8010dc <fd_alloc>
  801adf:	89 c3                	mov    %eax,%ebx
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	0f 88 e2 00 00 00    	js     801bce <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aec:	83 ec 04             	sub    $0x4,%esp
  801aef:	68 07 04 00 00       	push   $0x407
  801af4:	ff 75 f0             	pushl  -0x10(%ebp)
  801af7:	6a 00                	push   $0x0
  801af9:	e8 be f0 ff ff       	call   800bbc <sys_page_alloc>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	85 c0                	test   %eax,%eax
  801b05:	0f 88 c3 00 00 00    	js     801bce <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b11:	e8 af f5 ff ff       	call   8010c5 <fd2data>
  801b16:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	83 c4 0c             	add    $0xc,%esp
  801b1b:	68 07 04 00 00       	push   $0x407
  801b20:	50                   	push   %eax
  801b21:	6a 00                	push   $0x0
  801b23:	e8 94 f0 ff ff       	call   800bbc <sys_page_alloc>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	0f 88 89 00 00 00    	js     801bbe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	ff 75 f0             	pushl  -0x10(%ebp)
  801b3b:	e8 85 f5 ff ff       	call   8010c5 <fd2data>
  801b40:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b47:	50                   	push   %eax
  801b48:	6a 00                	push   $0x0
  801b4a:	56                   	push   %esi
  801b4b:	6a 00                	push   $0x0
  801b4d:	e8 ad f0 ff ff       	call   800bff <sys_page_map>
  801b52:	89 c3                	mov    %eax,%ebx
  801b54:	83 c4 20             	add    $0x20,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 55                	js     801bb0 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b5b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b64:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b69:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b70:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b79:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b85:	83 ec 0c             	sub    $0xc,%esp
  801b88:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8b:	e8 25 f5 ff ff       	call   8010b5 <fd2num>
  801b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b93:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b95:	83 c4 04             	add    $0x4,%esp
  801b98:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9b:	e8 15 f5 ff ff       	call   8010b5 <fd2num>
  801ba0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba3:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bae:	eb 30                	jmp    801be0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bb0:	83 ec 08             	sub    $0x8,%esp
  801bb3:	56                   	push   %esi
  801bb4:	6a 00                	push   $0x0
  801bb6:	e8 86 f0 ff ff       	call   800c41 <sys_page_unmap>
  801bbb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bbe:	83 ec 08             	sub    $0x8,%esp
  801bc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 76 f0 ff ff       	call   800c41 <sys_page_unmap>
  801bcb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bce:	83 ec 08             	sub    $0x8,%esp
  801bd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd4:	6a 00                	push   $0x0
  801bd6:	e8 66 f0 ff ff       	call   800c41 <sys_page_unmap>
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801be0:	89 d0                	mov    %edx,%eax
  801be2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf2:	50                   	push   %eax
  801bf3:	ff 75 08             	pushl  0x8(%ebp)
  801bf6:	e8 30 f5 ff ff       	call   80112b <fd_lookup>
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	78 18                	js     801c1a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	ff 75 f4             	pushl  -0xc(%ebp)
  801c08:	e8 b8 f4 ff ff       	call   8010c5 <fd2data>
	return _pipeisclosed(fd, p);
  801c0d:	89 c2                	mov    %eax,%edx
  801c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c12:	e8 21 fd ff ff       	call   801938 <_pipeisclosed>
  801c17:	83 c4 10             	add    $0x10,%esp
}
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    

00801c1c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    

00801c26 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c2c:	68 26 27 80 00       	push   $0x802726
  801c31:	ff 75 0c             	pushl  0xc(%ebp)
  801c34:	e8 80 eb ff ff       	call   8007b9 <strcpy>
	return 0;
}
  801c39:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	57                   	push   %edi
  801c44:	56                   	push   %esi
  801c45:	53                   	push   %ebx
  801c46:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c4c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c51:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c57:	eb 2d                	jmp    801c86 <devcons_write+0x46>
		m = n - tot;
  801c59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c5c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c5e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c61:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c66:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c69:	83 ec 04             	sub    $0x4,%esp
  801c6c:	53                   	push   %ebx
  801c6d:	03 45 0c             	add    0xc(%ebp),%eax
  801c70:	50                   	push   %eax
  801c71:	57                   	push   %edi
  801c72:	e8 d4 ec ff ff       	call   80094b <memmove>
		sys_cputs(buf, m);
  801c77:	83 c4 08             	add    $0x8,%esp
  801c7a:	53                   	push   %ebx
  801c7b:	57                   	push   %edi
  801c7c:	e8 7f ee ff ff       	call   800b00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c81:	01 de                	add    %ebx,%esi
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	89 f0                	mov    %esi,%eax
  801c88:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c8b:	72 cc                	jb     801c59 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5f                   	pop    %edi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ca0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ca4:	74 2a                	je     801cd0 <devcons_read+0x3b>
  801ca6:	eb 05                	jmp    801cad <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ca8:	e8 f0 ee ff ff       	call   800b9d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cad:	e8 6c ee ff ff       	call   800b1e <sys_cgetc>
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	74 f2                	je     801ca8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	78 16                	js     801cd0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cba:	83 f8 04             	cmp    $0x4,%eax
  801cbd:	74 0c                	je     801ccb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc2:	88 02                	mov    %al,(%edx)
	return 1;
  801cc4:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc9:	eb 05                	jmp    801cd0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    

00801cd2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cde:	6a 01                	push   $0x1
  801ce0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce3:	50                   	push   %eax
  801ce4:	e8 17 ee ff ff       	call   800b00 <sys_cputs>
}
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    

00801cee <getchar>:

int
getchar(void)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cf4:	6a 01                	push   $0x1
  801cf6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cf9:	50                   	push   %eax
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 90 f6 ff ff       	call   801391 <read>
	if (r < 0)
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	78 0f                	js     801d17 <getchar+0x29>
		return r;
	if (r < 1)
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	7e 06                	jle    801d12 <getchar+0x24>
		return -E_EOF;
	return c;
  801d0c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d10:	eb 05                	jmp    801d17 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d12:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d22:	50                   	push   %eax
  801d23:	ff 75 08             	pushl  0x8(%ebp)
  801d26:	e8 00 f4 ff ff       	call   80112b <fd_lookup>
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 11                	js     801d43 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d3b:	39 10                	cmp    %edx,(%eax)
  801d3d:	0f 94 c0             	sete   %al
  801d40:	0f b6 c0             	movzbl %al,%eax
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <opencons>:

int
opencons(void)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4e:	50                   	push   %eax
  801d4f:	e8 88 f3 ff ff       	call   8010dc <fd_alloc>
  801d54:	83 c4 10             	add    $0x10,%esp
		return r;
  801d57:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	78 3e                	js     801d9b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d5d:	83 ec 04             	sub    $0x4,%esp
  801d60:	68 07 04 00 00       	push   $0x407
  801d65:	ff 75 f4             	pushl  -0xc(%ebp)
  801d68:	6a 00                	push   $0x0
  801d6a:	e8 4d ee ff ff       	call   800bbc <sys_page_alloc>
  801d6f:	83 c4 10             	add    $0x10,%esp
		return r;
  801d72:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d74:	85 c0                	test   %eax,%eax
  801d76:	78 23                	js     801d9b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d78:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d81:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d86:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d8d:	83 ec 0c             	sub    $0xc,%esp
  801d90:	50                   	push   %eax
  801d91:	e8 1f f3 ff ff       	call   8010b5 <fd2num>
  801d96:	89 c2                	mov    %eax,%edx
  801d98:	83 c4 10             	add    $0x10,%esp
}
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801da4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801da7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dad:	e8 cc ed ff ff       	call   800b7e <sys_getenvid>
  801db2:	83 ec 0c             	sub    $0xc,%esp
  801db5:	ff 75 0c             	pushl  0xc(%ebp)
  801db8:	ff 75 08             	pushl  0x8(%ebp)
  801dbb:	56                   	push   %esi
  801dbc:	50                   	push   %eax
  801dbd:	68 34 27 80 00       	push   $0x802734
  801dc2:	e8 6d e4 ff ff       	call   800234 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dc7:	83 c4 18             	add    $0x18,%esp
  801dca:	53                   	push   %ebx
  801dcb:	ff 75 10             	pushl  0x10(%ebp)
  801dce:	e8 10 e4 ff ff       	call   8001e3 <vcprintf>
	cprintf("\n");
  801dd3:	c7 04 24 6f 22 80 00 	movl   $0x80226f,(%esp)
  801dda:	e8 55 e4 ff ff       	call   800234 <cprintf>
  801ddf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801de2:	cc                   	int3   
  801de3:	eb fd                	jmp    801de2 <_panic+0x43>

00801de5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801deb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801df2:	75 2a                	jne    801e1e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801df4:	83 ec 04             	sub    $0x4,%esp
  801df7:	6a 07                	push   $0x7
  801df9:	68 00 f0 bf ee       	push   $0xeebff000
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 b7 ed ff ff       	call   800bbc <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	79 12                	jns    801e1e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e0c:	50                   	push   %eax
  801e0d:	68 58 27 80 00       	push   $0x802758
  801e12:	6a 23                	push   $0x23
  801e14:	68 5c 27 80 00       	push   $0x80275c
  801e19:	e8 81 ff ff ff       	call   801d9f <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e21:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e26:	83 ec 08             	sub    $0x8,%esp
  801e29:	68 50 1e 80 00       	push   $0x801e50
  801e2e:	6a 00                	push   $0x0
  801e30:	e8 d2 ee ff ff       	call   800d07 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	79 12                	jns    801e4e <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e3c:	50                   	push   %eax
  801e3d:	68 58 27 80 00       	push   $0x802758
  801e42:	6a 2c                	push   $0x2c
  801e44:	68 5c 27 80 00       	push   $0x80275c
  801e49:	e8 51 ff ff ff       	call   801d9f <_panic>
	}
}
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e50:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e51:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e56:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e58:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e5b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e5f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e64:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e68:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e6a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e6d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e6e:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e71:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e72:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e73:	c3                   	ret    

00801e74 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	8b 75 08             	mov    0x8(%ebp),%esi
  801e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e82:	85 c0                	test   %eax,%eax
  801e84:	75 12                	jne    801e98 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	68 00 00 c0 ee       	push   $0xeec00000
  801e8e:	e8 d9 ee ff ff       	call   800d6c <sys_ipc_recv>
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	eb 0c                	jmp    801ea4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e98:	83 ec 0c             	sub    $0xc,%esp
  801e9b:	50                   	push   %eax
  801e9c:	e8 cb ee ff ff       	call   800d6c <sys_ipc_recv>
  801ea1:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801ea4:	85 f6                	test   %esi,%esi
  801ea6:	0f 95 c1             	setne  %cl
  801ea9:	85 db                	test   %ebx,%ebx
  801eab:	0f 95 c2             	setne  %dl
  801eae:	84 d1                	test   %dl,%cl
  801eb0:	74 09                	je     801ebb <ipc_recv+0x47>
  801eb2:	89 c2                	mov    %eax,%edx
  801eb4:	c1 ea 1f             	shr    $0x1f,%edx
  801eb7:	84 d2                	test   %dl,%dl
  801eb9:	75 27                	jne    801ee2 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ebb:	85 f6                	test   %esi,%esi
  801ebd:	74 0a                	je     801ec9 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801ebf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec4:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ec7:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ec9:	85 db                	test   %ebx,%ebx
  801ecb:	74 0d                	je     801eda <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  801ecd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801ed8:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eda:	a1 04 40 80 00       	mov    0x804004,%eax
  801edf:	8b 40 78             	mov    0x78(%eax),%eax
}
  801ee2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	57                   	push   %edi
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	83 ec 0c             	sub    $0xc,%esp
  801ef2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f02:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f05:	ff 75 14             	pushl  0x14(%ebp)
  801f08:	53                   	push   %ebx
  801f09:	56                   	push   %esi
  801f0a:	57                   	push   %edi
  801f0b:	e8 39 ee ff ff       	call   800d49 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f10:	89 c2                	mov    %eax,%edx
  801f12:	c1 ea 1f             	shr    $0x1f,%edx
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	84 d2                	test   %dl,%dl
  801f1a:	74 17                	je     801f33 <ipc_send+0x4a>
  801f1c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1f:	74 12                	je     801f33 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f21:	50                   	push   %eax
  801f22:	68 6a 27 80 00       	push   $0x80276a
  801f27:	6a 47                	push   $0x47
  801f29:	68 78 27 80 00       	push   $0x802778
  801f2e:	e8 6c fe ff ff       	call   801d9f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f33:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f36:	75 07                	jne    801f3f <ipc_send+0x56>
			sys_yield();
  801f38:	e8 60 ec ff ff       	call   800b9d <sys_yield>
  801f3d:	eb c6                	jmp    801f05 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	75 c2                	jne    801f05 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5f                   	pop    %edi
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f51:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f56:	89 c2                	mov    %eax,%edx
  801f58:	c1 e2 07             	shl    $0x7,%edx
  801f5b:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801f62:	8b 52 58             	mov    0x58(%edx),%edx
  801f65:	39 ca                	cmp    %ecx,%edx
  801f67:	75 11                	jne    801f7a <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f69:	89 c2                	mov    %eax,%edx
  801f6b:	c1 e2 07             	shl    $0x7,%edx
  801f6e:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  801f75:	8b 40 50             	mov    0x50(%eax),%eax
  801f78:	eb 0f                	jmp    801f89 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7a:	83 c0 01             	add    $0x1,%eax
  801f7d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f82:	75 d2                	jne    801f56 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f91:	89 d0                	mov    %edx,%eax
  801f93:	c1 e8 16             	shr    $0x16,%eax
  801f96:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa2:	f6 c1 01             	test   $0x1,%cl
  801fa5:	74 1d                	je     801fc4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa7:	c1 ea 0c             	shr    $0xc,%edx
  801faa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb1:	f6 c2 01             	test   $0x1,%dl
  801fb4:	74 0e                	je     801fc4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb6:	c1 ea 0c             	shr    $0xc,%edx
  801fb9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc0:	ef 
  801fc1:	0f b7 c0             	movzwl %ax,%eax
}
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
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
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
