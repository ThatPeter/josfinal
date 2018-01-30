
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
  800150:	e8 47 13 00 00       	call   80149c <close_all>
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
  800b34:	e8 94 14 00 00       	call   801fcd <_panic>

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
  800bb5:	e8 13 14 00 00       	call   801fcd <_panic>

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
  800bf7:	e8 d1 13 00 00       	call   801fcd <_panic>

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
  800c39:	e8 8f 13 00 00       	call   801fcd <_panic>

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
  800c7b:	e8 4d 13 00 00       	call   801fcd <_panic>

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
  800cbd:	e8 0b 13 00 00       	call   801fcd <_panic>
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
  800cff:	e8 c9 12 00 00       	call   801fcd <_panic>

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
  800d63:	e8 65 12 00 00       	call   801fcd <_panic>

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
  800e02:	e8 c6 11 00 00       	call   801fcd <_panic>
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
  800e2c:	e8 9c 11 00 00       	call   801fcd <_panic>
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
  800e74:	e8 54 11 00 00       	call   801fcd <_panic>
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
  800e9c:	e8 2c 11 00 00       	call   801fcd <_panic>
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
  800eb4:	e8 5a 11 00 00       	call   802013 <set_pgfault_handler>
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
  800edc:	e8 ec 10 00 00       	call   801fcd <_panic>
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
  800f95:	e8 33 10 00 00       	call   801fcd <_panic>
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
  800fda:	e8 ee 0f 00 00       	call   801fcd <_panic>
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
  801008:	e8 c0 0f 00 00       	call   801fcd <_panic>
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
  801032:	e8 96 0f 00 00       	call   801fcd <_panic>
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
  8010f2:	e8 d6 0e 00 00       	call   801fcd <_panic>
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
  801158:	e8 70 0e 00 00       	call   801fcd <_panic>
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
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80116e:	b8 01 00 00 00       	mov    $0x1,%eax
  801173:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801176:	85 c0                	test   %eax,%eax
  801178:	74 4a                	je     8011c4 <mutex_lock+0x5e>
  80117a:	8b 73 04             	mov    0x4(%ebx),%esi
  80117d:	83 3e 00             	cmpl   $0x0,(%esi)
  801180:	75 42                	jne    8011c4 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  801182:	e8 ba f9 ff ff       	call   800b41 <sys_getenvid>
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	56                   	push   %esi
  80118b:	50                   	push   %eax
  80118c:	e8 32 ff ff ff       	call   8010c3 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801191:	e8 ab f9 ff ff       	call   800b41 <sys_getenvid>
  801196:	83 c4 08             	add    $0x8,%esp
  801199:	6a 04                	push   $0x4
  80119b:	50                   	push   %eax
  80119c:	e8 a5 fa ff ff       	call   800c46 <sys_env_set_status>

		if (r < 0) {
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	79 15                	jns    8011bd <mutex_lock+0x57>
			panic("%e\n", r);
  8011a8:	50                   	push   %eax
  8011a9:	68 72 28 80 00       	push   $0x802872
  8011ae:	68 02 01 00 00       	push   $0x102
  8011b3:	68 fa 27 80 00       	push   $0x8027fa
  8011b8:	e8 10 0e 00 00       	call   801fcd <_panic>
		}
		sys_yield();
  8011bd:	e8 9e f9 ff ff       	call   800b60 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011c2:	eb 08                	jmp    8011cc <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8011c4:	e8 78 f9 ff ff       	call   800b41 <sys_getenvid>
  8011c9:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8011cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e2:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8011e5:	8b 43 04             	mov    0x4(%ebx),%eax
  8011e8:	83 38 00             	cmpl   $0x0,(%eax)
  8011eb:	74 33                	je     801220 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8011ed:	83 ec 0c             	sub    $0xc,%esp
  8011f0:	50                   	push   %eax
  8011f1:	e8 41 ff ff ff       	call   801137 <queue_pop>
  8011f6:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8011f9:	83 c4 08             	add    $0x8,%esp
  8011fc:	6a 02                	push   $0x2
  8011fe:	50                   	push   %eax
  8011ff:	e8 42 fa ff ff       	call   800c46 <sys_env_set_status>
		if (r < 0) {
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	79 15                	jns    801220 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80120b:	50                   	push   %eax
  80120c:	68 72 28 80 00       	push   $0x802872
  801211:	68 16 01 00 00       	push   $0x116
  801216:	68 fa 27 80 00       	push   $0x8027fa
  80121b:	e8 ad 0d 00 00       	call   801fcd <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  801220:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801223:	c9                   	leave  
  801224:	c3                   	ret    

00801225 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	53                   	push   %ebx
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80122f:	e8 0d f9 ff ff       	call   800b41 <sys_getenvid>
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	6a 07                	push   $0x7
  801239:	53                   	push   %ebx
  80123a:	50                   	push   %eax
  80123b:	e8 3f f9 ff ff       	call   800b7f <sys_page_alloc>
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	79 15                	jns    80125c <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801247:	50                   	push   %eax
  801248:	68 5d 28 80 00       	push   $0x80285d
  80124d:	68 22 01 00 00       	push   $0x122
  801252:	68 fa 27 80 00       	push   $0x8027fa
  801257:	e8 71 0d 00 00       	call   801fcd <_panic>
	}	
	mtx->locked = 0;
  80125c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801262:	8b 43 04             	mov    0x4(%ebx),%eax
  801265:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80126b:	8b 43 04             	mov    0x4(%ebx),%eax
  80126e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801275:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80127c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127f:	c9                   	leave  
  801280:	c3                   	ret    

00801281 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	53                   	push   %ebx
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  80128b:	eb 21                	jmp    8012ae <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	50                   	push   %eax
  801291:	e8 a1 fe ff ff       	call   801137 <queue_pop>
  801296:	83 c4 08             	add    $0x8,%esp
  801299:	6a 02                	push   $0x2
  80129b:	50                   	push   %eax
  80129c:	e8 a5 f9 ff ff       	call   800c46 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8012a1:	8b 43 04             	mov    0x4(%ebx),%eax
  8012a4:	8b 10                	mov    (%eax),%edx
  8012a6:	8b 52 04             	mov    0x4(%edx),%edx
  8012a9:	89 10                	mov    %edx,(%eax)
  8012ab:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8012ae:	8b 43 04             	mov    0x4(%ebx),%eax
  8012b1:	83 38 00             	cmpl   $0x0,(%eax)
  8012b4:	75 d7                	jne    80128d <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8012b6:	83 ec 04             	sub    $0x4,%esp
  8012b9:	68 00 10 00 00       	push   $0x1000
  8012be:	6a 00                	push   $0x0
  8012c0:	53                   	push   %ebx
  8012c1:	e8 fb f5 ff ff       	call   8008c1 <memset>
	mtx = NULL;
}
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    

008012ce <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d4:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d9:	c1 e8 0c             	shr    $0xc,%eax
}
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e4:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ee:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801300:	89 c2                	mov    %eax,%edx
  801302:	c1 ea 16             	shr    $0x16,%edx
  801305:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130c:	f6 c2 01             	test   $0x1,%dl
  80130f:	74 11                	je     801322 <fd_alloc+0x2d>
  801311:	89 c2                	mov    %eax,%edx
  801313:	c1 ea 0c             	shr    $0xc,%edx
  801316:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131d:	f6 c2 01             	test   $0x1,%dl
  801320:	75 09                	jne    80132b <fd_alloc+0x36>
			*fd_store = fd;
  801322:	89 01                	mov    %eax,(%ecx)
			return 0;
  801324:	b8 00 00 00 00       	mov    $0x0,%eax
  801329:	eb 17                	jmp    801342 <fd_alloc+0x4d>
  80132b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801330:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801335:	75 c9                	jne    801300 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801337:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80133d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80134a:	83 f8 1f             	cmp    $0x1f,%eax
  80134d:	77 36                	ja     801385 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80134f:	c1 e0 0c             	shl    $0xc,%eax
  801352:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801357:	89 c2                	mov    %eax,%edx
  801359:	c1 ea 16             	shr    $0x16,%edx
  80135c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801363:	f6 c2 01             	test   $0x1,%dl
  801366:	74 24                	je     80138c <fd_lookup+0x48>
  801368:	89 c2                	mov    %eax,%edx
  80136a:	c1 ea 0c             	shr    $0xc,%edx
  80136d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801374:	f6 c2 01             	test   $0x1,%dl
  801377:	74 1a                	je     801393 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801379:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137c:	89 02                	mov    %eax,(%edx)
	return 0;
  80137e:	b8 00 00 00 00       	mov    $0x0,%eax
  801383:	eb 13                	jmp    801398 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801385:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138a:	eb 0c                	jmp    801398 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801391:	eb 05                	jmp    801398 <fd_lookup+0x54>
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a3:	ba f4 28 80 00       	mov    $0x8028f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013a8:	eb 13                	jmp    8013bd <dev_lookup+0x23>
  8013aa:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ad:	39 08                	cmp    %ecx,(%eax)
  8013af:	75 0c                	jne    8013bd <dev_lookup+0x23>
			*dev = devtab[i];
  8013b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bb:	eb 31                	jmp    8013ee <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013bd:	8b 02                	mov    (%edx),%eax
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	75 e7                	jne    8013aa <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	51                   	push   %ecx
  8013d2:	50                   	push   %eax
  8013d3:	68 78 28 80 00       	push   $0x802878
  8013d8:	e8 1a ee ff ff       	call   8001f7 <cprintf>
	*dev = 0;
  8013dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    

008013f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	56                   	push   %esi
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 10             	sub    $0x10,%esp
  8013f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8013fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801408:	c1 e8 0c             	shr    $0xc,%eax
  80140b:	50                   	push   %eax
  80140c:	e8 33 ff ff ff       	call   801344 <fd_lookup>
  801411:	83 c4 08             	add    $0x8,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 05                	js     80141d <fd_close+0x2d>
	    || fd != fd2)
  801418:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80141b:	74 0c                	je     801429 <fd_close+0x39>
		return (must_exist ? r : 0);
  80141d:	84 db                	test   %bl,%bl
  80141f:	ba 00 00 00 00       	mov    $0x0,%edx
  801424:	0f 44 c2             	cmove  %edx,%eax
  801427:	eb 41                	jmp    80146a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	ff 36                	pushl  (%esi)
  801432:	e8 63 ff ff ff       	call   80139a <dev_lookup>
  801437:	89 c3                	mov    %eax,%ebx
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 1a                	js     80145a <fd_close+0x6a>
		if (dev->dev_close)
  801440:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801443:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801446:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80144b:	85 c0                	test   %eax,%eax
  80144d:	74 0b                	je     80145a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80144f:	83 ec 0c             	sub    $0xc,%esp
  801452:	56                   	push   %esi
  801453:	ff d0                	call   *%eax
  801455:	89 c3                	mov    %eax,%ebx
  801457:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	56                   	push   %esi
  80145e:	6a 00                	push   $0x0
  801460:	e8 9f f7 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	89 d8                	mov    %ebx,%eax
}
  80146a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 75 08             	pushl  0x8(%ebp)
  80147e:	e8 c1 fe ff ff       	call   801344 <fd_lookup>
  801483:	83 c4 08             	add    $0x8,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 10                	js     80149a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	6a 01                	push   $0x1
  80148f:	ff 75 f4             	pushl  -0xc(%ebp)
  801492:	e8 59 ff ff ff       	call   8013f0 <fd_close>
  801497:	83 c4 10             	add    $0x10,%esp
}
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <close_all>:

void
close_all(void)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	53                   	push   %ebx
  8014a0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a8:	83 ec 0c             	sub    $0xc,%esp
  8014ab:	53                   	push   %ebx
  8014ac:	e8 c0 ff ff ff       	call   801471 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b1:	83 c3 01             	add    $0x1,%ebx
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	83 fb 20             	cmp    $0x20,%ebx
  8014ba:	75 ec                	jne    8014a8 <close_all+0xc>
		close(i);
}
  8014bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	57                   	push   %edi
  8014c5:	56                   	push   %esi
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 2c             	sub    $0x2c,%esp
  8014ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d0:	50                   	push   %eax
  8014d1:	ff 75 08             	pushl  0x8(%ebp)
  8014d4:	e8 6b fe ff ff       	call   801344 <fd_lookup>
  8014d9:	83 c4 08             	add    $0x8,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	0f 88 c1 00 00 00    	js     8015a5 <dup+0xe4>
		return r;
	close(newfdnum);
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	56                   	push   %esi
  8014e8:	e8 84 ff ff ff       	call   801471 <close>

	newfd = INDEX2FD(newfdnum);
  8014ed:	89 f3                	mov    %esi,%ebx
  8014ef:	c1 e3 0c             	shl    $0xc,%ebx
  8014f2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014f8:	83 c4 04             	add    $0x4,%esp
  8014fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014fe:	e8 db fd ff ff       	call   8012de <fd2data>
  801503:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801505:	89 1c 24             	mov    %ebx,(%esp)
  801508:	e8 d1 fd ff ff       	call   8012de <fd2data>
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801513:	89 f8                	mov    %edi,%eax
  801515:	c1 e8 16             	shr    $0x16,%eax
  801518:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80151f:	a8 01                	test   $0x1,%al
  801521:	74 37                	je     80155a <dup+0x99>
  801523:	89 f8                	mov    %edi,%eax
  801525:	c1 e8 0c             	shr    $0xc,%eax
  801528:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152f:	f6 c2 01             	test   $0x1,%dl
  801532:	74 26                	je     80155a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801534:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	25 07 0e 00 00       	and    $0xe07,%eax
  801543:	50                   	push   %eax
  801544:	ff 75 d4             	pushl  -0x2c(%ebp)
  801547:	6a 00                	push   $0x0
  801549:	57                   	push   %edi
  80154a:	6a 00                	push   $0x0
  80154c:	e8 71 f6 ff ff       	call   800bc2 <sys_page_map>
  801551:	89 c7                	mov    %eax,%edi
  801553:	83 c4 20             	add    $0x20,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 2e                	js     801588 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80155a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80155d:	89 d0                	mov    %edx,%eax
  80155f:	c1 e8 0c             	shr    $0xc,%eax
  801562:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801569:	83 ec 0c             	sub    $0xc,%esp
  80156c:	25 07 0e 00 00       	and    $0xe07,%eax
  801571:	50                   	push   %eax
  801572:	53                   	push   %ebx
  801573:	6a 00                	push   $0x0
  801575:	52                   	push   %edx
  801576:	6a 00                	push   $0x0
  801578:	e8 45 f6 ff ff       	call   800bc2 <sys_page_map>
  80157d:	89 c7                	mov    %eax,%edi
  80157f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801582:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801584:	85 ff                	test   %edi,%edi
  801586:	79 1d                	jns    8015a5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	53                   	push   %ebx
  80158c:	6a 00                	push   $0x0
  80158e:	e8 71 f6 ff ff       	call   800c04 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	ff 75 d4             	pushl  -0x2c(%ebp)
  801599:	6a 00                	push   $0x0
  80159b:	e8 64 f6 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	89 f8                	mov    %edi,%eax
}
  8015a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a8:	5b                   	pop    %ebx
  8015a9:	5e                   	pop    %esi
  8015aa:	5f                   	pop    %edi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    

008015ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 14             	sub    $0x14,%esp
  8015b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	53                   	push   %ebx
  8015bc:	e8 83 fd ff ff       	call   801344 <fd_lookup>
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	89 c2                	mov    %eax,%edx
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 70                	js     80163a <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d4:	ff 30                	pushl  (%eax)
  8015d6:	e8 bf fd ff ff       	call   80139a <dev_lookup>
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 4f                	js     801631 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e5:	8b 42 08             	mov    0x8(%edx),%eax
  8015e8:	83 e0 03             	and    $0x3,%eax
  8015eb:	83 f8 01             	cmp    $0x1,%eax
  8015ee:	75 24                	jne    801614 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015f5:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8015fb:	83 ec 04             	sub    $0x4,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	50                   	push   %eax
  801600:	68 b9 28 80 00       	push   $0x8028b9
  801605:	e8 ed eb ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801612:	eb 26                	jmp    80163a <read+0x8d>
	}
	if (!dev->dev_read)
  801614:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801617:	8b 40 08             	mov    0x8(%eax),%eax
  80161a:	85 c0                	test   %eax,%eax
  80161c:	74 17                	je     801635 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	ff 75 10             	pushl  0x10(%ebp)
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	52                   	push   %edx
  801628:	ff d0                	call   *%eax
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb 09                	jmp    80163a <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801631:	89 c2                	mov    %eax,%edx
  801633:	eb 05                	jmp    80163a <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801635:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80163a:	89 d0                	mov    %edx,%eax
  80163c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	57                   	push   %edi
  801645:	56                   	push   %esi
  801646:	53                   	push   %ebx
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80164d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801650:	bb 00 00 00 00       	mov    $0x0,%ebx
  801655:	eb 21                	jmp    801678 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801657:	83 ec 04             	sub    $0x4,%esp
  80165a:	89 f0                	mov    %esi,%eax
  80165c:	29 d8                	sub    %ebx,%eax
  80165e:	50                   	push   %eax
  80165f:	89 d8                	mov    %ebx,%eax
  801661:	03 45 0c             	add    0xc(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	57                   	push   %edi
  801666:	e8 42 ff ff ff       	call   8015ad <read>
		if (m < 0)
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 10                	js     801682 <readn+0x41>
			return m;
		if (m == 0)
  801672:	85 c0                	test   %eax,%eax
  801674:	74 0a                	je     801680 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801676:	01 c3                	add    %eax,%ebx
  801678:	39 f3                	cmp    %esi,%ebx
  80167a:	72 db                	jb     801657 <readn+0x16>
  80167c:	89 d8                	mov    %ebx,%eax
  80167e:	eb 02                	jmp    801682 <readn+0x41>
  801680:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	53                   	push   %ebx
  80168e:	83 ec 14             	sub    $0x14,%esp
  801691:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801694:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	53                   	push   %ebx
  801699:	e8 a6 fc ff ff       	call   801344 <fd_lookup>
  80169e:	83 c4 08             	add    $0x8,%esp
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 6b                	js     801712 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b1:	ff 30                	pushl  (%eax)
  8016b3:	e8 e2 fc ff ff       	call   80139a <dev_lookup>
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 4a                	js     801709 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c6:	75 24                	jne    8016ec <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8016cd:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	53                   	push   %ebx
  8016d7:	50                   	push   %eax
  8016d8:	68 d5 28 80 00       	push   $0x8028d5
  8016dd:	e8 15 eb ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ea:	eb 26                	jmp    801712 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ef:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f2:	85 d2                	test   %edx,%edx
  8016f4:	74 17                	je     80170d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f6:	83 ec 04             	sub    $0x4,%esp
  8016f9:	ff 75 10             	pushl  0x10(%ebp)
  8016fc:	ff 75 0c             	pushl  0xc(%ebp)
  8016ff:	50                   	push   %eax
  801700:	ff d2                	call   *%edx
  801702:	89 c2                	mov    %eax,%edx
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	eb 09                	jmp    801712 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801709:	89 c2                	mov    %eax,%edx
  80170b:	eb 05                	jmp    801712 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80170d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801712:	89 d0                	mov    %edx,%eax
  801714:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <seek>:

int
seek(int fdnum, off_t offset)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801722:	50                   	push   %eax
  801723:	ff 75 08             	pushl  0x8(%ebp)
  801726:	e8 19 fc ff ff       	call   801344 <fd_lookup>
  80172b:	83 c4 08             	add    $0x8,%esp
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 0e                	js     801740 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801732:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801735:	8b 55 0c             	mov    0xc(%ebp),%edx
  801738:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80173b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	83 ec 14             	sub    $0x14,%esp
  801749:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174f:	50                   	push   %eax
  801750:	53                   	push   %ebx
  801751:	e8 ee fb ff ff       	call   801344 <fd_lookup>
  801756:	83 c4 08             	add    $0x8,%esp
  801759:	89 c2                	mov    %eax,%edx
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 68                	js     8017c7 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801769:	ff 30                	pushl  (%eax)
  80176b:	e8 2a fc ff ff       	call   80139a <dev_lookup>
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	78 47                	js     8017be <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177e:	75 24                	jne    8017a4 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801780:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801785:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80178b:	83 ec 04             	sub    $0x4,%esp
  80178e:	53                   	push   %ebx
  80178f:	50                   	push   %eax
  801790:	68 98 28 80 00       	push   $0x802898
  801795:	e8 5d ea ff ff       	call   8001f7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a2:	eb 23                	jmp    8017c7 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8017a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a7:	8b 52 18             	mov    0x18(%edx),%edx
  8017aa:	85 d2                	test   %edx,%edx
  8017ac:	74 14                	je     8017c2 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	50                   	push   %eax
  8017b5:	ff d2                	call   *%edx
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	eb 09                	jmp    8017c7 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017be:	89 c2                	mov    %eax,%edx
  8017c0:	eb 05                	jmp    8017c7 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c7:	89 d0                	mov    %edx,%eax
  8017c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 14             	sub    $0x14,%esp
  8017d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017db:	50                   	push   %eax
  8017dc:	ff 75 08             	pushl  0x8(%ebp)
  8017df:	e8 60 fb ff ff       	call   801344 <fd_lookup>
  8017e4:	83 c4 08             	add    $0x8,%esp
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	78 58                	js     801845 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f3:	50                   	push   %eax
  8017f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f7:	ff 30                	pushl  (%eax)
  8017f9:	e8 9c fb ff ff       	call   80139a <dev_lookup>
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	85 c0                	test   %eax,%eax
  801803:	78 37                	js     80183c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801805:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801808:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80180c:	74 32                	je     801840 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80180e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801811:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801818:	00 00 00 
	stat->st_isdir = 0;
  80181b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801822:	00 00 00 
	stat->st_dev = dev;
  801825:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	53                   	push   %ebx
  80182f:	ff 75 f0             	pushl  -0x10(%ebp)
  801832:	ff 50 14             	call   *0x14(%eax)
  801835:	89 c2                	mov    %eax,%edx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	eb 09                	jmp    801845 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183c:	89 c2                	mov    %eax,%edx
  80183e:	eb 05                	jmp    801845 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801840:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801845:	89 d0                	mov    %edx,%eax
  801847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	56                   	push   %esi
  801850:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801851:	83 ec 08             	sub    $0x8,%esp
  801854:	6a 00                	push   $0x0
  801856:	ff 75 08             	pushl  0x8(%ebp)
  801859:	e8 e3 01 00 00       	call   801a41 <open>
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	78 1b                	js     801882 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	ff 75 0c             	pushl  0xc(%ebp)
  80186d:	50                   	push   %eax
  80186e:	e8 5b ff ff ff       	call   8017ce <fstat>
  801873:	89 c6                	mov    %eax,%esi
	close(fd);
  801875:	89 1c 24             	mov    %ebx,(%esp)
  801878:	e8 f4 fb ff ff       	call   801471 <close>
	return r;
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	89 f0                	mov    %esi,%eax
}
  801882:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5d                   	pop    %ebp
  801888:	c3                   	ret    

00801889 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	56                   	push   %esi
  80188d:	53                   	push   %ebx
  80188e:	89 c6                	mov    %eax,%esi
  801890:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801892:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801899:	75 12                	jne    8018ad <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80189b:	83 ec 0c             	sub    $0xc,%esp
  80189e:	6a 01                	push   $0x1
  8018a0:	e8 da 08 00 00       	call   80217f <ipc_find_env>
  8018a5:	a3 00 40 80 00       	mov    %eax,0x804000
  8018aa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ad:	6a 07                	push   $0x7
  8018af:	68 00 50 80 00       	push   $0x805000
  8018b4:	56                   	push   %esi
  8018b5:	ff 35 00 40 80 00    	pushl  0x804000
  8018bb:	e8 5d 08 00 00       	call   80211d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018c0:	83 c4 0c             	add    $0xc,%esp
  8018c3:	6a 00                	push   $0x0
  8018c5:	53                   	push   %ebx
  8018c6:	6a 00                	push   $0x0
  8018c8:	e8 d5 07 00 00       	call   8020a2 <ipc_recv>
}
  8018cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f7:	e8 8d ff ff ff       	call   801889 <fsipc>
}
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	8b 40 0c             	mov    0xc(%eax),%eax
  80190a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80190f:	ba 00 00 00 00       	mov    $0x0,%edx
  801914:	b8 06 00 00 00       	mov    $0x6,%eax
  801919:	e8 6b ff ff ff       	call   801889 <fsipc>
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	53                   	push   %ebx
  801924:	83 ec 04             	sub    $0x4,%esp
  801927:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	8b 40 0c             	mov    0xc(%eax),%eax
  801930:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801935:	ba 00 00 00 00       	mov    $0x0,%edx
  80193a:	b8 05 00 00 00       	mov    $0x5,%eax
  80193f:	e8 45 ff ff ff       	call   801889 <fsipc>
  801944:	85 c0                	test   %eax,%eax
  801946:	78 2c                	js     801974 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	68 00 50 80 00       	push   $0x805000
  801950:	53                   	push   %ebx
  801951:	e8 26 ee ff ff       	call   80077c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801956:	a1 80 50 80 00       	mov    0x805080,%eax
  80195b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801961:	a1 84 50 80 00       	mov    0x805084,%eax
  801966:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801974:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801977:	c9                   	leave  
  801978:	c3                   	ret    

00801979 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 0c             	sub    $0xc,%esp
  80197f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801982:	8b 55 08             	mov    0x8(%ebp),%edx
  801985:	8b 52 0c             	mov    0xc(%edx),%edx
  801988:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80198e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801993:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801998:	0f 47 c2             	cmova  %edx,%eax
  80199b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019a0:	50                   	push   %eax
  8019a1:	ff 75 0c             	pushl  0xc(%ebp)
  8019a4:	68 08 50 80 00       	push   $0x805008
  8019a9:	e8 60 ef ff ff       	call   80090e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b8:	e8 cc fe ff ff       	call   801889 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	56                   	push   %esi
  8019c3:	53                   	push   %ebx
  8019c4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8019cd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019d2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8019e2:	e8 a2 fe ff ff       	call   801889 <fsipc>
  8019e7:	89 c3                	mov    %eax,%ebx
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 4b                	js     801a38 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019ed:	39 c6                	cmp    %eax,%esi
  8019ef:	73 16                	jae    801a07 <devfile_read+0x48>
  8019f1:	68 04 29 80 00       	push   $0x802904
  8019f6:	68 0b 29 80 00       	push   $0x80290b
  8019fb:	6a 7c                	push   $0x7c
  8019fd:	68 20 29 80 00       	push   $0x802920
  801a02:	e8 c6 05 00 00       	call   801fcd <_panic>
	assert(r <= PGSIZE);
  801a07:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a0c:	7e 16                	jle    801a24 <devfile_read+0x65>
  801a0e:	68 2b 29 80 00       	push   $0x80292b
  801a13:	68 0b 29 80 00       	push   $0x80290b
  801a18:	6a 7d                	push   $0x7d
  801a1a:	68 20 29 80 00       	push   $0x802920
  801a1f:	e8 a9 05 00 00       	call   801fcd <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	50                   	push   %eax
  801a28:	68 00 50 80 00       	push   $0x805000
  801a2d:	ff 75 0c             	pushl  0xc(%ebp)
  801a30:	e8 d9 ee ff ff       	call   80090e <memmove>
	return r;
  801a35:	83 c4 10             	add    $0x10,%esp
}
  801a38:	89 d8                	mov    %ebx,%eax
  801a3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3d:	5b                   	pop    %ebx
  801a3e:	5e                   	pop    %esi
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	53                   	push   %ebx
  801a45:	83 ec 20             	sub    $0x20,%esp
  801a48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a4b:	53                   	push   %ebx
  801a4c:	e8 f2 ec ff ff       	call   800743 <strlen>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a59:	7f 67                	jg     801ac2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a61:	50                   	push   %eax
  801a62:	e8 8e f8 ff ff       	call   8012f5 <fd_alloc>
  801a67:	83 c4 10             	add    $0x10,%esp
		return r;
  801a6a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	78 57                	js     801ac7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	53                   	push   %ebx
  801a74:	68 00 50 80 00       	push   $0x805000
  801a79:	e8 fe ec ff ff       	call   80077c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a81:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a89:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8e:	e8 f6 fd ff ff       	call   801889 <fsipc>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	79 14                	jns    801ab0 <open+0x6f>
		fd_close(fd, 0);
  801a9c:	83 ec 08             	sub    $0x8,%esp
  801a9f:	6a 00                	push   $0x0
  801aa1:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa4:	e8 47 f9 ff ff       	call   8013f0 <fd_close>
		return r;
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	89 da                	mov    %ebx,%edx
  801aae:	eb 17                	jmp    801ac7 <open+0x86>
	}

	return fd2num(fd);
  801ab0:	83 ec 0c             	sub    $0xc,%esp
  801ab3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab6:	e8 13 f8 ff ff       	call   8012ce <fd2num>
  801abb:	89 c2                	mov    %eax,%edx
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	eb 05                	jmp    801ac7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ac2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ac7:	89 d0                	mov    %edx,%eax
  801ac9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad9:	b8 08 00 00 00       	mov    $0x8,%eax
  801ade:	e8 a6 fd ff ff       	call   801889 <fsipc>
}
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	56                   	push   %esi
  801ae9:	53                   	push   %ebx
  801aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	ff 75 08             	pushl  0x8(%ebp)
  801af3:	e8 e6 f7 ff ff       	call   8012de <fd2data>
  801af8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801afa:	83 c4 08             	add    $0x8,%esp
  801afd:	68 37 29 80 00       	push   $0x802937
  801b02:	53                   	push   %ebx
  801b03:	e8 74 ec ff ff       	call   80077c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b08:	8b 46 04             	mov    0x4(%esi),%eax
  801b0b:	2b 06                	sub    (%esi),%eax
  801b0d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b13:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b1a:	00 00 00 
	stat->st_dev = &devpipe;
  801b1d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b24:	30 80 00 
	return 0;
}
  801b27:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	53                   	push   %ebx
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b3d:	53                   	push   %ebx
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 bf f0 ff ff       	call   800c04 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b45:	89 1c 24             	mov    %ebx,(%esp)
  801b48:	e8 91 f7 ff ff       	call   8012de <fd2data>
  801b4d:	83 c4 08             	add    $0x8,%esp
  801b50:	50                   	push   %eax
  801b51:	6a 00                	push   $0x0
  801b53:	e8 ac f0 ff ff       	call   800c04 <sys_page_unmap>
}
  801b58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5b:	c9                   	leave  
  801b5c:	c3                   	ret    

00801b5d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	57                   	push   %edi
  801b61:	56                   	push   %esi
  801b62:	53                   	push   %ebx
  801b63:	83 ec 1c             	sub    $0x1c,%esp
  801b66:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b69:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b70:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	ff 75 e0             	pushl  -0x20(%ebp)
  801b7c:	e8 43 06 00 00       	call   8021c4 <pageref>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	89 3c 24             	mov    %edi,(%esp)
  801b86:	e8 39 06 00 00       	call   8021c4 <pageref>
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	39 c3                	cmp    %eax,%ebx
  801b90:	0f 94 c1             	sete   %cl
  801b93:	0f b6 c9             	movzbl %cl,%ecx
  801b96:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b99:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b9f:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801ba5:	39 ce                	cmp    %ecx,%esi
  801ba7:	74 1e                	je     801bc7 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801ba9:	39 c3                	cmp    %eax,%ebx
  801bab:	75 be                	jne    801b6b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bad:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801bb3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb6:	50                   	push   %eax
  801bb7:	56                   	push   %esi
  801bb8:	68 3e 29 80 00       	push   $0x80293e
  801bbd:	e8 35 e6 ff ff       	call   8001f7 <cprintf>
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	eb a4                	jmp    801b6b <_pipeisclosed+0xe>
	}
}
  801bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	57                   	push   %edi
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 28             	sub    $0x28,%esp
  801bdb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bde:	56                   	push   %esi
  801bdf:	e8 fa f6 ff ff       	call   8012de <fd2data>
  801be4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	bf 00 00 00 00       	mov    $0x0,%edi
  801bee:	eb 4b                	jmp    801c3b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bf0:	89 da                	mov    %ebx,%edx
  801bf2:	89 f0                	mov    %esi,%eax
  801bf4:	e8 64 ff ff ff       	call   801b5d <_pipeisclosed>
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	75 48                	jne    801c45 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bfd:	e8 5e ef ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c02:	8b 43 04             	mov    0x4(%ebx),%eax
  801c05:	8b 0b                	mov    (%ebx),%ecx
  801c07:	8d 51 20             	lea    0x20(%ecx),%edx
  801c0a:	39 d0                	cmp    %edx,%eax
  801c0c:	73 e2                	jae    801bf0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c11:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c15:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c18:	89 c2                	mov    %eax,%edx
  801c1a:	c1 fa 1f             	sar    $0x1f,%edx
  801c1d:	89 d1                	mov    %edx,%ecx
  801c1f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c22:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c25:	83 e2 1f             	and    $0x1f,%edx
  801c28:	29 ca                	sub    %ecx,%edx
  801c2a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c2e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c32:	83 c0 01             	add    $0x1,%eax
  801c35:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c38:	83 c7 01             	add    $0x1,%edi
  801c3b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c3e:	75 c2                	jne    801c02 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c40:	8b 45 10             	mov    0x10(%ebp),%eax
  801c43:	eb 05                	jmp    801c4a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 18             	sub    $0x18,%esp
  801c5b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c5e:	57                   	push   %edi
  801c5f:	e8 7a f6 ff ff       	call   8012de <fd2data>
  801c64:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6e:	eb 3d                	jmp    801cad <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c70:	85 db                	test   %ebx,%ebx
  801c72:	74 04                	je     801c78 <devpipe_read+0x26>
				return i;
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	eb 44                	jmp    801cbc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c78:	89 f2                	mov    %esi,%edx
  801c7a:	89 f8                	mov    %edi,%eax
  801c7c:	e8 dc fe ff ff       	call   801b5d <_pipeisclosed>
  801c81:	85 c0                	test   %eax,%eax
  801c83:	75 32                	jne    801cb7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c85:	e8 d6 ee ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c8a:	8b 06                	mov    (%esi),%eax
  801c8c:	3b 46 04             	cmp    0x4(%esi),%eax
  801c8f:	74 df                	je     801c70 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c91:	99                   	cltd   
  801c92:	c1 ea 1b             	shr    $0x1b,%edx
  801c95:	01 d0                	add    %edx,%eax
  801c97:	83 e0 1f             	and    $0x1f,%eax
  801c9a:	29 d0                	sub    %edx,%eax
  801c9c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ca7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801caa:	83 c3 01             	add    $0x1,%ebx
  801cad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cb0:	75 d8                	jne    801c8a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb5:	eb 05                	jmp    801cbc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    

00801cc4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ccc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccf:	50                   	push   %eax
  801cd0:	e8 20 f6 ff ff       	call   8012f5 <fd_alloc>
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	89 c2                	mov    %eax,%edx
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	0f 88 2c 01 00 00    	js     801e0e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce2:	83 ec 04             	sub    $0x4,%esp
  801ce5:	68 07 04 00 00       	push   $0x407
  801cea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ced:	6a 00                	push   $0x0
  801cef:	e8 8b ee ff ff       	call   800b7f <sys_page_alloc>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	89 c2                	mov    %eax,%edx
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	0f 88 0d 01 00 00    	js     801e0e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d01:	83 ec 0c             	sub    $0xc,%esp
  801d04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d07:	50                   	push   %eax
  801d08:	e8 e8 f5 ff ff       	call   8012f5 <fd_alloc>
  801d0d:	89 c3                	mov    %eax,%ebx
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	85 c0                	test   %eax,%eax
  801d14:	0f 88 e2 00 00 00    	js     801dfc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1a:	83 ec 04             	sub    $0x4,%esp
  801d1d:	68 07 04 00 00       	push   $0x407
  801d22:	ff 75 f0             	pushl  -0x10(%ebp)
  801d25:	6a 00                	push   $0x0
  801d27:	e8 53 ee ff ff       	call   800b7f <sys_page_alloc>
  801d2c:	89 c3                	mov    %eax,%ebx
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	0f 88 c3 00 00 00    	js     801dfc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d39:	83 ec 0c             	sub    $0xc,%esp
  801d3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3f:	e8 9a f5 ff ff       	call   8012de <fd2data>
  801d44:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d46:	83 c4 0c             	add    $0xc,%esp
  801d49:	68 07 04 00 00       	push   $0x407
  801d4e:	50                   	push   %eax
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 29 ee ff ff       	call   800b7f <sys_page_alloc>
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	0f 88 89 00 00 00    	js     801dec <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d63:	83 ec 0c             	sub    $0xc,%esp
  801d66:	ff 75 f0             	pushl  -0x10(%ebp)
  801d69:	e8 70 f5 ff ff       	call   8012de <fd2data>
  801d6e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d75:	50                   	push   %eax
  801d76:	6a 00                	push   $0x0
  801d78:	56                   	push   %esi
  801d79:	6a 00                	push   $0x0
  801d7b:	e8 42 ee ff ff       	call   800bc2 <sys_page_map>
  801d80:	89 c3                	mov    %eax,%ebx
  801d82:	83 c4 20             	add    $0x20,%esp
  801d85:	85 c0                	test   %eax,%eax
  801d87:	78 55                	js     801dde <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d89:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d92:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d97:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d9e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	ff 75 f4             	pushl  -0xc(%ebp)
  801db9:	e8 10 f5 ff ff       	call   8012ce <fd2num>
  801dbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc3:	83 c4 04             	add    $0x4,%esp
  801dc6:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc9:	e8 00 f5 ff ff       	call   8012ce <fd2num>
  801dce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd1:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	ba 00 00 00 00       	mov    $0x0,%edx
  801ddc:	eb 30                	jmp    801e0e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801dde:	83 ec 08             	sub    $0x8,%esp
  801de1:	56                   	push   %esi
  801de2:	6a 00                	push   $0x0
  801de4:	e8 1b ee ff ff       	call   800c04 <sys_page_unmap>
  801de9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dec:	83 ec 08             	sub    $0x8,%esp
  801def:	ff 75 f0             	pushl  -0x10(%ebp)
  801df2:	6a 00                	push   $0x0
  801df4:	e8 0b ee ff ff       	call   800c04 <sys_page_unmap>
  801df9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dfc:	83 ec 08             	sub    $0x8,%esp
  801dff:	ff 75 f4             	pushl  -0xc(%ebp)
  801e02:	6a 00                	push   $0x0
  801e04:	e8 fb ed ff ff       	call   800c04 <sys_page_unmap>
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e0e:	89 d0                	mov    %edx,%eax
  801e10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e13:	5b                   	pop    %ebx
  801e14:	5e                   	pop    %esi
  801e15:	5d                   	pop    %ebp
  801e16:	c3                   	ret    

00801e17 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e20:	50                   	push   %eax
  801e21:	ff 75 08             	pushl  0x8(%ebp)
  801e24:	e8 1b f5 ff ff       	call   801344 <fd_lookup>
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	78 18                	js     801e48 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e30:	83 ec 0c             	sub    $0xc,%esp
  801e33:	ff 75 f4             	pushl  -0xc(%ebp)
  801e36:	e8 a3 f4 ff ff       	call   8012de <fd2data>
	return _pipeisclosed(fd, p);
  801e3b:	89 c2                	mov    %eax,%edx
  801e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e40:	e8 18 fd ff ff       	call   801b5d <_pipeisclosed>
  801e45:	83 c4 10             	add    $0x10,%esp
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e5a:	68 56 29 80 00       	push   $0x802956
  801e5f:	ff 75 0c             	pushl  0xc(%ebp)
  801e62:	e8 15 e9 ff ff       	call   80077c <strcpy>
	return 0;
}
  801e67:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	57                   	push   %edi
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
  801e74:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e7f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e85:	eb 2d                	jmp    801eb4 <devcons_write+0x46>
		m = n - tot;
  801e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e8a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e8c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e8f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e94:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e97:	83 ec 04             	sub    $0x4,%esp
  801e9a:	53                   	push   %ebx
  801e9b:	03 45 0c             	add    0xc(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	57                   	push   %edi
  801ea0:	e8 69 ea ff ff       	call   80090e <memmove>
		sys_cputs(buf, m);
  801ea5:	83 c4 08             	add    $0x8,%esp
  801ea8:	53                   	push   %ebx
  801ea9:	57                   	push   %edi
  801eaa:	e8 14 ec ff ff       	call   800ac3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eaf:	01 de                	add    %ebx,%esi
  801eb1:	83 c4 10             	add    $0x10,%esp
  801eb4:	89 f0                	mov    %esi,%eax
  801eb6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb9:	72 cc                	jb     801e87 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebe:	5b                   	pop    %ebx
  801ebf:	5e                   	pop    %esi
  801ec0:	5f                   	pop    %edi
  801ec1:	5d                   	pop    %ebp
  801ec2:	c3                   	ret    

00801ec3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	83 ec 08             	sub    $0x8,%esp
  801ec9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ece:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed2:	74 2a                	je     801efe <devcons_read+0x3b>
  801ed4:	eb 05                	jmp    801edb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ed6:	e8 85 ec ff ff       	call   800b60 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801edb:	e8 01 ec ff ff       	call   800ae1 <sys_cgetc>
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	74 f2                	je     801ed6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 16                	js     801efe <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ee8:	83 f8 04             	cmp    $0x4,%eax
  801eeb:	74 0c                	je     801ef9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eed:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef0:	88 02                	mov    %al,(%edx)
	return 1;
  801ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef7:	eb 05                	jmp    801efe <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ef9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f06:	8b 45 08             	mov    0x8(%ebp),%eax
  801f09:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f0c:	6a 01                	push   $0x1
  801f0e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f11:	50                   	push   %eax
  801f12:	e8 ac eb ff ff       	call   800ac3 <sys_cputs>
}
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <getchar>:

int
getchar(void)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f22:	6a 01                	push   $0x1
  801f24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f27:	50                   	push   %eax
  801f28:	6a 00                	push   $0x0
  801f2a:	e8 7e f6 ff ff       	call   8015ad <read>
	if (r < 0)
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	78 0f                	js     801f45 <getchar+0x29>
		return r;
	if (r < 1)
  801f36:	85 c0                	test   %eax,%eax
  801f38:	7e 06                	jle    801f40 <getchar+0x24>
		return -E_EOF;
	return c;
  801f3a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f3e:	eb 05                	jmp    801f45 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f40:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f50:	50                   	push   %eax
  801f51:	ff 75 08             	pushl  0x8(%ebp)
  801f54:	e8 eb f3 ff ff       	call   801344 <fd_lookup>
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 11                	js     801f71 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f63:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f69:	39 10                	cmp    %edx,(%eax)
  801f6b:	0f 94 c0             	sete   %al
  801f6e:	0f b6 c0             	movzbl %al,%eax
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <opencons>:

int
opencons(void)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	e8 73 f3 ff ff       	call   8012f5 <fd_alloc>
  801f82:	83 c4 10             	add    $0x10,%esp
		return r;
  801f85:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 3e                	js     801fc9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f8b:	83 ec 04             	sub    $0x4,%esp
  801f8e:	68 07 04 00 00       	push   $0x407
  801f93:	ff 75 f4             	pushl  -0xc(%ebp)
  801f96:	6a 00                	push   $0x0
  801f98:	e8 e2 eb ff ff       	call   800b7f <sys_page_alloc>
  801f9d:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 23                	js     801fc9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fa6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801faf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fbb:	83 ec 0c             	sub    $0xc,%esp
  801fbe:	50                   	push   %eax
  801fbf:	e8 0a f3 ff ff       	call   8012ce <fd2num>
  801fc4:	89 c2                	mov    %eax,%edx
  801fc6:	83 c4 10             	add    $0x10,%esp
}
  801fc9:	89 d0                	mov    %edx,%eax
  801fcb:	c9                   	leave  
  801fcc:	c3                   	ret    

00801fcd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	56                   	push   %esi
  801fd1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fd2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fd5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fdb:	e8 61 eb ff ff       	call   800b41 <sys_getenvid>
  801fe0:	83 ec 0c             	sub    $0xc,%esp
  801fe3:	ff 75 0c             	pushl  0xc(%ebp)
  801fe6:	ff 75 08             	pushl  0x8(%ebp)
  801fe9:	56                   	push   %esi
  801fea:	50                   	push   %eax
  801feb:	68 64 29 80 00       	push   $0x802964
  801ff0:	e8 02 e2 ff ff       	call   8001f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ff5:	83 c4 18             	add    $0x18,%esp
  801ff8:	53                   	push   %ebx
  801ff9:	ff 75 10             	pushl  0x10(%ebp)
  801ffc:	e8 a5 e1 ff ff       	call   8001a6 <vcprintf>
	cprintf("\n");
  802001:	c7 04 24 5b 28 80 00 	movl   $0x80285b,(%esp)
  802008:	e8 ea e1 ff ff       	call   8001f7 <cprintf>
  80200d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802010:	cc                   	int3   
  802011:	eb fd                	jmp    802010 <_panic+0x43>

00802013 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802019:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802020:	75 2a                	jne    80204c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802022:	83 ec 04             	sub    $0x4,%esp
  802025:	6a 07                	push   $0x7
  802027:	68 00 f0 bf ee       	push   $0xeebff000
  80202c:	6a 00                	push   $0x0
  80202e:	e8 4c eb ff ff       	call   800b7f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	85 c0                	test   %eax,%eax
  802038:	79 12                	jns    80204c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80203a:	50                   	push   %eax
  80203b:	68 72 28 80 00       	push   $0x802872
  802040:	6a 23                	push   $0x23
  802042:	68 88 29 80 00       	push   $0x802988
  802047:	e8 81 ff ff ff       	call   801fcd <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80204c:	8b 45 08             	mov    0x8(%ebp),%eax
  80204f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802054:	83 ec 08             	sub    $0x8,%esp
  802057:	68 7e 20 80 00       	push   $0x80207e
  80205c:	6a 00                	push   $0x0
  80205e:	e8 67 ec ff ff       	call   800cca <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802063:	83 c4 10             	add    $0x10,%esp
  802066:	85 c0                	test   %eax,%eax
  802068:	79 12                	jns    80207c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80206a:	50                   	push   %eax
  80206b:	68 72 28 80 00       	push   $0x802872
  802070:	6a 2c                	push   $0x2c
  802072:	68 88 29 80 00       	push   $0x802988
  802077:	e8 51 ff ff ff       	call   801fcd <_panic>
	}
}
  80207c:	c9                   	leave  
  80207d:	c3                   	ret    

0080207e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80207e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80207f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802084:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802086:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802089:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80208d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802092:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802096:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802098:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80209b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80209c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80209f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020a0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020a1:	c3                   	ret    

008020a2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	56                   	push   %esi
  8020a6:	53                   	push   %ebx
  8020a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8020aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	75 12                	jne    8020c6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020b4:	83 ec 0c             	sub    $0xc,%esp
  8020b7:	68 00 00 c0 ee       	push   $0xeec00000
  8020bc:	e8 6e ec ff ff       	call   800d2f <sys_ipc_recv>
  8020c1:	83 c4 10             	add    $0x10,%esp
  8020c4:	eb 0c                	jmp    8020d2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020c6:	83 ec 0c             	sub    $0xc,%esp
  8020c9:	50                   	push   %eax
  8020ca:	e8 60 ec ff ff       	call   800d2f <sys_ipc_recv>
  8020cf:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020d2:	85 f6                	test   %esi,%esi
  8020d4:	0f 95 c1             	setne  %cl
  8020d7:	85 db                	test   %ebx,%ebx
  8020d9:	0f 95 c2             	setne  %dl
  8020dc:	84 d1                	test   %dl,%cl
  8020de:	74 09                	je     8020e9 <ipc_recv+0x47>
  8020e0:	89 c2                	mov    %eax,%edx
  8020e2:	c1 ea 1f             	shr    $0x1f,%edx
  8020e5:	84 d2                	test   %dl,%dl
  8020e7:	75 2d                	jne    802116 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020e9:	85 f6                	test   %esi,%esi
  8020eb:	74 0d                	je     8020fa <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f2:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8020f8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020fa:	85 db                	test   %ebx,%ebx
  8020fc:	74 0d                	je     80210b <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020fe:	a1 04 40 80 00       	mov    0x804004,%eax
  802103:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802109:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80210b:	a1 04 40 80 00       	mov    0x804004,%eax
  802110:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802116:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802119:	5b                   	pop    %ebx
  80211a:	5e                   	pop    %esi
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    

0080211d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	57                   	push   %edi
  802121:	56                   	push   %esi
  802122:	53                   	push   %ebx
  802123:	83 ec 0c             	sub    $0xc,%esp
  802126:	8b 7d 08             	mov    0x8(%ebp),%edi
  802129:	8b 75 0c             	mov    0xc(%ebp),%esi
  80212c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80212f:	85 db                	test   %ebx,%ebx
  802131:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802136:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802139:	ff 75 14             	pushl  0x14(%ebp)
  80213c:	53                   	push   %ebx
  80213d:	56                   	push   %esi
  80213e:	57                   	push   %edi
  80213f:	e8 c8 eb ff ff       	call   800d0c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802144:	89 c2                	mov    %eax,%edx
  802146:	c1 ea 1f             	shr    $0x1f,%edx
  802149:	83 c4 10             	add    $0x10,%esp
  80214c:	84 d2                	test   %dl,%dl
  80214e:	74 17                	je     802167 <ipc_send+0x4a>
  802150:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802153:	74 12                	je     802167 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802155:	50                   	push   %eax
  802156:	68 96 29 80 00       	push   $0x802996
  80215b:	6a 47                	push   $0x47
  80215d:	68 a4 29 80 00       	push   $0x8029a4
  802162:	e8 66 fe ff ff       	call   801fcd <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802167:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80216a:	75 07                	jne    802173 <ipc_send+0x56>
			sys_yield();
  80216c:	e8 ef e9 ff ff       	call   800b60 <sys_yield>
  802171:	eb c6                	jmp    802139 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802173:	85 c0                	test   %eax,%eax
  802175:	75 c2                	jne    802139 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802177:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80217a:	5b                   	pop    %ebx
  80217b:	5e                   	pop    %esi
  80217c:	5f                   	pop    %edi
  80217d:	5d                   	pop    %ebp
  80217e:	c3                   	ret    

0080217f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80217f:	55                   	push   %ebp
  802180:	89 e5                	mov    %esp,%ebp
  802182:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802185:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80218a:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802190:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802196:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80219c:	39 ca                	cmp    %ecx,%edx
  80219e:	75 13                	jne    8021b3 <ipc_find_env+0x34>
			return envs[i].env_id;
  8021a0:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8021a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021ab:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8021b1:	eb 0f                	jmp    8021c2 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021b3:	83 c0 01             	add    $0x1,%eax
  8021b6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021bb:	75 cd                	jne    80218a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    

008021c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ca:	89 d0                	mov    %edx,%eax
  8021cc:	c1 e8 16             	shr    $0x16,%eax
  8021cf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021d6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021db:	f6 c1 01             	test   $0x1,%cl
  8021de:	74 1d                	je     8021fd <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021e0:	c1 ea 0c             	shr    $0xc,%edx
  8021e3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021ea:	f6 c2 01             	test   $0x1,%dl
  8021ed:	74 0e                	je     8021fd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ef:	c1 ea 0c             	shr    $0xc,%edx
  8021f2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021f9:	ef 
  8021fa:	0f b7 c0             	movzwl %ax,%eax
}
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    
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
