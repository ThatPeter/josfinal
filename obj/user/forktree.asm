
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
  800047:	68 60 22 80 00       	push   $0x802260
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
  800095:	68 71 22 80 00       	push   $0x802271
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 84 06 00 00       	call   800729 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 d9 0d 00 00       	call   800e86 <fork>
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
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 50 0a 00 00       	call   800b41 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  800150:	e8 1a 11 00 00       	call   80126f <close_all>
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
  80025a:	e8 71 1d 00 00       	call   801fd0 <__udivdi3>
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
  80029d:	e8 5e 1e 00 00       	call   802100 <__umoddi3>
  8002a2:	83 c4 14             	add    $0x14,%esp
  8002a5:	0f be 80 80 22 80 00 	movsbl 0x802280(%eax),%eax
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
  8003a1:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  800465:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80046c:	85 d2                	test   %edx,%edx
  80046e:	75 18                	jne    800488 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800470:	50                   	push   %eax
  800471:	68 98 22 80 00       	push   $0x802298
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
  800489:	68 cd 26 80 00       	push   $0x8026cd
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
  8004ad:	b8 91 22 80 00       	mov    $0x802291,%eax
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
  800b28:	68 7f 25 80 00       	push   $0x80257f
  800b2d:	6a 23                	push   $0x23
  800b2f:	68 9c 25 80 00       	push   $0x80259c
  800b34:	e8 5e 12 00 00       	call   801d97 <_panic>

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
  800ba9:	68 7f 25 80 00       	push   $0x80257f
  800bae:	6a 23                	push   $0x23
  800bb0:	68 9c 25 80 00       	push   $0x80259c
  800bb5:	e8 dd 11 00 00       	call   801d97 <_panic>

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
  800beb:	68 7f 25 80 00       	push   $0x80257f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 9c 25 80 00       	push   $0x80259c
  800bf7:	e8 9b 11 00 00       	call   801d97 <_panic>

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
  800c2d:	68 7f 25 80 00       	push   $0x80257f
  800c32:	6a 23                	push   $0x23
  800c34:	68 9c 25 80 00       	push   $0x80259c
  800c39:	e8 59 11 00 00       	call   801d97 <_panic>

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
  800c6f:	68 7f 25 80 00       	push   $0x80257f
  800c74:	6a 23                	push   $0x23
  800c76:	68 9c 25 80 00       	push   $0x80259c
  800c7b:	e8 17 11 00 00       	call   801d97 <_panic>

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
  800cb1:	68 7f 25 80 00       	push   $0x80257f
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 9c 25 80 00       	push   $0x80259c
  800cbd:	e8 d5 10 00 00       	call   801d97 <_panic>
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
  800cf3:	68 7f 25 80 00       	push   $0x80257f
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 9c 25 80 00       	push   $0x80259c
  800cff:	e8 93 10 00 00       	call   801d97 <_panic>

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
  800d57:	68 7f 25 80 00       	push   $0x80257f
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 9c 25 80 00       	push   $0x80259c
  800d63:	e8 2f 10 00 00       	call   801d97 <_panic>

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

00800db0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	53                   	push   %ebx
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dba:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dbc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc0:	74 11                	je     800dd3 <pgfault+0x23>
  800dc2:	89 d8                	mov    %ebx,%eax
  800dc4:	c1 e8 0c             	shr    $0xc,%eax
  800dc7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dce:	f6 c4 08             	test   $0x8,%ah
  800dd1:	75 14                	jne    800de7 <pgfault+0x37>
		panic("faulting access");
  800dd3:	83 ec 04             	sub    $0x4,%esp
  800dd6:	68 aa 25 80 00       	push   $0x8025aa
  800ddb:	6a 1e                	push   $0x1e
  800ddd:	68 ba 25 80 00       	push   $0x8025ba
  800de2:	e8 b0 0f 00 00       	call   801d97 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	6a 07                	push   $0x7
  800dec:	68 00 f0 7f 00       	push   $0x7ff000
  800df1:	6a 00                	push   $0x0
  800df3:	e8 87 fd ff ff       	call   800b7f <sys_page_alloc>
	if (r < 0) {
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	79 12                	jns    800e11 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800dff:	50                   	push   %eax
  800e00:	68 c5 25 80 00       	push   $0x8025c5
  800e05:	6a 2c                	push   $0x2c
  800e07:	68 ba 25 80 00       	push   $0x8025ba
  800e0c:	e8 86 0f 00 00       	call   801d97 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e11:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	68 00 10 00 00       	push   $0x1000
  800e1f:	53                   	push   %ebx
  800e20:	68 00 f0 7f 00       	push   $0x7ff000
  800e25:	e8 4c fb ff ff       	call   800976 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e2a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e31:	53                   	push   %ebx
  800e32:	6a 00                	push   $0x0
  800e34:	68 00 f0 7f 00       	push   $0x7ff000
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 82 fd ff ff       	call   800bc2 <sys_page_map>
	if (r < 0) {
  800e40:	83 c4 20             	add    $0x20,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	79 12                	jns    800e59 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e47:	50                   	push   %eax
  800e48:	68 c5 25 80 00       	push   $0x8025c5
  800e4d:	6a 33                	push   $0x33
  800e4f:	68 ba 25 80 00       	push   $0x8025ba
  800e54:	e8 3e 0f 00 00       	call   801d97 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e59:	83 ec 08             	sub    $0x8,%esp
  800e5c:	68 00 f0 7f 00       	push   $0x7ff000
  800e61:	6a 00                	push   $0x0
  800e63:	e8 9c fd ff ff       	call   800c04 <sys_page_unmap>
	if (r < 0) {
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	79 12                	jns    800e81 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e6f:	50                   	push   %eax
  800e70:	68 c5 25 80 00       	push   $0x8025c5
  800e75:	6a 37                	push   $0x37
  800e77:	68 ba 25 80 00       	push   $0x8025ba
  800e7c:	e8 16 0f 00 00       	call   801d97 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e8f:	68 b0 0d 80 00       	push   $0x800db0
  800e94:	e8 44 0f 00 00       	call   801ddd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e99:	b8 07 00 00 00       	mov    $0x7,%eax
  800e9e:	cd 30                	int    $0x30
  800ea0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ea3:	83 c4 10             	add    $0x10,%esp
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	79 17                	jns    800ec1 <fork+0x3b>
		panic("fork fault %e");
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	68 de 25 80 00       	push   $0x8025de
  800eb2:	68 84 00 00 00       	push   $0x84
  800eb7:	68 ba 25 80 00       	push   $0x8025ba
  800ebc:	e8 d6 0e 00 00       	call   801d97 <_panic>
  800ec1:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ec3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec7:	75 24                	jne    800eed <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec9:	e8 73 fc ff ff       	call   800b41 <sys_getenvid>
  800ece:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800ed9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ede:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	e9 64 01 00 00       	jmp    801051 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800eed:	83 ec 04             	sub    $0x4,%esp
  800ef0:	6a 07                	push   $0x7
  800ef2:	68 00 f0 bf ee       	push   $0xeebff000
  800ef7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800efa:	e8 80 fc ff ff       	call   800b7f <sys_page_alloc>
  800eff:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f02:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f07:	89 d8                	mov    %ebx,%eax
  800f09:	c1 e8 16             	shr    $0x16,%eax
  800f0c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f13:	a8 01                	test   $0x1,%al
  800f15:	0f 84 fc 00 00 00    	je     801017 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f1b:	89 d8                	mov    %ebx,%eax
  800f1d:	c1 e8 0c             	shr    $0xc,%eax
  800f20:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f27:	f6 c2 01             	test   $0x1,%dl
  800f2a:	0f 84 e7 00 00 00    	je     801017 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f30:	89 c6                	mov    %eax,%esi
  800f32:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f35:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3c:	f6 c6 04             	test   $0x4,%dh
  800f3f:	74 39                	je     800f7a <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f41:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f50:	50                   	push   %eax
  800f51:	56                   	push   %esi
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	6a 00                	push   $0x0
  800f56:	e8 67 fc ff ff       	call   800bc2 <sys_page_map>
		if (r < 0) {
  800f5b:	83 c4 20             	add    $0x20,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	0f 89 b1 00 00 00    	jns    801017 <fork+0x191>
		    	panic("sys page map fault %e");
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	68 ec 25 80 00       	push   $0x8025ec
  800f6e:	6a 54                	push   $0x54
  800f70:	68 ba 25 80 00       	push   $0x8025ba
  800f75:	e8 1d 0e 00 00       	call   801d97 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f7a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f81:	f6 c2 02             	test   $0x2,%dl
  800f84:	75 0c                	jne    800f92 <fork+0x10c>
  800f86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8d:	f6 c4 08             	test   $0x8,%ah
  800f90:	74 5b                	je     800fed <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f92:	83 ec 0c             	sub    $0xc,%esp
  800f95:	68 05 08 00 00       	push   $0x805
  800f9a:	56                   	push   %esi
  800f9b:	57                   	push   %edi
  800f9c:	56                   	push   %esi
  800f9d:	6a 00                	push   $0x0
  800f9f:	e8 1e fc ff ff       	call   800bc2 <sys_page_map>
		if (r < 0) {
  800fa4:	83 c4 20             	add    $0x20,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	79 14                	jns    800fbf <fork+0x139>
		    	panic("sys page map fault %e");
  800fab:	83 ec 04             	sub    $0x4,%esp
  800fae:	68 ec 25 80 00       	push   $0x8025ec
  800fb3:	6a 5b                	push   $0x5b
  800fb5:	68 ba 25 80 00       	push   $0x8025ba
  800fba:	e8 d8 0d 00 00       	call   801d97 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	68 05 08 00 00       	push   $0x805
  800fc7:	56                   	push   %esi
  800fc8:	6a 00                	push   $0x0
  800fca:	56                   	push   %esi
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 f0 fb ff ff       	call   800bc2 <sys_page_map>
		if (r < 0) {
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	79 3e                	jns    801017 <fork+0x191>
		    	panic("sys page map fault %e");
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	68 ec 25 80 00       	push   $0x8025ec
  800fe1:	6a 5f                	push   $0x5f
  800fe3:	68 ba 25 80 00       	push   $0x8025ba
  800fe8:	e8 aa 0d 00 00       	call   801d97 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	6a 05                	push   $0x5
  800ff2:	56                   	push   %esi
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 c6 fb ff ff       	call   800bc2 <sys_page_map>
		if (r < 0) {
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	79 14                	jns    801017 <fork+0x191>
		    	panic("sys page map fault %e");
  801003:	83 ec 04             	sub    $0x4,%esp
  801006:	68 ec 25 80 00       	push   $0x8025ec
  80100b:	6a 64                	push   $0x64
  80100d:	68 ba 25 80 00       	push   $0x8025ba
  801012:	e8 80 0d 00 00       	call   801d97 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801017:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801023:	0f 85 de fe ff ff    	jne    800f07 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801029:	a1 04 40 80 00       	mov    0x804004,%eax
  80102e:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  801034:	83 ec 08             	sub    $0x8,%esp
  801037:	50                   	push   %eax
  801038:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80103b:	57                   	push   %edi
  80103c:	e8 89 fc ff ff       	call   800cca <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801041:	83 c4 08             	add    $0x8,%esp
  801044:	6a 02                	push   $0x2
  801046:	57                   	push   %edi
  801047:	e8 fa fb ff ff       	call   800c46 <sys_env_set_status>
	
	return envid;
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801051:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5f                   	pop    %edi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <sfork>:

envid_t
sfork(void)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80105c:	b8 00 00 00 00       	mov    $0x0,%eax
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80106b:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801071:	83 ec 08             	sub    $0x8,%esp
  801074:	53                   	push   %ebx
  801075:	68 04 26 80 00       	push   $0x802604
  80107a:	e8 78 f1 ff ff       	call   8001f7 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80107f:	c7 04 24 2a 01 80 00 	movl   $0x80012a,(%esp)
  801086:	e8 e5 fc ff ff       	call   800d70 <sys_thread_create>
  80108b:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80108d:	83 c4 08             	add    $0x8,%esp
  801090:	53                   	push   %ebx
  801091:	68 04 26 80 00       	push   $0x802604
  801096:	e8 5c f1 ff ff       	call   8001f7 <cprintf>
	return id;
}
  80109b:	89 f0                	mov    %esi,%eax
  80109d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8010af:	c1 e8 0c             	shr    $0xc,%eax
}
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010c4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010d6:	89 c2                	mov    %eax,%edx
  8010d8:	c1 ea 16             	shr    $0x16,%edx
  8010db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e2:	f6 c2 01             	test   $0x1,%dl
  8010e5:	74 11                	je     8010f8 <fd_alloc+0x2d>
  8010e7:	89 c2                	mov    %eax,%edx
  8010e9:	c1 ea 0c             	shr    $0xc,%edx
  8010ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f3:	f6 c2 01             	test   $0x1,%dl
  8010f6:	75 09                	jne    801101 <fd_alloc+0x36>
			*fd_store = fd;
  8010f8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ff:	eb 17                	jmp    801118 <fd_alloc+0x4d>
  801101:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801106:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80110b:	75 c9                	jne    8010d6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80110d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801113:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801120:	83 f8 1f             	cmp    $0x1f,%eax
  801123:	77 36                	ja     80115b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801125:	c1 e0 0c             	shl    $0xc,%eax
  801128:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	c1 ea 16             	shr    $0x16,%edx
  801132:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801139:	f6 c2 01             	test   $0x1,%dl
  80113c:	74 24                	je     801162 <fd_lookup+0x48>
  80113e:	89 c2                	mov    %eax,%edx
  801140:	c1 ea 0c             	shr    $0xc,%edx
  801143:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80114a:	f6 c2 01             	test   $0x1,%dl
  80114d:	74 1a                	je     801169 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80114f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801152:	89 02                	mov    %eax,(%edx)
	return 0;
  801154:	b8 00 00 00 00       	mov    $0x0,%eax
  801159:	eb 13                	jmp    80116e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80115b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801160:	eb 0c                	jmp    80116e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801162:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801167:	eb 05                	jmp    80116e <fd_lookup+0x54>
  801169:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	83 ec 08             	sub    $0x8,%esp
  801176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801179:	ba a4 26 80 00       	mov    $0x8026a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80117e:	eb 13                	jmp    801193 <dev_lookup+0x23>
  801180:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801183:	39 08                	cmp    %ecx,(%eax)
  801185:	75 0c                	jne    801193 <dev_lookup+0x23>
			*dev = devtab[i];
  801187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118c:	b8 00 00 00 00       	mov    $0x0,%eax
  801191:	eb 2e                	jmp    8011c1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801193:	8b 02                	mov    (%edx),%eax
  801195:	85 c0                	test   %eax,%eax
  801197:	75 e7                	jne    801180 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801199:	a1 04 40 80 00       	mov    0x804004,%eax
  80119e:	8b 40 7c             	mov    0x7c(%eax),%eax
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	51                   	push   %ecx
  8011a5:	50                   	push   %eax
  8011a6:	68 28 26 80 00       	push   $0x802628
  8011ab:	e8 47 f0 ff ff       	call   8001f7 <cprintf>
	*dev = 0;
  8011b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c1:	c9                   	leave  
  8011c2:	c3                   	ret    

008011c3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 10             	sub    $0x10,%esp
  8011cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011db:	c1 e8 0c             	shr    $0xc,%eax
  8011de:	50                   	push   %eax
  8011df:	e8 36 ff ff ff       	call   80111a <fd_lookup>
  8011e4:	83 c4 08             	add    $0x8,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 05                	js     8011f0 <fd_close+0x2d>
	    || fd != fd2)
  8011eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ee:	74 0c                	je     8011fc <fd_close+0x39>
		return (must_exist ? r : 0);
  8011f0:	84 db                	test   %bl,%bl
  8011f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f7:	0f 44 c2             	cmove  %edx,%eax
  8011fa:	eb 41                	jmp    80123d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011fc:	83 ec 08             	sub    $0x8,%esp
  8011ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	ff 36                	pushl  (%esi)
  801205:	e8 66 ff ff ff       	call   801170 <dev_lookup>
  80120a:	89 c3                	mov    %eax,%ebx
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 1a                	js     80122d <fd_close+0x6a>
		if (dev->dev_close)
  801213:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801216:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801219:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80121e:	85 c0                	test   %eax,%eax
  801220:	74 0b                	je     80122d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801222:	83 ec 0c             	sub    $0xc,%esp
  801225:	56                   	push   %esi
  801226:	ff d0                	call   *%eax
  801228:	89 c3                	mov    %eax,%ebx
  80122a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80122d:	83 ec 08             	sub    $0x8,%esp
  801230:	56                   	push   %esi
  801231:	6a 00                	push   $0x0
  801233:	e8 cc f9 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	89 d8                	mov    %ebx,%eax
}
  80123d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124d:	50                   	push   %eax
  80124e:	ff 75 08             	pushl  0x8(%ebp)
  801251:	e8 c4 fe ff ff       	call   80111a <fd_lookup>
  801256:	83 c4 08             	add    $0x8,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 10                	js     80126d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80125d:	83 ec 08             	sub    $0x8,%esp
  801260:	6a 01                	push   $0x1
  801262:	ff 75 f4             	pushl  -0xc(%ebp)
  801265:	e8 59 ff ff ff       	call   8011c3 <fd_close>
  80126a:	83 c4 10             	add    $0x10,%esp
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <close_all>:

void
close_all(void)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	53                   	push   %ebx
  801273:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801276:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80127b:	83 ec 0c             	sub    $0xc,%esp
  80127e:	53                   	push   %ebx
  80127f:	e8 c0 ff ff ff       	call   801244 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801284:	83 c3 01             	add    $0x1,%ebx
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	83 fb 20             	cmp    $0x20,%ebx
  80128d:	75 ec                	jne    80127b <close_all+0xc>
		close(i);
}
  80128f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801292:	c9                   	leave  
  801293:	c3                   	ret    

00801294 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	83 ec 2c             	sub    $0x2c,%esp
  80129d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a3:	50                   	push   %eax
  8012a4:	ff 75 08             	pushl  0x8(%ebp)
  8012a7:	e8 6e fe ff ff       	call   80111a <fd_lookup>
  8012ac:	83 c4 08             	add    $0x8,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	0f 88 c1 00 00 00    	js     801378 <dup+0xe4>
		return r;
	close(newfdnum);
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	56                   	push   %esi
  8012bb:	e8 84 ff ff ff       	call   801244 <close>

	newfd = INDEX2FD(newfdnum);
  8012c0:	89 f3                	mov    %esi,%ebx
  8012c2:	c1 e3 0c             	shl    $0xc,%ebx
  8012c5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012cb:	83 c4 04             	add    $0x4,%esp
  8012ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012d1:	e8 de fd ff ff       	call   8010b4 <fd2data>
  8012d6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012d8:	89 1c 24             	mov    %ebx,(%esp)
  8012db:	e8 d4 fd ff ff       	call   8010b4 <fd2data>
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012e6:	89 f8                	mov    %edi,%eax
  8012e8:	c1 e8 16             	shr    $0x16,%eax
  8012eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012f2:	a8 01                	test   $0x1,%al
  8012f4:	74 37                	je     80132d <dup+0x99>
  8012f6:	89 f8                	mov    %edi,%eax
  8012f8:	c1 e8 0c             	shr    $0xc,%eax
  8012fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801302:	f6 c2 01             	test   $0x1,%dl
  801305:	74 26                	je     80132d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801307:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	25 07 0e 00 00       	and    $0xe07,%eax
  801316:	50                   	push   %eax
  801317:	ff 75 d4             	pushl  -0x2c(%ebp)
  80131a:	6a 00                	push   $0x0
  80131c:	57                   	push   %edi
  80131d:	6a 00                	push   $0x0
  80131f:	e8 9e f8 ff ff       	call   800bc2 <sys_page_map>
  801324:	89 c7                	mov    %eax,%edi
  801326:	83 c4 20             	add    $0x20,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 2e                	js     80135b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801330:	89 d0                	mov    %edx,%eax
  801332:	c1 e8 0c             	shr    $0xc,%eax
  801335:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	25 07 0e 00 00       	and    $0xe07,%eax
  801344:	50                   	push   %eax
  801345:	53                   	push   %ebx
  801346:	6a 00                	push   $0x0
  801348:	52                   	push   %edx
  801349:	6a 00                	push   $0x0
  80134b:	e8 72 f8 ff ff       	call   800bc2 <sys_page_map>
  801350:	89 c7                	mov    %eax,%edi
  801352:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801355:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801357:	85 ff                	test   %edi,%edi
  801359:	79 1d                	jns    801378 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	53                   	push   %ebx
  80135f:	6a 00                	push   $0x0
  801361:	e8 9e f8 ff ff       	call   800c04 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801366:	83 c4 08             	add    $0x8,%esp
  801369:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136c:	6a 00                	push   $0x0
  80136e:	e8 91 f8 ff ff       	call   800c04 <sys_page_unmap>
	return r;
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	89 f8                	mov    %edi,%eax
}
  801378:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 14             	sub    $0x14,%esp
  801387:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	53                   	push   %ebx
  80138f:	e8 86 fd ff ff       	call   80111a <fd_lookup>
  801394:	83 c4 08             	add    $0x8,%esp
  801397:	89 c2                	mov    %eax,%edx
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 6d                	js     80140a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a7:	ff 30                	pushl  (%eax)
  8013a9:	e8 c2 fd ff ff       	call   801170 <dev_lookup>
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 4c                	js     801401 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b8:	8b 42 08             	mov    0x8(%edx),%eax
  8013bb:	83 e0 03             	and    $0x3,%eax
  8013be:	83 f8 01             	cmp    $0x1,%eax
  8013c1:	75 21                	jne    8013e4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c8:	8b 40 7c             	mov    0x7c(%eax),%eax
  8013cb:	83 ec 04             	sub    $0x4,%esp
  8013ce:	53                   	push   %ebx
  8013cf:	50                   	push   %eax
  8013d0:	68 69 26 80 00       	push   $0x802669
  8013d5:	e8 1d ee ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e2:	eb 26                	jmp    80140a <read+0x8a>
	}
	if (!dev->dev_read)
  8013e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e7:	8b 40 08             	mov    0x8(%eax),%eax
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	74 17                	je     801405 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013ee:	83 ec 04             	sub    $0x4,%esp
  8013f1:	ff 75 10             	pushl  0x10(%ebp)
  8013f4:	ff 75 0c             	pushl  0xc(%ebp)
  8013f7:	52                   	push   %edx
  8013f8:	ff d0                	call   *%eax
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	eb 09                	jmp    80140a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801401:	89 c2                	mov    %eax,%edx
  801403:	eb 05                	jmp    80140a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801405:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80140a:	89 d0                	mov    %edx,%eax
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	57                   	push   %edi
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 0c             	sub    $0xc,%esp
  80141a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80141d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801420:	bb 00 00 00 00       	mov    $0x0,%ebx
  801425:	eb 21                	jmp    801448 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801427:	83 ec 04             	sub    $0x4,%esp
  80142a:	89 f0                	mov    %esi,%eax
  80142c:	29 d8                	sub    %ebx,%eax
  80142e:	50                   	push   %eax
  80142f:	89 d8                	mov    %ebx,%eax
  801431:	03 45 0c             	add    0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	57                   	push   %edi
  801436:	e8 45 ff ff ff       	call   801380 <read>
		if (m < 0)
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 10                	js     801452 <readn+0x41>
			return m;
		if (m == 0)
  801442:	85 c0                	test   %eax,%eax
  801444:	74 0a                	je     801450 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801446:	01 c3                	add    %eax,%ebx
  801448:	39 f3                	cmp    %esi,%ebx
  80144a:	72 db                	jb     801427 <readn+0x16>
  80144c:	89 d8                	mov    %ebx,%eax
  80144e:	eb 02                	jmp    801452 <readn+0x41>
  801450:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801452:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 14             	sub    $0x14,%esp
  801461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801464:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	53                   	push   %ebx
  801469:	e8 ac fc ff ff       	call   80111a <fd_lookup>
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	89 c2                	mov    %eax,%edx
  801473:	85 c0                	test   %eax,%eax
  801475:	78 68                	js     8014df <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147d:	50                   	push   %eax
  80147e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801481:	ff 30                	pushl  (%eax)
  801483:	e8 e8 fc ff ff       	call   801170 <dev_lookup>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 47                	js     8014d6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801496:	75 21                	jne    8014b9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801498:	a1 04 40 80 00       	mov    0x804004,%eax
  80149d:	8b 40 7c             	mov    0x7c(%eax),%eax
  8014a0:	83 ec 04             	sub    $0x4,%esp
  8014a3:	53                   	push   %ebx
  8014a4:	50                   	push   %eax
  8014a5:	68 85 26 80 00       	push   $0x802685
  8014aa:	e8 48 ed ff ff       	call   8001f7 <cprintf>
		return -E_INVAL;
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b7:	eb 26                	jmp    8014df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bf:	85 d2                	test   %edx,%edx
  8014c1:	74 17                	je     8014da <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014c3:	83 ec 04             	sub    $0x4,%esp
  8014c6:	ff 75 10             	pushl  0x10(%ebp)
  8014c9:	ff 75 0c             	pushl  0xc(%ebp)
  8014cc:	50                   	push   %eax
  8014cd:	ff d2                	call   *%edx
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	eb 09                	jmp    8014df <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	eb 05                	jmp    8014df <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014df:	89 d0                	mov    %edx,%eax
  8014e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	ff 75 08             	pushl  0x8(%ebp)
  8014f3:	e8 22 fc ff ff       	call   80111a <fd_lookup>
  8014f8:	83 c4 08             	add    $0x8,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 0e                	js     80150d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801502:	8b 55 0c             	mov    0xc(%ebp),%edx
  801505:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801508:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150d:	c9                   	leave  
  80150e:	c3                   	ret    

0080150f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	53                   	push   %ebx
  801513:	83 ec 14             	sub    $0x14,%esp
  801516:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801519:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151c:	50                   	push   %eax
  80151d:	53                   	push   %ebx
  80151e:	e8 f7 fb ff ff       	call   80111a <fd_lookup>
  801523:	83 c4 08             	add    $0x8,%esp
  801526:	89 c2                	mov    %eax,%edx
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 65                	js     801591 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	ff 30                	pushl  (%eax)
  801538:	e8 33 fc ff ff       	call   801170 <dev_lookup>
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 44                	js     801588 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801547:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154b:	75 21                	jne    80156e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80154d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801552:	8b 40 7c             	mov    0x7c(%eax),%eax
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	53                   	push   %ebx
  801559:	50                   	push   %eax
  80155a:	68 48 26 80 00       	push   $0x802648
  80155f:	e8 93 ec ff ff       	call   8001f7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156c:	eb 23                	jmp    801591 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80156e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801571:	8b 52 18             	mov    0x18(%edx),%edx
  801574:	85 d2                	test   %edx,%edx
  801576:	74 14                	je     80158c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	ff 75 0c             	pushl  0xc(%ebp)
  80157e:	50                   	push   %eax
  80157f:	ff d2                	call   *%edx
  801581:	89 c2                	mov    %eax,%edx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	eb 09                	jmp    801591 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801588:	89 c2                	mov    %eax,%edx
  80158a:	eb 05                	jmp    801591 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80158c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801591:	89 d0                	mov    %edx,%eax
  801593:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 14             	sub    $0x14,%esp
  80159f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	ff 75 08             	pushl  0x8(%ebp)
  8015a9:	e8 6c fb ff ff       	call   80111a <fd_lookup>
  8015ae:	83 c4 08             	add    $0x8,%esp
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 58                	js     80160f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	ff 30                	pushl  (%eax)
  8015c3:	e8 a8 fb ff ff       	call   801170 <dev_lookup>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 37                	js     801606 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d6:	74 32                	je     80160a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015db:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015e2:	00 00 00 
	stat->st_isdir = 0;
  8015e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015ec:	00 00 00 
	stat->st_dev = dev;
  8015ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	53                   	push   %ebx
  8015f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8015fc:	ff 50 14             	call   *0x14(%eax)
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	eb 09                	jmp    80160f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801606:	89 c2                	mov    %eax,%edx
  801608:	eb 05                	jmp    80160f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80160a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80160f:	89 d0                	mov    %edx,%eax
  801611:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	56                   	push   %esi
  80161a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	6a 00                	push   $0x0
  801620:	ff 75 08             	pushl  0x8(%ebp)
  801623:	e8 e3 01 00 00       	call   80180b <open>
  801628:	89 c3                	mov    %eax,%ebx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 1b                	js     80164c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	ff 75 0c             	pushl  0xc(%ebp)
  801637:	50                   	push   %eax
  801638:	e8 5b ff ff ff       	call   801598 <fstat>
  80163d:	89 c6                	mov    %eax,%esi
	close(fd);
  80163f:	89 1c 24             	mov    %ebx,(%esp)
  801642:	e8 fd fb ff ff       	call   801244 <close>
	return r;
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	89 f0                	mov    %esi,%eax
}
  80164c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	56                   	push   %esi
  801657:	53                   	push   %ebx
  801658:	89 c6                	mov    %eax,%esi
  80165a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80165c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801663:	75 12                	jne    801677 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	6a 01                	push   $0x1
  80166a:	e8 da 08 00 00       	call   801f49 <ipc_find_env>
  80166f:	a3 00 40 80 00       	mov    %eax,0x804000
  801674:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801677:	6a 07                	push   $0x7
  801679:	68 00 50 80 00       	push   $0x805000
  80167e:	56                   	push   %esi
  80167f:	ff 35 00 40 80 00    	pushl  0x804000
  801685:	e8 5d 08 00 00       	call   801ee7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80168a:	83 c4 0c             	add    $0xc,%esp
  80168d:	6a 00                	push   $0x0
  80168f:	53                   	push   %ebx
  801690:	6a 00                	push   $0x0
  801692:	e8 d5 07 00 00       	call   801e6c <ipc_recv>
}
  801697:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c1:	e8 8d ff ff ff       	call   801653 <fsipc>
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016de:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e3:	e8 6b ff ff ff       	call   801653 <fsipc>
}
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 04             	sub    $0x4,%esp
  8016f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801704:	b8 05 00 00 00       	mov    $0x5,%eax
  801709:	e8 45 ff ff ff       	call   801653 <fsipc>
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 2c                	js     80173e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801712:	83 ec 08             	sub    $0x8,%esp
  801715:	68 00 50 80 00       	push   $0x805000
  80171a:	53                   	push   %ebx
  80171b:	e8 5c f0 ff ff       	call   80077c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801720:	a1 80 50 80 00       	mov    0x805080,%eax
  801725:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80172b:	a1 84 50 80 00       	mov    0x805084,%eax
  801730:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 0c             	sub    $0xc,%esp
  801749:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80174c:	8b 55 08             	mov    0x8(%ebp),%edx
  80174f:	8b 52 0c             	mov    0xc(%edx),%edx
  801752:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801758:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80175d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801762:	0f 47 c2             	cmova  %edx,%eax
  801765:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80176a:	50                   	push   %eax
  80176b:	ff 75 0c             	pushl  0xc(%ebp)
  80176e:	68 08 50 80 00       	push   $0x805008
  801773:	e8 96 f1 ff ff       	call   80090e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801778:	ba 00 00 00 00       	mov    $0x0,%edx
  80177d:	b8 04 00 00 00       	mov    $0x4,%eax
  801782:	e8 cc fe ff ff       	call   801653 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801787:	c9                   	leave  
  801788:	c3                   	ret    

00801789 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	8b 40 0c             	mov    0xc(%eax),%eax
  801797:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80179c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ac:	e8 a2 fe ff ff       	call   801653 <fsipc>
  8017b1:	89 c3                	mov    %eax,%ebx
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 4b                	js     801802 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b7:	39 c6                	cmp    %eax,%esi
  8017b9:	73 16                	jae    8017d1 <devfile_read+0x48>
  8017bb:	68 b4 26 80 00       	push   $0x8026b4
  8017c0:	68 bb 26 80 00       	push   $0x8026bb
  8017c5:	6a 7c                	push   $0x7c
  8017c7:	68 d0 26 80 00       	push   $0x8026d0
  8017cc:	e8 c6 05 00 00       	call   801d97 <_panic>
	assert(r <= PGSIZE);
  8017d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d6:	7e 16                	jle    8017ee <devfile_read+0x65>
  8017d8:	68 db 26 80 00       	push   $0x8026db
  8017dd:	68 bb 26 80 00       	push   $0x8026bb
  8017e2:	6a 7d                	push   $0x7d
  8017e4:	68 d0 26 80 00       	push   $0x8026d0
  8017e9:	e8 a9 05 00 00       	call   801d97 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ee:	83 ec 04             	sub    $0x4,%esp
  8017f1:	50                   	push   %eax
  8017f2:	68 00 50 80 00       	push   $0x805000
  8017f7:	ff 75 0c             	pushl  0xc(%ebp)
  8017fa:	e8 0f f1 ff ff       	call   80090e <memmove>
	return r;
  8017ff:	83 c4 10             	add    $0x10,%esp
}
  801802:	89 d8                	mov    %ebx,%eax
  801804:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801807:	5b                   	pop    %ebx
  801808:	5e                   	pop    %esi
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	53                   	push   %ebx
  80180f:	83 ec 20             	sub    $0x20,%esp
  801812:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801815:	53                   	push   %ebx
  801816:	e8 28 ef ff ff       	call   800743 <strlen>
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801823:	7f 67                	jg     80188c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	e8 9a f8 ff ff       	call   8010cb <fd_alloc>
  801831:	83 c4 10             	add    $0x10,%esp
		return r;
  801834:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801836:	85 c0                	test   %eax,%eax
  801838:	78 57                	js     801891 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	53                   	push   %ebx
  80183e:	68 00 50 80 00       	push   $0x805000
  801843:	e8 34 ef ff ff       	call   80077c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801850:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801853:	b8 01 00 00 00       	mov    $0x1,%eax
  801858:	e8 f6 fd ff ff       	call   801653 <fsipc>
  80185d:	89 c3                	mov    %eax,%ebx
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	79 14                	jns    80187a <open+0x6f>
		fd_close(fd, 0);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	6a 00                	push   $0x0
  80186b:	ff 75 f4             	pushl  -0xc(%ebp)
  80186e:	e8 50 f9 ff ff       	call   8011c3 <fd_close>
		return r;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	89 da                	mov    %ebx,%edx
  801878:	eb 17                	jmp    801891 <open+0x86>
	}

	return fd2num(fd);
  80187a:	83 ec 0c             	sub    $0xc,%esp
  80187d:	ff 75 f4             	pushl  -0xc(%ebp)
  801880:	e8 1f f8 ff ff       	call   8010a4 <fd2num>
  801885:	89 c2                	mov    %eax,%edx
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	eb 05                	jmp    801891 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801891:	89 d0                	mov    %edx,%eax
  801893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a8:	e8 a6 fd ff ff       	call   801653 <fsipc>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	56                   	push   %esi
  8018b3:	53                   	push   %ebx
  8018b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b7:	83 ec 0c             	sub    $0xc,%esp
  8018ba:	ff 75 08             	pushl  0x8(%ebp)
  8018bd:	e8 f2 f7 ff ff       	call   8010b4 <fd2data>
  8018c2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c4:	83 c4 08             	add    $0x8,%esp
  8018c7:	68 e7 26 80 00       	push   $0x8026e7
  8018cc:	53                   	push   %ebx
  8018cd:	e8 aa ee ff ff       	call   80077c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d2:	8b 46 04             	mov    0x4(%esi),%eax
  8018d5:	2b 06                	sub    (%esi),%eax
  8018d7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e4:	00 00 00 
	stat->st_dev = &devpipe;
  8018e7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018ee:	30 80 00 
	return 0;
}
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f9:	5b                   	pop    %ebx
  8018fa:	5e                   	pop    %esi
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	53                   	push   %ebx
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801907:	53                   	push   %ebx
  801908:	6a 00                	push   $0x0
  80190a:	e8 f5 f2 ff ff       	call   800c04 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80190f:	89 1c 24             	mov    %ebx,(%esp)
  801912:	e8 9d f7 ff ff       	call   8010b4 <fd2data>
  801917:	83 c4 08             	add    $0x8,%esp
  80191a:	50                   	push   %eax
  80191b:	6a 00                	push   $0x0
  80191d:	e8 e2 f2 ff ff       	call   800c04 <sys_page_unmap>
}
  801922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	57                   	push   %edi
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	83 ec 1c             	sub    $0x1c,%esp
  801930:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801933:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801935:	a1 04 40 80 00       	mov    0x804004,%eax
  80193a:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801940:	83 ec 0c             	sub    $0xc,%esp
  801943:	ff 75 e0             	pushl  -0x20(%ebp)
  801946:	e8 40 06 00 00       	call   801f8b <pageref>
  80194b:	89 c3                	mov    %eax,%ebx
  80194d:	89 3c 24             	mov    %edi,(%esp)
  801950:	e8 36 06 00 00       	call   801f8b <pageref>
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	39 c3                	cmp    %eax,%ebx
  80195a:	0f 94 c1             	sete   %cl
  80195d:	0f b6 c9             	movzbl %cl,%ecx
  801960:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801963:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801969:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  80196f:	39 ce                	cmp    %ecx,%esi
  801971:	74 1e                	je     801991 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801973:	39 c3                	cmp    %eax,%ebx
  801975:	75 be                	jne    801935 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801977:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  80197d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801980:	50                   	push   %eax
  801981:	56                   	push   %esi
  801982:	68 ee 26 80 00       	push   $0x8026ee
  801987:	e8 6b e8 ff ff       	call   8001f7 <cprintf>
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	eb a4                	jmp    801935 <_pipeisclosed+0xe>
	}
}
  801991:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801994:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801997:	5b                   	pop    %ebx
  801998:	5e                   	pop    %esi
  801999:	5f                   	pop    %edi
  80199a:	5d                   	pop    %ebp
  80199b:	c3                   	ret    

0080199c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	57                   	push   %edi
  8019a0:	56                   	push   %esi
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 28             	sub    $0x28,%esp
  8019a5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019a8:	56                   	push   %esi
  8019a9:	e8 06 f7 ff ff       	call   8010b4 <fd2data>
  8019ae:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b8:	eb 4b                	jmp    801a05 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019ba:	89 da                	mov    %ebx,%edx
  8019bc:	89 f0                	mov    %esi,%eax
  8019be:	e8 64 ff ff ff       	call   801927 <_pipeisclosed>
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	75 48                	jne    801a0f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019c7:	e8 94 f1 ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019cc:	8b 43 04             	mov    0x4(%ebx),%eax
  8019cf:	8b 0b                	mov    (%ebx),%ecx
  8019d1:	8d 51 20             	lea    0x20(%ecx),%edx
  8019d4:	39 d0                	cmp    %edx,%eax
  8019d6:	73 e2                	jae    8019ba <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019db:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019df:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019e2:	89 c2                	mov    %eax,%edx
  8019e4:	c1 fa 1f             	sar    $0x1f,%edx
  8019e7:	89 d1                	mov    %edx,%ecx
  8019e9:	c1 e9 1b             	shr    $0x1b,%ecx
  8019ec:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019ef:	83 e2 1f             	and    $0x1f,%edx
  8019f2:	29 ca                	sub    %ecx,%edx
  8019f4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019fc:	83 c0 01             	add    $0x1,%eax
  8019ff:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a02:	83 c7 01             	add    $0x1,%edi
  801a05:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a08:	75 c2                	jne    8019cc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a0a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0d:	eb 05                	jmp    801a14 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a17:	5b                   	pop    %ebx
  801a18:	5e                   	pop    %esi
  801a19:	5f                   	pop    %edi
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	57                   	push   %edi
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	83 ec 18             	sub    $0x18,%esp
  801a25:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a28:	57                   	push   %edi
  801a29:	e8 86 f6 ff ff       	call   8010b4 <fd2data>
  801a2e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a38:	eb 3d                	jmp    801a77 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a3a:	85 db                	test   %ebx,%ebx
  801a3c:	74 04                	je     801a42 <devpipe_read+0x26>
				return i;
  801a3e:	89 d8                	mov    %ebx,%eax
  801a40:	eb 44                	jmp    801a86 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a42:	89 f2                	mov    %esi,%edx
  801a44:	89 f8                	mov    %edi,%eax
  801a46:	e8 dc fe ff ff       	call   801927 <_pipeisclosed>
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	75 32                	jne    801a81 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a4f:	e8 0c f1 ff ff       	call   800b60 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a54:	8b 06                	mov    (%esi),%eax
  801a56:	3b 46 04             	cmp    0x4(%esi),%eax
  801a59:	74 df                	je     801a3a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a5b:	99                   	cltd   
  801a5c:	c1 ea 1b             	shr    $0x1b,%edx
  801a5f:	01 d0                	add    %edx,%eax
  801a61:	83 e0 1f             	and    $0x1f,%eax
  801a64:	29 d0                	sub    %edx,%eax
  801a66:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a71:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a74:	83 c3 01             	add    $0x1,%ebx
  801a77:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a7a:	75 d8                	jne    801a54 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7f:	eb 05                	jmp    801a86 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a81:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5e                   	pop    %esi
  801a8b:	5f                   	pop    %edi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	56                   	push   %esi
  801a92:	53                   	push   %ebx
  801a93:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a99:	50                   	push   %eax
  801a9a:	e8 2c f6 ff ff       	call   8010cb <fd_alloc>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	89 c2                	mov    %eax,%edx
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	0f 88 2c 01 00 00    	js     801bd8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aac:	83 ec 04             	sub    $0x4,%esp
  801aaf:	68 07 04 00 00       	push   $0x407
  801ab4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab7:	6a 00                	push   $0x0
  801ab9:	e8 c1 f0 ff ff       	call   800b7f <sys_page_alloc>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	89 c2                	mov    %eax,%edx
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	0f 88 0d 01 00 00    	js     801bd8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801acb:	83 ec 0c             	sub    $0xc,%esp
  801ace:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ad1:	50                   	push   %eax
  801ad2:	e8 f4 f5 ff ff       	call   8010cb <fd_alloc>
  801ad7:	89 c3                	mov    %eax,%ebx
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	85 c0                	test   %eax,%eax
  801ade:	0f 88 e2 00 00 00    	js     801bc6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	68 07 04 00 00       	push   $0x407
  801aec:	ff 75 f0             	pushl  -0x10(%ebp)
  801aef:	6a 00                	push   $0x0
  801af1:	e8 89 f0 ff ff       	call   800b7f <sys_page_alloc>
  801af6:	89 c3                	mov    %eax,%ebx
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	85 c0                	test   %eax,%eax
  801afd:	0f 88 c3 00 00 00    	js     801bc6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	ff 75 f4             	pushl  -0xc(%ebp)
  801b09:	e8 a6 f5 ff ff       	call   8010b4 <fd2data>
  801b0e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b10:	83 c4 0c             	add    $0xc,%esp
  801b13:	68 07 04 00 00       	push   $0x407
  801b18:	50                   	push   %eax
  801b19:	6a 00                	push   $0x0
  801b1b:	e8 5f f0 ff ff       	call   800b7f <sys_page_alloc>
  801b20:	89 c3                	mov    %eax,%ebx
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	85 c0                	test   %eax,%eax
  801b27:	0f 88 89 00 00 00    	js     801bb6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	ff 75 f0             	pushl  -0x10(%ebp)
  801b33:	e8 7c f5 ff ff       	call   8010b4 <fd2data>
  801b38:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b3f:	50                   	push   %eax
  801b40:	6a 00                	push   $0x0
  801b42:	56                   	push   %esi
  801b43:	6a 00                	push   $0x0
  801b45:	e8 78 f0 ff ff       	call   800bc2 <sys_page_map>
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	83 c4 20             	add    $0x20,%esp
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	78 55                	js     801ba8 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b53:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b61:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b68:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b71:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b76:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	ff 75 f4             	pushl  -0xc(%ebp)
  801b83:	e8 1c f5 ff ff       	call   8010a4 <fd2num>
  801b88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b8b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b8d:	83 c4 04             	add    $0x4,%esp
  801b90:	ff 75 f0             	pushl  -0x10(%ebp)
  801b93:	e8 0c f5 ff ff       	call   8010a4 <fd2num>
  801b98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b9b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba6:	eb 30                	jmp    801bd8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ba8:	83 ec 08             	sub    $0x8,%esp
  801bab:	56                   	push   %esi
  801bac:	6a 00                	push   $0x0
  801bae:	e8 51 f0 ff ff       	call   800c04 <sys_page_unmap>
  801bb3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bb6:	83 ec 08             	sub    $0x8,%esp
  801bb9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 41 f0 ff ff       	call   800c04 <sys_page_unmap>
  801bc3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bc6:	83 ec 08             	sub    $0x8,%esp
  801bc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 31 f0 ff ff       	call   800c04 <sys_page_unmap>
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bd8:	89 d0                	mov    %edx,%eax
  801bda:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bea:	50                   	push   %eax
  801beb:	ff 75 08             	pushl  0x8(%ebp)
  801bee:	e8 27 f5 ff ff       	call   80111a <fd_lookup>
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	78 18                	js     801c12 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bfa:	83 ec 0c             	sub    $0xc,%esp
  801bfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801c00:	e8 af f4 ff ff       	call   8010b4 <fd2data>
	return _pipeisclosed(fd, p);
  801c05:	89 c2                	mov    %eax,%edx
  801c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0a:	e8 18 fd ff ff       	call   801927 <_pipeisclosed>
  801c0f:	83 c4 10             	add    $0x10,%esp
}
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c17:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c24:	68 06 27 80 00       	push   $0x802706
  801c29:	ff 75 0c             	pushl  0xc(%ebp)
  801c2c:	e8 4b eb ff ff       	call   80077c <strcpy>
	return 0;
}
  801c31:	b8 00 00 00 00       	mov    $0x0,%eax
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	57                   	push   %edi
  801c3c:	56                   	push   %esi
  801c3d:	53                   	push   %ebx
  801c3e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c44:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c49:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c4f:	eb 2d                	jmp    801c7e <devcons_write+0x46>
		m = n - tot;
  801c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c54:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c56:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c59:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c5e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c61:	83 ec 04             	sub    $0x4,%esp
  801c64:	53                   	push   %ebx
  801c65:	03 45 0c             	add    0xc(%ebp),%eax
  801c68:	50                   	push   %eax
  801c69:	57                   	push   %edi
  801c6a:	e8 9f ec ff ff       	call   80090e <memmove>
		sys_cputs(buf, m);
  801c6f:	83 c4 08             	add    $0x8,%esp
  801c72:	53                   	push   %ebx
  801c73:	57                   	push   %edi
  801c74:	e8 4a ee ff ff       	call   800ac3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c79:	01 de                	add    %ebx,%esi
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	89 f0                	mov    %esi,%eax
  801c80:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c83:	72 cc                	jb     801c51 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c88:	5b                   	pop    %ebx
  801c89:	5e                   	pop    %esi
  801c8a:	5f                   	pop    %edi
  801c8b:	5d                   	pop    %ebp
  801c8c:	c3                   	ret    

00801c8d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	83 ec 08             	sub    $0x8,%esp
  801c93:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c9c:	74 2a                	je     801cc8 <devcons_read+0x3b>
  801c9e:	eb 05                	jmp    801ca5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ca0:	e8 bb ee ff ff       	call   800b60 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ca5:	e8 37 ee ff ff       	call   800ae1 <sys_cgetc>
  801caa:	85 c0                	test   %eax,%eax
  801cac:	74 f2                	je     801ca0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	78 16                	js     801cc8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cb2:	83 f8 04             	cmp    $0x4,%eax
  801cb5:	74 0c                	je     801cc3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cba:	88 02                	mov    %al,(%edx)
	return 1;
  801cbc:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc1:	eb 05                	jmp    801cc8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cd6:	6a 01                	push   $0x1
  801cd8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cdb:	50                   	push   %eax
  801cdc:	e8 e2 ed ff ff       	call   800ac3 <sys_cputs>
}
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	c9                   	leave  
  801ce5:	c3                   	ret    

00801ce6 <getchar>:

int
getchar(void)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cec:	6a 01                	push   $0x1
  801cee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cf1:	50                   	push   %eax
  801cf2:	6a 00                	push   $0x0
  801cf4:	e8 87 f6 ff ff       	call   801380 <read>
	if (r < 0)
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 0f                	js     801d0f <getchar+0x29>
		return r;
	if (r < 1)
  801d00:	85 c0                	test   %eax,%eax
  801d02:	7e 06                	jle    801d0a <getchar+0x24>
		return -E_EOF;
	return c;
  801d04:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d08:	eb 05                	jmp    801d0f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d0a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d0f:	c9                   	leave  
  801d10:	c3                   	ret    

00801d11 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1a:	50                   	push   %eax
  801d1b:	ff 75 08             	pushl  0x8(%ebp)
  801d1e:	e8 f7 f3 ff ff       	call   80111a <fd_lookup>
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	85 c0                	test   %eax,%eax
  801d28:	78 11                	js     801d3b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d33:	39 10                	cmp    %edx,(%eax)
  801d35:	0f 94 c0             	sete   %al
  801d38:	0f b6 c0             	movzbl %al,%eax
}
  801d3b:	c9                   	leave  
  801d3c:	c3                   	ret    

00801d3d <opencons>:

int
opencons(void)
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d46:	50                   	push   %eax
  801d47:	e8 7f f3 ff ff       	call   8010cb <fd_alloc>
  801d4c:	83 c4 10             	add    $0x10,%esp
		return r;
  801d4f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d51:	85 c0                	test   %eax,%eax
  801d53:	78 3e                	js     801d93 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d55:	83 ec 04             	sub    $0x4,%esp
  801d58:	68 07 04 00 00       	push   $0x407
  801d5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d60:	6a 00                	push   $0x0
  801d62:	e8 18 ee ff ff       	call   800b7f <sys_page_alloc>
  801d67:	83 c4 10             	add    $0x10,%esp
		return r;
  801d6a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 23                	js     801d93 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d70:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d79:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d85:	83 ec 0c             	sub    $0xc,%esp
  801d88:	50                   	push   %eax
  801d89:	e8 16 f3 ff ff       	call   8010a4 <fd2num>
  801d8e:	89 c2                	mov    %eax,%edx
  801d90:	83 c4 10             	add    $0x10,%esp
}
  801d93:	89 d0                	mov    %edx,%eax
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	56                   	push   %esi
  801d9b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d9c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d9f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801da5:	e8 97 ed ff ff       	call   800b41 <sys_getenvid>
  801daa:	83 ec 0c             	sub    $0xc,%esp
  801dad:	ff 75 0c             	pushl  0xc(%ebp)
  801db0:	ff 75 08             	pushl  0x8(%ebp)
  801db3:	56                   	push   %esi
  801db4:	50                   	push   %eax
  801db5:	68 14 27 80 00       	push   $0x802714
  801dba:	e8 38 e4 ff ff       	call   8001f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dbf:	83 c4 18             	add    $0x18,%esp
  801dc2:	53                   	push   %ebx
  801dc3:	ff 75 10             	pushl  0x10(%ebp)
  801dc6:	e8 db e3 ff ff       	call   8001a6 <vcprintf>
	cprintf("\n");
  801dcb:	c7 04 24 6f 22 80 00 	movl   $0x80226f,(%esp)
  801dd2:	e8 20 e4 ff ff       	call   8001f7 <cprintf>
  801dd7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dda:	cc                   	int3   
  801ddb:	eb fd                	jmp    801dda <_panic+0x43>

00801ddd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801de3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dea:	75 2a                	jne    801e16 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801dec:	83 ec 04             	sub    $0x4,%esp
  801def:	6a 07                	push   $0x7
  801df1:	68 00 f0 bf ee       	push   $0xeebff000
  801df6:	6a 00                	push   $0x0
  801df8:	e8 82 ed ff ff       	call   800b7f <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	79 12                	jns    801e16 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e04:	50                   	push   %eax
  801e05:	68 38 27 80 00       	push   $0x802738
  801e0a:	6a 23                	push   $0x23
  801e0c:	68 3c 27 80 00       	push   $0x80273c
  801e11:	e8 81 ff ff ff       	call   801d97 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e1e:	83 ec 08             	sub    $0x8,%esp
  801e21:	68 48 1e 80 00       	push   $0x801e48
  801e26:	6a 00                	push   $0x0
  801e28:	e8 9d ee ff ff       	call   800cca <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	79 12                	jns    801e46 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e34:	50                   	push   %eax
  801e35:	68 38 27 80 00       	push   $0x802738
  801e3a:	6a 2c                	push   $0x2c
  801e3c:	68 3c 27 80 00       	push   $0x80273c
  801e41:	e8 51 ff ff ff       	call   801d97 <_panic>
	}
}
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e48:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e49:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e4e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e50:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e53:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e57:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e5c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e60:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e62:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e65:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e66:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e69:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e6a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e6b:	c3                   	ret    

00801e6c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	8b 75 08             	mov    0x8(%ebp),%esi
  801e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	75 12                	jne    801e90 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e7e:	83 ec 0c             	sub    $0xc,%esp
  801e81:	68 00 00 c0 ee       	push   $0xeec00000
  801e86:	e8 a4 ee ff ff       	call   800d2f <sys_ipc_recv>
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	eb 0c                	jmp    801e9c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e90:	83 ec 0c             	sub    $0xc,%esp
  801e93:	50                   	push   %eax
  801e94:	e8 96 ee ff ff       	call   800d2f <sys_ipc_recv>
  801e99:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e9c:	85 f6                	test   %esi,%esi
  801e9e:	0f 95 c1             	setne  %cl
  801ea1:	85 db                	test   %ebx,%ebx
  801ea3:	0f 95 c2             	setne  %dl
  801ea6:	84 d1                	test   %dl,%cl
  801ea8:	74 09                	je     801eb3 <ipc_recv+0x47>
  801eaa:	89 c2                	mov    %eax,%edx
  801eac:	c1 ea 1f             	shr    $0x1f,%edx
  801eaf:	84 d2                	test   %dl,%dl
  801eb1:	75 2d                	jne    801ee0 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801eb3:	85 f6                	test   %esi,%esi
  801eb5:	74 0d                	je     801ec4 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801eb7:	a1 04 40 80 00       	mov    0x804004,%eax
  801ebc:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801ec2:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ec4:	85 db                	test   %ebx,%ebx
  801ec6:	74 0d                	je     801ed5 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ec8:	a1 04 40 80 00       	mov    0x804004,%eax
  801ecd:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801ed3:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ed5:	a1 04 40 80 00       	mov    0x804004,%eax
  801eda:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801ee0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5e                   	pop    %esi
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	57                   	push   %edi
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
  801eed:	83 ec 0c             	sub    $0xc,%esp
  801ef0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ef9:	85 db                	test   %ebx,%ebx
  801efb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f00:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f03:	ff 75 14             	pushl  0x14(%ebp)
  801f06:	53                   	push   %ebx
  801f07:	56                   	push   %esi
  801f08:	57                   	push   %edi
  801f09:	e8 fe ed ff ff       	call   800d0c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f0e:	89 c2                	mov    %eax,%edx
  801f10:	c1 ea 1f             	shr    $0x1f,%edx
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	84 d2                	test   %dl,%dl
  801f18:	74 17                	je     801f31 <ipc_send+0x4a>
  801f1a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1d:	74 12                	je     801f31 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f1f:	50                   	push   %eax
  801f20:	68 4a 27 80 00       	push   $0x80274a
  801f25:	6a 47                	push   $0x47
  801f27:	68 58 27 80 00       	push   $0x802758
  801f2c:	e8 66 fe ff ff       	call   801d97 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f31:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f34:	75 07                	jne    801f3d <ipc_send+0x56>
			sys_yield();
  801f36:	e8 25 ec ff ff       	call   800b60 <sys_yield>
  801f3b:	eb c6                	jmp    801f03 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	75 c2                	jne    801f03 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f44:	5b                   	pop    %ebx
  801f45:	5e                   	pop    %esi
  801f46:	5f                   	pop    %edi
  801f47:	5d                   	pop    %ebp
  801f48:	c3                   	ret    

00801f49 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f4f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f54:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801f5a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f60:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f66:	39 ca                	cmp    %ecx,%edx
  801f68:	75 10                	jne    801f7a <ipc_find_env+0x31>
			return envs[i].env_id;
  801f6a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801f70:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f75:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f78:	eb 0f                	jmp    801f89 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7a:	83 c0 01             	add    $0x1,%eax
  801f7d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f82:	75 d0                	jne    801f54 <ipc_find_env+0xb>
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
