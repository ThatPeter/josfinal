
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
  800047:	68 20 25 80 00       	push   $0x802520
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
  800095:	68 31 25 80 00       	push   $0x802531
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
  8000d2:	68 07 29 80 00       	push   $0x802907
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
  8000f6:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  800150:	e8 c5 13 00 00       	call   80151a <close_all>
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
  80025a:	e8 21 20 00 00       	call   802280 <__udivdi3>
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
  80029d:	e8 0e 21 00 00       	call   8023b0 <__umoddi3>
  8002a2:	83 c4 14             	add    $0x14,%esp
  8002a5:	0f be 80 40 25 80 00 	movsbl 0x802540(%eax),%eax
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
  8003a1:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
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
  800465:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  80046c:	85 d2                	test   %edx,%edx
  80046e:	75 18                	jne    800488 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800470:	50                   	push   %eax
  800471:	68 58 25 80 00       	push   $0x802558
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
  800489:	68 6d 2a 80 00       	push   $0x802a6d
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
  8004ad:	b8 51 25 80 00       	mov    $0x802551,%eax
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
  800b28:	68 3f 28 80 00       	push   $0x80283f
  800b2d:	6a 23                	push   $0x23
  800b2f:	68 5c 28 80 00       	push   $0x80285c
  800b34:	e8 12 15 00 00       	call   80204b <_panic>

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
  800ba9:	68 3f 28 80 00       	push   $0x80283f
  800bae:	6a 23                	push   $0x23
  800bb0:	68 5c 28 80 00       	push   $0x80285c
  800bb5:	e8 91 14 00 00       	call   80204b <_panic>

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
  800beb:	68 3f 28 80 00       	push   $0x80283f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 5c 28 80 00       	push   $0x80285c
  800bf7:	e8 4f 14 00 00       	call   80204b <_panic>

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
  800c2d:	68 3f 28 80 00       	push   $0x80283f
  800c32:	6a 23                	push   $0x23
  800c34:	68 5c 28 80 00       	push   $0x80285c
  800c39:	e8 0d 14 00 00       	call   80204b <_panic>

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
  800c6f:	68 3f 28 80 00       	push   $0x80283f
  800c74:	6a 23                	push   $0x23
  800c76:	68 5c 28 80 00       	push   $0x80285c
  800c7b:	e8 cb 13 00 00       	call   80204b <_panic>

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
  800cb1:	68 3f 28 80 00       	push   $0x80283f
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 5c 28 80 00       	push   $0x80285c
  800cbd:	e8 89 13 00 00       	call   80204b <_panic>
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
  800cf3:	68 3f 28 80 00       	push   $0x80283f
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 5c 28 80 00       	push   $0x80285c
  800cff:	e8 47 13 00 00       	call   80204b <_panic>

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
  800d57:	68 3f 28 80 00       	push   $0x80283f
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 5c 28 80 00       	push   $0x80285c
  800d63:	e8 e3 12 00 00       	call   80204b <_panic>

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
  800df6:	68 6a 28 80 00       	push   $0x80286a
  800dfb:	6a 1f                	push   $0x1f
  800dfd:	68 7a 28 80 00       	push   $0x80287a
  800e02:	e8 44 12 00 00       	call   80204b <_panic>
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
  800e20:	68 85 28 80 00       	push   $0x802885
  800e25:	6a 2d                	push   $0x2d
  800e27:	68 7a 28 80 00       	push   $0x80287a
  800e2c:	e8 1a 12 00 00       	call   80204b <_panic>
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
  800e68:	68 85 28 80 00       	push   $0x802885
  800e6d:	6a 34                	push   $0x34
  800e6f:	68 7a 28 80 00       	push   $0x80287a
  800e74:	e8 d2 11 00 00       	call   80204b <_panic>
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
  800e90:	68 85 28 80 00       	push   $0x802885
  800e95:	6a 38                	push   $0x38
  800e97:	68 7a 28 80 00       	push   $0x80287a
  800e9c:	e8 aa 11 00 00       	call   80204b <_panic>
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
  800eb4:	e8 d8 11 00 00       	call   802091 <set_pgfault_handler>
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
  800ecd:	68 9e 28 80 00       	push   $0x80289e
  800ed2:	68 85 00 00 00       	push   $0x85
  800ed7:	68 7a 28 80 00       	push   $0x80287a
  800edc:	e8 6a 11 00 00       	call   80204b <_panic>
  800ee1:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ee3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ee7:	75 24                	jne    800f0d <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ee9:	e8 53 fc ff ff       	call   800b41 <sys_getenvid>
  800eee:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef3:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800f89:	68 ac 28 80 00       	push   $0x8028ac
  800f8e:	6a 55                	push   $0x55
  800f90:	68 7a 28 80 00       	push   $0x80287a
  800f95:	e8 b1 10 00 00       	call   80204b <_panic>
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
  800fce:	68 ac 28 80 00       	push   $0x8028ac
  800fd3:	6a 5c                	push   $0x5c
  800fd5:	68 7a 28 80 00       	push   $0x80287a
  800fda:	e8 6c 10 00 00       	call   80204b <_panic>
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
  800ffc:	68 ac 28 80 00       	push   $0x8028ac
  801001:	6a 60                	push   $0x60
  801003:	68 7a 28 80 00       	push   $0x80287a
  801008:	e8 3e 10 00 00       	call   80204b <_panic>
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
  801026:	68 ac 28 80 00       	push   $0x8028ac
  80102b:	6a 65                	push   $0x65
  80102d:	68 7a 28 80 00       	push   $0x80287a
  801032:	e8 14 10 00 00       	call   80204b <_panic>
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
  80104e:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80108b:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	53                   	push   %ebx
  801095:	68 3c 29 80 00       	push   $0x80293c
  80109a:	e8 58 f1 ff ff       	call   8001f7 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80109f:	c7 04 24 2a 01 80 00 	movl   $0x80012a,(%esp)
  8010a6:	e8 c5 fc ff ff       	call   800d70 <sys_thread_create>
  8010ab:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8010ad:	83 c4 08             	add    $0x8,%esp
  8010b0:	53                   	push   %ebx
  8010b1:	68 3c 29 80 00       	push   $0x80293c
  8010b6:	e8 3c f1 ff ff       	call   8001f7 <cprintf>
	return id;
}
  8010bb:	89 f0                	mov    %esi,%eax
  8010bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8010ca:	ff 75 08             	pushl  0x8(%ebp)
  8010cd:	e8 be fc ff ff       	call   800d90 <sys_thread_free>
}
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8010dd:	ff 75 08             	pushl  0x8(%ebp)
  8010e0:	e8 cb fc ff ff       	call   800db0 <sys_thread_join>
}
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8010f5:	83 ec 04             	sub    $0x4,%esp
  8010f8:	6a 07                	push   $0x7
  8010fa:	6a 00                	push   $0x0
  8010fc:	56                   	push   %esi
  8010fd:	e8 7d fa ff ff       	call   800b7f <sys_page_alloc>
	if (r < 0) {
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	79 15                	jns    80111e <queue_append+0x34>
		panic("%e\n", r);
  801109:	50                   	push   %eax
  80110a:	68 38 29 80 00       	push   $0x802938
  80110f:	68 c4 00 00 00       	push   $0xc4
  801114:	68 7a 28 80 00       	push   $0x80287a
  801119:	e8 2d 0f 00 00       	call   80204b <_panic>
	}	
	wt->envid = envid;
  80111e:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801124:	83 ec 04             	sub    $0x4,%esp
  801127:	ff 33                	pushl  (%ebx)
  801129:	56                   	push   %esi
  80112a:	68 60 29 80 00       	push   $0x802960
  80112f:	e8 c3 f0 ff ff       	call   8001f7 <cprintf>
	if (queue->first == NULL) {
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	83 3b 00             	cmpl   $0x0,(%ebx)
  80113a:	75 29                	jne    801165 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	68 c2 28 80 00       	push   $0x8028c2
  801144:	e8 ae f0 ff ff       	call   8001f7 <cprintf>
		queue->first = wt;
  801149:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80114f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801156:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80115d:	00 00 00 
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	eb 2b                	jmp    801190 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	68 dc 28 80 00       	push   $0x8028dc
  80116d:	e8 85 f0 ff ff       	call   8001f7 <cprintf>
		queue->last->next = wt;
  801172:	8b 43 04             	mov    0x4(%ebx),%eax
  801175:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80117c:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801183:	00 00 00 
		queue->last = wt;
  801186:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80118d:	83 c4 10             	add    $0x10,%esp
	}
}
  801190:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	53                   	push   %ebx
  80119b:	83 ec 04             	sub    $0x4,%esp
  80119e:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8011a1:	8b 02                	mov    (%edx),%eax
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	75 17                	jne    8011be <queue_pop+0x27>
		panic("queue empty!\n");
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	68 fa 28 80 00       	push   $0x8028fa
  8011af:	68 d8 00 00 00       	push   $0xd8
  8011b4:	68 7a 28 80 00       	push   $0x80287a
  8011b9:	e8 8d 0e 00 00       	call   80204b <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8011be:	8b 48 04             	mov    0x4(%eax),%ecx
  8011c1:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8011c3:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	53                   	push   %ebx
  8011c9:	68 08 29 80 00       	push   $0x802908
  8011ce:	e8 24 f0 ff ff       	call   8001f7 <cprintf>
	return envid;
}
  8011d3:	89 d8                	mov    %ebx,%eax
  8011d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8011e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e9:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	74 5a                	je     80124a <mutex_lock+0x70>
  8011f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8011f3:	83 38 00             	cmpl   $0x0,(%eax)
  8011f6:	75 52                	jne    80124a <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8011f8:	83 ec 0c             	sub    $0xc,%esp
  8011fb:	68 88 29 80 00       	push   $0x802988
  801200:	e8 f2 ef ff ff       	call   8001f7 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801205:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801208:	e8 34 f9 ff ff       	call   800b41 <sys_getenvid>
  80120d:	83 c4 08             	add    $0x8,%esp
  801210:	53                   	push   %ebx
  801211:	50                   	push   %eax
  801212:	e8 d3 fe ff ff       	call   8010ea <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  801217:	e8 25 f9 ff ff       	call   800b41 <sys_getenvid>
  80121c:	83 c4 08             	add    $0x8,%esp
  80121f:	6a 04                	push   $0x4
  801221:	50                   	push   %eax
  801222:	e8 1f fa ff ff       	call   800c46 <sys_env_set_status>
		if (r < 0) {
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	79 15                	jns    801243 <mutex_lock+0x69>
			panic("%e\n", r);
  80122e:	50                   	push   %eax
  80122f:	68 38 29 80 00       	push   $0x802938
  801234:	68 eb 00 00 00       	push   $0xeb
  801239:	68 7a 28 80 00       	push   $0x80287a
  80123e:	e8 08 0e 00 00       	call   80204b <_panic>
		}
		sys_yield();
  801243:	e8 18 f9 ff ff       	call   800b60 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801248:	eb 18                	jmp    801262 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80124a:	83 ec 0c             	sub    $0xc,%esp
  80124d:	68 a8 29 80 00       	push   $0x8029a8
  801252:	e8 a0 ef ff ff       	call   8001f7 <cprintf>
	mtx->owner = sys_getenvid();}
  801257:	e8 e5 f8 ff ff       	call   800b41 <sys_getenvid>
  80125c:	89 43 08             	mov    %eax,0x8(%ebx)
  80125f:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	53                   	push   %ebx
  80126b:	83 ec 04             	sub    $0x4,%esp
  80126e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
  801276:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801279:	8b 43 04             	mov    0x4(%ebx),%eax
  80127c:	83 38 00             	cmpl   $0x0,(%eax)
  80127f:	74 33                	je     8012b4 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	50                   	push   %eax
  801285:	e8 0d ff ff ff       	call   801197 <queue_pop>
  80128a:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80128d:	83 c4 08             	add    $0x8,%esp
  801290:	6a 02                	push   $0x2
  801292:	50                   	push   %eax
  801293:	e8 ae f9 ff ff       	call   800c46 <sys_env_set_status>
		if (r < 0) {
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	79 15                	jns    8012b4 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80129f:	50                   	push   %eax
  8012a0:	68 38 29 80 00       	push   $0x802938
  8012a5:	68 00 01 00 00       	push   $0x100
  8012aa:	68 7a 28 80 00       	push   $0x80287a
  8012af:	e8 97 0d 00 00       	call   80204b <_panic>
		}
	}

	asm volatile("pause");
  8012b4:	f3 90                	pause  
	//sys_yield();
}
  8012b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 04             	sub    $0x4,%esp
  8012c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8012c5:	e8 77 f8 ff ff       	call   800b41 <sys_getenvid>
  8012ca:	83 ec 04             	sub    $0x4,%esp
  8012cd:	6a 07                	push   $0x7
  8012cf:	53                   	push   %ebx
  8012d0:	50                   	push   %eax
  8012d1:	e8 a9 f8 ff ff       	call   800b7f <sys_page_alloc>
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	79 15                	jns    8012f2 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8012dd:	50                   	push   %eax
  8012de:	68 23 29 80 00       	push   $0x802923
  8012e3:	68 0d 01 00 00       	push   $0x10d
  8012e8:	68 7a 28 80 00       	push   $0x80287a
  8012ed:	e8 59 0d 00 00       	call   80204b <_panic>
	}	
	mtx->locked = 0;
  8012f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8012f8:	8b 43 04             	mov    0x4(%ebx),%eax
  8012fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801301:	8b 43 04             	mov    0x4(%ebx),%eax
  801304:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80130b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801312:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801315:	c9                   	leave  
  801316:	c3                   	ret    

00801317 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80131d:	e8 1f f8 ff ff       	call   800b41 <sys_getenvid>
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	ff 75 08             	pushl  0x8(%ebp)
  801328:	50                   	push   %eax
  801329:	e8 d6 f8 ff ff       	call   800c04 <sys_page_unmap>
	if (r < 0) {
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	79 15                	jns    80134a <mutex_destroy+0x33>
		panic("%e\n", r);
  801335:	50                   	push   %eax
  801336:	68 38 29 80 00       	push   $0x802938
  80133b:	68 1a 01 00 00       	push   $0x11a
  801340:	68 7a 28 80 00       	push   $0x80287a
  801345:	e8 01 0d 00 00       	call   80204b <_panic>
	}
}
  80134a:	c9                   	leave  
  80134b:	c3                   	ret    

0080134c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134f:	8b 45 08             	mov    0x8(%ebp),%eax
  801352:	05 00 00 00 30       	add    $0x30000000,%eax
  801357:	c1 e8 0c             	shr    $0xc,%eax
}
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80135f:	8b 45 08             	mov    0x8(%ebp),%eax
  801362:	05 00 00 00 30       	add    $0x30000000,%eax
  801367:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80136c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801379:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80137e:	89 c2                	mov    %eax,%edx
  801380:	c1 ea 16             	shr    $0x16,%edx
  801383:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80138a:	f6 c2 01             	test   $0x1,%dl
  80138d:	74 11                	je     8013a0 <fd_alloc+0x2d>
  80138f:	89 c2                	mov    %eax,%edx
  801391:	c1 ea 0c             	shr    $0xc,%edx
  801394:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80139b:	f6 c2 01             	test   $0x1,%dl
  80139e:	75 09                	jne    8013a9 <fd_alloc+0x36>
			*fd_store = fd;
  8013a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a7:	eb 17                	jmp    8013c0 <fd_alloc+0x4d>
  8013a9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013ae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013b3:	75 c9                	jne    80137e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013b5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013c8:	83 f8 1f             	cmp    $0x1f,%eax
  8013cb:	77 36                	ja     801403 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013cd:	c1 e0 0c             	shl    $0xc,%eax
  8013d0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013d5:	89 c2                	mov    %eax,%edx
  8013d7:	c1 ea 16             	shr    $0x16,%edx
  8013da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e1:	f6 c2 01             	test   $0x1,%dl
  8013e4:	74 24                	je     80140a <fd_lookup+0x48>
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	c1 ea 0c             	shr    $0xc,%edx
  8013eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f2:	f6 c2 01             	test   $0x1,%dl
  8013f5:	74 1a                	je     801411 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fa:	89 02                	mov    %eax,(%edx)
	return 0;
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801401:	eb 13                	jmp    801416 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801403:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801408:	eb 0c                	jmp    801416 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80140a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140f:	eb 05                	jmp    801416 <fd_lookup+0x54>
  801411:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    

00801418 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801421:	ba 44 2a 80 00       	mov    $0x802a44,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801426:	eb 13                	jmp    80143b <dev_lookup+0x23>
  801428:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80142b:	39 08                	cmp    %ecx,(%eax)
  80142d:	75 0c                	jne    80143b <dev_lookup+0x23>
			*dev = devtab[i];
  80142f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801432:	89 01                	mov    %eax,(%ecx)
			return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
  801439:	eb 31                	jmp    80146c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80143b:	8b 02                	mov    (%edx),%eax
  80143d:	85 c0                	test   %eax,%eax
  80143f:	75 e7                	jne    801428 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801441:	a1 04 40 80 00       	mov    0x804004,%eax
  801446:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80144c:	83 ec 04             	sub    $0x4,%esp
  80144f:	51                   	push   %ecx
  801450:	50                   	push   %eax
  801451:	68 c8 29 80 00       	push   $0x8029c8
  801456:	e8 9c ed ff ff       	call   8001f7 <cprintf>
	*dev = 0;
  80145b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	56                   	push   %esi
  801472:	53                   	push   %ebx
  801473:	83 ec 10             	sub    $0x10,%esp
  801476:	8b 75 08             	mov    0x8(%ebp),%esi
  801479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801486:	c1 e8 0c             	shr    $0xc,%eax
  801489:	50                   	push   %eax
  80148a:	e8 33 ff ff ff       	call   8013c2 <fd_lookup>
  80148f:	83 c4 08             	add    $0x8,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 05                	js     80149b <fd_close+0x2d>
	    || fd != fd2)
  801496:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801499:	74 0c                	je     8014a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80149b:	84 db                	test   %bl,%bl
  80149d:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a2:	0f 44 c2             	cmove  %edx,%eax
  8014a5:	eb 41                	jmp    8014e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	ff 36                	pushl  (%esi)
  8014b0:	e8 63 ff ff ff       	call   801418 <dev_lookup>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 1a                	js     8014d8 <fd_close+0x6a>
		if (dev->dev_close)
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	74 0b                	je     8014d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	56                   	push   %esi
  8014d1:	ff d0                	call   *%eax
  8014d3:	89 c3                	mov    %eax,%ebx
  8014d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	56                   	push   %esi
  8014dc:	6a 00                	push   $0x0
  8014de:	e8 21 f7 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	89 d8                	mov    %ebx,%eax
}
  8014e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014eb:	5b                   	pop    %ebx
  8014ec:	5e                   	pop    %esi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    

008014ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f8:	50                   	push   %eax
  8014f9:	ff 75 08             	pushl  0x8(%ebp)
  8014fc:	e8 c1 fe ff ff       	call   8013c2 <fd_lookup>
  801501:	83 c4 08             	add    $0x8,%esp
  801504:	85 c0                	test   %eax,%eax
  801506:	78 10                	js     801518 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	6a 01                	push   $0x1
  80150d:	ff 75 f4             	pushl  -0xc(%ebp)
  801510:	e8 59 ff ff ff       	call   80146e <fd_close>
  801515:	83 c4 10             	add    $0x10,%esp
}
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <close_all>:

void
close_all(void)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	53                   	push   %ebx
  80151e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801521:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801526:	83 ec 0c             	sub    $0xc,%esp
  801529:	53                   	push   %ebx
  80152a:	e8 c0 ff ff ff       	call   8014ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80152f:	83 c3 01             	add    $0x1,%ebx
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	83 fb 20             	cmp    $0x20,%ebx
  801538:	75 ec                	jne    801526 <close_all+0xc>
		close(i);
}
  80153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	57                   	push   %edi
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	83 ec 2c             	sub    $0x2c,%esp
  801548:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80154b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	ff 75 08             	pushl  0x8(%ebp)
  801552:	e8 6b fe ff ff       	call   8013c2 <fd_lookup>
  801557:	83 c4 08             	add    $0x8,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	0f 88 c1 00 00 00    	js     801623 <dup+0xe4>
		return r;
	close(newfdnum);
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	56                   	push   %esi
  801566:	e8 84 ff ff ff       	call   8014ef <close>

	newfd = INDEX2FD(newfdnum);
  80156b:	89 f3                	mov    %esi,%ebx
  80156d:	c1 e3 0c             	shl    $0xc,%ebx
  801570:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801576:	83 c4 04             	add    $0x4,%esp
  801579:	ff 75 e4             	pushl  -0x1c(%ebp)
  80157c:	e8 db fd ff ff       	call   80135c <fd2data>
  801581:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801583:	89 1c 24             	mov    %ebx,(%esp)
  801586:	e8 d1 fd ff ff       	call   80135c <fd2data>
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801591:	89 f8                	mov    %edi,%eax
  801593:	c1 e8 16             	shr    $0x16,%eax
  801596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80159d:	a8 01                	test   $0x1,%al
  80159f:	74 37                	je     8015d8 <dup+0x99>
  8015a1:	89 f8                	mov    %edi,%eax
  8015a3:	c1 e8 0c             	shr    $0xc,%eax
  8015a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015ad:	f6 c2 01             	test   $0x1,%dl
  8015b0:	74 26                	je     8015d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b9:	83 ec 0c             	sub    $0xc,%esp
  8015bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c1:	50                   	push   %eax
  8015c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015c5:	6a 00                	push   $0x0
  8015c7:	57                   	push   %edi
  8015c8:	6a 00                	push   $0x0
  8015ca:	e8 f3 f5 ff ff       	call   800bc2 <sys_page_map>
  8015cf:	89 c7                	mov    %eax,%edi
  8015d1:	83 c4 20             	add    $0x20,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 2e                	js     801606 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015db:	89 d0                	mov    %edx,%eax
  8015dd:	c1 e8 0c             	shr    $0xc,%eax
  8015e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ef:	50                   	push   %eax
  8015f0:	53                   	push   %ebx
  8015f1:	6a 00                	push   $0x0
  8015f3:	52                   	push   %edx
  8015f4:	6a 00                	push   $0x0
  8015f6:	e8 c7 f5 ff ff       	call   800bc2 <sys_page_map>
  8015fb:	89 c7                	mov    %eax,%edi
  8015fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801600:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801602:	85 ff                	test   %edi,%edi
  801604:	79 1d                	jns    801623 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	53                   	push   %ebx
  80160a:	6a 00                	push   $0x0
  80160c:	e8 f3 f5 ff ff       	call   800c04 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801611:	83 c4 08             	add    $0x8,%esp
  801614:	ff 75 d4             	pushl  -0x2c(%ebp)
  801617:	6a 00                	push   $0x0
  801619:	e8 e6 f5 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	89 f8                	mov    %edi,%eax
}
  801623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5f                   	pop    %edi
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    

0080162b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	53                   	push   %ebx
  80162f:	83 ec 14             	sub    $0x14,%esp
  801632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	53                   	push   %ebx
  80163a:	e8 83 fd ff ff       	call   8013c2 <fd_lookup>
  80163f:	83 c4 08             	add    $0x8,%esp
  801642:	89 c2                	mov    %eax,%edx
  801644:	85 c0                	test   %eax,%eax
  801646:	78 70                	js     8016b8 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	ff 30                	pushl  (%eax)
  801654:	e8 bf fd ff ff       	call   801418 <dev_lookup>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 4f                	js     8016af <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801663:	8b 42 08             	mov    0x8(%edx),%eax
  801666:	83 e0 03             	and    $0x3,%eax
  801669:	83 f8 01             	cmp    $0x1,%eax
  80166c:	75 24                	jne    801692 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80166e:	a1 04 40 80 00       	mov    0x804004,%eax
  801673:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	53                   	push   %ebx
  80167d:	50                   	push   %eax
  80167e:	68 09 2a 80 00       	push   $0x802a09
  801683:	e8 6f eb ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801690:	eb 26                	jmp    8016b8 <read+0x8d>
	}
	if (!dev->dev_read)
  801692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801695:	8b 40 08             	mov    0x8(%eax),%eax
  801698:	85 c0                	test   %eax,%eax
  80169a:	74 17                	je     8016b3 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80169c:	83 ec 04             	sub    $0x4,%esp
  80169f:	ff 75 10             	pushl  0x10(%ebp)
  8016a2:	ff 75 0c             	pushl  0xc(%ebp)
  8016a5:	52                   	push   %edx
  8016a6:	ff d0                	call   *%eax
  8016a8:	89 c2                	mov    %eax,%edx
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	eb 09                	jmp    8016b8 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	eb 05                	jmp    8016b8 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016b8:	89 d0                	mov    %edx,%eax
  8016ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	57                   	push   %edi
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 0c             	sub    $0xc,%esp
  8016c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d3:	eb 21                	jmp    8016f6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016d5:	83 ec 04             	sub    $0x4,%esp
  8016d8:	89 f0                	mov    %esi,%eax
  8016da:	29 d8                	sub    %ebx,%eax
  8016dc:	50                   	push   %eax
  8016dd:	89 d8                	mov    %ebx,%eax
  8016df:	03 45 0c             	add    0xc(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	57                   	push   %edi
  8016e4:	e8 42 ff ff ff       	call   80162b <read>
		if (m < 0)
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 10                	js     801700 <readn+0x41>
			return m;
		if (m == 0)
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	74 0a                	je     8016fe <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f4:	01 c3                	add    %eax,%ebx
  8016f6:	39 f3                	cmp    %esi,%ebx
  8016f8:	72 db                	jb     8016d5 <readn+0x16>
  8016fa:	89 d8                	mov    %ebx,%eax
  8016fc:	eb 02                	jmp    801700 <readn+0x41>
  8016fe:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5f                   	pop    %edi
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	53                   	push   %ebx
  80170c:	83 ec 14             	sub    $0x14,%esp
  80170f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801712:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801715:	50                   	push   %eax
  801716:	53                   	push   %ebx
  801717:	e8 a6 fc ff ff       	call   8013c2 <fd_lookup>
  80171c:	83 c4 08             	add    $0x8,%esp
  80171f:	89 c2                	mov    %eax,%edx
  801721:	85 c0                	test   %eax,%eax
  801723:	78 6b                	js     801790 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172f:	ff 30                	pushl  (%eax)
  801731:	e8 e2 fc ff ff       	call   801418 <dev_lookup>
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 4a                	js     801787 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801740:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801744:	75 24                	jne    80176a <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801746:	a1 04 40 80 00       	mov    0x804004,%eax
  80174b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801751:	83 ec 04             	sub    $0x4,%esp
  801754:	53                   	push   %ebx
  801755:	50                   	push   %eax
  801756:	68 25 2a 80 00       	push   $0x802a25
  80175b:	e8 97 ea ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801768:	eb 26                	jmp    801790 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80176a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176d:	8b 52 0c             	mov    0xc(%edx),%edx
  801770:	85 d2                	test   %edx,%edx
  801772:	74 17                	je     80178b <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801774:	83 ec 04             	sub    $0x4,%esp
  801777:	ff 75 10             	pushl  0x10(%ebp)
  80177a:	ff 75 0c             	pushl  0xc(%ebp)
  80177d:	50                   	push   %eax
  80177e:	ff d2                	call   *%edx
  801780:	89 c2                	mov    %eax,%edx
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	eb 09                	jmp    801790 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801787:	89 c2                	mov    %eax,%edx
  801789:	eb 05                	jmp    801790 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80178b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801790:	89 d0                	mov    %edx,%eax
  801792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <seek>:

int
seek(int fdnum, off_t offset)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80179d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017a0:	50                   	push   %eax
  8017a1:	ff 75 08             	pushl  0x8(%ebp)
  8017a4:	e8 19 fc ff ff       	call   8013c2 <fd_lookup>
  8017a9:	83 c4 08             	add    $0x8,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 0e                	js     8017be <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017be:	c9                   	leave  
  8017bf:	c3                   	ret    

008017c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	53                   	push   %ebx
  8017c4:	83 ec 14             	sub    $0x14,%esp
  8017c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cd:	50                   	push   %eax
  8017ce:	53                   	push   %ebx
  8017cf:	e8 ee fb ff ff       	call   8013c2 <fd_lookup>
  8017d4:	83 c4 08             	add    $0x8,%esp
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	78 68                	js     801845 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e3:	50                   	push   %eax
  8017e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e7:	ff 30                	pushl  (%eax)
  8017e9:	e8 2a fc ff ff       	call   801418 <dev_lookup>
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 47                	js     80183c <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017fc:	75 24                	jne    801822 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017fe:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801803:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801809:	83 ec 04             	sub    $0x4,%esp
  80180c:	53                   	push   %ebx
  80180d:	50                   	push   %eax
  80180e:	68 e8 29 80 00       	push   $0x8029e8
  801813:	e8 df e9 ff ff       	call   8001f7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801820:	eb 23                	jmp    801845 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801822:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801825:	8b 52 18             	mov    0x18(%edx),%edx
  801828:	85 d2                	test   %edx,%edx
  80182a:	74 14                	je     801840 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	ff 75 0c             	pushl  0xc(%ebp)
  801832:	50                   	push   %eax
  801833:	ff d2                	call   *%edx
  801835:	89 c2                	mov    %eax,%edx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	eb 09                	jmp    801845 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183c:	89 c2                	mov    %eax,%edx
  80183e:	eb 05                	jmp    801845 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801840:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801845:	89 d0                	mov    %edx,%eax
  801847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	53                   	push   %ebx
  801850:	83 ec 14             	sub    $0x14,%esp
  801853:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801856:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	ff 75 08             	pushl  0x8(%ebp)
  80185d:	e8 60 fb ff ff       	call   8013c2 <fd_lookup>
  801862:	83 c4 08             	add    $0x8,%esp
  801865:	89 c2                	mov    %eax,%edx
  801867:	85 c0                	test   %eax,%eax
  801869:	78 58                	js     8018c3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801871:	50                   	push   %eax
  801872:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801875:	ff 30                	pushl  (%eax)
  801877:	e8 9c fb ff ff       	call   801418 <dev_lookup>
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 37                	js     8018ba <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801883:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801886:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80188a:	74 32                	je     8018be <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80188c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80188f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801896:	00 00 00 
	stat->st_isdir = 0;
  801899:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a0:	00 00 00 
	stat->st_dev = dev;
  8018a3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	53                   	push   %ebx
  8018ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b0:	ff 50 14             	call   *0x14(%eax)
  8018b3:	89 c2                	mov    %eax,%edx
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	eb 09                	jmp    8018c3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ba:	89 c2                	mov    %eax,%edx
  8018bc:	eb 05                	jmp    8018c3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018c3:	89 d0                	mov    %edx,%eax
  8018c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	56                   	push   %esi
  8018ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	6a 00                	push   $0x0
  8018d4:	ff 75 08             	pushl  0x8(%ebp)
  8018d7:	e8 e3 01 00 00       	call   801abf <open>
  8018dc:	89 c3                	mov    %eax,%ebx
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 1b                	js     801900 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	ff 75 0c             	pushl  0xc(%ebp)
  8018eb:	50                   	push   %eax
  8018ec:	e8 5b ff ff ff       	call   80184c <fstat>
  8018f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8018f3:	89 1c 24             	mov    %ebx,(%esp)
  8018f6:	e8 f4 fb ff ff       	call   8014ef <close>
	return r;
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	89 f0                	mov    %esi,%eax
}
  801900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801903:	5b                   	pop    %ebx
  801904:	5e                   	pop    %esi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	56                   	push   %esi
  80190b:	53                   	push   %ebx
  80190c:	89 c6                	mov    %eax,%esi
  80190e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801910:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801917:	75 12                	jne    80192b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801919:	83 ec 0c             	sub    $0xc,%esp
  80191c:	6a 01                	push   $0x1
  80191e:	e8 da 08 00 00       	call   8021fd <ipc_find_env>
  801923:	a3 00 40 80 00       	mov    %eax,0x804000
  801928:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80192b:	6a 07                	push   $0x7
  80192d:	68 00 50 80 00       	push   $0x805000
  801932:	56                   	push   %esi
  801933:	ff 35 00 40 80 00    	pushl  0x804000
  801939:	e8 5d 08 00 00       	call   80219b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80193e:	83 c4 0c             	add    $0xc,%esp
  801941:	6a 00                	push   $0x0
  801943:	53                   	push   %ebx
  801944:	6a 00                	push   $0x0
  801946:	e8 d5 07 00 00       	call   802120 <ipc_recv>
}
  80194b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194e:	5b                   	pop    %ebx
  80194f:	5e                   	pop    %esi
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801958:	8b 45 08             	mov    0x8(%ebp),%eax
  80195b:	8b 40 0c             	mov    0xc(%eax),%eax
  80195e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801963:	8b 45 0c             	mov    0xc(%ebp),%eax
  801966:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
  801970:	b8 02 00 00 00       	mov    $0x2,%eax
  801975:	e8 8d ff ff ff       	call   801907 <fsipc>
}
  80197a:	c9                   	leave  
  80197b:	c3                   	ret    

0080197c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801982:	8b 45 08             	mov    0x8(%ebp),%eax
  801985:	8b 40 0c             	mov    0xc(%eax),%eax
  801988:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80198d:	ba 00 00 00 00       	mov    $0x0,%edx
  801992:	b8 06 00 00 00       	mov    $0x6,%eax
  801997:	e8 6b ff ff ff       	call   801907 <fsipc>
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 04             	sub    $0x4,%esp
  8019a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8019bd:	e8 45 ff ff ff       	call   801907 <fsipc>
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 2c                	js     8019f2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019c6:	83 ec 08             	sub    $0x8,%esp
  8019c9:	68 00 50 80 00       	push   $0x805000
  8019ce:	53                   	push   %ebx
  8019cf:	e8 a8 ed ff ff       	call   80077c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019d4:	a1 80 50 80 00       	mov    0x805080,%eax
  8019d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019df:	a1 84 50 80 00       	mov    0x805084,%eax
  8019e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a00:	8b 55 08             	mov    0x8(%ebp),%edx
  801a03:	8b 52 0c             	mov    0xc(%edx),%edx
  801a06:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a0c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a11:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a16:	0f 47 c2             	cmova  %edx,%eax
  801a19:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a1e:	50                   	push   %eax
  801a1f:	ff 75 0c             	pushl  0xc(%ebp)
  801a22:	68 08 50 80 00       	push   $0x805008
  801a27:	e8 e2 ee ff ff       	call   80090e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a31:	b8 04 00 00 00       	mov    $0x4,%eax
  801a36:	e8 cc fe ff ff       	call   801907 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    

00801a3d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a45:	8b 45 08             	mov    0x8(%ebp),%eax
  801a48:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a50:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a56:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5b:	b8 03 00 00 00       	mov    $0x3,%eax
  801a60:	e8 a2 fe ff ff       	call   801907 <fsipc>
  801a65:	89 c3                	mov    %eax,%ebx
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 4b                	js     801ab6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a6b:	39 c6                	cmp    %eax,%esi
  801a6d:	73 16                	jae    801a85 <devfile_read+0x48>
  801a6f:	68 54 2a 80 00       	push   $0x802a54
  801a74:	68 5b 2a 80 00       	push   $0x802a5b
  801a79:	6a 7c                	push   $0x7c
  801a7b:	68 70 2a 80 00       	push   $0x802a70
  801a80:	e8 c6 05 00 00       	call   80204b <_panic>
	assert(r <= PGSIZE);
  801a85:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a8a:	7e 16                	jle    801aa2 <devfile_read+0x65>
  801a8c:	68 7b 2a 80 00       	push   $0x802a7b
  801a91:	68 5b 2a 80 00       	push   $0x802a5b
  801a96:	6a 7d                	push   $0x7d
  801a98:	68 70 2a 80 00       	push   $0x802a70
  801a9d:	e8 a9 05 00 00       	call   80204b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	50                   	push   %eax
  801aa6:	68 00 50 80 00       	push   $0x805000
  801aab:	ff 75 0c             	pushl  0xc(%ebp)
  801aae:	e8 5b ee ff ff       	call   80090e <memmove>
	return r;
  801ab3:	83 c4 10             	add    $0x10,%esp
}
  801ab6:	89 d8                	mov    %ebx,%eax
  801ab8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abb:	5b                   	pop    %ebx
  801abc:	5e                   	pop    %esi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	53                   	push   %ebx
  801ac3:	83 ec 20             	sub    $0x20,%esp
  801ac6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ac9:	53                   	push   %ebx
  801aca:	e8 74 ec ff ff       	call   800743 <strlen>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ad7:	7f 67                	jg     801b40 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adf:	50                   	push   %eax
  801ae0:	e8 8e f8 ff ff       	call   801373 <fd_alloc>
  801ae5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 57                	js     801b45 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	53                   	push   %ebx
  801af2:	68 00 50 80 00       	push   $0x805000
  801af7:	e8 80 ec ff ff       	call   80077c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b07:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0c:	e8 f6 fd ff ff       	call   801907 <fsipc>
  801b11:	89 c3                	mov    %eax,%ebx
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	79 14                	jns    801b2e <open+0x6f>
		fd_close(fd, 0);
  801b1a:	83 ec 08             	sub    $0x8,%esp
  801b1d:	6a 00                	push   $0x0
  801b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b22:	e8 47 f9 ff ff       	call   80146e <fd_close>
		return r;
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	89 da                	mov    %ebx,%edx
  801b2c:	eb 17                	jmp    801b45 <open+0x86>
	}

	return fd2num(fd);
  801b2e:	83 ec 0c             	sub    $0xc,%esp
  801b31:	ff 75 f4             	pushl  -0xc(%ebp)
  801b34:	e8 13 f8 ff ff       	call   80134c <fd2num>
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	eb 05                	jmp    801b45 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b40:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b45:	89 d0                	mov    %edx,%eax
  801b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b52:	ba 00 00 00 00       	mov    $0x0,%edx
  801b57:	b8 08 00 00 00       	mov    $0x8,%eax
  801b5c:	e8 a6 fd ff ff       	call   801907 <fsipc>
}
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    

00801b63 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	ff 75 08             	pushl  0x8(%ebp)
  801b71:	e8 e6 f7 ff ff       	call   80135c <fd2data>
  801b76:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b78:	83 c4 08             	add    $0x8,%esp
  801b7b:	68 87 2a 80 00       	push   $0x802a87
  801b80:	53                   	push   %ebx
  801b81:	e8 f6 eb ff ff       	call   80077c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b86:	8b 46 04             	mov    0x4(%esi),%eax
  801b89:	2b 06                	sub    (%esi),%eax
  801b8b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b91:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b98:	00 00 00 
	stat->st_dev = &devpipe;
  801b9b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ba2:	30 80 00 
	return 0;
}
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  801baa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bbb:	53                   	push   %ebx
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 41 f0 ff ff       	call   800c04 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc3:	89 1c 24             	mov    %ebx,(%esp)
  801bc6:	e8 91 f7 ff ff       	call   80135c <fd2data>
  801bcb:	83 c4 08             	add    $0x8,%esp
  801bce:	50                   	push   %eax
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 2e f0 ff ff       	call   800c04 <sys_page_unmap>
}
  801bd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	57                   	push   %edi
  801bdf:	56                   	push   %esi
  801be0:	53                   	push   %ebx
  801be1:	83 ec 1c             	sub    $0x1c,%esp
  801be4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801be7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801be9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bee:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bf4:	83 ec 0c             	sub    $0xc,%esp
  801bf7:	ff 75 e0             	pushl  -0x20(%ebp)
  801bfa:	e8 43 06 00 00       	call   802242 <pageref>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	89 3c 24             	mov    %edi,(%esp)
  801c04:	e8 39 06 00 00       	call   802242 <pageref>
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	39 c3                	cmp    %eax,%ebx
  801c0e:	0f 94 c1             	sete   %cl
  801c11:	0f b6 c9             	movzbl %cl,%ecx
  801c14:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c17:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c1d:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801c23:	39 ce                	cmp    %ecx,%esi
  801c25:	74 1e                	je     801c45 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801c27:	39 c3                	cmp    %eax,%ebx
  801c29:	75 be                	jne    801be9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c2b:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801c31:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c34:	50                   	push   %eax
  801c35:	56                   	push   %esi
  801c36:	68 8e 2a 80 00       	push   $0x802a8e
  801c3b:	e8 b7 e5 ff ff       	call   8001f7 <cprintf>
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	eb a4                	jmp    801be9 <_pipeisclosed+0xe>
	}
}
  801c45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	5f                   	pop    %edi
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	57                   	push   %edi
  801c54:	56                   	push   %esi
  801c55:	53                   	push   %ebx
  801c56:	83 ec 28             	sub    $0x28,%esp
  801c59:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c5c:	56                   	push   %esi
  801c5d:	e8 fa f6 ff ff       	call   80135c <fd2data>
  801c62:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	bf 00 00 00 00       	mov    $0x0,%edi
  801c6c:	eb 4b                	jmp    801cb9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c6e:	89 da                	mov    %ebx,%edx
  801c70:	89 f0                	mov    %esi,%eax
  801c72:	e8 64 ff ff ff       	call   801bdb <_pipeisclosed>
  801c77:	85 c0                	test   %eax,%eax
  801c79:	75 48                	jne    801cc3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c7b:	e8 e0 ee ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c80:	8b 43 04             	mov    0x4(%ebx),%eax
  801c83:	8b 0b                	mov    (%ebx),%ecx
  801c85:	8d 51 20             	lea    0x20(%ecx),%edx
  801c88:	39 d0                	cmp    %edx,%eax
  801c8a:	73 e2                	jae    801c6e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c96:	89 c2                	mov    %eax,%edx
  801c98:	c1 fa 1f             	sar    $0x1f,%edx
  801c9b:	89 d1                	mov    %edx,%ecx
  801c9d:	c1 e9 1b             	shr    $0x1b,%ecx
  801ca0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ca3:	83 e2 1f             	and    $0x1f,%edx
  801ca6:	29 ca                	sub    %ecx,%edx
  801ca8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cb0:	83 c0 01             	add    $0x1,%eax
  801cb3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cb6:	83 c7 01             	add    $0x1,%edi
  801cb9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cbc:	75 c2                	jne    801c80 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cbe:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc1:	eb 05                	jmp    801cc8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5f                   	pop    %edi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	57                   	push   %edi
  801cd4:	56                   	push   %esi
  801cd5:	53                   	push   %ebx
  801cd6:	83 ec 18             	sub    $0x18,%esp
  801cd9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cdc:	57                   	push   %edi
  801cdd:	e8 7a f6 ff ff       	call   80135c <fd2data>
  801ce2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cec:	eb 3d                	jmp    801d2b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cee:	85 db                	test   %ebx,%ebx
  801cf0:	74 04                	je     801cf6 <devpipe_read+0x26>
				return i;
  801cf2:	89 d8                	mov    %ebx,%eax
  801cf4:	eb 44                	jmp    801d3a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cf6:	89 f2                	mov    %esi,%edx
  801cf8:	89 f8                	mov    %edi,%eax
  801cfa:	e8 dc fe ff ff       	call   801bdb <_pipeisclosed>
  801cff:	85 c0                	test   %eax,%eax
  801d01:	75 32                	jne    801d35 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d03:	e8 58 ee ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d08:	8b 06                	mov    (%esi),%eax
  801d0a:	3b 46 04             	cmp    0x4(%esi),%eax
  801d0d:	74 df                	je     801cee <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d0f:	99                   	cltd   
  801d10:	c1 ea 1b             	shr    $0x1b,%edx
  801d13:	01 d0                	add    %edx,%eax
  801d15:	83 e0 1f             	and    $0x1f,%eax
  801d18:	29 d0                	sub    %edx,%eax
  801d1a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d22:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d25:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d28:	83 c3 01             	add    $0x1,%ebx
  801d2b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d2e:	75 d8                	jne    801d08 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d30:	8b 45 10             	mov    0x10(%ebp),%eax
  801d33:	eb 05                	jmp    801d3a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    

00801d42 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	56                   	push   %esi
  801d46:	53                   	push   %ebx
  801d47:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4d:	50                   	push   %eax
  801d4e:	e8 20 f6 ff ff       	call   801373 <fd_alloc>
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	89 c2                	mov    %eax,%edx
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	0f 88 2c 01 00 00    	js     801e8c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d60:	83 ec 04             	sub    $0x4,%esp
  801d63:	68 07 04 00 00       	push   $0x407
  801d68:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6b:	6a 00                	push   $0x0
  801d6d:	e8 0d ee ff ff       	call   800b7f <sys_page_alloc>
  801d72:	83 c4 10             	add    $0x10,%esp
  801d75:	89 c2                	mov    %eax,%edx
  801d77:	85 c0                	test   %eax,%eax
  801d79:	0f 88 0d 01 00 00    	js     801e8c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d7f:	83 ec 0c             	sub    $0xc,%esp
  801d82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d85:	50                   	push   %eax
  801d86:	e8 e8 f5 ff ff       	call   801373 <fd_alloc>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	0f 88 e2 00 00 00    	js     801e7a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d98:	83 ec 04             	sub    $0x4,%esp
  801d9b:	68 07 04 00 00       	push   $0x407
  801da0:	ff 75 f0             	pushl  -0x10(%ebp)
  801da3:	6a 00                	push   $0x0
  801da5:	e8 d5 ed ff ff       	call   800b7f <sys_page_alloc>
  801daa:	89 c3                	mov    %eax,%ebx
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	85 c0                	test   %eax,%eax
  801db1:	0f 88 c3 00 00 00    	js     801e7a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801db7:	83 ec 0c             	sub    $0xc,%esp
  801dba:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbd:	e8 9a f5 ff ff       	call   80135c <fd2data>
  801dc2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc4:	83 c4 0c             	add    $0xc,%esp
  801dc7:	68 07 04 00 00       	push   $0x407
  801dcc:	50                   	push   %eax
  801dcd:	6a 00                	push   $0x0
  801dcf:	e8 ab ed ff ff       	call   800b7f <sys_page_alloc>
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	0f 88 89 00 00 00    	js     801e6a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de1:	83 ec 0c             	sub    $0xc,%esp
  801de4:	ff 75 f0             	pushl  -0x10(%ebp)
  801de7:	e8 70 f5 ff ff       	call   80135c <fd2data>
  801dec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801df3:	50                   	push   %eax
  801df4:	6a 00                	push   $0x0
  801df6:	56                   	push   %esi
  801df7:	6a 00                	push   $0x0
  801df9:	e8 c4 ed ff ff       	call   800bc2 <sys_page_map>
  801dfe:	89 c3                	mov    %eax,%ebx
  801e00:	83 c4 20             	add    $0x20,%esp
  801e03:	85 c0                	test   %eax,%eax
  801e05:	78 55                	js     801e5c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e10:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e15:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e25:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e2a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e31:	83 ec 0c             	sub    $0xc,%esp
  801e34:	ff 75 f4             	pushl  -0xc(%ebp)
  801e37:	e8 10 f5 ff ff       	call   80134c <fd2num>
  801e3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e41:	83 c4 04             	add    $0x4,%esp
  801e44:	ff 75 f0             	pushl  -0x10(%ebp)
  801e47:	e8 00 f5 ff ff       	call   80134c <fd2num>
  801e4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e4f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	ba 00 00 00 00       	mov    $0x0,%edx
  801e5a:	eb 30                	jmp    801e8c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e5c:	83 ec 08             	sub    $0x8,%esp
  801e5f:	56                   	push   %esi
  801e60:	6a 00                	push   $0x0
  801e62:	e8 9d ed ff ff       	call   800c04 <sys_page_unmap>
  801e67:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e6a:	83 ec 08             	sub    $0x8,%esp
  801e6d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e70:	6a 00                	push   $0x0
  801e72:	e8 8d ed ff ff       	call   800c04 <sys_page_unmap>
  801e77:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e7a:	83 ec 08             	sub    $0x8,%esp
  801e7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e80:	6a 00                	push   $0x0
  801e82:	e8 7d ed ff ff       	call   800c04 <sys_page_unmap>
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e8c:	89 d0                	mov    %edx,%eax
  801e8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	ff 75 08             	pushl  0x8(%ebp)
  801ea2:	e8 1b f5 ff ff       	call   8013c2 <fd_lookup>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	78 18                	js     801ec6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb4:	e8 a3 f4 ff ff       	call   80135c <fd2data>
	return _pipeisclosed(fd, p);
  801eb9:	89 c2                	mov    %eax,%edx
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	e8 18 fd ff ff       	call   801bdb <_pipeisclosed>
  801ec3:	83 c4 10             	add    $0x10,%esp
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ed8:	68 a6 2a 80 00       	push   $0x802aa6
  801edd:	ff 75 0c             	pushl  0xc(%ebp)
  801ee0:	e8 97 e8 ff ff       	call   80077c <strcpy>
	return 0;
}
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	57                   	push   %edi
  801ef0:	56                   	push   %esi
  801ef1:	53                   	push   %ebx
  801ef2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801efd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f03:	eb 2d                	jmp    801f32 <devcons_write+0x46>
		m = n - tot;
  801f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f08:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f0a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f0d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f12:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f15:	83 ec 04             	sub    $0x4,%esp
  801f18:	53                   	push   %ebx
  801f19:	03 45 0c             	add    0xc(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	57                   	push   %edi
  801f1e:	e8 eb e9 ff ff       	call   80090e <memmove>
		sys_cputs(buf, m);
  801f23:	83 c4 08             	add    $0x8,%esp
  801f26:	53                   	push   %ebx
  801f27:	57                   	push   %edi
  801f28:	e8 96 eb ff ff       	call   800ac3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f2d:	01 de                	add    %ebx,%esi
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	89 f0                	mov    %esi,%eax
  801f34:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f37:	72 cc                	jb     801f05 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3c:	5b                   	pop    %ebx
  801f3d:	5e                   	pop    %esi
  801f3e:	5f                   	pop    %edi
  801f3f:	5d                   	pop    %ebp
  801f40:	c3                   	ret    

00801f41 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	83 ec 08             	sub    $0x8,%esp
  801f47:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f50:	74 2a                	je     801f7c <devcons_read+0x3b>
  801f52:	eb 05                	jmp    801f59 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f54:	e8 07 ec ff ff       	call   800b60 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f59:	e8 83 eb ff ff       	call   800ae1 <sys_cgetc>
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	74 f2                	je     801f54 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f62:	85 c0                	test   %eax,%eax
  801f64:	78 16                	js     801f7c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f66:	83 f8 04             	cmp    $0x4,%eax
  801f69:	74 0c                	je     801f77 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6e:	88 02                	mov    %al,(%edx)
	return 1;
  801f70:	b8 01 00 00 00       	mov    $0x1,%eax
  801f75:	eb 05                	jmp    801f7c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f77:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f7c:	c9                   	leave  
  801f7d:	c3                   	ret    

00801f7e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f84:	8b 45 08             	mov    0x8(%ebp),%eax
  801f87:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f8a:	6a 01                	push   $0x1
  801f8c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8f:	50                   	push   %eax
  801f90:	e8 2e eb ff ff       	call   800ac3 <sys_cputs>
}
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	c9                   	leave  
  801f99:	c3                   	ret    

00801f9a <getchar>:

int
getchar(void)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fa0:	6a 01                	push   $0x1
  801fa2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa5:	50                   	push   %eax
  801fa6:	6a 00                	push   $0x0
  801fa8:	e8 7e f6 ff ff       	call   80162b <read>
	if (r < 0)
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 0f                	js     801fc3 <getchar+0x29>
		return r;
	if (r < 1)
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	7e 06                	jle    801fbe <getchar+0x24>
		return -E_EOF;
	return c;
  801fb8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fbc:	eb 05                	jmp    801fc3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fbe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fce:	50                   	push   %eax
  801fcf:	ff 75 08             	pushl  0x8(%ebp)
  801fd2:	e8 eb f3 ff ff       	call   8013c2 <fd_lookup>
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	78 11                	js     801fef <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fe7:	39 10                	cmp    %edx,(%eax)
  801fe9:	0f 94 c0             	sete   %al
  801fec:	0f b6 c0             	movzbl %al,%eax
}
  801fef:	c9                   	leave  
  801ff0:	c3                   	ret    

00801ff1 <opencons>:

int
opencons(void)
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffa:	50                   	push   %eax
  801ffb:	e8 73 f3 ff ff       	call   801373 <fd_alloc>
  802000:	83 c4 10             	add    $0x10,%esp
		return r;
  802003:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802005:	85 c0                	test   %eax,%eax
  802007:	78 3e                	js     802047 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802009:	83 ec 04             	sub    $0x4,%esp
  80200c:	68 07 04 00 00       	push   $0x407
  802011:	ff 75 f4             	pushl  -0xc(%ebp)
  802014:	6a 00                	push   $0x0
  802016:	e8 64 eb ff ff       	call   800b7f <sys_page_alloc>
  80201b:	83 c4 10             	add    $0x10,%esp
		return r;
  80201e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802020:	85 c0                	test   %eax,%eax
  802022:	78 23                	js     802047 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802024:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80202a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802032:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802039:	83 ec 0c             	sub    $0xc,%esp
  80203c:	50                   	push   %eax
  80203d:	e8 0a f3 ff ff       	call   80134c <fd2num>
  802042:	89 c2                	mov    %eax,%edx
  802044:	83 c4 10             	add    $0x10,%esp
}
  802047:	89 d0                	mov    %edx,%eax
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802050:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802053:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802059:	e8 e3 ea ff ff       	call   800b41 <sys_getenvid>
  80205e:	83 ec 0c             	sub    $0xc,%esp
  802061:	ff 75 0c             	pushl  0xc(%ebp)
  802064:	ff 75 08             	pushl  0x8(%ebp)
  802067:	56                   	push   %esi
  802068:	50                   	push   %eax
  802069:	68 b4 2a 80 00       	push   $0x802ab4
  80206e:	e8 84 e1 ff ff       	call   8001f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802073:	83 c4 18             	add    $0x18,%esp
  802076:	53                   	push   %ebx
  802077:	ff 75 10             	pushl  0x10(%ebp)
  80207a:	e8 27 e1 ff ff       	call   8001a6 <vcprintf>
	cprintf("\n");
  80207f:	c7 04 24 06 29 80 00 	movl   $0x802906,(%esp)
  802086:	e8 6c e1 ff ff       	call   8001f7 <cprintf>
  80208b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80208e:	cc                   	int3   
  80208f:	eb fd                	jmp    80208e <_panic+0x43>

00802091 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802091:	55                   	push   %ebp
  802092:	89 e5                	mov    %esp,%ebp
  802094:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802097:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80209e:	75 2a                	jne    8020ca <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8020a0:	83 ec 04             	sub    $0x4,%esp
  8020a3:	6a 07                	push   $0x7
  8020a5:	68 00 f0 bf ee       	push   $0xeebff000
  8020aa:	6a 00                	push   $0x0
  8020ac:	e8 ce ea ff ff       	call   800b7f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	79 12                	jns    8020ca <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8020b8:	50                   	push   %eax
  8020b9:	68 38 29 80 00       	push   $0x802938
  8020be:	6a 23                	push   $0x23
  8020c0:	68 d8 2a 80 00       	push   $0x802ad8
  8020c5:	e8 81 ff ff ff       	call   80204b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cd:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8020d2:	83 ec 08             	sub    $0x8,%esp
  8020d5:	68 fc 20 80 00       	push   $0x8020fc
  8020da:	6a 00                	push   $0x0
  8020dc:	e8 e9 eb ff ff       	call   800cca <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8020e1:	83 c4 10             	add    $0x10,%esp
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	79 12                	jns    8020fa <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8020e8:	50                   	push   %eax
  8020e9:	68 38 29 80 00       	push   $0x802938
  8020ee:	6a 2c                	push   $0x2c
  8020f0:	68 d8 2a 80 00       	push   $0x802ad8
  8020f5:	e8 51 ff ff ff       	call   80204b <_panic>
	}
}
  8020fa:	c9                   	leave  
  8020fb:	c3                   	ret    

008020fc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020fc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020fd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802102:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802104:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802107:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80210b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802110:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802114:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802116:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802119:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80211a:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80211d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80211e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80211f:	c3                   	ret    

00802120 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	56                   	push   %esi
  802124:	53                   	push   %ebx
  802125:	8b 75 08             	mov    0x8(%ebp),%esi
  802128:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80212e:	85 c0                	test   %eax,%eax
  802130:	75 12                	jne    802144 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802132:	83 ec 0c             	sub    $0xc,%esp
  802135:	68 00 00 c0 ee       	push   $0xeec00000
  80213a:	e8 f0 eb ff ff       	call   800d2f <sys_ipc_recv>
  80213f:	83 c4 10             	add    $0x10,%esp
  802142:	eb 0c                	jmp    802150 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802144:	83 ec 0c             	sub    $0xc,%esp
  802147:	50                   	push   %eax
  802148:	e8 e2 eb ff ff       	call   800d2f <sys_ipc_recv>
  80214d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802150:	85 f6                	test   %esi,%esi
  802152:	0f 95 c1             	setne  %cl
  802155:	85 db                	test   %ebx,%ebx
  802157:	0f 95 c2             	setne  %dl
  80215a:	84 d1                	test   %dl,%cl
  80215c:	74 09                	je     802167 <ipc_recv+0x47>
  80215e:	89 c2                	mov    %eax,%edx
  802160:	c1 ea 1f             	shr    $0x1f,%edx
  802163:	84 d2                	test   %dl,%dl
  802165:	75 2d                	jne    802194 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802167:	85 f6                	test   %esi,%esi
  802169:	74 0d                	je     802178 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80216b:	a1 04 40 80 00       	mov    0x804004,%eax
  802170:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802176:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802178:	85 db                	test   %ebx,%ebx
  80217a:	74 0d                	je     802189 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80217c:	a1 04 40 80 00       	mov    0x804004,%eax
  802181:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802187:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802189:	a1 04 40 80 00       	mov    0x804004,%eax
  80218e:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802194:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    

0080219b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	57                   	push   %edi
  80219f:	56                   	push   %esi
  8021a0:	53                   	push   %ebx
  8021a1:	83 ec 0c             	sub    $0xc,%esp
  8021a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8021ad:	85 db                	test   %ebx,%ebx
  8021af:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021b4:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021b7:	ff 75 14             	pushl  0x14(%ebp)
  8021ba:	53                   	push   %ebx
  8021bb:	56                   	push   %esi
  8021bc:	57                   	push   %edi
  8021bd:	e8 4a eb ff ff       	call   800d0c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8021c2:	89 c2                	mov    %eax,%edx
  8021c4:	c1 ea 1f             	shr    $0x1f,%edx
  8021c7:	83 c4 10             	add    $0x10,%esp
  8021ca:	84 d2                	test   %dl,%dl
  8021cc:	74 17                	je     8021e5 <ipc_send+0x4a>
  8021ce:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021d1:	74 12                	je     8021e5 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8021d3:	50                   	push   %eax
  8021d4:	68 e6 2a 80 00       	push   $0x802ae6
  8021d9:	6a 47                	push   $0x47
  8021db:	68 f4 2a 80 00       	push   $0x802af4
  8021e0:	e8 66 fe ff ff       	call   80204b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8021e5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021e8:	75 07                	jne    8021f1 <ipc_send+0x56>
			sys_yield();
  8021ea:	e8 71 e9 ff ff       	call   800b60 <sys_yield>
  8021ef:	eb c6                	jmp    8021b7 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8021f1:	85 c0                	test   %eax,%eax
  8021f3:	75 c2                	jne    8021b7 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8021f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    

008021fd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802203:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802208:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80220e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802214:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80221a:	39 ca                	cmp    %ecx,%edx
  80221c:	75 13                	jne    802231 <ipc_find_env+0x34>
			return envs[i].env_id;
  80221e:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802224:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802229:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80222f:	eb 0f                	jmp    802240 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802231:	83 c0 01             	add    $0x1,%eax
  802234:	3d 00 04 00 00       	cmp    $0x400,%eax
  802239:	75 cd                	jne    802208 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80223b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    

00802242 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802242:	55                   	push   %ebp
  802243:	89 e5                	mov    %esp,%ebp
  802245:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802248:	89 d0                	mov    %edx,%eax
  80224a:	c1 e8 16             	shr    $0x16,%eax
  80224d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802254:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802259:	f6 c1 01             	test   $0x1,%cl
  80225c:	74 1d                	je     80227b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80225e:	c1 ea 0c             	shr    $0xc,%edx
  802261:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802268:	f6 c2 01             	test   $0x1,%dl
  80226b:	74 0e                	je     80227b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80226d:	c1 ea 0c             	shr    $0xc,%edx
  802270:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802277:	ef 
  802278:	0f b7 c0             	movzwl %ax,%eax
}
  80227b:	5d                   	pop    %ebp
  80227c:	c3                   	ret    
  80227d:	66 90                	xchg   %ax,%ax
  80227f:	90                   	nop

00802280 <__udivdi3>:
  802280:	55                   	push   %ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	53                   	push   %ebx
  802284:	83 ec 1c             	sub    $0x1c,%esp
  802287:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80228b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80228f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802297:	85 f6                	test   %esi,%esi
  802299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80229d:	89 ca                	mov    %ecx,%edx
  80229f:	89 f8                	mov    %edi,%eax
  8022a1:	75 3d                	jne    8022e0 <__udivdi3+0x60>
  8022a3:	39 cf                	cmp    %ecx,%edi
  8022a5:	0f 87 c5 00 00 00    	ja     802370 <__udivdi3+0xf0>
  8022ab:	85 ff                	test   %edi,%edi
  8022ad:	89 fd                	mov    %edi,%ebp
  8022af:	75 0b                	jne    8022bc <__udivdi3+0x3c>
  8022b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b6:	31 d2                	xor    %edx,%edx
  8022b8:	f7 f7                	div    %edi
  8022ba:	89 c5                	mov    %eax,%ebp
  8022bc:	89 c8                	mov    %ecx,%eax
  8022be:	31 d2                	xor    %edx,%edx
  8022c0:	f7 f5                	div    %ebp
  8022c2:	89 c1                	mov    %eax,%ecx
  8022c4:	89 d8                	mov    %ebx,%eax
  8022c6:	89 cf                	mov    %ecx,%edi
  8022c8:	f7 f5                	div    %ebp
  8022ca:	89 c3                	mov    %eax,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	39 ce                	cmp    %ecx,%esi
  8022e2:	77 74                	ja     802358 <__udivdi3+0xd8>
  8022e4:	0f bd fe             	bsr    %esi,%edi
  8022e7:	83 f7 1f             	xor    $0x1f,%edi
  8022ea:	0f 84 98 00 00 00    	je     802388 <__udivdi3+0x108>
  8022f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	89 c5                	mov    %eax,%ebp
  8022f9:	29 fb                	sub    %edi,%ebx
  8022fb:	d3 e6                	shl    %cl,%esi
  8022fd:	89 d9                	mov    %ebx,%ecx
  8022ff:	d3 ed                	shr    %cl,%ebp
  802301:	89 f9                	mov    %edi,%ecx
  802303:	d3 e0                	shl    %cl,%eax
  802305:	09 ee                	or     %ebp,%esi
  802307:	89 d9                	mov    %ebx,%ecx
  802309:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80230d:	89 d5                	mov    %edx,%ebp
  80230f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802313:	d3 ed                	shr    %cl,%ebp
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e2                	shl    %cl,%edx
  802319:	89 d9                	mov    %ebx,%ecx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	09 c2                	or     %eax,%edx
  80231f:	89 d0                	mov    %edx,%eax
  802321:	89 ea                	mov    %ebp,%edx
  802323:	f7 f6                	div    %esi
  802325:	89 d5                	mov    %edx,%ebp
  802327:	89 c3                	mov    %eax,%ebx
  802329:	f7 64 24 0c          	mull   0xc(%esp)
  80232d:	39 d5                	cmp    %edx,%ebp
  80232f:	72 10                	jb     802341 <__udivdi3+0xc1>
  802331:	8b 74 24 08          	mov    0x8(%esp),%esi
  802335:	89 f9                	mov    %edi,%ecx
  802337:	d3 e6                	shl    %cl,%esi
  802339:	39 c6                	cmp    %eax,%esi
  80233b:	73 07                	jae    802344 <__udivdi3+0xc4>
  80233d:	39 d5                	cmp    %edx,%ebp
  80233f:	75 03                	jne    802344 <__udivdi3+0xc4>
  802341:	83 eb 01             	sub    $0x1,%ebx
  802344:	31 ff                	xor    %edi,%edi
  802346:	89 d8                	mov    %ebx,%eax
  802348:	89 fa                	mov    %edi,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	31 ff                	xor    %edi,%edi
  80235a:	31 db                	xor    %ebx,%ebx
  80235c:	89 d8                	mov    %ebx,%eax
  80235e:	89 fa                	mov    %edi,%edx
  802360:	83 c4 1c             	add    $0x1c,%esp
  802363:	5b                   	pop    %ebx
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    
  802368:	90                   	nop
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	89 d8                	mov    %ebx,%eax
  802372:	f7 f7                	div    %edi
  802374:	31 ff                	xor    %edi,%edi
  802376:	89 c3                	mov    %eax,%ebx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 fa                	mov    %edi,%edx
  80237c:	83 c4 1c             	add    $0x1c,%esp
  80237f:	5b                   	pop    %ebx
  802380:	5e                   	pop    %esi
  802381:	5f                   	pop    %edi
  802382:	5d                   	pop    %ebp
  802383:	c3                   	ret    
  802384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802388:	39 ce                	cmp    %ecx,%esi
  80238a:	72 0c                	jb     802398 <__udivdi3+0x118>
  80238c:	31 db                	xor    %ebx,%ebx
  80238e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802392:	0f 87 34 ff ff ff    	ja     8022cc <__udivdi3+0x4c>
  802398:	bb 01 00 00 00       	mov    $0x1,%ebx
  80239d:	e9 2a ff ff ff       	jmp    8022cc <__udivdi3+0x4c>
  8023a2:	66 90                	xchg   %ax,%ax
  8023a4:	66 90                	xchg   %ax,%ax
  8023a6:	66 90                	xchg   %ax,%ax
  8023a8:	66 90                	xchg   %ax,%ax
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__umoddi3>:
  8023b0:	55                   	push   %ebp
  8023b1:	57                   	push   %edi
  8023b2:	56                   	push   %esi
  8023b3:	53                   	push   %ebx
  8023b4:	83 ec 1c             	sub    $0x1c,%esp
  8023b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023c7:	85 d2                	test   %edx,%edx
  8023c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023d1:	89 f3                	mov    %esi,%ebx
  8023d3:	89 3c 24             	mov    %edi,(%esp)
  8023d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023da:	75 1c                	jne    8023f8 <__umoddi3+0x48>
  8023dc:	39 f7                	cmp    %esi,%edi
  8023de:	76 50                	jbe    802430 <__umoddi3+0x80>
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	f7 f7                	div    %edi
  8023e6:	89 d0                	mov    %edx,%eax
  8023e8:	31 d2                	xor    %edx,%edx
  8023ea:	83 c4 1c             	add    $0x1c,%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    
  8023f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f8:	39 f2                	cmp    %esi,%edx
  8023fa:	89 d0                	mov    %edx,%eax
  8023fc:	77 52                	ja     802450 <__umoddi3+0xa0>
  8023fe:	0f bd ea             	bsr    %edx,%ebp
  802401:	83 f5 1f             	xor    $0x1f,%ebp
  802404:	75 5a                	jne    802460 <__umoddi3+0xb0>
  802406:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80240a:	0f 82 e0 00 00 00    	jb     8024f0 <__umoddi3+0x140>
  802410:	39 0c 24             	cmp    %ecx,(%esp)
  802413:	0f 86 d7 00 00 00    	jbe    8024f0 <__umoddi3+0x140>
  802419:	8b 44 24 08          	mov    0x8(%esp),%eax
  80241d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802421:	83 c4 1c             	add    $0x1c,%esp
  802424:	5b                   	pop    %ebx
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	85 ff                	test   %edi,%edi
  802432:	89 fd                	mov    %edi,%ebp
  802434:	75 0b                	jne    802441 <__umoddi3+0x91>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f7                	div    %edi
  80243f:	89 c5                	mov    %eax,%ebp
  802441:	89 f0                	mov    %esi,%eax
  802443:	31 d2                	xor    %edx,%edx
  802445:	f7 f5                	div    %ebp
  802447:	89 c8                	mov    %ecx,%eax
  802449:	f7 f5                	div    %ebp
  80244b:	89 d0                	mov    %edx,%eax
  80244d:	eb 99                	jmp    8023e8 <__umoddi3+0x38>
  80244f:	90                   	nop
  802450:	89 c8                	mov    %ecx,%eax
  802452:	89 f2                	mov    %esi,%edx
  802454:	83 c4 1c             	add    $0x1c,%esp
  802457:	5b                   	pop    %ebx
  802458:	5e                   	pop    %esi
  802459:	5f                   	pop    %edi
  80245a:	5d                   	pop    %ebp
  80245b:	c3                   	ret    
  80245c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802460:	8b 34 24             	mov    (%esp),%esi
  802463:	bf 20 00 00 00       	mov    $0x20,%edi
  802468:	89 e9                	mov    %ebp,%ecx
  80246a:	29 ef                	sub    %ebp,%edi
  80246c:	d3 e0                	shl    %cl,%eax
  80246e:	89 f9                	mov    %edi,%ecx
  802470:	89 f2                	mov    %esi,%edx
  802472:	d3 ea                	shr    %cl,%edx
  802474:	89 e9                	mov    %ebp,%ecx
  802476:	09 c2                	or     %eax,%edx
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	89 14 24             	mov    %edx,(%esp)
  80247d:	89 f2                	mov    %esi,%edx
  80247f:	d3 e2                	shl    %cl,%edx
  802481:	89 f9                	mov    %edi,%ecx
  802483:	89 54 24 04          	mov    %edx,0x4(%esp)
  802487:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80248b:	d3 e8                	shr    %cl,%eax
  80248d:	89 e9                	mov    %ebp,%ecx
  80248f:	89 c6                	mov    %eax,%esi
  802491:	d3 e3                	shl    %cl,%ebx
  802493:	89 f9                	mov    %edi,%ecx
  802495:	89 d0                	mov    %edx,%eax
  802497:	d3 e8                	shr    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	09 d8                	or     %ebx,%eax
  80249d:	89 d3                	mov    %edx,%ebx
  80249f:	89 f2                	mov    %esi,%edx
  8024a1:	f7 34 24             	divl   (%esp)
  8024a4:	89 d6                	mov    %edx,%esi
  8024a6:	d3 e3                	shl    %cl,%ebx
  8024a8:	f7 64 24 04          	mull   0x4(%esp)
  8024ac:	39 d6                	cmp    %edx,%esi
  8024ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024b2:	89 d1                	mov    %edx,%ecx
  8024b4:	89 c3                	mov    %eax,%ebx
  8024b6:	72 08                	jb     8024c0 <__umoddi3+0x110>
  8024b8:	75 11                	jne    8024cb <__umoddi3+0x11b>
  8024ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024be:	73 0b                	jae    8024cb <__umoddi3+0x11b>
  8024c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024c4:	1b 14 24             	sbb    (%esp),%edx
  8024c7:	89 d1                	mov    %edx,%ecx
  8024c9:	89 c3                	mov    %eax,%ebx
  8024cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024cf:	29 da                	sub    %ebx,%edx
  8024d1:	19 ce                	sbb    %ecx,%esi
  8024d3:	89 f9                	mov    %edi,%ecx
  8024d5:	89 f0                	mov    %esi,%eax
  8024d7:	d3 e0                	shl    %cl,%eax
  8024d9:	89 e9                	mov    %ebp,%ecx
  8024db:	d3 ea                	shr    %cl,%edx
  8024dd:	89 e9                	mov    %ebp,%ecx
  8024df:	d3 ee                	shr    %cl,%esi
  8024e1:	09 d0                	or     %edx,%eax
  8024e3:	89 f2                	mov    %esi,%edx
  8024e5:	83 c4 1c             	add    $0x1c,%esp
  8024e8:	5b                   	pop    %ebx
  8024e9:	5e                   	pop    %esi
  8024ea:	5f                   	pop    %edi
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    
  8024ed:	8d 76 00             	lea    0x0(%esi),%esi
  8024f0:	29 f9                	sub    %edi,%ecx
  8024f2:	19 d6                	sbb    %edx,%esi
  8024f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024fc:	e9 18 ff ff ff       	jmp    802419 <__umoddi3+0x69>
