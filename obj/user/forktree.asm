
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
  80003d:	e8 00 0b 00 00       	call   800b42 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 22 80 00       	push   $0x802260
  80004c:	e8 a7 01 00 00       	call   8001f8 <cprintf>

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
  80007e:	e8 c1 06 00 00       	call   800744 <strlen>
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
  8000a0:	e8 85 06 00 00       	call   80072a <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 da 0d 00 00       	call   800e87 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 89 00 00 00       	call   80014b <exit>
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
  8000ec:	e8 51 0a 00 00       	call   800b42 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	89 c2                	mov    %eax,%edx
  8000f8:	c1 e2 07             	shl    $0x7,%edx
  8000fb:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800102:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800107:	85 db                	test   %ebx,%ebx
  800109:	7e 07                	jle    800112 <libmain+0x31>
		binaryname = argv[0];
  80010b:	8b 06                	mov    (%esi),%eax
  80010d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800112:	83 ec 08             	sub    $0x8,%esp
  800115:	56                   	push   %esi
  800116:	53                   	push   %ebx
  800117:	e8 b0 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  80011c:	e8 2a 00 00 00       	call   80014b <exit>
}
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800131:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800136:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800138:	e8 05 0a 00 00       	call   800b42 <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	e8 4b 0c 00 00       	call   800d91 <sys_thread_free>
}
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800151:	e8 18 11 00 00       	call   80126e <close_all>
	sys_env_destroy(0);
  800156:	83 ec 0c             	sub    $0xc,%esp
  800159:	6a 00                	push   $0x0
  80015b:	e8 a1 09 00 00       	call   800b01 <sys_env_destroy>
}
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	53                   	push   %ebx
  800169:	83 ec 04             	sub    $0x4,%esp
  80016c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016f:	8b 13                	mov    (%ebx),%edx
  800171:	8d 42 01             	lea    0x1(%edx),%eax
  800174:	89 03                	mov    %eax,(%ebx)
  800176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800179:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800182:	75 1a                	jne    80019e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800184:	83 ec 08             	sub    $0x8,%esp
  800187:	68 ff 00 00 00       	push   $0xff
  80018c:	8d 43 08             	lea    0x8(%ebx),%eax
  80018f:	50                   	push   %eax
  800190:	e8 2f 09 00 00       	call   800ac4 <sys_cputs>
		b->idx = 0;
  800195:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 65 01 80 00       	push   $0x800165
  8001d6:	e8 54 01 00 00       	call   80032f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 d4 08 00 00       	call   800ac4 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 c7                	mov    %eax,%edi
  800217:	89 d6                	mov    %edx,%esi
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800222:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800225:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800230:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800233:	39 d3                	cmp    %edx,%ebx
  800235:	72 05                	jb     80023c <printnum+0x30>
  800237:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023a:	77 45                	ja     800281 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	8b 45 14             	mov    0x14(%ebp),%eax
  800245:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800248:	53                   	push   %ebx
  800249:	ff 75 10             	pushl  0x10(%ebp)
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800252:	ff 75 e0             	pushl  -0x20(%ebp)
  800255:	ff 75 dc             	pushl  -0x24(%ebp)
  800258:	ff 75 d8             	pushl  -0x28(%ebp)
  80025b:	e8 60 1d 00 00       	call   801fc0 <__udivdi3>
  800260:	83 c4 18             	add    $0x18,%esp
  800263:	52                   	push   %edx
  800264:	50                   	push   %eax
  800265:	89 f2                	mov    %esi,%edx
  800267:	89 f8                	mov    %edi,%eax
  800269:	e8 9e ff ff ff       	call   80020c <printnum>
  80026e:	83 c4 20             	add    $0x20,%esp
  800271:	eb 18                	jmp    80028b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	56                   	push   %esi
  800277:	ff 75 18             	pushl  0x18(%ebp)
  80027a:	ff d7                	call   *%edi
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	eb 03                	jmp    800284 <printnum+0x78>
  800281:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800284:	83 eb 01             	sub    $0x1,%ebx
  800287:	85 db                	test   %ebx,%ebx
  800289:	7f e8                	jg     800273 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	56                   	push   %esi
  80028f:	83 ec 04             	sub    $0x4,%esp
  800292:	ff 75 e4             	pushl  -0x1c(%ebp)
  800295:	ff 75 e0             	pushl  -0x20(%ebp)
  800298:	ff 75 dc             	pushl  -0x24(%ebp)
  80029b:	ff 75 d8             	pushl  -0x28(%ebp)
  80029e:	e8 4d 1e 00 00       	call   8020f0 <__umoddi3>
  8002a3:	83 c4 14             	add    $0x14,%esp
  8002a6:	0f be 80 80 22 80 00 	movsbl 0x802280(%eax),%eax
  8002ad:	50                   	push   %eax
  8002ae:	ff d7                	call   *%edi
}
  8002b0:	83 c4 10             	add    $0x10,%esp
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002be:	83 fa 01             	cmp    $0x1,%edx
  8002c1:	7e 0e                	jle    8002d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 02                	mov    (%edx),%eax
  8002cc:	8b 52 04             	mov    0x4(%edx),%edx
  8002cf:	eb 22                	jmp    8002f3 <getuint+0x38>
	else if (lflag)
  8002d1:	85 d2                	test   %edx,%edx
  8002d3:	74 10                	je     8002e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d5:	8b 10                	mov    (%eax),%edx
  8002d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 02                	mov    (%edx),%eax
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	eb 0e                	jmp    8002f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	3b 50 04             	cmp    0x4(%eax),%edx
  800304:	73 0a                	jae    800310 <sprintputch+0x1b>
		*b->buf++ = ch;
  800306:	8d 4a 01             	lea    0x1(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 45 08             	mov    0x8(%ebp),%eax
  80030e:	88 02                	mov    %al,(%edx)
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800318:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031b:	50                   	push   %eax
  80031c:	ff 75 10             	pushl  0x10(%ebp)
  80031f:	ff 75 0c             	pushl  0xc(%ebp)
  800322:	ff 75 08             	pushl  0x8(%ebp)
  800325:	e8 05 00 00 00       	call   80032f <vprintfmt>
	va_end(ap);
}
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	c9                   	leave  
  80032e:	c3                   	ret    

0080032f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	57                   	push   %edi
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	83 ec 2c             	sub    $0x2c,%esp
  800338:	8b 75 08             	mov    0x8(%ebp),%esi
  80033b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800341:	eb 12                	jmp    800355 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800343:	85 c0                	test   %eax,%eax
  800345:	0f 84 89 03 00 00    	je     8006d4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	53                   	push   %ebx
  80034f:	50                   	push   %eax
  800350:	ff d6                	call   *%esi
  800352:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800355:	83 c7 01             	add    $0x1,%edi
  800358:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035c:	83 f8 25             	cmp    $0x25,%eax
  80035f:	75 e2                	jne    800343 <vprintfmt+0x14>
  800361:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800365:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800373:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
  80037f:	eb 07                	jmp    800388 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800384:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8d 47 01             	lea    0x1(%edi),%eax
  80038b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038e:	0f b6 07             	movzbl (%edi),%eax
  800391:	0f b6 c8             	movzbl %al,%ecx
  800394:	83 e8 23             	sub    $0x23,%eax
  800397:	3c 55                	cmp    $0x55,%al
  800399:	0f 87 1a 03 00 00    	ja     8006b9 <vprintfmt+0x38a>
  80039f:	0f b6 c0             	movzbl %al,%eax
  8003a2:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b0:	eb d6                	jmp    800388 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ca:	83 fa 09             	cmp    $0x9,%edx
  8003cd:	77 39                	ja     800408 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d2:	eb e9                	jmp    8003bd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003da:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e5:	eb 27                	jmp    80040e <vprintfmt+0xdf>
  8003e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f1:	0f 49 c8             	cmovns %eax,%ecx
  8003f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fa:	eb 8c                	jmp    800388 <vprintfmt+0x59>
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ff:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800406:	eb 80                	jmp    800388 <vprintfmt+0x59>
  800408:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800412:	0f 89 70 ff ff ff    	jns    800388 <vprintfmt+0x59>
				width = precision, precision = -1;
  800418:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800425:	e9 5e ff ff ff       	jmp    800388 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800430:	e9 53 ff ff ff       	jmp    800388 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	53                   	push   %ebx
  800442:	ff 30                	pushl  (%eax)
  800444:	ff d6                	call   *%esi
			break;
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044c:	e9 04 ff ff ff       	jmp    800355 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	99                   	cltd   
  80045d:	31 d0                	xor    %edx,%eax
  80045f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800461:	83 f8 0f             	cmp    $0xf,%eax
  800464:	7f 0b                	jg     800471 <vprintfmt+0x142>
  800466:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80046d:	85 d2                	test   %edx,%edx
  80046f:	75 18                	jne    800489 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800471:	50                   	push   %eax
  800472:	68 98 22 80 00       	push   $0x802298
  800477:	53                   	push   %ebx
  800478:	56                   	push   %esi
  800479:	e8 94 fe ff ff       	call   800312 <printfmt>
  80047e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800484:	e9 cc fe ff ff       	jmp    800355 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800489:	52                   	push   %edx
  80048a:	68 cd 26 80 00       	push   $0x8026cd
  80048f:	53                   	push   %ebx
  800490:	56                   	push   %esi
  800491:	e8 7c fe ff ff       	call   800312 <printfmt>
  800496:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049c:	e9 b4 fe ff ff       	jmp    800355 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	b8 91 22 80 00       	mov    $0x802291,%eax
  8004b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ba:	0f 8e 94 00 00 00    	jle    800554 <vprintfmt+0x225>
  8004c0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c4:	0f 84 98 00 00 00    	je     800562 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d0:	57                   	push   %edi
  8004d1:	e8 86 02 00 00       	call   80075c <strnlen>
  8004d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d9:	29 c1                	sub    %eax,%ecx
  8004db:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004eb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	eb 0f                	jmp    8004fe <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7f ed                	jg     8004ef <vprintfmt+0x1c0>
  800502:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800505:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c1             	cmovns %ecx,%eax
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	89 cb                	mov    %ecx,%ebx
  80051f:	eb 4d                	jmp    80056e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	74 1b                	je     800542 <vprintfmt+0x213>
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	83 e8 20             	sub    $0x20,%eax
  80052d:	83 f8 5e             	cmp    $0x5e,%eax
  800530:	76 10                	jbe    800542 <vprintfmt+0x213>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	6a 3f                	push   $0x3f
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	eb 0d                	jmp    80054f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	52                   	push   %edx
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	eb 1a                	jmp    80056e <vprintfmt+0x23f>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	eb 0c                	jmp    80056e <vprintfmt+0x23f>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800575:	0f be d0             	movsbl %al,%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 23                	je     80059f <vprintfmt+0x270>
  80057c:	85 f6                	test   %esi,%esi
  80057e:	78 a1                	js     800521 <vprintfmt+0x1f2>
  800580:	83 ee 01             	sub    $0x1,%esi
  800583:	79 9c                	jns    800521 <vprintfmt+0x1f2>
  800585:	89 df                	mov    %ebx,%edi
  800587:	8b 75 08             	mov    0x8(%ebp),%esi
  80058a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058d:	eb 18                	jmp    8005a7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 20                	push   $0x20
  800595:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 ef 01             	sub    $0x1,%edi
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 08                	jmp    8005a7 <vprintfmt+0x278>
  80059f:	89 df                	mov    %ebx,%edi
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a7:	85 ff                	test   %edi,%edi
  8005a9:	7f e4                	jg     80058f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ae:	e9 a2 fd ff ff       	jmp    800355 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b3:	83 fa 01             	cmp    $0x1,%edx
  8005b6:	7e 16                	jle    8005ce <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 08             	lea    0x8(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 50 04             	mov    0x4(%eax),%edx
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	eb 32                	jmp    800600 <vprintfmt+0x2d1>
	else if (lflag)
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	74 18                	je     8005ea <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e0:	89 c1                	mov    %eax,%ecx
  8005e2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e8:	eb 16                	jmp    800600 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	89 c1                	mov    %eax,%ecx
  8005fa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800600:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800603:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800606:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060f:	79 74                	jns    800685 <vprintfmt+0x356>
				putch('-', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 2d                	push   $0x2d
  800617:	ff d6                	call   *%esi
				num = -(long long) num;
  800619:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061f:	f7 d8                	neg    %eax
  800621:	83 d2 00             	adc    $0x0,%edx
  800624:	f7 da                	neg    %edx
  800626:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800629:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062e:	eb 55                	jmp    800685 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800630:	8d 45 14             	lea    0x14(%ebp),%eax
  800633:	e8 83 fc ff ff       	call   8002bb <getuint>
			base = 10;
  800638:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063d:	eb 46                	jmp    800685 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 74 fc ff ff       	call   8002bb <getuint>
			base = 8;
  800647:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80064c:	eb 37                	jmp    800685 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 30                	push   $0x30
  800654:	ff d6                	call   *%esi
			putch('x', putdat);
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 78                	push   $0x78
  80065c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800671:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800676:	eb 0d                	jmp    800685 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 3b fc ff ff       	call   8002bb <getuint>
			base = 16;
  800680:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800685:	83 ec 0c             	sub    $0xc,%esp
  800688:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068c:	57                   	push   %edi
  80068d:	ff 75 e0             	pushl  -0x20(%ebp)
  800690:	51                   	push   %ecx
  800691:	52                   	push   %edx
  800692:	50                   	push   %eax
  800693:	89 da                	mov    %ebx,%edx
  800695:	89 f0                	mov    %esi,%eax
  800697:	e8 70 fb ff ff       	call   80020c <printnum>
			break;
  80069c:	83 c4 20             	add    $0x20,%esp
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a2:	e9 ae fc ff ff       	jmp    800355 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	51                   	push   %ecx
  8006ac:	ff d6                	call   *%esi
			break;
  8006ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b4:	e9 9c fc ff ff       	jmp    800355 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 25                	push   $0x25
  8006bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb 03                	jmp    8006c9 <vprintfmt+0x39a>
  8006c6:	83 ef 01             	sub    $0x1,%edi
  8006c9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006cd:	75 f7                	jne    8006c6 <vprintfmt+0x397>
  8006cf:	e9 81 fc ff ff       	jmp    800355 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d7:	5b                   	pop    %ebx
  8006d8:	5e                   	pop    %esi
  8006d9:	5f                   	pop    %edi
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 18             	sub    $0x18,%esp
  8006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006eb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 26                	je     800723 <vsnprintf+0x47>
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	7e 22                	jle    800723 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800701:	ff 75 14             	pushl  0x14(%ebp)
  800704:	ff 75 10             	pushl  0x10(%ebp)
  800707:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	68 f5 02 80 00       	push   $0x8002f5
  800710:	e8 1a fc ff ff       	call   80032f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800715:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800718:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb 05                	jmp    800728 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800733:	50                   	push   %eax
  800734:	ff 75 10             	pushl  0x10(%ebp)
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	ff 75 08             	pushl  0x8(%ebp)
  80073d:	e8 9a ff ff ff       	call   8006dc <vsnprintf>
	va_end(ap);

	return rc;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
  80074f:	eb 03                	jmp    800754 <strlen+0x10>
		n++;
  800751:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800754:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800758:	75 f7                	jne    800751 <strlen+0xd>
		n++;
	return n;
}
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	ba 00 00 00 00       	mov    $0x0,%edx
  80076a:	eb 03                	jmp    80076f <strnlen+0x13>
		n++;
  80076c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	39 c2                	cmp    %eax,%edx
  800771:	74 08                	je     80077b <strnlen+0x1f>
  800773:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800777:	75 f3                	jne    80076c <strnlen+0x10>
  800779:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	53                   	push   %ebx
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800787:	89 c2                	mov    %eax,%edx
  800789:	83 c2 01             	add    $0x1,%edx
  80078c:	83 c1 01             	add    $0x1,%ecx
  80078f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800793:	88 5a ff             	mov    %bl,-0x1(%edx)
  800796:	84 db                	test   %bl,%bl
  800798:	75 ef                	jne    800789 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079a:	5b                   	pop    %ebx
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	53                   	push   %ebx
  8007a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a4:	53                   	push   %ebx
  8007a5:	e8 9a ff ff ff       	call   800744 <strlen>
  8007aa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ad:	ff 75 0c             	pushl  0xc(%ebp)
  8007b0:	01 d8                	add    %ebx,%eax
  8007b2:	50                   	push   %eax
  8007b3:	e8 c5 ff ff ff       	call   80077d <strcpy>
	return dst;
}
  8007b8:	89 d8                	mov    %ebx,%eax
  8007ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	56                   	push   %esi
  8007c3:	53                   	push   %ebx
  8007c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ca:	89 f3                	mov    %esi,%ebx
  8007cc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cf:	89 f2                	mov    %esi,%edx
  8007d1:	eb 0f                	jmp    8007e2 <strncpy+0x23>
		*dst++ = *src;
  8007d3:	83 c2 01             	add    $0x1,%edx
  8007d6:	0f b6 01             	movzbl (%ecx),%eax
  8007d9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007dc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007df:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e2:	39 da                	cmp    %ebx,%edx
  8007e4:	75 ed                	jne    8007d3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	56                   	push   %esi
  8007f0:	53                   	push   %ebx
  8007f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fc:	85 d2                	test   %edx,%edx
  8007fe:	74 21                	je     800821 <strlcpy+0x35>
  800800:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800804:	89 f2                	mov    %esi,%edx
  800806:	eb 09                	jmp    800811 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800808:	83 c2 01             	add    $0x1,%edx
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800811:	39 c2                	cmp    %eax,%edx
  800813:	74 09                	je     80081e <strlcpy+0x32>
  800815:	0f b6 19             	movzbl (%ecx),%ebx
  800818:	84 db                	test   %bl,%bl
  80081a:	75 ec                	jne    800808 <strlcpy+0x1c>
  80081c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800821:	29 f0                	sub    %esi,%eax
}
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800830:	eb 06                	jmp    800838 <strcmp+0x11>
		p++, q++;
  800832:	83 c1 01             	add    $0x1,%ecx
  800835:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800838:	0f b6 01             	movzbl (%ecx),%eax
  80083b:	84 c0                	test   %al,%al
  80083d:	74 04                	je     800843 <strcmp+0x1c>
  80083f:	3a 02                	cmp    (%edx),%al
  800841:	74 ef                	je     800832 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 c0             	movzbl %al,%eax
  800846:	0f b6 12             	movzbl (%edx),%edx
  800849:	29 d0                	sub    %edx,%eax
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	53                   	push   %ebx
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
  800857:	89 c3                	mov    %eax,%ebx
  800859:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085c:	eb 06                	jmp    800864 <strncmp+0x17>
		n--, p++, q++;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800864:	39 d8                	cmp    %ebx,%eax
  800866:	74 15                	je     80087d <strncmp+0x30>
  800868:	0f b6 08             	movzbl (%eax),%ecx
  80086b:	84 c9                	test   %cl,%cl
  80086d:	74 04                	je     800873 <strncmp+0x26>
  80086f:	3a 0a                	cmp    (%edx),%cl
  800871:	74 eb                	je     80085e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 00             	movzbl (%eax),%eax
  800876:	0f b6 12             	movzbl (%edx),%edx
  800879:	29 d0                	sub    %edx,%eax
  80087b:	eb 05                	jmp    800882 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800882:	5b                   	pop    %ebx
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088f:	eb 07                	jmp    800898 <strchr+0x13>
		if (*s == c)
  800891:	38 ca                	cmp    %cl,%dl
  800893:	74 0f                	je     8008a4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800895:	83 c0 01             	add    $0x1,%eax
  800898:	0f b6 10             	movzbl (%eax),%edx
  80089b:	84 d2                	test   %dl,%dl
  80089d:	75 f2                	jne    800891 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b0:	eb 03                	jmp    8008b5 <strfind+0xf>
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 04                	je     8008c0 <strfind+0x1a>
  8008bc:	84 d2                	test   %dl,%dl
  8008be:	75 f2                	jne    8008b2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ce:	85 c9                	test   %ecx,%ecx
  8008d0:	74 36                	je     800908 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d8:	75 28                	jne    800902 <memset+0x40>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 23                	jne    800902 <memset+0x40>
		c &= 0xFF;
  8008df:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e3:	89 d3                	mov    %edx,%ebx
  8008e5:	c1 e3 08             	shl    $0x8,%ebx
  8008e8:	89 d6                	mov    %edx,%esi
  8008ea:	c1 e6 18             	shl    $0x18,%esi
  8008ed:	89 d0                	mov    %edx,%eax
  8008ef:	c1 e0 10             	shl    $0x10,%eax
  8008f2:	09 f0                	or     %esi,%eax
  8008f4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f6:	89 d8                	mov    %ebx,%eax
  8008f8:	09 d0                	or     %edx,%eax
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
  8008fd:	fc                   	cld    
  8008fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800900:	eb 06                	jmp    800908 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800902:	8b 45 0c             	mov    0xc(%ebp),%eax
  800905:	fc                   	cld    
  800906:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800908:	89 f8                	mov    %edi,%eax
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5f                   	pop    %edi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	57                   	push   %edi
  800913:	56                   	push   %esi
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091d:	39 c6                	cmp    %eax,%esi
  80091f:	73 35                	jae    800956 <memmove+0x47>
  800921:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800924:	39 d0                	cmp    %edx,%eax
  800926:	73 2e                	jae    800956 <memmove+0x47>
		s += n;
		d += n;
  800928:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	09 fe                	or     %edi,%esi
  80092f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800935:	75 13                	jne    80094a <memmove+0x3b>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 0e                	jne    80094a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093c:	83 ef 04             	sub    $0x4,%edi
  80093f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800942:	c1 e9 02             	shr    $0x2,%ecx
  800945:	fd                   	std    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 09                	jmp    800953 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 1d                	jmp    800973 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	89 f2                	mov    %esi,%edx
  800958:	09 c2                	or     %eax,%edx
  80095a:	f6 c2 03             	test   $0x3,%dl
  80095d:	75 0f                	jne    80096e <memmove+0x5f>
  80095f:	f6 c1 03             	test   $0x3,%cl
  800962:	75 0a                	jne    80096e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800964:	c1 e9 02             	shr    $0x2,%ecx
  800967:	89 c7                	mov    %eax,%edi
  800969:	fc                   	cld    
  80096a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096c:	eb 05                	jmp    800973 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096e:	89 c7                	mov    %eax,%edi
  800970:	fc                   	cld    
  800971:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097a:	ff 75 10             	pushl  0x10(%ebp)
  80097d:	ff 75 0c             	pushl  0xc(%ebp)
  800980:	ff 75 08             	pushl  0x8(%ebp)
  800983:	e8 87 ff ff ff       	call   80090f <memmove>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	89 c6                	mov    %eax,%esi
  800997:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099a:	eb 1a                	jmp    8009b6 <memcmp+0x2c>
		if (*s1 != *s2)
  80099c:	0f b6 08             	movzbl (%eax),%ecx
  80099f:	0f b6 1a             	movzbl (%edx),%ebx
  8009a2:	38 d9                	cmp    %bl,%cl
  8009a4:	74 0a                	je     8009b0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a6:	0f b6 c1             	movzbl %cl,%eax
  8009a9:	0f b6 db             	movzbl %bl,%ebx
  8009ac:	29 d8                	sub    %ebx,%eax
  8009ae:	eb 0f                	jmp    8009bf <memcmp+0x35>
		s1++, s2++;
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b6:	39 f0                	cmp    %esi,%eax
  8009b8:	75 e2                	jne    80099c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ca:	89 c1                	mov    %eax,%ecx
  8009cc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d3:	eb 0a                	jmp    8009df <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	39 da                	cmp    %ebx,%edx
  8009da:	74 07                	je     8009e3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	39 c8                	cmp    %ecx,%eax
  8009e1:	72 f2                	jb     8009d5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f2:	eb 03                	jmp    8009f7 <strtol+0x11>
		s++;
  8009f4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f7:	0f b6 01             	movzbl (%ecx),%eax
  8009fa:	3c 20                	cmp    $0x20,%al
  8009fc:	74 f6                	je     8009f4 <strtol+0xe>
  8009fe:	3c 09                	cmp    $0x9,%al
  800a00:	74 f2                	je     8009f4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a02:	3c 2b                	cmp    $0x2b,%al
  800a04:	75 0a                	jne    800a10 <strtol+0x2a>
		s++;
  800a06:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a09:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0e:	eb 11                	jmp    800a21 <strtol+0x3b>
  800a10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a15:	3c 2d                	cmp    $0x2d,%al
  800a17:	75 08                	jne    800a21 <strtol+0x3b>
		s++, neg = 1;
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a21:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a27:	75 15                	jne    800a3e <strtol+0x58>
  800a29:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2c:	75 10                	jne    800a3e <strtol+0x58>
  800a2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a32:	75 7c                	jne    800ab0 <strtol+0xca>
		s += 2, base = 16;
  800a34:	83 c1 02             	add    $0x2,%ecx
  800a37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3c:	eb 16                	jmp    800a54 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3e:	85 db                	test   %ebx,%ebx
  800a40:	75 12                	jne    800a54 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a47:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4a:	75 08                	jne    800a54 <strtol+0x6e>
		s++, base = 8;
  800a4c:	83 c1 01             	add    $0x1,%ecx
  800a4f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5c:	0f b6 11             	movzbl (%ecx),%edx
  800a5f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 09             	cmp    $0x9,%bl
  800a67:	77 08                	ja     800a71 <strtol+0x8b>
			dig = *s - '0';
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 30             	sub    $0x30,%edx
  800a6f:	eb 22                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a71:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	80 fb 19             	cmp    $0x19,%bl
  800a79:	77 08                	ja     800a83 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7b:	0f be d2             	movsbl %dl,%edx
  800a7e:	83 ea 57             	sub    $0x57,%edx
  800a81:	eb 10                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a83:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 19             	cmp    $0x19,%bl
  800a8b:	77 16                	ja     800aa3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8d:	0f be d2             	movsbl %dl,%edx
  800a90:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a93:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a96:	7d 0b                	jge    800aa3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa1:	eb b9                	jmp    800a5c <strtol+0x76>

	if (endptr)
  800aa3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa7:	74 0d                	je     800ab6 <strtol+0xd0>
		*endptr = (char *) s;
  800aa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aac:	89 0e                	mov    %ecx,(%esi)
  800aae:	eb 06                	jmp    800ab6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab0:	85 db                	test   %ebx,%ebx
  800ab2:	74 98                	je     800a4c <strtol+0x66>
  800ab4:	eb 9e                	jmp    800a54 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab6:	89 c2                	mov    %eax,%edx
  800ab8:	f7 da                	neg    %edx
  800aba:	85 ff                	test   %edi,%edi
  800abc:	0f 45 c2             	cmovne %edx,%eax
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 cb                	mov    %ecx,%ebx
  800b19:	89 cf                	mov    %ecx,%edi
  800b1b:	89 ce                	mov    %ecx,%esi
  800b1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	7e 17                	jle    800b3a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	50                   	push   %eax
  800b27:	6a 03                	push   $0x3
  800b29:	68 7f 25 80 00       	push   $0x80257f
  800b2e:	6a 23                	push   $0x23
  800b30:	68 9c 25 80 00       	push   $0x80259c
  800b35:	e8 53 12 00 00       	call   801d8d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_yield>:

void
sys_yield(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	be 00 00 00 00       	mov    $0x0,%esi
  800b8e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	89 f7                	mov    %esi,%edi
  800b9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 17                	jle    800bbb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 04                	push   $0x4
  800baa:	68 7f 25 80 00       	push   $0x80257f
  800baf:	6a 23                	push   $0x23
  800bb1:	68 9c 25 80 00       	push   $0x80259c
  800bb6:	e8 d2 11 00 00       	call   801d8d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdd:	8b 75 18             	mov    0x18(%ebp),%esi
  800be0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7e 17                	jle    800bfd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 05                	push   $0x5
  800bec:	68 7f 25 80 00       	push   $0x80257f
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 9c 25 80 00       	push   $0x80259c
  800bf8:	e8 90 11 00 00       	call   801d8d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c13:	b8 06 00 00 00       	mov    $0x6,%eax
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	89 df                	mov    %ebx,%edi
  800c20:	89 de                	mov    %ebx,%esi
  800c22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7e 17                	jle    800c3f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 06                	push   $0x6
  800c2e:	68 7f 25 80 00       	push   $0x80257f
  800c33:	6a 23                	push   $0x23
  800c35:	68 9c 25 80 00       	push   $0x80259c
  800c3a:	e8 4e 11 00 00       	call   801d8d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 08                	push   $0x8
  800c70:	68 7f 25 80 00       	push   $0x80257f
  800c75:	6a 23                	push   $0x23
  800c77:	68 9c 25 80 00       	push   $0x80259c
  800c7c:	e8 0c 11 00 00       	call   801d8d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 09                	push   $0x9
  800cb2:	68 7f 25 80 00       	push   $0x80257f
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 9c 25 80 00       	push   $0x80259c
  800cbe:	e8 ca 10 00 00       	call   801d8d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 0a                	push   $0xa
  800cf4:	68 7f 25 80 00       	push   $0x80257f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 9c 25 80 00       	push   $0x80259c
  800d00:	e8 88 10 00 00       	call   801d8d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	be 00 00 00 00       	mov    $0x0,%esi
  800d18:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 cb                	mov    %ecx,%ebx
  800d48:	89 cf                	mov    %ecx,%edi
  800d4a:	89 ce                	mov    %ecx,%esi
  800d4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	7e 17                	jle    800d69 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 0d                	push   $0xd
  800d58:	68 7f 25 80 00       	push   $0x80257f
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 9c 25 80 00       	push   $0x80259c
  800d64:	e8 24 10 00 00       	call   801d8d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 cb                	mov    %ecx,%ebx
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	89 ce                	mov    %ecx,%esi
  800d8a:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	89 cb                	mov    %ecx,%ebx
  800da6:	89 cf                	mov    %ecx,%edi
  800da8:	89 ce                	mov    %ecx,%esi
  800daa:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	53                   	push   %ebx
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dbb:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800dbd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc1:	74 11                	je     800dd4 <pgfault+0x23>
  800dc3:	89 d8                	mov    %ebx,%eax
  800dc5:	c1 e8 0c             	shr    $0xc,%eax
  800dc8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dcf:	f6 c4 08             	test   $0x8,%ah
  800dd2:	75 14                	jne    800de8 <pgfault+0x37>
		panic("faulting access");
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	68 aa 25 80 00       	push   $0x8025aa
  800ddc:	6a 1e                	push   $0x1e
  800dde:	68 ba 25 80 00       	push   $0x8025ba
  800de3:	e8 a5 0f 00 00       	call   801d8d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	6a 07                	push   $0x7
  800ded:	68 00 f0 7f 00       	push   $0x7ff000
  800df2:	6a 00                	push   $0x0
  800df4:	e8 87 fd ff ff       	call   800b80 <sys_page_alloc>
	if (r < 0) {
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	79 12                	jns    800e12 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800e00:	50                   	push   %eax
  800e01:	68 c5 25 80 00       	push   $0x8025c5
  800e06:	6a 2c                	push   $0x2c
  800e08:	68 ba 25 80 00       	push   $0x8025ba
  800e0d:	e8 7b 0f 00 00       	call   801d8d <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e12:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800e18:	83 ec 04             	sub    $0x4,%esp
  800e1b:	68 00 10 00 00       	push   $0x1000
  800e20:	53                   	push   %ebx
  800e21:	68 00 f0 7f 00       	push   $0x7ff000
  800e26:	e8 4c fb ff ff       	call   800977 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800e2b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e32:	53                   	push   %ebx
  800e33:	6a 00                	push   $0x0
  800e35:	68 00 f0 7f 00       	push   $0x7ff000
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 82 fd ff ff       	call   800bc3 <sys_page_map>
	if (r < 0) {
  800e41:	83 c4 20             	add    $0x20,%esp
  800e44:	85 c0                	test   %eax,%eax
  800e46:	79 12                	jns    800e5a <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800e48:	50                   	push   %eax
  800e49:	68 c5 25 80 00       	push   $0x8025c5
  800e4e:	6a 33                	push   $0x33
  800e50:	68 ba 25 80 00       	push   $0x8025ba
  800e55:	e8 33 0f 00 00       	call   801d8d <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800e5a:	83 ec 08             	sub    $0x8,%esp
  800e5d:	68 00 f0 7f 00       	push   $0x7ff000
  800e62:	6a 00                	push   $0x0
  800e64:	e8 9c fd ff ff       	call   800c05 <sys_page_unmap>
	if (r < 0) {
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	79 12                	jns    800e82 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800e70:	50                   	push   %eax
  800e71:	68 c5 25 80 00       	push   $0x8025c5
  800e76:	6a 37                	push   $0x37
  800e78:	68 ba 25 80 00       	push   $0x8025ba
  800e7d:	e8 0b 0f 00 00       	call   801d8d <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800e82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    

00800e87 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	57                   	push   %edi
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
  800e8d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800e90:	68 b1 0d 80 00       	push   $0x800db1
  800e95:	e8 39 0f 00 00       	call   801dd3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e9a:	b8 07 00 00 00       	mov    $0x7,%eax
  800e9f:	cd 30                	int    $0x30
  800ea1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	79 17                	jns    800ec2 <fork+0x3b>
		panic("fork fault %e");
  800eab:	83 ec 04             	sub    $0x4,%esp
  800eae:	68 de 25 80 00       	push   $0x8025de
  800eb3:	68 84 00 00 00       	push   $0x84
  800eb8:	68 ba 25 80 00       	push   $0x8025ba
  800ebd:	e8 cb 0e 00 00       	call   801d8d <_panic>
  800ec2:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ec4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec8:	75 25                	jne    800eef <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eca:	e8 73 fc ff ff       	call   800b42 <sys_getenvid>
  800ecf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed4:	89 c2                	mov    %eax,%edx
  800ed6:	c1 e2 07             	shl    $0x7,%edx
  800ed9:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800ee0:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eea:	e9 61 01 00 00       	jmp    801050 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	6a 07                	push   $0x7
  800ef4:	68 00 f0 bf ee       	push   $0xeebff000
  800ef9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800efc:	e8 7f fc ff ff       	call   800b80 <sys_page_alloc>
  800f01:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800f04:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f09:	89 d8                	mov    %ebx,%eax
  800f0b:	c1 e8 16             	shr    $0x16,%eax
  800f0e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f15:	a8 01                	test   $0x1,%al
  800f17:	0f 84 fc 00 00 00    	je     801019 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800f1d:	89 d8                	mov    %ebx,%eax
  800f1f:	c1 e8 0c             	shr    $0xc,%eax
  800f22:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800f29:	f6 c2 01             	test   $0x1,%dl
  800f2c:	0f 84 e7 00 00 00    	je     801019 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800f32:	89 c6                	mov    %eax,%esi
  800f34:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800f37:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f3e:	f6 c6 04             	test   $0x4,%dh
  800f41:	74 39                	je     800f7c <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f52:	50                   	push   %eax
  800f53:	56                   	push   %esi
  800f54:	57                   	push   %edi
  800f55:	56                   	push   %esi
  800f56:	6a 00                	push   $0x0
  800f58:	e8 66 fc ff ff       	call   800bc3 <sys_page_map>
		if (r < 0) {
  800f5d:	83 c4 20             	add    $0x20,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	0f 89 b1 00 00 00    	jns    801019 <fork+0x192>
		    	panic("sys page map fault %e");
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	68 ec 25 80 00       	push   $0x8025ec
  800f70:	6a 54                	push   $0x54
  800f72:	68 ba 25 80 00       	push   $0x8025ba
  800f77:	e8 11 0e 00 00       	call   801d8d <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800f7c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f83:	f6 c2 02             	test   $0x2,%dl
  800f86:	75 0c                	jne    800f94 <fork+0x10d>
  800f88:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f8f:	f6 c4 08             	test   $0x8,%ah
  800f92:	74 5b                	je     800fef <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	68 05 08 00 00       	push   $0x805
  800f9c:	56                   	push   %esi
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	6a 00                	push   $0x0
  800fa1:	e8 1d fc ff ff       	call   800bc3 <sys_page_map>
		if (r < 0) {
  800fa6:	83 c4 20             	add    $0x20,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	79 14                	jns    800fc1 <fork+0x13a>
		    	panic("sys page map fault %e");
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	68 ec 25 80 00       	push   $0x8025ec
  800fb5:	6a 5b                	push   $0x5b
  800fb7:	68 ba 25 80 00       	push   $0x8025ba
  800fbc:	e8 cc 0d 00 00       	call   801d8d <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	68 05 08 00 00       	push   $0x805
  800fc9:	56                   	push   %esi
  800fca:	6a 00                	push   $0x0
  800fcc:	56                   	push   %esi
  800fcd:	6a 00                	push   $0x0
  800fcf:	e8 ef fb ff ff       	call   800bc3 <sys_page_map>
		if (r < 0) {
  800fd4:	83 c4 20             	add    $0x20,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	79 3e                	jns    801019 <fork+0x192>
		    	panic("sys page map fault %e");
  800fdb:	83 ec 04             	sub    $0x4,%esp
  800fde:	68 ec 25 80 00       	push   $0x8025ec
  800fe3:	6a 5f                	push   $0x5f
  800fe5:	68 ba 25 80 00       	push   $0x8025ba
  800fea:	e8 9e 0d 00 00       	call   801d8d <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	6a 05                	push   $0x5
  800ff4:	56                   	push   %esi
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 c5 fb ff ff       	call   800bc3 <sys_page_map>
		if (r < 0) {
  800ffe:	83 c4 20             	add    $0x20,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	79 14                	jns    801019 <fork+0x192>
		    	panic("sys page map fault %e");
  801005:	83 ec 04             	sub    $0x4,%esp
  801008:	68 ec 25 80 00       	push   $0x8025ec
  80100d:	6a 64                	push   $0x64
  80100f:	68 ba 25 80 00       	push   $0x8025ba
  801014:	e8 74 0d 00 00       	call   801d8d <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801019:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101f:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801025:	0f 85 de fe ff ff    	jne    800f09 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80102b:	a1 04 40 80 00       	mov    0x804004,%eax
  801030:	8b 40 70             	mov    0x70(%eax),%eax
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	50                   	push   %eax
  801037:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80103a:	57                   	push   %edi
  80103b:	e8 8b fc ff ff       	call   800ccb <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801040:	83 c4 08             	add    $0x8,%esp
  801043:	6a 02                	push   $0x2
  801045:	57                   	push   %edi
  801046:	e8 fc fb ff ff       	call   800c47 <sys_env_set_status>
	
	return envid;
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  801050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sfork>:

envid_t
sfork(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80105b:	b8 00 00 00 00       	mov    $0x0,%eax
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80106a:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	53                   	push   %ebx
  801074:	68 04 26 80 00       	push   $0x802604
  801079:	e8 7a f1 ff ff       	call   8001f8 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80107e:	c7 04 24 2b 01 80 00 	movl   $0x80012b,(%esp)
  801085:	e8 e7 fc ff ff       	call   800d71 <sys_thread_create>
  80108a:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80108c:	83 c4 08             	add    $0x8,%esp
  80108f:	53                   	push   %ebx
  801090:	68 04 26 80 00       	push   $0x802604
  801095:	e8 5e f1 ff ff       	call   8001f8 <cprintf>
	return id;
	//return 0;
}
  80109a:	89 f0                	mov    %esi,%eax
  80109c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80109f:	5b                   	pop    %ebx
  8010a0:	5e                   	pop    %esi
  8010a1:	5d                   	pop    %ebp
  8010a2:	c3                   	ret    

008010a3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ae:	c1 e8 0c             	shr    $0xc,%eax
}
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b9:	05 00 00 00 30       	add    $0x30000000,%eax
  8010be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010c3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010d5:	89 c2                	mov    %eax,%edx
  8010d7:	c1 ea 16             	shr    $0x16,%edx
  8010da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010e1:	f6 c2 01             	test   $0x1,%dl
  8010e4:	74 11                	je     8010f7 <fd_alloc+0x2d>
  8010e6:	89 c2                	mov    %eax,%edx
  8010e8:	c1 ea 0c             	shr    $0xc,%edx
  8010eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f2:	f6 c2 01             	test   $0x1,%dl
  8010f5:	75 09                	jne    801100 <fd_alloc+0x36>
			*fd_store = fd;
  8010f7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fe:	eb 17                	jmp    801117 <fd_alloc+0x4d>
  801100:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801105:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80110a:	75 c9                	jne    8010d5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80110c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801112:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80111f:	83 f8 1f             	cmp    $0x1f,%eax
  801122:	77 36                	ja     80115a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801124:	c1 e0 0c             	shl    $0xc,%eax
  801127:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	c1 ea 16             	shr    $0x16,%edx
  801131:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801138:	f6 c2 01             	test   $0x1,%dl
  80113b:	74 24                	je     801161 <fd_lookup+0x48>
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	c1 ea 0c             	shr    $0xc,%edx
  801142:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801149:	f6 c2 01             	test   $0x1,%dl
  80114c:	74 1a                	je     801168 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80114e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801151:	89 02                	mov    %eax,(%edx)
	return 0;
  801153:	b8 00 00 00 00       	mov    $0x0,%eax
  801158:	eb 13                	jmp    80116d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80115a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115f:	eb 0c                	jmp    80116d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801161:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801166:	eb 05                	jmp    80116d <fd_lookup+0x54>
  801168:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	83 ec 08             	sub    $0x8,%esp
  801175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801178:	ba a4 26 80 00       	mov    $0x8026a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80117d:	eb 13                	jmp    801192 <dev_lookup+0x23>
  80117f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801182:	39 08                	cmp    %ecx,(%eax)
  801184:	75 0c                	jne    801192 <dev_lookup+0x23>
			*dev = devtab[i];
  801186:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801189:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118b:	b8 00 00 00 00       	mov    $0x0,%eax
  801190:	eb 2e                	jmp    8011c0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801192:	8b 02                	mov    (%edx),%eax
  801194:	85 c0                	test   %eax,%eax
  801196:	75 e7                	jne    80117f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801198:	a1 04 40 80 00       	mov    0x804004,%eax
  80119d:	8b 40 54             	mov    0x54(%eax),%eax
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	51                   	push   %ecx
  8011a4:	50                   	push   %eax
  8011a5:	68 28 26 80 00       	push   $0x802628
  8011aa:	e8 49 f0 ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  8011af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    

008011c2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	56                   	push   %esi
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 10             	sub    $0x10,%esp
  8011ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8011cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011da:	c1 e8 0c             	shr    $0xc,%eax
  8011dd:	50                   	push   %eax
  8011de:	e8 36 ff ff ff       	call   801119 <fd_lookup>
  8011e3:	83 c4 08             	add    $0x8,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 05                	js     8011ef <fd_close+0x2d>
	    || fd != fd2)
  8011ea:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ed:	74 0c                	je     8011fb <fd_close+0x39>
		return (must_exist ? r : 0);
  8011ef:	84 db                	test   %bl,%bl
  8011f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f6:	0f 44 c2             	cmove  %edx,%eax
  8011f9:	eb 41                	jmp    80123c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011fb:	83 ec 08             	sub    $0x8,%esp
  8011fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801201:	50                   	push   %eax
  801202:	ff 36                	pushl  (%esi)
  801204:	e8 66 ff ff ff       	call   80116f <dev_lookup>
  801209:	89 c3                	mov    %eax,%ebx
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	85 c0                	test   %eax,%eax
  801210:	78 1a                	js     80122c <fd_close+0x6a>
		if (dev->dev_close)
  801212:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801215:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801218:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80121d:	85 c0                	test   %eax,%eax
  80121f:	74 0b                	je     80122c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801221:	83 ec 0c             	sub    $0xc,%esp
  801224:	56                   	push   %esi
  801225:	ff d0                	call   *%eax
  801227:	89 c3                	mov    %eax,%ebx
  801229:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	56                   	push   %esi
  801230:	6a 00                	push   $0x0
  801232:	e8 ce f9 ff ff       	call   800c05 <sys_page_unmap>
	return r;
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	89 d8                	mov    %ebx,%eax
}
  80123c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123f:	5b                   	pop    %ebx
  801240:	5e                   	pop    %esi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801249:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	ff 75 08             	pushl  0x8(%ebp)
  801250:	e8 c4 fe ff ff       	call   801119 <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 10                	js     80126c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	6a 01                	push   $0x1
  801261:	ff 75 f4             	pushl  -0xc(%ebp)
  801264:	e8 59 ff ff ff       	call   8011c2 <fd_close>
  801269:	83 c4 10             	add    $0x10,%esp
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <close_all>:

void
close_all(void)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	53                   	push   %ebx
  801272:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801275:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	53                   	push   %ebx
  80127e:	e8 c0 ff ff ff       	call   801243 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801283:	83 c3 01             	add    $0x1,%ebx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	83 fb 20             	cmp    $0x20,%ebx
  80128c:	75 ec                	jne    80127a <close_all+0xc>
		close(i);
}
  80128e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801291:	c9                   	leave  
  801292:	c3                   	ret    

00801293 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	57                   	push   %edi
  801297:	56                   	push   %esi
  801298:	53                   	push   %ebx
  801299:	83 ec 2c             	sub    $0x2c,%esp
  80129c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80129f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a2:	50                   	push   %eax
  8012a3:	ff 75 08             	pushl  0x8(%ebp)
  8012a6:	e8 6e fe ff ff       	call   801119 <fd_lookup>
  8012ab:	83 c4 08             	add    $0x8,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	0f 88 c1 00 00 00    	js     801377 <dup+0xe4>
		return r;
	close(newfdnum);
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	56                   	push   %esi
  8012ba:	e8 84 ff ff ff       	call   801243 <close>

	newfd = INDEX2FD(newfdnum);
  8012bf:	89 f3                	mov    %esi,%ebx
  8012c1:	c1 e3 0c             	shl    $0xc,%ebx
  8012c4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012ca:	83 c4 04             	add    $0x4,%esp
  8012cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012d0:	e8 de fd ff ff       	call   8010b3 <fd2data>
  8012d5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012d7:	89 1c 24             	mov    %ebx,(%esp)
  8012da:	e8 d4 fd ff ff       	call   8010b3 <fd2data>
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012e5:	89 f8                	mov    %edi,%eax
  8012e7:	c1 e8 16             	shr    $0x16,%eax
  8012ea:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012f1:	a8 01                	test   $0x1,%al
  8012f3:	74 37                	je     80132c <dup+0x99>
  8012f5:	89 f8                	mov    %edi,%eax
  8012f7:	c1 e8 0c             	shr    $0xc,%eax
  8012fa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801301:	f6 c2 01             	test   $0x1,%dl
  801304:	74 26                	je     80132c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801306:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	25 07 0e 00 00       	and    $0xe07,%eax
  801315:	50                   	push   %eax
  801316:	ff 75 d4             	pushl  -0x2c(%ebp)
  801319:	6a 00                	push   $0x0
  80131b:	57                   	push   %edi
  80131c:	6a 00                	push   $0x0
  80131e:	e8 a0 f8 ff ff       	call   800bc3 <sys_page_map>
  801323:	89 c7                	mov    %eax,%edi
  801325:	83 c4 20             	add    $0x20,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 2e                	js     80135a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80132f:	89 d0                	mov    %edx,%eax
  801331:	c1 e8 0c             	shr    $0xc,%eax
  801334:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	25 07 0e 00 00       	and    $0xe07,%eax
  801343:	50                   	push   %eax
  801344:	53                   	push   %ebx
  801345:	6a 00                	push   $0x0
  801347:	52                   	push   %edx
  801348:	6a 00                	push   $0x0
  80134a:	e8 74 f8 ff ff       	call   800bc3 <sys_page_map>
  80134f:	89 c7                	mov    %eax,%edi
  801351:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801354:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801356:	85 ff                	test   %edi,%edi
  801358:	79 1d                	jns    801377 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	53                   	push   %ebx
  80135e:	6a 00                	push   $0x0
  801360:	e8 a0 f8 ff ff       	call   800c05 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801365:	83 c4 08             	add    $0x8,%esp
  801368:	ff 75 d4             	pushl  -0x2c(%ebp)
  80136b:	6a 00                	push   $0x0
  80136d:	e8 93 f8 ff ff       	call   800c05 <sys_page_unmap>
	return r;
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	89 f8                	mov    %edi,%eax
}
  801377:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137a:	5b                   	pop    %ebx
  80137b:	5e                   	pop    %esi
  80137c:	5f                   	pop    %edi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    

0080137f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	53                   	push   %ebx
  801383:	83 ec 14             	sub    $0x14,%esp
  801386:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801389:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	53                   	push   %ebx
  80138e:	e8 86 fd ff ff       	call   801119 <fd_lookup>
  801393:	83 c4 08             	add    $0x8,%esp
  801396:	89 c2                	mov    %eax,%edx
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 6d                	js     801409 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a2:	50                   	push   %eax
  8013a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a6:	ff 30                	pushl  (%eax)
  8013a8:	e8 c2 fd ff ff       	call   80116f <dev_lookup>
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 4c                	js     801400 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b7:	8b 42 08             	mov    0x8(%edx),%eax
  8013ba:	83 e0 03             	and    $0x3,%eax
  8013bd:	83 f8 01             	cmp    $0x1,%eax
  8013c0:	75 21                	jne    8013e3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c7:	8b 40 54             	mov    0x54(%eax),%eax
  8013ca:	83 ec 04             	sub    $0x4,%esp
  8013cd:	53                   	push   %ebx
  8013ce:	50                   	push   %eax
  8013cf:	68 69 26 80 00       	push   $0x802669
  8013d4:	e8 1f ee ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e1:	eb 26                	jmp    801409 <read+0x8a>
	}
	if (!dev->dev_read)
  8013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e6:	8b 40 08             	mov    0x8(%eax),%eax
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	74 17                	je     801404 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8013ed:	83 ec 04             	sub    $0x4,%esp
  8013f0:	ff 75 10             	pushl  0x10(%ebp)
  8013f3:	ff 75 0c             	pushl  0xc(%ebp)
  8013f6:	52                   	push   %edx
  8013f7:	ff d0                	call   *%eax
  8013f9:	89 c2                	mov    %eax,%edx
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	eb 09                	jmp    801409 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801400:	89 c2                	mov    %eax,%edx
  801402:	eb 05                	jmp    801409 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801404:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801409:	89 d0                	mov    %edx,%eax
  80140b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140e:	c9                   	leave  
  80140f:	c3                   	ret    

00801410 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	57                   	push   %edi
  801414:	56                   	push   %esi
  801415:	53                   	push   %ebx
  801416:	83 ec 0c             	sub    $0xc,%esp
  801419:	8b 7d 08             	mov    0x8(%ebp),%edi
  80141c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80141f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801424:	eb 21                	jmp    801447 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801426:	83 ec 04             	sub    $0x4,%esp
  801429:	89 f0                	mov    %esi,%eax
  80142b:	29 d8                	sub    %ebx,%eax
  80142d:	50                   	push   %eax
  80142e:	89 d8                	mov    %ebx,%eax
  801430:	03 45 0c             	add    0xc(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	57                   	push   %edi
  801435:	e8 45 ff ff ff       	call   80137f <read>
		if (m < 0)
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 10                	js     801451 <readn+0x41>
			return m;
		if (m == 0)
  801441:	85 c0                	test   %eax,%eax
  801443:	74 0a                	je     80144f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801445:	01 c3                	add    %eax,%ebx
  801447:	39 f3                	cmp    %esi,%ebx
  801449:	72 db                	jb     801426 <readn+0x16>
  80144b:	89 d8                	mov    %ebx,%eax
  80144d:	eb 02                	jmp    801451 <readn+0x41>
  80144f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801451:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5f                   	pop    %edi
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    

00801459 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	83 ec 14             	sub    $0x14,%esp
  801460:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801463:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	53                   	push   %ebx
  801468:	e8 ac fc ff ff       	call   801119 <fd_lookup>
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	89 c2                	mov    %eax,%edx
  801472:	85 c0                	test   %eax,%eax
  801474:	78 68                	js     8014de <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801480:	ff 30                	pushl  (%eax)
  801482:	e8 e8 fc ff ff       	call   80116f <dev_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 47                	js     8014d5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801495:	75 21                	jne    8014b8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801497:	a1 04 40 80 00       	mov    0x804004,%eax
  80149c:	8b 40 54             	mov    0x54(%eax),%eax
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	53                   	push   %ebx
  8014a3:	50                   	push   %eax
  8014a4:	68 85 26 80 00       	push   $0x802685
  8014a9:	e8 4a ed ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014b6:	eb 26                	jmp    8014de <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014bb:	8b 52 0c             	mov    0xc(%edx),%edx
  8014be:	85 d2                	test   %edx,%edx
  8014c0:	74 17                	je     8014d9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	ff 75 10             	pushl  0x10(%ebp)
  8014c8:	ff 75 0c             	pushl  0xc(%ebp)
  8014cb:	50                   	push   %eax
  8014cc:	ff d2                	call   *%edx
  8014ce:	89 c2                	mov    %eax,%edx
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	eb 09                	jmp    8014de <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d5:	89 c2                	mov    %eax,%edx
  8014d7:	eb 05                	jmp    8014de <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014de:	89 d0                	mov    %edx,%eax
  8014e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014eb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	ff 75 08             	pushl  0x8(%ebp)
  8014f2:	e8 22 fc ff ff       	call   801119 <fd_lookup>
  8014f7:	83 c4 08             	add    $0x8,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 0e                	js     80150c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801501:	8b 55 0c             	mov    0xc(%ebp),%edx
  801504:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801507:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	53                   	push   %ebx
  801512:	83 ec 14             	sub    $0x14,%esp
  801515:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801518:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	53                   	push   %ebx
  80151d:	e8 f7 fb ff ff       	call   801119 <fd_lookup>
  801522:	83 c4 08             	add    $0x8,%esp
  801525:	89 c2                	mov    %eax,%edx
  801527:	85 c0                	test   %eax,%eax
  801529:	78 65                	js     801590 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152b:	83 ec 08             	sub    $0x8,%esp
  80152e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801531:	50                   	push   %eax
  801532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801535:	ff 30                	pushl  (%eax)
  801537:	e8 33 fc ff ff       	call   80116f <dev_lookup>
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 44                	js     801587 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801546:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154a:	75 21                	jne    80156d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80154c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801551:	8b 40 54             	mov    0x54(%eax),%eax
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	53                   	push   %ebx
  801558:	50                   	push   %eax
  801559:	68 48 26 80 00       	push   $0x802648
  80155e:	e8 95 ec ff ff       	call   8001f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156b:	eb 23                	jmp    801590 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80156d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801570:	8b 52 18             	mov    0x18(%edx),%edx
  801573:	85 d2                	test   %edx,%edx
  801575:	74 14                	je     80158b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	ff 75 0c             	pushl  0xc(%ebp)
  80157d:	50                   	push   %eax
  80157e:	ff d2                	call   *%edx
  801580:	89 c2                	mov    %eax,%edx
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	eb 09                	jmp    801590 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801587:	89 c2                	mov    %eax,%edx
  801589:	eb 05                	jmp    801590 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80158b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801590:	89 d0                	mov    %edx,%eax
  801592:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	53                   	push   %ebx
  80159b:	83 ec 14             	sub    $0x14,%esp
  80159e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a4:	50                   	push   %eax
  8015a5:	ff 75 08             	pushl  0x8(%ebp)
  8015a8:	e8 6c fb ff ff       	call   801119 <fd_lookup>
  8015ad:	83 c4 08             	add    $0x8,%esp
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 58                	js     80160e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	ff 30                	pushl  (%eax)
  8015c2:	e8 a8 fb ff ff       	call   80116f <dev_lookup>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 37                	js     801605 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015d5:	74 32                	je     801609 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015da:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015e1:	00 00 00 
	stat->st_isdir = 0;
  8015e4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015eb:	00 00 00 
	stat->st_dev = dev;
  8015ee:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	53                   	push   %ebx
  8015f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8015fb:	ff 50 14             	call   *0x14(%eax)
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	eb 09                	jmp    80160e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	89 c2                	mov    %eax,%edx
  801607:	eb 05                	jmp    80160e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801609:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80160e:	89 d0                	mov    %edx,%eax
  801610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801613:	c9                   	leave  
  801614:	c3                   	ret    

00801615 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	56                   	push   %esi
  801619:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	6a 00                	push   $0x0
  80161f:	ff 75 08             	pushl  0x8(%ebp)
  801622:	e8 e3 01 00 00       	call   80180a <open>
  801627:	89 c3                	mov    %eax,%ebx
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 1b                	js     80164b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801630:	83 ec 08             	sub    $0x8,%esp
  801633:	ff 75 0c             	pushl  0xc(%ebp)
  801636:	50                   	push   %eax
  801637:	e8 5b ff ff ff       	call   801597 <fstat>
  80163c:	89 c6                	mov    %eax,%esi
	close(fd);
  80163e:	89 1c 24             	mov    %ebx,(%esp)
  801641:	e8 fd fb ff ff       	call   801243 <close>
	return r;
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	89 f0                	mov    %esi,%eax
}
  80164b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5d                   	pop    %ebp
  801651:	c3                   	ret    

00801652 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	56                   	push   %esi
  801656:	53                   	push   %ebx
  801657:	89 c6                	mov    %eax,%esi
  801659:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80165b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801662:	75 12                	jne    801676 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801664:	83 ec 0c             	sub    $0xc,%esp
  801667:	6a 01                	push   $0x1
  801669:	e8 ce 08 00 00       	call   801f3c <ipc_find_env>
  80166e:	a3 00 40 80 00       	mov    %eax,0x804000
  801673:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801676:	6a 07                	push   $0x7
  801678:	68 00 50 80 00       	push   $0x805000
  80167d:	56                   	push   %esi
  80167e:	ff 35 00 40 80 00    	pushl  0x804000
  801684:	e8 51 08 00 00       	call   801eda <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801689:	83 c4 0c             	add    $0xc,%esp
  80168c:	6a 00                	push   $0x0
  80168e:	53                   	push   %ebx
  80168f:	6a 00                	push   $0x0
  801691:	e8 cc 07 00 00       	call   801e62 <ipc_recv>
}
  801696:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8016c0:	e8 8d ff ff ff       	call   801652 <fsipc>
}
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dd:	b8 06 00 00 00       	mov    $0x6,%eax
  8016e2:	e8 6b ff ff ff       	call   801652 <fsipc>
}
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 04             	sub    $0x4,%esp
  8016f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	b8 05 00 00 00       	mov    $0x5,%eax
  801708:	e8 45 ff ff ff       	call   801652 <fsipc>
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 2c                	js     80173d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	68 00 50 80 00       	push   $0x805000
  801719:	53                   	push   %ebx
  80171a:	e8 5e f0 ff ff       	call   80077d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80171f:	a1 80 50 80 00       	mov    0x805080,%eax
  801724:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80172a:	a1 84 50 80 00       	mov    0x805084,%eax
  80172f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	83 ec 0c             	sub    $0xc,%esp
  801748:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80174b:	8b 55 08             	mov    0x8(%ebp),%edx
  80174e:	8b 52 0c             	mov    0xc(%edx),%edx
  801751:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801757:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80175c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801761:	0f 47 c2             	cmova  %edx,%eax
  801764:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801769:	50                   	push   %eax
  80176a:	ff 75 0c             	pushl  0xc(%ebp)
  80176d:	68 08 50 80 00       	push   $0x805008
  801772:	e8 98 f1 ff ff       	call   80090f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801777:	ba 00 00 00 00       	mov    $0x0,%edx
  80177c:	b8 04 00 00 00       	mov    $0x4,%eax
  801781:	e8 cc fe ff ff       	call   801652 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	56                   	push   %esi
  80178c:	53                   	push   %ebx
  80178d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	8b 40 0c             	mov    0xc(%eax),%eax
  801796:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80179b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a6:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ab:	e8 a2 fe ff ff       	call   801652 <fsipc>
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 4b                	js     801801 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017b6:	39 c6                	cmp    %eax,%esi
  8017b8:	73 16                	jae    8017d0 <devfile_read+0x48>
  8017ba:	68 b4 26 80 00       	push   $0x8026b4
  8017bf:	68 bb 26 80 00       	push   $0x8026bb
  8017c4:	6a 7c                	push   $0x7c
  8017c6:	68 d0 26 80 00       	push   $0x8026d0
  8017cb:	e8 bd 05 00 00       	call   801d8d <_panic>
	assert(r <= PGSIZE);
  8017d0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017d5:	7e 16                	jle    8017ed <devfile_read+0x65>
  8017d7:	68 db 26 80 00       	push   $0x8026db
  8017dc:	68 bb 26 80 00       	push   $0x8026bb
  8017e1:	6a 7d                	push   $0x7d
  8017e3:	68 d0 26 80 00       	push   $0x8026d0
  8017e8:	e8 a0 05 00 00       	call   801d8d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ed:	83 ec 04             	sub    $0x4,%esp
  8017f0:	50                   	push   %eax
  8017f1:	68 00 50 80 00       	push   $0x805000
  8017f6:	ff 75 0c             	pushl  0xc(%ebp)
  8017f9:	e8 11 f1 ff ff       	call   80090f <memmove>
	return r;
  8017fe:	83 c4 10             	add    $0x10,%esp
}
  801801:	89 d8                	mov    %ebx,%eax
  801803:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801806:	5b                   	pop    %ebx
  801807:	5e                   	pop    %esi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	83 ec 20             	sub    $0x20,%esp
  801811:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801814:	53                   	push   %ebx
  801815:	e8 2a ef ff ff       	call   800744 <strlen>
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801822:	7f 67                	jg     80188b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801824:	83 ec 0c             	sub    $0xc,%esp
  801827:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182a:	50                   	push   %eax
  80182b:	e8 9a f8 ff ff       	call   8010ca <fd_alloc>
  801830:	83 c4 10             	add    $0x10,%esp
		return r;
  801833:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801835:	85 c0                	test   %eax,%eax
  801837:	78 57                	js     801890 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801839:	83 ec 08             	sub    $0x8,%esp
  80183c:	53                   	push   %ebx
  80183d:	68 00 50 80 00       	push   $0x805000
  801842:	e8 36 ef ff ff       	call   80077d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80184f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801852:	b8 01 00 00 00       	mov    $0x1,%eax
  801857:	e8 f6 fd ff ff       	call   801652 <fsipc>
  80185c:	89 c3                	mov    %eax,%ebx
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	85 c0                	test   %eax,%eax
  801863:	79 14                	jns    801879 <open+0x6f>
		fd_close(fd, 0);
  801865:	83 ec 08             	sub    $0x8,%esp
  801868:	6a 00                	push   $0x0
  80186a:	ff 75 f4             	pushl  -0xc(%ebp)
  80186d:	e8 50 f9 ff ff       	call   8011c2 <fd_close>
		return r;
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	89 da                	mov    %ebx,%edx
  801877:	eb 17                	jmp    801890 <open+0x86>
	}

	return fd2num(fd);
  801879:	83 ec 0c             	sub    $0xc,%esp
  80187c:	ff 75 f4             	pushl  -0xc(%ebp)
  80187f:	e8 1f f8 ff ff       	call   8010a3 <fd2num>
  801884:	89 c2                	mov    %eax,%edx
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	eb 05                	jmp    801890 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80188b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801890:	89 d0                	mov    %edx,%eax
  801892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80189d:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a7:	e8 a6 fd ff ff       	call   801652 <fsipc>
}
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	56                   	push   %esi
  8018b2:	53                   	push   %ebx
  8018b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b6:	83 ec 0c             	sub    $0xc,%esp
  8018b9:	ff 75 08             	pushl  0x8(%ebp)
  8018bc:	e8 f2 f7 ff ff       	call   8010b3 <fd2data>
  8018c1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c3:	83 c4 08             	add    $0x8,%esp
  8018c6:	68 e7 26 80 00       	push   $0x8026e7
  8018cb:	53                   	push   %ebx
  8018cc:	e8 ac ee ff ff       	call   80077d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d1:	8b 46 04             	mov    0x4(%esi),%eax
  8018d4:	2b 06                	sub    (%esi),%eax
  8018d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e3:	00 00 00 
	stat->st_dev = &devpipe;
  8018e6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018ed:	30 80 00 
	return 0;
}
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f8:	5b                   	pop    %ebx
  8018f9:	5e                   	pop    %esi
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	53                   	push   %ebx
  801900:	83 ec 0c             	sub    $0xc,%esp
  801903:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801906:	53                   	push   %ebx
  801907:	6a 00                	push   $0x0
  801909:	e8 f7 f2 ff ff       	call   800c05 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80190e:	89 1c 24             	mov    %ebx,(%esp)
  801911:	e8 9d f7 ff ff       	call   8010b3 <fd2data>
  801916:	83 c4 08             	add    $0x8,%esp
  801919:	50                   	push   %eax
  80191a:	6a 00                	push   $0x0
  80191c:	e8 e4 f2 ff ff       	call   800c05 <sys_page_unmap>
}
  801921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	57                   	push   %edi
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	83 ec 1c             	sub    $0x1c,%esp
  80192f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801932:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801934:	a1 04 40 80 00       	mov    0x804004,%eax
  801939:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80193c:	83 ec 0c             	sub    $0xc,%esp
  80193f:	ff 75 e0             	pushl  -0x20(%ebp)
  801942:	e8 35 06 00 00       	call   801f7c <pageref>
  801947:	89 c3                	mov    %eax,%ebx
  801949:	89 3c 24             	mov    %edi,(%esp)
  80194c:	e8 2b 06 00 00       	call   801f7c <pageref>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	39 c3                	cmp    %eax,%ebx
  801956:	0f 94 c1             	sete   %cl
  801959:	0f b6 c9             	movzbl %cl,%ecx
  80195c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80195f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801965:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801968:	39 ce                	cmp    %ecx,%esi
  80196a:	74 1b                	je     801987 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80196c:	39 c3                	cmp    %eax,%ebx
  80196e:	75 c4                	jne    801934 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801970:	8b 42 64             	mov    0x64(%edx),%eax
  801973:	ff 75 e4             	pushl  -0x1c(%ebp)
  801976:	50                   	push   %eax
  801977:	56                   	push   %esi
  801978:	68 ee 26 80 00       	push   $0x8026ee
  80197d:	e8 76 e8 ff ff       	call   8001f8 <cprintf>
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	eb ad                	jmp    801934 <_pipeisclosed+0xe>
	}
}
  801987:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80198a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5e                   	pop    %esi
  80198f:	5f                   	pop    %edi
  801990:	5d                   	pop    %ebp
  801991:	c3                   	ret    

00801992 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	57                   	push   %edi
  801996:	56                   	push   %esi
  801997:	53                   	push   %ebx
  801998:	83 ec 28             	sub    $0x28,%esp
  80199b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80199e:	56                   	push   %esi
  80199f:	e8 0f f7 ff ff       	call   8010b3 <fd2data>
  8019a4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ae:	eb 4b                	jmp    8019fb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019b0:	89 da                	mov    %ebx,%edx
  8019b2:	89 f0                	mov    %esi,%eax
  8019b4:	e8 6d ff ff ff       	call   801926 <_pipeisclosed>
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	75 48                	jne    801a05 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019bd:	e8 9f f1 ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c2:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c5:	8b 0b                	mov    (%ebx),%ecx
  8019c7:	8d 51 20             	lea    0x20(%ecx),%edx
  8019ca:	39 d0                	cmp    %edx,%eax
  8019cc:	73 e2                	jae    8019b0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019d5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019d8:	89 c2                	mov    %eax,%edx
  8019da:	c1 fa 1f             	sar    $0x1f,%edx
  8019dd:	89 d1                	mov    %edx,%ecx
  8019df:	c1 e9 1b             	shr    $0x1b,%ecx
  8019e2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019e5:	83 e2 1f             	and    $0x1f,%edx
  8019e8:	29 ca                	sub    %ecx,%edx
  8019ea:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019f2:	83 c0 01             	add    $0x1,%eax
  8019f5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f8:	83 c7 01             	add    $0x1,%edi
  8019fb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019fe:	75 c2                	jne    8019c2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a00:	8b 45 10             	mov    0x10(%ebp),%eax
  801a03:	eb 05                	jmp    801a0a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a05:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5e                   	pop    %esi
  801a0f:	5f                   	pop    %edi
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	57                   	push   %edi
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	83 ec 18             	sub    $0x18,%esp
  801a1b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a1e:	57                   	push   %edi
  801a1f:	e8 8f f6 ff ff       	call   8010b3 <fd2data>
  801a24:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a2e:	eb 3d                	jmp    801a6d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a30:	85 db                	test   %ebx,%ebx
  801a32:	74 04                	je     801a38 <devpipe_read+0x26>
				return i;
  801a34:	89 d8                	mov    %ebx,%eax
  801a36:	eb 44                	jmp    801a7c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a38:	89 f2                	mov    %esi,%edx
  801a3a:	89 f8                	mov    %edi,%eax
  801a3c:	e8 e5 fe ff ff       	call   801926 <_pipeisclosed>
  801a41:	85 c0                	test   %eax,%eax
  801a43:	75 32                	jne    801a77 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a45:	e8 17 f1 ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a4a:	8b 06                	mov    (%esi),%eax
  801a4c:	3b 46 04             	cmp    0x4(%esi),%eax
  801a4f:	74 df                	je     801a30 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a51:	99                   	cltd   
  801a52:	c1 ea 1b             	shr    $0x1b,%edx
  801a55:	01 d0                	add    %edx,%eax
  801a57:	83 e0 1f             	and    $0x1f,%eax
  801a5a:	29 d0                	sub    %edx,%eax
  801a5c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a64:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a67:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6a:	83 c3 01             	add    $0x1,%ebx
  801a6d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a70:	75 d8                	jne    801a4a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a72:	8b 45 10             	mov    0x10(%ebp),%eax
  801a75:	eb 05                	jmp    801a7c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a77:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	56                   	push   %esi
  801a88:	53                   	push   %ebx
  801a89:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8f:	50                   	push   %eax
  801a90:	e8 35 f6 ff ff       	call   8010ca <fd_alloc>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	89 c2                	mov    %eax,%edx
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	0f 88 2c 01 00 00    	js     801bce <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	68 07 04 00 00       	push   $0x407
  801aaa:	ff 75 f4             	pushl  -0xc(%ebp)
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 cc f0 ff ff       	call   800b80 <sys_page_alloc>
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	89 c2                	mov    %eax,%edx
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	0f 88 0d 01 00 00    	js     801bce <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac7:	50                   	push   %eax
  801ac8:	e8 fd f5 ff ff       	call   8010ca <fd_alloc>
  801acd:	89 c3                	mov    %eax,%ebx
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	0f 88 e2 00 00 00    	js     801bbc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ada:	83 ec 04             	sub    $0x4,%esp
  801add:	68 07 04 00 00       	push   $0x407
  801ae2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae5:	6a 00                	push   $0x0
  801ae7:	e8 94 f0 ff ff       	call   800b80 <sys_page_alloc>
  801aec:	89 c3                	mov    %eax,%ebx
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	85 c0                	test   %eax,%eax
  801af3:	0f 88 c3 00 00 00    	js     801bbc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	ff 75 f4             	pushl  -0xc(%ebp)
  801aff:	e8 af f5 ff ff       	call   8010b3 <fd2data>
  801b04:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b06:	83 c4 0c             	add    $0xc,%esp
  801b09:	68 07 04 00 00       	push   $0x407
  801b0e:	50                   	push   %eax
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 6a f0 ff ff       	call   800b80 <sys_page_alloc>
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 88 89 00 00 00    	js     801bac <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	ff 75 f0             	pushl  -0x10(%ebp)
  801b29:	e8 85 f5 ff ff       	call   8010b3 <fd2data>
  801b2e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b35:	50                   	push   %eax
  801b36:	6a 00                	push   $0x0
  801b38:	56                   	push   %esi
  801b39:	6a 00                	push   $0x0
  801b3b:	e8 83 f0 ff ff       	call   800bc3 <sys_page_map>
  801b40:	89 c3                	mov    %eax,%ebx
  801b42:	83 c4 20             	add    $0x20,%esp
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 55                	js     801b9e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b49:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b52:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b5e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b67:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	ff 75 f4             	pushl  -0xc(%ebp)
  801b79:	e8 25 f5 ff ff       	call   8010a3 <fd2num>
  801b7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b81:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b83:	83 c4 04             	add    $0x4,%esp
  801b86:	ff 75 f0             	pushl  -0x10(%ebp)
  801b89:	e8 15 f5 ff ff       	call   8010a3 <fd2num>
  801b8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b91:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9c:	eb 30                	jmp    801bce <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b9e:	83 ec 08             	sub    $0x8,%esp
  801ba1:	56                   	push   %esi
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 5c f0 ff ff       	call   800c05 <sys_page_unmap>
  801ba9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bac:	83 ec 08             	sub    $0x8,%esp
  801baf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb2:	6a 00                	push   $0x0
  801bb4:	e8 4c f0 ff ff       	call   800c05 <sys_page_unmap>
  801bb9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc2:	6a 00                	push   $0x0
  801bc4:	e8 3c f0 ff ff       	call   800c05 <sys_page_unmap>
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bce:	89 d0                	mov    %edx,%eax
  801bd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be0:	50                   	push   %eax
  801be1:	ff 75 08             	pushl  0x8(%ebp)
  801be4:	e8 30 f5 ff ff       	call   801119 <fd_lookup>
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 18                	js     801c08 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf6:	e8 b8 f4 ff ff       	call   8010b3 <fd2data>
	return _pipeisclosed(fd, p);
  801bfb:	89 c2                	mov    %eax,%edx
  801bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c00:	e8 21 fd ff ff       	call   801926 <_pipeisclosed>
  801c05:	83 c4 10             	add    $0x10,%esp
}
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c1a:	68 06 27 80 00       	push   $0x802706
  801c1f:	ff 75 0c             	pushl  0xc(%ebp)
  801c22:	e8 56 eb ff ff       	call   80077d <strcpy>
	return 0;
}
  801c27:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c3a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c3f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c45:	eb 2d                	jmp    801c74 <devcons_write+0x46>
		m = n - tot;
  801c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c4a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c4c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c4f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c54:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c57:	83 ec 04             	sub    $0x4,%esp
  801c5a:	53                   	push   %ebx
  801c5b:	03 45 0c             	add    0xc(%ebp),%eax
  801c5e:	50                   	push   %eax
  801c5f:	57                   	push   %edi
  801c60:	e8 aa ec ff ff       	call   80090f <memmove>
		sys_cputs(buf, m);
  801c65:	83 c4 08             	add    $0x8,%esp
  801c68:	53                   	push   %ebx
  801c69:	57                   	push   %edi
  801c6a:	e8 55 ee ff ff       	call   800ac4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c6f:	01 de                	add    %ebx,%esi
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	89 f0                	mov    %esi,%eax
  801c76:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c79:	72 cc                	jb     801c47 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7e:	5b                   	pop    %ebx
  801c7f:	5e                   	pop    %esi
  801c80:	5f                   	pop    %edi
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 08             	sub    $0x8,%esp
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c92:	74 2a                	je     801cbe <devcons_read+0x3b>
  801c94:	eb 05                	jmp    801c9b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c96:	e8 c6 ee ff ff       	call   800b61 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c9b:	e8 42 ee ff ff       	call   800ae2 <sys_cgetc>
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	74 f2                	je     801c96 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	78 16                	js     801cbe <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ca8:	83 f8 04             	cmp    $0x4,%eax
  801cab:	74 0c                	je     801cb9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cad:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb0:	88 02                	mov    %al,(%edx)
	return 1;
  801cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb7:	eb 05                	jmp    801cbe <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ccc:	6a 01                	push   $0x1
  801cce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd1:	50                   	push   %eax
  801cd2:	e8 ed ed ff ff       	call   800ac4 <sys_cputs>
}
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <getchar>:

int
getchar(void)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ce2:	6a 01                	push   $0x1
  801ce4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce7:	50                   	push   %eax
  801ce8:	6a 00                	push   $0x0
  801cea:	e8 90 f6 ff ff       	call   80137f <read>
	if (r < 0)
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	78 0f                	js     801d05 <getchar+0x29>
		return r;
	if (r < 1)
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	7e 06                	jle    801d00 <getchar+0x24>
		return -E_EOF;
	return c;
  801cfa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cfe:	eb 05                	jmp    801d05 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d00:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    

00801d07 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	ff 75 08             	pushl  0x8(%ebp)
  801d14:	e8 00 f4 ff ff       	call   801119 <fd_lookup>
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	78 11                	js     801d31 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d23:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d29:	39 10                	cmp    %edx,(%eax)
  801d2b:	0f 94 c0             	sete   %al
  801d2e:	0f b6 c0             	movzbl %al,%eax
}
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    

00801d33 <opencons>:

int
opencons(void)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3c:	50                   	push   %eax
  801d3d:	e8 88 f3 ff ff       	call   8010ca <fd_alloc>
  801d42:	83 c4 10             	add    $0x10,%esp
		return r;
  801d45:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 3e                	js     801d89 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d4b:	83 ec 04             	sub    $0x4,%esp
  801d4e:	68 07 04 00 00       	push   $0x407
  801d53:	ff 75 f4             	pushl  -0xc(%ebp)
  801d56:	6a 00                	push   $0x0
  801d58:	e8 23 ee ff ff       	call   800b80 <sys_page_alloc>
  801d5d:	83 c4 10             	add    $0x10,%esp
		return r;
  801d60:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 23                	js     801d89 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d66:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d74:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d7b:	83 ec 0c             	sub    $0xc,%esp
  801d7e:	50                   	push   %eax
  801d7f:	e8 1f f3 ff ff       	call   8010a3 <fd2num>
  801d84:	89 c2                	mov    %eax,%edx
  801d86:	83 c4 10             	add    $0x10,%esp
}
  801d89:	89 d0                	mov    %edx,%eax
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    

00801d8d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d92:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d95:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d9b:	e8 a2 ed ff ff       	call   800b42 <sys_getenvid>
  801da0:	83 ec 0c             	sub    $0xc,%esp
  801da3:	ff 75 0c             	pushl  0xc(%ebp)
  801da6:	ff 75 08             	pushl  0x8(%ebp)
  801da9:	56                   	push   %esi
  801daa:	50                   	push   %eax
  801dab:	68 14 27 80 00       	push   $0x802714
  801db0:	e8 43 e4 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801db5:	83 c4 18             	add    $0x18,%esp
  801db8:	53                   	push   %ebx
  801db9:	ff 75 10             	pushl  0x10(%ebp)
  801dbc:	e8 e6 e3 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  801dc1:	c7 04 24 6f 22 80 00 	movl   $0x80226f,(%esp)
  801dc8:	e8 2b e4 ff ff       	call   8001f8 <cprintf>
  801dcd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dd0:	cc                   	int3   
  801dd1:	eb fd                	jmp    801dd0 <_panic+0x43>

00801dd3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dd9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801de0:	75 2a                	jne    801e0c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801de2:	83 ec 04             	sub    $0x4,%esp
  801de5:	6a 07                	push   $0x7
  801de7:	68 00 f0 bf ee       	push   $0xeebff000
  801dec:	6a 00                	push   $0x0
  801dee:	e8 8d ed ff ff       	call   800b80 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801df3:	83 c4 10             	add    $0x10,%esp
  801df6:	85 c0                	test   %eax,%eax
  801df8:	79 12                	jns    801e0c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801dfa:	50                   	push   %eax
  801dfb:	68 38 27 80 00       	push   $0x802738
  801e00:	6a 23                	push   $0x23
  801e02:	68 3c 27 80 00       	push   $0x80273c
  801e07:	e8 81 ff ff ff       	call   801d8d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e14:	83 ec 08             	sub    $0x8,%esp
  801e17:	68 3e 1e 80 00       	push   $0x801e3e
  801e1c:	6a 00                	push   $0x0
  801e1e:	e8 a8 ee ff ff       	call   800ccb <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	85 c0                	test   %eax,%eax
  801e28:	79 12                	jns    801e3c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e2a:	50                   	push   %eax
  801e2b:	68 38 27 80 00       	push   $0x802738
  801e30:	6a 2c                	push   $0x2c
  801e32:	68 3c 27 80 00       	push   $0x80273c
  801e37:	e8 51 ff ff ff       	call   801d8d <_panic>
	}
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e3e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e3f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e44:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e46:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e49:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e4d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e52:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e56:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e58:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e5b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e5c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e5f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e60:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e61:	c3                   	ret    

00801e62 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	56                   	push   %esi
  801e66:	53                   	push   %ebx
  801e67:	8b 75 08             	mov    0x8(%ebp),%esi
  801e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e70:	85 c0                	test   %eax,%eax
  801e72:	75 12                	jne    801e86 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e74:	83 ec 0c             	sub    $0xc,%esp
  801e77:	68 00 00 c0 ee       	push   $0xeec00000
  801e7c:	e8 af ee ff ff       	call   800d30 <sys_ipc_recv>
  801e81:	83 c4 10             	add    $0x10,%esp
  801e84:	eb 0c                	jmp    801e92 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	50                   	push   %eax
  801e8a:	e8 a1 ee ff ff       	call   800d30 <sys_ipc_recv>
  801e8f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e92:	85 f6                	test   %esi,%esi
  801e94:	0f 95 c1             	setne  %cl
  801e97:	85 db                	test   %ebx,%ebx
  801e99:	0f 95 c2             	setne  %dl
  801e9c:	84 d1                	test   %dl,%cl
  801e9e:	74 09                	je     801ea9 <ipc_recv+0x47>
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	c1 ea 1f             	shr    $0x1f,%edx
  801ea5:	84 d2                	test   %dl,%dl
  801ea7:	75 2a                	jne    801ed3 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ea9:	85 f6                	test   %esi,%esi
  801eab:	74 0d                	je     801eba <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801ead:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801eb8:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801eba:	85 db                	test   %ebx,%ebx
  801ebc:	74 0d                	je     801ecb <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ebe:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec3:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801ec9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ecb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed0:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801ed3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed6:	5b                   	pop    %ebx
  801ed7:	5e                   	pop    %esi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	57                   	push   %edi
  801ede:	56                   	push   %esi
  801edf:	53                   	push   %ebx
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ee6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801eec:	85 db                	test   %ebx,%ebx
  801eee:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ef3:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ef6:	ff 75 14             	pushl  0x14(%ebp)
  801ef9:	53                   	push   %ebx
  801efa:	56                   	push   %esi
  801efb:	57                   	push   %edi
  801efc:	e8 0c ee ff ff       	call   800d0d <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f01:	89 c2                	mov    %eax,%edx
  801f03:	c1 ea 1f             	shr    $0x1f,%edx
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	84 d2                	test   %dl,%dl
  801f0b:	74 17                	je     801f24 <ipc_send+0x4a>
  801f0d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f10:	74 12                	je     801f24 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f12:	50                   	push   %eax
  801f13:	68 4a 27 80 00       	push   $0x80274a
  801f18:	6a 47                	push   $0x47
  801f1a:	68 58 27 80 00       	push   $0x802758
  801f1f:	e8 69 fe ff ff       	call   801d8d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f24:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f27:	75 07                	jne    801f30 <ipc_send+0x56>
			sys_yield();
  801f29:	e8 33 ec ff ff       	call   800b61 <sys_yield>
  801f2e:	eb c6                	jmp    801ef6 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f30:	85 c0                	test   %eax,%eax
  801f32:	75 c2                	jne    801ef6 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f37:	5b                   	pop    %ebx
  801f38:	5e                   	pop    %esi
  801f39:	5f                   	pop    %edi
  801f3a:	5d                   	pop    %ebp
  801f3b:	c3                   	ret    

00801f3c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f47:	89 c2                	mov    %eax,%edx
  801f49:	c1 e2 07             	shl    $0x7,%edx
  801f4c:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801f53:	8b 52 5c             	mov    0x5c(%edx),%edx
  801f56:	39 ca                	cmp    %ecx,%edx
  801f58:	75 11                	jne    801f6b <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f5a:	89 c2                	mov    %eax,%edx
  801f5c:	c1 e2 07             	shl    $0x7,%edx
  801f5f:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f66:	8b 40 54             	mov    0x54(%eax),%eax
  801f69:	eb 0f                	jmp    801f7a <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f6b:	83 c0 01             	add    $0x1,%eax
  801f6e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f73:	75 d2                	jne    801f47 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    

00801f7c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f82:	89 d0                	mov    %edx,%eax
  801f84:	c1 e8 16             	shr    $0x16,%eax
  801f87:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f8e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f93:	f6 c1 01             	test   $0x1,%cl
  801f96:	74 1d                	je     801fb5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f98:	c1 ea 0c             	shr    $0xc,%edx
  801f9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa2:	f6 c2 01             	test   $0x1,%dl
  801fa5:	74 0e                	je     801fb5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa7:	c1 ea 0c             	shr    $0xc,%edx
  801faa:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb1:	ef 
  801fb2:	0f b7 c0             	movzwl %ax,%eax
}
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    
  801fb7:	66 90                	xchg   %ax,%ax
  801fb9:	66 90                	xchg   %ax,%ax
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
