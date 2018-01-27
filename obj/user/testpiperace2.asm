
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
  80003c:	68 a0 23 80 00       	push   $0x8023a0
  800041:	e8 e4 02 00 00       	call   80032a <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 c2 1b 00 00       	call   801c13 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 ee 23 80 00       	push   $0x8023ee
  80005e:	6a 0d                	push   $0xd
  800060:	68 f7 23 80 00       	push   $0x8023f7
  800065:	e8 e7 01 00 00       	call   800251 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 6a 0f 00 00       	call   800fd9 <fork>
  80006f:	89 c7                	mov    %eax,%edi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 0c 24 80 00       	push   $0x80240c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 f7 23 80 00       	push   $0x8023f7
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
  800091:	e8 2a 13 00 00       	call   8013c0 <close>
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
  8000be:	68 15 24 80 00       	push   $0x802415
  8000c3:	e8 62 02 00 00       	call   80032a <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 38 13 00 00       	call   801410 <dup>
			sys_yield();
  8000d8:	e8 b6 0b 00 00       	call   800c93 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 d7 12 00 00       	call   8013c0 <close>
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
  80011d:	e8 44 1c 00 00       	call   801d66 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 1d                	je     800146 <umain+0x113>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 19 24 80 00       	push   $0x802419
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
  800154:	68 35 24 80 00       	push   $0x802435
  800159:	e8 cc 01 00 00       	call   80032a <cprintf>
	if (pipeisclosed(p[0]))
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 75 e0             	pushl  -0x20(%ebp)
  800164:	e8 fd 1b 00 00       	call   801d66 <pipeisclosed>
  800169:	83 c4 10             	add    $0x10,%esp
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 14                	je     800184 <umain+0x151>
		panic("somehow the other end of p[0] got closed!");
  800170:	83 ec 04             	sub    $0x4,%esp
  800173:	68 c4 23 80 00       	push   $0x8023c4
  800178:	6a 40                	push   $0x40
  80017a:	68 f7 23 80 00       	push   $0x8023f7
  80017f:	e8 cd 00 00 00       	call   800251 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800184:	83 ec 08             	sub    $0x8,%esp
  800187:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	ff 75 e0             	pushl  -0x20(%ebp)
  80018e:	e8 00 11 00 00       	call   801293 <fd_lookup>
  800193:	83 c4 10             	add    $0x10,%esp
  800196:	85 c0                	test   %eax,%eax
  800198:	79 12                	jns    8001ac <umain+0x179>
		panic("cannot look up p[0]: %e", r);
  80019a:	50                   	push   %eax
  80019b:	68 4b 24 80 00       	push   $0x80244b
  8001a0:	6a 42                	push   $0x42
  8001a2:	68 f7 23 80 00       	push   $0x8023f7
  8001a7:	e8 a5 00 00 00       	call   800251 <_panic>
	(void) fd2data(fd);
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b2:	e8 76 10 00 00       	call   80122d <fd2data>
	cprintf("race didn't happen\n");
  8001b7:	c7 04 24 63 24 80 00 	movl   $0x802463,(%esp)
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
  80023d:	e8 a9 11 00 00       	call   8013eb <close_all>
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
  80026f:	68 84 24 80 00       	push   $0x802484
  800274:	e8 b1 00 00 00       	call   80032a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800279:	83 c4 18             	add    $0x18,%esp
  80027c:	53                   	push   %ebx
  80027d:	ff 75 10             	pushl  0x10(%ebp)
  800280:	e8 54 00 00 00       	call   8002d9 <vcprintf>
	cprintf("\n");
  800285:	c7 04 24 23 29 80 00 	movl   $0x802923,(%esp)
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
  80038d:	e8 7e 1d 00 00       	call   802110 <__udivdi3>
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
  8003d0:	e8 6b 1e 00 00       	call   802240 <__umoddi3>
  8003d5:	83 c4 14             	add    $0x14,%esp
  8003d8:	0f be 80 a7 24 80 00 	movsbl 0x8024a7(%eax),%eax
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
  8004d4:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
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
  800598:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	75 18                	jne    8005bb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005a3:	50                   	push   %eax
  8005a4:	68 bf 24 80 00       	push   $0x8024bf
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
  8005bc:	68 f1 28 80 00       	push   $0x8028f1
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
  8005e0:	b8 b8 24 80 00       	mov    $0x8024b8,%eax
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
  800c5b:	68 9f 27 80 00       	push   $0x80279f
  800c60:	6a 23                	push   $0x23
  800c62:	68 bc 27 80 00       	push   $0x8027bc
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
  800cdc:	68 9f 27 80 00       	push   $0x80279f
  800ce1:	6a 23                	push   $0x23
  800ce3:	68 bc 27 80 00       	push   $0x8027bc
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
  800d1e:	68 9f 27 80 00       	push   $0x80279f
  800d23:	6a 23                	push   $0x23
  800d25:	68 bc 27 80 00       	push   $0x8027bc
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
  800d60:	68 9f 27 80 00       	push   $0x80279f
  800d65:	6a 23                	push   $0x23
  800d67:	68 bc 27 80 00       	push   $0x8027bc
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
  800da2:	68 9f 27 80 00       	push   $0x80279f
  800da7:	6a 23                	push   $0x23
  800da9:	68 bc 27 80 00       	push   $0x8027bc
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
  800de4:	68 9f 27 80 00       	push   $0x80279f
  800de9:	6a 23                	push   $0x23
  800deb:	68 bc 27 80 00       	push   $0x8027bc
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
  800e26:	68 9f 27 80 00       	push   $0x80279f
  800e2b:	6a 23                	push   $0x23
  800e2d:	68 bc 27 80 00       	push   $0x8027bc
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
  800e8a:	68 9f 27 80 00       	push   $0x80279f
  800e8f:	6a 23                	push   $0x23
  800e91:	68 bc 27 80 00       	push   $0x8027bc
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
  800f29:	68 ca 27 80 00       	push   $0x8027ca
  800f2e:	6a 1e                	push   $0x1e
  800f30:	68 da 27 80 00       	push   $0x8027da
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
  800f53:	68 e5 27 80 00       	push   $0x8027e5
  800f58:	6a 2c                	push   $0x2c
  800f5a:	68 da 27 80 00       	push   $0x8027da
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
  800f9b:	68 e5 27 80 00       	push   $0x8027e5
  800fa0:	6a 33                	push   $0x33
  800fa2:	68 da 27 80 00       	push   $0x8027da
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
  800fc3:	68 e5 27 80 00       	push   $0x8027e5
  800fc8:	6a 37                	push   $0x37
  800fca:	68 da 27 80 00       	push   $0x8027da
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
  800fe7:	e8 30 0f 00 00       	call   801f1c <set_pgfault_handler>
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
  801000:	68 fe 27 80 00       	push   $0x8027fe
  801005:	68 84 00 00 00       	push   $0x84
  80100a:	68 da 27 80 00       	push   $0x8027da
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
  8010bc:	68 0c 28 80 00       	push   $0x80280c
  8010c1:	6a 54                	push   $0x54
  8010c3:	68 da 27 80 00       	push   $0x8027da
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
  801101:	68 0c 28 80 00       	push   $0x80280c
  801106:	6a 5b                	push   $0x5b
  801108:	68 da 27 80 00       	push   $0x8027da
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
  80112f:	68 0c 28 80 00       	push   $0x80280c
  801134:	6a 5f                	push   $0x5f
  801136:	68 da 27 80 00       	push   $0x8027da
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
  801159:	68 0c 28 80 00       	push   $0x80280c
  80115e:	6a 64                	push   $0x64
  801160:	68 da 27 80 00       	push   $0x8027da
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
  8011c8:	68 24 28 80 00       	push   $0x802824
  8011cd:	e8 58 f1 ff ff       	call   80032a <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8011d2:	c7 04 24 17 02 80 00 	movl   $0x800217,(%esp)
  8011d9:	e8 c5 fc ff ff       	call   800ea3 <sys_thread_create>
  8011de:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8011e0:	83 c4 08             	add    $0x8,%esp
  8011e3:	53                   	push   %ebx
  8011e4:	68 24 28 80 00       	push   $0x802824
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

0080121d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801220:	8b 45 08             	mov    0x8(%ebp),%eax
  801223:	05 00 00 00 30       	add    $0x30000000,%eax
  801228:	c1 e8 0c             	shr    $0xc,%eax
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801230:	8b 45 08             	mov    0x8(%ebp),%eax
  801233:	05 00 00 00 30       	add    $0x30000000,%eax
  801238:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80123d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    

00801244 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124f:	89 c2                	mov    %eax,%edx
  801251:	c1 ea 16             	shr    $0x16,%edx
  801254:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125b:	f6 c2 01             	test   $0x1,%dl
  80125e:	74 11                	je     801271 <fd_alloc+0x2d>
  801260:	89 c2                	mov    %eax,%edx
  801262:	c1 ea 0c             	shr    $0xc,%edx
  801265:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126c:	f6 c2 01             	test   $0x1,%dl
  80126f:	75 09                	jne    80127a <fd_alloc+0x36>
			*fd_store = fd;
  801271:	89 01                	mov    %eax,(%ecx)
			return 0;
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
  801278:	eb 17                	jmp    801291 <fd_alloc+0x4d>
  80127a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80127f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801284:	75 c9                	jne    80124f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801286:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80128c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801299:	83 f8 1f             	cmp    $0x1f,%eax
  80129c:	77 36                	ja     8012d4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80129e:	c1 e0 0c             	shl    $0xc,%eax
  8012a1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	c1 ea 16             	shr    $0x16,%edx
  8012ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	74 24                	je     8012db <fd_lookup+0x48>
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	c1 ea 0c             	shr    $0xc,%edx
  8012bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c3:	f6 c2 01             	test   $0x1,%dl
  8012c6:	74 1a                	je     8012e2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012cb:	89 02                	mov    %eax,(%edx)
	return 0;
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d2:	eb 13                	jmp    8012e7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d9:	eb 0c                	jmp    8012e7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e0:	eb 05                	jmp    8012e7 <fd_lookup+0x54>
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f2:	ba c8 28 80 00       	mov    $0x8028c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f7:	eb 13                	jmp    80130c <dev_lookup+0x23>
  8012f9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012fc:	39 08                	cmp    %ecx,(%eax)
  8012fe:	75 0c                	jne    80130c <dev_lookup+0x23>
			*dev = devtab[i];
  801300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801303:	89 01                	mov    %eax,(%ecx)
			return 0;
  801305:	b8 00 00 00 00       	mov    $0x0,%eax
  80130a:	eb 31                	jmp    80133d <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80130c:	8b 02                	mov    (%edx),%eax
  80130e:	85 c0                	test   %eax,%eax
  801310:	75 e7                	jne    8012f9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801312:	a1 04 40 80 00       	mov    0x804004,%eax
  801317:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80131d:	83 ec 04             	sub    $0x4,%esp
  801320:	51                   	push   %ecx
  801321:	50                   	push   %eax
  801322:	68 48 28 80 00       	push   $0x802848
  801327:	e8 fe ef ff ff       	call   80032a <cprintf>
	*dev = 0;
  80132c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 10             	sub    $0x10,%esp
  801347:	8b 75 08             	mov    0x8(%ebp),%esi
  80134a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801350:	50                   	push   %eax
  801351:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801357:	c1 e8 0c             	shr    $0xc,%eax
  80135a:	50                   	push   %eax
  80135b:	e8 33 ff ff ff       	call   801293 <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 05                	js     80136c <fd_close+0x2d>
	    || fd != fd2)
  801367:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80136a:	74 0c                	je     801378 <fd_close+0x39>
		return (must_exist ? r : 0);
  80136c:	84 db                	test   %bl,%bl
  80136e:	ba 00 00 00 00       	mov    $0x0,%edx
  801373:	0f 44 c2             	cmove  %edx,%eax
  801376:	eb 41                	jmp    8013b9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	ff 36                	pushl  (%esi)
  801381:	e8 63 ff ff ff       	call   8012e9 <dev_lookup>
  801386:	89 c3                	mov    %eax,%ebx
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 1a                	js     8013a9 <fd_close+0x6a>
		if (dev->dev_close)
  80138f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801392:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801395:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80139a:	85 c0                	test   %eax,%eax
  80139c:	74 0b                	je     8013a9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	56                   	push   %esi
  8013a2:	ff d0                	call   *%eax
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	56                   	push   %esi
  8013ad:	6a 00                	push   $0x0
  8013af:	e8 83 f9 ff ff       	call   800d37 <sys_page_unmap>
	return r;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	89 d8                	mov    %ebx,%eax
}
  8013b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c9:	50                   	push   %eax
  8013ca:	ff 75 08             	pushl  0x8(%ebp)
  8013cd:	e8 c1 fe ff ff       	call   801293 <fd_lookup>
  8013d2:	83 c4 08             	add    $0x8,%esp
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 10                	js     8013e9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	6a 01                	push   $0x1
  8013de:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e1:	e8 59 ff ff ff       	call   80133f <fd_close>
  8013e6:	83 c4 10             	add    $0x10,%esp
}
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <close_all>:

void
close_all(void)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	53                   	push   %ebx
  8013ef:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	53                   	push   %ebx
  8013fb:	e8 c0 ff ff ff       	call   8013c0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801400:	83 c3 01             	add    $0x1,%ebx
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	83 fb 20             	cmp    $0x20,%ebx
  801409:	75 ec                	jne    8013f7 <close_all+0xc>
		close(i);
}
  80140b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140e:	c9                   	leave  
  80140f:	c3                   	ret    

00801410 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	57                   	push   %edi
  801414:	56                   	push   %esi
  801415:	53                   	push   %ebx
  801416:	83 ec 2c             	sub    $0x2c,%esp
  801419:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141f:	50                   	push   %eax
  801420:	ff 75 08             	pushl  0x8(%ebp)
  801423:	e8 6b fe ff ff       	call   801293 <fd_lookup>
  801428:	83 c4 08             	add    $0x8,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	0f 88 c1 00 00 00    	js     8014f4 <dup+0xe4>
		return r;
	close(newfdnum);
  801433:	83 ec 0c             	sub    $0xc,%esp
  801436:	56                   	push   %esi
  801437:	e8 84 ff ff ff       	call   8013c0 <close>

	newfd = INDEX2FD(newfdnum);
  80143c:	89 f3                	mov    %esi,%ebx
  80143e:	c1 e3 0c             	shl    $0xc,%ebx
  801441:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801447:	83 c4 04             	add    $0x4,%esp
  80144a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144d:	e8 db fd ff ff       	call   80122d <fd2data>
  801452:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801454:	89 1c 24             	mov    %ebx,(%esp)
  801457:	e8 d1 fd ff ff       	call   80122d <fd2data>
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801462:	89 f8                	mov    %edi,%eax
  801464:	c1 e8 16             	shr    $0x16,%eax
  801467:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146e:	a8 01                	test   $0x1,%al
  801470:	74 37                	je     8014a9 <dup+0x99>
  801472:	89 f8                	mov    %edi,%eax
  801474:	c1 e8 0c             	shr    $0xc,%eax
  801477:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147e:	f6 c2 01             	test   $0x1,%dl
  801481:	74 26                	je     8014a9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801483:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148a:	83 ec 0c             	sub    $0xc,%esp
  80148d:	25 07 0e 00 00       	and    $0xe07,%eax
  801492:	50                   	push   %eax
  801493:	ff 75 d4             	pushl  -0x2c(%ebp)
  801496:	6a 00                	push   $0x0
  801498:	57                   	push   %edi
  801499:	6a 00                	push   $0x0
  80149b:	e8 55 f8 ff ff       	call   800cf5 <sys_page_map>
  8014a0:	89 c7                	mov    %eax,%edi
  8014a2:	83 c4 20             	add    $0x20,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 2e                	js     8014d7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014ac:	89 d0                	mov    %edx,%eax
  8014ae:	c1 e8 0c             	shr    $0xc,%eax
  8014b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c0:	50                   	push   %eax
  8014c1:	53                   	push   %ebx
  8014c2:	6a 00                	push   $0x0
  8014c4:	52                   	push   %edx
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 29 f8 ff ff       	call   800cf5 <sys_page_map>
  8014cc:	89 c7                	mov    %eax,%edi
  8014ce:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014d1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d3:	85 ff                	test   %edi,%edi
  8014d5:	79 1d                	jns    8014f4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	53                   	push   %ebx
  8014db:	6a 00                	push   $0x0
  8014dd:	e8 55 f8 ff ff       	call   800d37 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e2:	83 c4 08             	add    $0x8,%esp
  8014e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e8:	6a 00                	push   $0x0
  8014ea:	e8 48 f8 ff ff       	call   800d37 <sys_page_unmap>
	return r;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	89 f8                	mov    %edi,%eax
}
  8014f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f7:	5b                   	pop    %ebx
  8014f8:	5e                   	pop    %esi
  8014f9:	5f                   	pop    %edi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	53                   	push   %ebx
  801500:	83 ec 14             	sub    $0x14,%esp
  801503:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801506:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	53                   	push   %ebx
  80150b:	e8 83 fd ff ff       	call   801293 <fd_lookup>
  801510:	83 c4 08             	add    $0x8,%esp
  801513:	89 c2                	mov    %eax,%edx
  801515:	85 c0                	test   %eax,%eax
  801517:	78 70                	js     801589 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801523:	ff 30                	pushl  (%eax)
  801525:	e8 bf fd ff ff       	call   8012e9 <dev_lookup>
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 4f                	js     801580 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801531:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801534:	8b 42 08             	mov    0x8(%edx),%eax
  801537:	83 e0 03             	and    $0x3,%eax
  80153a:	83 f8 01             	cmp    $0x1,%eax
  80153d:	75 24                	jne    801563 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80153f:	a1 04 40 80 00       	mov    0x804004,%eax
  801544:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	53                   	push   %ebx
  80154e:	50                   	push   %eax
  80154f:	68 8c 28 80 00       	push   $0x80288c
  801554:	e8 d1 ed ff ff       	call   80032a <cprintf>
		return -E_INVAL;
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801561:	eb 26                	jmp    801589 <read+0x8d>
	}
	if (!dev->dev_read)
  801563:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801566:	8b 40 08             	mov    0x8(%eax),%eax
  801569:	85 c0                	test   %eax,%eax
  80156b:	74 17                	je     801584 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80156d:	83 ec 04             	sub    $0x4,%esp
  801570:	ff 75 10             	pushl  0x10(%ebp)
  801573:	ff 75 0c             	pushl  0xc(%ebp)
  801576:	52                   	push   %edx
  801577:	ff d0                	call   *%eax
  801579:	89 c2                	mov    %eax,%edx
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	eb 09                	jmp    801589 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	89 c2                	mov    %eax,%edx
  801582:	eb 05                	jmp    801589 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801584:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801589:	89 d0                	mov    %edx,%eax
  80158b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	57                   	push   %edi
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 0c             	sub    $0xc,%esp
  801599:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a4:	eb 21                	jmp    8015c7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	89 f0                	mov    %esi,%eax
  8015ab:	29 d8                	sub    %ebx,%eax
  8015ad:	50                   	push   %eax
  8015ae:	89 d8                	mov    %ebx,%eax
  8015b0:	03 45 0c             	add    0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	57                   	push   %edi
  8015b5:	e8 42 ff ff ff       	call   8014fc <read>
		if (m < 0)
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 10                	js     8015d1 <readn+0x41>
			return m;
		if (m == 0)
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	74 0a                	je     8015cf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c5:	01 c3                	add    %eax,%ebx
  8015c7:	39 f3                	cmp    %esi,%ebx
  8015c9:	72 db                	jb     8015a6 <readn+0x16>
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	eb 02                	jmp    8015d1 <readn+0x41>
  8015cf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d4:	5b                   	pop    %ebx
  8015d5:	5e                   	pop    %esi
  8015d6:	5f                   	pop    %edi
  8015d7:	5d                   	pop    %ebp
  8015d8:	c3                   	ret    

008015d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	53                   	push   %ebx
  8015dd:	83 ec 14             	sub    $0x14,%esp
  8015e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e6:	50                   	push   %eax
  8015e7:	53                   	push   %ebx
  8015e8:	e8 a6 fc ff ff       	call   801293 <fd_lookup>
  8015ed:	83 c4 08             	add    $0x8,%esp
  8015f0:	89 c2                	mov    %eax,%edx
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 6b                	js     801661 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801600:	ff 30                	pushl  (%eax)
  801602:	e8 e2 fc ff ff       	call   8012e9 <dev_lookup>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 4a                	js     801658 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801615:	75 24                	jne    80163b <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801617:	a1 04 40 80 00       	mov    0x804004,%eax
  80161c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	53                   	push   %ebx
  801626:	50                   	push   %eax
  801627:	68 a8 28 80 00       	push   $0x8028a8
  80162c:	e8 f9 ec ff ff       	call   80032a <cprintf>
		return -E_INVAL;
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801639:	eb 26                	jmp    801661 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80163b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163e:	8b 52 0c             	mov    0xc(%edx),%edx
  801641:	85 d2                	test   %edx,%edx
  801643:	74 17                	je     80165c <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801645:	83 ec 04             	sub    $0x4,%esp
  801648:	ff 75 10             	pushl  0x10(%ebp)
  80164b:	ff 75 0c             	pushl  0xc(%ebp)
  80164e:	50                   	push   %eax
  80164f:	ff d2                	call   *%edx
  801651:	89 c2                	mov    %eax,%edx
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	eb 09                	jmp    801661 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801658:	89 c2                	mov    %eax,%edx
  80165a:	eb 05                	jmp    801661 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80165c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801661:	89 d0                	mov    %edx,%eax
  801663:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <seek>:

int
seek(int fdnum, off_t offset)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801671:	50                   	push   %eax
  801672:	ff 75 08             	pushl  0x8(%ebp)
  801675:	e8 19 fc ff ff       	call   801293 <fd_lookup>
  80167a:	83 c4 08             	add    $0x8,%esp
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 0e                	js     80168f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801681:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801684:	8b 55 0c             	mov    0xc(%ebp),%edx
  801687:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80168a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80168f:	c9                   	leave  
  801690:	c3                   	ret    

00801691 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	53                   	push   %ebx
  801695:	83 ec 14             	sub    $0x14,%esp
  801698:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169e:	50                   	push   %eax
  80169f:	53                   	push   %ebx
  8016a0:	e8 ee fb ff ff       	call   801293 <fd_lookup>
  8016a5:	83 c4 08             	add    $0x8,%esp
  8016a8:	89 c2                	mov    %eax,%edx
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 68                	js     801716 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b8:	ff 30                	pushl  (%eax)
  8016ba:	e8 2a fc ff ff       	call   8012e9 <dev_lookup>
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 47                	js     80170d <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016cd:	75 24                	jne    8016f3 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016cf:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	53                   	push   %ebx
  8016de:	50                   	push   %eax
  8016df:	68 68 28 80 00       	push   $0x802868
  8016e4:	e8 41 ec ff ff       	call   80032a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f1:	eb 23                	jmp    801716 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  8016f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f6:	8b 52 18             	mov    0x18(%edx),%edx
  8016f9:	85 d2                	test   %edx,%edx
  8016fb:	74 14                	je     801711 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	ff 75 0c             	pushl  0xc(%ebp)
  801703:	50                   	push   %eax
  801704:	ff d2                	call   *%edx
  801706:	89 c2                	mov    %eax,%edx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb 09                	jmp    801716 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	eb 05                	jmp    801716 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801711:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801716:	89 d0                	mov    %edx,%eax
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	53                   	push   %ebx
  801721:	83 ec 14             	sub    $0x14,%esp
  801724:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801727:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172a:	50                   	push   %eax
  80172b:	ff 75 08             	pushl  0x8(%ebp)
  80172e:	e8 60 fb ff ff       	call   801293 <fd_lookup>
  801733:	83 c4 08             	add    $0x8,%esp
  801736:	89 c2                	mov    %eax,%edx
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 58                	js     801794 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173c:	83 ec 08             	sub    $0x8,%esp
  80173f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801742:	50                   	push   %eax
  801743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801746:	ff 30                	pushl  (%eax)
  801748:	e8 9c fb ff ff       	call   8012e9 <dev_lookup>
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	85 c0                	test   %eax,%eax
  801752:	78 37                	js     80178b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801757:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80175b:	74 32                	je     80178f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80175d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801760:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801767:	00 00 00 
	stat->st_isdir = 0;
  80176a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801771:	00 00 00 
	stat->st_dev = dev;
  801774:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	53                   	push   %ebx
  80177e:	ff 75 f0             	pushl  -0x10(%ebp)
  801781:	ff 50 14             	call   *0x14(%eax)
  801784:	89 c2                	mov    %eax,%edx
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	eb 09                	jmp    801794 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	eb 05                	jmp    801794 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80178f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801794:	89 d0                	mov    %edx,%eax
  801796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	6a 00                	push   $0x0
  8017a5:	ff 75 08             	pushl  0x8(%ebp)
  8017a8:	e8 e3 01 00 00       	call   801990 <open>
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 1b                	js     8017d1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	ff 75 0c             	pushl  0xc(%ebp)
  8017bc:	50                   	push   %eax
  8017bd:	e8 5b ff ff ff       	call   80171d <fstat>
  8017c2:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c4:	89 1c 24             	mov    %ebx,(%esp)
  8017c7:	e8 f4 fb ff ff       	call   8013c0 <close>
	return r;
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	89 f0                	mov    %esi,%eax
}
  8017d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d4:	5b                   	pop    %ebx
  8017d5:	5e                   	pop    %esi
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	56                   	push   %esi
  8017dc:	53                   	push   %ebx
  8017dd:	89 c6                	mov    %eax,%esi
  8017df:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017e1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e8:	75 12                	jne    8017fc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ea:	83 ec 0c             	sub    $0xc,%esp
  8017ed:	6a 01                	push   $0x1
  8017ef:	e8 94 08 00 00       	call   802088 <ipc_find_env>
  8017f4:	a3 00 40 80 00       	mov    %eax,0x804000
  8017f9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017fc:	6a 07                	push   $0x7
  8017fe:	68 00 50 80 00       	push   $0x805000
  801803:	56                   	push   %esi
  801804:	ff 35 00 40 80 00    	pushl  0x804000
  80180a:	e8 17 08 00 00       	call   802026 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80180f:	83 c4 0c             	add    $0xc,%esp
  801812:	6a 00                	push   $0x0
  801814:	53                   	push   %ebx
  801815:	6a 00                	push   $0x0
  801817:	e8 8f 07 00 00       	call   801fab <ipc_recv>
}
  80181c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	8b 40 0c             	mov    0xc(%eax),%eax
  80182f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801834:	8b 45 0c             	mov    0xc(%ebp),%eax
  801837:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80183c:	ba 00 00 00 00       	mov    $0x0,%edx
  801841:	b8 02 00 00 00       	mov    $0x2,%eax
  801846:	e8 8d ff ff ff       	call   8017d8 <fsipc>
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	8b 40 0c             	mov    0xc(%eax),%eax
  801859:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80185e:	ba 00 00 00 00       	mov    $0x0,%edx
  801863:	b8 06 00 00 00       	mov    $0x6,%eax
  801868:	e8 6b ff ff ff       	call   8017d8 <fsipc>
}
  80186d:	c9                   	leave  
  80186e:	c3                   	ret    

0080186f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	53                   	push   %ebx
  801873:	83 ec 04             	sub    $0x4,%esp
  801876:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	8b 40 0c             	mov    0xc(%eax),%eax
  80187f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801884:	ba 00 00 00 00       	mov    $0x0,%edx
  801889:	b8 05 00 00 00       	mov    $0x5,%eax
  80188e:	e8 45 ff ff ff       	call   8017d8 <fsipc>
  801893:	85 c0                	test   %eax,%eax
  801895:	78 2c                	js     8018c3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	68 00 50 80 00       	push   $0x805000
  80189f:	53                   	push   %ebx
  8018a0:	e8 0a f0 ff ff       	call   8008af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a5:	a1 80 50 80 00       	mov    0x805080,%eax
  8018aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b0:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 0c             	sub    $0xc,%esp
  8018ce:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8018d4:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018dd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018e2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018e7:	0f 47 c2             	cmova  %edx,%eax
  8018ea:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8018ef:	50                   	push   %eax
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	68 08 50 80 00       	push   $0x805008
  8018f8:	e8 44 f1 ff ff       	call   800a41 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 04 00 00 00       	mov    $0x4,%eax
  801907:	e8 cc fe ff ff       	call   8017d8 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	8b 40 0c             	mov    0xc(%eax),%eax
  80191c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801921:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801927:	ba 00 00 00 00       	mov    $0x0,%edx
  80192c:	b8 03 00 00 00       	mov    $0x3,%eax
  801931:	e8 a2 fe ff ff       	call   8017d8 <fsipc>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 4b                	js     801987 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80193c:	39 c6                	cmp    %eax,%esi
  80193e:	73 16                	jae    801956 <devfile_read+0x48>
  801940:	68 d8 28 80 00       	push   $0x8028d8
  801945:	68 df 28 80 00       	push   $0x8028df
  80194a:	6a 7c                	push   $0x7c
  80194c:	68 f4 28 80 00       	push   $0x8028f4
  801951:	e8 fb e8 ff ff       	call   800251 <_panic>
	assert(r <= PGSIZE);
  801956:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195b:	7e 16                	jle    801973 <devfile_read+0x65>
  80195d:	68 ff 28 80 00       	push   $0x8028ff
  801962:	68 df 28 80 00       	push   $0x8028df
  801967:	6a 7d                	push   $0x7d
  801969:	68 f4 28 80 00       	push   $0x8028f4
  80196e:	e8 de e8 ff ff       	call   800251 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801973:	83 ec 04             	sub    $0x4,%esp
  801976:	50                   	push   %eax
  801977:	68 00 50 80 00       	push   $0x805000
  80197c:	ff 75 0c             	pushl  0xc(%ebp)
  80197f:	e8 bd f0 ff ff       	call   800a41 <memmove>
	return r;
  801984:	83 c4 10             	add    $0x10,%esp
}
  801987:	89 d8                	mov    %ebx,%eax
  801989:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5e                   	pop    %esi
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	83 ec 20             	sub    $0x20,%esp
  801997:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80199a:	53                   	push   %ebx
  80199b:	e8 d6 ee ff ff       	call   800876 <strlen>
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a8:	7f 67                	jg     801a11 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b0:	50                   	push   %eax
  8019b1:	e8 8e f8 ff ff       	call   801244 <fd_alloc>
  8019b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 57                	js     801a16 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019bf:	83 ec 08             	sub    $0x8,%esp
  8019c2:	53                   	push   %ebx
  8019c3:	68 00 50 80 00       	push   $0x805000
  8019c8:	e8 e2 ee ff ff       	call   8008af <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8019dd:	e8 f6 fd ff ff       	call   8017d8 <fsipc>
  8019e2:	89 c3                	mov    %eax,%ebx
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	79 14                	jns    8019ff <open+0x6f>
		fd_close(fd, 0);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	6a 00                	push   $0x0
  8019f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f3:	e8 47 f9 ff ff       	call   80133f <fd_close>
		return r;
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	89 da                	mov    %ebx,%edx
  8019fd:	eb 17                	jmp    801a16 <open+0x86>
	}

	return fd2num(fd);
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	ff 75 f4             	pushl  -0xc(%ebp)
  801a05:	e8 13 f8 ff ff       	call   80121d <fd2num>
  801a0a:	89 c2                	mov    %eax,%edx
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	eb 05                	jmp    801a16 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a11:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a16:	89 d0                	mov    %edx,%eax
  801a18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a23:	ba 00 00 00 00       	mov    $0x0,%edx
  801a28:	b8 08 00 00 00       	mov    $0x8,%eax
  801a2d:	e8 a6 fd ff ff       	call   8017d8 <fsipc>
}
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	ff 75 08             	pushl  0x8(%ebp)
  801a42:	e8 e6 f7 ff ff       	call   80122d <fd2data>
  801a47:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a49:	83 c4 08             	add    $0x8,%esp
  801a4c:	68 0b 29 80 00       	push   $0x80290b
  801a51:	53                   	push   %ebx
  801a52:	e8 58 ee ff ff       	call   8008af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a57:	8b 46 04             	mov    0x4(%esi),%eax
  801a5a:	2b 06                	sub    (%esi),%eax
  801a5c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a62:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a69:	00 00 00 
	stat->st_dev = &devpipe;
  801a6c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a73:	30 80 00 
	return 0;
}
  801a76:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	53                   	push   %ebx
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a8c:	53                   	push   %ebx
  801a8d:	6a 00                	push   $0x0
  801a8f:	e8 a3 f2 ff ff       	call   800d37 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a94:	89 1c 24             	mov    %ebx,(%esp)
  801a97:	e8 91 f7 ff ff       	call   80122d <fd2data>
  801a9c:	83 c4 08             	add    $0x8,%esp
  801a9f:	50                   	push   %eax
  801aa0:	6a 00                	push   $0x0
  801aa2:	e8 90 f2 ff ff       	call   800d37 <sys_page_unmap>
}
  801aa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

00801aac <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	57                   	push   %edi
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 1c             	sub    $0x1c,%esp
  801ab5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aba:	a1 04 40 80 00       	mov    0x804004,%eax
  801abf:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ac5:	83 ec 0c             	sub    $0xc,%esp
  801ac8:	ff 75 e0             	pushl  -0x20(%ebp)
  801acb:	e8 fd 05 00 00       	call   8020cd <pageref>
  801ad0:	89 c3                	mov    %eax,%ebx
  801ad2:	89 3c 24             	mov    %edi,(%esp)
  801ad5:	e8 f3 05 00 00       	call   8020cd <pageref>
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	39 c3                	cmp    %eax,%ebx
  801adf:	0f 94 c1             	sete   %cl
  801ae2:	0f b6 c9             	movzbl %cl,%ecx
  801ae5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ae8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aee:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801af4:	39 ce                	cmp    %ecx,%esi
  801af6:	74 1e                	je     801b16 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801af8:	39 c3                	cmp    %eax,%ebx
  801afa:	75 be                	jne    801aba <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801afc:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801b02:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b05:	50                   	push   %eax
  801b06:	56                   	push   %esi
  801b07:	68 12 29 80 00       	push   $0x802912
  801b0c:	e8 19 e8 ff ff       	call   80032a <cprintf>
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	eb a4                	jmp    801aba <_pipeisclosed+0xe>
	}
}
  801b16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1c:	5b                   	pop    %ebx
  801b1d:	5e                   	pop    %esi
  801b1e:	5f                   	pop    %edi
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    

00801b21 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	57                   	push   %edi
  801b25:	56                   	push   %esi
  801b26:	53                   	push   %ebx
  801b27:	83 ec 28             	sub    $0x28,%esp
  801b2a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b2d:	56                   	push   %esi
  801b2e:	e8 fa f6 ff ff       	call   80122d <fd2data>
  801b33:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	bf 00 00 00 00       	mov    $0x0,%edi
  801b3d:	eb 4b                	jmp    801b8a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b3f:	89 da                	mov    %ebx,%edx
  801b41:	89 f0                	mov    %esi,%eax
  801b43:	e8 64 ff ff ff       	call   801aac <_pipeisclosed>
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	75 48                	jne    801b94 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b4c:	e8 42 f1 ff ff       	call   800c93 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b51:	8b 43 04             	mov    0x4(%ebx),%eax
  801b54:	8b 0b                	mov    (%ebx),%ecx
  801b56:	8d 51 20             	lea    0x20(%ecx),%edx
  801b59:	39 d0                	cmp    %edx,%eax
  801b5b:	73 e2                	jae    801b3f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b60:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b64:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b67:	89 c2                	mov    %eax,%edx
  801b69:	c1 fa 1f             	sar    $0x1f,%edx
  801b6c:	89 d1                	mov    %edx,%ecx
  801b6e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b71:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b74:	83 e2 1f             	and    $0x1f,%edx
  801b77:	29 ca                	sub    %ecx,%edx
  801b79:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b7d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b81:	83 c0 01             	add    $0x1,%eax
  801b84:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b87:	83 c7 01             	add    $0x1,%edi
  801b8a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b8d:	75 c2                	jne    801b51 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b8f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b92:	eb 05                	jmp    801b99 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	57                   	push   %edi
  801ba5:	56                   	push   %esi
  801ba6:	53                   	push   %ebx
  801ba7:	83 ec 18             	sub    $0x18,%esp
  801baa:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bad:	57                   	push   %edi
  801bae:	e8 7a f6 ff ff       	call   80122d <fd2data>
  801bb3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bbd:	eb 3d                	jmp    801bfc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bbf:	85 db                	test   %ebx,%ebx
  801bc1:	74 04                	je     801bc7 <devpipe_read+0x26>
				return i;
  801bc3:	89 d8                	mov    %ebx,%eax
  801bc5:	eb 44                	jmp    801c0b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bc7:	89 f2                	mov    %esi,%edx
  801bc9:	89 f8                	mov    %edi,%eax
  801bcb:	e8 dc fe ff ff       	call   801aac <_pipeisclosed>
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	75 32                	jne    801c06 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bd4:	e8 ba f0 ff ff       	call   800c93 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bd9:	8b 06                	mov    (%esi),%eax
  801bdb:	3b 46 04             	cmp    0x4(%esi),%eax
  801bde:	74 df                	je     801bbf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801be0:	99                   	cltd   
  801be1:	c1 ea 1b             	shr    $0x1b,%edx
  801be4:	01 d0                	add    %edx,%eax
  801be6:	83 e0 1f             	and    $0x1f,%eax
  801be9:	29 d0                	sub    %edx,%eax
  801beb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bf6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf9:	83 c3 01             	add    $0x1,%ebx
  801bfc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bff:	75 d8                	jne    801bd9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c01:	8b 45 10             	mov    0x10(%ebp),%eax
  801c04:	eb 05                	jmp    801c0b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5e                   	pop    %esi
  801c10:	5f                   	pop    %edi
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	56                   	push   %esi
  801c17:	53                   	push   %ebx
  801c18:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1e:	50                   	push   %eax
  801c1f:	e8 20 f6 ff ff       	call   801244 <fd_alloc>
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	89 c2                	mov    %eax,%edx
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	0f 88 2c 01 00 00    	js     801d5d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c31:	83 ec 04             	sub    $0x4,%esp
  801c34:	68 07 04 00 00       	push   $0x407
  801c39:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3c:	6a 00                	push   $0x0
  801c3e:	e8 6f f0 ff ff       	call   800cb2 <sys_page_alloc>
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	89 c2                	mov    %eax,%edx
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	0f 88 0d 01 00 00    	js     801d5d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c56:	50                   	push   %eax
  801c57:	e8 e8 f5 ff ff       	call   801244 <fd_alloc>
  801c5c:	89 c3                	mov    %eax,%ebx
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	85 c0                	test   %eax,%eax
  801c63:	0f 88 e2 00 00 00    	js     801d4b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c69:	83 ec 04             	sub    $0x4,%esp
  801c6c:	68 07 04 00 00       	push   $0x407
  801c71:	ff 75 f0             	pushl  -0x10(%ebp)
  801c74:	6a 00                	push   $0x0
  801c76:	e8 37 f0 ff ff       	call   800cb2 <sys_page_alloc>
  801c7b:	89 c3                	mov    %eax,%ebx
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	0f 88 c3 00 00 00    	js     801d4b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c88:	83 ec 0c             	sub    $0xc,%esp
  801c8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8e:	e8 9a f5 ff ff       	call   80122d <fd2data>
  801c93:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c95:	83 c4 0c             	add    $0xc,%esp
  801c98:	68 07 04 00 00       	push   $0x407
  801c9d:	50                   	push   %eax
  801c9e:	6a 00                	push   $0x0
  801ca0:	e8 0d f0 ff ff       	call   800cb2 <sys_page_alloc>
  801ca5:	89 c3                	mov    %eax,%ebx
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	0f 88 89 00 00 00    	js     801d3b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb2:	83 ec 0c             	sub    $0xc,%esp
  801cb5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb8:	e8 70 f5 ff ff       	call   80122d <fd2data>
  801cbd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cc4:	50                   	push   %eax
  801cc5:	6a 00                	push   $0x0
  801cc7:	56                   	push   %esi
  801cc8:	6a 00                	push   $0x0
  801cca:	e8 26 f0 ff ff       	call   800cf5 <sys_page_map>
  801ccf:	89 c3                	mov    %eax,%ebx
  801cd1:	83 c4 20             	add    $0x20,%esp
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	78 55                	js     801d2d <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cd8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ced:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d02:	83 ec 0c             	sub    $0xc,%esp
  801d05:	ff 75 f4             	pushl  -0xc(%ebp)
  801d08:	e8 10 f5 ff ff       	call   80121d <fd2num>
  801d0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d10:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d12:	83 c4 04             	add    $0x4,%esp
  801d15:	ff 75 f0             	pushl  -0x10(%ebp)
  801d18:	e8 00 f5 ff ff       	call   80121d <fd2num>
  801d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d20:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2b:	eb 30                	jmp    801d5d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d2d:	83 ec 08             	sub    $0x8,%esp
  801d30:	56                   	push   %esi
  801d31:	6a 00                	push   $0x0
  801d33:	e8 ff ef ff ff       	call   800d37 <sys_page_unmap>
  801d38:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d3b:	83 ec 08             	sub    $0x8,%esp
  801d3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d41:	6a 00                	push   $0x0
  801d43:	e8 ef ef ff ff       	call   800d37 <sys_page_unmap>
  801d48:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d4b:	83 ec 08             	sub    $0x8,%esp
  801d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d51:	6a 00                	push   $0x0
  801d53:	e8 df ef ff ff       	call   800d37 <sys_page_unmap>
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d5d:	89 d0                	mov    %edx,%eax
  801d5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d62:	5b                   	pop    %ebx
  801d63:	5e                   	pop    %esi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6f:	50                   	push   %eax
  801d70:	ff 75 08             	pushl  0x8(%ebp)
  801d73:	e8 1b f5 ff ff       	call   801293 <fd_lookup>
  801d78:	83 c4 10             	add    $0x10,%esp
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	78 18                	js     801d97 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d7f:	83 ec 0c             	sub    $0xc,%esp
  801d82:	ff 75 f4             	pushl  -0xc(%ebp)
  801d85:	e8 a3 f4 ff ff       	call   80122d <fd2data>
	return _pipeisclosed(fd, p);
  801d8a:	89 c2                	mov    %eax,%edx
  801d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8f:	e8 18 fd ff ff       	call   801aac <_pipeisclosed>
  801d94:	83 c4 10             	add    $0x10,%esp
}
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da9:	68 2a 29 80 00       	push   $0x80292a
  801dae:	ff 75 0c             	pushl  0xc(%ebp)
  801db1:	e8 f9 ea ff ff       	call   8008af <strcpy>
	return 0;
}
  801db6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbb:	c9                   	leave  
  801dbc:	c3                   	ret    

00801dbd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	57                   	push   %edi
  801dc1:	56                   	push   %esi
  801dc2:	53                   	push   %ebx
  801dc3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dce:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd4:	eb 2d                	jmp    801e03 <devcons_write+0x46>
		m = n - tot;
  801dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dd9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ddb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dde:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801de3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de6:	83 ec 04             	sub    $0x4,%esp
  801de9:	53                   	push   %ebx
  801dea:	03 45 0c             	add    0xc(%ebp),%eax
  801ded:	50                   	push   %eax
  801dee:	57                   	push   %edi
  801def:	e8 4d ec ff ff       	call   800a41 <memmove>
		sys_cputs(buf, m);
  801df4:	83 c4 08             	add    $0x8,%esp
  801df7:	53                   	push   %ebx
  801df8:	57                   	push   %edi
  801df9:	e8 f8 ed ff ff       	call   800bf6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dfe:	01 de                	add    %ebx,%esi
  801e00:	83 c4 10             	add    $0x10,%esp
  801e03:	89 f0                	mov    %esi,%eax
  801e05:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e08:	72 cc                	jb     801dd6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5f                   	pop    %edi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 08             	sub    $0x8,%esp
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e21:	74 2a                	je     801e4d <devcons_read+0x3b>
  801e23:	eb 05                	jmp    801e2a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e25:	e8 69 ee ff ff       	call   800c93 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e2a:	e8 e5 ed ff ff       	call   800c14 <sys_cgetc>
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	74 f2                	je     801e25 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 16                	js     801e4d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e37:	83 f8 04             	cmp    $0x4,%eax
  801e3a:	74 0c                	je     801e48 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e3f:	88 02                	mov    %al,(%edx)
	return 1;
  801e41:	b8 01 00 00 00       	mov    $0x1,%eax
  801e46:	eb 05                	jmp    801e4d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e48:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e55:	8b 45 08             	mov    0x8(%ebp),%eax
  801e58:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e5b:	6a 01                	push   $0x1
  801e5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e60:	50                   	push   %eax
  801e61:	e8 90 ed ff ff       	call   800bf6 <sys_cputs>
}
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <getchar>:

int
getchar(void)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e71:	6a 01                	push   $0x1
  801e73:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e76:	50                   	push   %eax
  801e77:	6a 00                	push   $0x0
  801e79:	e8 7e f6 ff ff       	call   8014fc <read>
	if (r < 0)
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	85 c0                	test   %eax,%eax
  801e83:	78 0f                	js     801e94 <getchar+0x29>
		return r;
	if (r < 1)
  801e85:	85 c0                	test   %eax,%eax
  801e87:	7e 06                	jle    801e8f <getchar+0x24>
		return -E_EOF;
	return c;
  801e89:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e8d:	eb 05                	jmp    801e94 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e8f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e94:	c9                   	leave  
  801e95:	c3                   	ret    

00801e96 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9f:	50                   	push   %eax
  801ea0:	ff 75 08             	pushl  0x8(%ebp)
  801ea3:	e8 eb f3 ff ff       	call   801293 <fd_lookup>
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	85 c0                	test   %eax,%eax
  801ead:	78 11                	js     801ec0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb8:	39 10                	cmp    %edx,(%eax)
  801eba:	0f 94 c0             	sete   %al
  801ebd:	0f b6 c0             	movzbl %al,%eax
}
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    

00801ec2 <opencons>:

int
opencons(void)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecb:	50                   	push   %eax
  801ecc:	e8 73 f3 ff ff       	call   801244 <fd_alloc>
  801ed1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 3e                	js     801f18 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eda:	83 ec 04             	sub    $0x4,%esp
  801edd:	68 07 04 00 00       	push   $0x407
  801ee2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee5:	6a 00                	push   $0x0
  801ee7:	e8 c6 ed ff ff       	call   800cb2 <sys_page_alloc>
  801eec:	83 c4 10             	add    $0x10,%esp
		return r;
  801eef:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 23                	js     801f18 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ef5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f03:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f0a:	83 ec 0c             	sub    $0xc,%esp
  801f0d:	50                   	push   %eax
  801f0e:	e8 0a f3 ff ff       	call   80121d <fd2num>
  801f13:	89 c2                	mov    %eax,%edx
  801f15:	83 c4 10             	add    $0x10,%esp
}
  801f18:	89 d0                	mov    %edx,%eax
  801f1a:	c9                   	leave  
  801f1b:	c3                   	ret    

00801f1c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f22:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f29:	75 2a                	jne    801f55 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f2b:	83 ec 04             	sub    $0x4,%esp
  801f2e:	6a 07                	push   $0x7
  801f30:	68 00 f0 bf ee       	push   $0xeebff000
  801f35:	6a 00                	push   $0x0
  801f37:	e8 76 ed ff ff       	call   800cb2 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	79 12                	jns    801f55 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f43:	50                   	push   %eax
  801f44:	68 36 29 80 00       	push   $0x802936
  801f49:	6a 23                	push   $0x23
  801f4b:	68 3a 29 80 00       	push   $0x80293a
  801f50:	e8 fc e2 ff ff       	call   800251 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f55:	8b 45 08             	mov    0x8(%ebp),%eax
  801f58:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801f5d:	83 ec 08             	sub    $0x8,%esp
  801f60:	68 87 1f 80 00       	push   $0x801f87
  801f65:	6a 00                	push   $0x0
  801f67:	e8 91 ee ff ff       	call   800dfd <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	79 12                	jns    801f85 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801f73:	50                   	push   %eax
  801f74:	68 36 29 80 00       	push   $0x802936
  801f79:	6a 2c                	push   $0x2c
  801f7b:	68 3a 29 80 00       	push   $0x80293a
  801f80:	e8 cc e2 ff ff       	call   800251 <_panic>
	}
}
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f87:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f88:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f8d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f8f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801f92:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801f96:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801f9b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801f9f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801fa1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801fa4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801fa5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801fa8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801fa9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801faa:	c3                   	ret    

00801fab <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	56                   	push   %esi
  801faf:	53                   	push   %ebx
  801fb0:	8b 75 08             	mov    0x8(%ebp),%esi
  801fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	75 12                	jne    801fcf <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801fbd:	83 ec 0c             	sub    $0xc,%esp
  801fc0:	68 00 00 c0 ee       	push   $0xeec00000
  801fc5:	e8 98 ee ff ff       	call   800e62 <sys_ipc_recv>
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	eb 0c                	jmp    801fdb <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801fcf:	83 ec 0c             	sub    $0xc,%esp
  801fd2:	50                   	push   %eax
  801fd3:	e8 8a ee ff ff       	call   800e62 <sys_ipc_recv>
  801fd8:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801fdb:	85 f6                	test   %esi,%esi
  801fdd:	0f 95 c1             	setne  %cl
  801fe0:	85 db                	test   %ebx,%ebx
  801fe2:	0f 95 c2             	setne  %dl
  801fe5:	84 d1                	test   %dl,%cl
  801fe7:	74 09                	je     801ff2 <ipc_recv+0x47>
  801fe9:	89 c2                	mov    %eax,%edx
  801feb:	c1 ea 1f             	shr    $0x1f,%edx
  801fee:	84 d2                	test   %dl,%dl
  801ff0:	75 2d                	jne    80201f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ff2:	85 f6                	test   %esi,%esi
  801ff4:	74 0d                	je     802003 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801ff6:	a1 04 40 80 00       	mov    0x804004,%eax
  801ffb:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802001:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802003:	85 db                	test   %ebx,%ebx
  802005:	74 0d                	je     802014 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802007:	a1 04 40 80 00       	mov    0x804004,%eax
  80200c:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  802012:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802014:	a1 04 40 80 00       	mov    0x804004,%eax
  802019:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80201f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802022:	5b                   	pop    %ebx
  802023:	5e                   	pop    %esi
  802024:	5d                   	pop    %ebp
  802025:	c3                   	ret    

00802026 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	57                   	push   %edi
  80202a:	56                   	push   %esi
  80202b:	53                   	push   %ebx
  80202c:	83 ec 0c             	sub    $0xc,%esp
  80202f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802032:	8b 75 0c             	mov    0xc(%ebp),%esi
  802035:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802038:	85 db                	test   %ebx,%ebx
  80203a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80203f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802042:	ff 75 14             	pushl  0x14(%ebp)
  802045:	53                   	push   %ebx
  802046:	56                   	push   %esi
  802047:	57                   	push   %edi
  802048:	e8 f2 ed ff ff       	call   800e3f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80204d:	89 c2                	mov    %eax,%edx
  80204f:	c1 ea 1f             	shr    $0x1f,%edx
  802052:	83 c4 10             	add    $0x10,%esp
  802055:	84 d2                	test   %dl,%dl
  802057:	74 17                	je     802070 <ipc_send+0x4a>
  802059:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80205c:	74 12                	je     802070 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80205e:	50                   	push   %eax
  80205f:	68 48 29 80 00       	push   $0x802948
  802064:	6a 47                	push   $0x47
  802066:	68 56 29 80 00       	push   $0x802956
  80206b:	e8 e1 e1 ff ff       	call   800251 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802070:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802073:	75 07                	jne    80207c <ipc_send+0x56>
			sys_yield();
  802075:	e8 19 ec ff ff       	call   800c93 <sys_yield>
  80207a:	eb c6                	jmp    802042 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80207c:	85 c0                	test   %eax,%eax
  80207e:	75 c2                	jne    802042 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    

00802088 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80208e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802093:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802099:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80209f:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8020a5:	39 ca                	cmp    %ecx,%edx
  8020a7:	75 13                	jne    8020bc <ipc_find_env+0x34>
			return envs[i].env_id;
  8020a9:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8020af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020b4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8020ba:	eb 0f                	jmp    8020cb <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020bc:	83 c0 01             	add    $0x1,%eax
  8020bf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c4:	75 cd                	jne    802093 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020cb:	5d                   	pop    %ebp
  8020cc:	c3                   	ret    

008020cd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020cd:	55                   	push   %ebp
  8020ce:	89 e5                	mov    %esp,%ebp
  8020d0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d3:	89 d0                	mov    %edx,%eax
  8020d5:	c1 e8 16             	shr    $0x16,%eax
  8020d8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020df:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e4:	f6 c1 01             	test   $0x1,%cl
  8020e7:	74 1d                	je     802106 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020e9:	c1 ea 0c             	shr    $0xc,%edx
  8020ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020f3:	f6 c2 01             	test   $0x1,%dl
  8020f6:	74 0e                	je     802106 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f8:	c1 ea 0c             	shr    $0xc,%edx
  8020fb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802102:	ef 
  802103:	0f b7 c0             	movzwl %ax,%eax
}
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80211b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80211f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 f6                	test   %esi,%esi
  802129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212d:	89 ca                	mov    %ecx,%edx
  80212f:	89 f8                	mov    %edi,%eax
  802131:	75 3d                	jne    802170 <__udivdi3+0x60>
  802133:	39 cf                	cmp    %ecx,%edi
  802135:	0f 87 c5 00 00 00    	ja     802200 <__udivdi3+0xf0>
  80213b:	85 ff                	test   %edi,%edi
  80213d:	89 fd                	mov    %edi,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f7                	div    %edi
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 c8                	mov    %ecx,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c1                	mov    %eax,%ecx
  802154:	89 d8                	mov    %ebx,%eax
  802156:	89 cf                	mov    %ecx,%edi
  802158:	f7 f5                	div    %ebp
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	39 ce                	cmp    %ecx,%esi
  802172:	77 74                	ja     8021e8 <__udivdi3+0xd8>
  802174:	0f bd fe             	bsr    %esi,%edi
  802177:	83 f7 1f             	xor    $0x1f,%edi
  80217a:	0f 84 98 00 00 00    	je     802218 <__udivdi3+0x108>
  802180:	bb 20 00 00 00       	mov    $0x20,%ebx
  802185:	89 f9                	mov    %edi,%ecx
  802187:	89 c5                	mov    %eax,%ebp
  802189:	29 fb                	sub    %edi,%ebx
  80218b:	d3 e6                	shl    %cl,%esi
  80218d:	89 d9                	mov    %ebx,%ecx
  80218f:	d3 ed                	shr    %cl,%ebp
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e0                	shl    %cl,%eax
  802195:	09 ee                	or     %ebp,%esi
  802197:	89 d9                	mov    %ebx,%ecx
  802199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219d:	89 d5                	mov    %edx,%ebp
  80219f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a3:	d3 ed                	shr    %cl,%ebp
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e2                	shl    %cl,%edx
  8021a9:	89 d9                	mov    %ebx,%ecx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	09 c2                	or     %eax,%edx
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	89 ea                	mov    %ebp,%edx
  8021b3:	f7 f6                	div    %esi
  8021b5:	89 d5                	mov    %edx,%ebp
  8021b7:	89 c3                	mov    %eax,%ebx
  8021b9:	f7 64 24 0c          	mull   0xc(%esp)
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	72 10                	jb     8021d1 <__udivdi3+0xc1>
  8021c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e6                	shl    %cl,%esi
  8021c9:	39 c6                	cmp    %eax,%esi
  8021cb:	73 07                	jae    8021d4 <__udivdi3+0xc4>
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	75 03                	jne    8021d4 <__udivdi3+0xc4>
  8021d1:	83 eb 01             	sub    $0x1,%ebx
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	89 fa                	mov    %edi,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	31 db                	xor    %ebx,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d8                	mov    %ebx,%eax
  802202:	f7 f7                	div    %edi
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 c3                	mov    %eax,%ebx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 fa                	mov    %edi,%edx
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5f                   	pop    %edi
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	39 ce                	cmp    %ecx,%esi
  80221a:	72 0c                	jb     802228 <__udivdi3+0x118>
  80221c:	31 db                	xor    %ebx,%ebx
  80221e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802222:	0f 87 34 ff ff ff    	ja     80215c <__udivdi3+0x4c>
  802228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80222d:	e9 2a ff ff ff       	jmp    80215c <__udivdi3+0x4c>
  802232:	66 90                	xchg   %ax,%ax
  802234:	66 90                	xchg   %ax,%ax
  802236:	66 90                	xchg   %ax,%ax
  802238:	66 90                	xchg   %ax,%ax
  80223a:	66 90                	xchg   %ax,%ax
  80223c:	66 90                	xchg   %ax,%ax
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80224b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 d2                	test   %edx,%edx
  802259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f3                	mov    %esi,%ebx
  802263:	89 3c 24             	mov    %edi,(%esp)
  802266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80226a:	75 1c                	jne    802288 <__umoddi3+0x48>
  80226c:	39 f7                	cmp    %esi,%edi
  80226e:	76 50                	jbe    8022c0 <__umoddi3+0x80>
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	f7 f7                	div    %edi
  802276:	89 d0                	mov    %edx,%eax
  802278:	31 d2                	xor    %edx,%edx
  80227a:	83 c4 1c             	add    $0x1c,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	77 52                	ja     8022e0 <__umoddi3+0xa0>
  80228e:	0f bd ea             	bsr    %edx,%ebp
  802291:	83 f5 1f             	xor    $0x1f,%ebp
  802294:	75 5a                	jne    8022f0 <__umoddi3+0xb0>
  802296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80229a:	0f 82 e0 00 00 00    	jb     802380 <__umoddi3+0x140>
  8022a0:	39 0c 24             	cmp    %ecx,(%esp)
  8022a3:	0f 86 d7 00 00 00    	jbe    802380 <__umoddi3+0x140>
  8022a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022b1:	83 c4 1c             	add    $0x1c,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5f                   	pop    %edi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	85 ff                	test   %edi,%edi
  8022c2:	89 fd                	mov    %edi,%ebp
  8022c4:	75 0b                	jne    8022d1 <__umoddi3+0x91>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f7                	div    %edi
  8022cf:	89 c5                	mov    %eax,%ebp
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f5                	div    %ebp
  8022d7:	89 c8                	mov    %ecx,%eax
  8022d9:	f7 f5                	div    %ebp
  8022db:	89 d0                	mov    %edx,%eax
  8022dd:	eb 99                	jmp    802278 <__umoddi3+0x38>
  8022df:	90                   	nop
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	83 c4 1c             	add    $0x1c,%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	8b 34 24             	mov    (%esp),%esi
  8022f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022f8:	89 e9                	mov    %ebp,%ecx
  8022fa:	29 ef                	sub    %ebp,%edi
  8022fc:	d3 e0                	shl    %cl,%eax
  8022fe:	89 f9                	mov    %edi,%ecx
  802300:	89 f2                	mov    %esi,%edx
  802302:	d3 ea                	shr    %cl,%edx
  802304:	89 e9                	mov    %ebp,%ecx
  802306:	09 c2                	or     %eax,%edx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 14 24             	mov    %edx,(%esp)
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	d3 e2                	shl    %cl,%edx
  802311:	89 f9                	mov    %edi,%ecx
  802313:	89 54 24 04          	mov    %edx,0x4(%esp)
  802317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	89 c6                	mov    %eax,%esi
  802321:	d3 e3                	shl    %cl,%ebx
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 d0                	mov    %edx,%eax
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	09 d8                	or     %ebx,%eax
  80232d:	89 d3                	mov    %edx,%ebx
  80232f:	89 f2                	mov    %esi,%edx
  802331:	f7 34 24             	divl   (%esp)
  802334:	89 d6                	mov    %edx,%esi
  802336:	d3 e3                	shl    %cl,%ebx
  802338:	f7 64 24 04          	mull   0x4(%esp)
  80233c:	39 d6                	cmp    %edx,%esi
  80233e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802342:	89 d1                	mov    %edx,%ecx
  802344:	89 c3                	mov    %eax,%ebx
  802346:	72 08                	jb     802350 <__umoddi3+0x110>
  802348:	75 11                	jne    80235b <__umoddi3+0x11b>
  80234a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80234e:	73 0b                	jae    80235b <__umoddi3+0x11b>
  802350:	2b 44 24 04          	sub    0x4(%esp),%eax
  802354:	1b 14 24             	sbb    (%esp),%edx
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80235f:	29 da                	sub    %ebx,%edx
  802361:	19 ce                	sbb    %ecx,%esi
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 f0                	mov    %esi,%eax
  802367:	d3 e0                	shl    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	d3 ea                	shr    %cl,%edx
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	d3 ee                	shr    %cl,%esi
  802371:	09 d0                	or     %edx,%eax
  802373:	89 f2                	mov    %esi,%edx
  802375:	83 c4 1c             	add    $0x1c,%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	29 f9                	sub    %edi,%ecx
  802382:	19 d6                	sbb    %edx,%esi
  802384:	89 74 24 04          	mov    %esi,0x4(%esp)
  802388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238c:	e9 18 ff ff ff       	jmp    8022a9 <__umoddi3+0x69>
