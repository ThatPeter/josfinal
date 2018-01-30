
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
  80003c:	68 00 26 80 00       	push   $0x802600
  800041:	e8 e4 02 00 00       	call   80032a <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 24 1e 00 00       	call   801e75 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 4e 26 80 00       	push   $0x80264e
  80005e:	6a 0d                	push   $0xd
  800060:	68 57 26 80 00       	push   $0x802657
  800065:	e8 e7 01 00 00       	call   800251 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 6a 0f 00 00       	call   800fd9 <fork>
  80006f:	89 c7                	mov    %eax,%edi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 6c 26 80 00       	push   $0x80266c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 57 26 80 00       	push   $0x802657
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
  800091:	e8 8c 15 00 00       	call   801622 <close>
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
  8000be:	68 75 26 80 00       	push   $0x802675
  8000c3:	e8 62 02 00 00       	call   80032a <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 9a 15 00 00       	call   801672 <dup>
			sys_yield();
  8000d8:	e8 b6 0b 00 00       	call   800c93 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 39 15 00 00       	call   801622 <close>
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
  800109:	69 db d8 00 00 00    	imul   $0xd8,%ebx,%ebx
  80010f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 a6 1e 00 00       	call   801fc8 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 1d                	je     800146 <umain+0x113>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 79 26 80 00       	push   $0x802679
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
  800146:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  80014c:	83 f8 02             	cmp    $0x2,%eax
  80014f:	74 c6                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	68 95 26 80 00       	push   $0x802695
  800159:	e8 cc 01 00 00       	call   80032a <cprintf>
	if (pipeisclosed(p[0]))
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 75 e0             	pushl  -0x20(%ebp)
  800164:	e8 5f 1e 00 00       	call   801fc8 <pipeisclosed>
  800169:	83 c4 10             	add    $0x10,%esp
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 14                	je     800184 <umain+0x151>
		panic("somehow the other end of p[0] got closed!");
  800170:	83 ec 04             	sub    $0x4,%esp
  800173:	68 24 26 80 00       	push   $0x802624
  800178:	6a 40                	push   $0x40
  80017a:	68 57 26 80 00       	push   $0x802657
  80017f:	e8 cd 00 00 00       	call   800251 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800184:	83 ec 08             	sub    $0x8,%esp
  800187:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	ff 75 e0             	pushl  -0x20(%ebp)
  80018e:	e8 62 13 00 00       	call   8014f5 <fd_lookup>
  800193:	83 c4 10             	add    $0x10,%esp
  800196:	85 c0                	test   %eax,%eax
  800198:	79 12                	jns    8001ac <umain+0x179>
		panic("cannot look up p[0]: %e", r);
  80019a:	50                   	push   %eax
  80019b:	68 ab 26 80 00       	push   $0x8026ab
  8001a0:	6a 42                	push   $0x42
  8001a2:	68 57 26 80 00       	push   $0x802657
  8001a7:	e8 a5 00 00 00       	call   800251 <_panic>
	(void) fd2data(fd);
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b2:	e8 d8 12 00 00       	call   80148f <fd2data>
	cprintf("race didn't happen\n");
  8001b7:	c7 04 24 c3 26 80 00 	movl   $0x8026c3,(%esp)
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
  8001e3:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8001e9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ee:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  80023d:	e8 0b 14 00 00       	call   80164d <close_all>
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
  80026f:	68 e4 26 80 00       	push   $0x8026e4
  800274:	e8 b1 00 00 00       	call   80032a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800279:	83 c4 18             	add    $0x18,%esp
  80027c:	53                   	push   %ebx
  80027d:	ff 75 10             	pushl  0x10(%ebp)
  800280:	e8 54 00 00 00       	call   8002d9 <vcprintf>
	cprintf("\n");
  800285:	c7 04 24 c6 2a 80 00 	movl   $0x802ac6,(%esp)
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
  80038d:	e8 de 1f 00 00       	call   802370 <__udivdi3>
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
  8003d0:	e8 cb 20 00 00       	call   8024a0 <__umoddi3>
  8003d5:	83 c4 14             	add    $0x14,%esp
  8003d8:	0f be 80 07 27 80 00 	movsbl 0x802707(%eax),%eax
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
  8004d4:	ff 24 85 40 28 80 00 	jmp    *0x802840(,%eax,4)
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
  800598:	8b 14 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%edx
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	75 18                	jne    8005bb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005a3:	50                   	push   %eax
  8005a4:	68 1f 27 80 00       	push   $0x80271f
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
  8005bc:	68 31 2c 80 00       	push   $0x802c31
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
  8005e0:	b8 18 27 80 00       	mov    $0x802718,%eax
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
  800c5b:	68 ff 29 80 00       	push   $0x8029ff
  800c60:	6a 23                	push   $0x23
  800c62:	68 1c 2a 80 00       	push   $0x802a1c
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
  800cdc:	68 ff 29 80 00       	push   $0x8029ff
  800ce1:	6a 23                	push   $0x23
  800ce3:	68 1c 2a 80 00       	push   $0x802a1c
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
  800d1e:	68 ff 29 80 00       	push   $0x8029ff
  800d23:	6a 23                	push   $0x23
  800d25:	68 1c 2a 80 00       	push   $0x802a1c
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
  800d60:	68 ff 29 80 00       	push   $0x8029ff
  800d65:	6a 23                	push   $0x23
  800d67:	68 1c 2a 80 00       	push   $0x802a1c
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
  800da2:	68 ff 29 80 00       	push   $0x8029ff
  800da7:	6a 23                	push   $0x23
  800da9:	68 1c 2a 80 00       	push   $0x802a1c
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
  800de4:	68 ff 29 80 00       	push   $0x8029ff
  800de9:	6a 23                	push   $0x23
  800deb:	68 1c 2a 80 00       	push   $0x802a1c
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
  800e26:	68 ff 29 80 00       	push   $0x8029ff
  800e2b:	6a 23                	push   $0x23
  800e2d:	68 1c 2a 80 00       	push   $0x802a1c
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
  800e8a:	68 ff 29 80 00       	push   $0x8029ff
  800e8f:	6a 23                	push   $0x23
  800e91:	68 1c 2a 80 00       	push   $0x802a1c
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
  800f29:	68 2a 2a 80 00       	push   $0x802a2a
  800f2e:	6a 1f                	push   $0x1f
  800f30:	68 3a 2a 80 00       	push   $0x802a3a
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
  800f53:	68 45 2a 80 00       	push   $0x802a45
  800f58:	6a 2d                	push   $0x2d
  800f5a:	68 3a 2a 80 00       	push   $0x802a3a
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
  800f9b:	68 45 2a 80 00       	push   $0x802a45
  800fa0:	6a 34                	push   $0x34
  800fa2:	68 3a 2a 80 00       	push   $0x802a3a
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
  800fc3:	68 45 2a 80 00       	push   $0x802a45
  800fc8:	6a 38                	push   $0x38
  800fca:	68 3a 2a 80 00       	push   $0x802a3a
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
  800fe7:	e8 92 11 00 00       	call   80217e <set_pgfault_handler>
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
  801000:	68 5e 2a 80 00       	push   $0x802a5e
  801005:	68 85 00 00 00       	push   $0x85
  80100a:	68 3a 2a 80 00       	push   $0x802a3a
  80100f:	e8 3d f2 ff ff       	call   800251 <_panic>
  801014:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  801016:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80101a:	75 24                	jne    801040 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80101c:	e8 53 fc ff ff       	call   800c74 <sys_getenvid>
  801021:	25 ff 03 00 00       	and    $0x3ff,%eax
  801026:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8010bc:	68 6c 2a 80 00       	push   $0x802a6c
  8010c1:	6a 55                	push   $0x55
  8010c3:	68 3a 2a 80 00       	push   $0x802a3a
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
  801101:	68 6c 2a 80 00       	push   $0x802a6c
  801106:	6a 5c                	push   $0x5c
  801108:	68 3a 2a 80 00       	push   $0x802a3a
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
  80112f:	68 6c 2a 80 00       	push   $0x802a6c
  801134:	6a 60                	push   $0x60
  801136:	68 3a 2a 80 00       	push   $0x802a3a
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
  801159:	68 6c 2a 80 00       	push   $0x802a6c
  80115e:	6a 65                	push   $0x65
  801160:	68 3a 2a 80 00       	push   $0x802a3a
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
  801181:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	56                   	push   %esi
  8011ba:	53                   	push   %ebx
  8011bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8011be:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	53                   	push   %ebx
  8011c8:	68 fc 2a 80 00       	push   $0x802afc
  8011cd:	e8 58 f1 ff ff       	call   80032a <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011d2:	c7 04 24 17 02 80 00 	movl   $0x800217,(%esp)
  8011d9:	e8 c5 fc ff ff       	call   800ea3 <sys_thread_create>
  8011de:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011e0:	83 c4 08             	add    $0x8,%esp
  8011e3:	53                   	push   %ebx
  8011e4:	68 fc 2a 80 00       	push   $0x802afc
  8011e9:	e8 3c f1 ff ff       	call   80032a <cprintf>
	return id;
}
  8011ee:	89 f0                	mov    %esi,%eax
  8011f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8011fd:	ff 75 08             	pushl  0x8(%ebp)
  801200:	e8 be fc ff ff       	call   800ec3 <sys_thread_free>
}
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	c9                   	leave  
  801209:	c3                   	ret    

0080120a <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801210:	ff 75 08             	pushl  0x8(%ebp)
  801213:	e8 cb fc ff ff       	call   800ee3 <sys_thread_join>
}
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	56                   	push   %esi
  801221:	53                   	push   %ebx
  801222:	8b 75 08             	mov    0x8(%ebp),%esi
  801225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	6a 07                	push   $0x7
  80122d:	6a 00                	push   $0x0
  80122f:	56                   	push   %esi
  801230:	e8 7d fa ff ff       	call   800cb2 <sys_page_alloc>
	if (r < 0) {
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	79 15                	jns    801251 <queue_append+0x34>
		panic("%e\n", r);
  80123c:	50                   	push   %eax
  80123d:	68 f8 2a 80 00       	push   $0x802af8
  801242:	68 c4 00 00 00       	push   $0xc4
  801247:	68 3a 2a 80 00       	push   $0x802a3a
  80124c:	e8 00 f0 ff ff       	call   800251 <_panic>
	}	
	wt->envid = envid;
  801251:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  801257:	83 ec 04             	sub    $0x4,%esp
  80125a:	ff 33                	pushl  (%ebx)
  80125c:	56                   	push   %esi
  80125d:	68 20 2b 80 00       	push   $0x802b20
  801262:	e8 c3 f0 ff ff       	call   80032a <cprintf>
	if (queue->first == NULL) {
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	83 3b 00             	cmpl   $0x0,(%ebx)
  80126d:	75 29                	jne    801298 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80126f:	83 ec 0c             	sub    $0xc,%esp
  801272:	68 82 2a 80 00       	push   $0x802a82
  801277:	e8 ae f0 ff ff       	call   80032a <cprintf>
		queue->first = wt;
  80127c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  801282:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  801289:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  801290:	00 00 00 
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	eb 2b                	jmp    8012c3 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	68 9c 2a 80 00       	push   $0x802a9c
  8012a0:	e8 85 f0 ff ff       	call   80032a <cprintf>
		queue->last->next = wt;
  8012a5:	8b 43 04             	mov    0x4(%ebx),%eax
  8012a8:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8012af:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8012b6:	00 00 00 
		queue->last = wt;
  8012b9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8012c0:	83 c4 10             	add    $0x10,%esp
	}
}
  8012c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c6:	5b                   	pop    %ebx
  8012c7:	5e                   	pop    %esi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 04             	sub    $0x4,%esp
  8012d1:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8012d4:	8b 02                	mov    (%edx),%eax
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	75 17                	jne    8012f1 <queue_pop+0x27>
		panic("queue empty!\n");
  8012da:	83 ec 04             	sub    $0x4,%esp
  8012dd:	68 ba 2a 80 00       	push   $0x802aba
  8012e2:	68 d8 00 00 00       	push   $0xd8
  8012e7:	68 3a 2a 80 00       	push   $0x802a3a
  8012ec:	e8 60 ef ff ff       	call   800251 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8012f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8012f4:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8012f6:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	53                   	push   %ebx
  8012fc:	68 c8 2a 80 00       	push   $0x802ac8
  801301:	e8 24 f0 ff ff       	call   80032a <cprintf>
	return envid;
}
  801306:	89 d8                	mov    %ebx,%eax
  801308:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    

0080130d <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	53                   	push   %ebx
  801311:	83 ec 04             	sub    $0x4,%esp
  801314:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  801317:	b8 01 00 00 00       	mov    $0x1,%eax
  80131c:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80131f:	85 c0                	test   %eax,%eax
  801321:	74 5a                	je     80137d <mutex_lock+0x70>
  801323:	8b 43 04             	mov    0x4(%ebx),%eax
  801326:	83 38 00             	cmpl   $0x0,(%eax)
  801329:	75 52                	jne    80137d <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  80132b:	83 ec 0c             	sub    $0xc,%esp
  80132e:	68 48 2b 80 00       	push   $0x802b48
  801333:	e8 f2 ef ff ff       	call   80032a <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801338:	8b 5b 04             	mov    0x4(%ebx),%ebx
  80133b:	e8 34 f9 ff ff       	call   800c74 <sys_getenvid>
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	53                   	push   %ebx
  801344:	50                   	push   %eax
  801345:	e8 d3 fe ff ff       	call   80121d <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80134a:	e8 25 f9 ff ff       	call   800c74 <sys_getenvid>
  80134f:	83 c4 08             	add    $0x8,%esp
  801352:	6a 04                	push   $0x4
  801354:	50                   	push   %eax
  801355:	e8 1f fa ff ff       	call   800d79 <sys_env_set_status>
		if (r < 0) {
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	79 15                	jns    801376 <mutex_lock+0x69>
			panic("%e\n", r);
  801361:	50                   	push   %eax
  801362:	68 f8 2a 80 00       	push   $0x802af8
  801367:	68 eb 00 00 00       	push   $0xeb
  80136c:	68 3a 2a 80 00       	push   $0x802a3a
  801371:	e8 db ee ff ff       	call   800251 <_panic>
		}
		sys_yield();
  801376:	e8 18 f9 ff ff       	call   800c93 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80137b:	eb 18                	jmp    801395 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	68 68 2b 80 00       	push   $0x802b68
  801385:	e8 a0 ef ff ff       	call   80032a <cprintf>
	mtx->owner = sys_getenvid();}
  80138a:	e8 e5 f8 ff ff       	call   800c74 <sys_getenvid>
  80138f:	89 43 08             	mov    %eax,0x8(%ebx)
  801392:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  801395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	53                   	push   %ebx
  80139e:	83 ec 04             	sub    $0x4,%esp
  8013a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a9:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8013ac:	8b 43 04             	mov    0x4(%ebx),%eax
  8013af:	83 38 00             	cmpl   $0x0,(%eax)
  8013b2:	74 33                	je     8013e7 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8013b4:	83 ec 0c             	sub    $0xc,%esp
  8013b7:	50                   	push   %eax
  8013b8:	e8 0d ff ff ff       	call   8012ca <queue_pop>
  8013bd:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	6a 02                	push   $0x2
  8013c5:	50                   	push   %eax
  8013c6:	e8 ae f9 ff ff       	call   800d79 <sys_env_set_status>
		if (r < 0) {
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	79 15                	jns    8013e7 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8013d2:	50                   	push   %eax
  8013d3:	68 f8 2a 80 00       	push   $0x802af8
  8013d8:	68 00 01 00 00       	push   $0x100
  8013dd:	68 3a 2a 80 00       	push   $0x802a3a
  8013e2:	e8 6a ee ff ff       	call   800251 <_panic>
		}
	}

	asm volatile("pause");
  8013e7:	f3 90                	pause  
	//sys_yield();
}
  8013e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	53                   	push   %ebx
  8013f2:	83 ec 04             	sub    $0x4,%esp
  8013f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8013f8:	e8 77 f8 ff ff       	call   800c74 <sys_getenvid>
  8013fd:	83 ec 04             	sub    $0x4,%esp
  801400:	6a 07                	push   $0x7
  801402:	53                   	push   %ebx
  801403:	50                   	push   %eax
  801404:	e8 a9 f8 ff ff       	call   800cb2 <sys_page_alloc>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	79 15                	jns    801425 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801410:	50                   	push   %eax
  801411:	68 e3 2a 80 00       	push   $0x802ae3
  801416:	68 0d 01 00 00       	push   $0x10d
  80141b:	68 3a 2a 80 00       	push   $0x802a3a
  801420:	e8 2c ee ff ff       	call   800251 <_panic>
	}	
	mtx->locked = 0;
  801425:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80142b:	8b 43 04             	mov    0x4(%ebx),%eax
  80142e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  801434:	8b 43 04             	mov    0x4(%ebx),%eax
  801437:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80143e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  801445:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  801450:	e8 1f f8 ff ff       	call   800c74 <sys_getenvid>
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	ff 75 08             	pushl  0x8(%ebp)
  80145b:	50                   	push   %eax
  80145c:	e8 d6 f8 ff ff       	call   800d37 <sys_page_unmap>
	if (r < 0) {
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	79 15                	jns    80147d <mutex_destroy+0x33>
		panic("%e\n", r);
  801468:	50                   	push   %eax
  801469:	68 f8 2a 80 00       	push   $0x802af8
  80146e:	68 1a 01 00 00       	push   $0x11a
  801473:	68 3a 2a 80 00       	push   $0x802a3a
  801478:	e8 d4 ed ff ff       	call   800251 <_panic>
	}
}
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	05 00 00 00 30       	add    $0x30000000,%eax
  80148a:	c1 e8 0c             	shr    $0xc,%eax
}
  80148d:	5d                   	pop    %ebp
  80148e:	c3                   	ret    

0080148f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	05 00 00 00 30       	add    $0x30000000,%eax
  80149a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80149f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ac:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	c1 ea 16             	shr    $0x16,%edx
  8014b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014bd:	f6 c2 01             	test   $0x1,%dl
  8014c0:	74 11                	je     8014d3 <fd_alloc+0x2d>
  8014c2:	89 c2                	mov    %eax,%edx
  8014c4:	c1 ea 0c             	shr    $0xc,%edx
  8014c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ce:	f6 c2 01             	test   $0x1,%dl
  8014d1:	75 09                	jne    8014dc <fd_alloc+0x36>
			*fd_store = fd;
  8014d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014da:	eb 17                	jmp    8014f3 <fd_alloc+0x4d>
  8014dc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014e1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014e6:	75 c9                	jne    8014b1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014e8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014ee:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    

008014f5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014fb:	83 f8 1f             	cmp    $0x1f,%eax
  8014fe:	77 36                	ja     801536 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801500:	c1 e0 0c             	shl    $0xc,%eax
  801503:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801508:	89 c2                	mov    %eax,%edx
  80150a:	c1 ea 16             	shr    $0x16,%edx
  80150d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801514:	f6 c2 01             	test   $0x1,%dl
  801517:	74 24                	je     80153d <fd_lookup+0x48>
  801519:	89 c2                	mov    %eax,%edx
  80151b:	c1 ea 0c             	shr    $0xc,%edx
  80151e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801525:	f6 c2 01             	test   $0x1,%dl
  801528:	74 1a                	je     801544 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80152a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152d:	89 02                	mov    %eax,(%edx)
	return 0;
  80152f:	b8 00 00 00 00       	mov    $0x0,%eax
  801534:	eb 13                	jmp    801549 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801536:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153b:	eb 0c                	jmp    801549 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80153d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801542:	eb 05                	jmp    801549 <fd_lookup+0x54>
  801544:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801554:	ba 08 2c 80 00       	mov    $0x802c08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801559:	eb 13                	jmp    80156e <dev_lookup+0x23>
  80155b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80155e:	39 08                	cmp    %ecx,(%eax)
  801560:	75 0c                	jne    80156e <dev_lookup+0x23>
			*dev = devtab[i];
  801562:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801565:	89 01                	mov    %eax,(%ecx)
			return 0;
  801567:	b8 00 00 00 00       	mov    $0x0,%eax
  80156c:	eb 31                	jmp    80159f <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80156e:	8b 02                	mov    (%edx),%eax
  801570:	85 c0                	test   %eax,%eax
  801572:	75 e7                	jne    80155b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801574:	a1 04 40 80 00       	mov    0x804004,%eax
  801579:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	51                   	push   %ecx
  801583:	50                   	push   %eax
  801584:	68 88 2b 80 00       	push   $0x802b88
  801589:	e8 9c ed ff ff       	call   80032a <cprintf>
	*dev = 0;
  80158e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801591:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 10             	sub    $0x10,%esp
  8015a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015b9:	c1 e8 0c             	shr    $0xc,%eax
  8015bc:	50                   	push   %eax
  8015bd:	e8 33 ff ff ff       	call   8014f5 <fd_lookup>
  8015c2:	83 c4 08             	add    $0x8,%esp
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 05                	js     8015ce <fd_close+0x2d>
	    || fd != fd2)
  8015c9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015cc:	74 0c                	je     8015da <fd_close+0x39>
		return (must_exist ? r : 0);
  8015ce:	84 db                	test   %bl,%bl
  8015d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d5:	0f 44 c2             	cmove  %edx,%eax
  8015d8:	eb 41                	jmp    80161b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	ff 36                	pushl  (%esi)
  8015e3:	e8 63 ff ff ff       	call   80154b <dev_lookup>
  8015e8:	89 c3                	mov    %eax,%ebx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 1a                	js     80160b <fd_close+0x6a>
		if (dev->dev_close)
  8015f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	74 0b                	je     80160b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801600:	83 ec 0c             	sub    $0xc,%esp
  801603:	56                   	push   %esi
  801604:	ff d0                	call   *%eax
  801606:	89 c3                	mov    %eax,%ebx
  801608:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	56                   	push   %esi
  80160f:	6a 00                	push   $0x0
  801611:	e8 21 f7 ff ff       	call   800d37 <sys_page_unmap>
	return r;
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	89 d8                	mov    %ebx,%eax
}
  80161b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161e:	5b                   	pop    %ebx
  80161f:	5e                   	pop    %esi
  801620:	5d                   	pop    %ebp
  801621:	c3                   	ret    

00801622 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	ff 75 08             	pushl  0x8(%ebp)
  80162f:	e8 c1 fe ff ff       	call   8014f5 <fd_lookup>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 10                	js     80164b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	6a 01                	push   $0x1
  801640:	ff 75 f4             	pushl  -0xc(%ebp)
  801643:	e8 59 ff ff ff       	call   8015a1 <fd_close>
  801648:	83 c4 10             	add    $0x10,%esp
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <close_all>:

void
close_all(void)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	53                   	push   %ebx
  801651:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801654:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801659:	83 ec 0c             	sub    $0xc,%esp
  80165c:	53                   	push   %ebx
  80165d:	e8 c0 ff ff ff       	call   801622 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801662:	83 c3 01             	add    $0x1,%ebx
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	83 fb 20             	cmp    $0x20,%ebx
  80166b:	75 ec                	jne    801659 <close_all+0xc>
		close(i);
}
  80166d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	57                   	push   %edi
  801676:	56                   	push   %esi
  801677:	53                   	push   %ebx
  801678:	83 ec 2c             	sub    $0x2c,%esp
  80167b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80167e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	ff 75 08             	pushl  0x8(%ebp)
  801685:	e8 6b fe ff ff       	call   8014f5 <fd_lookup>
  80168a:	83 c4 08             	add    $0x8,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	0f 88 c1 00 00 00    	js     801756 <dup+0xe4>
		return r;
	close(newfdnum);
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	56                   	push   %esi
  801699:	e8 84 ff ff ff       	call   801622 <close>

	newfd = INDEX2FD(newfdnum);
  80169e:	89 f3                	mov    %esi,%ebx
  8016a0:	c1 e3 0c             	shl    $0xc,%ebx
  8016a3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016a9:	83 c4 04             	add    $0x4,%esp
  8016ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016af:	e8 db fd ff ff       	call   80148f <fd2data>
  8016b4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016b6:	89 1c 24             	mov    %ebx,(%esp)
  8016b9:	e8 d1 fd ff ff       	call   80148f <fd2data>
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016c4:	89 f8                	mov    %edi,%eax
  8016c6:	c1 e8 16             	shr    $0x16,%eax
  8016c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016d0:	a8 01                	test   $0x1,%al
  8016d2:	74 37                	je     80170b <dup+0x99>
  8016d4:	89 f8                	mov    %edi,%eax
  8016d6:	c1 e8 0c             	shr    $0xc,%eax
  8016d9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016e0:	f6 c2 01             	test   $0x1,%dl
  8016e3:	74 26                	je     80170b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ec:	83 ec 0c             	sub    $0xc,%esp
  8016ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f4:	50                   	push   %eax
  8016f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016f8:	6a 00                	push   $0x0
  8016fa:	57                   	push   %edi
  8016fb:	6a 00                	push   $0x0
  8016fd:	e8 f3 f5 ff ff       	call   800cf5 <sys_page_map>
  801702:	89 c7                	mov    %eax,%edi
  801704:	83 c4 20             	add    $0x20,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 2e                	js     801739 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80170b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80170e:	89 d0                	mov    %edx,%eax
  801710:	c1 e8 0c             	shr    $0xc,%eax
  801713:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	25 07 0e 00 00       	and    $0xe07,%eax
  801722:	50                   	push   %eax
  801723:	53                   	push   %ebx
  801724:	6a 00                	push   $0x0
  801726:	52                   	push   %edx
  801727:	6a 00                	push   $0x0
  801729:	e8 c7 f5 ff ff       	call   800cf5 <sys_page_map>
  80172e:	89 c7                	mov    %eax,%edi
  801730:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801733:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801735:	85 ff                	test   %edi,%edi
  801737:	79 1d                	jns    801756 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801739:	83 ec 08             	sub    $0x8,%esp
  80173c:	53                   	push   %ebx
  80173d:	6a 00                	push   $0x0
  80173f:	e8 f3 f5 ff ff       	call   800d37 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801744:	83 c4 08             	add    $0x8,%esp
  801747:	ff 75 d4             	pushl  -0x2c(%ebp)
  80174a:	6a 00                	push   $0x0
  80174c:	e8 e6 f5 ff ff       	call   800d37 <sys_page_unmap>
	return r;
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	89 f8                	mov    %edi,%eax
}
  801756:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5f                   	pop    %edi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	53                   	push   %ebx
  801762:	83 ec 14             	sub    $0x14,%esp
  801765:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801768:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	53                   	push   %ebx
  80176d:	e8 83 fd ff ff       	call   8014f5 <fd_lookup>
  801772:	83 c4 08             	add    $0x8,%esp
  801775:	89 c2                	mov    %eax,%edx
  801777:	85 c0                	test   %eax,%eax
  801779:	78 70                	js     8017eb <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801781:	50                   	push   %eax
  801782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801785:	ff 30                	pushl  (%eax)
  801787:	e8 bf fd ff ff       	call   80154b <dev_lookup>
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 4f                	js     8017e2 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801793:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801796:	8b 42 08             	mov    0x8(%edx),%eax
  801799:	83 e0 03             	and    $0x3,%eax
  80179c:	83 f8 01             	cmp    $0x1,%eax
  80179f:	75 24                	jne    8017c5 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017a6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8017ac:	83 ec 04             	sub    $0x4,%esp
  8017af:	53                   	push   %ebx
  8017b0:	50                   	push   %eax
  8017b1:	68 cc 2b 80 00       	push   $0x802bcc
  8017b6:	e8 6f eb ff ff       	call   80032a <cprintf>
		return -E_INVAL;
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017c3:	eb 26                	jmp    8017eb <read+0x8d>
	}
	if (!dev->dev_read)
  8017c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c8:	8b 40 08             	mov    0x8(%eax),%eax
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	74 17                	je     8017e6 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8017cf:	83 ec 04             	sub    $0x4,%esp
  8017d2:	ff 75 10             	pushl  0x10(%ebp)
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	52                   	push   %edx
  8017d9:	ff d0                	call   *%eax
  8017db:	89 c2                	mov    %eax,%edx
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	eb 09                	jmp    8017eb <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e2:	89 c2                	mov    %eax,%edx
  8017e4:	eb 05                	jmp    8017eb <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8017eb:	89 d0                	mov    %edx,%eax
  8017ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	57                   	push   %edi
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 0c             	sub    $0xc,%esp
  8017fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801801:	bb 00 00 00 00       	mov    $0x0,%ebx
  801806:	eb 21                	jmp    801829 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801808:	83 ec 04             	sub    $0x4,%esp
  80180b:	89 f0                	mov    %esi,%eax
  80180d:	29 d8                	sub    %ebx,%eax
  80180f:	50                   	push   %eax
  801810:	89 d8                	mov    %ebx,%eax
  801812:	03 45 0c             	add    0xc(%ebp),%eax
  801815:	50                   	push   %eax
  801816:	57                   	push   %edi
  801817:	e8 42 ff ff ff       	call   80175e <read>
		if (m < 0)
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	85 c0                	test   %eax,%eax
  801821:	78 10                	js     801833 <readn+0x41>
			return m;
		if (m == 0)
  801823:	85 c0                	test   %eax,%eax
  801825:	74 0a                	je     801831 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801827:	01 c3                	add    %eax,%ebx
  801829:	39 f3                	cmp    %esi,%ebx
  80182b:	72 db                	jb     801808 <readn+0x16>
  80182d:	89 d8                	mov    %ebx,%eax
  80182f:	eb 02                	jmp    801833 <readn+0x41>
  801831:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801833:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5f                   	pop    %edi
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    

0080183b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	53                   	push   %ebx
  80183f:	83 ec 14             	sub    $0x14,%esp
  801842:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801848:	50                   	push   %eax
  801849:	53                   	push   %ebx
  80184a:	e8 a6 fc ff ff       	call   8014f5 <fd_lookup>
  80184f:	83 c4 08             	add    $0x8,%esp
  801852:	89 c2                	mov    %eax,%edx
  801854:	85 c0                	test   %eax,%eax
  801856:	78 6b                	js     8018c3 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185e:	50                   	push   %eax
  80185f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801862:	ff 30                	pushl  (%eax)
  801864:	e8 e2 fc ff ff       	call   80154b <dev_lookup>
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 4a                	js     8018ba <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801870:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801873:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801877:	75 24                	jne    80189d <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801879:	a1 04 40 80 00       	mov    0x804004,%eax
  80187e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801884:	83 ec 04             	sub    $0x4,%esp
  801887:	53                   	push   %ebx
  801888:	50                   	push   %eax
  801889:	68 e8 2b 80 00       	push   $0x802be8
  80188e:	e8 97 ea ff ff       	call   80032a <cprintf>
		return -E_INVAL;
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80189b:	eb 26                	jmp    8018c3 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80189d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a0:	8b 52 0c             	mov    0xc(%edx),%edx
  8018a3:	85 d2                	test   %edx,%edx
  8018a5:	74 17                	je     8018be <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018a7:	83 ec 04             	sub    $0x4,%esp
  8018aa:	ff 75 10             	pushl  0x10(%ebp)
  8018ad:	ff 75 0c             	pushl  0xc(%ebp)
  8018b0:	50                   	push   %eax
  8018b1:	ff d2                	call   *%edx
  8018b3:	89 c2                	mov    %eax,%edx
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	eb 09                	jmp    8018c3 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ba:	89 c2                	mov    %eax,%edx
  8018bc:	eb 05                	jmp    8018c3 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018c3:	89 d0                	mov    %edx,%eax
  8018c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018d3:	50                   	push   %eax
  8018d4:	ff 75 08             	pushl  0x8(%ebp)
  8018d7:	e8 19 fc ff ff       	call   8014f5 <fd_lookup>
  8018dc:	83 c4 08             	add    $0x8,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 0e                	js     8018f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 14             	sub    $0x14,%esp
  8018fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	53                   	push   %ebx
  801902:	e8 ee fb ff ff       	call   8014f5 <fd_lookup>
  801907:	83 c4 08             	add    $0x8,%esp
  80190a:	89 c2                	mov    %eax,%edx
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 68                	js     801978 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801916:	50                   	push   %eax
  801917:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191a:	ff 30                	pushl  (%eax)
  80191c:	e8 2a fc ff ff       	call   80154b <dev_lookup>
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	85 c0                	test   %eax,%eax
  801926:	78 47                	js     80196f <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801928:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80192f:	75 24                	jne    801955 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801931:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801936:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80193c:	83 ec 04             	sub    $0x4,%esp
  80193f:	53                   	push   %ebx
  801940:	50                   	push   %eax
  801941:	68 a8 2b 80 00       	push   $0x802ba8
  801946:	e8 df e9 ff ff       	call   80032a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801953:	eb 23                	jmp    801978 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801955:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801958:	8b 52 18             	mov    0x18(%edx),%edx
  80195b:	85 d2                	test   %edx,%edx
  80195d:	74 14                	je     801973 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	ff 75 0c             	pushl  0xc(%ebp)
  801965:	50                   	push   %eax
  801966:	ff d2                	call   *%edx
  801968:	89 c2                	mov    %eax,%edx
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	eb 09                	jmp    801978 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196f:	89 c2                	mov    %eax,%edx
  801971:	eb 05                	jmp    801978 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801973:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801978:	89 d0                	mov    %edx,%eax
  80197a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197d:	c9                   	leave  
  80197e:	c3                   	ret    

0080197f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	53                   	push   %ebx
  801983:	83 ec 14             	sub    $0x14,%esp
  801986:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801989:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	ff 75 08             	pushl  0x8(%ebp)
  801990:	e8 60 fb ff ff       	call   8014f5 <fd_lookup>
  801995:	83 c4 08             	add    $0x8,%esp
  801998:	89 c2                	mov    %eax,%edx
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 58                	js     8019f6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a4:	50                   	push   %eax
  8019a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a8:	ff 30                	pushl  (%eax)
  8019aa:	e8 9c fb ff ff       	call   80154b <dev_lookup>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	78 37                	js     8019ed <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019bd:	74 32                	je     8019f1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019bf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019c2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019c9:	00 00 00 
	stat->st_isdir = 0;
  8019cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d3:	00 00 00 
	stat->st_dev = dev;
  8019d6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019dc:	83 ec 08             	sub    $0x8,%esp
  8019df:	53                   	push   %ebx
  8019e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019e3:	ff 50 14             	call   *0x14(%eax)
  8019e6:	89 c2                	mov    %eax,%edx
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	eb 09                	jmp    8019f6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ed:	89 c2                	mov    %eax,%edx
  8019ef:	eb 05                	jmp    8019f6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019f6:	89 d0                	mov    %edx,%eax
  8019f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    

008019fd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	56                   	push   %esi
  801a01:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a02:	83 ec 08             	sub    $0x8,%esp
  801a05:	6a 00                	push   $0x0
  801a07:	ff 75 08             	pushl  0x8(%ebp)
  801a0a:	e8 e3 01 00 00       	call   801bf2 <open>
  801a0f:	89 c3                	mov    %eax,%ebx
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 1b                	js     801a33 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a18:	83 ec 08             	sub    $0x8,%esp
  801a1b:	ff 75 0c             	pushl  0xc(%ebp)
  801a1e:	50                   	push   %eax
  801a1f:	e8 5b ff ff ff       	call   80197f <fstat>
  801a24:	89 c6                	mov    %eax,%esi
	close(fd);
  801a26:	89 1c 24             	mov    %ebx,(%esp)
  801a29:	e8 f4 fb ff ff       	call   801622 <close>
	return r;
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	89 f0                	mov    %esi,%eax
}
  801a33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a36:	5b                   	pop    %ebx
  801a37:	5e                   	pop    %esi
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    

00801a3a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	56                   	push   %esi
  801a3e:	53                   	push   %ebx
  801a3f:	89 c6                	mov    %eax,%esi
  801a41:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a43:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a4a:	75 12                	jne    801a5e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	6a 01                	push   $0x1
  801a51:	e8 94 08 00 00       	call   8022ea <ipc_find_env>
  801a56:	a3 00 40 80 00       	mov    %eax,0x804000
  801a5b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a5e:	6a 07                	push   $0x7
  801a60:	68 00 50 80 00       	push   $0x805000
  801a65:	56                   	push   %esi
  801a66:	ff 35 00 40 80 00    	pushl  0x804000
  801a6c:	e8 17 08 00 00       	call   802288 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a71:	83 c4 0c             	add    $0xc,%esp
  801a74:	6a 00                	push   $0x0
  801a76:	53                   	push   %ebx
  801a77:	6a 00                	push   $0x0
  801a79:	e8 8f 07 00 00       	call   80220d <ipc_recv>
}
  801a7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a81:	5b                   	pop    %ebx
  801a82:	5e                   	pop    %esi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a91:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a99:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a9e:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa3:	b8 02 00 00 00       	mov    $0x2,%eax
  801aa8:	e8 8d ff ff ff       	call   801a3a <fsipc>
}
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab8:	8b 40 0c             	mov    0xc(%eax),%eax
  801abb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac5:	b8 06 00 00 00       	mov    $0x6,%eax
  801aca:	e8 6b ff ff ff       	call   801a3a <fsipc>
}
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 04             	sub    $0x4,%esp
  801ad8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801adb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ade:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  801aeb:	b8 05 00 00 00       	mov    $0x5,%eax
  801af0:	e8 45 ff ff ff       	call   801a3a <fsipc>
  801af5:	85 c0                	test   %eax,%eax
  801af7:	78 2c                	js     801b25 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801af9:	83 ec 08             	sub    $0x8,%esp
  801afc:	68 00 50 80 00       	push   $0x805000
  801b01:	53                   	push   %ebx
  801b02:	e8 a8 ed ff ff       	call   8008af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b07:	a1 80 50 80 00       	mov    0x805080,%eax
  801b0c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b12:	a1 84 50 80 00       	mov    0x805084,%eax
  801b17:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    

00801b2a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b33:	8b 55 08             	mov    0x8(%ebp),%edx
  801b36:	8b 52 0c             	mov    0xc(%edx),%edx
  801b39:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b3f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b44:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b49:	0f 47 c2             	cmova  %edx,%eax
  801b4c:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b51:	50                   	push   %eax
  801b52:	ff 75 0c             	pushl  0xc(%ebp)
  801b55:	68 08 50 80 00       	push   $0x805008
  801b5a:	e8 e2 ee ff ff       	call   800a41 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b64:	b8 04 00 00 00       	mov    $0x4,%eax
  801b69:	e8 cc fe ff ff       	call   801a3a <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801b6e:	c9                   	leave  
  801b6f:	c3                   	ret    

00801b70 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	56                   	push   %esi
  801b74:	53                   	push   %ebx
  801b75:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b83:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b89:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8e:	b8 03 00 00 00       	mov    $0x3,%eax
  801b93:	e8 a2 fe ff ff       	call   801a3a <fsipc>
  801b98:	89 c3                	mov    %eax,%ebx
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 4b                	js     801be9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b9e:	39 c6                	cmp    %eax,%esi
  801ba0:	73 16                	jae    801bb8 <devfile_read+0x48>
  801ba2:	68 18 2c 80 00       	push   $0x802c18
  801ba7:	68 1f 2c 80 00       	push   $0x802c1f
  801bac:	6a 7c                	push   $0x7c
  801bae:	68 34 2c 80 00       	push   $0x802c34
  801bb3:	e8 99 e6 ff ff       	call   800251 <_panic>
	assert(r <= PGSIZE);
  801bb8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bbd:	7e 16                	jle    801bd5 <devfile_read+0x65>
  801bbf:	68 3f 2c 80 00       	push   $0x802c3f
  801bc4:	68 1f 2c 80 00       	push   $0x802c1f
  801bc9:	6a 7d                	push   $0x7d
  801bcb:	68 34 2c 80 00       	push   $0x802c34
  801bd0:	e8 7c e6 ff ff       	call   800251 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bd5:	83 ec 04             	sub    $0x4,%esp
  801bd8:	50                   	push   %eax
  801bd9:	68 00 50 80 00       	push   $0x805000
  801bde:	ff 75 0c             	pushl  0xc(%ebp)
  801be1:	e8 5b ee ff ff       	call   800a41 <memmove>
	return r;
  801be6:	83 c4 10             	add    $0x10,%esp
}
  801be9:	89 d8                	mov    %ebx,%eax
  801beb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	53                   	push   %ebx
  801bf6:	83 ec 20             	sub    $0x20,%esp
  801bf9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bfc:	53                   	push   %ebx
  801bfd:	e8 74 ec ff ff       	call   800876 <strlen>
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c0a:	7f 67                	jg     801c73 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c12:	50                   	push   %eax
  801c13:	e8 8e f8 ff ff       	call   8014a6 <fd_alloc>
  801c18:	83 c4 10             	add    $0x10,%esp
		return r;
  801c1b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 57                	js     801c78 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c21:	83 ec 08             	sub    $0x8,%esp
  801c24:	53                   	push   %ebx
  801c25:	68 00 50 80 00       	push   $0x805000
  801c2a:	e8 80 ec ff ff       	call   8008af <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c32:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c37:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c3a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3f:	e8 f6 fd ff ff       	call   801a3a <fsipc>
  801c44:	89 c3                	mov    %eax,%ebx
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	79 14                	jns    801c61 <open+0x6f>
		fd_close(fd, 0);
  801c4d:	83 ec 08             	sub    $0x8,%esp
  801c50:	6a 00                	push   $0x0
  801c52:	ff 75 f4             	pushl  -0xc(%ebp)
  801c55:	e8 47 f9 ff ff       	call   8015a1 <fd_close>
		return r;
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	89 da                	mov    %ebx,%edx
  801c5f:	eb 17                	jmp    801c78 <open+0x86>
	}

	return fd2num(fd);
  801c61:	83 ec 0c             	sub    $0xc,%esp
  801c64:	ff 75 f4             	pushl  -0xc(%ebp)
  801c67:	e8 13 f8 ff ff       	call   80147f <fd2num>
  801c6c:	89 c2                	mov    %eax,%edx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	eb 05                	jmp    801c78 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c73:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c78:	89 d0                	mov    %edx,%eax
  801c7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    

00801c7f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c85:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8a:	b8 08 00 00 00       	mov    $0x8,%eax
  801c8f:	e8 a6 fd ff ff       	call   801a3a <fsipc>
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	56                   	push   %esi
  801c9a:	53                   	push   %ebx
  801c9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c9e:	83 ec 0c             	sub    $0xc,%esp
  801ca1:	ff 75 08             	pushl  0x8(%ebp)
  801ca4:	e8 e6 f7 ff ff       	call   80148f <fd2data>
  801ca9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cab:	83 c4 08             	add    $0x8,%esp
  801cae:	68 4b 2c 80 00       	push   $0x802c4b
  801cb3:	53                   	push   %ebx
  801cb4:	e8 f6 eb ff ff       	call   8008af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cb9:	8b 46 04             	mov    0x4(%esi),%eax
  801cbc:	2b 06                	sub    (%esi),%eax
  801cbe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cc4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ccb:	00 00 00 
	stat->st_dev = &devpipe;
  801cce:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801cd5:	30 80 00 
	return 0;
}
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cee:	53                   	push   %ebx
  801cef:	6a 00                	push   $0x0
  801cf1:	e8 41 f0 ff ff       	call   800d37 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cf6:	89 1c 24             	mov    %ebx,(%esp)
  801cf9:	e8 91 f7 ff ff       	call   80148f <fd2data>
  801cfe:	83 c4 08             	add    $0x8,%esp
  801d01:	50                   	push   %eax
  801d02:	6a 00                	push   $0x0
  801d04:	e8 2e f0 ff ff       	call   800d37 <sys_page_unmap>
}
  801d09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 1c             	sub    $0x1c,%esp
  801d17:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d1a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801d21:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d27:	83 ec 0c             	sub    $0xc,%esp
  801d2a:	ff 75 e0             	pushl  -0x20(%ebp)
  801d2d:	e8 fd 05 00 00       	call   80232f <pageref>
  801d32:	89 c3                	mov    %eax,%ebx
  801d34:	89 3c 24             	mov    %edi,(%esp)
  801d37:	e8 f3 05 00 00       	call   80232f <pageref>
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	39 c3                	cmp    %eax,%ebx
  801d41:	0f 94 c1             	sete   %cl
  801d44:	0f b6 c9             	movzbl %cl,%ecx
  801d47:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d4a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d50:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801d56:	39 ce                	cmp    %ecx,%esi
  801d58:	74 1e                	je     801d78 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801d5a:	39 c3                	cmp    %eax,%ebx
  801d5c:	75 be                	jne    801d1c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d5e:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801d64:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d67:	50                   	push   %eax
  801d68:	56                   	push   %esi
  801d69:	68 52 2c 80 00       	push   $0x802c52
  801d6e:	e8 b7 e5 ff ff       	call   80032a <cprintf>
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	eb a4                	jmp    801d1c <_pipeisclosed+0xe>
	}
}
  801d78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	57                   	push   %edi
  801d87:	56                   	push   %esi
  801d88:	53                   	push   %ebx
  801d89:	83 ec 28             	sub    $0x28,%esp
  801d8c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d8f:	56                   	push   %esi
  801d90:	e8 fa f6 ff ff       	call   80148f <fd2data>
  801d95:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	bf 00 00 00 00       	mov    $0x0,%edi
  801d9f:	eb 4b                	jmp    801dec <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801da1:	89 da                	mov    %ebx,%edx
  801da3:	89 f0                	mov    %esi,%eax
  801da5:	e8 64 ff ff ff       	call   801d0e <_pipeisclosed>
  801daa:	85 c0                	test   %eax,%eax
  801dac:	75 48                	jne    801df6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dae:	e8 e0 ee ff ff       	call   800c93 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801db3:	8b 43 04             	mov    0x4(%ebx),%eax
  801db6:	8b 0b                	mov    (%ebx),%ecx
  801db8:	8d 51 20             	lea    0x20(%ecx),%edx
  801dbb:	39 d0                	cmp    %edx,%eax
  801dbd:	73 e2                	jae    801da1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dc2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dc6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dc9:	89 c2                	mov    %eax,%edx
  801dcb:	c1 fa 1f             	sar    $0x1f,%edx
  801dce:	89 d1                	mov    %edx,%ecx
  801dd0:	c1 e9 1b             	shr    $0x1b,%ecx
  801dd3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dd6:	83 e2 1f             	and    $0x1f,%edx
  801dd9:	29 ca                	sub    %ecx,%edx
  801ddb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ddf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801de3:	83 c0 01             	add    $0x1,%eax
  801de6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de9:	83 c7 01             	add    $0x1,%edi
  801dec:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801def:	75 c2                	jne    801db3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801df1:	8b 45 10             	mov    0x10(%ebp),%eax
  801df4:	eb 05                	jmp    801dfb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    

00801e03 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	57                   	push   %edi
  801e07:	56                   	push   %esi
  801e08:	53                   	push   %ebx
  801e09:	83 ec 18             	sub    $0x18,%esp
  801e0c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e0f:	57                   	push   %edi
  801e10:	e8 7a f6 ff ff       	call   80148f <fd2data>
  801e15:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e1f:	eb 3d                	jmp    801e5e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e21:	85 db                	test   %ebx,%ebx
  801e23:	74 04                	je     801e29 <devpipe_read+0x26>
				return i;
  801e25:	89 d8                	mov    %ebx,%eax
  801e27:	eb 44                	jmp    801e6d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e29:	89 f2                	mov    %esi,%edx
  801e2b:	89 f8                	mov    %edi,%eax
  801e2d:	e8 dc fe ff ff       	call   801d0e <_pipeisclosed>
  801e32:	85 c0                	test   %eax,%eax
  801e34:	75 32                	jne    801e68 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e36:	e8 58 ee ff ff       	call   800c93 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e3b:	8b 06                	mov    (%esi),%eax
  801e3d:	3b 46 04             	cmp    0x4(%esi),%eax
  801e40:	74 df                	je     801e21 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e42:	99                   	cltd   
  801e43:	c1 ea 1b             	shr    $0x1b,%edx
  801e46:	01 d0                	add    %edx,%eax
  801e48:	83 e0 1f             	and    $0x1f,%eax
  801e4b:	29 d0                	sub    %edx,%eax
  801e4d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e55:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e58:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e5b:	83 c3 01             	add    $0x1,%ebx
  801e5e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e61:	75 d8                	jne    801e3b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e63:	8b 45 10             	mov    0x10(%ebp),%eax
  801e66:	eb 05                	jmp    801e6d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e68:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5f                   	pop    %edi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    

00801e75 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	56                   	push   %esi
  801e79:	53                   	push   %ebx
  801e7a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e80:	50                   	push   %eax
  801e81:	e8 20 f6 ff ff       	call   8014a6 <fd_alloc>
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	89 c2                	mov    %eax,%edx
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	0f 88 2c 01 00 00    	js     801fbf <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e93:	83 ec 04             	sub    $0x4,%esp
  801e96:	68 07 04 00 00       	push   $0x407
  801e9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9e:	6a 00                	push   $0x0
  801ea0:	e8 0d ee ff ff       	call   800cb2 <sys_page_alloc>
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	89 c2                	mov    %eax,%edx
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	0f 88 0d 01 00 00    	js     801fbf <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb8:	50                   	push   %eax
  801eb9:	e8 e8 f5 ff ff       	call   8014a6 <fd_alloc>
  801ebe:	89 c3                	mov    %eax,%ebx
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	0f 88 e2 00 00 00    	js     801fad <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ecb:	83 ec 04             	sub    $0x4,%esp
  801ece:	68 07 04 00 00       	push   $0x407
  801ed3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 d5 ed ff ff       	call   800cb2 <sys_page_alloc>
  801edd:	89 c3                	mov    %eax,%ebx
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	0f 88 c3 00 00 00    	js     801fad <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef0:	e8 9a f5 ff ff       	call   80148f <fd2data>
  801ef5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef7:	83 c4 0c             	add    $0xc,%esp
  801efa:	68 07 04 00 00       	push   $0x407
  801eff:	50                   	push   %eax
  801f00:	6a 00                	push   $0x0
  801f02:	e8 ab ed ff ff       	call   800cb2 <sys_page_alloc>
  801f07:	89 c3                	mov    %eax,%ebx
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	0f 88 89 00 00 00    	js     801f9d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f14:	83 ec 0c             	sub    $0xc,%esp
  801f17:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1a:	e8 70 f5 ff ff       	call   80148f <fd2data>
  801f1f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f26:	50                   	push   %eax
  801f27:	6a 00                	push   $0x0
  801f29:	56                   	push   %esi
  801f2a:	6a 00                	push   $0x0
  801f2c:	e8 c4 ed ff ff       	call   800cf5 <sys_page_map>
  801f31:	89 c3                	mov    %eax,%ebx
  801f33:	83 c4 20             	add    $0x20,%esp
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 55                	js     801f8f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f3a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f43:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f48:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f4f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f58:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f5d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f64:	83 ec 0c             	sub    $0xc,%esp
  801f67:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6a:	e8 10 f5 ff ff       	call   80147f <fd2num>
  801f6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f72:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f74:	83 c4 04             	add    $0x4,%esp
  801f77:	ff 75 f0             	pushl  -0x10(%ebp)
  801f7a:	e8 00 f5 ff ff       	call   80147f <fd2num>
  801f7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f82:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	ba 00 00 00 00       	mov    $0x0,%edx
  801f8d:	eb 30                	jmp    801fbf <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f8f:	83 ec 08             	sub    $0x8,%esp
  801f92:	56                   	push   %esi
  801f93:	6a 00                	push   $0x0
  801f95:	e8 9d ed ff ff       	call   800d37 <sys_page_unmap>
  801f9a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f9d:	83 ec 08             	sub    $0x8,%esp
  801fa0:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa3:	6a 00                	push   $0x0
  801fa5:	e8 8d ed ff ff       	call   800d37 <sys_page_unmap>
  801faa:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fad:	83 ec 08             	sub    $0x8,%esp
  801fb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb3:	6a 00                	push   $0x0
  801fb5:	e8 7d ed ff ff       	call   800d37 <sys_page_unmap>
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd1:	50                   	push   %eax
  801fd2:	ff 75 08             	pushl  0x8(%ebp)
  801fd5:	e8 1b f5 ff ff       	call   8014f5 <fd_lookup>
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	78 18                	js     801ff9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fe1:	83 ec 0c             	sub    $0xc,%esp
  801fe4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe7:	e8 a3 f4 ff ff       	call   80148f <fd2data>
	return _pipeisclosed(fd, p);
  801fec:	89 c2                	mov    %eax,%edx
  801fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff1:	e8 18 fd ff ff       	call   801d0e <_pipeisclosed>
  801ff6:	83 c4 10             	add    $0x10,%esp
}
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80200b:	68 6a 2c 80 00       	push   $0x802c6a
  802010:	ff 75 0c             	pushl  0xc(%ebp)
  802013:	e8 97 e8 ff ff       	call   8008af <strcpy>
	return 0;
}
  802018:	b8 00 00 00 00       	mov    $0x0,%eax
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    

0080201f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	57                   	push   %edi
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80202b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802030:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802036:	eb 2d                	jmp    802065 <devcons_write+0x46>
		m = n - tot;
  802038:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80203b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80203d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802040:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802045:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802048:	83 ec 04             	sub    $0x4,%esp
  80204b:	53                   	push   %ebx
  80204c:	03 45 0c             	add    0xc(%ebp),%eax
  80204f:	50                   	push   %eax
  802050:	57                   	push   %edi
  802051:	e8 eb e9 ff ff       	call   800a41 <memmove>
		sys_cputs(buf, m);
  802056:	83 c4 08             	add    $0x8,%esp
  802059:	53                   	push   %ebx
  80205a:	57                   	push   %edi
  80205b:	e8 96 eb ff ff       	call   800bf6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802060:	01 de                	add    %ebx,%esi
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	89 f0                	mov    %esi,%eax
  802067:	3b 75 10             	cmp    0x10(%ebp),%esi
  80206a:	72 cc                	jb     802038 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80206c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	83 ec 08             	sub    $0x8,%esp
  80207a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80207f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802083:	74 2a                	je     8020af <devcons_read+0x3b>
  802085:	eb 05                	jmp    80208c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802087:	e8 07 ec ff ff       	call   800c93 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80208c:	e8 83 eb ff ff       	call   800c14 <sys_cgetc>
  802091:	85 c0                	test   %eax,%eax
  802093:	74 f2                	je     802087 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802095:	85 c0                	test   %eax,%eax
  802097:	78 16                	js     8020af <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802099:	83 f8 04             	cmp    $0x4,%eax
  80209c:	74 0c                	je     8020aa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80209e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a1:	88 02                	mov    %al,(%edx)
	return 1;
  8020a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a8:	eb 05                	jmp    8020af <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020aa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ba:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020bd:	6a 01                	push   $0x1
  8020bf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c2:	50                   	push   %eax
  8020c3:	e8 2e eb ff ff       	call   800bf6 <sys_cputs>
}
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	c9                   	leave  
  8020cc:	c3                   	ret    

008020cd <getchar>:

int
getchar(void)
{
  8020cd:	55                   	push   %ebp
  8020ce:	89 e5                	mov    %esp,%ebp
  8020d0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020d3:	6a 01                	push   $0x1
  8020d5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d8:	50                   	push   %eax
  8020d9:	6a 00                	push   $0x0
  8020db:	e8 7e f6 ff ff       	call   80175e <read>
	if (r < 0)
  8020e0:	83 c4 10             	add    $0x10,%esp
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 0f                	js     8020f6 <getchar+0x29>
		return r;
	if (r < 1)
  8020e7:	85 c0                	test   %eax,%eax
  8020e9:	7e 06                	jle    8020f1 <getchar+0x24>
		return -E_EOF;
	return c;
  8020eb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020ef:	eb 05                	jmp    8020f6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020f1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020f6:	c9                   	leave  
  8020f7:	c3                   	ret    

008020f8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802101:	50                   	push   %eax
  802102:	ff 75 08             	pushl  0x8(%ebp)
  802105:	e8 eb f3 ff ff       	call   8014f5 <fd_lookup>
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	85 c0                	test   %eax,%eax
  80210f:	78 11                	js     802122 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802114:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80211a:	39 10                	cmp    %edx,(%eax)
  80211c:	0f 94 c0             	sete   %al
  80211f:	0f b6 c0             	movzbl %al,%eax
}
  802122:	c9                   	leave  
  802123:	c3                   	ret    

00802124 <opencons>:

int
opencons(void)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80212a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212d:	50                   	push   %eax
  80212e:	e8 73 f3 ff ff       	call   8014a6 <fd_alloc>
  802133:	83 c4 10             	add    $0x10,%esp
		return r;
  802136:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802138:	85 c0                	test   %eax,%eax
  80213a:	78 3e                	js     80217a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80213c:	83 ec 04             	sub    $0x4,%esp
  80213f:	68 07 04 00 00       	push   $0x407
  802144:	ff 75 f4             	pushl  -0xc(%ebp)
  802147:	6a 00                	push   $0x0
  802149:	e8 64 eb ff ff       	call   800cb2 <sys_page_alloc>
  80214e:	83 c4 10             	add    $0x10,%esp
		return r;
  802151:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802153:	85 c0                	test   %eax,%eax
  802155:	78 23                	js     80217a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802157:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80215d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802160:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802165:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80216c:	83 ec 0c             	sub    $0xc,%esp
  80216f:	50                   	push   %eax
  802170:	e8 0a f3 ff ff       	call   80147f <fd2num>
  802175:	89 c2                	mov    %eax,%edx
  802177:	83 c4 10             	add    $0x10,%esp
}
  80217a:	89 d0                	mov    %edx,%eax
  80217c:	c9                   	leave  
  80217d:	c3                   	ret    

0080217e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80217e:	55                   	push   %ebp
  80217f:	89 e5                	mov    %esp,%ebp
  802181:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802184:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80218b:	75 2a                	jne    8021b7 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80218d:	83 ec 04             	sub    $0x4,%esp
  802190:	6a 07                	push   $0x7
  802192:	68 00 f0 bf ee       	push   $0xeebff000
  802197:	6a 00                	push   $0x0
  802199:	e8 14 eb ff ff       	call   800cb2 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80219e:	83 c4 10             	add    $0x10,%esp
  8021a1:	85 c0                	test   %eax,%eax
  8021a3:	79 12                	jns    8021b7 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8021a5:	50                   	push   %eax
  8021a6:	68 f8 2a 80 00       	push   $0x802af8
  8021ab:	6a 23                	push   $0x23
  8021ad:	68 76 2c 80 00       	push   $0x802c76
  8021b2:	e8 9a e0 ff ff       	call   800251 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ba:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8021bf:	83 ec 08             	sub    $0x8,%esp
  8021c2:	68 e9 21 80 00       	push   $0x8021e9
  8021c7:	6a 00                	push   $0x0
  8021c9:	e8 2f ec ff ff       	call   800dfd <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8021ce:	83 c4 10             	add    $0x10,%esp
  8021d1:	85 c0                	test   %eax,%eax
  8021d3:	79 12                	jns    8021e7 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8021d5:	50                   	push   %eax
  8021d6:	68 f8 2a 80 00       	push   $0x802af8
  8021db:	6a 2c                	push   $0x2c
  8021dd:	68 76 2c 80 00       	push   $0x802c76
  8021e2:	e8 6a e0 ff ff       	call   800251 <_panic>
	}
}
  8021e7:	c9                   	leave  
  8021e8:	c3                   	ret    

008021e9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021e9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021ea:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021ef:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021f1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8021f4:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8021f8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8021fd:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802201:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802203:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802206:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802207:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80220a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80220b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80220c:	c3                   	ret    

0080220d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	56                   	push   %esi
  802211:	53                   	push   %ebx
  802212:	8b 75 08             	mov    0x8(%ebp),%esi
  802215:	8b 45 0c             	mov    0xc(%ebp),%eax
  802218:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80221b:	85 c0                	test   %eax,%eax
  80221d:	75 12                	jne    802231 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80221f:	83 ec 0c             	sub    $0xc,%esp
  802222:	68 00 00 c0 ee       	push   $0xeec00000
  802227:	e8 36 ec ff ff       	call   800e62 <sys_ipc_recv>
  80222c:	83 c4 10             	add    $0x10,%esp
  80222f:	eb 0c                	jmp    80223d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802231:	83 ec 0c             	sub    $0xc,%esp
  802234:	50                   	push   %eax
  802235:	e8 28 ec ff ff       	call   800e62 <sys_ipc_recv>
  80223a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80223d:	85 f6                	test   %esi,%esi
  80223f:	0f 95 c1             	setne  %cl
  802242:	85 db                	test   %ebx,%ebx
  802244:	0f 95 c2             	setne  %dl
  802247:	84 d1                	test   %dl,%cl
  802249:	74 09                	je     802254 <ipc_recv+0x47>
  80224b:	89 c2                	mov    %eax,%edx
  80224d:	c1 ea 1f             	shr    $0x1f,%edx
  802250:	84 d2                	test   %dl,%dl
  802252:	75 2d                	jne    802281 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802254:	85 f6                	test   %esi,%esi
  802256:	74 0d                	je     802265 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802258:	a1 04 40 80 00       	mov    0x804004,%eax
  80225d:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802263:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802265:	85 db                	test   %ebx,%ebx
  802267:	74 0d                	je     802276 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802269:	a1 04 40 80 00       	mov    0x804004,%eax
  80226e:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802274:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802276:	a1 04 40 80 00       	mov    0x804004,%eax
  80227b:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	57                   	push   %edi
  80228c:	56                   	push   %esi
  80228d:	53                   	push   %ebx
  80228e:	83 ec 0c             	sub    $0xc,%esp
  802291:	8b 7d 08             	mov    0x8(%ebp),%edi
  802294:	8b 75 0c             	mov    0xc(%ebp),%esi
  802297:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80229a:	85 db                	test   %ebx,%ebx
  80229c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022a1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8022a4:	ff 75 14             	pushl  0x14(%ebp)
  8022a7:	53                   	push   %ebx
  8022a8:	56                   	push   %esi
  8022a9:	57                   	push   %edi
  8022aa:	e8 90 eb ff ff       	call   800e3f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8022af:	89 c2                	mov    %eax,%edx
  8022b1:	c1 ea 1f             	shr    $0x1f,%edx
  8022b4:	83 c4 10             	add    $0x10,%esp
  8022b7:	84 d2                	test   %dl,%dl
  8022b9:	74 17                	je     8022d2 <ipc_send+0x4a>
  8022bb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022be:	74 12                	je     8022d2 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8022c0:	50                   	push   %eax
  8022c1:	68 84 2c 80 00       	push   $0x802c84
  8022c6:	6a 47                	push   $0x47
  8022c8:	68 92 2c 80 00       	push   $0x802c92
  8022cd:	e8 7f df ff ff       	call   800251 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8022d2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022d5:	75 07                	jne    8022de <ipc_send+0x56>
			sys_yield();
  8022d7:	e8 b7 e9 ff ff       	call   800c93 <sys_yield>
  8022dc:	eb c6                	jmp    8022a4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8022de:	85 c0                	test   %eax,%eax
  8022e0:	75 c2                	jne    8022a4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8022e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e5:	5b                   	pop    %ebx
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022f0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022f5:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8022fb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802301:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802307:	39 ca                	cmp    %ecx,%edx
  802309:	75 13                	jne    80231e <ipc_find_env+0x34>
			return envs[i].env_id;
  80230b:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802311:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802316:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80231c:	eb 0f                	jmp    80232d <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80231e:	83 c0 01             	add    $0x1,%eax
  802321:	3d 00 04 00 00       	cmp    $0x400,%eax
  802326:	75 cd                	jne    8022f5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802328:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80232d:	5d                   	pop    %ebp
  80232e:	c3                   	ret    

0080232f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80232f:	55                   	push   %ebp
  802330:	89 e5                	mov    %esp,%ebp
  802332:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802335:	89 d0                	mov    %edx,%eax
  802337:	c1 e8 16             	shr    $0x16,%eax
  80233a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802341:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802346:	f6 c1 01             	test   $0x1,%cl
  802349:	74 1d                	je     802368 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80234b:	c1 ea 0c             	shr    $0xc,%edx
  80234e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802355:	f6 c2 01             	test   $0x1,%dl
  802358:	74 0e                	je     802368 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80235a:	c1 ea 0c             	shr    $0xc,%edx
  80235d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802364:	ef 
  802365:	0f b7 c0             	movzwl %ax,%eax
}
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    
  80236a:	66 90                	xchg   %ax,%ax
  80236c:	66 90                	xchg   %ax,%ax
  80236e:	66 90                	xchg   %ax,%ax

00802370 <__udivdi3>:
  802370:	55                   	push   %ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
  802374:	83 ec 1c             	sub    $0x1c,%esp
  802377:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80237b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80237f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802383:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802387:	85 f6                	test   %esi,%esi
  802389:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80238d:	89 ca                	mov    %ecx,%edx
  80238f:	89 f8                	mov    %edi,%eax
  802391:	75 3d                	jne    8023d0 <__udivdi3+0x60>
  802393:	39 cf                	cmp    %ecx,%edi
  802395:	0f 87 c5 00 00 00    	ja     802460 <__udivdi3+0xf0>
  80239b:	85 ff                	test   %edi,%edi
  80239d:	89 fd                	mov    %edi,%ebp
  80239f:	75 0b                	jne    8023ac <__udivdi3+0x3c>
  8023a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a6:	31 d2                	xor    %edx,%edx
  8023a8:	f7 f7                	div    %edi
  8023aa:	89 c5                	mov    %eax,%ebp
  8023ac:	89 c8                	mov    %ecx,%eax
  8023ae:	31 d2                	xor    %edx,%edx
  8023b0:	f7 f5                	div    %ebp
  8023b2:	89 c1                	mov    %eax,%ecx
  8023b4:	89 d8                	mov    %ebx,%eax
  8023b6:	89 cf                	mov    %ecx,%edi
  8023b8:	f7 f5                	div    %ebp
  8023ba:	89 c3                	mov    %eax,%ebx
  8023bc:	89 d8                	mov    %ebx,%eax
  8023be:	89 fa                	mov    %edi,%edx
  8023c0:	83 c4 1c             	add    $0x1c,%esp
  8023c3:	5b                   	pop    %ebx
  8023c4:	5e                   	pop    %esi
  8023c5:	5f                   	pop    %edi
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    
  8023c8:	90                   	nop
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	39 ce                	cmp    %ecx,%esi
  8023d2:	77 74                	ja     802448 <__udivdi3+0xd8>
  8023d4:	0f bd fe             	bsr    %esi,%edi
  8023d7:	83 f7 1f             	xor    $0x1f,%edi
  8023da:	0f 84 98 00 00 00    	je     802478 <__udivdi3+0x108>
  8023e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8023e5:	89 f9                	mov    %edi,%ecx
  8023e7:	89 c5                	mov    %eax,%ebp
  8023e9:	29 fb                	sub    %edi,%ebx
  8023eb:	d3 e6                	shl    %cl,%esi
  8023ed:	89 d9                	mov    %ebx,%ecx
  8023ef:	d3 ed                	shr    %cl,%ebp
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	d3 e0                	shl    %cl,%eax
  8023f5:	09 ee                	or     %ebp,%esi
  8023f7:	89 d9                	mov    %ebx,%ecx
  8023f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023fd:	89 d5                	mov    %edx,%ebp
  8023ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802403:	d3 ed                	shr    %cl,%ebp
  802405:	89 f9                	mov    %edi,%ecx
  802407:	d3 e2                	shl    %cl,%edx
  802409:	89 d9                	mov    %ebx,%ecx
  80240b:	d3 e8                	shr    %cl,%eax
  80240d:	09 c2                	or     %eax,%edx
  80240f:	89 d0                	mov    %edx,%eax
  802411:	89 ea                	mov    %ebp,%edx
  802413:	f7 f6                	div    %esi
  802415:	89 d5                	mov    %edx,%ebp
  802417:	89 c3                	mov    %eax,%ebx
  802419:	f7 64 24 0c          	mull   0xc(%esp)
  80241d:	39 d5                	cmp    %edx,%ebp
  80241f:	72 10                	jb     802431 <__udivdi3+0xc1>
  802421:	8b 74 24 08          	mov    0x8(%esp),%esi
  802425:	89 f9                	mov    %edi,%ecx
  802427:	d3 e6                	shl    %cl,%esi
  802429:	39 c6                	cmp    %eax,%esi
  80242b:	73 07                	jae    802434 <__udivdi3+0xc4>
  80242d:	39 d5                	cmp    %edx,%ebp
  80242f:	75 03                	jne    802434 <__udivdi3+0xc4>
  802431:	83 eb 01             	sub    $0x1,%ebx
  802434:	31 ff                	xor    %edi,%edi
  802436:	89 d8                	mov    %ebx,%eax
  802438:	89 fa                	mov    %edi,%edx
  80243a:	83 c4 1c             	add    $0x1c,%esp
  80243d:	5b                   	pop    %ebx
  80243e:	5e                   	pop    %esi
  80243f:	5f                   	pop    %edi
  802440:	5d                   	pop    %ebp
  802441:	c3                   	ret    
  802442:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802448:	31 ff                	xor    %edi,%edi
  80244a:	31 db                	xor    %ebx,%ebx
  80244c:	89 d8                	mov    %ebx,%eax
  80244e:	89 fa                	mov    %edi,%edx
  802450:	83 c4 1c             	add    $0x1c,%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5f                   	pop    %edi
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    
  802458:	90                   	nop
  802459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802460:	89 d8                	mov    %ebx,%eax
  802462:	f7 f7                	div    %edi
  802464:	31 ff                	xor    %edi,%edi
  802466:	89 c3                	mov    %eax,%ebx
  802468:	89 d8                	mov    %ebx,%eax
  80246a:	89 fa                	mov    %edi,%edx
  80246c:	83 c4 1c             	add    $0x1c,%esp
  80246f:	5b                   	pop    %ebx
  802470:	5e                   	pop    %esi
  802471:	5f                   	pop    %edi
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	39 ce                	cmp    %ecx,%esi
  80247a:	72 0c                	jb     802488 <__udivdi3+0x118>
  80247c:	31 db                	xor    %ebx,%ebx
  80247e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802482:	0f 87 34 ff ff ff    	ja     8023bc <__udivdi3+0x4c>
  802488:	bb 01 00 00 00       	mov    $0x1,%ebx
  80248d:	e9 2a ff ff ff       	jmp    8023bc <__udivdi3+0x4c>
  802492:	66 90                	xchg   %ax,%ax
  802494:	66 90                	xchg   %ax,%ax
  802496:	66 90                	xchg   %ax,%ax
  802498:	66 90                	xchg   %ax,%ax
  80249a:	66 90                	xchg   %ax,%ax
  80249c:	66 90                	xchg   %ax,%ax
  80249e:	66 90                	xchg   %ax,%ax

008024a0 <__umoddi3>:
  8024a0:	55                   	push   %ebp
  8024a1:	57                   	push   %edi
  8024a2:	56                   	push   %esi
  8024a3:	53                   	push   %ebx
  8024a4:	83 ec 1c             	sub    $0x1c,%esp
  8024a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024b7:	85 d2                	test   %edx,%edx
  8024b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024c1:	89 f3                	mov    %esi,%ebx
  8024c3:	89 3c 24             	mov    %edi,(%esp)
  8024c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ca:	75 1c                	jne    8024e8 <__umoddi3+0x48>
  8024cc:	39 f7                	cmp    %esi,%edi
  8024ce:	76 50                	jbe    802520 <__umoddi3+0x80>
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	f7 f7                	div    %edi
  8024d6:	89 d0                	mov    %edx,%eax
  8024d8:	31 d2                	xor    %edx,%edx
  8024da:	83 c4 1c             	add    $0x1c,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	39 f2                	cmp    %esi,%edx
  8024ea:	89 d0                	mov    %edx,%eax
  8024ec:	77 52                	ja     802540 <__umoddi3+0xa0>
  8024ee:	0f bd ea             	bsr    %edx,%ebp
  8024f1:	83 f5 1f             	xor    $0x1f,%ebp
  8024f4:	75 5a                	jne    802550 <__umoddi3+0xb0>
  8024f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8024fa:	0f 82 e0 00 00 00    	jb     8025e0 <__umoddi3+0x140>
  802500:	39 0c 24             	cmp    %ecx,(%esp)
  802503:	0f 86 d7 00 00 00    	jbe    8025e0 <__umoddi3+0x140>
  802509:	8b 44 24 08          	mov    0x8(%esp),%eax
  80250d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802511:	83 c4 1c             	add    $0x1c,%esp
  802514:	5b                   	pop    %ebx
  802515:	5e                   	pop    %esi
  802516:	5f                   	pop    %edi
  802517:	5d                   	pop    %ebp
  802518:	c3                   	ret    
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	85 ff                	test   %edi,%edi
  802522:	89 fd                	mov    %edi,%ebp
  802524:	75 0b                	jne    802531 <__umoddi3+0x91>
  802526:	b8 01 00 00 00       	mov    $0x1,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	f7 f7                	div    %edi
  80252f:	89 c5                	mov    %eax,%ebp
  802531:	89 f0                	mov    %esi,%eax
  802533:	31 d2                	xor    %edx,%edx
  802535:	f7 f5                	div    %ebp
  802537:	89 c8                	mov    %ecx,%eax
  802539:	f7 f5                	div    %ebp
  80253b:	89 d0                	mov    %edx,%eax
  80253d:	eb 99                	jmp    8024d8 <__umoddi3+0x38>
  80253f:	90                   	nop
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 f2                	mov    %esi,%edx
  802544:	83 c4 1c             	add    $0x1c,%esp
  802547:	5b                   	pop    %ebx
  802548:	5e                   	pop    %esi
  802549:	5f                   	pop    %edi
  80254a:	5d                   	pop    %ebp
  80254b:	c3                   	ret    
  80254c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802550:	8b 34 24             	mov    (%esp),%esi
  802553:	bf 20 00 00 00       	mov    $0x20,%edi
  802558:	89 e9                	mov    %ebp,%ecx
  80255a:	29 ef                	sub    %ebp,%edi
  80255c:	d3 e0                	shl    %cl,%eax
  80255e:	89 f9                	mov    %edi,%ecx
  802560:	89 f2                	mov    %esi,%edx
  802562:	d3 ea                	shr    %cl,%edx
  802564:	89 e9                	mov    %ebp,%ecx
  802566:	09 c2                	or     %eax,%edx
  802568:	89 d8                	mov    %ebx,%eax
  80256a:	89 14 24             	mov    %edx,(%esp)
  80256d:	89 f2                	mov    %esi,%edx
  80256f:	d3 e2                	shl    %cl,%edx
  802571:	89 f9                	mov    %edi,%ecx
  802573:	89 54 24 04          	mov    %edx,0x4(%esp)
  802577:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80257b:	d3 e8                	shr    %cl,%eax
  80257d:	89 e9                	mov    %ebp,%ecx
  80257f:	89 c6                	mov    %eax,%esi
  802581:	d3 e3                	shl    %cl,%ebx
  802583:	89 f9                	mov    %edi,%ecx
  802585:	89 d0                	mov    %edx,%eax
  802587:	d3 e8                	shr    %cl,%eax
  802589:	89 e9                	mov    %ebp,%ecx
  80258b:	09 d8                	or     %ebx,%eax
  80258d:	89 d3                	mov    %edx,%ebx
  80258f:	89 f2                	mov    %esi,%edx
  802591:	f7 34 24             	divl   (%esp)
  802594:	89 d6                	mov    %edx,%esi
  802596:	d3 e3                	shl    %cl,%ebx
  802598:	f7 64 24 04          	mull   0x4(%esp)
  80259c:	39 d6                	cmp    %edx,%esi
  80259e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025a2:	89 d1                	mov    %edx,%ecx
  8025a4:	89 c3                	mov    %eax,%ebx
  8025a6:	72 08                	jb     8025b0 <__umoddi3+0x110>
  8025a8:	75 11                	jne    8025bb <__umoddi3+0x11b>
  8025aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8025ae:	73 0b                	jae    8025bb <__umoddi3+0x11b>
  8025b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8025b4:	1b 14 24             	sbb    (%esp),%edx
  8025b7:	89 d1                	mov    %edx,%ecx
  8025b9:	89 c3                	mov    %eax,%ebx
  8025bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8025bf:	29 da                	sub    %ebx,%edx
  8025c1:	19 ce                	sbb    %ecx,%esi
  8025c3:	89 f9                	mov    %edi,%ecx
  8025c5:	89 f0                	mov    %esi,%eax
  8025c7:	d3 e0                	shl    %cl,%eax
  8025c9:	89 e9                	mov    %ebp,%ecx
  8025cb:	d3 ea                	shr    %cl,%edx
  8025cd:	89 e9                	mov    %ebp,%ecx
  8025cf:	d3 ee                	shr    %cl,%esi
  8025d1:	09 d0                	or     %edx,%eax
  8025d3:	89 f2                	mov    %esi,%edx
  8025d5:	83 c4 1c             	add    $0x1c,%esp
  8025d8:	5b                   	pop    %ebx
  8025d9:	5e                   	pop    %esi
  8025da:	5f                   	pop    %edi
  8025db:	5d                   	pop    %ebp
  8025dc:	c3                   	ret    
  8025dd:	8d 76 00             	lea    0x0(%esi),%esi
  8025e0:	29 f9                	sub    %edi,%ecx
  8025e2:	19 d6                	sbb    %edx,%esi
  8025e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025ec:	e9 18 ff ff ff       	jmp    802509 <__umoddi3+0x69>
