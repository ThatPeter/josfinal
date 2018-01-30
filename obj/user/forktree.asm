
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
  80003d:	e8 ff 0a 00 00       	call   800b41 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 a0 24 80 00       	push   $0x8024a0
  80004c:	e8 a6 01 00 00       	call   8001f7 <cprintf>

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
  80007e:	e8 c0 06 00 00       	call   800743 <strlen>
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
  800095:	68 b1 24 80 00       	push   $0x8024b1
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 84 06 00 00       	call   800729 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 f9 0d 00 00       	call   800ea6 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 88 00 00 00       	call   80014a <exit>
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
  8000d2:	68 5c 28 80 00       	push   $0x80285c
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
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 50 0a 00 00       	call   800b41 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800106:	85 db                	test   %ebx,%ebx
  800108:	7e 07                	jle    800111 <libmain+0x30>
		binaryname = argv[0];
  80010a:	8b 06                	mov    (%esi),%eax
  80010c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	e8 b1 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  80011b:	e8 2a 00 00 00       	call   80014a <exit>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800130:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800135:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800137:	e8 05 0a 00 00       	call   800b41 <sys_getenvid>
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	50                   	push   %eax
  800140:	e8 4b 0c 00 00       	call   800d90 <sys_thread_free>
}
  800145:	83 c4 10             	add    $0x10,%esp
  800148:	c9                   	leave  
  800149:	c3                   	ret    

0080014a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800150:	e8 43 13 00 00       	call   801498 <close_all>
	sys_env_destroy(0);
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	6a 00                	push   $0x0
  80015a:	e8 a1 09 00 00       	call   800b00 <sys_env_destroy>
}
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 13                	mov    (%ebx),%edx
  800170:	8d 42 01             	lea    0x1(%edx),%eax
  800173:	89 03                	mov    %eax,(%ebx)
  800175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800181:	75 1a                	jne    80019d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 2f 09 00 00       	call   800ac3 <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001af:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b6:	00 00 00 
	b.cnt = 0;
  8001b9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c3:	ff 75 0c             	pushl  0xc(%ebp)
  8001c6:	ff 75 08             	pushl  0x8(%ebp)
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	50                   	push   %eax
  8001d0:	68 64 01 80 00       	push   $0x800164
  8001d5:	e8 54 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001da:	83 c4 08             	add    $0x8,%esp
  8001dd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e9:	50                   	push   %eax
  8001ea:	e8 d4 08 00 00       	call   800ac3 <sys_cputs>

	return b.cnt;
}
  8001ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800200:	50                   	push   %eax
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	e8 9d ff ff ff       	call   8001a6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 1c             	sub    $0x1c,%esp
  800214:	89 c7                	mov    %eax,%edi
  800216:	89 d6                	mov    %edx,%esi
  800218:	8b 45 08             	mov    0x8(%ebp),%eax
  80021b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800221:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800224:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800232:	39 d3                	cmp    %edx,%ebx
  800234:	72 05                	jb     80023b <printnum+0x30>
  800236:	39 45 10             	cmp    %eax,0x10(%ebp)
  800239:	77 45                	ja     800280 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	ff 75 18             	pushl  0x18(%ebp)
  800241:	8b 45 14             	mov    0x14(%ebp),%eax
  800244:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800247:	53                   	push   %ebx
  800248:	ff 75 10             	pushl  0x10(%ebp)
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 a1 1f 00 00       	call   802200 <__udivdi3>
  80025f:	83 c4 18             	add    $0x18,%esp
  800262:	52                   	push   %edx
  800263:	50                   	push   %eax
  800264:	89 f2                	mov    %esi,%edx
  800266:	89 f8                	mov    %edi,%eax
  800268:	e8 9e ff ff ff       	call   80020b <printnum>
  80026d:	83 c4 20             	add    $0x20,%esp
  800270:	eb 18                	jmp    80028a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	56                   	push   %esi
  800276:	ff 75 18             	pushl  0x18(%ebp)
  800279:	ff d7                	call   *%edi
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	eb 03                	jmp    800283 <printnum+0x78>
  800280:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800283:	83 eb 01             	sub    $0x1,%ebx
  800286:	85 db                	test   %ebx,%ebx
  800288:	7f e8                	jg     800272 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	56                   	push   %esi
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	ff 75 e4             	pushl  -0x1c(%ebp)
  800294:	ff 75 e0             	pushl  -0x20(%ebp)
  800297:	ff 75 dc             	pushl  -0x24(%ebp)
  80029a:	ff 75 d8             	pushl  -0x28(%ebp)
  80029d:	e8 8e 20 00 00       	call   802330 <__umoddi3>
  8002a2:	83 c4 14             	add    $0x14,%esp
  8002a5:	0f be 80 c0 24 80 00 	movsbl 0x8024c0(%eax),%eax
  8002ac:	50                   	push   %eax
  8002ad:	ff d7                	call   *%edi
}
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bd:	83 fa 01             	cmp    $0x1,%edx
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x38>
	else if (lflag)
  8002d0:	85 d2                	test   %edx,%edx
  8002d2:	74 10                	je     8002e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	3b 50 04             	cmp    0x4(%eax),%edx
  800303:	73 0a                	jae    80030f <sprintputch+0x1b>
		*b->buf++ = ch;
  800305:	8d 4a 01             	lea    0x1(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	88 02                	mov    %al,(%edx)
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	e8 05 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 2c             	sub    $0x2c,%esp
  800337:	8b 75 08             	mov    0x8(%ebp),%esi
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800340:	eb 12                	jmp    800354 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800342:	85 c0                	test   %eax,%eax
  800344:	0f 84 89 03 00 00    	je     8006d3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80034a:	83 ec 08             	sub    $0x8,%esp
  80034d:	53                   	push   %ebx
  80034e:	50                   	push   %eax
  80034f:	ff d6                	call   *%esi
  800351:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800354:	83 c7 01             	add    $0x1,%edi
  800357:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035b:	83 f8 25             	cmp    $0x25,%eax
  80035e:	75 e2                	jne    800342 <vprintfmt+0x14>
  800360:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800364:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800372:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	eb 07                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8d 47 01             	lea    0x1(%edi),%eax
  80038a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038d:	0f b6 07             	movzbl (%edi),%eax
  800390:	0f b6 c8             	movzbl %al,%ecx
  800393:	83 e8 23             	sub    $0x23,%eax
  800396:	3c 55                	cmp    $0x55,%al
  800398:	0f 87 1a 03 00 00    	ja     8006b8 <vprintfmt+0x38a>
  80039e:	0f b6 c0             	movzbl %al,%eax
  8003a1:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ab:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003af:	eb d6                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c9:	83 fa 09             	cmp    $0x9,%edx
  8003cc:	77 39                	ja     800407 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ce:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d1:	eb e9                	jmp    8003bc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e4:	eb 27                	jmp    80040d <vprintfmt+0xdf>
  8003e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f0:	0f 49 c8             	cmovns %eax,%ecx
  8003f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f9:	eb 8c                	jmp    800387 <vprintfmt+0x59>
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800405:	eb 80                	jmp    800387 <vprintfmt+0x59>
  800407:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800411:	0f 89 70 ff ff ff    	jns    800387 <vprintfmt+0x59>
				width = precision, precision = -1;
  800417:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800424:	e9 5e ff ff ff       	jmp    800387 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800429:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042f:	e9 53 ff ff ff       	jmp    800387 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	53                   	push   %ebx
  800441:	ff 30                	pushl  (%eax)
  800443:	ff d6                	call   *%esi
			break;
  800445:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044b:	e9 04 ff ff ff       	jmp    800354 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	99                   	cltd   
  80045c:	31 d0                	xor    %edx,%eax
  80045e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800460:	83 f8 0f             	cmp    $0xf,%eax
  800463:	7f 0b                	jg     800470 <vprintfmt+0x142>
  800465:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  80046c:	85 d2                	test   %edx,%edx
  80046e:	75 18                	jne    800488 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800470:	50                   	push   %eax
  800471:	68 d8 24 80 00       	push   $0x8024d8
  800476:	53                   	push   %ebx
  800477:	56                   	push   %esi
  800478:	e8 94 fe ff ff       	call   800311 <printfmt>
  80047d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800483:	e9 cc fe ff ff       	jmp    800354 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800488:	52                   	push   %edx
  800489:	68 1d 29 80 00       	push   $0x80291d
  80048e:	53                   	push   %ebx
  80048f:	56                   	push   %esi
  800490:	e8 7c fe ff ff       	call   800311 <printfmt>
  800495:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049b:	e9 b4 fe ff ff       	jmp    800354 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ab:	85 ff                	test   %edi,%edi
  8004ad:	b8 d1 24 80 00       	mov    $0x8024d1,%eax
  8004b2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b9:	0f 8e 94 00 00 00    	jle    800553 <vprintfmt+0x225>
  8004bf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c3:	0f 84 98 00 00 00    	je     800561 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004cf:	57                   	push   %edi
  8004d0:	e8 86 02 00 00       	call   80075b <strnlen>
  8004d5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d8:	29 c1                	sub    %eax,%ecx
  8004da:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004dd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ea:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	eb 0f                	jmp    8004fd <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	53                   	push   %ebx
  8004f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f7:	83 ef 01             	sub    $0x1,%edi
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	85 ff                	test   %edi,%edi
  8004ff:	7f ed                	jg     8004ee <vprintfmt+0x1c0>
  800501:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800504:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800507:	85 c9                	test   %ecx,%ecx
  800509:	b8 00 00 00 00       	mov    $0x0,%eax
  80050e:	0f 49 c1             	cmovns %ecx,%eax
  800511:	29 c1                	sub    %eax,%ecx
  800513:	89 75 08             	mov    %esi,0x8(%ebp)
  800516:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800519:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051c:	89 cb                	mov    %ecx,%ebx
  80051e:	eb 4d                	jmp    80056d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800520:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800524:	74 1b                	je     800541 <vprintfmt+0x213>
  800526:	0f be c0             	movsbl %al,%eax
  800529:	83 e8 20             	sub    $0x20,%eax
  80052c:	83 f8 5e             	cmp    $0x5e,%eax
  80052f:	76 10                	jbe    800541 <vprintfmt+0x213>
					putch('?', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	ff 75 0c             	pushl  0xc(%ebp)
  800537:	6a 3f                	push   $0x3f
  800539:	ff 55 08             	call   *0x8(%ebp)
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	eb 0d                	jmp    80054e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	ff 75 0c             	pushl  0xc(%ebp)
  800547:	52                   	push   %edx
  800548:	ff 55 08             	call   *0x8(%ebp)
  80054b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054e:	83 eb 01             	sub    $0x1,%ebx
  800551:	eb 1a                	jmp    80056d <vprintfmt+0x23f>
  800553:	89 75 08             	mov    %esi,0x8(%ebp)
  800556:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800559:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055f:	eb 0c                	jmp    80056d <vprintfmt+0x23f>
  800561:	89 75 08             	mov    %esi,0x8(%ebp)
  800564:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800567:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056d:	83 c7 01             	add    $0x1,%edi
  800570:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800574:	0f be d0             	movsbl %al,%edx
  800577:	85 d2                	test   %edx,%edx
  800579:	74 23                	je     80059e <vprintfmt+0x270>
  80057b:	85 f6                	test   %esi,%esi
  80057d:	78 a1                	js     800520 <vprintfmt+0x1f2>
  80057f:	83 ee 01             	sub    $0x1,%esi
  800582:	79 9c                	jns    800520 <vprintfmt+0x1f2>
  800584:	89 df                	mov    %ebx,%edi
  800586:	8b 75 08             	mov    0x8(%ebp),%esi
  800589:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058c:	eb 18                	jmp    8005a6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	53                   	push   %ebx
  800592:	6a 20                	push   $0x20
  800594:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800596:	83 ef 01             	sub    $0x1,%edi
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	eb 08                	jmp    8005a6 <vprintfmt+0x278>
  80059e:	89 df                	mov    %ebx,%edi
  8005a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a6:	85 ff                	test   %edi,%edi
  8005a8:	7f e4                	jg     80058e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ad:	e9 a2 fd ff ff       	jmp    800354 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b2:	83 fa 01             	cmp    $0x1,%edx
  8005b5:	7e 16                	jle    8005cd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 50 08             	lea    0x8(%eax),%edx
  8005bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c0:	8b 50 04             	mov    0x4(%eax),%edx
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cb:	eb 32                	jmp    8005ff <vprintfmt+0x2d1>
	else if (lflag)
  8005cd:	85 d2                	test   %edx,%edx
  8005cf:	74 18                	je     8005e9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005df:	89 c1                	mov    %eax,%ecx
  8005e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e7:	eb 16                	jmp    8005ff <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 c1                	mov    %eax,%ecx
  8005f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800602:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800605:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060e:	79 74                	jns    800684 <vprintfmt+0x356>
				putch('-', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 2d                	push   $0x2d
  800616:	ff d6                	call   *%esi
				num = -(long long) num;
  800618:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061e:	f7 d8                	neg    %eax
  800620:	83 d2 00             	adc    $0x0,%edx
  800623:	f7 da                	neg    %edx
  800625:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800628:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062d:	eb 55                	jmp    800684 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 83 fc ff ff       	call   8002ba <getuint>
			base = 10;
  800637:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063c:	eb 46                	jmp    800684 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063e:	8d 45 14             	lea    0x14(%ebp),%eax
  800641:	e8 74 fc ff ff       	call   8002ba <getuint>
			base = 8;
  800646:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80064b:	eb 37                	jmp    800684 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 30                	push   $0x30
  800653:	ff d6                	call   *%esi
			putch('x', putdat);
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 78                	push   $0x78
  80065b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 50 04             	lea    0x4(%eax),%edx
  800663:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800666:	8b 00                	mov    (%eax),%eax
  800668:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800670:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800675:	eb 0d                	jmp    800684 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 3b fc ff ff       	call   8002ba <getuint>
			base = 16;
  80067f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800684:	83 ec 0c             	sub    $0xc,%esp
  800687:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068b:	57                   	push   %edi
  80068c:	ff 75 e0             	pushl  -0x20(%ebp)
  80068f:	51                   	push   %ecx
  800690:	52                   	push   %edx
  800691:	50                   	push   %eax
  800692:	89 da                	mov    %ebx,%edx
  800694:	89 f0                	mov    %esi,%eax
  800696:	e8 70 fb ff ff       	call   80020b <printnum>
			break;
  80069b:	83 c4 20             	add    $0x20,%esp
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	e9 ae fc ff ff       	jmp    800354 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	51                   	push   %ecx
  8006ab:	ff d6                	call   *%esi
			break;
  8006ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b3:	e9 9c fc ff ff       	jmp    800354 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	6a 25                	push   $0x25
  8006be:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 03                	jmp    8006c8 <vprintfmt+0x39a>
  8006c5:	83 ef 01             	sub    $0x1,%edi
  8006c8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006cc:	75 f7                	jne    8006c5 <vprintfmt+0x397>
  8006ce:	e9 81 fc ff ff       	jmp    800354 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d6:	5b                   	pop    %ebx
  8006d7:	5e                   	pop    %esi
  8006d8:	5f                   	pop    %edi
  8006d9:	5d                   	pop    %ebp
  8006da:	c3                   	ret    

008006db <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 18             	sub    $0x18,%esp
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 26                	je     800722 <vsnprintf+0x47>
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	7e 22                	jle    800722 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800700:	ff 75 14             	pushl  0x14(%ebp)
  800703:	ff 75 10             	pushl  0x10(%ebp)
  800706:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	68 f4 02 80 00       	push   $0x8002f4
  80070f:	e8 1a fc ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800714:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800717:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	eb 05                	jmp    800727 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800722:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800727:	c9                   	leave  
  800728:	c3                   	ret    

00800729 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800732:	50                   	push   %eax
  800733:	ff 75 10             	pushl  0x10(%ebp)
  800736:	ff 75 0c             	pushl  0xc(%ebp)
  800739:	ff 75 08             	pushl  0x8(%ebp)
  80073c:	e8 9a ff ff ff       	call   8006db <vsnprintf>
	va_end(ap);

	return rc;
}
  800741:	c9                   	leave  
  800742:	c3                   	ret    

00800743 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800749:	b8 00 00 00 00       	mov    $0x0,%eax
  80074e:	eb 03                	jmp    800753 <strlen+0x10>
		n++;
  800750:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800753:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800757:	75 f7                	jne    800750 <strlen+0xd>
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800761:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800764:	ba 00 00 00 00       	mov    $0x0,%edx
  800769:	eb 03                	jmp    80076e <strnlen+0x13>
		n++;
  80076b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076e:	39 c2                	cmp    %eax,%edx
  800770:	74 08                	je     80077a <strnlen+0x1f>
  800772:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800776:	75 f3                	jne    80076b <strnlen+0x10>
  800778:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	53                   	push   %ebx
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c2 01             	add    $0x1,%edx
  80078b:	83 c1 01             	add    $0x1,%ecx
  80078e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800792:	88 5a ff             	mov    %bl,-0x1(%edx)
  800795:	84 db                	test   %bl,%bl
  800797:	75 ef                	jne    800788 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800799:	5b                   	pop    %ebx
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a3:	53                   	push   %ebx
  8007a4:	e8 9a ff ff ff       	call   800743 <strlen>
  8007a9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	01 d8                	add    %ebx,%eax
  8007b1:	50                   	push   %eax
  8007b2:	e8 c5 ff ff ff       	call   80077c <strcpy>
	return dst;
}
  8007b7:	89 d8                	mov    %ebx,%eax
  8007b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	56                   	push   %esi
  8007c2:	53                   	push   %ebx
  8007c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c9:	89 f3                	mov    %esi,%ebx
  8007cb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	eb 0f                	jmp    8007e1 <strncpy+0x23>
		*dst++ = *src;
  8007d2:	83 c2 01             	add    $0x1,%edx
  8007d5:	0f b6 01             	movzbl (%ecx),%eax
  8007d8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007db:	80 39 01             	cmpb   $0x1,(%ecx)
  8007de:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e1:	39 da                	cmp    %ebx,%edx
  8007e3:	75 ed                	jne    8007d2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e5:	89 f0                	mov    %esi,%eax
  8007e7:	5b                   	pop    %ebx
  8007e8:	5e                   	pop    %esi
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	56                   	push   %esi
  8007ef:	53                   	push   %ebx
  8007f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fb:	85 d2                	test   %edx,%edx
  8007fd:	74 21                	je     800820 <strlcpy+0x35>
  8007ff:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800803:	89 f2                	mov    %esi,%edx
  800805:	eb 09                	jmp    800810 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800807:	83 c2 01             	add    $0x1,%edx
  80080a:	83 c1 01             	add    $0x1,%ecx
  80080d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800810:	39 c2                	cmp    %eax,%edx
  800812:	74 09                	je     80081d <strlcpy+0x32>
  800814:	0f b6 19             	movzbl (%ecx),%ebx
  800817:	84 db                	test   %bl,%bl
  800819:	75 ec                	jne    800807 <strlcpy+0x1c>
  80081b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800820:	29 f0                	sub    %esi,%eax
}
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082f:	eb 06                	jmp    800837 <strcmp+0x11>
		p++, q++;
  800831:	83 c1 01             	add    $0x1,%ecx
  800834:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800837:	0f b6 01             	movzbl (%ecx),%eax
  80083a:	84 c0                	test   %al,%al
  80083c:	74 04                	je     800842 <strcmp+0x1c>
  80083e:	3a 02                	cmp    (%edx),%al
  800840:	74 ef                	je     800831 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800842:	0f b6 c0             	movzbl %al,%eax
  800845:	0f b6 12             	movzbl (%edx),%edx
  800848:	29 d0                	sub    %edx,%eax
}
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	53                   	push   %ebx
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
  800856:	89 c3                	mov    %eax,%ebx
  800858:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085b:	eb 06                	jmp    800863 <strncmp+0x17>
		n--, p++, q++;
  80085d:	83 c0 01             	add    $0x1,%eax
  800860:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800863:	39 d8                	cmp    %ebx,%eax
  800865:	74 15                	je     80087c <strncmp+0x30>
  800867:	0f b6 08             	movzbl (%eax),%ecx
  80086a:	84 c9                	test   %cl,%cl
  80086c:	74 04                	je     800872 <strncmp+0x26>
  80086e:	3a 0a                	cmp    (%edx),%cl
  800870:	74 eb                	je     80085d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800872:	0f b6 00             	movzbl (%eax),%eax
  800875:	0f b6 12             	movzbl (%edx),%edx
  800878:	29 d0                	sub    %edx,%eax
  80087a:	eb 05                	jmp    800881 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800881:	5b                   	pop    %ebx
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088e:	eb 07                	jmp    800897 <strchr+0x13>
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	74 0f                	je     8008a3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800894:	83 c0 01             	add    $0x1,%eax
  800897:	0f b6 10             	movzbl (%eax),%edx
  80089a:	84 d2                	test   %dl,%dl
  80089c:	75 f2                	jne    800890 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008af:	eb 03                	jmp    8008b4 <strfind+0xf>
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b7:	38 ca                	cmp    %cl,%dl
  8008b9:	74 04                	je     8008bf <strfind+0x1a>
  8008bb:	84 d2                	test   %dl,%dl
  8008bd:	75 f2                	jne    8008b1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	57                   	push   %edi
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	74 36                	je     800907 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d7:	75 28                	jne    800901 <memset+0x40>
  8008d9:	f6 c1 03             	test   $0x3,%cl
  8008dc:	75 23                	jne    800901 <memset+0x40>
		c &= 0xFF;
  8008de:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e2:	89 d3                	mov    %edx,%ebx
  8008e4:	c1 e3 08             	shl    $0x8,%ebx
  8008e7:	89 d6                	mov    %edx,%esi
  8008e9:	c1 e6 18             	shl    $0x18,%esi
  8008ec:	89 d0                	mov    %edx,%eax
  8008ee:	c1 e0 10             	shl    $0x10,%eax
  8008f1:	09 f0                	or     %esi,%eax
  8008f3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f5:	89 d8                	mov    %ebx,%eax
  8008f7:	09 d0                	or     %edx,%eax
  8008f9:	c1 e9 02             	shr    $0x2,%ecx
  8008fc:	fc                   	cld    
  8008fd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ff:	eb 06                	jmp    800907 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800901:	8b 45 0c             	mov    0xc(%ebp),%eax
  800904:	fc                   	cld    
  800905:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800907:	89 f8                	mov    %edi,%eax
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5f                   	pop    %edi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	57                   	push   %edi
  800912:	56                   	push   %esi
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 75 0c             	mov    0xc(%ebp),%esi
  800919:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091c:	39 c6                	cmp    %eax,%esi
  80091e:	73 35                	jae    800955 <memmove+0x47>
  800920:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800923:	39 d0                	cmp    %edx,%eax
  800925:	73 2e                	jae    800955 <memmove+0x47>
		s += n;
		d += n;
  800927:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092a:	89 d6                	mov    %edx,%esi
  80092c:	09 fe                	or     %edi,%esi
  80092e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800934:	75 13                	jne    800949 <memmove+0x3b>
  800936:	f6 c1 03             	test   $0x3,%cl
  800939:	75 0e                	jne    800949 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093b:	83 ef 04             	sub    $0x4,%edi
  80093e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800941:	c1 e9 02             	shr    $0x2,%ecx
  800944:	fd                   	std    
  800945:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800947:	eb 09                	jmp    800952 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800949:	83 ef 01             	sub    $0x1,%edi
  80094c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094f:	fd                   	std    
  800950:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800952:	fc                   	cld    
  800953:	eb 1d                	jmp    800972 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800955:	89 f2                	mov    %esi,%edx
  800957:	09 c2                	or     %eax,%edx
  800959:	f6 c2 03             	test   $0x3,%dl
  80095c:	75 0f                	jne    80096d <memmove+0x5f>
  80095e:	f6 c1 03             	test   $0x3,%cl
  800961:	75 0a                	jne    80096d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800963:	c1 e9 02             	shr    $0x2,%ecx
  800966:	89 c7                	mov    %eax,%edi
  800968:	fc                   	cld    
  800969:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096b:	eb 05                	jmp    800972 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096d:	89 c7                	mov    %eax,%edi
  80096f:	fc                   	cld    
  800970:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800979:	ff 75 10             	pushl  0x10(%ebp)
  80097c:	ff 75 0c             	pushl  0xc(%ebp)
  80097f:	ff 75 08             	pushl  0x8(%ebp)
  800982:	e8 87 ff ff ff       	call   80090e <memmove>
}
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
  800994:	89 c6                	mov    %eax,%esi
  800996:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800999:	eb 1a                	jmp    8009b5 <memcmp+0x2c>
		if (*s1 != *s2)
  80099b:	0f b6 08             	movzbl (%eax),%ecx
  80099e:	0f b6 1a             	movzbl (%edx),%ebx
  8009a1:	38 d9                	cmp    %bl,%cl
  8009a3:	74 0a                	je     8009af <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a5:	0f b6 c1             	movzbl %cl,%eax
  8009a8:	0f b6 db             	movzbl %bl,%ebx
  8009ab:	29 d8                	sub    %ebx,%eax
  8009ad:	eb 0f                	jmp    8009be <memcmp+0x35>
		s1++, s2++;
  8009af:	83 c0 01             	add    $0x1,%eax
  8009b2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b5:	39 f0                	cmp    %esi,%eax
  8009b7:	75 e2                	jne    80099b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c9:	89 c1                	mov    %eax,%ecx
  8009cb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ce:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d2:	eb 0a                	jmp    8009de <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d4:	0f b6 10             	movzbl (%eax),%edx
  8009d7:	39 da                	cmp    %ebx,%edx
  8009d9:	74 07                	je     8009e2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	39 c8                	cmp    %ecx,%eax
  8009e0:	72 f2                	jb     8009d4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	57                   	push   %edi
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f1:	eb 03                	jmp    8009f6 <strtol+0x11>
		s++;
  8009f3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f6:	0f b6 01             	movzbl (%ecx),%eax
  8009f9:	3c 20                	cmp    $0x20,%al
  8009fb:	74 f6                	je     8009f3 <strtol+0xe>
  8009fd:	3c 09                	cmp    $0x9,%al
  8009ff:	74 f2                	je     8009f3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a01:	3c 2b                	cmp    $0x2b,%al
  800a03:	75 0a                	jne    800a0f <strtol+0x2a>
		s++;
  800a05:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a08:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0d:	eb 11                	jmp    800a20 <strtol+0x3b>
  800a0f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a14:	3c 2d                	cmp    $0x2d,%al
  800a16:	75 08                	jne    800a20 <strtol+0x3b>
		s++, neg = 1;
  800a18:	83 c1 01             	add    $0x1,%ecx
  800a1b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a20:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a26:	75 15                	jne    800a3d <strtol+0x58>
  800a28:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2b:	75 10                	jne    800a3d <strtol+0x58>
  800a2d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a31:	75 7c                	jne    800aaf <strtol+0xca>
		s += 2, base = 16;
  800a33:	83 c1 02             	add    $0x2,%ecx
  800a36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3b:	eb 16                	jmp    800a53 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3d:	85 db                	test   %ebx,%ebx
  800a3f:	75 12                	jne    800a53 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a41:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a46:	80 39 30             	cmpb   $0x30,(%ecx)
  800a49:	75 08                	jne    800a53 <strtol+0x6e>
		s++, base = 8;
  800a4b:	83 c1 01             	add    $0x1,%ecx
  800a4e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
  800a58:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5b:	0f b6 11             	movzbl (%ecx),%edx
  800a5e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a61:	89 f3                	mov    %esi,%ebx
  800a63:	80 fb 09             	cmp    $0x9,%bl
  800a66:	77 08                	ja     800a70 <strtol+0x8b>
			dig = *s - '0';
  800a68:	0f be d2             	movsbl %dl,%edx
  800a6b:	83 ea 30             	sub    $0x30,%edx
  800a6e:	eb 22                	jmp    800a92 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a70:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a73:	89 f3                	mov    %esi,%ebx
  800a75:	80 fb 19             	cmp    $0x19,%bl
  800a78:	77 08                	ja     800a82 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7a:	0f be d2             	movsbl %dl,%edx
  800a7d:	83 ea 57             	sub    $0x57,%edx
  800a80:	eb 10                	jmp    800a92 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a82:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a85:	89 f3                	mov    %esi,%ebx
  800a87:	80 fb 19             	cmp    $0x19,%bl
  800a8a:	77 16                	ja     800aa2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8c:	0f be d2             	movsbl %dl,%edx
  800a8f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a92:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a95:	7d 0b                	jge    800aa2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa0:	eb b9                	jmp    800a5b <strtol+0x76>

	if (endptr)
  800aa2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa6:	74 0d                	je     800ab5 <strtol+0xd0>
		*endptr = (char *) s;
  800aa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aab:	89 0e                	mov    %ecx,(%esi)
  800aad:	eb 06                	jmp    800ab5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aaf:	85 db                	test   %ebx,%ebx
  800ab1:	74 98                	je     800a4b <strtol+0x66>
  800ab3:	eb 9e                	jmp    800a53 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab5:	89 c2                	mov    %eax,%edx
  800ab7:	f7 da                	neg    %edx
  800ab9:	85 ff                	test   %edi,%edi
  800abb:	0f 45 c2             	cmovne %edx,%eax
}
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad4:	89 c3                	mov    %eax,%ebx
  800ad6:	89 c7                	mov    %eax,%edi
  800ad8:	89 c6                	mov    %eax,%esi
  800ada:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aec:	b8 01 00 00 00       	mov    $0x1,%eax
  800af1:	89 d1                	mov    %edx,%ecx
  800af3:	89 d3                	mov    %edx,%ebx
  800af5:	89 d7                	mov    %edx,%edi
  800af7:	89 d6                	mov    %edx,%esi
  800af9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	89 cb                	mov    %ecx,%ebx
  800b18:	89 cf                	mov    %ecx,%edi
  800b1a:	89 ce                	mov    %ecx,%esi
  800b1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	7e 17                	jle    800b39 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b22:	83 ec 0c             	sub    $0xc,%esp
  800b25:	50                   	push   %eax
  800b26:	6a 03                	push   $0x3
  800b28:	68 bf 27 80 00       	push   $0x8027bf
  800b2d:	6a 23                	push   $0x23
  800b2f:	68 dc 27 80 00       	push   $0x8027dc
  800b34:	e8 90 14 00 00       	call   801fc9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b51:	89 d1                	mov    %edx,%ecx
  800b53:	89 d3                	mov    %edx,%ebx
  800b55:	89 d7                	mov    %edx,%edi
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_yield>:

void
sys_yield(void)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b70:	89 d1                	mov    %edx,%ecx
  800b72:	89 d3                	mov    %edx,%ebx
  800b74:	89 d7                	mov    %edx,%edi
  800b76:	89 d6                	mov    %edx,%esi
  800b78:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	be 00 00 00 00       	mov    $0x0,%esi
  800b8d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9b:	89 f7                	mov    %esi,%edi
  800b9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 04                	push   $0x4
  800ba9:	68 bf 27 80 00       	push   $0x8027bf
  800bae:	6a 23                	push   $0x23
  800bb0:	68 dc 27 80 00       	push   $0x8027dc
  800bb5:	e8 0f 14 00 00       	call   801fc9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdc:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 05                	push   $0x5
  800beb:	68 bf 27 80 00       	push   $0x8027bf
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 dc 27 80 00       	push   $0x8027dc
  800bf7:	e8 cd 13 00 00       	call   801fc9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 06 00 00 00       	mov    $0x6,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 06                	push   $0x6
  800c2d:	68 bf 27 80 00       	push   $0x8027bf
  800c32:	6a 23                	push   $0x23
  800c34:	68 dc 27 80 00       	push   $0x8027dc
  800c39:	e8 8b 13 00 00       	call   801fc9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 08 00 00 00       	mov    $0x8,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 08                	push   $0x8
  800c6f:	68 bf 27 80 00       	push   $0x8027bf
  800c74:	6a 23                	push   $0x23
  800c76:	68 dc 27 80 00       	push   $0x8027dc
  800c7b:	e8 49 13 00 00       	call   801fc9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 09                	push   $0x9
  800cb1:	68 bf 27 80 00       	push   $0x8027bf
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 dc 27 80 00       	push   $0x8027dc
  800cbd:	e8 07 13 00 00       	call   801fc9 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 17                	jle    800d04 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 0a                	push   $0xa
  800cf3:	68 bf 27 80 00       	push   $0x8027bf
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 dc 27 80 00       	push   $0x8027dc
  800cff:	e8 c5 12 00 00       	call   801fc9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d12:	be 00 00 00 00       	mov    $0x0,%esi
  800d17:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d25:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d28:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
  800d35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	89 cb                	mov    %ecx,%ebx
  800d47:	89 cf                	mov    %ecx,%edi
  800d49:	89 ce                	mov    %ecx,%esi
  800d4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 17                	jle    800d68 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 0d                	push   $0xd
  800d57:	68 bf 27 80 00       	push   $0x8027bf
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 dc 27 80 00       	push   $0x8027dc
  800d63:	e8 61 12 00 00       	call   801fc9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 cb                	mov    %ecx,%ebx
  800d85:	89 cf                	mov    %ecx,%edi
  800d87:	89 ce                	mov    %ecx,%esi
  800d89:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 cb                	mov    %ecx,%ebx
  800da5:	89 cf                	mov    %ecx,%edi
  800da7:	89 ce                	mov    %ecx,%esi
  800da9:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbb:	b8 10 00 00 00       	mov    $0x10,%eax
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 cb                	mov    %ecx,%ebx
  800dc5:	89 cf                	mov    %ecx,%edi
  800dc7:	89 ce                	mov    %ecx,%esi
  800dc9:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dda:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800ddc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de0:	74 11                	je     800df3 <pgfault+0x23>
  800de2:	89 d8                	mov    %ebx,%eax
  800de4:	c1 e8 0c             	shr    $0xc,%eax
  800de7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dee:	f6 c4 08             	test   $0x8,%ah
  800df1:	75 14                	jne    800e07 <pgfault+0x37>
		panic("faulting access");
  800df3:	83 ec 04             	sub    $0x4,%esp
  800df6:	68 ea 27 80 00       	push   $0x8027ea
  800dfb:	6a 1f                	push   $0x1f
  800dfd:	68 fa 27 80 00       	push   $0x8027fa
  800e02:	e8 c2 11 00 00       	call   801fc9 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800e07:	83 ec 04             	sub    $0x4,%esp
  800e0a:	6a 07                	push   $0x7
  800e0c:	68 00 f0 7f 00       	push   $0x7ff000
  800e11:	6a 00                	push   $0x0
  800e13:	e8 67 fd ff ff       	call   800b7f <sys_page_alloc>
	if (r < 0) {
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	79 12                	jns    800e31 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e1f:	50                   	push   %eax
  800e20:	68 05 28 80 00       	push   $0x802805
  800e25:	6a 2d                	push   $0x2d
  800e27:	68 fa 27 80 00       	push   $0x8027fa
  800e2c:	e8 98 11 00 00       	call   801fc9 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e31:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	68 00 10 00 00       	push   $0x1000
  800e3f:	53                   	push   %ebx
  800e40:	68 00 f0 7f 00       	push   $0x7ff000
  800e45:	e8 2c fb ff ff       	call   800976 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e4a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e51:	53                   	push   %ebx
  800e52:	6a 00                	push   $0x0
  800e54:	68 00 f0 7f 00       	push   $0x7ff000
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 62 fd ff ff       	call   800bc2 <sys_page_map>
	if (r < 0) {
  800e60:	83 c4 20             	add    $0x20,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	79 12                	jns    800e79 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e67:	50                   	push   %eax
  800e68:	68 05 28 80 00       	push   $0x802805
  800e6d:	6a 34                	push   $0x34
  800e6f:	68 fa 27 80 00       	push   $0x8027fa
  800e74:	e8 50 11 00 00       	call   801fc9 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e79:	83 ec 08             	sub    $0x8,%esp
  800e7c:	68 00 f0 7f 00       	push   $0x7ff000
  800e81:	6a 00                	push   $0x0
  800e83:	e8 7c fd ff ff       	call   800c04 <sys_page_unmap>
	if (r < 0) {
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	79 12                	jns    800ea1 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e8f:	50                   	push   %eax
  800e90:	68 05 28 80 00       	push   $0x802805
  800e95:	6a 38                	push   $0x38
  800e97:	68 fa 27 80 00       	push   $0x8027fa
  800e9c:	e8 28 11 00 00       	call   801fc9 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800eaf:	68 d0 0d 80 00       	push   $0x800dd0
  800eb4:	e8 56 11 00 00       	call   80200f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb9:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebe:	cd 30                	int    $0x30
  800ec0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	79 17                	jns    800ee1 <fork+0x3b>
		panic("fork fault %e");
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	68 1e 28 80 00       	push   $0x80281e
  800ed2:	68 85 00 00 00       	push   $0x85
  800ed7:	68 fa 27 80 00       	push   $0x8027fa
  800edc:	e8 e8 10 00 00       	call   801fc9 <_panic>
  800ee1:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ee3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ee7:	75 24                	jne    800f0d <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ee9:	e8 53 fc ff ff       	call   800b41 <sys_getenvid>
  800eee:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef3:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800ef9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800efe:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f03:	b8 00 00 00 00       	mov    $0x0,%eax
  800f08:	e9 64 01 00 00       	jmp    801071 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	6a 07                	push   $0x7
  800f12:	68 00 f0 bf ee       	push   $0xeebff000
  800f17:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f1a:	e8 60 fc ff ff       	call   800b7f <sys_page_alloc>
  800f1f:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f22:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f27:	89 d8                	mov    %ebx,%eax
  800f29:	c1 e8 16             	shr    $0x16,%eax
  800f2c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f33:	a8 01                	test   $0x1,%al
  800f35:	0f 84 fc 00 00 00    	je     801037 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f3b:	89 d8                	mov    %ebx,%eax
  800f3d:	c1 e8 0c             	shr    $0xc,%eax
  800f40:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f47:	f6 c2 01             	test   $0x1,%dl
  800f4a:	0f 84 e7 00 00 00    	je     801037 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f50:	89 c6                	mov    %eax,%esi
  800f52:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f55:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5c:	f6 c6 04             	test   $0x4,%dh
  800f5f:	74 39                	je     800f9a <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f61:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f70:	50                   	push   %eax
  800f71:	56                   	push   %esi
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	e8 47 fc ff ff       	call   800bc2 <sys_page_map>
		if (r < 0) {
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	0f 89 b1 00 00 00    	jns    801037 <fork+0x191>
		    	panic("sys page map fault %e");
  800f86:	83 ec 04             	sub    $0x4,%esp
  800f89:	68 2c 28 80 00       	push   $0x80282c
  800f8e:	6a 55                	push   $0x55
  800f90:	68 fa 27 80 00       	push   $0x8027fa
  800f95:	e8 2f 10 00 00       	call   801fc9 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f9a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa1:	f6 c2 02             	test   $0x2,%dl
  800fa4:	75 0c                	jne    800fb2 <fork+0x10c>
  800fa6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fad:	f6 c4 08             	test   $0x8,%ah
  800fb0:	74 5b                	je     80100d <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800fb2:	83 ec 0c             	sub    $0xc,%esp
  800fb5:	68 05 08 00 00       	push   $0x805
  800fba:	56                   	push   %esi
  800fbb:	57                   	push   %edi
  800fbc:	56                   	push   %esi
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 fe fb ff ff       	call   800bc2 <sys_page_map>
		if (r < 0) {
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	79 14                	jns    800fdf <fork+0x139>
		    	panic("sys page map fault %e");
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	68 2c 28 80 00       	push   $0x80282c
  800fd3:	6a 5c                	push   $0x5c
  800fd5:	68 fa 27 80 00       	push   $0x8027fa
  800fda:	e8 ea 0f 00 00       	call   801fc9 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	68 05 08 00 00       	push   $0x805
  800fe7:	56                   	push   %esi
  800fe8:	6a 00                	push   $0x0
  800fea:	56                   	push   %esi
  800feb:	6a 00                	push   $0x0
  800fed:	e8 d0 fb ff ff       	call   800bc2 <sys_page_map>
		if (r < 0) {
  800ff2:	83 c4 20             	add    $0x20,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 3e                	jns    801037 <fork+0x191>
		    	panic("sys page map fault %e");
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	68 2c 28 80 00       	push   $0x80282c
  801001:	6a 60                	push   $0x60
  801003:	68 fa 27 80 00       	push   $0x8027fa
  801008:	e8 bc 0f 00 00       	call   801fc9 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	6a 05                	push   $0x5
  801012:	56                   	push   %esi
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	6a 00                	push   $0x0
  801017:	e8 a6 fb ff ff       	call   800bc2 <sys_page_map>
		if (r < 0) {
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	79 14                	jns    801037 <fork+0x191>
		    	panic("sys page map fault %e");
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	68 2c 28 80 00       	push   $0x80282c
  80102b:	6a 65                	push   $0x65
  80102d:	68 fa 27 80 00       	push   $0x8027fa
  801032:	e8 92 0f 00 00       	call   801fc9 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801037:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80103d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801043:	0f 85 de fe ff ff    	jne    800f27 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801049:	a1 04 40 80 00       	mov    0x804004,%eax
  80104e:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	50                   	push   %eax
  801058:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80105b:	57                   	push   %edi
  80105c:	e8 69 fc ff ff       	call   800cca <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801061:	83 c4 08             	add    $0x8,%esp
  801064:	6a 02                	push   $0x2
  801066:	57                   	push   %edi
  801067:	e8 da fb ff ff       	call   800c46 <sys_env_set_status>
	
	return envid;
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801071:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <sfork>:

envid_t
sfork(void)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801091:	68 2a 01 80 00       	push   $0x80012a
  801096:	e8 d5 fc ff ff       	call   800d70 <sys_thread_create>

	return id;
}
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8010a3:	ff 75 08             	pushl  0x8(%ebp)
  8010a6:	e8 e5 fc ff ff       	call   800d90 <sys_thread_free>
}
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8010b6:	ff 75 08             	pushl  0x8(%ebp)
  8010b9:	e8 f2 fc ff ff       	call   800db0 <sys_thread_join>
}
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8010cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010ce:	83 ec 04             	sub    $0x4,%esp
  8010d1:	6a 07                	push   $0x7
  8010d3:	6a 00                	push   $0x0
  8010d5:	56                   	push   %esi
  8010d6:	e8 a4 fa ff ff       	call   800b7f <sys_page_alloc>
	if (r < 0) {
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 15                	jns    8010f7 <queue_append+0x34>
		panic("%e\n", r);
  8010e2:	50                   	push   %eax
  8010e3:	68 72 28 80 00       	push   $0x802872
  8010e8:	68 d5 00 00 00       	push   $0xd5
  8010ed:	68 fa 27 80 00       	push   $0x8027fa
  8010f2:	e8 d2 0e 00 00       	call   801fc9 <_panic>
	}	

	wt->envid = envid;
  8010f7:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8010fd:	83 3b 00             	cmpl   $0x0,(%ebx)
  801100:	75 13                	jne    801115 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801102:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801109:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801110:	00 00 00 
  801113:	eb 1b                	jmp    801130 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801115:	8b 43 04             	mov    0x4(%ebx),%eax
  801118:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80111f:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801126:	00 00 00 
		queue->last = wt;
  801129:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801130:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801140:	8b 02                	mov    (%edx),%eax
  801142:	85 c0                	test   %eax,%eax
  801144:	75 17                	jne    80115d <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	68 42 28 80 00       	push   $0x802842
  80114e:	68 ec 00 00 00       	push   $0xec
  801153:	68 fa 27 80 00       	push   $0x8027fa
  801158:	e8 6c 0e 00 00       	call   801fc9 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80115d:	8b 48 04             	mov    0x4(%eax),%ecx
  801160:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801162:	8b 00                	mov    (%eax),%eax
}
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	53                   	push   %ebx
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801170:	b8 01 00 00 00       	mov    $0x1,%eax
  801175:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  801178:	85 c0                	test   %eax,%eax
  80117a:	74 45                	je     8011c1 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  80117c:	e8 c0 f9 ff ff       	call   800b41 <sys_getenvid>
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	83 c3 04             	add    $0x4,%ebx
  801187:	53                   	push   %ebx
  801188:	50                   	push   %eax
  801189:	e8 35 ff ff ff       	call   8010c3 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80118e:	e8 ae f9 ff ff       	call   800b41 <sys_getenvid>
  801193:	83 c4 08             	add    $0x8,%esp
  801196:	6a 04                	push   $0x4
  801198:	50                   	push   %eax
  801199:	e8 a8 fa ff ff       	call   800c46 <sys_env_set_status>

		if (r < 0) {
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	79 15                	jns    8011ba <mutex_lock+0x54>
			panic("%e\n", r);
  8011a5:	50                   	push   %eax
  8011a6:	68 72 28 80 00       	push   $0x802872
  8011ab:	68 02 01 00 00       	push   $0x102
  8011b0:	68 fa 27 80 00       	push   $0x8027fa
  8011b5:	e8 0f 0e 00 00       	call   801fc9 <_panic>
		}
		sys_yield();
  8011ba:	e8 a1 f9 ff ff       	call   800b60 <sys_yield>
  8011bf:	eb 08                	jmp    8011c9 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8011c1:	e8 7b f9 ff ff       	call   800b41 <sys_getenvid>
  8011c6:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8011c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8011d8:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8011dc:	74 36                	je     801214 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8011de:	83 ec 0c             	sub    $0xc,%esp
  8011e1:	8d 43 04             	lea    0x4(%ebx),%eax
  8011e4:	50                   	push   %eax
  8011e5:	e8 4d ff ff ff       	call   801137 <queue_pop>
  8011ea:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8011ed:	83 c4 08             	add    $0x8,%esp
  8011f0:	6a 02                	push   $0x2
  8011f2:	50                   	push   %eax
  8011f3:	e8 4e fa ff ff       	call   800c46 <sys_env_set_status>
		if (r < 0) {
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	79 1d                	jns    80121c <mutex_unlock+0x4e>
			panic("%e\n", r);
  8011ff:	50                   	push   %eax
  801200:	68 72 28 80 00       	push   $0x802872
  801205:	68 16 01 00 00       	push   $0x116
  80120a:	68 fa 27 80 00       	push   $0x8027fa
  80120f:	e8 b5 0d 00 00       	call   801fc9 <_panic>
  801214:	b8 00 00 00 00       	mov    $0x0,%eax
  801219:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80121c:	e8 3f f9 ff ff       	call   800b60 <sys_yield>
}
  801221:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	53                   	push   %ebx
  80122a:	83 ec 04             	sub    $0x4,%esp
  80122d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801230:	e8 0c f9 ff ff       	call   800b41 <sys_getenvid>
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	6a 07                	push   $0x7
  80123a:	53                   	push   %ebx
  80123b:	50                   	push   %eax
  80123c:	e8 3e f9 ff ff       	call   800b7f <sys_page_alloc>
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	79 15                	jns    80125d <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801248:	50                   	push   %eax
  801249:	68 5d 28 80 00       	push   $0x80285d
  80124e:	68 23 01 00 00       	push   $0x123
  801253:	68 fa 27 80 00       	push   $0x8027fa
  801258:	e8 6c 0d 00 00       	call   801fc9 <_panic>
	}	
	mtx->locked = 0;
  80125d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  801263:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80126a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  801271:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  801278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127b:	c9                   	leave  
  80127c:	c3                   	ret    

0080127d <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	56                   	push   %esi
  801281:	53                   	push   %ebx
  801282:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  801285:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  801288:	eb 20                	jmp    8012aa <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	56                   	push   %esi
  80128e:	e8 a4 fe ff ff       	call   801137 <queue_pop>
  801293:	83 c4 08             	add    $0x8,%esp
  801296:	6a 02                	push   $0x2
  801298:	50                   	push   %eax
  801299:	e8 a8 f9 ff ff       	call   800c46 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  80129e:	8b 43 04             	mov    0x4(%ebx),%eax
  8012a1:	8b 40 04             	mov    0x4(%eax),%eax
  8012a4:	89 43 04             	mov    %eax,0x4(%ebx)
  8012a7:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8012aa:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8012ae:	75 da                	jne    80128a <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8012b0:	83 ec 04             	sub    $0x4,%esp
  8012b3:	68 00 10 00 00       	push   $0x1000
  8012b8:	6a 00                	push   $0x0
  8012ba:	53                   	push   %ebx
  8012bb:	e8 01 f6 ff ff       	call   8008c1 <memset>
	mtx = NULL;
}
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c6:	5b                   	pop    %ebx
  8012c7:	5e                   	pop    %esi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d0:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d5:	c1 e8 0c             	shr    $0xc,%eax
}
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e0:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ea:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    

008012f1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012fc:	89 c2                	mov    %eax,%edx
  8012fe:	c1 ea 16             	shr    $0x16,%edx
  801301:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801308:	f6 c2 01             	test   $0x1,%dl
  80130b:	74 11                	je     80131e <fd_alloc+0x2d>
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	c1 ea 0c             	shr    $0xc,%edx
  801312:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801319:	f6 c2 01             	test   $0x1,%dl
  80131c:	75 09                	jne    801327 <fd_alloc+0x36>
			*fd_store = fd;
  80131e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801320:	b8 00 00 00 00       	mov    $0x0,%eax
  801325:	eb 17                	jmp    80133e <fd_alloc+0x4d>
  801327:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80132c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801331:	75 c9                	jne    8012fc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801333:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801339:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801346:	83 f8 1f             	cmp    $0x1f,%eax
  801349:	77 36                	ja     801381 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80134b:	c1 e0 0c             	shl    $0xc,%eax
  80134e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801353:	89 c2                	mov    %eax,%edx
  801355:	c1 ea 16             	shr    $0x16,%edx
  801358:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135f:	f6 c2 01             	test   $0x1,%dl
  801362:	74 24                	je     801388 <fd_lookup+0x48>
  801364:	89 c2                	mov    %eax,%edx
  801366:	c1 ea 0c             	shr    $0xc,%edx
  801369:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801370:	f6 c2 01             	test   $0x1,%dl
  801373:	74 1a                	je     80138f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801375:	8b 55 0c             	mov    0xc(%ebp),%edx
  801378:	89 02                	mov    %eax,(%edx)
	return 0;
  80137a:	b8 00 00 00 00       	mov    $0x0,%eax
  80137f:	eb 13                	jmp    801394 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801381:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801386:	eb 0c                	jmp    801394 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801388:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138d:	eb 05                	jmp    801394 <fd_lookup+0x54>
  80138f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139f:	ba f4 28 80 00       	mov    $0x8028f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a4:	eb 13                	jmp    8013b9 <dev_lookup+0x23>
  8013a6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013a9:	39 08                	cmp    %ecx,(%eax)
  8013ab:	75 0c                	jne    8013b9 <dev_lookup+0x23>
			*dev = devtab[i];
  8013ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b7:	eb 31                	jmp    8013ea <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013b9:	8b 02                	mov    (%edx),%eax
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	75 e7                	jne    8013a6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8013ca:	83 ec 04             	sub    $0x4,%esp
  8013cd:	51                   	push   %ecx
  8013ce:	50                   	push   %eax
  8013cf:	68 78 28 80 00       	push   $0x802878
  8013d4:	e8 1e ee ff ff       	call   8001f7 <cprintf>
	*dev = 0;
  8013d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	56                   	push   %esi
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 10             	sub    $0x10,%esp
  8013f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801404:	c1 e8 0c             	shr    $0xc,%eax
  801407:	50                   	push   %eax
  801408:	e8 33 ff ff ff       	call   801340 <fd_lookup>
  80140d:	83 c4 08             	add    $0x8,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	78 05                	js     801419 <fd_close+0x2d>
	    || fd != fd2)
  801414:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801417:	74 0c                	je     801425 <fd_close+0x39>
		return (must_exist ? r : 0);
  801419:	84 db                	test   %bl,%bl
  80141b:	ba 00 00 00 00       	mov    $0x0,%edx
  801420:	0f 44 c2             	cmove  %edx,%eax
  801423:	eb 41                	jmp    801466 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	ff 36                	pushl  (%esi)
  80142e:	e8 63 ff ff ff       	call   801396 <dev_lookup>
  801433:	89 c3                	mov    %eax,%ebx
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 1a                	js     801456 <fd_close+0x6a>
		if (dev->dev_close)
  80143c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801442:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801447:	85 c0                	test   %eax,%eax
  801449:	74 0b                	je     801456 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80144b:	83 ec 0c             	sub    $0xc,%esp
  80144e:	56                   	push   %esi
  80144f:	ff d0                	call   *%eax
  801451:	89 c3                	mov    %eax,%ebx
  801453:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	56                   	push   %esi
  80145a:	6a 00                	push   $0x0
  80145c:	e8 a3 f7 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	89 d8                	mov    %ebx,%eax
}
  801466:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    

0080146d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	ff 75 08             	pushl  0x8(%ebp)
  80147a:	e8 c1 fe ff ff       	call   801340 <fd_lookup>
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 10                	js     801496 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	6a 01                	push   $0x1
  80148b:	ff 75 f4             	pushl  -0xc(%ebp)
  80148e:	e8 59 ff ff ff       	call   8013ec <fd_close>
  801493:	83 c4 10             	add    $0x10,%esp
}
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <close_all>:

void
close_all(void)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	53                   	push   %ebx
  80149c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80149f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a4:	83 ec 0c             	sub    $0xc,%esp
  8014a7:	53                   	push   %ebx
  8014a8:	e8 c0 ff ff ff       	call   80146d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ad:	83 c3 01             	add    $0x1,%ebx
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	83 fb 20             	cmp    $0x20,%ebx
  8014b6:	75 ec                	jne    8014a4 <close_all+0xc>
		close(i);
}
  8014b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	57                   	push   %edi
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 2c             	sub    $0x2c,%esp
  8014c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	ff 75 08             	pushl  0x8(%ebp)
  8014d0:	e8 6b fe ff ff       	call   801340 <fd_lookup>
  8014d5:	83 c4 08             	add    $0x8,%esp
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	0f 88 c1 00 00 00    	js     8015a1 <dup+0xe4>
		return r;
	close(newfdnum);
  8014e0:	83 ec 0c             	sub    $0xc,%esp
  8014e3:	56                   	push   %esi
  8014e4:	e8 84 ff ff ff       	call   80146d <close>

	newfd = INDEX2FD(newfdnum);
  8014e9:	89 f3                	mov    %esi,%ebx
  8014eb:	c1 e3 0c             	shl    $0xc,%ebx
  8014ee:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014f4:	83 c4 04             	add    $0x4,%esp
  8014f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014fa:	e8 db fd ff ff       	call   8012da <fd2data>
  8014ff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801501:	89 1c 24             	mov    %ebx,(%esp)
  801504:	e8 d1 fd ff ff       	call   8012da <fd2data>
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80150f:	89 f8                	mov    %edi,%eax
  801511:	c1 e8 16             	shr    $0x16,%eax
  801514:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80151b:	a8 01                	test   $0x1,%al
  80151d:	74 37                	je     801556 <dup+0x99>
  80151f:	89 f8                	mov    %edi,%eax
  801521:	c1 e8 0c             	shr    $0xc,%eax
  801524:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152b:	f6 c2 01             	test   $0x1,%dl
  80152e:	74 26                	je     801556 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801530:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	25 07 0e 00 00       	and    $0xe07,%eax
  80153f:	50                   	push   %eax
  801540:	ff 75 d4             	pushl  -0x2c(%ebp)
  801543:	6a 00                	push   $0x0
  801545:	57                   	push   %edi
  801546:	6a 00                	push   $0x0
  801548:	e8 75 f6 ff ff       	call   800bc2 <sys_page_map>
  80154d:	89 c7                	mov    %eax,%edi
  80154f:	83 c4 20             	add    $0x20,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	78 2e                	js     801584 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801556:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801559:	89 d0                	mov    %edx,%eax
  80155b:	c1 e8 0c             	shr    $0xc,%eax
  80155e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801565:	83 ec 0c             	sub    $0xc,%esp
  801568:	25 07 0e 00 00       	and    $0xe07,%eax
  80156d:	50                   	push   %eax
  80156e:	53                   	push   %ebx
  80156f:	6a 00                	push   $0x0
  801571:	52                   	push   %edx
  801572:	6a 00                	push   $0x0
  801574:	e8 49 f6 ff ff       	call   800bc2 <sys_page_map>
  801579:	89 c7                	mov    %eax,%edi
  80157b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80157e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801580:	85 ff                	test   %edi,%edi
  801582:	79 1d                	jns    8015a1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	53                   	push   %ebx
  801588:	6a 00                	push   $0x0
  80158a:	e8 75 f6 ff ff       	call   800c04 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	ff 75 d4             	pushl  -0x2c(%ebp)
  801595:	6a 00                	push   $0x0
  801597:	e8 68 f6 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	89 f8                	mov    %edi,%eax
}
  8015a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5e                   	pop    %esi
  8015a6:	5f                   	pop    %edi
  8015a7:	5d                   	pop    %ebp
  8015a8:	c3                   	ret    

008015a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 14             	sub    $0x14,%esp
  8015b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	53                   	push   %ebx
  8015b8:	e8 83 fd ff ff       	call   801340 <fd_lookup>
  8015bd:	83 c4 08             	add    $0x8,%esp
  8015c0:	89 c2                	mov    %eax,%edx
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 70                	js     801636 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d0:	ff 30                	pushl  (%eax)
  8015d2:	e8 bf fd ff ff       	call   801396 <dev_lookup>
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 4f                	js     80162d <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e1:	8b 42 08             	mov    0x8(%edx),%eax
  8015e4:	83 e0 03             	and    $0x3,%eax
  8015e7:	83 f8 01             	cmp    $0x1,%eax
  8015ea:	75 24                	jne    801610 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8015f1:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8015f7:	83 ec 04             	sub    $0x4,%esp
  8015fa:	53                   	push   %ebx
  8015fb:	50                   	push   %eax
  8015fc:	68 b9 28 80 00       	push   $0x8028b9
  801601:	e8 f1 eb ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80160e:	eb 26                	jmp    801636 <read+0x8d>
	}
	if (!dev->dev_read)
  801610:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801613:	8b 40 08             	mov    0x8(%eax),%eax
  801616:	85 c0                	test   %eax,%eax
  801618:	74 17                	je     801631 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	ff 75 10             	pushl  0x10(%ebp)
  801620:	ff 75 0c             	pushl  0xc(%ebp)
  801623:	52                   	push   %edx
  801624:	ff d0                	call   *%eax
  801626:	89 c2                	mov    %eax,%edx
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb 09                	jmp    801636 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162d:	89 c2                	mov    %eax,%edx
  80162f:	eb 05                	jmp    801636 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801631:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801636:	89 d0                	mov    %edx,%eax
  801638:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	57                   	push   %edi
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	8b 7d 08             	mov    0x8(%ebp),%edi
  801649:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801651:	eb 21                	jmp    801674 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801653:	83 ec 04             	sub    $0x4,%esp
  801656:	89 f0                	mov    %esi,%eax
  801658:	29 d8                	sub    %ebx,%eax
  80165a:	50                   	push   %eax
  80165b:	89 d8                	mov    %ebx,%eax
  80165d:	03 45 0c             	add    0xc(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	57                   	push   %edi
  801662:	e8 42 ff ff ff       	call   8015a9 <read>
		if (m < 0)
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 10                	js     80167e <readn+0x41>
			return m;
		if (m == 0)
  80166e:	85 c0                	test   %eax,%eax
  801670:	74 0a                	je     80167c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801672:	01 c3                	add    %eax,%ebx
  801674:	39 f3                	cmp    %esi,%ebx
  801676:	72 db                	jb     801653 <readn+0x16>
  801678:	89 d8                	mov    %ebx,%eax
  80167a:	eb 02                	jmp    80167e <readn+0x41>
  80167c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80167e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5f                   	pop    %edi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 14             	sub    $0x14,%esp
  80168d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	53                   	push   %ebx
  801695:	e8 a6 fc ff ff       	call   801340 <fd_lookup>
  80169a:	83 c4 08             	add    $0x8,%esp
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 6b                	js     80170e <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	ff 30                	pushl  (%eax)
  8016af:	e8 e2 fc ff ff       	call   801396 <dev_lookup>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 4a                	js     801705 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c2:	75 24                	jne    8016e8 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c9:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016cf:	83 ec 04             	sub    $0x4,%esp
  8016d2:	53                   	push   %ebx
  8016d3:	50                   	push   %eax
  8016d4:	68 d5 28 80 00       	push   $0x8028d5
  8016d9:	e8 19 eb ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016e6:	eb 26                	jmp    80170e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ee:	85 d2                	test   %edx,%edx
  8016f0:	74 17                	je     801709 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f2:	83 ec 04             	sub    $0x4,%esp
  8016f5:	ff 75 10             	pushl  0x10(%ebp)
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	50                   	push   %eax
  8016fc:	ff d2                	call   *%edx
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	eb 09                	jmp    80170e <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	89 c2                	mov    %eax,%edx
  801707:	eb 05                	jmp    80170e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801709:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80170e:	89 d0                	mov    %edx,%eax
  801710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <seek>:

int
seek(int fdnum, off_t offset)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	ff 75 08             	pushl  0x8(%ebp)
  801722:	e8 19 fc ff ff       	call   801340 <fd_lookup>
  801727:	83 c4 08             	add    $0x8,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 0e                	js     80173c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80172e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801731:	8b 55 0c             	mov    0xc(%ebp),%edx
  801734:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801737:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 14             	sub    $0x14,%esp
  801745:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801748:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174b:	50                   	push   %eax
  80174c:	53                   	push   %ebx
  80174d:	e8 ee fb ff ff       	call   801340 <fd_lookup>
  801752:	83 c4 08             	add    $0x8,%esp
  801755:	89 c2                	mov    %eax,%edx
  801757:	85 c0                	test   %eax,%eax
  801759:	78 68                	js     8017c3 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175b:	83 ec 08             	sub    $0x8,%esp
  80175e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801765:	ff 30                	pushl  (%eax)
  801767:	e8 2a fc ff ff       	call   801396 <dev_lookup>
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 47                	js     8017ba <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801773:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801776:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177a:	75 24                	jne    8017a0 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80177c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801781:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801787:	83 ec 04             	sub    $0x4,%esp
  80178a:	53                   	push   %ebx
  80178b:	50                   	push   %eax
  80178c:	68 98 28 80 00       	push   $0x802898
  801791:	e8 61 ea ff ff       	call   8001f7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80179e:	eb 23                	jmp    8017c3 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a3:	8b 52 18             	mov    0x18(%edx),%edx
  8017a6:	85 d2                	test   %edx,%edx
  8017a8:	74 14                	je     8017be <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	ff 75 0c             	pushl  0xc(%ebp)
  8017b0:	50                   	push   %eax
  8017b1:	ff d2                	call   *%edx
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	eb 09                	jmp    8017c3 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ba:	89 c2                	mov    %eax,%edx
  8017bc:	eb 05                	jmp    8017c3 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c3:	89 d0                	mov    %edx,%eax
  8017c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    

008017ca <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	53                   	push   %ebx
  8017ce:	83 ec 14             	sub    $0x14,%esp
  8017d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d7:	50                   	push   %eax
  8017d8:	ff 75 08             	pushl  0x8(%ebp)
  8017db:	e8 60 fb ff ff       	call   801340 <fd_lookup>
  8017e0:	83 c4 08             	add    $0x8,%esp
  8017e3:	89 c2                	mov    %eax,%edx
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 58                	js     801841 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ef:	50                   	push   %eax
  8017f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f3:	ff 30                	pushl  (%eax)
  8017f5:	e8 9c fb ff ff       	call   801396 <dev_lookup>
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 37                	js     801838 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801804:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801808:	74 32                	je     80183c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80180a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80180d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801814:	00 00 00 
	stat->st_isdir = 0;
  801817:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80181e:	00 00 00 
	stat->st_dev = dev;
  801821:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801827:	83 ec 08             	sub    $0x8,%esp
  80182a:	53                   	push   %ebx
  80182b:	ff 75 f0             	pushl  -0x10(%ebp)
  80182e:	ff 50 14             	call   *0x14(%eax)
  801831:	89 c2                	mov    %eax,%edx
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	eb 09                	jmp    801841 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801838:	89 c2                	mov    %eax,%edx
  80183a:	eb 05                	jmp    801841 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80183c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801841:	89 d0                	mov    %edx,%eax
  801843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	6a 00                	push   $0x0
  801852:	ff 75 08             	pushl  0x8(%ebp)
  801855:	e8 e3 01 00 00       	call   801a3d <open>
  80185a:	89 c3                	mov    %eax,%ebx
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 c0                	test   %eax,%eax
  801861:	78 1b                	js     80187e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801863:	83 ec 08             	sub    $0x8,%esp
  801866:	ff 75 0c             	pushl  0xc(%ebp)
  801869:	50                   	push   %eax
  80186a:	e8 5b ff ff ff       	call   8017ca <fstat>
  80186f:	89 c6                	mov    %eax,%esi
	close(fd);
  801871:	89 1c 24             	mov    %ebx,(%esp)
  801874:	e8 f4 fb ff ff       	call   80146d <close>
	return r;
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	89 f0                	mov    %esi,%eax
}
  80187e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	56                   	push   %esi
  801889:	53                   	push   %ebx
  80188a:	89 c6                	mov    %eax,%esi
  80188c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80188e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801895:	75 12                	jne    8018a9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801897:	83 ec 0c             	sub    $0xc,%esp
  80189a:	6a 01                	push   $0x1
  80189c:	e8 da 08 00 00       	call   80217b <ipc_find_env>
  8018a1:	a3 00 40 80 00       	mov    %eax,0x804000
  8018a6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a9:	6a 07                	push   $0x7
  8018ab:	68 00 50 80 00       	push   $0x805000
  8018b0:	56                   	push   %esi
  8018b1:	ff 35 00 40 80 00    	pushl  0x804000
  8018b7:	e8 5d 08 00 00       	call   802119 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018bc:	83 c4 0c             	add    $0xc,%esp
  8018bf:	6a 00                	push   $0x0
  8018c1:	53                   	push   %ebx
  8018c2:	6a 00                	push   $0x0
  8018c4:	e8 d5 07 00 00       	call   80209e <ipc_recv>
}
  8018c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cc:	5b                   	pop    %ebx
  8018cd:	5e                   	pop    %esi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ee:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f3:	e8 8d ff ff ff       	call   801885 <fsipc>
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801900:	8b 45 08             	mov    0x8(%ebp),%eax
  801903:	8b 40 0c             	mov    0xc(%eax),%eax
  801906:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80190b:	ba 00 00 00 00       	mov    $0x0,%edx
  801910:	b8 06 00 00 00       	mov    $0x6,%eax
  801915:	e8 6b ff ff ff       	call   801885 <fsipc>
}
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	53                   	push   %ebx
  801920:	83 ec 04             	sub    $0x4,%esp
  801923:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	8b 40 0c             	mov    0xc(%eax),%eax
  80192c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801931:	ba 00 00 00 00       	mov    $0x0,%edx
  801936:	b8 05 00 00 00       	mov    $0x5,%eax
  80193b:	e8 45 ff ff ff       	call   801885 <fsipc>
  801940:	85 c0                	test   %eax,%eax
  801942:	78 2c                	js     801970 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	68 00 50 80 00       	push   $0x805000
  80194c:	53                   	push   %ebx
  80194d:	e8 2a ee ff ff       	call   80077c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801952:	a1 80 50 80 00       	mov    0x805080,%eax
  801957:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80195d:	a1 84 50 80 00       	mov    0x805084,%eax
  801962:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801970:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 0c             	sub    $0xc,%esp
  80197b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80197e:	8b 55 08             	mov    0x8(%ebp),%edx
  801981:	8b 52 0c             	mov    0xc(%edx),%edx
  801984:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80198a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80198f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801994:	0f 47 c2             	cmova  %edx,%eax
  801997:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80199c:	50                   	push   %eax
  80199d:	ff 75 0c             	pushl  0xc(%ebp)
  8019a0:	68 08 50 80 00       	push   $0x805008
  8019a5:	e8 64 ef ff ff       	call   80090e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019af:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b4:	e8 cc fe ff ff       	call   801885 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019ce:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019de:	e8 a2 fe ff ff       	call   801885 <fsipc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 4b                	js     801a34 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019e9:	39 c6                	cmp    %eax,%esi
  8019eb:	73 16                	jae    801a03 <devfile_read+0x48>
  8019ed:	68 04 29 80 00       	push   $0x802904
  8019f2:	68 0b 29 80 00       	push   $0x80290b
  8019f7:	6a 7c                	push   $0x7c
  8019f9:	68 20 29 80 00       	push   $0x802920
  8019fe:	e8 c6 05 00 00       	call   801fc9 <_panic>
	assert(r <= PGSIZE);
  801a03:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a08:	7e 16                	jle    801a20 <devfile_read+0x65>
  801a0a:	68 2b 29 80 00       	push   $0x80292b
  801a0f:	68 0b 29 80 00       	push   $0x80290b
  801a14:	6a 7d                	push   $0x7d
  801a16:	68 20 29 80 00       	push   $0x802920
  801a1b:	e8 a9 05 00 00       	call   801fc9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a20:	83 ec 04             	sub    $0x4,%esp
  801a23:	50                   	push   %eax
  801a24:	68 00 50 80 00       	push   $0x805000
  801a29:	ff 75 0c             	pushl  0xc(%ebp)
  801a2c:	e8 dd ee ff ff       	call   80090e <memmove>
	return r;
  801a31:	83 c4 10             	add    $0x10,%esp
}
  801a34:	89 d8                	mov    %ebx,%eax
  801a36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a39:	5b                   	pop    %ebx
  801a3a:	5e                   	pop    %esi
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    

00801a3d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	53                   	push   %ebx
  801a41:	83 ec 20             	sub    $0x20,%esp
  801a44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a47:	53                   	push   %ebx
  801a48:	e8 f6 ec ff ff       	call   800743 <strlen>
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a55:	7f 67                	jg     801abe <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5d:	50                   	push   %eax
  801a5e:	e8 8e f8 ff ff       	call   8012f1 <fd_alloc>
  801a63:	83 c4 10             	add    $0x10,%esp
		return r;
  801a66:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 57                	js     801ac3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	53                   	push   %ebx
  801a70:	68 00 50 80 00       	push   $0x805000
  801a75:	e8 02 ed ff ff       	call   80077c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a82:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a85:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8a:	e8 f6 fd ff ff       	call   801885 <fsipc>
  801a8f:	89 c3                	mov    %eax,%ebx
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	85 c0                	test   %eax,%eax
  801a96:	79 14                	jns    801aac <open+0x6f>
		fd_close(fd, 0);
  801a98:	83 ec 08             	sub    $0x8,%esp
  801a9b:	6a 00                	push   $0x0
  801a9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa0:	e8 47 f9 ff ff       	call   8013ec <fd_close>
		return r;
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	89 da                	mov    %ebx,%edx
  801aaa:	eb 17                	jmp    801ac3 <open+0x86>
	}

	return fd2num(fd);
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab2:	e8 13 f8 ff ff       	call   8012ca <fd2num>
  801ab7:	89 c2                	mov    %eax,%edx
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	eb 05                	jmp    801ac3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801abe:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ac3:	89 d0                	mov    %edx,%eax
  801ac5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac8:	c9                   	leave  
  801ac9:	c3                   	ret    

00801aca <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ad0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad5:	b8 08 00 00 00       	mov    $0x8,%eax
  801ada:	e8 a6 fd ff ff       	call   801885 <fsipc>
}
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	ff 75 08             	pushl  0x8(%ebp)
  801aef:	e8 e6 f7 ff ff       	call   8012da <fd2data>
  801af4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801af6:	83 c4 08             	add    $0x8,%esp
  801af9:	68 37 29 80 00       	push   $0x802937
  801afe:	53                   	push   %ebx
  801aff:	e8 78 ec ff ff       	call   80077c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b04:	8b 46 04             	mov    0x4(%esi),%eax
  801b07:	2b 06                	sub    (%esi),%eax
  801b09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b0f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b16:	00 00 00 
	stat->st_dev = &devpipe;
  801b19:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b20:	30 80 00 
	return 0;
}
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
  801b28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	53                   	push   %ebx
  801b33:	83 ec 0c             	sub    $0xc,%esp
  801b36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b39:	53                   	push   %ebx
  801b3a:	6a 00                	push   $0x0
  801b3c:	e8 c3 f0 ff ff       	call   800c04 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b41:	89 1c 24             	mov    %ebx,(%esp)
  801b44:	e8 91 f7 ff ff       	call   8012da <fd2data>
  801b49:	83 c4 08             	add    $0x8,%esp
  801b4c:	50                   	push   %eax
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 b0 f0 ff ff       	call   800c04 <sys_page_unmap>
}
  801b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	57                   	push   %edi
  801b5d:	56                   	push   %esi
  801b5e:	53                   	push   %ebx
  801b5f:	83 ec 1c             	sub    $0x1c,%esp
  801b62:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b65:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b67:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6c:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	ff 75 e0             	pushl  -0x20(%ebp)
  801b78:	e8 43 06 00 00       	call   8021c0 <pageref>
  801b7d:	89 c3                	mov    %eax,%ebx
  801b7f:	89 3c 24             	mov    %edi,(%esp)
  801b82:	e8 39 06 00 00       	call   8021c0 <pageref>
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	39 c3                	cmp    %eax,%ebx
  801b8c:	0f 94 c1             	sete   %cl
  801b8f:	0f b6 c9             	movzbl %cl,%ecx
  801b92:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b95:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b9b:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801ba1:	39 ce                	cmp    %ecx,%esi
  801ba3:	74 1e                	je     801bc3 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ba5:	39 c3                	cmp    %eax,%ebx
  801ba7:	75 be                	jne    801b67 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ba9:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801baf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb2:	50                   	push   %eax
  801bb3:	56                   	push   %esi
  801bb4:	68 3e 29 80 00       	push   $0x80293e
  801bb9:	e8 39 e6 ff ff       	call   8001f7 <cprintf>
  801bbe:	83 c4 10             	add    $0x10,%esp
  801bc1:	eb a4                	jmp    801b67 <_pipeisclosed+0xe>
	}
}
  801bc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc9:	5b                   	pop    %ebx
  801bca:	5e                   	pop    %esi
  801bcb:	5f                   	pop    %edi
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 28             	sub    $0x28,%esp
  801bd7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bda:	56                   	push   %esi
  801bdb:	e8 fa f6 ff ff       	call   8012da <fd2data>
  801be0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	bf 00 00 00 00       	mov    $0x0,%edi
  801bea:	eb 4b                	jmp    801c37 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bec:	89 da                	mov    %ebx,%edx
  801bee:	89 f0                	mov    %esi,%eax
  801bf0:	e8 64 ff ff ff       	call   801b59 <_pipeisclosed>
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	75 48                	jne    801c41 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bf9:	e8 62 ef ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bfe:	8b 43 04             	mov    0x4(%ebx),%eax
  801c01:	8b 0b                	mov    (%ebx),%ecx
  801c03:	8d 51 20             	lea    0x20(%ecx),%edx
  801c06:	39 d0                	cmp    %edx,%eax
  801c08:	73 e2                	jae    801bec <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c11:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c14:	89 c2                	mov    %eax,%edx
  801c16:	c1 fa 1f             	sar    $0x1f,%edx
  801c19:	89 d1                	mov    %edx,%ecx
  801c1b:	c1 e9 1b             	shr    $0x1b,%ecx
  801c1e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c21:	83 e2 1f             	and    $0x1f,%edx
  801c24:	29 ca                	sub    %ecx,%edx
  801c26:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c2a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c2e:	83 c0 01             	add    $0x1,%eax
  801c31:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c34:	83 c7 01             	add    $0x1,%edi
  801c37:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c3a:	75 c2                	jne    801bfe <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c3c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3f:	eb 05                	jmp    801c46 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c41:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c49:	5b                   	pop    %ebx
  801c4a:	5e                   	pop    %esi
  801c4b:	5f                   	pop    %edi
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	83 ec 18             	sub    $0x18,%esp
  801c57:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c5a:	57                   	push   %edi
  801c5b:	e8 7a f6 ff ff       	call   8012da <fd2data>
  801c60:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6a:	eb 3d                	jmp    801ca9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c6c:	85 db                	test   %ebx,%ebx
  801c6e:	74 04                	je     801c74 <devpipe_read+0x26>
				return i;
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	eb 44                	jmp    801cb8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c74:	89 f2                	mov    %esi,%edx
  801c76:	89 f8                	mov    %edi,%eax
  801c78:	e8 dc fe ff ff       	call   801b59 <_pipeisclosed>
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	75 32                	jne    801cb3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c81:	e8 da ee ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c86:	8b 06                	mov    (%esi),%eax
  801c88:	3b 46 04             	cmp    0x4(%esi),%eax
  801c8b:	74 df                	je     801c6c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c8d:	99                   	cltd   
  801c8e:	c1 ea 1b             	shr    $0x1b,%edx
  801c91:	01 d0                	add    %edx,%eax
  801c93:	83 e0 1f             	and    $0x1f,%eax
  801c96:	29 d0                	sub    %edx,%eax
  801c98:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ca3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca6:	83 c3 01             	add    $0x1,%ebx
  801ca9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cac:	75 d8                	jne    801c86 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cae:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb1:	eb 05                	jmp    801cb8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbb:	5b                   	pop    %ebx
  801cbc:	5e                   	pop    %esi
  801cbd:	5f                   	pop    %edi
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    

00801cc0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccb:	50                   	push   %eax
  801ccc:	e8 20 f6 ff ff       	call   8012f1 <fd_alloc>
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	89 c2                	mov    %eax,%edx
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	0f 88 2c 01 00 00    	js     801e0a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cde:	83 ec 04             	sub    $0x4,%esp
  801ce1:	68 07 04 00 00       	push   $0x407
  801ce6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce9:	6a 00                	push   $0x0
  801ceb:	e8 8f ee ff ff       	call   800b7f <sys_page_alloc>
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	89 c2                	mov    %eax,%edx
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	0f 88 0d 01 00 00    	js     801e0a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d03:	50                   	push   %eax
  801d04:	e8 e8 f5 ff ff       	call   8012f1 <fd_alloc>
  801d09:	89 c3                	mov    %eax,%ebx
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	0f 88 e2 00 00 00    	js     801df8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d16:	83 ec 04             	sub    $0x4,%esp
  801d19:	68 07 04 00 00       	push   $0x407
  801d1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d21:	6a 00                	push   $0x0
  801d23:	e8 57 ee ff ff       	call   800b7f <sys_page_alloc>
  801d28:	89 c3                	mov    %eax,%ebx
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	0f 88 c3 00 00 00    	js     801df8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d35:	83 ec 0c             	sub    $0xc,%esp
  801d38:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3b:	e8 9a f5 ff ff       	call   8012da <fd2data>
  801d40:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d42:	83 c4 0c             	add    $0xc,%esp
  801d45:	68 07 04 00 00       	push   $0x407
  801d4a:	50                   	push   %eax
  801d4b:	6a 00                	push   $0x0
  801d4d:	e8 2d ee ff ff       	call   800b7f <sys_page_alloc>
  801d52:	89 c3                	mov    %eax,%ebx
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 c0                	test   %eax,%eax
  801d59:	0f 88 89 00 00 00    	js     801de8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5f:	83 ec 0c             	sub    $0xc,%esp
  801d62:	ff 75 f0             	pushl  -0x10(%ebp)
  801d65:	e8 70 f5 ff ff       	call   8012da <fd2data>
  801d6a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d71:	50                   	push   %eax
  801d72:	6a 00                	push   $0x0
  801d74:	56                   	push   %esi
  801d75:	6a 00                	push   $0x0
  801d77:	e8 46 ee ff ff       	call   800bc2 <sys_page_map>
  801d7c:	89 c3                	mov    %eax,%ebx
  801d7e:	83 c4 20             	add    $0x20,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	78 55                	js     801dda <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d85:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d93:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d9a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801daf:	83 ec 0c             	sub    $0xc,%esp
  801db2:	ff 75 f4             	pushl  -0xc(%ebp)
  801db5:	e8 10 f5 ff ff       	call   8012ca <fd2num>
  801dba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dbf:	83 c4 04             	add    $0x4,%esp
  801dc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc5:	e8 00 f5 ff ff       	call   8012ca <fd2num>
  801dca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dcd:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd8:	eb 30                	jmp    801e0a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dda:	83 ec 08             	sub    $0x8,%esp
  801ddd:	56                   	push   %esi
  801dde:	6a 00                	push   $0x0
  801de0:	e8 1f ee ff ff       	call   800c04 <sys_page_unmap>
  801de5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dee:	6a 00                	push   $0x0
  801df0:	e8 0f ee ff ff       	call   800c04 <sys_page_unmap>
  801df5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801df8:	83 ec 08             	sub    $0x8,%esp
  801dfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 ff ed ff ff       	call   800c04 <sys_page_unmap>
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    

00801e13 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1c:	50                   	push   %eax
  801e1d:	ff 75 08             	pushl  0x8(%ebp)
  801e20:	e8 1b f5 ff ff       	call   801340 <fd_lookup>
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	78 18                	js     801e44 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e2c:	83 ec 0c             	sub    $0xc,%esp
  801e2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e32:	e8 a3 f4 ff ff       	call   8012da <fd2data>
	return _pipeisclosed(fd, p);
  801e37:	89 c2                	mov    %eax,%edx
  801e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3c:	e8 18 fd ff ff       	call   801b59 <_pipeisclosed>
  801e41:	83 c4 10             	add    $0x10,%esp
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e56:	68 56 29 80 00       	push   $0x802956
  801e5b:	ff 75 0c             	pushl  0xc(%ebp)
  801e5e:	e8 19 e9 ff ff       	call   80077c <strcpy>
	return 0;
}
  801e63:	b8 00 00 00 00       	mov    $0x0,%eax
  801e68:	c9                   	leave  
  801e69:	c3                   	ret    

00801e6a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	57                   	push   %edi
  801e6e:	56                   	push   %esi
  801e6f:	53                   	push   %ebx
  801e70:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e76:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e7b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e81:	eb 2d                	jmp    801eb0 <devcons_write+0x46>
		m = n - tot;
  801e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e86:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e88:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e8b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e90:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e93:	83 ec 04             	sub    $0x4,%esp
  801e96:	53                   	push   %ebx
  801e97:	03 45 0c             	add    0xc(%ebp),%eax
  801e9a:	50                   	push   %eax
  801e9b:	57                   	push   %edi
  801e9c:	e8 6d ea ff ff       	call   80090e <memmove>
		sys_cputs(buf, m);
  801ea1:	83 c4 08             	add    $0x8,%esp
  801ea4:	53                   	push   %ebx
  801ea5:	57                   	push   %edi
  801ea6:	e8 18 ec ff ff       	call   800ac3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eab:	01 de                	add    %ebx,%esi
  801ead:	83 c4 10             	add    $0x10,%esp
  801eb0:	89 f0                	mov    %esi,%eax
  801eb2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb5:	72 cc                	jb     801e83 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801eb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5f                   	pop    %edi
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	83 ec 08             	sub    $0x8,%esp
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801eca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ece:	74 2a                	je     801efa <devcons_read+0x3b>
  801ed0:	eb 05                	jmp    801ed7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ed2:	e8 89 ec ff ff       	call   800b60 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ed7:	e8 05 ec ff ff       	call   800ae1 <sys_cgetc>
  801edc:	85 c0                	test   %eax,%eax
  801ede:	74 f2                	je     801ed2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 16                	js     801efa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ee4:	83 f8 04             	cmp    $0x4,%eax
  801ee7:	74 0c                	je     801ef5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ee9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eec:	88 02                	mov    %al,(%edx)
	return 1;
  801eee:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef3:	eb 05                	jmp    801efa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ef5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f02:	8b 45 08             	mov    0x8(%ebp),%eax
  801f05:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f08:	6a 01                	push   $0x1
  801f0a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f0d:	50                   	push   %eax
  801f0e:	e8 b0 eb ff ff       	call   800ac3 <sys_cputs>
}
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	c9                   	leave  
  801f17:	c3                   	ret    

00801f18 <getchar>:

int
getchar(void)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f1e:	6a 01                	push   $0x1
  801f20:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f23:	50                   	push   %eax
  801f24:	6a 00                	push   $0x0
  801f26:	e8 7e f6 ff ff       	call   8015a9 <read>
	if (r < 0)
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	78 0f                	js     801f41 <getchar+0x29>
		return r;
	if (r < 1)
  801f32:	85 c0                	test   %eax,%eax
  801f34:	7e 06                	jle    801f3c <getchar+0x24>
		return -E_EOF;
	return c;
  801f36:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f3a:	eb 05                	jmp    801f41 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f3c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f41:	c9                   	leave  
  801f42:	c3                   	ret    

00801f43 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4c:	50                   	push   %eax
  801f4d:	ff 75 08             	pushl  0x8(%ebp)
  801f50:	e8 eb f3 ff ff       	call   801340 <fd_lookup>
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	78 11                	js     801f6d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f65:	39 10                	cmp    %edx,(%eax)
  801f67:	0f 94 c0             	sete   %al
  801f6a:	0f b6 c0             	movzbl %al,%eax
}
  801f6d:	c9                   	leave  
  801f6e:	c3                   	ret    

00801f6f <opencons>:

int
opencons(void)
{
  801f6f:	55                   	push   %ebp
  801f70:	89 e5                	mov    %esp,%ebp
  801f72:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f78:	50                   	push   %eax
  801f79:	e8 73 f3 ff ff       	call   8012f1 <fd_alloc>
  801f7e:	83 c4 10             	add    $0x10,%esp
		return r;
  801f81:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f83:	85 c0                	test   %eax,%eax
  801f85:	78 3e                	js     801fc5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f87:	83 ec 04             	sub    $0x4,%esp
  801f8a:	68 07 04 00 00       	push   $0x407
  801f8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f92:	6a 00                	push   $0x0
  801f94:	e8 e6 eb ff ff       	call   800b7f <sys_page_alloc>
  801f99:	83 c4 10             	add    $0x10,%esp
		return r;
  801f9c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	78 23                	js     801fc5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fa2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fab:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb7:	83 ec 0c             	sub    $0xc,%esp
  801fba:	50                   	push   %eax
  801fbb:	e8 0a f3 ff ff       	call   8012ca <fd2num>
  801fc0:	89 c2                	mov    %eax,%edx
  801fc2:	83 c4 10             	add    $0x10,%esp
}
  801fc5:	89 d0                	mov    %edx,%eax
  801fc7:	c9                   	leave  
  801fc8:	c3                   	ret    

00801fc9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fd1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fd7:	e8 65 eb ff ff       	call   800b41 <sys_getenvid>
  801fdc:	83 ec 0c             	sub    $0xc,%esp
  801fdf:	ff 75 0c             	pushl  0xc(%ebp)
  801fe2:	ff 75 08             	pushl  0x8(%ebp)
  801fe5:	56                   	push   %esi
  801fe6:	50                   	push   %eax
  801fe7:	68 64 29 80 00       	push   $0x802964
  801fec:	e8 06 e2 ff ff       	call   8001f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ff1:	83 c4 18             	add    $0x18,%esp
  801ff4:	53                   	push   %ebx
  801ff5:	ff 75 10             	pushl  0x10(%ebp)
  801ff8:	e8 a9 e1 ff ff       	call   8001a6 <vcprintf>
	cprintf("\n");
  801ffd:	c7 04 24 5b 28 80 00 	movl   $0x80285b,(%esp)
  802004:	e8 ee e1 ff ff       	call   8001f7 <cprintf>
  802009:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80200c:	cc                   	int3   
  80200d:	eb fd                	jmp    80200c <_panic+0x43>

0080200f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802015:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80201c:	75 2a                	jne    802048 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80201e:	83 ec 04             	sub    $0x4,%esp
  802021:	6a 07                	push   $0x7
  802023:	68 00 f0 bf ee       	push   $0xeebff000
  802028:	6a 00                	push   $0x0
  80202a:	e8 50 eb ff ff       	call   800b7f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	85 c0                	test   %eax,%eax
  802034:	79 12                	jns    802048 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802036:	50                   	push   %eax
  802037:	68 72 28 80 00       	push   $0x802872
  80203c:	6a 23                	push   $0x23
  80203e:	68 88 29 80 00       	push   $0x802988
  802043:	e8 81 ff ff ff       	call   801fc9 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802048:	8b 45 08             	mov    0x8(%ebp),%eax
  80204b:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802050:	83 ec 08             	sub    $0x8,%esp
  802053:	68 7a 20 80 00       	push   $0x80207a
  802058:	6a 00                	push   $0x0
  80205a:	e8 6b ec ff ff       	call   800cca <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80205f:	83 c4 10             	add    $0x10,%esp
  802062:	85 c0                	test   %eax,%eax
  802064:	79 12                	jns    802078 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802066:	50                   	push   %eax
  802067:	68 72 28 80 00       	push   $0x802872
  80206c:	6a 2c                	push   $0x2c
  80206e:	68 88 29 80 00       	push   $0x802988
  802073:	e8 51 ff ff ff       	call   801fc9 <_panic>
	}
}
  802078:	c9                   	leave  
  802079:	c3                   	ret    

0080207a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80207a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80207b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802080:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802082:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802085:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802089:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80208e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802092:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802094:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802097:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802098:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80209b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80209c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80209d:	c3                   	ret    

0080209e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	56                   	push   %esi
  8020a2:	53                   	push   %ebx
  8020a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8020a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	75 12                	jne    8020c2 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	68 00 00 c0 ee       	push   $0xeec00000
  8020b8:	e8 72 ec ff ff       	call   800d2f <sys_ipc_recv>
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	eb 0c                	jmp    8020ce <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020c2:	83 ec 0c             	sub    $0xc,%esp
  8020c5:	50                   	push   %eax
  8020c6:	e8 64 ec ff ff       	call   800d2f <sys_ipc_recv>
  8020cb:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020ce:	85 f6                	test   %esi,%esi
  8020d0:	0f 95 c1             	setne  %cl
  8020d3:	85 db                	test   %ebx,%ebx
  8020d5:	0f 95 c2             	setne  %dl
  8020d8:	84 d1                	test   %dl,%cl
  8020da:	74 09                	je     8020e5 <ipc_recv+0x47>
  8020dc:	89 c2                	mov    %eax,%edx
  8020de:	c1 ea 1f             	shr    $0x1f,%edx
  8020e1:	84 d2                	test   %dl,%dl
  8020e3:	75 2d                	jne    802112 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020e5:	85 f6                	test   %esi,%esi
  8020e7:	74 0d                	je     8020f6 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ee:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8020f4:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020f6:	85 db                	test   %ebx,%ebx
  8020f8:	74 0d                	je     802107 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ff:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802105:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802107:	a1 04 40 80 00       	mov    0x804004,%eax
  80210c:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802112:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802115:	5b                   	pop    %ebx
  802116:	5e                   	pop    %esi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    

00802119 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	57                   	push   %edi
  80211d:	56                   	push   %esi
  80211e:	53                   	push   %ebx
  80211f:	83 ec 0c             	sub    $0xc,%esp
  802122:	8b 7d 08             	mov    0x8(%ebp),%edi
  802125:	8b 75 0c             	mov    0xc(%ebp),%esi
  802128:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80212b:	85 db                	test   %ebx,%ebx
  80212d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802132:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802135:	ff 75 14             	pushl  0x14(%ebp)
  802138:	53                   	push   %ebx
  802139:	56                   	push   %esi
  80213a:	57                   	push   %edi
  80213b:	e8 cc eb ff ff       	call   800d0c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802140:	89 c2                	mov    %eax,%edx
  802142:	c1 ea 1f             	shr    $0x1f,%edx
  802145:	83 c4 10             	add    $0x10,%esp
  802148:	84 d2                	test   %dl,%dl
  80214a:	74 17                	je     802163 <ipc_send+0x4a>
  80214c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80214f:	74 12                	je     802163 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802151:	50                   	push   %eax
  802152:	68 96 29 80 00       	push   $0x802996
  802157:	6a 47                	push   $0x47
  802159:	68 a4 29 80 00       	push   $0x8029a4
  80215e:	e8 66 fe ff ff       	call   801fc9 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802163:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802166:	75 07                	jne    80216f <ipc_send+0x56>
			sys_yield();
  802168:	e8 f3 e9 ff ff       	call   800b60 <sys_yield>
  80216d:	eb c6                	jmp    802135 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80216f:	85 c0                	test   %eax,%eax
  802171:	75 c2                	jne    802135 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802176:	5b                   	pop    %ebx
  802177:	5e                   	pop    %esi
  802178:	5f                   	pop    %edi
  802179:	5d                   	pop    %ebp
  80217a:	c3                   	ret    

0080217b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80217b:	55                   	push   %ebp
  80217c:	89 e5                	mov    %esp,%ebp
  80217e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802181:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802186:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80218c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802192:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802198:	39 ca                	cmp    %ecx,%edx
  80219a:	75 13                	jne    8021af <ipc_find_env+0x34>
			return envs[i].env_id;
  80219c:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8021a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021a7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8021ad:	eb 0f                	jmp    8021be <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021af:	83 c0 01             	add    $0x1,%eax
  8021b2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021b7:	75 cd                	jne    802186 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    

008021c0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	c1 e8 16             	shr    $0x16,%eax
  8021cb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021d2:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d7:	f6 c1 01             	test   $0x1,%cl
  8021da:	74 1d                	je     8021f9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021dc:	c1 ea 0c             	shr    $0xc,%edx
  8021df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021e6:	f6 c2 01             	test   $0x1,%dl
  8021e9:	74 0e                	je     8021f9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021eb:	c1 ea 0c             	shr    $0xc,%edx
  8021ee:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021f5:	ef 
  8021f6:	0f b7 c0             	movzwl %ax,%eax
}
  8021f9:	5d                   	pop    %ebp
  8021fa:	c3                   	ret    
  8021fb:	66 90                	xchg   %ax,%ax
  8021fd:	66 90                	xchg   %ax,%ax
  8021ff:	90                   	nop

00802200 <__udivdi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80220b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80220f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 f6                	test   %esi,%esi
  802219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80221d:	89 ca                	mov    %ecx,%edx
  80221f:	89 f8                	mov    %edi,%eax
  802221:	75 3d                	jne    802260 <__udivdi3+0x60>
  802223:	39 cf                	cmp    %ecx,%edi
  802225:	0f 87 c5 00 00 00    	ja     8022f0 <__udivdi3+0xf0>
  80222b:	85 ff                	test   %edi,%edi
  80222d:	89 fd                	mov    %edi,%ebp
  80222f:	75 0b                	jne    80223c <__udivdi3+0x3c>
  802231:	b8 01 00 00 00       	mov    $0x1,%eax
  802236:	31 d2                	xor    %edx,%edx
  802238:	f7 f7                	div    %edi
  80223a:	89 c5                	mov    %eax,%ebp
  80223c:	89 c8                	mov    %ecx,%eax
  80223e:	31 d2                	xor    %edx,%edx
  802240:	f7 f5                	div    %ebp
  802242:	89 c1                	mov    %eax,%ecx
  802244:	89 d8                	mov    %ebx,%eax
  802246:	89 cf                	mov    %ecx,%edi
  802248:	f7 f5                	div    %ebp
  80224a:	89 c3                	mov    %eax,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	39 ce                	cmp    %ecx,%esi
  802262:	77 74                	ja     8022d8 <__udivdi3+0xd8>
  802264:	0f bd fe             	bsr    %esi,%edi
  802267:	83 f7 1f             	xor    $0x1f,%edi
  80226a:	0f 84 98 00 00 00    	je     802308 <__udivdi3+0x108>
  802270:	bb 20 00 00 00       	mov    $0x20,%ebx
  802275:	89 f9                	mov    %edi,%ecx
  802277:	89 c5                	mov    %eax,%ebp
  802279:	29 fb                	sub    %edi,%ebx
  80227b:	d3 e6                	shl    %cl,%esi
  80227d:	89 d9                	mov    %ebx,%ecx
  80227f:	d3 ed                	shr    %cl,%ebp
  802281:	89 f9                	mov    %edi,%ecx
  802283:	d3 e0                	shl    %cl,%eax
  802285:	09 ee                	or     %ebp,%esi
  802287:	89 d9                	mov    %ebx,%ecx
  802289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80228d:	89 d5                	mov    %edx,%ebp
  80228f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802293:	d3 ed                	shr    %cl,%ebp
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e2                	shl    %cl,%edx
  802299:	89 d9                	mov    %ebx,%ecx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	09 c2                	or     %eax,%edx
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	89 ea                	mov    %ebp,%edx
  8022a3:	f7 f6                	div    %esi
  8022a5:	89 d5                	mov    %edx,%ebp
  8022a7:	89 c3                	mov    %eax,%ebx
  8022a9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	72 10                	jb     8022c1 <__udivdi3+0xc1>
  8022b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e6                	shl    %cl,%esi
  8022b9:	39 c6                	cmp    %eax,%esi
  8022bb:	73 07                	jae    8022c4 <__udivdi3+0xc4>
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	75 03                	jne    8022c4 <__udivdi3+0xc4>
  8022c1:	83 eb 01             	sub    $0x1,%ebx
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 d8                	mov    %ebx,%eax
  8022c8:	89 fa                	mov    %edi,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	31 ff                	xor    %edi,%edi
  8022da:	31 db                	xor    %ebx,%ebx
  8022dc:	89 d8                	mov    %ebx,%eax
  8022de:	89 fa                	mov    %edi,%edx
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	89 d8                	mov    %ebx,%eax
  8022f2:	f7 f7                	div    %edi
  8022f4:	31 ff                	xor    %edi,%edi
  8022f6:	89 c3                	mov    %eax,%ebx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 fa                	mov    %edi,%edx
  8022fc:	83 c4 1c             	add    $0x1c,%esp
  8022ff:	5b                   	pop    %ebx
  802300:	5e                   	pop    %esi
  802301:	5f                   	pop    %edi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	39 ce                	cmp    %ecx,%esi
  80230a:	72 0c                	jb     802318 <__udivdi3+0x118>
  80230c:	31 db                	xor    %ebx,%ebx
  80230e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802312:	0f 87 34 ff ff ff    	ja     80224c <__udivdi3+0x4c>
  802318:	bb 01 00 00 00       	mov    $0x1,%ebx
  80231d:	e9 2a ff ff ff       	jmp    80224c <__udivdi3+0x4c>
  802322:	66 90                	xchg   %ax,%ax
  802324:	66 90                	xchg   %ax,%ax
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__umoddi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	53                   	push   %ebx
  802334:	83 ec 1c             	sub    $0x1c,%esp
  802337:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80233b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80233f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802347:	85 d2                	test   %edx,%edx
  802349:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80234d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802351:	89 f3                	mov    %esi,%ebx
  802353:	89 3c 24             	mov    %edi,(%esp)
  802356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80235a:	75 1c                	jne    802378 <__umoddi3+0x48>
  80235c:	39 f7                	cmp    %esi,%edi
  80235e:	76 50                	jbe    8023b0 <__umoddi3+0x80>
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	f7 f7                	div    %edi
  802366:	89 d0                	mov    %edx,%eax
  802368:	31 d2                	xor    %edx,%edx
  80236a:	83 c4 1c             	add    $0x1c,%esp
  80236d:	5b                   	pop    %ebx
  80236e:	5e                   	pop    %esi
  80236f:	5f                   	pop    %edi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
  802372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802378:	39 f2                	cmp    %esi,%edx
  80237a:	89 d0                	mov    %edx,%eax
  80237c:	77 52                	ja     8023d0 <__umoddi3+0xa0>
  80237e:	0f bd ea             	bsr    %edx,%ebp
  802381:	83 f5 1f             	xor    $0x1f,%ebp
  802384:	75 5a                	jne    8023e0 <__umoddi3+0xb0>
  802386:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80238a:	0f 82 e0 00 00 00    	jb     802470 <__umoddi3+0x140>
  802390:	39 0c 24             	cmp    %ecx,(%esp)
  802393:	0f 86 d7 00 00 00    	jbe    802470 <__umoddi3+0x140>
  802399:	8b 44 24 08          	mov    0x8(%esp),%eax
  80239d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023a1:	83 c4 1c             	add    $0x1c,%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5e                   	pop    %esi
  8023a6:	5f                   	pop    %edi
  8023a7:	5d                   	pop    %ebp
  8023a8:	c3                   	ret    
  8023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	85 ff                	test   %edi,%edi
  8023b2:	89 fd                	mov    %edi,%ebp
  8023b4:	75 0b                	jne    8023c1 <__umoddi3+0x91>
  8023b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	f7 f7                	div    %edi
  8023bf:	89 c5                	mov    %eax,%ebp
  8023c1:	89 f0                	mov    %esi,%eax
  8023c3:	31 d2                	xor    %edx,%edx
  8023c5:	f7 f5                	div    %ebp
  8023c7:	89 c8                	mov    %ecx,%eax
  8023c9:	f7 f5                	div    %ebp
  8023cb:	89 d0                	mov    %edx,%eax
  8023cd:	eb 99                	jmp    802368 <__umoddi3+0x38>
  8023cf:	90                   	nop
  8023d0:	89 c8                	mov    %ecx,%eax
  8023d2:	89 f2                	mov    %esi,%edx
  8023d4:	83 c4 1c             	add    $0x1c,%esp
  8023d7:	5b                   	pop    %ebx
  8023d8:	5e                   	pop    %esi
  8023d9:	5f                   	pop    %edi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	8b 34 24             	mov    (%esp),%esi
  8023e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023e8:	89 e9                	mov    %ebp,%ecx
  8023ea:	29 ef                	sub    %ebp,%edi
  8023ec:	d3 e0                	shl    %cl,%eax
  8023ee:	89 f9                	mov    %edi,%ecx
  8023f0:	89 f2                	mov    %esi,%edx
  8023f2:	d3 ea                	shr    %cl,%edx
  8023f4:	89 e9                	mov    %ebp,%ecx
  8023f6:	09 c2                	or     %eax,%edx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 14 24             	mov    %edx,(%esp)
  8023fd:	89 f2                	mov    %esi,%edx
  8023ff:	d3 e2                	shl    %cl,%edx
  802401:	89 f9                	mov    %edi,%ecx
  802403:	89 54 24 04          	mov    %edx,0x4(%esp)
  802407:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80240b:	d3 e8                	shr    %cl,%eax
  80240d:	89 e9                	mov    %ebp,%ecx
  80240f:	89 c6                	mov    %eax,%esi
  802411:	d3 e3                	shl    %cl,%ebx
  802413:	89 f9                	mov    %edi,%ecx
  802415:	89 d0                	mov    %edx,%eax
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 e9                	mov    %ebp,%ecx
  80241b:	09 d8                	or     %ebx,%eax
  80241d:	89 d3                	mov    %edx,%ebx
  80241f:	89 f2                	mov    %esi,%edx
  802421:	f7 34 24             	divl   (%esp)
  802424:	89 d6                	mov    %edx,%esi
  802426:	d3 e3                	shl    %cl,%ebx
  802428:	f7 64 24 04          	mull   0x4(%esp)
  80242c:	39 d6                	cmp    %edx,%esi
  80242e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802432:	89 d1                	mov    %edx,%ecx
  802434:	89 c3                	mov    %eax,%ebx
  802436:	72 08                	jb     802440 <__umoddi3+0x110>
  802438:	75 11                	jne    80244b <__umoddi3+0x11b>
  80243a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80243e:	73 0b                	jae    80244b <__umoddi3+0x11b>
  802440:	2b 44 24 04          	sub    0x4(%esp),%eax
  802444:	1b 14 24             	sbb    (%esp),%edx
  802447:	89 d1                	mov    %edx,%ecx
  802449:	89 c3                	mov    %eax,%ebx
  80244b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80244f:	29 da                	sub    %ebx,%edx
  802451:	19 ce                	sbb    %ecx,%esi
  802453:	89 f9                	mov    %edi,%ecx
  802455:	89 f0                	mov    %esi,%eax
  802457:	d3 e0                	shl    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	d3 ea                	shr    %cl,%edx
  80245d:	89 e9                	mov    %ebp,%ecx
  80245f:	d3 ee                	shr    %cl,%esi
  802461:	09 d0                	or     %edx,%eax
  802463:	89 f2                	mov    %esi,%edx
  802465:	83 c4 1c             	add    $0x1c,%esp
  802468:	5b                   	pop    %ebx
  802469:	5e                   	pop    %esi
  80246a:	5f                   	pop    %edi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	8d 76 00             	lea    0x0(%esi),%esi
  802470:	29 f9                	sub    %edi,%ecx
  802472:	19 d6                	sbb    %edx,%esi
  802474:	89 74 24 04          	mov    %esi,0x4(%esp)
  802478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80247c:	e9 18 ff ff ff       	jmp    802399 <__umoddi3+0x69>
