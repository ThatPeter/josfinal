
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
  80002c:	e8 a4 01 00 00       	call   8001d5 <libmain>
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
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 40 23 80 00       	push   $0x802340
  800041:	e8 ec 02 00 00       	call   800332 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 6d 1b 00 00       	call   801bbe <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 8e 23 80 00       	push   $0x80238e
  80005e:	6a 0d                	push   $0xd
  800060:	68 97 23 80 00       	push   $0x802397
  800065:	e8 ef 01 00 00       	call   800259 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 52 0f 00 00       	call   800fc1 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 ac 23 80 00       	push   $0x8023ac
  80007b:	6a 0f                	push   $0xf
  80007d:	68 97 23 80 00       	push   $0x802397
  800082:	e8 d2 01 00 00       	call   800259 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 e7 12 00 00       	call   80137d <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
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
  8000be:	68 b5 23 80 00       	push   $0x8023b5
  8000c3:	e8 6a 02 00 00       	call   800332 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 f5 12 00 00       	call   8013cd <dup>
			sys_yield();
  8000d8:	e8 be 0b 00 00       	call   800c9b <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 94 12 00 00       	call   80137d <close>
			sys_yield();
  8000e9:	e8 ad 0b 00 00       	call   800c9b <sys_yield>
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
  8000fc:	e8 3e 01 00 00       	call   80023f <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c c5 00 00 00 00 	lea    0x0(,%eax,8),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 ef 1b 00 00       	call   801d11 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 27                	je     800150 <umain+0x11d>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 b9 23 80 00       	push   $0x8023b9
  800131:	e8 fc 01 00 00       	call   800332 <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 fd 0a 00 00       	call   800c3b <sys_env_destroy>
			exit();
  80013e:	e8 fc 00 00 00       	call   80023f <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800149:	8d 9c 07 00 00 c0 ee 	lea    -0x11400000(%edi,%eax,1),%ebx
  800150:	8b 43 60             	mov    0x60(%ebx),%eax
  800153:	83 f8 02             	cmp    $0x2,%eax
  800156:	74 bf                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	68 d5 23 80 00       	push   $0x8023d5
  800160:	e8 cd 01 00 00       	call   800332 <cprintf>
	if (pipeisclosed(p[0]))
  800165:	83 c4 04             	add    $0x4,%esp
  800168:	ff 75 e0             	pushl  -0x20(%ebp)
  80016b:	e8 a1 1b 00 00       	call   801d11 <pipeisclosed>
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	85 c0                	test   %eax,%eax
  800175:	74 14                	je     80018b <umain+0x158>
		panic("somehow the other end of p[0] got closed!");
  800177:	83 ec 04             	sub    $0x4,%esp
  80017a:	68 64 23 80 00       	push   $0x802364
  80017f:	6a 40                	push   $0x40
  800181:	68 97 23 80 00       	push   $0x802397
  800186:	e8 ce 00 00 00       	call   800259 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018b:	83 ec 08             	sub    $0x8,%esp
  80018e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800191:	50                   	push   %eax
  800192:	ff 75 e0             	pushl  -0x20(%ebp)
  800195:	e8 b9 10 00 00       	call   801253 <fd_lookup>
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	85 c0                	test   %eax,%eax
  80019f:	79 12                	jns    8001b3 <umain+0x180>
		panic("cannot look up p[0]: %e", r);
  8001a1:	50                   	push   %eax
  8001a2:	68 eb 23 80 00       	push   $0x8023eb
  8001a7:	6a 42                	push   $0x42
  8001a9:	68 97 23 80 00       	push   $0x802397
  8001ae:	e8 a6 00 00 00       	call   800259 <_panic>
	(void) fd2data(fd);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b9:	e8 2f 10 00 00       	call   8011ed <fd2data>
	cprintf("race didn't happen\n");
  8001be:	c7 04 24 03 24 80 00 	movl   $0x802403,(%esp)
  8001c5:	e8 68 01 00 00       	call   800332 <cprintf>
}
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001dd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e0:	e8 97 0a 00 00       	call   800c7c <sys_getenvid>
  8001e5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ea:	89 c2                	mov    %eax,%edx
  8001ec:	c1 e2 07             	shl    $0x7,%edx
  8001ef:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8001f6:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fb:	85 db                	test   %ebx,%ebx
  8001fd:	7e 07                	jle    800206 <libmain+0x31>
		binaryname = argv[0];
  8001ff:	8b 06                	mov    (%esi),%eax
  800201:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	e8 23 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800210:	e8 2a 00 00 00       	call   80023f <exit>
}
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    

0080021f <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800225:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80022a:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80022c:	e8 4b 0a 00 00       	call   800c7c <sys_getenvid>
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	50                   	push   %eax
  800235:	e8 91 0c 00 00       	call   800ecb <sys_thread_free>
}
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800245:	e8 5e 11 00 00       	call   8013a8 <close_all>
	sys_env_destroy(0);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	6a 00                	push   $0x0
  80024f:	e8 e7 09 00 00       	call   800c3b <sys_env_destroy>
}
  800254:	83 c4 10             	add    $0x10,%esp
  800257:	c9                   	leave  
  800258:	c3                   	ret    

00800259 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	56                   	push   %esi
  80025d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80025e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800261:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800267:	e8 10 0a 00 00       	call   800c7c <sys_getenvid>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	ff 75 0c             	pushl  0xc(%ebp)
  800272:	ff 75 08             	pushl  0x8(%ebp)
  800275:	56                   	push   %esi
  800276:	50                   	push   %eax
  800277:	68 24 24 80 00       	push   $0x802424
  80027c:	e8 b1 00 00 00       	call   800332 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800281:	83 c4 18             	add    $0x18,%esp
  800284:	53                   	push   %ebx
  800285:	ff 75 10             	pushl  0x10(%ebp)
  800288:	e8 54 00 00 00       	call   8002e1 <vcprintf>
	cprintf("\n");
  80028d:	c7 04 24 c3 28 80 00 	movl   $0x8028c3,(%esp)
  800294:	e8 99 00 00 00       	call   800332 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80029c:	cc                   	int3   
  80029d:	eb fd                	jmp    80029c <_panic+0x43>

0080029f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 04             	sub    $0x4,%esp
  8002a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a9:	8b 13                	mov    (%ebx),%edx
  8002ab:	8d 42 01             	lea    0x1(%edx),%eax
  8002ae:	89 03                	mov    %eax,(%ebx)
  8002b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002bc:	75 1a                	jne    8002d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	68 ff 00 00 00       	push   $0xff
  8002c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c9:	50                   	push   %eax
  8002ca:	e8 2f 09 00 00       	call   800bfe <sys_cputs>
		b->idx = 0;
  8002cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f1:	00 00 00 
	b.cnt = 0;
  8002f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002fe:	ff 75 0c             	pushl  0xc(%ebp)
  800301:	ff 75 08             	pushl  0x8(%ebp)
  800304:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80030a:	50                   	push   %eax
  80030b:	68 9f 02 80 00       	push   $0x80029f
  800310:	e8 54 01 00 00       	call   800469 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800315:	83 c4 08             	add    $0x8,%esp
  800318:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80031e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800324:	50                   	push   %eax
  800325:	e8 d4 08 00 00       	call   800bfe <sys_cputs>

	return b.cnt;
}
  80032a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800338:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80033b:	50                   	push   %eax
  80033c:	ff 75 08             	pushl  0x8(%ebp)
  80033f:	e8 9d ff ff ff       	call   8002e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
  80034c:	83 ec 1c             	sub    $0x1c,%esp
  80034f:	89 c7                	mov    %eax,%edi
  800351:	89 d6                	mov    %edx,%esi
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	8b 55 0c             	mov    0xc(%ebp),%edx
  800359:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80035f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800362:	bb 00 00 00 00       	mov    $0x0,%ebx
  800367:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80036a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80036d:	39 d3                	cmp    %edx,%ebx
  80036f:	72 05                	jb     800376 <printnum+0x30>
  800371:	39 45 10             	cmp    %eax,0x10(%ebp)
  800374:	77 45                	ja     8003bb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	ff 75 18             	pushl  0x18(%ebp)
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800382:	53                   	push   %ebx
  800383:	ff 75 10             	pushl  0x10(%ebp)
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038c:	ff 75 e0             	pushl  -0x20(%ebp)
  80038f:	ff 75 dc             	pushl  -0x24(%ebp)
  800392:	ff 75 d8             	pushl  -0x28(%ebp)
  800395:	e8 16 1d 00 00       	call   8020b0 <__udivdi3>
  80039a:	83 c4 18             	add    $0x18,%esp
  80039d:	52                   	push   %edx
  80039e:	50                   	push   %eax
  80039f:	89 f2                	mov    %esi,%edx
  8003a1:	89 f8                	mov    %edi,%eax
  8003a3:	e8 9e ff ff ff       	call   800346 <printnum>
  8003a8:	83 c4 20             	add    $0x20,%esp
  8003ab:	eb 18                	jmp    8003c5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	56                   	push   %esi
  8003b1:	ff 75 18             	pushl  0x18(%ebp)
  8003b4:	ff d7                	call   *%edi
  8003b6:	83 c4 10             	add    $0x10,%esp
  8003b9:	eb 03                	jmp    8003be <printnum+0x78>
  8003bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003be:	83 eb 01             	sub    $0x1,%ebx
  8003c1:	85 db                	test   %ebx,%ebx
  8003c3:	7f e8                	jg     8003ad <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	56                   	push   %esi
  8003c9:	83 ec 04             	sub    $0x4,%esp
  8003cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d8:	e8 03 1e 00 00       	call   8021e0 <__umoddi3>
  8003dd:	83 c4 14             	add    $0x14,%esp
  8003e0:	0f be 80 47 24 80 00 	movsbl 0x802447(%eax),%eax
  8003e7:	50                   	push   %eax
  8003e8:	ff d7                	call   *%edi
}
  8003ea:	83 c4 10             	add    $0x10,%esp
  8003ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f0:	5b                   	pop    %ebx
  8003f1:	5e                   	pop    %esi
  8003f2:	5f                   	pop    %edi
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f8:	83 fa 01             	cmp    $0x1,%edx
  8003fb:	7e 0e                	jle    80040b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003fd:	8b 10                	mov    (%eax),%edx
  8003ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 02                	mov    (%edx),%eax
  800406:	8b 52 04             	mov    0x4(%edx),%edx
  800409:	eb 22                	jmp    80042d <getuint+0x38>
	else if (lflag)
  80040b:	85 d2                	test   %edx,%edx
  80040d:	74 10                	je     80041f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80040f:	8b 10                	mov    (%eax),%edx
  800411:	8d 4a 04             	lea    0x4(%edx),%ecx
  800414:	89 08                	mov    %ecx,(%eax)
  800416:	8b 02                	mov    (%edx),%eax
  800418:	ba 00 00 00 00       	mov    $0x0,%edx
  80041d:	eb 0e                	jmp    80042d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80041f:	8b 10                	mov    (%eax),%edx
  800421:	8d 4a 04             	lea    0x4(%edx),%ecx
  800424:	89 08                	mov    %ecx,(%eax)
  800426:	8b 02                	mov    (%edx),%eax
  800428:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800435:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	3b 50 04             	cmp    0x4(%eax),%edx
  80043e:	73 0a                	jae    80044a <sprintputch+0x1b>
		*b->buf++ = ch;
  800440:	8d 4a 01             	lea    0x1(%edx),%ecx
  800443:	89 08                	mov    %ecx,(%eax)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	88 02                	mov    %al,(%edx)
}
  80044a:	5d                   	pop    %ebp
  80044b:	c3                   	ret    

0080044c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800452:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800455:	50                   	push   %eax
  800456:	ff 75 10             	pushl  0x10(%ebp)
  800459:	ff 75 0c             	pushl  0xc(%ebp)
  80045c:	ff 75 08             	pushl  0x8(%ebp)
  80045f:	e8 05 00 00 00       	call   800469 <vprintfmt>
	va_end(ap);
}
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	c9                   	leave  
  800468:	c3                   	ret    

00800469 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	57                   	push   %edi
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 2c             	sub    $0x2c,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800478:	8b 7d 10             	mov    0x10(%ebp),%edi
  80047b:	eb 12                	jmp    80048f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80047d:	85 c0                	test   %eax,%eax
  80047f:	0f 84 89 03 00 00    	je     80080e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	53                   	push   %ebx
  800489:	50                   	push   %eax
  80048a:	ff d6                	call   *%esi
  80048c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80048f:	83 c7 01             	add    $0x1,%edi
  800492:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800496:	83 f8 25             	cmp    $0x25,%eax
  800499:	75 e2                	jne    80047d <vprintfmt+0x14>
  80049b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80049f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b9:	eb 07                	jmp    8004c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8d 47 01             	lea    0x1(%edi),%eax
  8004c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c8:	0f b6 07             	movzbl (%edi),%eax
  8004cb:	0f b6 c8             	movzbl %al,%ecx
  8004ce:	83 e8 23             	sub    $0x23,%eax
  8004d1:	3c 55                	cmp    $0x55,%al
  8004d3:	0f 87 1a 03 00 00    	ja     8007f3 <vprintfmt+0x38a>
  8004d9:	0f b6 c0             	movzbl %al,%eax
  8004dc:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  8004e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004e6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004ea:	eb d6                	jmp    8004c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004fa:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004fe:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800501:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800504:	83 fa 09             	cmp    $0x9,%edx
  800507:	77 39                	ja     800542 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800509:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80050c:	eb e9                	jmp    8004f7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 48 04             	lea    0x4(%eax),%ecx
  800514:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80051f:	eb 27                	jmp    800548 <vprintfmt+0xdf>
  800521:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800524:	85 c0                	test   %eax,%eax
  800526:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052b:	0f 49 c8             	cmovns %eax,%ecx
  80052e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800534:	eb 8c                	jmp    8004c2 <vprintfmt+0x59>
  800536:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800539:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800540:	eb 80                	jmp    8004c2 <vprintfmt+0x59>
  800542:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800545:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800548:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054c:	0f 89 70 ff ff ff    	jns    8004c2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800552:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800555:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800558:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80055f:	e9 5e ff ff ff       	jmp    8004c2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800564:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056a:	e9 53 ff ff ff       	jmp    8004c2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 50 04             	lea    0x4(%eax),%edx
  800575:	89 55 14             	mov    %edx,0x14(%ebp)
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	53                   	push   %ebx
  80057c:	ff 30                	pushl  (%eax)
  80057e:	ff d6                	call   *%esi
			break;
  800580:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800583:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800586:	e9 04 ff ff ff       	jmp    80048f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	99                   	cltd   
  800597:	31 d0                	xor    %edx,%eax
  800599:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059b:	83 f8 0f             	cmp    $0xf,%eax
  80059e:	7f 0b                	jg     8005ab <vprintfmt+0x142>
  8005a0:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8005a7:	85 d2                	test   %edx,%edx
  8005a9:	75 18                	jne    8005c3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ab:	50                   	push   %eax
  8005ac:	68 5f 24 80 00       	push   $0x80245f
  8005b1:	53                   	push   %ebx
  8005b2:	56                   	push   %esi
  8005b3:	e8 94 fe ff ff       	call   80044c <printfmt>
  8005b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005be:	e9 cc fe ff ff       	jmp    80048f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005c3:	52                   	push   %edx
  8005c4:	68 91 28 80 00       	push   $0x802891
  8005c9:	53                   	push   %ebx
  8005ca:	56                   	push   %esi
  8005cb:	e8 7c fe ff ff       	call   80044c <printfmt>
  8005d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d6:	e9 b4 fe ff ff       	jmp    80048f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005e6:	85 ff                	test   %edi,%edi
  8005e8:	b8 58 24 80 00       	mov    $0x802458,%eax
  8005ed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f4:	0f 8e 94 00 00 00    	jle    80068e <vprintfmt+0x225>
  8005fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005fe:	0f 84 98 00 00 00    	je     80069c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	ff 75 d0             	pushl  -0x30(%ebp)
  80060a:	57                   	push   %edi
  80060b:	e8 86 02 00 00       	call   800896 <strnlen>
  800610:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800613:	29 c1                	sub    %eax,%ecx
  800615:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800618:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80061b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80061f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800622:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800625:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800627:	eb 0f                	jmp    800638 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	ff 75 e0             	pushl  -0x20(%ebp)
  800630:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800632:	83 ef 01             	sub    $0x1,%edi
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	85 ff                	test   %edi,%edi
  80063a:	7f ed                	jg     800629 <vprintfmt+0x1c0>
  80063c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80063f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800642:	85 c9                	test   %ecx,%ecx
  800644:	b8 00 00 00 00       	mov    $0x0,%eax
  800649:	0f 49 c1             	cmovns %ecx,%eax
  80064c:	29 c1                	sub    %eax,%ecx
  80064e:	89 75 08             	mov    %esi,0x8(%ebp)
  800651:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800654:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800657:	89 cb                	mov    %ecx,%ebx
  800659:	eb 4d                	jmp    8006a8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80065b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80065f:	74 1b                	je     80067c <vprintfmt+0x213>
  800661:	0f be c0             	movsbl %al,%eax
  800664:	83 e8 20             	sub    $0x20,%eax
  800667:	83 f8 5e             	cmp    $0x5e,%eax
  80066a:	76 10                	jbe    80067c <vprintfmt+0x213>
					putch('?', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	ff 75 0c             	pushl  0xc(%ebp)
  800672:	6a 3f                	push   $0x3f
  800674:	ff 55 08             	call   *0x8(%ebp)
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	eb 0d                	jmp    800689 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	ff 75 0c             	pushl  0xc(%ebp)
  800682:	52                   	push   %edx
  800683:	ff 55 08             	call   *0x8(%ebp)
  800686:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800689:	83 eb 01             	sub    $0x1,%ebx
  80068c:	eb 1a                	jmp    8006a8 <vprintfmt+0x23f>
  80068e:	89 75 08             	mov    %esi,0x8(%ebp)
  800691:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800694:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800697:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80069a:	eb 0c                	jmp    8006a8 <vprintfmt+0x23f>
  80069c:	89 75 08             	mov    %esi,0x8(%ebp)
  80069f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006a8:	83 c7 01             	add    $0x1,%edi
  8006ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006af:	0f be d0             	movsbl %al,%edx
  8006b2:	85 d2                	test   %edx,%edx
  8006b4:	74 23                	je     8006d9 <vprintfmt+0x270>
  8006b6:	85 f6                	test   %esi,%esi
  8006b8:	78 a1                	js     80065b <vprintfmt+0x1f2>
  8006ba:	83 ee 01             	sub    $0x1,%esi
  8006bd:	79 9c                	jns    80065b <vprintfmt+0x1f2>
  8006bf:	89 df                	mov    %ebx,%edi
  8006c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c7:	eb 18                	jmp    8006e1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 20                	push   $0x20
  8006cf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d1:	83 ef 01             	sub    $0x1,%edi
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	eb 08                	jmp    8006e1 <vprintfmt+0x278>
  8006d9:	89 df                	mov    %ebx,%edi
  8006db:	8b 75 08             	mov    0x8(%ebp),%esi
  8006de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e1:	85 ff                	test   %edi,%edi
  8006e3:	7f e4                	jg     8006c9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e8:	e9 a2 fd ff ff       	jmp    80048f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ed:	83 fa 01             	cmp    $0x1,%edx
  8006f0:	7e 16                	jle    800708 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 08             	lea    0x8(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 50 04             	mov    0x4(%eax),%edx
  8006fe:	8b 00                	mov    (%eax),%eax
  800700:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800703:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800706:	eb 32                	jmp    80073a <vprintfmt+0x2d1>
	else if (lflag)
  800708:	85 d2                	test   %edx,%edx
  80070a:	74 18                	je     800724 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8d 50 04             	lea    0x4(%eax),%edx
  800712:	89 55 14             	mov    %edx,0x14(%ebp)
  800715:	8b 00                	mov    (%eax),%eax
  800717:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071a:	89 c1                	mov    %eax,%ecx
  80071c:	c1 f9 1f             	sar    $0x1f,%ecx
  80071f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800722:	eb 16                	jmp    80073a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800732:	89 c1                	mov    %eax,%ecx
  800734:	c1 f9 1f             	sar    $0x1f,%ecx
  800737:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80073a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80073d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800745:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800749:	79 74                	jns    8007bf <vprintfmt+0x356>
				putch('-', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	53                   	push   %ebx
  80074f:	6a 2d                	push   $0x2d
  800751:	ff d6                	call   *%esi
				num = -(long long) num;
  800753:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800756:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800759:	f7 d8                	neg    %eax
  80075b:	83 d2 00             	adc    $0x0,%edx
  80075e:	f7 da                	neg    %edx
  800760:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800763:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800768:	eb 55                	jmp    8007bf <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
  80076d:	e8 83 fc ff ff       	call   8003f5 <getuint>
			base = 10;
  800772:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800777:	eb 46                	jmp    8007bf <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800779:	8d 45 14             	lea    0x14(%ebp),%eax
  80077c:	e8 74 fc ff ff       	call   8003f5 <getuint>
			base = 8;
  800781:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800786:	eb 37                	jmp    8007bf <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	53                   	push   %ebx
  80078c:	6a 30                	push   $0x30
  80078e:	ff d6                	call   *%esi
			putch('x', putdat);
  800790:	83 c4 08             	add    $0x8,%esp
  800793:	53                   	push   %ebx
  800794:	6a 78                	push   $0x78
  800796:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 50 04             	lea    0x4(%eax),%edx
  80079e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ab:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007b0:	eb 0d                	jmp    8007bf <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b5:	e8 3b fc ff ff       	call   8003f5 <getuint>
			base = 16;
  8007ba:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bf:	83 ec 0c             	sub    $0xc,%esp
  8007c2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c6:	57                   	push   %edi
  8007c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ca:	51                   	push   %ecx
  8007cb:	52                   	push   %edx
  8007cc:	50                   	push   %eax
  8007cd:	89 da                	mov    %ebx,%edx
  8007cf:	89 f0                	mov    %esi,%eax
  8007d1:	e8 70 fb ff ff       	call   800346 <printnum>
			break;
  8007d6:	83 c4 20             	add    $0x20,%esp
  8007d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007dc:	e9 ae fc ff ff       	jmp    80048f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e1:	83 ec 08             	sub    $0x8,%esp
  8007e4:	53                   	push   %ebx
  8007e5:	51                   	push   %ecx
  8007e6:	ff d6                	call   *%esi
			break;
  8007e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ee:	e9 9c fc ff ff       	jmp    80048f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	6a 25                	push   $0x25
  8007f9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb 03                	jmp    800803 <vprintfmt+0x39a>
  800800:	83 ef 01             	sub    $0x1,%edi
  800803:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800807:	75 f7                	jne    800800 <vprintfmt+0x397>
  800809:	e9 81 fc ff ff       	jmp    80048f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80080e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5f                   	pop    %edi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 18             	sub    $0x18,%esp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800822:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800825:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800829:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800833:	85 c0                	test   %eax,%eax
  800835:	74 26                	je     80085d <vsnprintf+0x47>
  800837:	85 d2                	test   %edx,%edx
  800839:	7e 22                	jle    80085d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083b:	ff 75 14             	pushl  0x14(%ebp)
  80083e:	ff 75 10             	pushl  0x10(%ebp)
  800841:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800844:	50                   	push   %eax
  800845:	68 2f 04 80 00       	push   $0x80042f
  80084a:	e8 1a fc ff ff       	call   800469 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800852:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800855:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	eb 05                	jmp    800862 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80086a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086d:	50                   	push   %eax
  80086e:	ff 75 10             	pushl  0x10(%ebp)
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 9a ff ff ff       	call   800816 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
  800889:	eb 03                	jmp    80088e <strlen+0x10>
		n++;
  80088b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800892:	75 f7                	jne    80088b <strlen+0xd>
		n++;
	return n;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089f:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a4:	eb 03                	jmp    8008a9 <strnlen+0x13>
		n++;
  8008a6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a9:	39 c2                	cmp    %eax,%edx
  8008ab:	74 08                	je     8008b5 <strnlen+0x1f>
  8008ad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008b1:	75 f3                	jne    8008a6 <strnlen+0x10>
  8008b3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	83 c2 01             	add    $0x1,%edx
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	75 ef                	jne    8008c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008de:	53                   	push   %ebx
  8008df:	e8 9a ff ff ff       	call   80087e <strlen>
  8008e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	01 d8                	add    %ebx,%eax
  8008ec:	50                   	push   %eax
  8008ed:	e8 c5 ff ff ff       	call   8008b7 <strcpy>
	return dst;
}
  8008f2:	89 d8                	mov    %ebx,%eax
  8008f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    

008008f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800901:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800904:	89 f3                	mov    %esi,%ebx
  800906:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800909:	89 f2                	mov    %esi,%edx
  80090b:	eb 0f                	jmp    80091c <strncpy+0x23>
		*dst++ = *src;
  80090d:	83 c2 01             	add    $0x1,%edx
  800910:	0f b6 01             	movzbl (%ecx),%eax
  800913:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800916:	80 39 01             	cmpb   $0x1,(%ecx)
  800919:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091c:	39 da                	cmp    %ebx,%edx
  80091e:	75 ed                	jne    80090d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800920:	89 f0                	mov    %esi,%eax
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 75 08             	mov    0x8(%ebp),%esi
  80092e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800931:	8b 55 10             	mov    0x10(%ebp),%edx
  800934:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800936:	85 d2                	test   %edx,%edx
  800938:	74 21                	je     80095b <strlcpy+0x35>
  80093a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093e:	89 f2                	mov    %esi,%edx
  800940:	eb 09                	jmp    80094b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800942:	83 c2 01             	add    $0x1,%edx
  800945:	83 c1 01             	add    $0x1,%ecx
  800948:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80094b:	39 c2                	cmp    %eax,%edx
  80094d:	74 09                	je     800958 <strlcpy+0x32>
  80094f:	0f b6 19             	movzbl (%ecx),%ebx
  800952:	84 db                	test   %bl,%bl
  800954:	75 ec                	jne    800942 <strlcpy+0x1c>
  800956:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800958:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095b:	29 f0                	sub    %esi,%eax
}
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096a:	eb 06                	jmp    800972 <strcmp+0x11>
		p++, q++;
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	84 c0                	test   %al,%al
  800977:	74 04                	je     80097d <strcmp+0x1c>
  800979:	3a 02                	cmp    (%edx),%al
  80097b:	74 ef                	je     80096c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097d:	0f b6 c0             	movzbl %al,%eax
  800980:	0f b6 12             	movzbl (%edx),%edx
  800983:	29 d0                	sub    %edx,%eax
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	89 c3                	mov    %eax,%ebx
  800993:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800996:	eb 06                	jmp    80099e <strncmp+0x17>
		n--, p++, q++;
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099e:	39 d8                	cmp    %ebx,%eax
  8009a0:	74 15                	je     8009b7 <strncmp+0x30>
  8009a2:	0f b6 08             	movzbl (%eax),%ecx
  8009a5:	84 c9                	test   %cl,%cl
  8009a7:	74 04                	je     8009ad <strncmp+0x26>
  8009a9:	3a 0a                	cmp    (%edx),%cl
  8009ab:	74 eb                	je     800998 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ad:	0f b6 00             	movzbl (%eax),%eax
  8009b0:	0f b6 12             	movzbl (%edx),%edx
  8009b3:	29 d0                	sub    %edx,%eax
  8009b5:	eb 05                	jmp    8009bc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c9:	eb 07                	jmp    8009d2 <strchr+0x13>
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 0f                	je     8009de <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	0f b6 10             	movzbl (%eax),%edx
  8009d5:	84 d2                	test   %dl,%dl
  8009d7:	75 f2                	jne    8009cb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ea:	eb 03                	jmp    8009ef <strfind+0xf>
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	74 04                	je     8009fa <strfind+0x1a>
  8009f6:	84 d2                	test   %dl,%dl
  8009f8:	75 f2                	jne    8009ec <strfind+0xc>
			break;
	return (char *) s;
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a08:	85 c9                	test   %ecx,%ecx
  800a0a:	74 36                	je     800a42 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a12:	75 28                	jne    800a3c <memset+0x40>
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 23                	jne    800a3c <memset+0x40>
		c &= 0xFF;
  800a19:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1d:	89 d3                	mov    %edx,%ebx
  800a1f:	c1 e3 08             	shl    $0x8,%ebx
  800a22:	89 d6                	mov    %edx,%esi
  800a24:	c1 e6 18             	shl    $0x18,%esi
  800a27:	89 d0                	mov    %edx,%eax
  800a29:	c1 e0 10             	shl    $0x10,%eax
  800a2c:	09 f0                	or     %esi,%eax
  800a2e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a30:	89 d8                	mov    %ebx,%eax
  800a32:	09 d0                	or     %edx,%eax
  800a34:	c1 e9 02             	shr    $0x2,%ecx
  800a37:	fc                   	cld    
  800a38:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3a:	eb 06                	jmp    800a42 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	fc                   	cld    
  800a40:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a42:	89 f8                	mov    %edi,%eax
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a57:	39 c6                	cmp    %eax,%esi
  800a59:	73 35                	jae    800a90 <memmove+0x47>
  800a5b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5e:	39 d0                	cmp    %edx,%eax
  800a60:	73 2e                	jae    800a90 <memmove+0x47>
		s += n;
		d += n;
  800a62:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a65:	89 d6                	mov    %edx,%esi
  800a67:	09 fe                	or     %edi,%esi
  800a69:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6f:	75 13                	jne    800a84 <memmove+0x3b>
  800a71:	f6 c1 03             	test   $0x3,%cl
  800a74:	75 0e                	jne    800a84 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a76:	83 ef 04             	sub    $0x4,%edi
  800a79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
  800a7f:	fd                   	std    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 09                	jmp    800a8d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a84:	83 ef 01             	sub    $0x1,%edi
  800a87:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a8a:	fd                   	std    
  800a8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8d:	fc                   	cld    
  800a8e:	eb 1d                	jmp    800aad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a90:	89 f2                	mov    %esi,%edx
  800a92:	09 c2                	or     %eax,%edx
  800a94:	f6 c2 03             	test   $0x3,%dl
  800a97:	75 0f                	jne    800aa8 <memmove+0x5f>
  800a99:	f6 c1 03             	test   $0x3,%cl
  800a9c:	75 0a                	jne    800aa8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
  800aa1:	89 c7                	mov    %eax,%edi
  800aa3:	fc                   	cld    
  800aa4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa6:	eb 05                	jmp    800aad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa8:	89 c7                	mov    %eax,%edi
  800aaa:	fc                   	cld    
  800aab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab4:	ff 75 10             	pushl  0x10(%ebp)
  800ab7:	ff 75 0c             	pushl  0xc(%ebp)
  800aba:	ff 75 08             	pushl  0x8(%ebp)
  800abd:	e8 87 ff ff ff       	call   800a49 <memmove>
}
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad4:	eb 1a                	jmp    800af0 <memcmp+0x2c>
		if (*s1 != *s2)
  800ad6:	0f b6 08             	movzbl (%eax),%ecx
  800ad9:	0f b6 1a             	movzbl (%edx),%ebx
  800adc:	38 d9                	cmp    %bl,%cl
  800ade:	74 0a                	je     800aea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae0:	0f b6 c1             	movzbl %cl,%eax
  800ae3:	0f b6 db             	movzbl %bl,%ebx
  800ae6:	29 d8                	sub    %ebx,%eax
  800ae8:	eb 0f                	jmp    800af9 <memcmp+0x35>
		s1++, s2++;
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af0:	39 f0                	cmp    %esi,%eax
  800af2:	75 e2                	jne    800ad6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	53                   	push   %ebx
  800b01:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b04:	89 c1                	mov    %eax,%ecx
  800b06:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b09:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0d:	eb 0a                	jmp    800b19 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0f:	0f b6 10             	movzbl (%eax),%edx
  800b12:	39 da                	cmp    %ebx,%edx
  800b14:	74 07                	je     800b1d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b16:	83 c0 01             	add    $0x1,%eax
  800b19:	39 c8                	cmp    %ecx,%eax
  800b1b:	72 f2                	jb     800b0f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2c:	eb 03                	jmp    800b31 <strtol+0x11>
		s++;
  800b2e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b31:	0f b6 01             	movzbl (%ecx),%eax
  800b34:	3c 20                	cmp    $0x20,%al
  800b36:	74 f6                	je     800b2e <strtol+0xe>
  800b38:	3c 09                	cmp    $0x9,%al
  800b3a:	74 f2                	je     800b2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3c:	3c 2b                	cmp    $0x2b,%al
  800b3e:	75 0a                	jne    800b4a <strtol+0x2a>
		s++;
  800b40:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b43:	bf 00 00 00 00       	mov    $0x0,%edi
  800b48:	eb 11                	jmp    800b5b <strtol+0x3b>
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4f:	3c 2d                	cmp    $0x2d,%al
  800b51:	75 08                	jne    800b5b <strtol+0x3b>
		s++, neg = 1;
  800b53:	83 c1 01             	add    $0x1,%ecx
  800b56:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b61:	75 15                	jne    800b78 <strtol+0x58>
  800b63:	80 39 30             	cmpb   $0x30,(%ecx)
  800b66:	75 10                	jne    800b78 <strtol+0x58>
  800b68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6c:	75 7c                	jne    800bea <strtol+0xca>
		s += 2, base = 16;
  800b6e:	83 c1 02             	add    $0x2,%ecx
  800b71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b76:	eb 16                	jmp    800b8e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b78:	85 db                	test   %ebx,%ebx
  800b7a:	75 12                	jne    800b8e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b81:	80 39 30             	cmpb   $0x30,(%ecx)
  800b84:	75 08                	jne    800b8e <strtol+0x6e>
		s++, base = 8;
  800b86:	83 c1 01             	add    $0x1,%ecx
  800b89:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b93:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b96:	0f b6 11             	movzbl (%ecx),%edx
  800b99:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b9c:	89 f3                	mov    %esi,%ebx
  800b9e:	80 fb 09             	cmp    $0x9,%bl
  800ba1:	77 08                	ja     800bab <strtol+0x8b>
			dig = *s - '0';
  800ba3:	0f be d2             	movsbl %dl,%edx
  800ba6:	83 ea 30             	sub    $0x30,%edx
  800ba9:	eb 22                	jmp    800bcd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bab:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bae:	89 f3                	mov    %esi,%ebx
  800bb0:	80 fb 19             	cmp    $0x19,%bl
  800bb3:	77 08                	ja     800bbd <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bb5:	0f be d2             	movsbl %dl,%edx
  800bb8:	83 ea 57             	sub    $0x57,%edx
  800bbb:	eb 10                	jmp    800bcd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bbd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc0:	89 f3                	mov    %esi,%ebx
  800bc2:	80 fb 19             	cmp    $0x19,%bl
  800bc5:	77 16                	ja     800bdd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc7:	0f be d2             	movsbl %dl,%edx
  800bca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bcd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd0:	7d 0b                	jge    800bdd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bd2:	83 c1 01             	add    $0x1,%ecx
  800bd5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bdb:	eb b9                	jmp    800b96 <strtol+0x76>

	if (endptr)
  800bdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be1:	74 0d                	je     800bf0 <strtol+0xd0>
		*endptr = (char *) s;
  800be3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be6:	89 0e                	mov    %ecx,(%esi)
  800be8:	eb 06                	jmp    800bf0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bea:	85 db                	test   %ebx,%ebx
  800bec:	74 98                	je     800b86 <strtol+0x66>
  800bee:	eb 9e                	jmp    800b8e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf0:	89 c2                	mov    %eax,%edx
  800bf2:	f7 da                	neg    %edx
  800bf4:	85 ff                	test   %edi,%edi
  800bf6:	0f 45 c2             	cmovne %edx,%eax
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	89 c3                	mov    %eax,%ebx
  800c11:	89 c7                	mov    %eax,%edi
  800c13:	89 c6                	mov    %eax,%esi
  800c15:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2c:	89 d1                	mov    %edx,%ecx
  800c2e:	89 d3                	mov    %edx,%ebx
  800c30:	89 d7                	mov    %edx,%edi
  800c32:	89 d6                	mov    %edx,%esi
  800c34:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c49:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	89 cb                	mov    %ecx,%ebx
  800c53:	89 cf                	mov    %ecx,%edi
  800c55:	89 ce                	mov    %ecx,%esi
  800c57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 03                	push   $0x3
  800c63:	68 3f 27 80 00       	push   $0x80273f
  800c68:	6a 23                	push   $0x23
  800c6a:	68 5c 27 80 00       	push   $0x80275c
  800c6f:	e8 e5 f5 ff ff       	call   800259 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8c:	89 d1                	mov    %edx,%ecx
  800c8e:	89 d3                	mov    %edx,%ebx
  800c90:	89 d7                	mov    %edx,%edi
  800c92:	89 d6                	mov    %edx,%esi
  800c94:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_yield>:

void
sys_yield(void)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cab:	89 d1                	mov    %edx,%ecx
  800cad:	89 d3                	mov    %edx,%ebx
  800caf:	89 d7                	mov    %edx,%edi
  800cb1:	89 d6                	mov    %edx,%esi
  800cb3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	be 00 00 00 00       	mov    $0x0,%esi
  800cc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd6:	89 f7                	mov    %esi,%edi
  800cd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 17                	jle    800cf5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 04                	push   $0x4
  800ce4:	68 3f 27 80 00       	push   $0x80273f
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 5c 27 80 00       	push   $0x80275c
  800cf0:	e8 64 f5 ff ff       	call   800259 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d17:	8b 75 18             	mov    0x18(%ebp),%esi
  800d1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 17                	jle    800d37 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 05                	push   $0x5
  800d26:	68 3f 27 80 00       	push   $0x80273f
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 5c 27 80 00       	push   $0x80275c
  800d32:	e8 22 f5 ff ff       	call   800259 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 17                	jle    800d79 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	50                   	push   %eax
  800d66:	6a 06                	push   $0x6
  800d68:	68 3f 27 80 00       	push   $0x80273f
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 5c 27 80 00       	push   $0x80275c
  800d74:	e8 e0 f4 ff ff       	call   800259 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 df                	mov    %ebx,%edi
  800d9c:	89 de                	mov    %ebx,%esi
  800d9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 17                	jle    800dbb <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	50                   	push   %eax
  800da8:	6a 08                	push   $0x8
  800daa:	68 3f 27 80 00       	push   $0x80273f
  800daf:	6a 23                	push   $0x23
  800db1:	68 5c 27 80 00       	push   $0x80275c
  800db6:	e8 9e f4 ff ff       	call   800259 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd1:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 df                	mov    %ebx,%edi
  800dde:	89 de                	mov    %ebx,%esi
  800de0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 09                	push   $0x9
  800dec:	68 3f 27 80 00       	push   $0x80273f
  800df1:	6a 23                	push   $0x23
  800df3:	68 5c 27 80 00       	push   $0x80275c
  800df8:	e8 5c f4 ff ff       	call   800259 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e13:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 df                	mov    %ebx,%edi
  800e20:	89 de                	mov    %ebx,%esi
  800e22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 17                	jle    800e3f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 0a                	push   $0xa
  800e2e:	68 3f 27 80 00       	push   $0x80273f
  800e33:	6a 23                	push   $0x23
  800e35:	68 5c 27 80 00       	push   $0x80275c
  800e3a:	e8 1a f4 ff ff       	call   800259 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4d:	be 00 00 00 00       	mov    $0x0,%esi
  800e52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e63:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e78:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	89 cb                	mov    %ecx,%ebx
  800e82:	89 cf                	mov    %ecx,%edi
  800e84:	89 ce                	mov    %ecx,%esi
  800e86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 17                	jle    800ea3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	50                   	push   %eax
  800e90:	6a 0d                	push   $0xd
  800e92:	68 3f 27 80 00       	push   $0x80273f
  800e97:	6a 23                	push   $0x23
  800e99:	68 5c 27 80 00       	push   $0x80275c
  800e9e:	e8 b6 f3 ff ff       	call   800259 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 cb                	mov    %ecx,%ebx
  800ec0:	89 cf                	mov    %ecx,%edi
  800ec2:	89 ce                	mov    %ecx,%esi
  800ec4:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed6:	b8 0f 00 00 00       	mov    $0xf,%eax
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	89 cb                	mov    %ecx,%ebx
  800ee0:	89 cf                	mov    %ecx,%edi
  800ee2:	89 ce                	mov    %ecx,%esi
  800ee4:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	53                   	push   %ebx
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800ef7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800efb:	74 11                	je     800f0e <pgfault+0x23>
  800efd:	89 d8                	mov    %ebx,%eax
  800eff:	c1 e8 0c             	shr    $0xc,%eax
  800f02:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f09:	f6 c4 08             	test   $0x8,%ah
  800f0c:	75 14                	jne    800f22 <pgfault+0x37>
		panic("faulting access");
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	68 6a 27 80 00       	push   $0x80276a
  800f16:	6a 1e                	push   $0x1e
  800f18:	68 7a 27 80 00       	push   $0x80277a
  800f1d:	e8 37 f3 ff ff       	call   800259 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	6a 07                	push   $0x7
  800f27:	68 00 f0 7f 00       	push   $0x7ff000
  800f2c:	6a 00                	push   $0x0
  800f2e:	e8 87 fd ff ff       	call   800cba <sys_page_alloc>
	if (r < 0) {
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	79 12                	jns    800f4c <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f3a:	50                   	push   %eax
  800f3b:	68 85 27 80 00       	push   $0x802785
  800f40:	6a 2c                	push   $0x2c
  800f42:	68 7a 27 80 00       	push   $0x80277a
  800f47:	e8 0d f3 ff ff       	call   800259 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f4c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f52:	83 ec 04             	sub    $0x4,%esp
  800f55:	68 00 10 00 00       	push   $0x1000
  800f5a:	53                   	push   %ebx
  800f5b:	68 00 f0 7f 00       	push   $0x7ff000
  800f60:	e8 4c fb ff ff       	call   800ab1 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f65:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f6c:	53                   	push   %ebx
  800f6d:	6a 00                	push   $0x0
  800f6f:	68 00 f0 7f 00       	push   $0x7ff000
  800f74:	6a 00                	push   $0x0
  800f76:	e8 82 fd ff ff       	call   800cfd <sys_page_map>
	if (r < 0) {
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	79 12                	jns    800f94 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f82:	50                   	push   %eax
  800f83:	68 85 27 80 00       	push   $0x802785
  800f88:	6a 33                	push   $0x33
  800f8a:	68 7a 27 80 00       	push   $0x80277a
  800f8f:	e8 c5 f2 ff ff       	call   800259 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f94:	83 ec 08             	sub    $0x8,%esp
  800f97:	68 00 f0 7f 00       	push   $0x7ff000
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 9c fd ff ff       	call   800d3f <sys_page_unmap>
	if (r < 0) {
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 12                	jns    800fbc <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800faa:	50                   	push   %eax
  800fab:	68 85 27 80 00       	push   $0x802785
  800fb0:	6a 37                	push   $0x37
  800fb2:	68 7a 27 80 00       	push   $0x80277a
  800fb7:	e8 9d f2 ff ff       	call   800259 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	57                   	push   %edi
  800fc5:	56                   	push   %esi
  800fc6:	53                   	push   %ebx
  800fc7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800fca:	68 eb 0e 80 00       	push   $0x800eeb
  800fcf:	e8 f3 0e 00 00       	call   801ec7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd4:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd9:	cd 30                	int    $0x30
  800fdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 17                	jns    800ffc <fork+0x3b>
		panic("fork fault %e");
  800fe5:	83 ec 04             	sub    $0x4,%esp
  800fe8:	68 9e 27 80 00       	push   $0x80279e
  800fed:	68 84 00 00 00       	push   $0x84
  800ff2:	68 7a 27 80 00       	push   $0x80277a
  800ff7:	e8 5d f2 ff ff       	call   800259 <_panic>
  800ffc:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800ffe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801002:	75 25                	jne    801029 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801004:	e8 73 fc ff ff       	call   800c7c <sys_getenvid>
  801009:	25 ff 03 00 00       	and    $0x3ff,%eax
  80100e:	89 c2                	mov    %eax,%edx
  801010:	c1 e2 07             	shl    $0x7,%edx
  801013:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80101a:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
  801024:	e9 61 01 00 00       	jmp    80118a <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	6a 07                	push   $0x7
  80102e:	68 00 f0 bf ee       	push   $0xeebff000
  801033:	ff 75 e4             	pushl  -0x1c(%ebp)
  801036:	e8 7f fc ff ff       	call   800cba <sys_page_alloc>
  80103b:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80103e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801043:	89 d8                	mov    %ebx,%eax
  801045:	c1 e8 16             	shr    $0x16,%eax
  801048:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104f:	a8 01                	test   $0x1,%al
  801051:	0f 84 fc 00 00 00    	je     801153 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801057:	89 d8                	mov    %ebx,%eax
  801059:	c1 e8 0c             	shr    $0xc,%eax
  80105c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801063:	f6 c2 01             	test   $0x1,%dl
  801066:	0f 84 e7 00 00 00    	je     801153 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80106c:	89 c6                	mov    %eax,%esi
  80106e:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801071:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801078:	f6 c6 04             	test   $0x4,%dh
  80107b:	74 39                	je     8010b6 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80107d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	25 07 0e 00 00       	and    $0xe07,%eax
  80108c:	50                   	push   %eax
  80108d:	56                   	push   %esi
  80108e:	57                   	push   %edi
  80108f:	56                   	push   %esi
  801090:	6a 00                	push   $0x0
  801092:	e8 66 fc ff ff       	call   800cfd <sys_page_map>
		if (r < 0) {
  801097:	83 c4 20             	add    $0x20,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	0f 89 b1 00 00 00    	jns    801153 <fork+0x192>
		    	panic("sys page map fault %e");
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	68 ac 27 80 00       	push   $0x8027ac
  8010aa:	6a 54                	push   $0x54
  8010ac:	68 7a 27 80 00       	push   $0x80277a
  8010b1:	e8 a3 f1 ff ff       	call   800259 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010b6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bd:	f6 c2 02             	test   $0x2,%dl
  8010c0:	75 0c                	jne    8010ce <fork+0x10d>
  8010c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c9:	f6 c4 08             	test   $0x8,%ah
  8010cc:	74 5b                	je     801129 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	68 05 08 00 00       	push   $0x805
  8010d6:	56                   	push   %esi
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	6a 00                	push   $0x0
  8010db:	e8 1d fc ff ff       	call   800cfd <sys_page_map>
		if (r < 0) {
  8010e0:	83 c4 20             	add    $0x20,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	79 14                	jns    8010fb <fork+0x13a>
		    	panic("sys page map fault %e");
  8010e7:	83 ec 04             	sub    $0x4,%esp
  8010ea:	68 ac 27 80 00       	push   $0x8027ac
  8010ef:	6a 5b                	push   $0x5b
  8010f1:	68 7a 27 80 00       	push   $0x80277a
  8010f6:	e8 5e f1 ff ff       	call   800259 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	68 05 08 00 00       	push   $0x805
  801103:	56                   	push   %esi
  801104:	6a 00                	push   $0x0
  801106:	56                   	push   %esi
  801107:	6a 00                	push   $0x0
  801109:	e8 ef fb ff ff       	call   800cfd <sys_page_map>
		if (r < 0) {
  80110e:	83 c4 20             	add    $0x20,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	79 3e                	jns    801153 <fork+0x192>
		    	panic("sys page map fault %e");
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	68 ac 27 80 00       	push   $0x8027ac
  80111d:	6a 5f                	push   $0x5f
  80111f:	68 7a 27 80 00       	push   $0x80277a
  801124:	e8 30 f1 ff ff       	call   800259 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801129:	83 ec 0c             	sub    $0xc,%esp
  80112c:	6a 05                	push   $0x5
  80112e:	56                   	push   %esi
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	6a 00                	push   $0x0
  801133:	e8 c5 fb ff ff       	call   800cfd <sys_page_map>
		if (r < 0) {
  801138:	83 c4 20             	add    $0x20,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	79 14                	jns    801153 <fork+0x192>
		    	panic("sys page map fault %e");
  80113f:	83 ec 04             	sub    $0x4,%esp
  801142:	68 ac 27 80 00       	push   $0x8027ac
  801147:	6a 64                	push   $0x64
  801149:	68 7a 27 80 00       	push   $0x80277a
  80114e:	e8 06 f1 ff ff       	call   800259 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801153:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801159:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80115f:	0f 85 de fe ff ff    	jne    801043 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801165:	a1 04 40 80 00       	mov    0x804004,%eax
  80116a:	8b 40 70             	mov    0x70(%eax),%eax
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	50                   	push   %eax
  801171:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801174:	57                   	push   %edi
  801175:	e8 8b fc ff ff       	call   800e05 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80117a:	83 c4 08             	add    $0x8,%esp
  80117d:	6a 02                	push   $0x2
  80117f:	57                   	push   %edi
  801180:	e8 fc fb ff ff       	call   800d81 <sys_env_set_status>
	
	return envid;
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80118a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <sfork>:

envid_t
sfork(void)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801195:	b8 00 00 00 00       	mov    $0x0,%eax
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
  8011a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8011a4:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	53                   	push   %ebx
  8011ae:	68 c4 27 80 00       	push   $0x8027c4
  8011b3:	e8 7a f1 ff ff       	call   800332 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011b8:	c7 04 24 1f 02 80 00 	movl   $0x80021f,(%esp)
  8011bf:	e8 e7 fc ff ff       	call   800eab <sys_thread_create>
  8011c4:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011c6:	83 c4 08             	add    $0x8,%esp
  8011c9:	53                   	push   %ebx
  8011ca:	68 c4 27 80 00       	push   $0x8027c4
  8011cf:	e8 5e f1 ff ff       	call   800332 <cprintf>
	return id;
	//return 0;
}
  8011d4:	89 f0                	mov    %esi,%eax
  8011d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d9:	5b                   	pop    %ebx
  8011da:	5e                   	pop    %esi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e8:	c1 e8 0c             	shr    $0xc,%eax
}
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120f:	89 c2                	mov    %eax,%edx
  801211:	c1 ea 16             	shr    $0x16,%edx
  801214:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80121b:	f6 c2 01             	test   $0x1,%dl
  80121e:	74 11                	je     801231 <fd_alloc+0x2d>
  801220:	89 c2                	mov    %eax,%edx
  801222:	c1 ea 0c             	shr    $0xc,%edx
  801225:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122c:	f6 c2 01             	test   $0x1,%dl
  80122f:	75 09                	jne    80123a <fd_alloc+0x36>
			*fd_store = fd;
  801231:	89 01                	mov    %eax,(%ecx)
			return 0;
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
  801238:	eb 17                	jmp    801251 <fd_alloc+0x4d>
  80123a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80123f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801244:	75 c9                	jne    80120f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801246:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80124c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801259:	83 f8 1f             	cmp    $0x1f,%eax
  80125c:	77 36                	ja     801294 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125e:	c1 e0 0c             	shl    $0xc,%eax
  801261:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801266:	89 c2                	mov    %eax,%edx
  801268:	c1 ea 16             	shr    $0x16,%edx
  80126b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801272:	f6 c2 01             	test   $0x1,%dl
  801275:	74 24                	je     80129b <fd_lookup+0x48>
  801277:	89 c2                	mov    %eax,%edx
  801279:	c1 ea 0c             	shr    $0xc,%edx
  80127c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801283:	f6 c2 01             	test   $0x1,%dl
  801286:	74 1a                	je     8012a2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801288:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128b:	89 02                	mov    %eax,(%edx)
	return 0;
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	eb 13                	jmp    8012a7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801294:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801299:	eb 0c                	jmp    8012a7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a0:	eb 05                	jmp    8012a7 <fd_lookup+0x54>
  8012a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    

008012a9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	83 ec 08             	sub    $0x8,%esp
  8012af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b2:	ba 68 28 80 00       	mov    $0x802868,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012b7:	eb 13                	jmp    8012cc <dev_lookup+0x23>
  8012b9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012bc:	39 08                	cmp    %ecx,(%eax)
  8012be:	75 0c                	jne    8012cc <dev_lookup+0x23>
			*dev = devtab[i];
  8012c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ca:	eb 2e                	jmp    8012fa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012cc:	8b 02                	mov    (%edx),%eax
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	75 e7                	jne    8012b9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d7:	8b 40 54             	mov    0x54(%eax),%eax
  8012da:	83 ec 04             	sub    $0x4,%esp
  8012dd:	51                   	push   %ecx
  8012de:	50                   	push   %eax
  8012df:	68 e8 27 80 00       	push   $0x8027e8
  8012e4:	e8 49 f0 ff ff       	call   800332 <cprintf>
	*dev = 0;
  8012e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	56                   	push   %esi
  801300:	53                   	push   %ebx
  801301:	83 ec 10             	sub    $0x10,%esp
  801304:	8b 75 08             	mov    0x8(%ebp),%esi
  801307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801314:	c1 e8 0c             	shr    $0xc,%eax
  801317:	50                   	push   %eax
  801318:	e8 36 ff ff ff       	call   801253 <fd_lookup>
  80131d:	83 c4 08             	add    $0x8,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 05                	js     801329 <fd_close+0x2d>
	    || fd != fd2)
  801324:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801327:	74 0c                	je     801335 <fd_close+0x39>
		return (must_exist ? r : 0);
  801329:	84 db                	test   %bl,%bl
  80132b:	ba 00 00 00 00       	mov    $0x0,%edx
  801330:	0f 44 c2             	cmove  %edx,%eax
  801333:	eb 41                	jmp    801376 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 36                	pushl  (%esi)
  80133e:	e8 66 ff ff ff       	call   8012a9 <dev_lookup>
  801343:	89 c3                	mov    %eax,%ebx
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 1a                	js     801366 <fd_close+0x6a>
		if (dev->dev_close)
  80134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801352:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801357:	85 c0                	test   %eax,%eax
  801359:	74 0b                	je     801366 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80135b:	83 ec 0c             	sub    $0xc,%esp
  80135e:	56                   	push   %esi
  80135f:	ff d0                	call   *%eax
  801361:	89 c3                	mov    %eax,%ebx
  801363:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	56                   	push   %esi
  80136a:	6a 00                	push   $0x0
  80136c:	e8 ce f9 ff ff       	call   800d3f <sys_page_unmap>
	return r;
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	89 d8                	mov    %ebx,%eax
}
  801376:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801379:	5b                   	pop    %ebx
  80137a:	5e                   	pop    %esi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801383:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801386:	50                   	push   %eax
  801387:	ff 75 08             	pushl  0x8(%ebp)
  80138a:	e8 c4 fe ff ff       	call   801253 <fd_lookup>
  80138f:	83 c4 08             	add    $0x8,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	78 10                	js     8013a6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	6a 01                	push   $0x1
  80139b:	ff 75 f4             	pushl  -0xc(%ebp)
  80139e:	e8 59 ff ff ff       	call   8012fc <fd_close>
  8013a3:	83 c4 10             	add    $0x10,%esp
}
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    

008013a8 <close_all>:

void
close_all(void)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013af:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b4:	83 ec 0c             	sub    $0xc,%esp
  8013b7:	53                   	push   %ebx
  8013b8:	e8 c0 ff ff ff       	call   80137d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bd:	83 c3 01             	add    $0x1,%ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	83 fb 20             	cmp    $0x20,%ebx
  8013c6:	75 ec                	jne    8013b4 <close_all+0xc>
		close(i);
}
  8013c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	57                   	push   %edi
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 2c             	sub    $0x2c,%esp
  8013d6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013dc:	50                   	push   %eax
  8013dd:	ff 75 08             	pushl  0x8(%ebp)
  8013e0:	e8 6e fe ff ff       	call   801253 <fd_lookup>
  8013e5:	83 c4 08             	add    $0x8,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	0f 88 c1 00 00 00    	js     8014b1 <dup+0xe4>
		return r;
	close(newfdnum);
  8013f0:	83 ec 0c             	sub    $0xc,%esp
  8013f3:	56                   	push   %esi
  8013f4:	e8 84 ff ff ff       	call   80137d <close>

	newfd = INDEX2FD(newfdnum);
  8013f9:	89 f3                	mov    %esi,%ebx
  8013fb:	c1 e3 0c             	shl    $0xc,%ebx
  8013fe:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801404:	83 c4 04             	add    $0x4,%esp
  801407:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140a:	e8 de fd ff ff       	call   8011ed <fd2data>
  80140f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801411:	89 1c 24             	mov    %ebx,(%esp)
  801414:	e8 d4 fd ff ff       	call   8011ed <fd2data>
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141f:	89 f8                	mov    %edi,%eax
  801421:	c1 e8 16             	shr    $0x16,%eax
  801424:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142b:	a8 01                	test   $0x1,%al
  80142d:	74 37                	je     801466 <dup+0x99>
  80142f:	89 f8                	mov    %edi,%eax
  801431:	c1 e8 0c             	shr    $0xc,%eax
  801434:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143b:	f6 c2 01             	test   $0x1,%dl
  80143e:	74 26                	je     801466 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801440:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801447:	83 ec 0c             	sub    $0xc,%esp
  80144a:	25 07 0e 00 00       	and    $0xe07,%eax
  80144f:	50                   	push   %eax
  801450:	ff 75 d4             	pushl  -0x2c(%ebp)
  801453:	6a 00                	push   $0x0
  801455:	57                   	push   %edi
  801456:	6a 00                	push   $0x0
  801458:	e8 a0 f8 ff ff       	call   800cfd <sys_page_map>
  80145d:	89 c7                	mov    %eax,%edi
  80145f:	83 c4 20             	add    $0x20,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 2e                	js     801494 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801466:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801469:	89 d0                	mov    %edx,%eax
  80146b:	c1 e8 0c             	shr    $0xc,%eax
  80146e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801475:	83 ec 0c             	sub    $0xc,%esp
  801478:	25 07 0e 00 00       	and    $0xe07,%eax
  80147d:	50                   	push   %eax
  80147e:	53                   	push   %ebx
  80147f:	6a 00                	push   $0x0
  801481:	52                   	push   %edx
  801482:	6a 00                	push   $0x0
  801484:	e8 74 f8 ff ff       	call   800cfd <sys_page_map>
  801489:	89 c7                	mov    %eax,%edi
  80148b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80148e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801490:	85 ff                	test   %edi,%edi
  801492:	79 1d                	jns    8014b1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	53                   	push   %ebx
  801498:	6a 00                	push   $0x0
  80149a:	e8 a0 f8 ff ff       	call   800d3f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 93 f8 ff ff       	call   800d3f <sys_page_unmap>
	return r;
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	89 f8                	mov    %edi,%eax
}
  8014b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5f                   	pop    %edi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    

008014b9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	53                   	push   %ebx
  8014bd:	83 ec 14             	sub    $0x14,%esp
  8014c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	53                   	push   %ebx
  8014c8:	e8 86 fd ff ff       	call   801253 <fd_lookup>
  8014cd:	83 c4 08             	add    $0x8,%esp
  8014d0:	89 c2                	mov    %eax,%edx
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 6d                	js     801543 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e0:	ff 30                	pushl  (%eax)
  8014e2:	e8 c2 fd ff ff       	call   8012a9 <dev_lookup>
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 4c                	js     80153a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f1:	8b 42 08             	mov    0x8(%edx),%eax
  8014f4:	83 e0 03             	and    $0x3,%eax
  8014f7:	83 f8 01             	cmp    $0x1,%eax
  8014fa:	75 21                	jne    80151d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801501:	8b 40 54             	mov    0x54(%eax),%eax
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	53                   	push   %ebx
  801508:	50                   	push   %eax
  801509:	68 2c 28 80 00       	push   $0x80282c
  80150e:	e8 1f ee ff ff       	call   800332 <cprintf>
		return -E_INVAL;
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151b:	eb 26                	jmp    801543 <read+0x8a>
	}
	if (!dev->dev_read)
  80151d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801520:	8b 40 08             	mov    0x8(%eax),%eax
  801523:	85 c0                	test   %eax,%eax
  801525:	74 17                	je     80153e <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801527:	83 ec 04             	sub    $0x4,%esp
  80152a:	ff 75 10             	pushl  0x10(%ebp)
  80152d:	ff 75 0c             	pushl  0xc(%ebp)
  801530:	52                   	push   %edx
  801531:	ff d0                	call   *%eax
  801533:	89 c2                	mov    %eax,%edx
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	eb 09                	jmp    801543 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	eb 05                	jmp    801543 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801543:	89 d0                	mov    %edx,%eax
  801545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
  801550:	83 ec 0c             	sub    $0xc,%esp
  801553:	8b 7d 08             	mov    0x8(%ebp),%edi
  801556:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801559:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155e:	eb 21                	jmp    801581 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801560:	83 ec 04             	sub    $0x4,%esp
  801563:	89 f0                	mov    %esi,%eax
  801565:	29 d8                	sub    %ebx,%eax
  801567:	50                   	push   %eax
  801568:	89 d8                	mov    %ebx,%eax
  80156a:	03 45 0c             	add    0xc(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	57                   	push   %edi
  80156f:	e8 45 ff ff ff       	call   8014b9 <read>
		if (m < 0)
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 10                	js     80158b <readn+0x41>
			return m;
		if (m == 0)
  80157b:	85 c0                	test   %eax,%eax
  80157d:	74 0a                	je     801589 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157f:	01 c3                	add    %eax,%ebx
  801581:	39 f3                	cmp    %esi,%ebx
  801583:	72 db                	jb     801560 <readn+0x16>
  801585:	89 d8                	mov    %ebx,%eax
  801587:	eb 02                	jmp    80158b <readn+0x41>
  801589:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80158b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158e:	5b                   	pop    %ebx
  80158f:	5e                   	pop    %esi
  801590:	5f                   	pop    %edi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    

00801593 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 14             	sub    $0x14,%esp
  80159a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	53                   	push   %ebx
  8015a2:	e8 ac fc ff ff       	call   801253 <fd_lookup>
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 68                	js     801618 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ba:	ff 30                	pushl  (%eax)
  8015bc:	e8 e8 fc ff ff       	call   8012a9 <dev_lookup>
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 47                	js     80160f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cf:	75 21                	jne    8015f2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d6:	8b 40 54             	mov    0x54(%eax),%eax
  8015d9:	83 ec 04             	sub    $0x4,%esp
  8015dc:	53                   	push   %ebx
  8015dd:	50                   	push   %eax
  8015de:	68 48 28 80 00       	push   $0x802848
  8015e3:	e8 4a ed ff ff       	call   800332 <cprintf>
		return -E_INVAL;
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f0:	eb 26                	jmp    801618 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f8:	85 d2                	test   %edx,%edx
  8015fa:	74 17                	je     801613 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fc:	83 ec 04             	sub    $0x4,%esp
  8015ff:	ff 75 10             	pushl  0x10(%ebp)
  801602:	ff 75 0c             	pushl  0xc(%ebp)
  801605:	50                   	push   %eax
  801606:	ff d2                	call   *%edx
  801608:	89 c2                	mov    %eax,%edx
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	eb 09                	jmp    801618 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160f:	89 c2                	mov    %eax,%edx
  801611:	eb 05                	jmp    801618 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801613:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801618:	89 d0                	mov    %edx,%eax
  80161a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <seek>:

int
seek(int fdnum, off_t offset)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801625:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	ff 75 08             	pushl  0x8(%ebp)
  80162c:	e8 22 fc ff ff       	call   801253 <fd_lookup>
  801631:	83 c4 08             	add    $0x8,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	78 0e                	js     801646 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801638:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801641:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	53                   	push   %ebx
  80164c:	83 ec 14             	sub    $0x14,%esp
  80164f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801652:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	53                   	push   %ebx
  801657:	e8 f7 fb ff ff       	call   801253 <fd_lookup>
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	89 c2                	mov    %eax,%edx
  801661:	85 c0                	test   %eax,%eax
  801663:	78 65                	js     8016ca <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166f:	ff 30                	pushl  (%eax)
  801671:	e8 33 fc ff ff       	call   8012a9 <dev_lookup>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 44                	js     8016c1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801680:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801684:	75 21                	jne    8016a7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801686:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168b:	8b 40 54             	mov    0x54(%eax),%eax
  80168e:	83 ec 04             	sub    $0x4,%esp
  801691:	53                   	push   %ebx
  801692:	50                   	push   %eax
  801693:	68 08 28 80 00       	push   $0x802808
  801698:	e8 95 ec ff ff       	call   800332 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a5:	eb 23                	jmp    8016ca <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016aa:	8b 52 18             	mov    0x18(%edx),%edx
  8016ad:	85 d2                	test   %edx,%edx
  8016af:	74 14                	je     8016c5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	ff 75 0c             	pushl  0xc(%ebp)
  8016b7:	50                   	push   %eax
  8016b8:	ff d2                	call   *%edx
  8016ba:	89 c2                	mov    %eax,%edx
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	eb 09                	jmp    8016ca <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c1:	89 c2                	mov    %eax,%edx
  8016c3:	eb 05                	jmp    8016ca <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ca:	89 d0                	mov    %edx,%eax
  8016cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	53                   	push   %ebx
  8016d5:	83 ec 14             	sub    $0x14,%esp
  8016d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016de:	50                   	push   %eax
  8016df:	ff 75 08             	pushl  0x8(%ebp)
  8016e2:	e8 6c fb ff ff       	call   801253 <fd_lookup>
  8016e7:	83 c4 08             	add    $0x8,%esp
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 58                	js     801748 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f6:	50                   	push   %eax
  8016f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fa:	ff 30                	pushl  (%eax)
  8016fc:	e8 a8 fb ff ff       	call   8012a9 <dev_lookup>
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	85 c0                	test   %eax,%eax
  801706:	78 37                	js     80173f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170f:	74 32                	je     801743 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801711:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801714:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171b:	00 00 00 
	stat->st_isdir = 0;
  80171e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801725:	00 00 00 
	stat->st_dev = dev;
  801728:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	53                   	push   %ebx
  801732:	ff 75 f0             	pushl  -0x10(%ebp)
  801735:	ff 50 14             	call   *0x14(%eax)
  801738:	89 c2                	mov    %eax,%edx
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	eb 09                	jmp    801748 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173f:	89 c2                	mov    %eax,%edx
  801741:	eb 05                	jmp    801748 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801743:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801748:	89 d0                	mov    %edx,%eax
  80174a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801754:	83 ec 08             	sub    $0x8,%esp
  801757:	6a 00                	push   $0x0
  801759:	ff 75 08             	pushl  0x8(%ebp)
  80175c:	e8 e3 01 00 00       	call   801944 <open>
  801761:	89 c3                	mov    %eax,%ebx
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	85 c0                	test   %eax,%eax
  801768:	78 1b                	js     801785 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	ff 75 0c             	pushl  0xc(%ebp)
  801770:	50                   	push   %eax
  801771:	e8 5b ff ff ff       	call   8016d1 <fstat>
  801776:	89 c6                	mov    %eax,%esi
	close(fd);
  801778:	89 1c 24             	mov    %ebx,(%esp)
  80177b:	e8 fd fb ff ff       	call   80137d <close>
	return r;
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	89 f0                	mov    %esi,%eax
}
  801785:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	89 c6                	mov    %eax,%esi
  801793:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801795:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80179c:	75 12                	jne    8017b0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179e:	83 ec 0c             	sub    $0xc,%esp
  8017a1:	6a 01                	push   $0x1
  8017a3:	e8 88 08 00 00       	call   802030 <ipc_find_env>
  8017a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b0:	6a 07                	push   $0x7
  8017b2:	68 00 50 80 00       	push   $0x805000
  8017b7:	56                   	push   %esi
  8017b8:	ff 35 00 40 80 00    	pushl  0x804000
  8017be:	e8 0b 08 00 00       	call   801fce <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c3:	83 c4 0c             	add    $0xc,%esp
  8017c6:	6a 00                	push   $0x0
  8017c8:	53                   	push   %ebx
  8017c9:	6a 00                	push   $0x0
  8017cb:	e8 86 07 00 00       	call   801f56 <ipc_recv>
}
  8017d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d3:	5b                   	pop    %ebx
  8017d4:	5e                   	pop    %esi
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017eb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017fa:	e8 8d ff ff ff       	call   80178c <fsipc>
}
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    

00801801 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	8b 40 0c             	mov    0xc(%eax),%eax
  80180d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801812:	ba 00 00 00 00       	mov    $0x0,%edx
  801817:	b8 06 00 00 00       	mov    $0x6,%eax
  80181c:	e8 6b ff ff ff       	call   80178c <fsipc>
}
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	53                   	push   %ebx
  801827:	83 ec 04             	sub    $0x4,%esp
  80182a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	8b 40 0c             	mov    0xc(%eax),%eax
  801833:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801838:	ba 00 00 00 00       	mov    $0x0,%edx
  80183d:	b8 05 00 00 00       	mov    $0x5,%eax
  801842:	e8 45 ff ff ff       	call   80178c <fsipc>
  801847:	85 c0                	test   %eax,%eax
  801849:	78 2c                	js     801877 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184b:	83 ec 08             	sub    $0x8,%esp
  80184e:	68 00 50 80 00       	push   $0x805000
  801853:	53                   	push   %ebx
  801854:	e8 5e f0 ff ff       	call   8008b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801859:	a1 80 50 80 00       	mov    0x805080,%eax
  80185e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801864:	a1 84 50 80 00       	mov    0x805084,%eax
  801869:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801877:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 0c             	sub    $0xc,%esp
  801882:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801885:	8b 55 08             	mov    0x8(%ebp),%edx
  801888:	8b 52 0c             	mov    0xc(%edx),%edx
  80188b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801891:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801896:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80189b:	0f 47 c2             	cmova  %edx,%eax
  80189e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018a3:	50                   	push   %eax
  8018a4:	ff 75 0c             	pushl  0xc(%ebp)
  8018a7:	68 08 50 80 00       	push   $0x805008
  8018ac:	e8 98 f1 ff ff       	call   800a49 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018bb:	e8 cc fe ff ff       	call   80178c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	56                   	push   %esi
  8018c6:	53                   	push   %ebx
  8018c7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e5:	e8 a2 fe ff ff       	call   80178c <fsipc>
  8018ea:	89 c3                	mov    %eax,%ebx
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 4b                	js     80193b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018f0:	39 c6                	cmp    %eax,%esi
  8018f2:	73 16                	jae    80190a <devfile_read+0x48>
  8018f4:	68 78 28 80 00       	push   $0x802878
  8018f9:	68 7f 28 80 00       	push   $0x80287f
  8018fe:	6a 7c                	push   $0x7c
  801900:	68 94 28 80 00       	push   $0x802894
  801905:	e8 4f e9 ff ff       	call   800259 <_panic>
	assert(r <= PGSIZE);
  80190a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80190f:	7e 16                	jle    801927 <devfile_read+0x65>
  801911:	68 9f 28 80 00       	push   $0x80289f
  801916:	68 7f 28 80 00       	push   $0x80287f
  80191b:	6a 7d                	push   $0x7d
  80191d:	68 94 28 80 00       	push   $0x802894
  801922:	e8 32 e9 ff ff       	call   800259 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801927:	83 ec 04             	sub    $0x4,%esp
  80192a:	50                   	push   %eax
  80192b:	68 00 50 80 00       	push   $0x805000
  801930:	ff 75 0c             	pushl  0xc(%ebp)
  801933:	e8 11 f1 ff ff       	call   800a49 <memmove>
	return r;
  801938:	83 c4 10             	add    $0x10,%esp
}
  80193b:	89 d8                	mov    %ebx,%eax
  80193d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801940:	5b                   	pop    %ebx
  801941:	5e                   	pop    %esi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	53                   	push   %ebx
  801948:	83 ec 20             	sub    $0x20,%esp
  80194b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80194e:	53                   	push   %ebx
  80194f:	e8 2a ef ff ff       	call   80087e <strlen>
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195c:	7f 67                	jg     8019c5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801964:	50                   	push   %eax
  801965:	e8 9a f8 ff ff       	call   801204 <fd_alloc>
  80196a:	83 c4 10             	add    $0x10,%esp
		return r;
  80196d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 57                	js     8019ca <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	53                   	push   %ebx
  801977:	68 00 50 80 00       	push   $0x805000
  80197c:	e8 36 ef ff ff       	call   8008b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801981:	8b 45 0c             	mov    0xc(%ebp),%eax
  801984:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801989:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198c:	b8 01 00 00 00       	mov    $0x1,%eax
  801991:	e8 f6 fd ff ff       	call   80178c <fsipc>
  801996:	89 c3                	mov    %eax,%ebx
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	79 14                	jns    8019b3 <open+0x6f>
		fd_close(fd, 0);
  80199f:	83 ec 08             	sub    $0x8,%esp
  8019a2:	6a 00                	push   $0x0
  8019a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a7:	e8 50 f9 ff ff       	call   8012fc <fd_close>
		return r;
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	89 da                	mov    %ebx,%edx
  8019b1:	eb 17                	jmp    8019ca <open+0x86>
	}

	return fd2num(fd);
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b9:	e8 1f f8 ff ff       	call   8011dd <fd2num>
  8019be:	89 c2                	mov    %eax,%edx
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	eb 05                	jmp    8019ca <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ca:	89 d0                	mov    %edx,%eax
  8019cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e1:	e8 a6 fd ff ff       	call   80178c <fsipc>
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 75 08             	pushl  0x8(%ebp)
  8019f6:	e8 f2 f7 ff ff       	call   8011ed <fd2data>
  8019fb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019fd:	83 c4 08             	add    $0x8,%esp
  801a00:	68 ab 28 80 00       	push   $0x8028ab
  801a05:	53                   	push   %ebx
  801a06:	e8 ac ee ff ff       	call   8008b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a0b:	8b 46 04             	mov    0x4(%esi),%eax
  801a0e:	2b 06                	sub    (%esi),%eax
  801a10:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a16:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a1d:	00 00 00 
	stat->st_dev = &devpipe;
  801a20:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a27:	30 80 00 
	return 0;
}
  801a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a32:	5b                   	pop    %ebx
  801a33:	5e                   	pop    %esi
  801a34:	5d                   	pop    %ebp
  801a35:	c3                   	ret    

00801a36 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a40:	53                   	push   %ebx
  801a41:	6a 00                	push   $0x0
  801a43:	e8 f7 f2 ff ff       	call   800d3f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a48:	89 1c 24             	mov    %ebx,(%esp)
  801a4b:	e8 9d f7 ff ff       	call   8011ed <fd2data>
  801a50:	83 c4 08             	add    $0x8,%esp
  801a53:	50                   	push   %eax
  801a54:	6a 00                	push   $0x0
  801a56:	e8 e4 f2 ff ff       	call   800d3f <sys_page_unmap>
}
  801a5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	57                   	push   %edi
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	83 ec 1c             	sub    $0x1c,%esp
  801a69:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a6c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a73:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a76:	83 ec 0c             	sub    $0xc,%esp
  801a79:	ff 75 e0             	pushl  -0x20(%ebp)
  801a7c:	e8 ef 05 00 00       	call   802070 <pageref>
  801a81:	89 c3                	mov    %eax,%ebx
  801a83:	89 3c 24             	mov    %edi,(%esp)
  801a86:	e8 e5 05 00 00       	call   802070 <pageref>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	39 c3                	cmp    %eax,%ebx
  801a90:	0f 94 c1             	sete   %cl
  801a93:	0f b6 c9             	movzbl %cl,%ecx
  801a96:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a99:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a9f:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801aa2:	39 ce                	cmp    %ecx,%esi
  801aa4:	74 1b                	je     801ac1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aa6:	39 c3                	cmp    %eax,%ebx
  801aa8:	75 c4                	jne    801a6e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aaa:	8b 42 64             	mov    0x64(%edx),%eax
  801aad:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab0:	50                   	push   %eax
  801ab1:	56                   	push   %esi
  801ab2:	68 b2 28 80 00       	push   $0x8028b2
  801ab7:	e8 76 e8 ff ff       	call   800332 <cprintf>
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	eb ad                	jmp    801a6e <_pipeisclosed+0xe>
	}
}
  801ac1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5f                   	pop    %edi
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	57                   	push   %edi
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 28             	sub    $0x28,%esp
  801ad5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ad8:	56                   	push   %esi
  801ad9:	e8 0f f7 ff ff       	call   8011ed <fd2data>
  801ade:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ae8:	eb 4b                	jmp    801b35 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aea:	89 da                	mov    %ebx,%edx
  801aec:	89 f0                	mov    %esi,%eax
  801aee:	e8 6d ff ff ff       	call   801a60 <_pipeisclosed>
  801af3:	85 c0                	test   %eax,%eax
  801af5:	75 48                	jne    801b3f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801af7:	e8 9f f1 ff ff       	call   800c9b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801afc:	8b 43 04             	mov    0x4(%ebx),%eax
  801aff:	8b 0b                	mov    (%ebx),%ecx
  801b01:	8d 51 20             	lea    0x20(%ecx),%edx
  801b04:	39 d0                	cmp    %edx,%eax
  801b06:	73 e2                	jae    801aea <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b0f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b12:	89 c2                	mov    %eax,%edx
  801b14:	c1 fa 1f             	sar    $0x1f,%edx
  801b17:	89 d1                	mov    %edx,%ecx
  801b19:	c1 e9 1b             	shr    $0x1b,%ecx
  801b1c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b1f:	83 e2 1f             	and    $0x1f,%edx
  801b22:	29 ca                	sub    %ecx,%edx
  801b24:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b28:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b2c:	83 c0 01             	add    $0x1,%eax
  801b2f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b32:	83 c7 01             	add    $0x1,%edi
  801b35:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b38:	75 c2                	jne    801afc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3d:	eb 05                	jmp    801b44 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5f                   	pop    %edi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	57                   	push   %edi
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	83 ec 18             	sub    $0x18,%esp
  801b55:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b58:	57                   	push   %edi
  801b59:	e8 8f f6 ff ff       	call   8011ed <fd2data>
  801b5e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b68:	eb 3d                	jmp    801ba7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b6a:	85 db                	test   %ebx,%ebx
  801b6c:	74 04                	je     801b72 <devpipe_read+0x26>
				return i;
  801b6e:	89 d8                	mov    %ebx,%eax
  801b70:	eb 44                	jmp    801bb6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b72:	89 f2                	mov    %esi,%edx
  801b74:	89 f8                	mov    %edi,%eax
  801b76:	e8 e5 fe ff ff       	call   801a60 <_pipeisclosed>
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	75 32                	jne    801bb1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b7f:	e8 17 f1 ff ff       	call   800c9b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b84:	8b 06                	mov    (%esi),%eax
  801b86:	3b 46 04             	cmp    0x4(%esi),%eax
  801b89:	74 df                	je     801b6a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8b:	99                   	cltd   
  801b8c:	c1 ea 1b             	shr    $0x1b,%edx
  801b8f:	01 d0                	add    %edx,%eax
  801b91:	83 e0 1f             	and    $0x1f,%eax
  801b94:	29 d0                	sub    %edx,%eax
  801b96:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ba1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba4:	83 c3 01             	add    $0x1,%ebx
  801ba7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801baa:	75 d8                	jne    801b84 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bac:	8b 45 10             	mov    0x10(%ebp),%eax
  801baf:	eb 05                	jmp    801bb6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc9:	50                   	push   %eax
  801bca:	e8 35 f6 ff ff       	call   801204 <fd_alloc>
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	89 c2                	mov    %eax,%edx
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	0f 88 2c 01 00 00    	js     801d08 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdc:	83 ec 04             	sub    $0x4,%esp
  801bdf:	68 07 04 00 00       	push   $0x407
  801be4:	ff 75 f4             	pushl  -0xc(%ebp)
  801be7:	6a 00                	push   $0x0
  801be9:	e8 cc f0 ff ff       	call   800cba <sys_page_alloc>
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	89 c2                	mov    %eax,%edx
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	0f 88 0d 01 00 00    	js     801d08 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bfb:	83 ec 0c             	sub    $0xc,%esp
  801bfe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c01:	50                   	push   %eax
  801c02:	e8 fd f5 ff ff       	call   801204 <fd_alloc>
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	0f 88 e2 00 00 00    	js     801cf6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c14:	83 ec 04             	sub    $0x4,%esp
  801c17:	68 07 04 00 00       	push   $0x407
  801c1c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1f:	6a 00                	push   $0x0
  801c21:	e8 94 f0 ff ff       	call   800cba <sys_page_alloc>
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	0f 88 c3 00 00 00    	js     801cf6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c33:	83 ec 0c             	sub    $0xc,%esp
  801c36:	ff 75 f4             	pushl  -0xc(%ebp)
  801c39:	e8 af f5 ff ff       	call   8011ed <fd2data>
  801c3e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c40:	83 c4 0c             	add    $0xc,%esp
  801c43:	68 07 04 00 00       	push   $0x407
  801c48:	50                   	push   %eax
  801c49:	6a 00                	push   $0x0
  801c4b:	e8 6a f0 ff ff       	call   800cba <sys_page_alloc>
  801c50:	89 c3                	mov    %eax,%ebx
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	85 c0                	test   %eax,%eax
  801c57:	0f 88 89 00 00 00    	js     801ce6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5d:	83 ec 0c             	sub    $0xc,%esp
  801c60:	ff 75 f0             	pushl  -0x10(%ebp)
  801c63:	e8 85 f5 ff ff       	call   8011ed <fd2data>
  801c68:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c6f:	50                   	push   %eax
  801c70:	6a 00                	push   $0x0
  801c72:	56                   	push   %esi
  801c73:	6a 00                	push   $0x0
  801c75:	e8 83 f0 ff ff       	call   800cfd <sys_page_map>
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	83 c4 20             	add    $0x20,%esp
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	78 55                	js     801cd8 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c83:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c98:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cad:	83 ec 0c             	sub    $0xc,%esp
  801cb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb3:	e8 25 f5 ff ff       	call   8011dd <fd2num>
  801cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cbd:	83 c4 04             	add    $0x4,%esp
  801cc0:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc3:	e8 15 f5 ff ff       	call   8011dd <fd2num>
  801cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccb:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd6:	eb 30                	jmp    801d08 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cd8:	83 ec 08             	sub    $0x8,%esp
  801cdb:	56                   	push   %esi
  801cdc:	6a 00                	push   $0x0
  801cde:	e8 5c f0 ff ff       	call   800d3f <sys_page_unmap>
  801ce3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ce6:	83 ec 08             	sub    $0x8,%esp
  801ce9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cec:	6a 00                	push   $0x0
  801cee:	e8 4c f0 ff ff       	call   800d3f <sys_page_unmap>
  801cf3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cf6:	83 ec 08             	sub    $0x8,%esp
  801cf9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfc:	6a 00                	push   $0x0
  801cfe:	e8 3c f0 ff ff       	call   800d3f <sys_page_unmap>
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d08:	89 d0                	mov    %edx,%eax
  801d0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1a:	50                   	push   %eax
  801d1b:	ff 75 08             	pushl  0x8(%ebp)
  801d1e:	e8 30 f5 ff ff       	call   801253 <fd_lookup>
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	85 c0                	test   %eax,%eax
  801d28:	78 18                	js     801d42 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d2a:	83 ec 0c             	sub    $0xc,%esp
  801d2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d30:	e8 b8 f4 ff ff       	call   8011ed <fd2data>
	return _pipeisclosed(fd, p);
  801d35:	89 c2                	mov    %eax,%edx
  801d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3a:	e8 21 fd ff ff       	call   801a60 <_pipeisclosed>
  801d3f:	83 c4 10             	add    $0x10,%esp
}
  801d42:	c9                   	leave  
  801d43:	c3                   	ret    

00801d44 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d54:	68 ca 28 80 00       	push   $0x8028ca
  801d59:	ff 75 0c             	pushl  0xc(%ebp)
  801d5c:	e8 56 eb ff ff       	call   8008b7 <strcpy>
	return 0;
}
  801d61:	b8 00 00 00 00       	mov    $0x0,%eax
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	57                   	push   %edi
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d74:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d79:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7f:	eb 2d                	jmp    801dae <devcons_write+0x46>
		m = n - tot;
  801d81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d84:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d86:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d89:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d8e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d91:	83 ec 04             	sub    $0x4,%esp
  801d94:	53                   	push   %ebx
  801d95:	03 45 0c             	add    0xc(%ebp),%eax
  801d98:	50                   	push   %eax
  801d99:	57                   	push   %edi
  801d9a:	e8 aa ec ff ff       	call   800a49 <memmove>
		sys_cputs(buf, m);
  801d9f:	83 c4 08             	add    $0x8,%esp
  801da2:	53                   	push   %ebx
  801da3:	57                   	push   %edi
  801da4:	e8 55 ee ff ff       	call   800bfe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da9:	01 de                	add    %ebx,%esi
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	89 f0                	mov    %esi,%eax
  801db0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db3:	72 cc                	jb     801d81 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801db5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5f                   	pop    %edi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    

00801dbd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dcc:	74 2a                	je     801df8 <devcons_read+0x3b>
  801dce:	eb 05                	jmp    801dd5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dd0:	e8 c6 ee ff ff       	call   800c9b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dd5:	e8 42 ee ff ff       	call   800c1c <sys_cgetc>
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	74 f2                	je     801dd0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 16                	js     801df8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801de2:	83 f8 04             	cmp    $0x4,%eax
  801de5:	74 0c                	je     801df3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801de7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dea:	88 02                	mov    %al,(%edx)
	return 1;
  801dec:	b8 01 00 00 00       	mov    $0x1,%eax
  801df1:	eb 05                	jmp    801df8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801df3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e00:	8b 45 08             	mov    0x8(%ebp),%eax
  801e03:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e06:	6a 01                	push   $0x1
  801e08:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	e8 ed ed ff ff       	call   800bfe <sys_cputs>
}
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <getchar>:

int
getchar(void)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e1c:	6a 01                	push   $0x1
  801e1e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e21:	50                   	push   %eax
  801e22:	6a 00                	push   $0x0
  801e24:	e8 90 f6 ff ff       	call   8014b9 <read>
	if (r < 0)
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	85 c0                	test   %eax,%eax
  801e2e:	78 0f                	js     801e3f <getchar+0x29>
		return r;
	if (r < 1)
  801e30:	85 c0                	test   %eax,%eax
  801e32:	7e 06                	jle    801e3a <getchar+0x24>
		return -E_EOF;
	return c;
  801e34:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e38:	eb 05                	jmp    801e3f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e3a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e3f:	c9                   	leave  
  801e40:	c3                   	ret    

00801e41 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4a:	50                   	push   %eax
  801e4b:	ff 75 08             	pushl  0x8(%ebp)
  801e4e:	e8 00 f4 ff ff       	call   801253 <fd_lookup>
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	85 c0                	test   %eax,%eax
  801e58:	78 11                	js     801e6b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e63:	39 10                	cmp    %edx,(%eax)
  801e65:	0f 94 c0             	sete   %al
  801e68:	0f b6 c0             	movzbl %al,%eax
}
  801e6b:	c9                   	leave  
  801e6c:	c3                   	ret    

00801e6d <opencons>:

int
opencons(void)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e76:	50                   	push   %eax
  801e77:	e8 88 f3 ff ff       	call   801204 <fd_alloc>
  801e7c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e7f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e81:	85 c0                	test   %eax,%eax
  801e83:	78 3e                	js     801ec3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e85:	83 ec 04             	sub    $0x4,%esp
  801e88:	68 07 04 00 00       	push   $0x407
  801e8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e90:	6a 00                	push   $0x0
  801e92:	e8 23 ee ff ff       	call   800cba <sys_page_alloc>
  801e97:	83 c4 10             	add    $0x10,%esp
		return r;
  801e9a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	78 23                	js     801ec3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ea0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb5:	83 ec 0c             	sub    $0xc,%esp
  801eb8:	50                   	push   %eax
  801eb9:	e8 1f f3 ff ff       	call   8011dd <fd2num>
  801ebe:	89 c2                	mov    %eax,%edx
  801ec0:	83 c4 10             	add    $0x10,%esp
}
  801ec3:	89 d0                	mov    %edx,%eax
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ecd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ed4:	75 2a                	jne    801f00 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ed6:	83 ec 04             	sub    $0x4,%esp
  801ed9:	6a 07                	push   $0x7
  801edb:	68 00 f0 bf ee       	push   $0xeebff000
  801ee0:	6a 00                	push   $0x0
  801ee2:	e8 d3 ed ff ff       	call   800cba <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	79 12                	jns    801f00 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801eee:	50                   	push   %eax
  801eef:	68 d6 28 80 00       	push   $0x8028d6
  801ef4:	6a 23                	push   $0x23
  801ef6:	68 da 28 80 00       	push   $0x8028da
  801efb:	e8 59 e3 ff ff       	call   800259 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f00:	8b 45 08             	mov    0x8(%ebp),%eax
  801f03:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f08:	83 ec 08             	sub    $0x8,%esp
  801f0b:	68 32 1f 80 00       	push   $0x801f32
  801f10:	6a 00                	push   $0x0
  801f12:	e8 ee ee ff ff       	call   800e05 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	79 12                	jns    801f30 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f1e:	50                   	push   %eax
  801f1f:	68 d6 28 80 00       	push   $0x8028d6
  801f24:	6a 2c                	push   $0x2c
  801f26:	68 da 28 80 00       	push   $0x8028da
  801f2b:	e8 29 e3 ff ff       	call   800259 <_panic>
	}
}
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f32:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f33:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f38:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f3a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f3d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f41:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f46:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f4a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801f4c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801f4f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f50:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f53:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f54:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f55:	c3                   	ret    

00801f56 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	56                   	push   %esi
  801f5a:	53                   	push   %ebx
  801f5b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801f64:	85 c0                	test   %eax,%eax
  801f66:	75 12                	jne    801f7a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801f68:	83 ec 0c             	sub    $0xc,%esp
  801f6b:	68 00 00 c0 ee       	push   $0xeec00000
  801f70:	e8 f5 ee ff ff       	call   800e6a <sys_ipc_recv>
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	eb 0c                	jmp    801f86 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801f7a:	83 ec 0c             	sub    $0xc,%esp
  801f7d:	50                   	push   %eax
  801f7e:	e8 e7 ee ff ff       	call   800e6a <sys_ipc_recv>
  801f83:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801f86:	85 f6                	test   %esi,%esi
  801f88:	0f 95 c1             	setne  %cl
  801f8b:	85 db                	test   %ebx,%ebx
  801f8d:	0f 95 c2             	setne  %dl
  801f90:	84 d1                	test   %dl,%cl
  801f92:	74 09                	je     801f9d <ipc_recv+0x47>
  801f94:	89 c2                	mov    %eax,%edx
  801f96:	c1 ea 1f             	shr    $0x1f,%edx
  801f99:	84 d2                	test   %dl,%dl
  801f9b:	75 2a                	jne    801fc7 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801f9d:	85 f6                	test   %esi,%esi
  801f9f:	74 0d                	je     801fae <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801fa1:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801fac:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801fae:	85 db                	test   %ebx,%ebx
  801fb0:	74 0d                	je     801fbf <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801fb2:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb7:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801fbd:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fbf:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc4:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801fc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fca:	5b                   	pop    %ebx
  801fcb:	5e                   	pop    %esi
  801fcc:	5d                   	pop    %ebp
  801fcd:	c3                   	ret    

00801fce <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 0c             	sub    $0xc,%esp
  801fd7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fda:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801fe0:	85 db                	test   %ebx,%ebx
  801fe2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fe7:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801fea:	ff 75 14             	pushl  0x14(%ebp)
  801fed:	53                   	push   %ebx
  801fee:	56                   	push   %esi
  801fef:	57                   	push   %edi
  801ff0:	e8 52 ee ff ff       	call   800e47 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ff5:	89 c2                	mov    %eax,%edx
  801ff7:	c1 ea 1f             	shr    $0x1f,%edx
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	84 d2                	test   %dl,%dl
  801fff:	74 17                	je     802018 <ipc_send+0x4a>
  802001:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802004:	74 12                	je     802018 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802006:	50                   	push   %eax
  802007:	68 e8 28 80 00       	push   $0x8028e8
  80200c:	6a 47                	push   $0x47
  80200e:	68 f6 28 80 00       	push   $0x8028f6
  802013:	e8 41 e2 ff ff       	call   800259 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802018:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80201b:	75 07                	jne    802024 <ipc_send+0x56>
			sys_yield();
  80201d:	e8 79 ec ff ff       	call   800c9b <sys_yield>
  802022:	eb c6                	jmp    801fea <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802024:	85 c0                	test   %eax,%eax
  802026:	75 c2                	jne    801fea <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802028:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5e                   	pop    %esi
  80202d:	5f                   	pop    %edi
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    

00802030 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802036:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80203b:	89 c2                	mov    %eax,%edx
  80203d:	c1 e2 07             	shl    $0x7,%edx
  802040:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  802047:	8b 52 5c             	mov    0x5c(%edx),%edx
  80204a:	39 ca                	cmp    %ecx,%edx
  80204c:	75 11                	jne    80205f <ipc_find_env+0x2f>
			return envs[i].env_id;
  80204e:	89 c2                	mov    %eax,%edx
  802050:	c1 e2 07             	shl    $0x7,%edx
  802053:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80205a:	8b 40 54             	mov    0x54(%eax),%eax
  80205d:	eb 0f                	jmp    80206e <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205f:	83 c0 01             	add    $0x1,%eax
  802062:	3d 00 04 00 00       	cmp    $0x400,%eax
  802067:	75 d2                	jne    80203b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80206e:	5d                   	pop    %ebp
  80206f:	c3                   	ret    

00802070 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802076:	89 d0                	mov    %edx,%eax
  802078:	c1 e8 16             	shr    $0x16,%eax
  80207b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802087:	f6 c1 01             	test   $0x1,%cl
  80208a:	74 1d                	je     8020a9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80208c:	c1 ea 0c             	shr    $0xc,%edx
  80208f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802096:	f6 c2 01             	test   $0x1,%dl
  802099:	74 0e                	je     8020a9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80209b:	c1 ea 0c             	shr    $0xc,%edx
  80209e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020a5:	ef 
  8020a6:	0f b7 c0             	movzwl %ax,%eax
}
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    
  8020ab:	66 90                	xchg   %ax,%ax
  8020ad:	66 90                	xchg   %ax,%ax
  8020af:	90                   	nop

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 f6                	test   %esi,%esi
  8020c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020cd:	89 ca                	mov    %ecx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	75 3d                	jne    802110 <__udivdi3+0x60>
  8020d3:	39 cf                	cmp    %ecx,%edi
  8020d5:	0f 87 c5 00 00 00    	ja     8021a0 <__udivdi3+0xf0>
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	89 fd                	mov    %edi,%ebp
  8020df:	75 0b                	jne    8020ec <__udivdi3+0x3c>
  8020e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e6:	31 d2                	xor    %edx,%edx
  8020e8:	f7 f7                	div    %edi
  8020ea:	89 c5                	mov    %eax,%ebp
  8020ec:	89 c8                	mov    %ecx,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f5                	div    %ebp
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	89 cf                	mov    %ecx,%edi
  8020f8:	f7 f5                	div    %ebp
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	89 fa                	mov    %edi,%edx
  802100:	83 c4 1c             	add    $0x1c,%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	90                   	nop
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 ce                	cmp    %ecx,%esi
  802112:	77 74                	ja     802188 <__udivdi3+0xd8>
  802114:	0f bd fe             	bsr    %esi,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0x108>
  802120:	bb 20 00 00 00       	mov    $0x20,%ebx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	89 c5                	mov    %eax,%ebp
  802129:	29 fb                	sub    %edi,%ebx
  80212b:	d3 e6                	shl    %cl,%esi
  80212d:	89 d9                	mov    %ebx,%ecx
  80212f:	d3 ed                	shr    %cl,%ebp
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 e0                	shl    %cl,%eax
  802135:	09 ee                	or     %ebp,%esi
  802137:	89 d9                	mov    %ebx,%ecx
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 d5                	mov    %edx,%ebp
  80213f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802143:	d3 ed                	shr    %cl,%ebp
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e2                	shl    %cl,%edx
  802149:	89 d9                	mov    %ebx,%ecx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	09 c2                	or     %eax,%edx
  80214f:	89 d0                	mov    %edx,%eax
  802151:	89 ea                	mov    %ebp,%edx
  802153:	f7 f6                	div    %esi
  802155:	89 d5                	mov    %edx,%ebp
  802157:	89 c3                	mov    %eax,%ebx
  802159:	f7 64 24 0c          	mull   0xc(%esp)
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	72 10                	jb     802171 <__udivdi3+0xc1>
  802161:	8b 74 24 08          	mov    0x8(%esp),%esi
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e6                	shl    %cl,%esi
  802169:	39 c6                	cmp    %eax,%esi
  80216b:	73 07                	jae    802174 <__udivdi3+0xc4>
  80216d:	39 d5                	cmp    %edx,%ebp
  80216f:	75 03                	jne    802174 <__udivdi3+0xc4>
  802171:	83 eb 01             	sub    $0x1,%ebx
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 d8                	mov    %ebx,%eax
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	31 db                	xor    %ebx,%ebx
  80218c:	89 d8                	mov    %ebx,%eax
  80218e:	89 fa                	mov    %edi,%edx
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	f7 f7                	div    %edi
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	89 d8                	mov    %ebx,%eax
  8021aa:	89 fa                	mov    %edi,%edx
  8021ac:	83 c4 1c             	add    $0x1c,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5e                   	pop    %esi
  8021b1:	5f                   	pop    %edi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	39 ce                	cmp    %ecx,%esi
  8021ba:	72 0c                	jb     8021c8 <__udivdi3+0x118>
  8021bc:	31 db                	xor    %ebx,%ebx
  8021be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021c2:	0f 87 34 ff ff ff    	ja     8020fc <__udivdi3+0x4c>
  8021c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021cd:	e9 2a ff ff ff       	jmp    8020fc <__udivdi3+0x4c>
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 d2                	test   %edx,%edx
  8021f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802201:	89 f3                	mov    %esi,%ebx
  802203:	89 3c 24             	mov    %edi,(%esp)
  802206:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220a:	75 1c                	jne    802228 <__umoddi3+0x48>
  80220c:	39 f7                	cmp    %esi,%edi
  80220e:	76 50                	jbe    802260 <__umoddi3+0x80>
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	f7 f7                	div    %edi
  802216:	89 d0                	mov    %edx,%eax
  802218:	31 d2                	xor    %edx,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	89 d0                	mov    %edx,%eax
  80222c:	77 52                	ja     802280 <__umoddi3+0xa0>
  80222e:	0f bd ea             	bsr    %edx,%ebp
  802231:	83 f5 1f             	xor    $0x1f,%ebp
  802234:	75 5a                	jne    802290 <__umoddi3+0xb0>
  802236:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80223a:	0f 82 e0 00 00 00    	jb     802320 <__umoddi3+0x140>
  802240:	39 0c 24             	cmp    %ecx,(%esp)
  802243:	0f 86 d7 00 00 00    	jbe    802320 <__umoddi3+0x140>
  802249:	8b 44 24 08          	mov    0x8(%esp),%eax
  80224d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	85 ff                	test   %edi,%edi
  802262:	89 fd                	mov    %edi,%ebp
  802264:	75 0b                	jne    802271 <__umoddi3+0x91>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f7                	div    %edi
  80226f:	89 c5                	mov    %eax,%ebp
  802271:	89 f0                	mov    %esi,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f5                	div    %ebp
  802277:	89 c8                	mov    %ecx,%eax
  802279:	f7 f5                	div    %ebp
  80227b:	89 d0                	mov    %edx,%eax
  80227d:	eb 99                	jmp    802218 <__umoddi3+0x38>
  80227f:	90                   	nop
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	83 c4 1c             	add    $0x1c,%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	8b 34 24             	mov    (%esp),%esi
  802293:	bf 20 00 00 00       	mov    $0x20,%edi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	29 ef                	sub    %ebp,%edi
  80229c:	d3 e0                	shl    %cl,%eax
  80229e:	89 f9                	mov    %edi,%ecx
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	d3 ea                	shr    %cl,%edx
  8022a4:	89 e9                	mov    %ebp,%ecx
  8022a6:	09 c2                	or     %eax,%edx
  8022a8:	89 d8                	mov    %ebx,%eax
  8022aa:	89 14 24             	mov    %edx,(%esp)
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	d3 e2                	shl    %cl,%edx
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	89 c6                	mov    %eax,%esi
  8022c1:	d3 e3                	shl    %cl,%ebx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	09 d8                	or     %ebx,%eax
  8022cd:	89 d3                	mov    %edx,%ebx
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	f7 34 24             	divl   (%esp)
  8022d4:	89 d6                	mov    %edx,%esi
  8022d6:	d3 e3                	shl    %cl,%ebx
  8022d8:	f7 64 24 04          	mull   0x4(%esp)
  8022dc:	39 d6                	cmp    %edx,%esi
  8022de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	89 c3                	mov    %eax,%ebx
  8022e6:	72 08                	jb     8022f0 <__umoddi3+0x110>
  8022e8:	75 11                	jne    8022fb <__umoddi3+0x11b>
  8022ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ee:	73 0b                	jae    8022fb <__umoddi3+0x11b>
  8022f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022f4:	1b 14 24             	sbb    (%esp),%edx
  8022f7:	89 d1                	mov    %edx,%ecx
  8022f9:	89 c3                	mov    %eax,%ebx
  8022fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ff:	29 da                	sub    %ebx,%edx
  802301:	19 ce                	sbb    %ecx,%esi
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	d3 ea                	shr    %cl,%edx
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	d3 ee                	shr    %cl,%esi
  802311:	09 d0                	or     %edx,%eax
  802313:	89 f2                	mov    %esi,%edx
  802315:	83 c4 1c             	add    $0x1c,%esp
  802318:	5b                   	pop    %ebx
  802319:	5e                   	pop    %esi
  80231a:	5f                   	pop    %edi
  80231b:	5d                   	pop    %ebp
  80231c:	c3                   	ret    
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	29 f9                	sub    %edi,%ecx
  802322:	19 d6                	sbb    %edx,%esi
  802324:	89 74 24 04          	mov    %esi,0x4(%esp)
  802328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80232c:	e9 18 ff ff ff       	jmp    802249 <__umoddi3+0x69>
