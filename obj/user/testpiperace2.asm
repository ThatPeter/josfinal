
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 9d 01 00 00       	call   8001ce <libmain>
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
  800039:	83 ec 28             	sub    $0x28,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 80 25 80 00       	push   $0x802580
  800041:	e8 e4 02 00 00       	call   80032a <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 a6 1d 00 00       	call   801df7 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 ce 25 80 00       	push   $0x8025ce
  80005e:	6a 0d                	push   $0xd
  800060:	68 d7 25 80 00       	push   $0x8025d7
  800065:	e8 e7 01 00 00       	call   800251 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 6a 0f 00 00       	call   800fd9 <fork>
  80006f:	89 c7                	mov    %eax,%edi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 ec 25 80 00       	push   $0x8025ec
  80007b:	6a 0f                	push   $0xf
  80007d:	68 d7 25 80 00       	push   $0x8025d7
  800082:	e8 ca 01 00 00       	call   800251 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 0e 15 00 00       	call   8015a4 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ee                	imul   %esi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 f5 25 80 00       	push   $0x8025f5
  8000c3:	e8 62 02 00 00       	call   80032a <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 1c 15 00 00       	call   8015f4 <dup>
			sys_yield();
  8000d8:	e8 b6 0b 00 00       	call   800c93 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 bb 14 00 00       	call   8015a4 <close>
			sys_yield();
  8000e9:	e8 a5 0b 00 00       	call   800c93 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 36 01 00 00       	call   800237 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 fb                	mov    %edi,%ebx
  800103:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  800109:	69 db d4 00 00 00    	imul   $0xd4,%ebx,%ebx
  80010f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 28 1e 00 00       	call   801f4a <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 1d                	je     800146 <umain+0x113>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 f9 25 80 00       	push   $0x8025f9
  800131:	e8 f4 01 00 00       	call   80032a <cprintf>
			sys_env_destroy(r);
  800136:	89 3c 24             	mov    %edi,(%esp)
  800139:	e8 f5 0a 00 00       	call   800c33 <sys_env_destroy>
			exit();
  80013e:	e8 f4 00 00 00       	call   800237 <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 83 ac 00 00 00    	mov    0xac(%ebx),%eax
  80014c:	83 f8 02             	cmp    $0x2,%eax
  80014f:	74 c6                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	68 15 26 80 00       	push   $0x802615
  800159:	e8 cc 01 00 00       	call   80032a <cprintf>
	if (pipeisclosed(p[0]))
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 75 e0             	pushl  -0x20(%ebp)
  800164:	e8 e1 1d 00 00       	call   801f4a <pipeisclosed>
  800169:	83 c4 10             	add    $0x10,%esp
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 14                	je     800184 <umain+0x151>
		panic("somehow the other end of p[0] got closed!");
  800170:	83 ec 04             	sub    $0x4,%esp
  800173:	68 a4 25 80 00       	push   $0x8025a4
  800178:	6a 40                	push   $0x40
  80017a:	68 d7 25 80 00       	push   $0x8025d7
  80017f:	e8 cd 00 00 00       	call   800251 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800184:	83 ec 08             	sub    $0x8,%esp
  800187:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	ff 75 e0             	pushl  -0x20(%ebp)
  80018e:	e8 e4 12 00 00       	call   801477 <fd_lookup>
  800193:	83 c4 10             	add    $0x10,%esp
  800196:	85 c0                	test   %eax,%eax
  800198:	79 12                	jns    8001ac <umain+0x179>
		panic("cannot look up p[0]: %e", r);
  80019a:	50                   	push   %eax
  80019b:	68 2b 26 80 00       	push   $0x80262b
  8001a0:	6a 42                	push   $0x42
  8001a2:	68 d7 25 80 00       	push   $0x8025d7
  8001a7:	e8 a5 00 00 00       	call   800251 <_panic>
	(void) fd2data(fd);
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b2:	e8 5a 12 00 00       	call   801411 <fd2data>
	cprintf("race didn't happen\n");
  8001b7:	c7 04 24 43 26 80 00 	movl   $0x802643,(%esp)
  8001be:	e8 67 01 00 00       	call   80032a <cprintf>
}
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c9:	5b                   	pop    %ebx
  8001ca:	5e                   	pop    %esi
  8001cb:	5f                   	pop    %edi
  8001cc:	5d                   	pop    %ebp
  8001cd:	c3                   	ret    

008001ce <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001d9:	e8 96 0a 00 00       	call   800c74 <sys_getenvid>
  8001de:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e3:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8001e9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ee:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f3:	85 db                	test   %ebx,%ebx
  8001f5:	7e 07                	jle    8001fe <libmain+0x30>
		binaryname = argv[0];
  8001f7:	8b 06                	mov    (%esi),%eax
  8001f9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	e8 2b fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800208:	e8 2a 00 00 00       	call   800237 <exit>
}
  80020d:	83 c4 10             	add    $0x10,%esp
  800210:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    

00800217 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  80021d:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800222:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800224:	e8 4b 0a 00 00       	call   800c74 <sys_getenvid>
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	e8 91 0c 00 00       	call   800ec3 <sys_thread_free>
}
  800232:	83 c4 10             	add    $0x10,%esp
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80023d:	e8 8d 13 00 00       	call   8015cf <close_all>
	sys_env_destroy(0);
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	6a 00                	push   $0x0
  800247:	e8 e7 09 00 00       	call   800c33 <sys_env_destroy>
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800256:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800259:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80025f:	e8 10 0a 00 00       	call   800c74 <sys_getenvid>
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	ff 75 0c             	pushl  0xc(%ebp)
  80026a:	ff 75 08             	pushl  0x8(%ebp)
  80026d:	56                   	push   %esi
  80026e:	50                   	push   %eax
  80026f:	68 64 26 80 00       	push   $0x802664
  800274:	e8 b1 00 00 00       	call   80032a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800279:	83 c4 18             	add    $0x18,%esp
  80027c:	53                   	push   %ebx
  80027d:	ff 75 10             	pushl  0x10(%ebp)
  800280:	e8 54 00 00 00       	call   8002d9 <vcprintf>
	cprintf("\n");
  800285:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  80028c:	e8 99 00 00 00       	call   80032a <cprintf>
  800291:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800294:	cc                   	int3   
  800295:	eb fd                	jmp    800294 <_panic+0x43>

00800297 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	53                   	push   %ebx
  80029b:	83 ec 04             	sub    $0x4,%esp
  80029e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a1:	8b 13                	mov    (%ebx),%edx
  8002a3:	8d 42 01             	lea    0x1(%edx),%eax
  8002a6:	89 03                	mov    %eax,(%ebx)
  8002a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b4:	75 1a                	jne    8002d0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	68 ff 00 00 00       	push   $0xff
  8002be:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c1:	50                   	push   %eax
  8002c2:	e8 2f 09 00 00       	call   800bf6 <sys_cputs>
		b->idx = 0;
  8002c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002cd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002d0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    

008002d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e9:	00 00 00 
	b.cnt = 0;
  8002ec:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f6:	ff 75 0c             	pushl  0xc(%ebp)
  8002f9:	ff 75 08             	pushl  0x8(%ebp)
  8002fc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800302:	50                   	push   %eax
  800303:	68 97 02 80 00       	push   $0x800297
  800308:	e8 54 01 00 00       	call   800461 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030d:	83 c4 08             	add    $0x8,%esp
  800310:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800316:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031c:	50                   	push   %eax
  80031d:	e8 d4 08 00 00       	call   800bf6 <sys_cputs>

	return b.cnt;
}
  800322:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800330:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800333:	50                   	push   %eax
  800334:	ff 75 08             	pushl  0x8(%ebp)
  800337:	e8 9d ff ff ff       	call   8002d9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	57                   	push   %edi
  800342:	56                   	push   %esi
  800343:	53                   	push   %ebx
  800344:	83 ec 1c             	sub    $0x1c,%esp
  800347:	89 c7                	mov    %eax,%edi
  800349:	89 d6                	mov    %edx,%esi
  80034b:	8b 45 08             	mov    0x8(%ebp),%eax
  80034e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800351:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800354:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800357:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80035a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80035f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800362:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800365:	39 d3                	cmp    %edx,%ebx
  800367:	72 05                	jb     80036e <printnum+0x30>
  800369:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036c:	77 45                	ja     8003b3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036e:	83 ec 0c             	sub    $0xc,%esp
  800371:	ff 75 18             	pushl  0x18(%ebp)
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80037a:	53                   	push   %ebx
  80037b:	ff 75 10             	pushl  0x10(%ebp)
  80037e:	83 ec 08             	sub    $0x8,%esp
  800381:	ff 75 e4             	pushl  -0x1c(%ebp)
  800384:	ff 75 e0             	pushl  -0x20(%ebp)
  800387:	ff 75 dc             	pushl  -0x24(%ebp)
  80038a:	ff 75 d8             	pushl  -0x28(%ebp)
  80038d:	e8 5e 1f 00 00       	call   8022f0 <__udivdi3>
  800392:	83 c4 18             	add    $0x18,%esp
  800395:	52                   	push   %edx
  800396:	50                   	push   %eax
  800397:	89 f2                	mov    %esi,%edx
  800399:	89 f8                	mov    %edi,%eax
  80039b:	e8 9e ff ff ff       	call   80033e <printnum>
  8003a0:	83 c4 20             	add    $0x20,%esp
  8003a3:	eb 18                	jmp    8003bd <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	56                   	push   %esi
  8003a9:	ff 75 18             	pushl  0x18(%ebp)
  8003ac:	ff d7                	call   *%edi
  8003ae:	83 c4 10             	add    $0x10,%esp
  8003b1:	eb 03                	jmp    8003b6 <printnum+0x78>
  8003b3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b6:	83 eb 01             	sub    $0x1,%ebx
  8003b9:	85 db                	test   %ebx,%ebx
  8003bb:	7f e8                	jg     8003a5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	56                   	push   %esi
  8003c1:	83 ec 04             	sub    $0x4,%esp
  8003c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8003cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d0:	e8 4b 20 00 00       	call   802420 <__umoddi3>
  8003d5:	83 c4 14             	add    $0x14,%esp
  8003d8:	0f be 80 87 26 80 00 	movsbl 0x802687(%eax),%eax
  8003df:	50                   	push   %eax
  8003e0:	ff d7                	call   *%edi
}
  8003e2:	83 c4 10             	add    $0x10,%esp
  8003e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e8:	5b                   	pop    %ebx
  8003e9:	5e                   	pop    %esi
  8003ea:	5f                   	pop    %edi
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    

008003ed <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f0:	83 fa 01             	cmp    $0x1,%edx
  8003f3:	7e 0e                	jle    800403 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003f5:	8b 10                	mov    (%eax),%edx
  8003f7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003fa:	89 08                	mov    %ecx,(%eax)
  8003fc:	8b 02                	mov    (%edx),%eax
  8003fe:	8b 52 04             	mov    0x4(%edx),%edx
  800401:	eb 22                	jmp    800425 <getuint+0x38>
	else if (lflag)
  800403:	85 d2                	test   %edx,%edx
  800405:	74 10                	je     800417 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800407:	8b 10                	mov    (%eax),%edx
  800409:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040c:	89 08                	mov    %ecx,(%eax)
  80040e:	8b 02                	mov    (%edx),%eax
  800410:	ba 00 00 00 00       	mov    $0x0,%edx
  800415:	eb 0e                	jmp    800425 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800417:	8b 10                	mov    (%eax),%edx
  800419:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041c:	89 08                	mov    %ecx,(%eax)
  80041e:	8b 02                	mov    (%edx),%eax
  800420:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80042d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800431:	8b 10                	mov    (%eax),%edx
  800433:	3b 50 04             	cmp    0x4(%eax),%edx
  800436:	73 0a                	jae    800442 <sprintputch+0x1b>
		*b->buf++ = ch;
  800438:	8d 4a 01             	lea    0x1(%edx),%ecx
  80043b:	89 08                	mov    %ecx,(%eax)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	88 02                	mov    %al,(%edx)
}
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80044a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80044d:	50                   	push   %eax
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	ff 75 0c             	pushl  0xc(%ebp)
  800454:	ff 75 08             	pushl  0x8(%ebp)
  800457:	e8 05 00 00 00       	call   800461 <vprintfmt>
	va_end(ap);
}
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	c9                   	leave  
  800460:	c3                   	ret    

00800461 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
  800464:	57                   	push   %edi
  800465:	56                   	push   %esi
  800466:	53                   	push   %ebx
  800467:	83 ec 2c             	sub    $0x2c,%esp
  80046a:	8b 75 08             	mov    0x8(%ebp),%esi
  80046d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800470:	8b 7d 10             	mov    0x10(%ebp),%edi
  800473:	eb 12                	jmp    800487 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800475:	85 c0                	test   %eax,%eax
  800477:	0f 84 89 03 00 00    	je     800806 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	50                   	push   %eax
  800482:	ff d6                	call   *%esi
  800484:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800487:	83 c7 01             	add    $0x1,%edi
  80048a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048e:	83 f8 25             	cmp    $0x25,%eax
  800491:	75 e2                	jne    800475 <vprintfmt+0x14>
  800493:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800497:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80049e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004a5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b1:	eb 07                	jmp    8004ba <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8d 47 01             	lea    0x1(%edi),%eax
  8004bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c0:	0f b6 07             	movzbl (%edi),%eax
  8004c3:	0f b6 c8             	movzbl %al,%ecx
  8004c6:	83 e8 23             	sub    $0x23,%eax
  8004c9:	3c 55                	cmp    $0x55,%al
  8004cb:	0f 87 1a 03 00 00    	ja     8007eb <vprintfmt+0x38a>
  8004d1:	0f b6 c0             	movzbl %al,%eax
  8004d4:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004de:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004e2:	eb d6                	jmp    8004ba <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ef:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004f2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004f6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004f9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004fc:	83 fa 09             	cmp    $0x9,%edx
  8004ff:	77 39                	ja     80053a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800501:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800504:	eb e9                	jmp    8004ef <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 48 04             	lea    0x4(%eax),%ecx
  80050c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800517:	eb 27                	jmp    800540 <vprintfmt+0xdf>
  800519:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051c:	85 c0                	test   %eax,%eax
  80051e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800523:	0f 49 c8             	cmovns %eax,%ecx
  800526:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800529:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052c:	eb 8c                	jmp    8004ba <vprintfmt+0x59>
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800531:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800538:	eb 80                	jmp    8004ba <vprintfmt+0x59>
  80053a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80053d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800540:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800544:	0f 89 70 ff ff ff    	jns    8004ba <vprintfmt+0x59>
				width = precision, precision = -1;
  80054a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80054d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800550:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800557:	e9 5e ff ff ff       	jmp    8004ba <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80055c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800562:	e9 53 ff ff ff       	jmp    8004ba <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	53                   	push   %ebx
  800574:	ff 30                	pushl  (%eax)
  800576:	ff d6                	call   *%esi
			break;
  800578:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80057e:	e9 04 ff ff ff       	jmp    800487 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	99                   	cltd   
  80058f:	31 d0                	xor    %edx,%eax
  800591:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800593:	83 f8 0f             	cmp    $0xf,%eax
  800596:	7f 0b                	jg     8005a3 <vprintfmt+0x142>
  800598:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	75 18                	jne    8005bb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005a3:	50                   	push   %eax
  8005a4:	68 9f 26 80 00       	push   $0x80269f
  8005a9:	53                   	push   %ebx
  8005aa:	56                   	push   %esi
  8005ab:	e8 94 fe ff ff       	call   800444 <printfmt>
  8005b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b6:	e9 cc fe ff ff       	jmp    800487 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005bb:	52                   	push   %edx
  8005bc:	68 e1 2a 80 00       	push   $0x802ae1
  8005c1:	53                   	push   %ebx
  8005c2:	56                   	push   %esi
  8005c3:	e8 7c fe ff ff       	call   800444 <printfmt>
  8005c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ce:	e9 b4 fe ff ff       	jmp    800487 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 04             	lea    0x4(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005de:	85 ff                	test   %edi,%edi
  8005e0:	b8 98 26 80 00       	mov    $0x802698,%eax
  8005e5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ec:	0f 8e 94 00 00 00    	jle    800686 <vprintfmt+0x225>
  8005f2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005f6:	0f 84 98 00 00 00    	je     800694 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	ff 75 d0             	pushl  -0x30(%ebp)
  800602:	57                   	push   %edi
  800603:	e8 86 02 00 00       	call   80088e <strnlen>
  800608:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80060b:	29 c1                	sub    %eax,%ecx
  80060d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800610:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800613:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800617:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80061a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80061d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	eb 0f                	jmp    800630 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	ff 75 e0             	pushl  -0x20(%ebp)
  800628:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80062a:	83 ef 01             	sub    $0x1,%edi
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	85 ff                	test   %edi,%edi
  800632:	7f ed                	jg     800621 <vprintfmt+0x1c0>
  800634:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800637:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80063a:	85 c9                	test   %ecx,%ecx
  80063c:	b8 00 00 00 00       	mov    $0x0,%eax
  800641:	0f 49 c1             	cmovns %ecx,%eax
  800644:	29 c1                	sub    %eax,%ecx
  800646:	89 75 08             	mov    %esi,0x8(%ebp)
  800649:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80064c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80064f:	89 cb                	mov    %ecx,%ebx
  800651:	eb 4d                	jmp    8006a0 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800653:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800657:	74 1b                	je     800674 <vprintfmt+0x213>
  800659:	0f be c0             	movsbl %al,%eax
  80065c:	83 e8 20             	sub    $0x20,%eax
  80065f:	83 f8 5e             	cmp    $0x5e,%eax
  800662:	76 10                	jbe    800674 <vprintfmt+0x213>
					putch('?', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	ff 75 0c             	pushl  0xc(%ebp)
  80066a:	6a 3f                	push   $0x3f
  80066c:	ff 55 08             	call   *0x8(%ebp)
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	eb 0d                	jmp    800681 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	ff 75 0c             	pushl  0xc(%ebp)
  80067a:	52                   	push   %edx
  80067b:	ff 55 08             	call   *0x8(%ebp)
  80067e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800681:	83 eb 01             	sub    $0x1,%ebx
  800684:	eb 1a                	jmp    8006a0 <vprintfmt+0x23f>
  800686:	89 75 08             	mov    %esi,0x8(%ebp)
  800689:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80068f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800692:	eb 0c                	jmp    8006a0 <vprintfmt+0x23f>
  800694:	89 75 08             	mov    %esi,0x8(%ebp)
  800697:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80069a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80069d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006a0:	83 c7 01             	add    $0x1,%edi
  8006a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a7:	0f be d0             	movsbl %al,%edx
  8006aa:	85 d2                	test   %edx,%edx
  8006ac:	74 23                	je     8006d1 <vprintfmt+0x270>
  8006ae:	85 f6                	test   %esi,%esi
  8006b0:	78 a1                	js     800653 <vprintfmt+0x1f2>
  8006b2:	83 ee 01             	sub    $0x1,%esi
  8006b5:	79 9c                	jns    800653 <vprintfmt+0x1f2>
  8006b7:	89 df                	mov    %ebx,%edi
  8006b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006bf:	eb 18                	jmp    8006d9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 20                	push   $0x20
  8006c7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c9:	83 ef 01             	sub    $0x1,%edi
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	eb 08                	jmp    8006d9 <vprintfmt+0x278>
  8006d1:	89 df                	mov    %ebx,%edi
  8006d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d9:	85 ff                	test   %edi,%edi
  8006db:	7f e4                	jg     8006c1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e0:	e9 a2 fd ff ff       	jmp    800487 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e5:	83 fa 01             	cmp    $0x1,%edx
  8006e8:	7e 16                	jle    800700 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 08             	lea    0x8(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f3:	8b 50 04             	mov    0x4(%eax),%edx
  8006f6:	8b 00                	mov    (%eax),%eax
  8006f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006fe:	eb 32                	jmp    800732 <vprintfmt+0x2d1>
	else if (lflag)
  800700:	85 d2                	test   %edx,%edx
  800702:	74 18                	je     80071c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8d 50 04             	lea    0x4(%eax),%edx
  80070a:	89 55 14             	mov    %edx,0x14(%ebp)
  80070d:	8b 00                	mov    (%eax),%eax
  80070f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800712:	89 c1                	mov    %eax,%ecx
  800714:	c1 f9 1f             	sar    $0x1f,%ecx
  800717:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80071a:	eb 16                	jmp    800732 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 50 04             	lea    0x4(%eax),%edx
  800722:	89 55 14             	mov    %edx,0x14(%ebp)
  800725:	8b 00                	mov    (%eax),%eax
  800727:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072a:	89 c1                	mov    %eax,%ecx
  80072c:	c1 f9 1f             	sar    $0x1f,%ecx
  80072f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800732:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800735:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800738:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80073d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800741:	79 74                	jns    8007b7 <vprintfmt+0x356>
				putch('-', putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	53                   	push   %ebx
  800747:	6a 2d                	push   $0x2d
  800749:	ff d6                	call   *%esi
				num = -(long long) num;
  80074b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80074e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800751:	f7 d8                	neg    %eax
  800753:	83 d2 00             	adc    $0x0,%edx
  800756:	f7 da                	neg    %edx
  800758:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80075b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800760:	eb 55                	jmp    8007b7 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 83 fc ff ff       	call   8003ed <getuint>
			base = 10;
  80076a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80076f:	eb 46                	jmp    8007b7 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 74 fc ff ff       	call   8003ed <getuint>
			base = 8;
  800779:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80077e:	eb 37                	jmp    8007b7 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	53                   	push   %ebx
  800784:	6a 30                	push   $0x30
  800786:	ff d6                	call   *%esi
			putch('x', putdat);
  800788:	83 c4 08             	add    $0x8,%esp
  80078b:	53                   	push   %ebx
  80078c:	6a 78                	push   $0x78
  80078e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 50 04             	lea    0x4(%eax),%edx
  800796:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800799:	8b 00                	mov    (%eax),%eax
  80079b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007a8:	eb 0d                	jmp    8007b7 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ad:	e8 3b fc ff ff       	call   8003ed <getuint>
			base = 16;
  8007b2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b7:	83 ec 0c             	sub    $0xc,%esp
  8007ba:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007be:	57                   	push   %edi
  8007bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c2:	51                   	push   %ecx
  8007c3:	52                   	push   %edx
  8007c4:	50                   	push   %eax
  8007c5:	89 da                	mov    %ebx,%edx
  8007c7:	89 f0                	mov    %esi,%eax
  8007c9:	e8 70 fb ff ff       	call   80033e <printnum>
			break;
  8007ce:	83 c4 20             	add    $0x20,%esp
  8007d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d4:	e9 ae fc ff ff       	jmp    800487 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	53                   	push   %ebx
  8007dd:	51                   	push   %ecx
  8007de:	ff d6                	call   *%esi
			break;
  8007e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007e6:	e9 9c fc ff ff       	jmp    800487 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	53                   	push   %ebx
  8007ef:	6a 25                	push   $0x25
  8007f1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f3:	83 c4 10             	add    $0x10,%esp
  8007f6:	eb 03                	jmp    8007fb <vprintfmt+0x39a>
  8007f8:	83 ef 01             	sub    $0x1,%edi
  8007fb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007ff:	75 f7                	jne    8007f8 <vprintfmt+0x397>
  800801:	e9 81 fc ff ff       	jmp    800487 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800806:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5f                   	pop    %edi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	83 ec 18             	sub    $0x18,%esp
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800821:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800824:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082b:	85 c0                	test   %eax,%eax
  80082d:	74 26                	je     800855 <vsnprintf+0x47>
  80082f:	85 d2                	test   %edx,%edx
  800831:	7e 22                	jle    800855 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800833:	ff 75 14             	pushl  0x14(%ebp)
  800836:	ff 75 10             	pushl  0x10(%ebp)
  800839:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80083c:	50                   	push   %eax
  80083d:	68 27 04 80 00       	push   $0x800427
  800842:	e8 1a fc ff ff       	call   800461 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800847:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800850:	83 c4 10             	add    $0x10,%esp
  800853:	eb 05                	jmp    80085a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800855:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    

0080085c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800862:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800865:	50                   	push   %eax
  800866:	ff 75 10             	pushl  0x10(%ebp)
  800869:	ff 75 0c             	pushl  0xc(%ebp)
  80086c:	ff 75 08             	pushl  0x8(%ebp)
  80086f:	e8 9a ff ff ff       	call   80080e <vsnprintf>
	va_end(ap);

	return rc;
}
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
  800881:	eb 03                	jmp    800886 <strlen+0x10>
		n++;
  800883:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80088a:	75 f7                	jne    800883 <strlen+0xd>
		n++;
	return n;
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800894:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800897:	ba 00 00 00 00       	mov    $0x0,%edx
  80089c:	eb 03                	jmp    8008a1 <strnlen+0x13>
		n++;
  80089e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a1:	39 c2                	cmp    %eax,%edx
  8008a3:	74 08                	je     8008ad <strnlen+0x1f>
  8008a5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008a9:	75 f3                	jne    80089e <strnlen+0x10>
  8008ab:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	53                   	push   %ebx
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	83 c2 01             	add    $0x1,%edx
  8008be:	83 c1 01             	add    $0x1,%ecx
  8008c1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c8:	84 db                	test   %bl,%bl
  8008ca:	75 ef                	jne    8008bb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008cc:	5b                   	pop    %ebx
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d6:	53                   	push   %ebx
  8008d7:	e8 9a ff ff ff       	call   800876 <strlen>
  8008dc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	01 d8                	add    %ebx,%eax
  8008e4:	50                   	push   %eax
  8008e5:	e8 c5 ff ff ff       	call   8008af <strcpy>
	return dst;
}
  8008ea:	89 d8                	mov    %ebx,%eax
  8008ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fc:	89 f3                	mov    %esi,%ebx
  8008fe:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800901:	89 f2                	mov    %esi,%edx
  800903:	eb 0f                	jmp    800914 <strncpy+0x23>
		*dst++ = *src;
  800905:	83 c2 01             	add    $0x1,%edx
  800908:	0f b6 01             	movzbl (%ecx),%eax
  80090b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090e:	80 39 01             	cmpb   $0x1,(%ecx)
  800911:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800914:	39 da                	cmp    %ebx,%edx
  800916:	75 ed                	jne    800905 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800918:	89 f0                	mov    %esi,%eax
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 75 08             	mov    0x8(%ebp),%esi
  800926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800929:	8b 55 10             	mov    0x10(%ebp),%edx
  80092c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092e:	85 d2                	test   %edx,%edx
  800930:	74 21                	je     800953 <strlcpy+0x35>
  800932:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800936:	89 f2                	mov    %esi,%edx
  800938:	eb 09                	jmp    800943 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093a:	83 c2 01             	add    $0x1,%edx
  80093d:	83 c1 01             	add    $0x1,%ecx
  800940:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800943:	39 c2                	cmp    %eax,%edx
  800945:	74 09                	je     800950 <strlcpy+0x32>
  800947:	0f b6 19             	movzbl (%ecx),%ebx
  80094a:	84 db                	test   %bl,%bl
  80094c:	75 ec                	jne    80093a <strlcpy+0x1c>
  80094e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800950:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800953:	29 f0                	sub    %esi,%eax
}
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800962:	eb 06                	jmp    80096a <strcmp+0x11>
		p++, q++;
  800964:	83 c1 01             	add    $0x1,%ecx
  800967:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096a:	0f b6 01             	movzbl (%ecx),%eax
  80096d:	84 c0                	test   %al,%al
  80096f:	74 04                	je     800975 <strcmp+0x1c>
  800971:	3a 02                	cmp    (%edx),%al
  800973:	74 ef                	je     800964 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800975:	0f b6 c0             	movzbl %al,%eax
  800978:	0f b6 12             	movzbl (%edx),%edx
  80097b:	29 d0                	sub    %edx,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
  800989:	89 c3                	mov    %eax,%ebx
  80098b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098e:	eb 06                	jmp    800996 <strncmp+0x17>
		n--, p++, q++;
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800996:	39 d8                	cmp    %ebx,%eax
  800998:	74 15                	je     8009af <strncmp+0x30>
  80099a:	0f b6 08             	movzbl (%eax),%ecx
  80099d:	84 c9                	test   %cl,%cl
  80099f:	74 04                	je     8009a5 <strncmp+0x26>
  8009a1:	3a 0a                	cmp    (%edx),%cl
  8009a3:	74 eb                	je     800990 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a5:	0f b6 00             	movzbl (%eax),%eax
  8009a8:	0f b6 12             	movzbl (%edx),%edx
  8009ab:	29 d0                	sub    %edx,%eax
  8009ad:	eb 05                	jmp    8009b4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c1:	eb 07                	jmp    8009ca <strchr+0x13>
		if (*s == c)
  8009c3:	38 ca                	cmp    %cl,%dl
  8009c5:	74 0f                	je     8009d6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c7:	83 c0 01             	add    $0x1,%eax
  8009ca:	0f b6 10             	movzbl (%eax),%edx
  8009cd:	84 d2                	test   %dl,%dl
  8009cf:	75 f2                	jne    8009c3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e2:	eb 03                	jmp    8009e7 <strfind+0xf>
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ea:	38 ca                	cmp    %cl,%dl
  8009ec:	74 04                	je     8009f2 <strfind+0x1a>
  8009ee:	84 d2                	test   %dl,%dl
  8009f0:	75 f2                	jne    8009e4 <strfind+0xc>
			break;
	return (char *) s;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	74 36                	je     800a3a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0a:	75 28                	jne    800a34 <memset+0x40>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 23                	jne    800a34 <memset+0x40>
		c &= 0xFF;
  800a11:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a15:	89 d3                	mov    %edx,%ebx
  800a17:	c1 e3 08             	shl    $0x8,%ebx
  800a1a:	89 d6                	mov    %edx,%esi
  800a1c:	c1 e6 18             	shl    $0x18,%esi
  800a1f:	89 d0                	mov    %edx,%eax
  800a21:	c1 e0 10             	shl    $0x10,%eax
  800a24:	09 f0                	or     %esi,%eax
  800a26:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a28:	89 d8                	mov    %ebx,%eax
  800a2a:	09 d0                	or     %edx,%eax
  800a2c:	c1 e9 02             	shr    $0x2,%ecx
  800a2f:	fc                   	cld    
  800a30:	f3 ab                	rep stos %eax,%es:(%edi)
  800a32:	eb 06                	jmp    800a3a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a37:	fc                   	cld    
  800a38:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3a:	89 f8                	mov    %edi,%eax
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4f:	39 c6                	cmp    %eax,%esi
  800a51:	73 35                	jae    800a88 <memmove+0x47>
  800a53:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a56:	39 d0                	cmp    %edx,%eax
  800a58:	73 2e                	jae    800a88 <memmove+0x47>
		s += n;
		d += n;
  800a5a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	09 fe                	or     %edi,%esi
  800a61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a67:	75 13                	jne    800a7c <memmove+0x3b>
  800a69:	f6 c1 03             	test   $0x3,%cl
  800a6c:	75 0e                	jne    800a7c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a6e:	83 ef 04             	sub    $0x4,%edi
  800a71:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a74:	c1 e9 02             	shr    $0x2,%ecx
  800a77:	fd                   	std    
  800a78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7a:	eb 09                	jmp    800a85 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a7c:	83 ef 01             	sub    $0x1,%edi
  800a7f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a82:	fd                   	std    
  800a83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a85:	fc                   	cld    
  800a86:	eb 1d                	jmp    800aa5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	89 f2                	mov    %esi,%edx
  800a8a:	09 c2                	or     %eax,%edx
  800a8c:	f6 c2 03             	test   $0x3,%dl
  800a8f:	75 0f                	jne    800aa0 <memmove+0x5f>
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 0a                	jne    800aa0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a96:	c1 e9 02             	shr    $0x2,%ecx
  800a99:	89 c7                	mov    %eax,%edi
  800a9b:	fc                   	cld    
  800a9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9e:	eb 05                	jmp    800aa5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa0:	89 c7                	mov    %eax,%edi
  800aa2:	fc                   	cld    
  800aa3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aac:	ff 75 10             	pushl  0x10(%ebp)
  800aaf:	ff 75 0c             	pushl  0xc(%ebp)
  800ab2:	ff 75 08             	pushl  0x8(%ebp)
  800ab5:	e8 87 ff ff ff       	call   800a41 <memmove>
}
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac7:	89 c6                	mov    %eax,%esi
  800ac9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acc:	eb 1a                	jmp    800ae8 <memcmp+0x2c>
		if (*s1 != *s2)
  800ace:	0f b6 08             	movzbl (%eax),%ecx
  800ad1:	0f b6 1a             	movzbl (%edx),%ebx
  800ad4:	38 d9                	cmp    %bl,%cl
  800ad6:	74 0a                	je     800ae2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ad8:	0f b6 c1             	movzbl %cl,%eax
  800adb:	0f b6 db             	movzbl %bl,%ebx
  800ade:	29 d8                	sub    %ebx,%eax
  800ae0:	eb 0f                	jmp    800af1 <memcmp+0x35>
		s1++, s2++;
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae8:	39 f0                	cmp    %esi,%eax
  800aea:	75 e2                	jne    800ace <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	53                   	push   %ebx
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800afc:	89 c1                	mov    %eax,%ecx
  800afe:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b01:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b05:	eb 0a                	jmp    800b11 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b07:	0f b6 10             	movzbl (%eax),%edx
  800b0a:	39 da                	cmp    %ebx,%edx
  800b0c:	74 07                	je     800b15 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0e:	83 c0 01             	add    $0x1,%eax
  800b11:	39 c8                	cmp    %ecx,%eax
  800b13:	72 f2                	jb     800b07 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b15:	5b                   	pop    %ebx
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b24:	eb 03                	jmp    800b29 <strtol+0x11>
		s++;
  800b26:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b29:	0f b6 01             	movzbl (%ecx),%eax
  800b2c:	3c 20                	cmp    $0x20,%al
  800b2e:	74 f6                	je     800b26 <strtol+0xe>
  800b30:	3c 09                	cmp    $0x9,%al
  800b32:	74 f2                	je     800b26 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b34:	3c 2b                	cmp    $0x2b,%al
  800b36:	75 0a                	jne    800b42 <strtol+0x2a>
		s++;
  800b38:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b40:	eb 11                	jmp    800b53 <strtol+0x3b>
  800b42:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b47:	3c 2d                	cmp    $0x2d,%al
  800b49:	75 08                	jne    800b53 <strtol+0x3b>
		s++, neg = 1;
  800b4b:	83 c1 01             	add    $0x1,%ecx
  800b4e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b53:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b59:	75 15                	jne    800b70 <strtol+0x58>
  800b5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5e:	75 10                	jne    800b70 <strtol+0x58>
  800b60:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b64:	75 7c                	jne    800be2 <strtol+0xca>
		s += 2, base = 16;
  800b66:	83 c1 02             	add    $0x2,%ecx
  800b69:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6e:	eb 16                	jmp    800b86 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b70:	85 db                	test   %ebx,%ebx
  800b72:	75 12                	jne    800b86 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b74:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b79:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7c:	75 08                	jne    800b86 <strtol+0x6e>
		s++, base = 8;
  800b7e:	83 c1 01             	add    $0x1,%ecx
  800b81:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b8e:	0f b6 11             	movzbl (%ecx),%edx
  800b91:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b94:	89 f3                	mov    %esi,%ebx
  800b96:	80 fb 09             	cmp    $0x9,%bl
  800b99:	77 08                	ja     800ba3 <strtol+0x8b>
			dig = *s - '0';
  800b9b:	0f be d2             	movsbl %dl,%edx
  800b9e:	83 ea 30             	sub    $0x30,%edx
  800ba1:	eb 22                	jmp    800bc5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ba3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ba6:	89 f3                	mov    %esi,%ebx
  800ba8:	80 fb 19             	cmp    $0x19,%bl
  800bab:	77 08                	ja     800bb5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bad:	0f be d2             	movsbl %dl,%edx
  800bb0:	83 ea 57             	sub    $0x57,%edx
  800bb3:	eb 10                	jmp    800bc5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bb5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bb8:	89 f3                	mov    %esi,%ebx
  800bba:	80 fb 19             	cmp    $0x19,%bl
  800bbd:	77 16                	ja     800bd5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bbf:	0f be d2             	movsbl %dl,%edx
  800bc2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bc5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bc8:	7d 0b                	jge    800bd5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bca:	83 c1 01             	add    $0x1,%ecx
  800bcd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bd3:	eb b9                	jmp    800b8e <strtol+0x76>

	if (endptr)
  800bd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd9:	74 0d                	je     800be8 <strtol+0xd0>
		*endptr = (char *) s;
  800bdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bde:	89 0e                	mov    %ecx,(%esi)
  800be0:	eb 06                	jmp    800be8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be2:	85 db                	test   %ebx,%ebx
  800be4:	74 98                	je     800b7e <strtol+0x66>
  800be6:	eb 9e                	jmp    800b86 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800be8:	89 c2                	mov    %eax,%edx
  800bea:	f7 da                	neg    %edx
  800bec:	85 ff                	test   %edi,%edi
  800bee:	0f 45 c2             	cmovne %edx,%eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	89 c3                	mov    %eax,%ebx
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	89 c6                	mov    %eax,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c24:	89 d1                	mov    %edx,%ecx
  800c26:	89 d3                	mov    %edx,%ebx
  800c28:	89 d7                	mov    %edx,%edi
  800c2a:	89 d6                	mov    %edx,%esi
  800c2c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c41:	b8 03 00 00 00       	mov    $0x3,%eax
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 cb                	mov    %ecx,%ebx
  800c4b:	89 cf                	mov    %ecx,%edi
  800c4d:	89 ce                	mov    %ecx,%esi
  800c4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 17                	jle    800c6c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 03                	push   $0x3
  800c5b:	68 7f 29 80 00       	push   $0x80297f
  800c60:	6a 23                	push   $0x23
  800c62:	68 9c 29 80 00       	push   $0x80299c
  800c67:	e8 e5 f5 ff ff       	call   800251 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_yield>:

void
sys_yield(void)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c99:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca3:	89 d1                	mov    %edx,%ecx
  800ca5:	89 d3                	mov    %edx,%ebx
  800ca7:	89 d7                	mov    %edx,%edi
  800ca9:	89 d6                	mov    %edx,%esi
  800cab:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	be 00 00 00 00       	mov    $0x0,%esi
  800cc0:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cce:	89 f7                	mov    %esi,%edi
  800cd0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	7e 17                	jle    800ced <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd6:	83 ec 0c             	sub    $0xc,%esp
  800cd9:	50                   	push   %eax
  800cda:	6a 04                	push   $0x4
  800cdc:	68 7f 29 80 00       	push   $0x80297f
  800ce1:	6a 23                	push   $0x23
  800ce3:	68 9c 29 80 00       	push   $0x80299c
  800ce8:	e8 64 f5 ff ff       	call   800251 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7e 17                	jle    800d2f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	50                   	push   %eax
  800d1c:	6a 05                	push   $0x5
  800d1e:	68 7f 29 80 00       	push   $0x80297f
  800d23:	6a 23                	push   $0x23
  800d25:	68 9c 29 80 00       	push   $0x80299c
  800d2a:	e8 22 f5 ff ff       	call   800251 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d45:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	89 df                	mov    %ebx,%edi
  800d52:	89 de                	mov    %ebx,%esi
  800d54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7e 17                	jle    800d71 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	83 ec 0c             	sub    $0xc,%esp
  800d5d:	50                   	push   %eax
  800d5e:	6a 06                	push   $0x6
  800d60:	68 7f 29 80 00       	push   $0x80297f
  800d65:	6a 23                	push   $0x23
  800d67:	68 9c 29 80 00       	push   $0x80299c
  800d6c:	e8 e0 f4 ff ff       	call   800251 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d87:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 df                	mov    %ebx,%edi
  800d94:	89 de                	mov    %ebx,%esi
  800d96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 17                	jle    800db3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 08                	push   $0x8
  800da2:	68 7f 29 80 00       	push   $0x80297f
  800da7:	6a 23                	push   $0x23
  800da9:	68 9c 29 80 00       	push   $0x80299c
  800dae:	e8 9e f4 ff ff       	call   800251 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc9:	b8 09 00 00 00       	mov    $0x9,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	89 df                	mov    %ebx,%edi
  800dd6:	89 de                	mov    %ebx,%esi
  800dd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7e 17                	jle    800df5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	50                   	push   %eax
  800de2:	6a 09                	push   $0x9
  800de4:	68 7f 29 80 00       	push   $0x80297f
  800de9:	6a 23                	push   $0x23
  800deb:	68 9c 29 80 00       	push   $0x80299c
  800df0:	e8 5c f4 ff ff       	call   800251 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7e 17                	jle    800e37 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	50                   	push   %eax
  800e24:	6a 0a                	push   $0xa
  800e26:	68 7f 29 80 00       	push   $0x80297f
  800e2b:	6a 23                	push   $0x23
  800e2d:	68 9c 29 80 00       	push   $0x80299c
  800e32:	e8 1a f4 ff ff       	call   800251 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e45:	be 00 00 00 00       	mov    $0x0,%esi
  800e4a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e52:	8b 55 08             	mov    0x8(%ebp),%edx
  800e55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	57                   	push   %edi
  800e66:	56                   	push   %esi
  800e67:	53                   	push   %ebx
  800e68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e70:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	89 cb                	mov    %ecx,%ebx
  800e7a:	89 cf                	mov    %ecx,%edi
  800e7c:	89 ce                	mov    %ecx,%esi
  800e7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 17                	jle    800e9b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 0d                	push   $0xd
  800e8a:	68 7f 29 80 00       	push   $0x80297f
  800e8f:	6a 23                	push   $0x23
  800e91:	68 9c 29 80 00       	push   $0x80299c
  800e96:	e8 b6 f3 ff ff       	call   800251 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eae:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb6:	89 cb                	mov    %ecx,%ebx
  800eb8:	89 cf                	mov    %ecx,%edi
  800eba:	89 ce                	mov    %ecx,%esi
  800ebc:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ece:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ed3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed6:	89 cb                	mov    %ecx,%ebx
  800ed8:	89 cf                	mov    %ecx,%edi
  800eda:	89 ce                	mov    %ecx,%esi
  800edc:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eee:	b8 10 00 00 00       	mov    $0x10,%eax
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	89 cb                	mov    %ecx,%ebx
  800ef8:	89 cf                	mov    %ecx,%edi
  800efa:	89 ce                	mov    %ecx,%esi
  800efc:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	53                   	push   %ebx
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f0d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800f0f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f13:	74 11                	je     800f26 <pgfault+0x23>
  800f15:	89 d8                	mov    %ebx,%eax
  800f17:	c1 e8 0c             	shr    $0xc,%eax
  800f1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f21:	f6 c4 08             	test   $0x8,%ah
  800f24:	75 14                	jne    800f3a <pgfault+0x37>
		panic("faulting access");
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	68 aa 29 80 00       	push   $0x8029aa
  800f2e:	6a 1f                	push   $0x1f
  800f30:	68 ba 29 80 00       	push   $0x8029ba
  800f35:	e8 17 f3 ff ff       	call   800251 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f3a:	83 ec 04             	sub    $0x4,%esp
  800f3d:	6a 07                	push   $0x7
  800f3f:	68 00 f0 7f 00       	push   $0x7ff000
  800f44:	6a 00                	push   $0x0
  800f46:	e8 67 fd ff ff       	call   800cb2 <sys_page_alloc>
	if (r < 0) {
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	79 12                	jns    800f64 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f52:	50                   	push   %eax
  800f53:	68 c5 29 80 00       	push   $0x8029c5
  800f58:	6a 2d                	push   $0x2d
  800f5a:	68 ba 29 80 00       	push   $0x8029ba
  800f5f:	e8 ed f2 ff ff       	call   800251 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f64:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f6a:	83 ec 04             	sub    $0x4,%esp
  800f6d:	68 00 10 00 00       	push   $0x1000
  800f72:	53                   	push   %ebx
  800f73:	68 00 f0 7f 00       	push   $0x7ff000
  800f78:	e8 2c fb ff ff       	call   800aa9 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f7d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f84:	53                   	push   %ebx
  800f85:	6a 00                	push   $0x0
  800f87:	68 00 f0 7f 00       	push   $0x7ff000
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 62 fd ff ff       	call   800cf5 <sys_page_map>
	if (r < 0) {
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 12                	jns    800fac <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f9a:	50                   	push   %eax
  800f9b:	68 c5 29 80 00       	push   $0x8029c5
  800fa0:	6a 34                	push   $0x34
  800fa2:	68 ba 29 80 00       	push   $0x8029ba
  800fa7:	e8 a5 f2 ff ff       	call   800251 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800fac:	83 ec 08             	sub    $0x8,%esp
  800faf:	68 00 f0 7f 00       	push   $0x7ff000
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 7c fd ff ff       	call   800d37 <sys_page_unmap>
	if (r < 0) {
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	79 12                	jns    800fd4 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800fc2:	50                   	push   %eax
  800fc3:	68 c5 29 80 00       	push   $0x8029c5
  800fc8:	6a 38                	push   $0x38
  800fca:	68 ba 29 80 00       	push   $0x8029ba
  800fcf:	e8 7d f2 ff ff       	call   800251 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd7:	c9                   	leave  
  800fd8:	c3                   	ret    

00800fd9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fe2:	68 03 0f 80 00       	push   $0x800f03
  800fe7:	e8 14 11 00 00       	call   802100 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fec:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff1:	cd 30                	int    $0x30
  800ff3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	79 17                	jns    801014 <fork+0x3b>
		panic("fork fault %e");
  800ffd:	83 ec 04             	sub    $0x4,%esp
  801000:	68 de 29 80 00       	push   $0x8029de
  801005:	68 85 00 00 00       	push   $0x85
  80100a:	68 ba 29 80 00       	push   $0x8029ba
  80100f:	e8 3d f2 ff ff       	call   800251 <_panic>
  801014:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801016:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80101a:	75 24                	jne    801040 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80101c:	e8 53 fc ff ff       	call   800c74 <sys_getenvid>
  801021:	25 ff 03 00 00       	and    $0x3ff,%eax
  801026:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80102c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801031:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801036:	b8 00 00 00 00       	mov    $0x0,%eax
  80103b:	e9 64 01 00 00       	jmp    8011a4 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	6a 07                	push   $0x7
  801045:	68 00 f0 bf ee       	push   $0xeebff000
  80104a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104d:	e8 60 fc ff ff       	call   800cb2 <sys_page_alloc>
  801052:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801055:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80105a:	89 d8                	mov    %ebx,%eax
  80105c:	c1 e8 16             	shr    $0x16,%eax
  80105f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801066:	a8 01                	test   $0x1,%al
  801068:	0f 84 fc 00 00 00    	je     80116a <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80106e:	89 d8                	mov    %ebx,%eax
  801070:	c1 e8 0c             	shr    $0xc,%eax
  801073:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80107a:	f6 c2 01             	test   $0x1,%dl
  80107d:	0f 84 e7 00 00 00    	je     80116a <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  801083:	89 c6                	mov    %eax,%esi
  801085:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801088:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108f:	f6 c6 04             	test   $0x4,%dh
  801092:	74 39                	je     8010cd <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a3:	50                   	push   %eax
  8010a4:	56                   	push   %esi
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 47 fc ff ff       	call   800cf5 <sys_page_map>
		if (r < 0) {
  8010ae:	83 c4 20             	add    $0x20,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	0f 89 b1 00 00 00    	jns    80116a <fork+0x191>
		    	panic("sys page map fault %e");
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	68 ec 29 80 00       	push   $0x8029ec
  8010c1:	6a 55                	push   $0x55
  8010c3:	68 ba 29 80 00       	push   $0x8029ba
  8010c8:	e8 84 f1 ff ff       	call   800251 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d4:	f6 c2 02             	test   $0x2,%dl
  8010d7:	75 0c                	jne    8010e5 <fork+0x10c>
  8010d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e0:	f6 c4 08             	test   $0x8,%ah
  8010e3:	74 5b                	je     801140 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	68 05 08 00 00       	push   $0x805
  8010ed:	56                   	push   %esi
  8010ee:	57                   	push   %edi
  8010ef:	56                   	push   %esi
  8010f0:	6a 00                	push   $0x0
  8010f2:	e8 fe fb ff ff       	call   800cf5 <sys_page_map>
		if (r < 0) {
  8010f7:	83 c4 20             	add    $0x20,%esp
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 14                	jns    801112 <fork+0x139>
		    	panic("sys page map fault %e");
  8010fe:	83 ec 04             	sub    $0x4,%esp
  801101:	68 ec 29 80 00       	push   $0x8029ec
  801106:	6a 5c                	push   $0x5c
  801108:	68 ba 29 80 00       	push   $0x8029ba
  80110d:	e8 3f f1 ff ff       	call   800251 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  801112:	83 ec 0c             	sub    $0xc,%esp
  801115:	68 05 08 00 00       	push   $0x805
  80111a:	56                   	push   %esi
  80111b:	6a 00                	push   $0x0
  80111d:	56                   	push   %esi
  80111e:	6a 00                	push   $0x0
  801120:	e8 d0 fb ff ff       	call   800cf5 <sys_page_map>
		if (r < 0) {
  801125:	83 c4 20             	add    $0x20,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	79 3e                	jns    80116a <fork+0x191>
		    	panic("sys page map fault %e");
  80112c:	83 ec 04             	sub    $0x4,%esp
  80112f:	68 ec 29 80 00       	push   $0x8029ec
  801134:	6a 60                	push   $0x60
  801136:	68 ba 29 80 00       	push   $0x8029ba
  80113b:	e8 11 f1 ff ff       	call   800251 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	6a 05                	push   $0x5
  801145:	56                   	push   %esi
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	6a 00                	push   $0x0
  80114a:	e8 a6 fb ff ff       	call   800cf5 <sys_page_map>
		if (r < 0) {
  80114f:	83 c4 20             	add    $0x20,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	79 14                	jns    80116a <fork+0x191>
		    	panic("sys page map fault %e");
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	68 ec 29 80 00       	push   $0x8029ec
  80115e:	6a 65                	push   $0x65
  801160:	68 ba 29 80 00       	push   $0x8029ba
  801165:	e8 e7 f0 ff ff       	call   800251 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80116a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801170:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801176:	0f 85 de fe ff ff    	jne    80105a <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80117c:	a1 04 40 80 00       	mov    0x804004,%eax
  801181:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	50                   	push   %eax
  80118b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80118e:	57                   	push   %edi
  80118f:	e8 69 fc ff ff       	call   800dfd <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  801194:	83 c4 08             	add    $0x8,%esp
  801197:	6a 02                	push   $0x2
  801199:	57                   	push   %edi
  80119a:	e8 da fb ff ff       	call   800d79 <sys_env_set_status>
	
	return envid;
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <sfork>:

envid_t
sfork(void)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8011bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bf:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011c4:	68 17 02 80 00       	push   $0x800217
  8011c9:	e8 d5 fc ff ff       	call   800ea3 <sys_thread_create>

	return id;
}
  8011ce:	c9                   	leave  
  8011cf:	c3                   	ret    

008011d0 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8011d6:	ff 75 08             	pushl  0x8(%ebp)
  8011d9:	e8 e5 fc ff ff       	call   800ec3 <sys_thread_free>
}
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8011e9:	ff 75 08             	pushl  0x8(%ebp)
  8011ec:	e8 f2 fc ff ff       	call   800ee3 <sys_thread_join>
}
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	c9                   	leave  
  8011f5:	c3                   	ret    

008011f6 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	56                   	push   %esi
  8011fa:	53                   	push   %ebx
  8011fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8011fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	6a 07                	push   $0x7
  801206:	6a 00                	push   $0x0
  801208:	56                   	push   %esi
  801209:	e8 a4 fa ff ff       	call   800cb2 <sys_page_alloc>
	if (r < 0) {
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	79 15                	jns    80122a <queue_append+0x34>
		panic("%e\n", r);
  801215:	50                   	push   %eax
  801216:	68 32 2a 80 00       	push   $0x802a32
  80121b:	68 d5 00 00 00       	push   $0xd5
  801220:	68 ba 29 80 00       	push   $0x8029ba
  801225:	e8 27 f0 ff ff       	call   800251 <_panic>
	}	

	wt->envid = envid;
  80122a:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  801230:	83 3b 00             	cmpl   $0x0,(%ebx)
  801233:	75 13                	jne    801248 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  801235:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80123c:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801243:	00 00 00 
  801246:	eb 1b                	jmp    801263 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  801248:	8b 43 04             	mov    0x4(%ebx),%eax
  80124b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801252:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801259:	00 00 00 
		queue->last = wt;
  80125c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801263:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801266:	5b                   	pop    %ebx
  801267:	5e                   	pop    %esi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  801273:	8b 02                	mov    (%edx),%eax
  801275:	85 c0                	test   %eax,%eax
  801277:	75 17                	jne    801290 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  801279:	83 ec 04             	sub    $0x4,%esp
  80127c:	68 02 2a 80 00       	push   $0x802a02
  801281:	68 ec 00 00 00       	push   $0xec
  801286:	68 ba 29 80 00       	push   $0x8029ba
  80128b:	e8 c1 ef ff ff       	call   800251 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801290:	8b 48 04             	mov    0x4(%eax),%ecx
  801293:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  801295:	8b 00                	mov    (%eax),%eax
}
  801297:	c9                   	leave  
  801298:	c3                   	ret    

00801299 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8012a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a6:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	74 4a                	je     8012f7 <mutex_lock+0x5e>
  8012ad:	8b 73 04             	mov    0x4(%ebx),%esi
  8012b0:	83 3e 00             	cmpl   $0x0,(%esi)
  8012b3:	75 42                	jne    8012f7 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  8012b5:	e8 ba f9 ff ff       	call   800c74 <sys_getenvid>
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	56                   	push   %esi
  8012be:	50                   	push   %eax
  8012bf:	e8 32 ff ff ff       	call   8011f6 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8012c4:	e8 ab f9 ff ff       	call   800c74 <sys_getenvid>
  8012c9:	83 c4 08             	add    $0x8,%esp
  8012cc:	6a 04                	push   $0x4
  8012ce:	50                   	push   %eax
  8012cf:	e8 a5 fa ff ff       	call   800d79 <sys_env_set_status>

		if (r < 0) {
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	79 15                	jns    8012f0 <mutex_lock+0x57>
			panic("%e\n", r);
  8012db:	50                   	push   %eax
  8012dc:	68 32 2a 80 00       	push   $0x802a32
  8012e1:	68 02 01 00 00       	push   $0x102
  8012e6:	68 ba 29 80 00       	push   $0x8029ba
  8012eb:	e8 61 ef ff ff       	call   800251 <_panic>
		}
		sys_yield();
  8012f0:	e8 9e f9 ff ff       	call   800c93 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8012f5:	eb 08                	jmp    8012ff <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8012f7:	e8 78 f9 ff ff       	call   800c74 <sys_getenvid>
  8012fc:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8012ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801302:	5b                   	pop    %ebx
  801303:	5e                   	pop    %esi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	53                   	push   %ebx
  80130a:	83 ec 04             	sub    $0x4,%esp
  80130d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
  801315:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801318:	8b 43 04             	mov    0x4(%ebx),%eax
  80131b:	83 38 00             	cmpl   $0x0,(%eax)
  80131e:	74 33                	je     801353 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  801320:	83 ec 0c             	sub    $0xc,%esp
  801323:	50                   	push   %eax
  801324:	e8 41 ff ff ff       	call   80126a <queue_pop>
  801329:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	6a 02                	push   $0x2
  801331:	50                   	push   %eax
  801332:	e8 42 fa ff ff       	call   800d79 <sys_env_set_status>
		if (r < 0) {
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	79 15                	jns    801353 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80133e:	50                   	push   %eax
  80133f:	68 32 2a 80 00       	push   $0x802a32
  801344:	68 16 01 00 00       	push   $0x116
  801349:	68 ba 29 80 00       	push   $0x8029ba
  80134e:	e8 fe ee ff ff       	call   800251 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  801353:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	53                   	push   %ebx
  80135c:	83 ec 04             	sub    $0x4,%esp
  80135f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801362:	e8 0d f9 ff ff       	call   800c74 <sys_getenvid>
  801367:	83 ec 04             	sub    $0x4,%esp
  80136a:	6a 07                	push   $0x7
  80136c:	53                   	push   %ebx
  80136d:	50                   	push   %eax
  80136e:	e8 3f f9 ff ff       	call   800cb2 <sys_page_alloc>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	79 15                	jns    80138f <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80137a:	50                   	push   %eax
  80137b:	68 1d 2a 80 00       	push   $0x802a1d
  801380:	68 22 01 00 00       	push   $0x122
  801385:	68 ba 29 80 00       	push   $0x8029ba
  80138a:	e8 c2 ee ff ff       	call   800251 <_panic>
	}	
	mtx->locked = 0;
  80138f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801395:	8b 43 04             	mov    0x4(%ebx),%eax
  801398:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80139e:	8b 43 04             	mov    0x4(%ebx),%eax
  8013a1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8013a8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8013af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    

008013b4 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  8013be:	eb 21                	jmp    8013e1 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  8013c0:	83 ec 0c             	sub    $0xc,%esp
  8013c3:	50                   	push   %eax
  8013c4:	e8 a1 fe ff ff       	call   80126a <queue_pop>
  8013c9:	83 c4 08             	add    $0x8,%esp
  8013cc:	6a 02                	push   $0x2
  8013ce:	50                   	push   %eax
  8013cf:	e8 a5 f9 ff ff       	call   800d79 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8013d4:	8b 43 04             	mov    0x4(%ebx),%eax
  8013d7:	8b 10                	mov    (%eax),%edx
  8013d9:	8b 52 04             	mov    0x4(%edx),%edx
  8013dc:	89 10                	mov    %edx,(%eax)
  8013de:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8013e1:	8b 43 04             	mov    0x4(%ebx),%eax
  8013e4:	83 38 00             	cmpl   $0x0,(%eax)
  8013e7:	75 d7                	jne    8013c0 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8013e9:	83 ec 04             	sub    $0x4,%esp
  8013ec:	68 00 10 00 00       	push   $0x1000
  8013f1:	6a 00                	push   $0x0
  8013f3:	53                   	push   %ebx
  8013f4:	e8 fb f5 ff ff       	call   8009f4 <memset>
	mtx = NULL;
}
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801404:	8b 45 08             	mov    0x8(%ebp),%eax
  801407:	05 00 00 00 30       	add    $0x30000000,%eax
  80140c:	c1 e8 0c             	shr    $0xc,%eax
}
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801414:	8b 45 08             	mov    0x8(%ebp),%eax
  801417:	05 00 00 00 30       	add    $0x30000000,%eax
  80141c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801421:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801433:	89 c2                	mov    %eax,%edx
  801435:	c1 ea 16             	shr    $0x16,%edx
  801438:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143f:	f6 c2 01             	test   $0x1,%dl
  801442:	74 11                	je     801455 <fd_alloc+0x2d>
  801444:	89 c2                	mov    %eax,%edx
  801446:	c1 ea 0c             	shr    $0xc,%edx
  801449:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801450:	f6 c2 01             	test   $0x1,%dl
  801453:	75 09                	jne    80145e <fd_alloc+0x36>
			*fd_store = fd;
  801455:	89 01                	mov    %eax,(%ecx)
			return 0;
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
  80145c:	eb 17                	jmp    801475 <fd_alloc+0x4d>
  80145e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801463:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801468:	75 c9                	jne    801433 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80146a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801470:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80147d:	83 f8 1f             	cmp    $0x1f,%eax
  801480:	77 36                	ja     8014b8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801482:	c1 e0 0c             	shl    $0xc,%eax
  801485:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80148a:	89 c2                	mov    %eax,%edx
  80148c:	c1 ea 16             	shr    $0x16,%edx
  80148f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801496:	f6 c2 01             	test   $0x1,%dl
  801499:	74 24                	je     8014bf <fd_lookup+0x48>
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	c1 ea 0c             	shr    $0xc,%edx
  8014a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a7:	f6 c2 01             	test   $0x1,%dl
  8014aa:	74 1a                	je     8014c6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014af:	89 02                	mov    %eax,(%edx)
	return 0;
  8014b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b6:	eb 13                	jmp    8014cb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014bd:	eb 0c                	jmp    8014cb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c4:	eb 05                	jmp    8014cb <fd_lookup+0x54>
  8014c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d6:	ba b8 2a 80 00       	mov    $0x802ab8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014db:	eb 13                	jmp    8014f0 <dev_lookup+0x23>
  8014dd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014e0:	39 08                	cmp    %ecx,(%eax)
  8014e2:	75 0c                	jne    8014f0 <dev_lookup+0x23>
			*dev = devtab[i];
  8014e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ee:	eb 31                	jmp    801521 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014f0:	8b 02                	mov    (%edx),%eax
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	75 e7                	jne    8014dd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8014fb:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	51                   	push   %ecx
  801505:	50                   	push   %eax
  801506:	68 38 2a 80 00       	push   $0x802a38
  80150b:	e8 1a ee ff ff       	call   80032a <cprintf>
	*dev = 0;
  801510:	8b 45 0c             	mov    0xc(%ebp),%eax
  801513:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	83 ec 10             	sub    $0x10,%esp
  80152b:	8b 75 08             	mov    0x8(%ebp),%esi
  80152e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801531:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80153b:	c1 e8 0c             	shr    $0xc,%eax
  80153e:	50                   	push   %eax
  80153f:	e8 33 ff ff ff       	call   801477 <fd_lookup>
  801544:	83 c4 08             	add    $0x8,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 05                	js     801550 <fd_close+0x2d>
	    || fd != fd2)
  80154b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80154e:	74 0c                	je     80155c <fd_close+0x39>
		return (must_exist ? r : 0);
  801550:	84 db                	test   %bl,%bl
  801552:	ba 00 00 00 00       	mov    $0x0,%edx
  801557:	0f 44 c2             	cmove  %edx,%eax
  80155a:	eb 41                	jmp    80159d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80155c:	83 ec 08             	sub    $0x8,%esp
  80155f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801562:	50                   	push   %eax
  801563:	ff 36                	pushl  (%esi)
  801565:	e8 63 ff ff ff       	call   8014cd <dev_lookup>
  80156a:	89 c3                	mov    %eax,%ebx
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 1a                	js     80158d <fd_close+0x6a>
		if (dev->dev_close)
  801573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801576:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801579:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80157e:	85 c0                	test   %eax,%eax
  801580:	74 0b                	je     80158d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	56                   	push   %esi
  801586:	ff d0                	call   *%eax
  801588:	89 c3                	mov    %eax,%ebx
  80158a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	56                   	push   %esi
  801591:	6a 00                	push   $0x0
  801593:	e8 9f f7 ff ff       	call   800d37 <sys_page_unmap>
	return r;
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	89 d8                	mov    %ebx,%eax
}
  80159d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	ff 75 08             	pushl  0x8(%ebp)
  8015b1:	e8 c1 fe ff ff       	call   801477 <fd_lookup>
  8015b6:	83 c4 08             	add    $0x8,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 10                	js     8015cd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	6a 01                	push   $0x1
  8015c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c5:	e8 59 ff ff ff       	call   801523 <fd_close>
  8015ca:	83 c4 10             	add    $0x10,%esp
}
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <close_all>:

void
close_all(void)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015db:	83 ec 0c             	sub    $0xc,%esp
  8015de:	53                   	push   %ebx
  8015df:	e8 c0 ff ff ff       	call   8015a4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015e4:	83 c3 01             	add    $0x1,%ebx
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	83 fb 20             	cmp    $0x20,%ebx
  8015ed:	75 ec                	jne    8015db <close_all+0xc>
		close(i);
}
  8015ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	57                   	push   %edi
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 2c             	sub    $0x2c,%esp
  8015fd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801600:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	ff 75 08             	pushl  0x8(%ebp)
  801607:	e8 6b fe ff ff       	call   801477 <fd_lookup>
  80160c:	83 c4 08             	add    $0x8,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	0f 88 c1 00 00 00    	js     8016d8 <dup+0xe4>
		return r;
	close(newfdnum);
  801617:	83 ec 0c             	sub    $0xc,%esp
  80161a:	56                   	push   %esi
  80161b:	e8 84 ff ff ff       	call   8015a4 <close>

	newfd = INDEX2FD(newfdnum);
  801620:	89 f3                	mov    %esi,%ebx
  801622:	c1 e3 0c             	shl    $0xc,%ebx
  801625:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80162b:	83 c4 04             	add    $0x4,%esp
  80162e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801631:	e8 db fd ff ff       	call   801411 <fd2data>
  801636:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801638:	89 1c 24             	mov    %ebx,(%esp)
  80163b:	e8 d1 fd ff ff       	call   801411 <fd2data>
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801646:	89 f8                	mov    %edi,%eax
  801648:	c1 e8 16             	shr    $0x16,%eax
  80164b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801652:	a8 01                	test   $0x1,%al
  801654:	74 37                	je     80168d <dup+0x99>
  801656:	89 f8                	mov    %edi,%eax
  801658:	c1 e8 0c             	shr    $0xc,%eax
  80165b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801662:	f6 c2 01             	test   $0x1,%dl
  801665:	74 26                	je     80168d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801667:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80166e:	83 ec 0c             	sub    $0xc,%esp
  801671:	25 07 0e 00 00       	and    $0xe07,%eax
  801676:	50                   	push   %eax
  801677:	ff 75 d4             	pushl  -0x2c(%ebp)
  80167a:	6a 00                	push   $0x0
  80167c:	57                   	push   %edi
  80167d:	6a 00                	push   $0x0
  80167f:	e8 71 f6 ff ff       	call   800cf5 <sys_page_map>
  801684:	89 c7                	mov    %eax,%edi
  801686:	83 c4 20             	add    $0x20,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 2e                	js     8016bb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80168d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801690:	89 d0                	mov    %edx,%eax
  801692:	c1 e8 0c             	shr    $0xc,%eax
  801695:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80169c:	83 ec 0c             	sub    $0xc,%esp
  80169f:	25 07 0e 00 00       	and    $0xe07,%eax
  8016a4:	50                   	push   %eax
  8016a5:	53                   	push   %ebx
  8016a6:	6a 00                	push   $0x0
  8016a8:	52                   	push   %edx
  8016a9:	6a 00                	push   $0x0
  8016ab:	e8 45 f6 ff ff       	call   800cf5 <sys_page_map>
  8016b0:	89 c7                	mov    %eax,%edi
  8016b2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016b5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b7:	85 ff                	test   %edi,%edi
  8016b9:	79 1d                	jns    8016d8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016bb:	83 ec 08             	sub    $0x8,%esp
  8016be:	53                   	push   %ebx
  8016bf:	6a 00                	push   $0x0
  8016c1:	e8 71 f6 ff ff       	call   800d37 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016c6:	83 c4 08             	add    $0x8,%esp
  8016c9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016cc:	6a 00                	push   $0x0
  8016ce:	e8 64 f6 ff ff       	call   800d37 <sys_page_unmap>
	return r;
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	89 f8                	mov    %edi,%eax
}
  8016d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016db:	5b                   	pop    %ebx
  8016dc:	5e                   	pop    %esi
  8016dd:	5f                   	pop    %edi
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 14             	sub    $0x14,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	53                   	push   %ebx
  8016ef:	e8 83 fd ff ff       	call   801477 <fd_lookup>
  8016f4:	83 c4 08             	add    $0x8,%esp
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 70                	js     80176d <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801707:	ff 30                	pushl  (%eax)
  801709:	e8 bf fd ff ff       	call   8014cd <dev_lookup>
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 4f                	js     801764 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801715:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801718:	8b 42 08             	mov    0x8(%edx),%eax
  80171b:	83 e0 03             	and    $0x3,%eax
  80171e:	83 f8 01             	cmp    $0x1,%eax
  801721:	75 24                	jne    801747 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801723:	a1 04 40 80 00       	mov    0x804004,%eax
  801728:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80172e:	83 ec 04             	sub    $0x4,%esp
  801731:	53                   	push   %ebx
  801732:	50                   	push   %eax
  801733:	68 7c 2a 80 00       	push   $0x802a7c
  801738:	e8 ed eb ff ff       	call   80032a <cprintf>
		return -E_INVAL;
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801745:	eb 26                	jmp    80176d <read+0x8d>
	}
	if (!dev->dev_read)
  801747:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174a:	8b 40 08             	mov    0x8(%eax),%eax
  80174d:	85 c0                	test   %eax,%eax
  80174f:	74 17                	je     801768 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801751:	83 ec 04             	sub    $0x4,%esp
  801754:	ff 75 10             	pushl  0x10(%ebp)
  801757:	ff 75 0c             	pushl  0xc(%ebp)
  80175a:	52                   	push   %edx
  80175b:	ff d0                	call   *%eax
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	eb 09                	jmp    80176d <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801764:	89 c2                	mov    %eax,%edx
  801766:	eb 05                	jmp    80176d <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801768:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  80176d:	89 d0                	mov    %edx,%eax
  80176f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	57                   	push   %edi
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	83 ec 0c             	sub    $0xc,%esp
  80177d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801780:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801783:	bb 00 00 00 00       	mov    $0x0,%ebx
  801788:	eb 21                	jmp    8017ab <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	89 f0                	mov    %esi,%eax
  80178f:	29 d8                	sub    %ebx,%eax
  801791:	50                   	push   %eax
  801792:	89 d8                	mov    %ebx,%eax
  801794:	03 45 0c             	add    0xc(%ebp),%eax
  801797:	50                   	push   %eax
  801798:	57                   	push   %edi
  801799:	e8 42 ff ff ff       	call   8016e0 <read>
		if (m < 0)
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 10                	js     8017b5 <readn+0x41>
			return m;
		if (m == 0)
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	74 0a                	je     8017b3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017a9:	01 c3                	add    %eax,%ebx
  8017ab:	39 f3                	cmp    %esi,%ebx
  8017ad:	72 db                	jb     80178a <readn+0x16>
  8017af:	89 d8                	mov    %ebx,%eax
  8017b1:	eb 02                	jmp    8017b5 <readn+0x41>
  8017b3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	5f                   	pop    %edi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 14             	sub    $0x14,%esp
  8017c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ca:	50                   	push   %eax
  8017cb:	53                   	push   %ebx
  8017cc:	e8 a6 fc ff ff       	call   801477 <fd_lookup>
  8017d1:	83 c4 08             	add    $0x8,%esp
  8017d4:	89 c2                	mov    %eax,%edx
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 6b                	js     801845 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e0:	50                   	push   %eax
  8017e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e4:	ff 30                	pushl  (%eax)
  8017e6:	e8 e2 fc ff ff       	call   8014cd <dev_lookup>
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 4a                	js     80183c <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f9:	75 24                	jne    80181f <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801800:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	53                   	push   %ebx
  80180a:	50                   	push   %eax
  80180b:	68 98 2a 80 00       	push   $0x802a98
  801810:	e8 15 eb ff ff       	call   80032a <cprintf>
		return -E_INVAL;
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80181d:	eb 26                	jmp    801845 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80181f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801822:	8b 52 0c             	mov    0xc(%edx),%edx
  801825:	85 d2                	test   %edx,%edx
  801827:	74 17                	je     801840 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801829:	83 ec 04             	sub    $0x4,%esp
  80182c:	ff 75 10             	pushl  0x10(%ebp)
  80182f:	ff 75 0c             	pushl  0xc(%ebp)
  801832:	50                   	push   %eax
  801833:	ff d2                	call   *%edx
  801835:	89 c2                	mov    %eax,%edx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	eb 09                	jmp    801845 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183c:	89 c2                	mov    %eax,%edx
  80183e:	eb 05                	jmp    801845 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801840:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801845:	89 d0                	mov    %edx,%eax
  801847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <seek>:

int
seek(int fdnum, off_t offset)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801852:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801855:	50                   	push   %eax
  801856:	ff 75 08             	pushl  0x8(%ebp)
  801859:	e8 19 fc ff ff       	call   801477 <fd_lookup>
  80185e:	83 c4 08             	add    $0x8,%esp
  801861:	85 c0                	test   %eax,%eax
  801863:	78 0e                	js     801873 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801865:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80186b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80186e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801873:	c9                   	leave  
  801874:	c3                   	ret    

00801875 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	53                   	push   %ebx
  801879:	83 ec 14             	sub    $0x14,%esp
  80187c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801882:	50                   	push   %eax
  801883:	53                   	push   %ebx
  801884:	e8 ee fb ff ff       	call   801477 <fd_lookup>
  801889:	83 c4 08             	add    $0x8,%esp
  80188c:	89 c2                	mov    %eax,%edx
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 68                	js     8018fa <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189c:	ff 30                	pushl  (%eax)
  80189e:	e8 2a fc ff ff       	call   8014cd <dev_lookup>
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 47                	js     8018f1 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018b1:	75 24                	jne    8018d7 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018b3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018b8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8018be:	83 ec 04             	sub    $0x4,%esp
  8018c1:	53                   	push   %ebx
  8018c2:	50                   	push   %eax
  8018c3:	68 58 2a 80 00       	push   $0x802a58
  8018c8:	e8 5d ea ff ff       	call   80032a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018d5:	eb 23                	jmp    8018fa <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8018d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018da:	8b 52 18             	mov    0x18(%edx),%edx
  8018dd:	85 d2                	test   %edx,%edx
  8018df:	74 14                	je     8018f5 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	50                   	push   %eax
  8018e8:	ff d2                	call   *%edx
  8018ea:	89 c2                	mov    %eax,%edx
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	eb 09                	jmp    8018fa <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f1:	89 c2                	mov    %eax,%edx
  8018f3:	eb 05                	jmp    8018fa <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018fa:	89 d0                	mov    %edx,%eax
  8018fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ff:	c9                   	leave  
  801900:	c3                   	ret    

00801901 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	53                   	push   %ebx
  801905:	83 ec 14             	sub    $0x14,%esp
  801908:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80190b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80190e:	50                   	push   %eax
  80190f:	ff 75 08             	pushl  0x8(%ebp)
  801912:	e8 60 fb ff ff       	call   801477 <fd_lookup>
  801917:	83 c4 08             	add    $0x8,%esp
  80191a:	89 c2                	mov    %eax,%edx
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 58                	js     801978 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801920:	83 ec 08             	sub    $0x8,%esp
  801923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801926:	50                   	push   %eax
  801927:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192a:	ff 30                	pushl  (%eax)
  80192c:	e8 9c fb ff ff       	call   8014cd <dev_lookup>
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	85 c0                	test   %eax,%eax
  801936:	78 37                	js     80196f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801938:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80193f:	74 32                	je     801973 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801941:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801944:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80194b:	00 00 00 
	stat->st_isdir = 0;
  80194e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801955:	00 00 00 
	stat->st_dev = dev;
  801958:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	53                   	push   %ebx
  801962:	ff 75 f0             	pushl  -0x10(%ebp)
  801965:	ff 50 14             	call   *0x14(%eax)
  801968:	89 c2                	mov    %eax,%edx
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	eb 09                	jmp    801978 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196f:	89 c2                	mov    %eax,%edx
  801971:	eb 05                	jmp    801978 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801973:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801978:	89 d0                	mov    %edx,%eax
  80197a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	56                   	push   %esi
  801983:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801984:	83 ec 08             	sub    $0x8,%esp
  801987:	6a 00                	push   $0x0
  801989:	ff 75 08             	pushl  0x8(%ebp)
  80198c:	e8 e3 01 00 00       	call   801b74 <open>
  801991:	89 c3                	mov    %eax,%ebx
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	85 c0                	test   %eax,%eax
  801998:	78 1b                	js     8019b5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80199a:	83 ec 08             	sub    $0x8,%esp
  80199d:	ff 75 0c             	pushl  0xc(%ebp)
  8019a0:	50                   	push   %eax
  8019a1:	e8 5b ff ff ff       	call   801901 <fstat>
  8019a6:	89 c6                	mov    %eax,%esi
	close(fd);
  8019a8:	89 1c 24             	mov    %ebx,(%esp)
  8019ab:	e8 f4 fb ff ff       	call   8015a4 <close>
	return r;
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	89 f0                	mov    %esi,%eax
}
  8019b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5d                   	pop    %ebp
  8019bb:	c3                   	ret    

008019bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	89 c6                	mov    %eax,%esi
  8019c3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019c5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019cc:	75 12                	jne    8019e0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	6a 01                	push   $0x1
  8019d3:	e8 94 08 00 00       	call   80226c <ipc_find_env>
  8019d8:	a3 00 40 80 00       	mov    %eax,0x804000
  8019dd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019e0:	6a 07                	push   $0x7
  8019e2:	68 00 50 80 00       	push   $0x805000
  8019e7:	56                   	push   %esi
  8019e8:	ff 35 00 40 80 00    	pushl  0x804000
  8019ee:	e8 17 08 00 00       	call   80220a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019f3:	83 c4 0c             	add    $0xc,%esp
  8019f6:	6a 00                	push   $0x0
  8019f8:	53                   	push   %ebx
  8019f9:	6a 00                	push   $0x0
  8019fb:	e8 8f 07 00 00       	call   80218f <ipc_recv>
}
  801a00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    

00801a07 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a10:	8b 40 0c             	mov    0xc(%eax),%eax
  801a13:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a20:	ba 00 00 00 00       	mov    $0x0,%edx
  801a25:	b8 02 00 00 00       	mov    $0x2,%eax
  801a2a:	e8 8d ff ff ff       	call   8019bc <fsipc>
}
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    

00801a31 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a37:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a42:	ba 00 00 00 00       	mov    $0x0,%edx
  801a47:	b8 06 00 00 00       	mov    $0x6,%eax
  801a4c:	e8 6b ff ff ff       	call   8019bc <fsipc>
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	53                   	push   %ebx
  801a57:	83 ec 04             	sub    $0x4,%esp
  801a5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a60:	8b 40 0c             	mov    0xc(%eax),%eax
  801a63:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a68:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6d:	b8 05 00 00 00       	mov    $0x5,%eax
  801a72:	e8 45 ff ff ff       	call   8019bc <fsipc>
  801a77:	85 c0                	test   %eax,%eax
  801a79:	78 2c                	js     801aa7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a7b:	83 ec 08             	sub    $0x8,%esp
  801a7e:	68 00 50 80 00       	push   $0x805000
  801a83:	53                   	push   %ebx
  801a84:	e8 26 ee ff ff       	call   8008af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a89:	a1 80 50 80 00       	mov    0x805080,%eax
  801a8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a94:	a1 84 50 80 00       	mov    0x805084,%eax
  801a99:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

00801aac <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ab5:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab8:	8b 52 0c             	mov    0xc(%edx),%edx
  801abb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ac1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ac6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801acb:	0f 47 c2             	cmova  %edx,%eax
  801ace:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801ad3:	50                   	push   %eax
  801ad4:	ff 75 0c             	pushl  0xc(%ebp)
  801ad7:	68 08 50 80 00       	push   $0x805008
  801adc:	e8 60 ef ff ff       	call   800a41 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae6:	b8 04 00 00 00       	mov    $0x4,%eax
  801aeb:	e8 cc fe ff ff       	call   8019bc <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
  801af7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
  801afd:	8b 40 0c             	mov    0xc(%eax),%eax
  801b00:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b05:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b10:	b8 03 00 00 00       	mov    $0x3,%eax
  801b15:	e8 a2 fe ff ff       	call   8019bc <fsipc>
  801b1a:	89 c3                	mov    %eax,%ebx
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	78 4b                	js     801b6b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b20:	39 c6                	cmp    %eax,%esi
  801b22:	73 16                	jae    801b3a <devfile_read+0x48>
  801b24:	68 c8 2a 80 00       	push   $0x802ac8
  801b29:	68 cf 2a 80 00       	push   $0x802acf
  801b2e:	6a 7c                	push   $0x7c
  801b30:	68 e4 2a 80 00       	push   $0x802ae4
  801b35:	e8 17 e7 ff ff       	call   800251 <_panic>
	assert(r <= PGSIZE);
  801b3a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b3f:	7e 16                	jle    801b57 <devfile_read+0x65>
  801b41:	68 ef 2a 80 00       	push   $0x802aef
  801b46:	68 cf 2a 80 00       	push   $0x802acf
  801b4b:	6a 7d                	push   $0x7d
  801b4d:	68 e4 2a 80 00       	push   $0x802ae4
  801b52:	e8 fa e6 ff ff       	call   800251 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b57:	83 ec 04             	sub    $0x4,%esp
  801b5a:	50                   	push   %eax
  801b5b:	68 00 50 80 00       	push   $0x805000
  801b60:	ff 75 0c             	pushl  0xc(%ebp)
  801b63:	e8 d9 ee ff ff       	call   800a41 <memmove>
	return r;
  801b68:	83 c4 10             	add    $0x10,%esp
}
  801b6b:	89 d8                	mov    %ebx,%eax
  801b6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5e                   	pop    %esi
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	53                   	push   %ebx
  801b78:	83 ec 20             	sub    $0x20,%esp
  801b7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b7e:	53                   	push   %ebx
  801b7f:	e8 f2 ec ff ff       	call   800876 <strlen>
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b8c:	7f 67                	jg     801bf5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b94:	50                   	push   %eax
  801b95:	e8 8e f8 ff ff       	call   801428 <fd_alloc>
  801b9a:	83 c4 10             	add    $0x10,%esp
		return r;
  801b9d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	78 57                	js     801bfa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ba3:	83 ec 08             	sub    $0x8,%esp
  801ba6:	53                   	push   %ebx
  801ba7:	68 00 50 80 00       	push   $0x805000
  801bac:	e8 fe ec ff ff       	call   8008af <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bbc:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc1:	e8 f6 fd ff ff       	call   8019bc <fsipc>
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	79 14                	jns    801be3 <open+0x6f>
		fd_close(fd, 0);
  801bcf:	83 ec 08             	sub    $0x8,%esp
  801bd2:	6a 00                	push   $0x0
  801bd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd7:	e8 47 f9 ff ff       	call   801523 <fd_close>
		return r;
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	89 da                	mov    %ebx,%edx
  801be1:	eb 17                	jmp    801bfa <open+0x86>
	}

	return fd2num(fd);
  801be3:	83 ec 0c             	sub    $0xc,%esp
  801be6:	ff 75 f4             	pushl  -0xc(%ebp)
  801be9:	e8 13 f8 ff ff       	call   801401 <fd2num>
  801bee:	89 c2                	mov    %eax,%edx
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	eb 05                	jmp    801bfa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bf5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bfa:	89 d0                	mov    %edx,%eax
  801bfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bff:	c9                   	leave  
  801c00:	c3                   	ret    

00801c01 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c07:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0c:	b8 08 00 00 00       	mov    $0x8,%eax
  801c11:	e8 a6 fd ff ff       	call   8019bc <fsipc>
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	56                   	push   %esi
  801c1c:	53                   	push   %ebx
  801c1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c20:	83 ec 0c             	sub    $0xc,%esp
  801c23:	ff 75 08             	pushl  0x8(%ebp)
  801c26:	e8 e6 f7 ff ff       	call   801411 <fd2data>
  801c2b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c2d:	83 c4 08             	add    $0x8,%esp
  801c30:	68 fb 2a 80 00       	push   $0x802afb
  801c35:	53                   	push   %ebx
  801c36:	e8 74 ec ff ff       	call   8008af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c3b:	8b 46 04             	mov    0x4(%esi),%eax
  801c3e:	2b 06                	sub    (%esi),%eax
  801c40:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c46:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c4d:	00 00 00 
	stat->st_dev = &devpipe;
  801c50:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c57:	30 80 00 
	return 0;
}
  801c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c62:	5b                   	pop    %ebx
  801c63:	5e                   	pop    %esi
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c70:	53                   	push   %ebx
  801c71:	6a 00                	push   $0x0
  801c73:	e8 bf f0 ff ff       	call   800d37 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c78:	89 1c 24             	mov    %ebx,(%esp)
  801c7b:	e8 91 f7 ff ff       	call   801411 <fd2data>
  801c80:	83 c4 08             	add    $0x8,%esp
  801c83:	50                   	push   %eax
  801c84:	6a 00                	push   $0x0
  801c86:	e8 ac f0 ff ff       	call   800d37 <sys_page_unmap>
}
  801c8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	57                   	push   %edi
  801c94:	56                   	push   %esi
  801c95:	53                   	push   %ebx
  801c96:	83 ec 1c             	sub    $0x1c,%esp
  801c99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c9c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801ca3:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	ff 75 e0             	pushl  -0x20(%ebp)
  801caf:	e8 fd 05 00 00       	call   8022b1 <pageref>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	89 3c 24             	mov    %edi,(%esp)
  801cb9:	e8 f3 05 00 00       	call   8022b1 <pageref>
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	39 c3                	cmp    %eax,%ebx
  801cc3:	0f 94 c1             	sete   %cl
  801cc6:	0f b6 c9             	movzbl %cl,%ecx
  801cc9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ccc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cd2:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  801cd8:	39 ce                	cmp    %ecx,%esi
  801cda:	74 1e                	je     801cfa <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801cdc:	39 c3                	cmp    %eax,%ebx
  801cde:	75 be                	jne    801c9e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ce0:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  801ce6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ce9:	50                   	push   %eax
  801cea:	56                   	push   %esi
  801ceb:	68 02 2b 80 00       	push   $0x802b02
  801cf0:	e8 35 e6 ff ff       	call   80032a <cprintf>
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	eb a4                	jmp    801c9e <_pipeisclosed+0xe>
	}
}
  801cfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	57                   	push   %edi
  801d09:	56                   	push   %esi
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 28             	sub    $0x28,%esp
  801d0e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d11:	56                   	push   %esi
  801d12:	e8 fa f6 ff ff       	call   801411 <fd2data>
  801d17:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	bf 00 00 00 00       	mov    $0x0,%edi
  801d21:	eb 4b                	jmp    801d6e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d23:	89 da                	mov    %ebx,%edx
  801d25:	89 f0                	mov    %esi,%eax
  801d27:	e8 64 ff ff ff       	call   801c90 <_pipeisclosed>
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	75 48                	jne    801d78 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d30:	e8 5e ef ff ff       	call   800c93 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d35:	8b 43 04             	mov    0x4(%ebx),%eax
  801d38:	8b 0b                	mov    (%ebx),%ecx
  801d3a:	8d 51 20             	lea    0x20(%ecx),%edx
  801d3d:	39 d0                	cmp    %edx,%eax
  801d3f:	73 e2                	jae    801d23 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d44:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d48:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d4b:	89 c2                	mov    %eax,%edx
  801d4d:	c1 fa 1f             	sar    $0x1f,%edx
  801d50:	89 d1                	mov    %edx,%ecx
  801d52:	c1 e9 1b             	shr    $0x1b,%ecx
  801d55:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d58:	83 e2 1f             	and    $0x1f,%edx
  801d5b:	29 ca                	sub    %ecx,%edx
  801d5d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d61:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d65:	83 c0 01             	add    $0x1,%eax
  801d68:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6b:	83 c7 01             	add    $0x1,%edi
  801d6e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d71:	75 c2                	jne    801d35 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d73:	8b 45 10             	mov    0x10(%ebp),%eax
  801d76:	eb 05                	jmp    801d7d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	57                   	push   %edi
  801d89:	56                   	push   %esi
  801d8a:	53                   	push   %ebx
  801d8b:	83 ec 18             	sub    $0x18,%esp
  801d8e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d91:	57                   	push   %edi
  801d92:	e8 7a f6 ff ff       	call   801411 <fd2data>
  801d97:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801da1:	eb 3d                	jmp    801de0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801da3:	85 db                	test   %ebx,%ebx
  801da5:	74 04                	je     801dab <devpipe_read+0x26>
				return i;
  801da7:	89 d8                	mov    %ebx,%eax
  801da9:	eb 44                	jmp    801def <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dab:	89 f2                	mov    %esi,%edx
  801dad:	89 f8                	mov    %edi,%eax
  801daf:	e8 dc fe ff ff       	call   801c90 <_pipeisclosed>
  801db4:	85 c0                	test   %eax,%eax
  801db6:	75 32                	jne    801dea <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801db8:	e8 d6 ee ff ff       	call   800c93 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dbd:	8b 06                	mov    (%esi),%eax
  801dbf:	3b 46 04             	cmp    0x4(%esi),%eax
  801dc2:	74 df                	je     801da3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dc4:	99                   	cltd   
  801dc5:	c1 ea 1b             	shr    $0x1b,%edx
  801dc8:	01 d0                	add    %edx,%eax
  801dca:	83 e0 1f             	and    $0x1f,%eax
  801dcd:	29 d0                	sub    %edx,%eax
  801dcf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dd7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dda:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ddd:	83 c3 01             	add    $0x1,%ebx
  801de0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801de3:	75 d8                	jne    801dbd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801de5:	8b 45 10             	mov    0x10(%ebp),%eax
  801de8:	eb 05                	jmp    801def <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dea:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801def:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df2:	5b                   	pop    %ebx
  801df3:	5e                   	pop    %esi
  801df4:	5f                   	pop    %edi
  801df5:	5d                   	pop    %ebp
  801df6:	c3                   	ret    

00801df7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	56                   	push   %esi
  801dfb:	53                   	push   %ebx
  801dfc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e02:	50                   	push   %eax
  801e03:	e8 20 f6 ff ff       	call   801428 <fd_alloc>
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	89 c2                	mov    %eax,%edx
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	0f 88 2c 01 00 00    	js     801f41 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e15:	83 ec 04             	sub    $0x4,%esp
  801e18:	68 07 04 00 00       	push   $0x407
  801e1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e20:	6a 00                	push   $0x0
  801e22:	e8 8b ee ff ff       	call   800cb2 <sys_page_alloc>
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	89 c2                	mov    %eax,%edx
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	0f 88 0d 01 00 00    	js     801f41 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e3a:	50                   	push   %eax
  801e3b:	e8 e8 f5 ff ff       	call   801428 <fd_alloc>
  801e40:	89 c3                	mov    %eax,%ebx
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	85 c0                	test   %eax,%eax
  801e47:	0f 88 e2 00 00 00    	js     801f2f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4d:	83 ec 04             	sub    $0x4,%esp
  801e50:	68 07 04 00 00       	push   $0x407
  801e55:	ff 75 f0             	pushl  -0x10(%ebp)
  801e58:	6a 00                	push   $0x0
  801e5a:	e8 53 ee ff ff       	call   800cb2 <sys_page_alloc>
  801e5f:	89 c3                	mov    %eax,%ebx
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	85 c0                	test   %eax,%eax
  801e66:	0f 88 c3 00 00 00    	js     801f2f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e6c:	83 ec 0c             	sub    $0xc,%esp
  801e6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e72:	e8 9a f5 ff ff       	call   801411 <fd2data>
  801e77:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e79:	83 c4 0c             	add    $0xc,%esp
  801e7c:	68 07 04 00 00       	push   $0x407
  801e81:	50                   	push   %eax
  801e82:	6a 00                	push   $0x0
  801e84:	e8 29 ee ff ff       	call   800cb2 <sys_page_alloc>
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	0f 88 89 00 00 00    	js     801f1f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e96:	83 ec 0c             	sub    $0xc,%esp
  801e99:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9c:	e8 70 f5 ff ff       	call   801411 <fd2data>
  801ea1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ea8:	50                   	push   %eax
  801ea9:	6a 00                	push   $0x0
  801eab:	56                   	push   %esi
  801eac:	6a 00                	push   $0x0
  801eae:	e8 42 ee ff ff       	call   800cf5 <sys_page_map>
  801eb3:	89 c3                	mov    %eax,%ebx
  801eb5:	83 c4 20             	add    $0x20,%esp
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	78 55                	js     801f11 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ebc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ed1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eda:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801edf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	ff 75 f4             	pushl  -0xc(%ebp)
  801eec:	e8 10 f5 ff ff       	call   801401 <fd2num>
  801ef1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ef4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ef6:	83 c4 04             	add    $0x4,%esp
  801ef9:	ff 75 f0             	pushl  -0x10(%ebp)
  801efc:	e8 00 f5 ff ff       	call   801401 <fd2num>
  801f01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f04:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0f:	eb 30                	jmp    801f41 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f11:	83 ec 08             	sub    $0x8,%esp
  801f14:	56                   	push   %esi
  801f15:	6a 00                	push   $0x0
  801f17:	e8 1b ee ff ff       	call   800d37 <sys_page_unmap>
  801f1c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f1f:	83 ec 08             	sub    $0x8,%esp
  801f22:	ff 75 f0             	pushl  -0x10(%ebp)
  801f25:	6a 00                	push   $0x0
  801f27:	e8 0b ee ff ff       	call   800d37 <sys_page_unmap>
  801f2c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f2f:	83 ec 08             	sub    $0x8,%esp
  801f32:	ff 75 f4             	pushl  -0xc(%ebp)
  801f35:	6a 00                	push   $0x0
  801f37:	e8 fb ed ff ff       	call   800d37 <sys_page_unmap>
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f41:	89 d0                	mov    %edx,%eax
  801f43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    

00801f4a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f53:	50                   	push   %eax
  801f54:	ff 75 08             	pushl  0x8(%ebp)
  801f57:	e8 1b f5 ff ff       	call   801477 <fd_lookup>
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	78 18                	js     801f7b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f63:	83 ec 0c             	sub    $0xc,%esp
  801f66:	ff 75 f4             	pushl  -0xc(%ebp)
  801f69:	e8 a3 f4 ff ff       	call   801411 <fd2data>
	return _pipeisclosed(fd, p);
  801f6e:	89 c2                	mov    %eax,%edx
  801f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f73:	e8 18 fd ff ff       	call   801c90 <_pipeisclosed>
  801f78:	83 c4 10             	add    $0x10,%esp
}
  801f7b:	c9                   	leave  
  801f7c:	c3                   	ret    

00801f7d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f80:	b8 00 00 00 00       	mov    $0x0,%eax
  801f85:	5d                   	pop    %ebp
  801f86:	c3                   	ret    

00801f87 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f8d:	68 1a 2b 80 00       	push   $0x802b1a
  801f92:	ff 75 0c             	pushl  0xc(%ebp)
  801f95:	e8 15 e9 ff ff       	call   8008af <strcpy>
	return 0;
}
  801f9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	57                   	push   %edi
  801fa5:	56                   	push   %esi
  801fa6:	53                   	push   %ebx
  801fa7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fad:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fb2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb8:	eb 2d                	jmp    801fe7 <devcons_write+0x46>
		m = n - tot;
  801fba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fbd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fbf:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fc2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801fc7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fca:	83 ec 04             	sub    $0x4,%esp
  801fcd:	53                   	push   %ebx
  801fce:	03 45 0c             	add    0xc(%ebp),%eax
  801fd1:	50                   	push   %eax
  801fd2:	57                   	push   %edi
  801fd3:	e8 69 ea ff ff       	call   800a41 <memmove>
		sys_cputs(buf, m);
  801fd8:	83 c4 08             	add    $0x8,%esp
  801fdb:	53                   	push   %ebx
  801fdc:	57                   	push   %edi
  801fdd:	e8 14 ec ff ff       	call   800bf6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fe2:	01 de                	add    %ebx,%esi
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	89 f0                	mov    %esi,%eax
  801fe9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fec:	72 cc                	jb     801fba <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff1:	5b                   	pop    %ebx
  801ff2:	5e                   	pop    %esi
  801ff3:	5f                   	pop    %edi
  801ff4:	5d                   	pop    %ebp
  801ff5:	c3                   	ret    

00801ff6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	83 ec 08             	sub    $0x8,%esp
  801ffc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802001:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802005:	74 2a                	je     802031 <devcons_read+0x3b>
  802007:	eb 05                	jmp    80200e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802009:	e8 85 ec ff ff       	call   800c93 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80200e:	e8 01 ec ff ff       	call   800c14 <sys_cgetc>
  802013:	85 c0                	test   %eax,%eax
  802015:	74 f2                	je     802009 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802017:	85 c0                	test   %eax,%eax
  802019:	78 16                	js     802031 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80201b:	83 f8 04             	cmp    $0x4,%eax
  80201e:	74 0c                	je     80202c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802020:	8b 55 0c             	mov    0xc(%ebp),%edx
  802023:	88 02                	mov    %al,(%edx)
	return 1;
  802025:	b8 01 00 00 00       	mov    $0x1,%eax
  80202a:	eb 05                	jmp    802031 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80202c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802039:	8b 45 08             	mov    0x8(%ebp),%eax
  80203c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80203f:	6a 01                	push   $0x1
  802041:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802044:	50                   	push   %eax
  802045:	e8 ac eb ff ff       	call   800bf6 <sys_cputs>
}
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	c9                   	leave  
  80204e:	c3                   	ret    

0080204f <getchar>:

int
getchar(void)
{
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802055:	6a 01                	push   $0x1
  802057:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80205a:	50                   	push   %eax
  80205b:	6a 00                	push   $0x0
  80205d:	e8 7e f6 ff ff       	call   8016e0 <read>
	if (r < 0)
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	85 c0                	test   %eax,%eax
  802067:	78 0f                	js     802078 <getchar+0x29>
		return r;
	if (r < 1)
  802069:	85 c0                	test   %eax,%eax
  80206b:	7e 06                	jle    802073 <getchar+0x24>
		return -E_EOF;
	return c;
  80206d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802071:	eb 05                	jmp    802078 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802073:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802078:	c9                   	leave  
  802079:	c3                   	ret    

0080207a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802083:	50                   	push   %eax
  802084:	ff 75 08             	pushl  0x8(%ebp)
  802087:	e8 eb f3 ff ff       	call   801477 <fd_lookup>
  80208c:	83 c4 10             	add    $0x10,%esp
  80208f:	85 c0                	test   %eax,%eax
  802091:	78 11                	js     8020a4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802093:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802096:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80209c:	39 10                	cmp    %edx,(%eax)
  80209e:	0f 94 c0             	sete   %al
  8020a1:	0f b6 c0             	movzbl %al,%eax
}
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <opencons>:

int
opencons(void)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020af:	50                   	push   %eax
  8020b0:	e8 73 f3 ff ff       	call   801428 <fd_alloc>
  8020b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8020b8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ba:	85 c0                	test   %eax,%eax
  8020bc:	78 3e                	js     8020fc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020be:	83 ec 04             	sub    $0x4,%esp
  8020c1:	68 07 04 00 00       	push   $0x407
  8020c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c9:	6a 00                	push   $0x0
  8020cb:	e8 e2 eb ff ff       	call   800cb2 <sys_page_alloc>
  8020d0:	83 c4 10             	add    $0x10,%esp
		return r;
  8020d3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	78 23                	js     8020fc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020d9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020ee:	83 ec 0c             	sub    $0xc,%esp
  8020f1:	50                   	push   %eax
  8020f2:	e8 0a f3 ff ff       	call   801401 <fd2num>
  8020f7:	89 c2                	mov    %eax,%edx
  8020f9:	83 c4 10             	add    $0x10,%esp
}
  8020fc:	89 d0                	mov    %edx,%eax
  8020fe:	c9                   	leave  
  8020ff:	c3                   	ret    

00802100 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802106:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80210d:	75 2a                	jne    802139 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80210f:	83 ec 04             	sub    $0x4,%esp
  802112:	6a 07                	push   $0x7
  802114:	68 00 f0 bf ee       	push   $0xeebff000
  802119:	6a 00                	push   $0x0
  80211b:	e8 92 eb ff ff       	call   800cb2 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	85 c0                	test   %eax,%eax
  802125:	79 12                	jns    802139 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802127:	50                   	push   %eax
  802128:	68 32 2a 80 00       	push   $0x802a32
  80212d:	6a 23                	push   $0x23
  80212f:	68 26 2b 80 00       	push   $0x802b26
  802134:	e8 18 e1 ff ff       	call   800251 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802139:	8b 45 08             	mov    0x8(%ebp),%eax
  80213c:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802141:	83 ec 08             	sub    $0x8,%esp
  802144:	68 6b 21 80 00       	push   $0x80216b
  802149:	6a 00                	push   $0x0
  80214b:	e8 ad ec ff ff       	call   800dfd <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802150:	83 c4 10             	add    $0x10,%esp
  802153:	85 c0                	test   %eax,%eax
  802155:	79 12                	jns    802169 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802157:	50                   	push   %eax
  802158:	68 32 2a 80 00       	push   $0x802a32
  80215d:	6a 2c                	push   $0x2c
  80215f:	68 26 2b 80 00       	push   $0x802b26
  802164:	e8 e8 e0 ff ff       	call   800251 <_panic>
	}
}
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80216b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80216c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802171:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802173:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802176:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80217a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80217f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802183:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802185:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802188:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802189:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80218c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80218d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80218e:	c3                   	ret    

0080218f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	8b 75 08             	mov    0x8(%ebp),%esi
  802197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80219a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80219d:	85 c0                	test   %eax,%eax
  80219f:	75 12                	jne    8021b3 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8021a1:	83 ec 0c             	sub    $0xc,%esp
  8021a4:	68 00 00 c0 ee       	push   $0xeec00000
  8021a9:	e8 b4 ec ff ff       	call   800e62 <sys_ipc_recv>
  8021ae:	83 c4 10             	add    $0x10,%esp
  8021b1:	eb 0c                	jmp    8021bf <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8021b3:	83 ec 0c             	sub    $0xc,%esp
  8021b6:	50                   	push   %eax
  8021b7:	e8 a6 ec ff ff       	call   800e62 <sys_ipc_recv>
  8021bc:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8021bf:	85 f6                	test   %esi,%esi
  8021c1:	0f 95 c1             	setne  %cl
  8021c4:	85 db                	test   %ebx,%ebx
  8021c6:	0f 95 c2             	setne  %dl
  8021c9:	84 d1                	test   %dl,%cl
  8021cb:	74 09                	je     8021d6 <ipc_recv+0x47>
  8021cd:	89 c2                	mov    %eax,%edx
  8021cf:	c1 ea 1f             	shr    $0x1f,%edx
  8021d2:	84 d2                	test   %dl,%dl
  8021d4:	75 2d                	jne    802203 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8021d6:	85 f6                	test   %esi,%esi
  8021d8:	74 0d                	je     8021e7 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8021da:	a1 04 40 80 00       	mov    0x804004,%eax
  8021df:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  8021e5:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8021e7:	85 db                	test   %ebx,%ebx
  8021e9:	74 0d                	je     8021f8 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8021eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8021f0:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8021f6:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8021f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8021fd:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802203:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802206:	5b                   	pop    %ebx
  802207:	5e                   	pop    %esi
  802208:	5d                   	pop    %ebp
  802209:	c3                   	ret    

0080220a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	57                   	push   %edi
  80220e:	56                   	push   %esi
  80220f:	53                   	push   %ebx
  802210:	83 ec 0c             	sub    $0xc,%esp
  802213:	8b 7d 08             	mov    0x8(%ebp),%edi
  802216:	8b 75 0c             	mov    0xc(%ebp),%esi
  802219:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80221c:	85 db                	test   %ebx,%ebx
  80221e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802223:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802226:	ff 75 14             	pushl  0x14(%ebp)
  802229:	53                   	push   %ebx
  80222a:	56                   	push   %esi
  80222b:	57                   	push   %edi
  80222c:	e8 0e ec ff ff       	call   800e3f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802231:	89 c2                	mov    %eax,%edx
  802233:	c1 ea 1f             	shr    $0x1f,%edx
  802236:	83 c4 10             	add    $0x10,%esp
  802239:	84 d2                	test   %dl,%dl
  80223b:	74 17                	je     802254 <ipc_send+0x4a>
  80223d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802240:	74 12                	je     802254 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802242:	50                   	push   %eax
  802243:	68 34 2b 80 00       	push   $0x802b34
  802248:	6a 47                	push   $0x47
  80224a:	68 42 2b 80 00       	push   $0x802b42
  80224f:	e8 fd df ff ff       	call   800251 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802254:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802257:	75 07                	jne    802260 <ipc_send+0x56>
			sys_yield();
  802259:	e8 35 ea ff ff       	call   800c93 <sys_yield>
  80225e:	eb c6                	jmp    802226 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802260:	85 c0                	test   %eax,%eax
  802262:	75 c2                	jne    802226 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    

0080226c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80226c:	55                   	push   %ebp
  80226d:	89 e5                	mov    %esp,%ebp
  80226f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802272:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802277:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  80227d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802283:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802289:	39 ca                	cmp    %ecx,%edx
  80228b:	75 13                	jne    8022a0 <ipc_find_env+0x34>
			return envs[i].env_id;
  80228d:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802293:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802298:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80229e:	eb 0f                	jmp    8022af <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022a0:	83 c0 01             	add    $0x1,%eax
  8022a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022a8:	75 cd                	jne    802277 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022af:	5d                   	pop    %ebp
  8022b0:	c3                   	ret    

008022b1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022b1:	55                   	push   %ebp
  8022b2:	89 e5                	mov    %esp,%ebp
  8022b4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022b7:	89 d0                	mov    %edx,%eax
  8022b9:	c1 e8 16             	shr    $0x16,%eax
  8022bc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022c3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c8:	f6 c1 01             	test   $0x1,%cl
  8022cb:	74 1d                	je     8022ea <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022cd:	c1 ea 0c             	shr    $0xc,%edx
  8022d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022d7:	f6 c2 01             	test   $0x1,%dl
  8022da:	74 0e                	je     8022ea <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022dc:	c1 ea 0c             	shr    $0xc,%edx
  8022df:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022e6:	ef 
  8022e7:	0f b7 c0             	movzwl %ax,%eax
}
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <__udivdi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	57                   	push   %edi
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 1c             	sub    $0x1c,%esp
  8022f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8022fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8022ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802303:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802307:	85 f6                	test   %esi,%esi
  802309:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80230d:	89 ca                	mov    %ecx,%edx
  80230f:	89 f8                	mov    %edi,%eax
  802311:	75 3d                	jne    802350 <__udivdi3+0x60>
  802313:	39 cf                	cmp    %ecx,%edi
  802315:	0f 87 c5 00 00 00    	ja     8023e0 <__udivdi3+0xf0>
  80231b:	85 ff                	test   %edi,%edi
  80231d:	89 fd                	mov    %edi,%ebp
  80231f:	75 0b                	jne    80232c <__udivdi3+0x3c>
  802321:	b8 01 00 00 00       	mov    $0x1,%eax
  802326:	31 d2                	xor    %edx,%edx
  802328:	f7 f7                	div    %edi
  80232a:	89 c5                	mov    %eax,%ebp
  80232c:	89 c8                	mov    %ecx,%eax
  80232e:	31 d2                	xor    %edx,%edx
  802330:	f7 f5                	div    %ebp
  802332:	89 c1                	mov    %eax,%ecx
  802334:	89 d8                	mov    %ebx,%eax
  802336:	89 cf                	mov    %ecx,%edi
  802338:	f7 f5                	div    %ebp
  80233a:	89 c3                	mov    %eax,%ebx
  80233c:	89 d8                	mov    %ebx,%eax
  80233e:	89 fa                	mov    %edi,%edx
  802340:	83 c4 1c             	add    $0x1c,%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	90                   	nop
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	39 ce                	cmp    %ecx,%esi
  802352:	77 74                	ja     8023c8 <__udivdi3+0xd8>
  802354:	0f bd fe             	bsr    %esi,%edi
  802357:	83 f7 1f             	xor    $0x1f,%edi
  80235a:	0f 84 98 00 00 00    	je     8023f8 <__udivdi3+0x108>
  802360:	bb 20 00 00 00       	mov    $0x20,%ebx
  802365:	89 f9                	mov    %edi,%ecx
  802367:	89 c5                	mov    %eax,%ebp
  802369:	29 fb                	sub    %edi,%ebx
  80236b:	d3 e6                	shl    %cl,%esi
  80236d:	89 d9                	mov    %ebx,%ecx
  80236f:	d3 ed                	shr    %cl,%ebp
  802371:	89 f9                	mov    %edi,%ecx
  802373:	d3 e0                	shl    %cl,%eax
  802375:	09 ee                	or     %ebp,%esi
  802377:	89 d9                	mov    %ebx,%ecx
  802379:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80237d:	89 d5                	mov    %edx,%ebp
  80237f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802383:	d3 ed                	shr    %cl,%ebp
  802385:	89 f9                	mov    %edi,%ecx
  802387:	d3 e2                	shl    %cl,%edx
  802389:	89 d9                	mov    %ebx,%ecx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	09 c2                	or     %eax,%edx
  80238f:	89 d0                	mov    %edx,%eax
  802391:	89 ea                	mov    %ebp,%edx
  802393:	f7 f6                	div    %esi
  802395:	89 d5                	mov    %edx,%ebp
  802397:	89 c3                	mov    %eax,%ebx
  802399:	f7 64 24 0c          	mull   0xc(%esp)
  80239d:	39 d5                	cmp    %edx,%ebp
  80239f:	72 10                	jb     8023b1 <__udivdi3+0xc1>
  8023a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023a5:	89 f9                	mov    %edi,%ecx
  8023a7:	d3 e6                	shl    %cl,%esi
  8023a9:	39 c6                	cmp    %eax,%esi
  8023ab:	73 07                	jae    8023b4 <__udivdi3+0xc4>
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	75 03                	jne    8023b4 <__udivdi3+0xc4>
  8023b1:	83 eb 01             	sub    $0x1,%ebx
  8023b4:	31 ff                	xor    %edi,%edi
  8023b6:	89 d8                	mov    %ebx,%eax
  8023b8:	89 fa                	mov    %edi,%edx
  8023ba:	83 c4 1c             	add    $0x1c,%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5f                   	pop    %edi
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    
  8023c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c8:	31 ff                	xor    %edi,%edi
  8023ca:	31 db                	xor    %ebx,%ebx
  8023cc:	89 d8                	mov    %ebx,%eax
  8023ce:	89 fa                	mov    %edi,%edx
  8023d0:	83 c4 1c             	add    $0x1c,%esp
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5f                   	pop    %edi
  8023d6:	5d                   	pop    %ebp
  8023d7:	c3                   	ret    
  8023d8:	90                   	nop
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	89 d8                	mov    %ebx,%eax
  8023e2:	f7 f7                	div    %edi
  8023e4:	31 ff                	xor    %edi,%edi
  8023e6:	89 c3                	mov    %eax,%ebx
  8023e8:	89 d8                	mov    %ebx,%eax
  8023ea:	89 fa                	mov    %edi,%edx
  8023ec:	83 c4 1c             	add    $0x1c,%esp
  8023ef:	5b                   	pop    %ebx
  8023f0:	5e                   	pop    %esi
  8023f1:	5f                   	pop    %edi
  8023f2:	5d                   	pop    %ebp
  8023f3:	c3                   	ret    
  8023f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023f8:	39 ce                	cmp    %ecx,%esi
  8023fa:	72 0c                	jb     802408 <__udivdi3+0x118>
  8023fc:	31 db                	xor    %ebx,%ebx
  8023fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802402:	0f 87 34 ff ff ff    	ja     80233c <__udivdi3+0x4c>
  802408:	bb 01 00 00 00       	mov    $0x1,%ebx
  80240d:	e9 2a ff ff ff       	jmp    80233c <__udivdi3+0x4c>
  802412:	66 90                	xchg   %ax,%ax
  802414:	66 90                	xchg   %ax,%ax
  802416:	66 90                	xchg   %ax,%ax
  802418:	66 90                	xchg   %ax,%ax
  80241a:	66 90                	xchg   %ax,%ax
  80241c:	66 90                	xchg   %ax,%ax
  80241e:	66 90                	xchg   %ax,%ax

00802420 <__umoddi3>:
  802420:	55                   	push   %ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	53                   	push   %ebx
  802424:	83 ec 1c             	sub    $0x1c,%esp
  802427:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80242b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80242f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802433:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802437:	85 d2                	test   %edx,%edx
  802439:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80243d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802441:	89 f3                	mov    %esi,%ebx
  802443:	89 3c 24             	mov    %edi,(%esp)
  802446:	89 74 24 04          	mov    %esi,0x4(%esp)
  80244a:	75 1c                	jne    802468 <__umoddi3+0x48>
  80244c:	39 f7                	cmp    %esi,%edi
  80244e:	76 50                	jbe    8024a0 <__umoddi3+0x80>
  802450:	89 c8                	mov    %ecx,%eax
  802452:	89 f2                	mov    %esi,%edx
  802454:	f7 f7                	div    %edi
  802456:	89 d0                	mov    %edx,%eax
  802458:	31 d2                	xor    %edx,%edx
  80245a:	83 c4 1c             	add    $0x1c,%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5f                   	pop    %edi
  802460:	5d                   	pop    %ebp
  802461:	c3                   	ret    
  802462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802468:	39 f2                	cmp    %esi,%edx
  80246a:	89 d0                	mov    %edx,%eax
  80246c:	77 52                	ja     8024c0 <__umoddi3+0xa0>
  80246e:	0f bd ea             	bsr    %edx,%ebp
  802471:	83 f5 1f             	xor    $0x1f,%ebp
  802474:	75 5a                	jne    8024d0 <__umoddi3+0xb0>
  802476:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80247a:	0f 82 e0 00 00 00    	jb     802560 <__umoddi3+0x140>
  802480:	39 0c 24             	cmp    %ecx,(%esp)
  802483:	0f 86 d7 00 00 00    	jbe    802560 <__umoddi3+0x140>
  802489:	8b 44 24 08          	mov    0x8(%esp),%eax
  80248d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802491:	83 c4 1c             	add    $0x1c,%esp
  802494:	5b                   	pop    %ebx
  802495:	5e                   	pop    %esi
  802496:	5f                   	pop    %edi
  802497:	5d                   	pop    %ebp
  802498:	c3                   	ret    
  802499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	85 ff                	test   %edi,%edi
  8024a2:	89 fd                	mov    %edi,%ebp
  8024a4:	75 0b                	jne    8024b1 <__umoddi3+0x91>
  8024a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ab:	31 d2                	xor    %edx,%edx
  8024ad:	f7 f7                	div    %edi
  8024af:	89 c5                	mov    %eax,%ebp
  8024b1:	89 f0                	mov    %esi,%eax
  8024b3:	31 d2                	xor    %edx,%edx
  8024b5:	f7 f5                	div    %ebp
  8024b7:	89 c8                	mov    %ecx,%eax
  8024b9:	f7 f5                	div    %ebp
  8024bb:	89 d0                	mov    %edx,%eax
  8024bd:	eb 99                	jmp    802458 <__umoddi3+0x38>
  8024bf:	90                   	nop
  8024c0:	89 c8                	mov    %ecx,%eax
  8024c2:	89 f2                	mov    %esi,%edx
  8024c4:	83 c4 1c             	add    $0x1c,%esp
  8024c7:	5b                   	pop    %ebx
  8024c8:	5e                   	pop    %esi
  8024c9:	5f                   	pop    %edi
  8024ca:	5d                   	pop    %ebp
  8024cb:	c3                   	ret    
  8024cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	8b 34 24             	mov    (%esp),%esi
  8024d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024d8:	89 e9                	mov    %ebp,%ecx
  8024da:	29 ef                	sub    %ebp,%edi
  8024dc:	d3 e0                	shl    %cl,%eax
  8024de:	89 f9                	mov    %edi,%ecx
  8024e0:	89 f2                	mov    %esi,%edx
  8024e2:	d3 ea                	shr    %cl,%edx
  8024e4:	89 e9                	mov    %ebp,%ecx
  8024e6:	09 c2                	or     %eax,%edx
  8024e8:	89 d8                	mov    %ebx,%eax
  8024ea:	89 14 24             	mov    %edx,(%esp)
  8024ed:	89 f2                	mov    %esi,%edx
  8024ef:	d3 e2                	shl    %cl,%edx
  8024f1:	89 f9                	mov    %edi,%ecx
  8024f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024fb:	d3 e8                	shr    %cl,%eax
  8024fd:	89 e9                	mov    %ebp,%ecx
  8024ff:	89 c6                	mov    %eax,%esi
  802501:	d3 e3                	shl    %cl,%ebx
  802503:	89 f9                	mov    %edi,%ecx
  802505:	89 d0                	mov    %edx,%eax
  802507:	d3 e8                	shr    %cl,%eax
  802509:	89 e9                	mov    %ebp,%ecx
  80250b:	09 d8                	or     %ebx,%eax
  80250d:	89 d3                	mov    %edx,%ebx
  80250f:	89 f2                	mov    %esi,%edx
  802511:	f7 34 24             	divl   (%esp)
  802514:	89 d6                	mov    %edx,%esi
  802516:	d3 e3                	shl    %cl,%ebx
  802518:	f7 64 24 04          	mull   0x4(%esp)
  80251c:	39 d6                	cmp    %edx,%esi
  80251e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802522:	89 d1                	mov    %edx,%ecx
  802524:	89 c3                	mov    %eax,%ebx
  802526:	72 08                	jb     802530 <__umoddi3+0x110>
  802528:	75 11                	jne    80253b <__umoddi3+0x11b>
  80252a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80252e:	73 0b                	jae    80253b <__umoddi3+0x11b>
  802530:	2b 44 24 04          	sub    0x4(%esp),%eax
  802534:	1b 14 24             	sbb    (%esp),%edx
  802537:	89 d1                	mov    %edx,%ecx
  802539:	89 c3                	mov    %eax,%ebx
  80253b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80253f:	29 da                	sub    %ebx,%edx
  802541:	19 ce                	sbb    %ecx,%esi
  802543:	89 f9                	mov    %edi,%ecx
  802545:	89 f0                	mov    %esi,%eax
  802547:	d3 e0                	shl    %cl,%eax
  802549:	89 e9                	mov    %ebp,%ecx
  80254b:	d3 ea                	shr    %cl,%edx
  80254d:	89 e9                	mov    %ebp,%ecx
  80254f:	d3 ee                	shr    %cl,%esi
  802551:	09 d0                	or     %edx,%eax
  802553:	89 f2                	mov    %esi,%edx
  802555:	83 c4 1c             	add    $0x1c,%esp
  802558:	5b                   	pop    %ebx
  802559:	5e                   	pop    %esi
  80255a:	5f                   	pop    %edi
  80255b:	5d                   	pop    %ebp
  80255c:	c3                   	ret    
  80255d:	8d 76 00             	lea    0x0(%esi),%esi
  802560:	29 f9                	sub    %edi,%ecx
  802562:	19 d6                	sbb    %edx,%esi
  802564:	89 74 24 04          	mov    %esi,0x4(%esp)
  802568:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80256c:	e9 18 ff ff ff       	jmp    802489 <__umoddi3+0x69>
