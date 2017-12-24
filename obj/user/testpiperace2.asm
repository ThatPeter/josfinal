
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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
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
  80003c:	68 e0 22 80 00       	push   $0x8022e0
  800041:	e8 11 03 00 00       	call   800357 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 1d 1b 00 00       	call   801b6e <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 2e 23 80 00       	push   $0x80232e
  80005e:	6a 0d                	push   $0xd
  800060:	68 37 23 80 00       	push   $0x802337
  800065:	e8 14 02 00 00       	call   80027e <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 37 0f 00 00       	call   800fa6 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 4c 23 80 00       	push   $0x80234c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 37 23 80 00       	push   $0x802337
  800082:	e8 f7 01 00 00       	call   80027e <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 97 12 00 00       	call   80132d <close>
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
  8000be:	68 55 23 80 00       	push   $0x802355
  8000c3:	e8 8f 02 00 00       	call   800357 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 a5 12 00 00       	call   80137d <dup>
			sys_yield();
  8000d8:	e8 e3 0b 00 00       	call   800cc0 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 44 12 00 00       	call   80132d <close>
			sys_yield();
  8000e9:	e8 d2 0b 00 00       	call   800cc0 <sys_yield>
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
  8000fc:	e8 63 01 00 00       	call   800264 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 9f 1b 00 00       	call   801cc1 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 59 23 80 00       	push   $0x802359
  800131:	e8 21 02 00 00       	call   800357 <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 22 0b 00 00       	call   800c60 <sys_env_destroy>
			exit();
  80013e:	e8 21 01 00 00       	call   800264 <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 75 23 80 00       	push   $0x802375
  800161:	e8 f1 01 00 00       	call   800357 <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 50 1b 00 00       	call   801cc1 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 04 23 80 00       	push   $0x802304
  800180:	6a 40                	push   $0x40
  800182:	68 37 23 80 00       	push   $0x802337
  800187:	e8 f2 00 00 00       	call   80027e <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 68 10 00 00       	call   801203 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 8b 23 80 00       	push   $0x80238b
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 37 23 80 00       	push   $0x802337
  8001af:	e8 ca 00 00 00       	call   80027e <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 de 0f 00 00       	call   80119d <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 a3 23 80 00 	movl   $0x8023a3,(%esp)
  8001c6:	e8 8c 01 00 00       	call   800357 <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	57                   	push   %edi
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001df:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8001e6:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8001e9:	e8 b3 0a 00 00       	call   800ca1 <sys_getenvid>
  8001ee:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8001f4:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8001f9:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8001fe:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800203:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800206:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80020c:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  80020f:	39 c8                	cmp    %ecx,%eax
  800211:	0f 44 fb             	cmove  %ebx,%edi
  800214:	b9 01 00 00 00       	mov    $0x1,%ecx
  800219:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80021c:	83 c2 01             	add    $0x1,%edx
  80021f:	83 c3 7c             	add    $0x7c,%ebx
  800222:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800228:	75 d9                	jne    800203 <libmain+0x2d>
  80022a:	89 f0                	mov    %esi,%eax
  80022c:	84 c0                	test   %al,%al
  80022e:	74 06                	je     800236 <libmain+0x60>
  800230:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800236:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80023a:	7e 0a                	jle    800246 <libmain+0x70>
		binaryname = argv[0];
  80023c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023f:	8b 00                	mov    (%eax),%eax
  800241:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	ff 75 0c             	pushl  0xc(%ebp)
  80024c:	ff 75 08             	pushl  0x8(%ebp)
  80024f:	e8 df fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800254:	e8 0b 00 00 00       	call   800264 <exit>
}
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80026a:	e8 e9 10 00 00       	call   801358 <close_all>
	sys_env_destroy(0);
  80026f:	83 ec 0c             	sub    $0xc,%esp
  800272:	6a 00                	push   $0x0
  800274:	e8 e7 09 00 00       	call   800c60 <sys_env_destroy>
}
  800279:	83 c4 10             	add    $0x10,%esp
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	56                   	push   %esi
  800282:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800283:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800286:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80028c:	e8 10 0a 00 00       	call   800ca1 <sys_getenvid>
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	ff 75 0c             	pushl  0xc(%ebp)
  800297:	ff 75 08             	pushl  0x8(%ebp)
  80029a:	56                   	push   %esi
  80029b:	50                   	push   %eax
  80029c:	68 c4 23 80 00       	push   $0x8023c4
  8002a1:	e8 b1 00 00 00       	call   800357 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002a6:	83 c4 18             	add    $0x18,%esp
  8002a9:	53                   	push   %ebx
  8002aa:	ff 75 10             	pushl  0x10(%ebp)
  8002ad:	e8 54 00 00 00       	call   800306 <vcprintf>
	cprintf("\n");
  8002b2:	c7 04 24 53 28 80 00 	movl   $0x802853,(%esp)
  8002b9:	e8 99 00 00 00       	call   800357 <cprintf>
  8002be:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002c1:	cc                   	int3   
  8002c2:	eb fd                	jmp    8002c1 <_panic+0x43>

008002c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	53                   	push   %ebx
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ce:	8b 13                	mov    (%ebx),%edx
  8002d0:	8d 42 01             	lea    0x1(%edx),%eax
  8002d3:	89 03                	mov    %eax,(%ebx)
  8002d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002e1:	75 1a                	jne    8002fd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002e3:	83 ec 08             	sub    $0x8,%esp
  8002e6:	68 ff 00 00 00       	push   $0xff
  8002eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ee:	50                   	push   %eax
  8002ef:	e8 2f 09 00 00       	call   800c23 <sys_cputs>
		b->idx = 0;
  8002f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002fa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002fd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800301:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80030f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800316:	00 00 00 
	b.cnt = 0;
  800319:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800320:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800323:	ff 75 0c             	pushl  0xc(%ebp)
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80032f:	50                   	push   %eax
  800330:	68 c4 02 80 00       	push   $0x8002c4
  800335:	e8 54 01 00 00       	call   80048e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80033a:	83 c4 08             	add    $0x8,%esp
  80033d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800343:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	e8 d4 08 00 00       	call   800c23 <sys_cputs>

	return b.cnt;
}
  80034f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800355:	c9                   	leave  
  800356:	c3                   	ret    

00800357 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80035d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800360:	50                   	push   %eax
  800361:	ff 75 08             	pushl  0x8(%ebp)
  800364:	e8 9d ff ff ff       	call   800306 <vcprintf>
	va_end(ap);

	return cnt;
}
  800369:	c9                   	leave  
  80036a:	c3                   	ret    

0080036b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	57                   	push   %edi
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
  800371:	83 ec 1c             	sub    $0x1c,%esp
  800374:	89 c7                	mov    %eax,%edi
  800376:	89 d6                	mov    %edx,%esi
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80037e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800381:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800384:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800387:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80038f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800392:	39 d3                	cmp    %edx,%ebx
  800394:	72 05                	jb     80039b <printnum+0x30>
  800396:	39 45 10             	cmp    %eax,0x10(%ebp)
  800399:	77 45                	ja     8003e0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80039b:	83 ec 0c             	sub    $0xc,%esp
  80039e:	ff 75 18             	pushl  0x18(%ebp)
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003a7:	53                   	push   %ebx
  8003a8:	ff 75 10             	pushl  0x10(%ebp)
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 91 1c 00 00       	call   802050 <__udivdi3>
  8003bf:	83 c4 18             	add    $0x18,%esp
  8003c2:	52                   	push   %edx
  8003c3:	50                   	push   %eax
  8003c4:	89 f2                	mov    %esi,%edx
  8003c6:	89 f8                	mov    %edi,%eax
  8003c8:	e8 9e ff ff ff       	call   80036b <printnum>
  8003cd:	83 c4 20             	add    $0x20,%esp
  8003d0:	eb 18                	jmp    8003ea <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d2:	83 ec 08             	sub    $0x8,%esp
  8003d5:	56                   	push   %esi
  8003d6:	ff 75 18             	pushl  0x18(%ebp)
  8003d9:	ff d7                	call   *%edi
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	eb 03                	jmp    8003e3 <printnum+0x78>
  8003e0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e3:	83 eb 01             	sub    $0x1,%ebx
  8003e6:	85 db                	test   %ebx,%ebx
  8003e8:	7f e8                	jg     8003d2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	56                   	push   %esi
  8003ee:	83 ec 04             	sub    $0x4,%esp
  8003f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8003fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8003fd:	e8 7e 1d 00 00       	call   802180 <__umoddi3>
  800402:	83 c4 14             	add    $0x14,%esp
  800405:	0f be 80 e7 23 80 00 	movsbl 0x8023e7(%eax),%eax
  80040c:	50                   	push   %eax
  80040d:	ff d7                	call   *%edi
}
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800415:	5b                   	pop    %ebx
  800416:	5e                   	pop    %esi
  800417:	5f                   	pop    %edi
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80041d:	83 fa 01             	cmp    $0x1,%edx
  800420:	7e 0e                	jle    800430 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800422:	8b 10                	mov    (%eax),%edx
  800424:	8d 4a 08             	lea    0x8(%edx),%ecx
  800427:	89 08                	mov    %ecx,(%eax)
  800429:	8b 02                	mov    (%edx),%eax
  80042b:	8b 52 04             	mov    0x4(%edx),%edx
  80042e:	eb 22                	jmp    800452 <getuint+0x38>
	else if (lflag)
  800430:	85 d2                	test   %edx,%edx
  800432:	74 10                	je     800444 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 4a 04             	lea    0x4(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
  800442:	eb 0e                	jmp    800452 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800444:	8b 10                	mov    (%eax),%edx
  800446:	8d 4a 04             	lea    0x4(%edx),%ecx
  800449:	89 08                	mov    %ecx,(%eax)
  80044b:	8b 02                	mov    (%edx),%eax
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800452:	5d                   	pop    %ebp
  800453:	c3                   	ret    

00800454 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80045a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	3b 50 04             	cmp    0x4(%eax),%edx
  800463:	73 0a                	jae    80046f <sprintputch+0x1b>
		*b->buf++ = ch;
  800465:	8d 4a 01             	lea    0x1(%edx),%ecx
  800468:	89 08                	mov    %ecx,(%eax)
  80046a:	8b 45 08             	mov    0x8(%ebp),%eax
  80046d:	88 02                	mov    %al,(%edx)
}
  80046f:	5d                   	pop    %ebp
  800470:	c3                   	ret    

00800471 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800477:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80047a:	50                   	push   %eax
  80047b:	ff 75 10             	pushl  0x10(%ebp)
  80047e:	ff 75 0c             	pushl  0xc(%ebp)
  800481:	ff 75 08             	pushl  0x8(%ebp)
  800484:	e8 05 00 00 00       	call   80048e <vprintfmt>
	va_end(ap);
}
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	c9                   	leave  
  80048d:	c3                   	ret    

0080048e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	57                   	push   %edi
  800492:	56                   	push   %esi
  800493:	53                   	push   %ebx
  800494:	83 ec 2c             	sub    $0x2c,%esp
  800497:	8b 75 08             	mov    0x8(%ebp),%esi
  80049a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004a0:	eb 12                	jmp    8004b4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	0f 84 89 03 00 00    	je     800833 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	50                   	push   %eax
  8004af:	ff d6                	call   *%esi
  8004b1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b4:	83 c7 01             	add    $0x1,%edi
  8004b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004bb:	83 f8 25             	cmp    $0x25,%eax
  8004be:	75 e2                	jne    8004a2 <vprintfmt+0x14>
  8004c0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004c4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004de:	eb 07                	jmp    8004e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004e3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8d 47 01             	lea    0x1(%edi),%eax
  8004ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ed:	0f b6 07             	movzbl (%edi),%eax
  8004f0:	0f b6 c8             	movzbl %al,%ecx
  8004f3:	83 e8 23             	sub    $0x23,%eax
  8004f6:	3c 55                	cmp    $0x55,%al
  8004f8:	0f 87 1a 03 00 00    	ja     800818 <vprintfmt+0x38a>
  8004fe:	0f b6 c0             	movzbl %al,%eax
  800501:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80050b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80050f:	eb d6                	jmp    8004e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800511:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800514:	b8 00 00 00 00       	mov    $0x0,%eax
  800519:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80051c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80051f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800523:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800526:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800529:	83 fa 09             	cmp    $0x9,%edx
  80052c:	77 39                	ja     800567 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80052e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800531:	eb e9                	jmp    80051c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 48 04             	lea    0x4(%eax),%ecx
  800539:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80053c:	8b 00                	mov    (%eax),%eax
  80053e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800544:	eb 27                	jmp    80056d <vprintfmt+0xdf>
  800546:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800549:	85 c0                	test   %eax,%eax
  80054b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800550:	0f 49 c8             	cmovns %eax,%ecx
  800553:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800559:	eb 8c                	jmp    8004e7 <vprintfmt+0x59>
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80055e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800565:	eb 80                	jmp    8004e7 <vprintfmt+0x59>
  800567:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80056a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80056d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800571:	0f 89 70 ff ff ff    	jns    8004e7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800577:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80057a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800584:	e9 5e ff ff ff       	jmp    8004e7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800589:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80058f:	e9 53 ff ff ff       	jmp    8004e7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	ff 30                	pushl  (%eax)
  8005a3:	ff d6                	call   *%esi
			break;
  8005a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005ab:	e9 04 ff ff ff       	jmp    8004b4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	99                   	cltd   
  8005bc:	31 d0                	xor    %edx,%eax
  8005be:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c0:	83 f8 0f             	cmp    $0xf,%eax
  8005c3:	7f 0b                	jg     8005d0 <vprintfmt+0x142>
  8005c5:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8005cc:	85 d2                	test   %edx,%edx
  8005ce:	75 18                	jne    8005e8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005d0:	50                   	push   %eax
  8005d1:	68 ff 23 80 00       	push   $0x8023ff
  8005d6:	53                   	push   %ebx
  8005d7:	56                   	push   %esi
  8005d8:	e8 94 fe ff ff       	call   800471 <printfmt>
  8005dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005e3:	e9 cc fe ff ff       	jmp    8004b4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005e8:	52                   	push   %edx
  8005e9:	68 21 28 80 00       	push   $0x802821
  8005ee:	53                   	push   %ebx
  8005ef:	56                   	push   %esi
  8005f0:	e8 7c fe ff ff       	call   800471 <printfmt>
  8005f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fb:	e9 b4 fe ff ff       	jmp    8004b4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80060b:	85 ff                	test   %edi,%edi
  80060d:	b8 f8 23 80 00       	mov    $0x8023f8,%eax
  800612:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800615:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800619:	0f 8e 94 00 00 00    	jle    8006b3 <vprintfmt+0x225>
  80061f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800623:	0f 84 98 00 00 00    	je     8006c1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	ff 75 d0             	pushl  -0x30(%ebp)
  80062f:	57                   	push   %edi
  800630:	e8 86 02 00 00       	call   8008bb <strnlen>
  800635:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800638:	29 c1                	sub    %eax,%ecx
  80063a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80063d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800640:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800644:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800647:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80064a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064c:	eb 0f                	jmp    80065d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	ff 75 e0             	pushl  -0x20(%ebp)
  800655:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800657:	83 ef 01             	sub    $0x1,%edi
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	85 ff                	test   %edi,%edi
  80065f:	7f ed                	jg     80064e <vprintfmt+0x1c0>
  800661:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800664:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800667:	85 c9                	test   %ecx,%ecx
  800669:	b8 00 00 00 00       	mov    $0x0,%eax
  80066e:	0f 49 c1             	cmovns %ecx,%eax
  800671:	29 c1                	sub    %eax,%ecx
  800673:	89 75 08             	mov    %esi,0x8(%ebp)
  800676:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800679:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067c:	89 cb                	mov    %ecx,%ebx
  80067e:	eb 4d                	jmp    8006cd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800680:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800684:	74 1b                	je     8006a1 <vprintfmt+0x213>
  800686:	0f be c0             	movsbl %al,%eax
  800689:	83 e8 20             	sub    $0x20,%eax
  80068c:	83 f8 5e             	cmp    $0x5e,%eax
  80068f:	76 10                	jbe    8006a1 <vprintfmt+0x213>
					putch('?', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	ff 75 0c             	pushl  0xc(%ebp)
  800697:	6a 3f                	push   $0x3f
  800699:	ff 55 08             	call   *0x8(%ebp)
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	eb 0d                	jmp    8006ae <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff 55 08             	call   *0x8(%ebp)
  8006ab:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ae:	83 eb 01             	sub    $0x1,%ebx
  8006b1:	eb 1a                	jmp    8006cd <vprintfmt+0x23f>
  8006b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006bf:	eb 0c                	jmp    8006cd <vprintfmt+0x23f>
  8006c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006cd:	83 c7 01             	add    $0x1,%edi
  8006d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d4:	0f be d0             	movsbl %al,%edx
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	74 23                	je     8006fe <vprintfmt+0x270>
  8006db:	85 f6                	test   %esi,%esi
  8006dd:	78 a1                	js     800680 <vprintfmt+0x1f2>
  8006df:	83 ee 01             	sub    $0x1,%esi
  8006e2:	79 9c                	jns    800680 <vprintfmt+0x1f2>
  8006e4:	89 df                	mov    %ebx,%edi
  8006e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ec:	eb 18                	jmp    800706 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 20                	push   $0x20
  8006f4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f6:	83 ef 01             	sub    $0x1,%edi
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb 08                	jmp    800706 <vprintfmt+0x278>
  8006fe:	89 df                	mov    %ebx,%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800706:	85 ff                	test   %edi,%edi
  800708:	7f e4                	jg     8006ee <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070d:	e9 a2 fd ff ff       	jmp    8004b4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800712:	83 fa 01             	cmp    $0x1,%edx
  800715:	7e 16                	jle    80072d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 50 08             	lea    0x8(%eax),%edx
  80071d:	89 55 14             	mov    %edx,0x14(%ebp)
  800720:	8b 50 04             	mov    0x4(%eax),%edx
  800723:	8b 00                	mov    (%eax),%eax
  800725:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800728:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80072b:	eb 32                	jmp    80075f <vprintfmt+0x2d1>
	else if (lflag)
  80072d:	85 d2                	test   %edx,%edx
  80072f:	74 18                	je     800749 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 04             	lea    0x4(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073f:	89 c1                	mov    %eax,%ecx
  800741:	c1 f9 1f             	sar    $0x1f,%ecx
  800744:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800747:	eb 16                	jmp    80075f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8d 50 04             	lea    0x4(%eax),%edx
  80074f:	89 55 14             	mov    %edx,0x14(%ebp)
  800752:	8b 00                	mov    (%eax),%eax
  800754:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800757:	89 c1                	mov    %eax,%ecx
  800759:	c1 f9 1f             	sar    $0x1f,%ecx
  80075c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800762:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800765:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80076a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80076e:	79 74                	jns    8007e4 <vprintfmt+0x356>
				putch('-', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	53                   	push   %ebx
  800774:	6a 2d                	push   $0x2d
  800776:	ff d6                	call   *%esi
				num = -(long long) num;
  800778:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80077e:	f7 d8                	neg    %eax
  800780:	83 d2 00             	adc    $0x0,%edx
  800783:	f7 da                	neg    %edx
  800785:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800788:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80078d:	eb 55                	jmp    8007e4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 83 fc ff ff       	call   80041a <getuint>
			base = 10;
  800797:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80079c:	eb 46                	jmp    8007e4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a1:	e8 74 fc ff ff       	call   80041a <getuint>
			base = 8;
  8007a6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007ab:	eb 37                	jmp    8007e4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	6a 30                	push   $0x30
  8007b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8007b5:	83 c4 08             	add    $0x8,%esp
  8007b8:	53                   	push   %ebx
  8007b9:	6a 78                	push   $0x78
  8007bb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 04             	lea    0x4(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007c6:	8b 00                	mov    (%eax),%eax
  8007c8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007d5:	eb 0d                	jmp    8007e4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007da:	e8 3b fc ff ff       	call   80041a <getuint>
			base = 16;
  8007df:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e4:	83 ec 0c             	sub    $0xc,%esp
  8007e7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007eb:	57                   	push   %edi
  8007ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ef:	51                   	push   %ecx
  8007f0:	52                   	push   %edx
  8007f1:	50                   	push   %eax
  8007f2:	89 da                	mov    %ebx,%edx
  8007f4:	89 f0                	mov    %esi,%eax
  8007f6:	e8 70 fb ff ff       	call   80036b <printnum>
			break;
  8007fb:	83 c4 20             	add    $0x20,%esp
  8007fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800801:	e9 ae fc ff ff       	jmp    8004b4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	53                   	push   %ebx
  80080a:	51                   	push   %ecx
  80080b:	ff d6                	call   *%esi
			break;
  80080d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800810:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800813:	e9 9c fc ff ff       	jmp    8004b4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	6a 25                	push   $0x25
  80081e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	eb 03                	jmp    800828 <vprintfmt+0x39a>
  800825:	83 ef 01             	sub    $0x1,%edi
  800828:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80082c:	75 f7                	jne    800825 <vprintfmt+0x397>
  80082e:	e9 81 fc ff ff       	jmp    8004b4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800833:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5f                   	pop    %edi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	83 ec 18             	sub    $0x18,%esp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800847:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80084e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800851:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800858:	85 c0                	test   %eax,%eax
  80085a:	74 26                	je     800882 <vsnprintf+0x47>
  80085c:	85 d2                	test   %edx,%edx
  80085e:	7e 22                	jle    800882 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800860:	ff 75 14             	pushl  0x14(%ebp)
  800863:	ff 75 10             	pushl  0x10(%ebp)
  800866:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800869:	50                   	push   %eax
  80086a:	68 54 04 80 00       	push   $0x800454
  80086f:	e8 1a fc ff ff       	call   80048e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800874:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800877:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	eb 05                	jmp    800887 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800882:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80088f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800892:	50                   	push   %eax
  800893:	ff 75 10             	pushl  0x10(%ebp)
  800896:	ff 75 0c             	pushl  0xc(%ebp)
  800899:	ff 75 08             	pushl  0x8(%ebp)
  80089c:	e8 9a ff ff ff       	call   80083b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ae:	eb 03                	jmp    8008b3 <strlen+0x10>
		n++;
  8008b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b7:	75 f7                	jne    8008b0 <strlen+0xd>
		n++;
	return n;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c9:	eb 03                	jmp    8008ce <strnlen+0x13>
		n++;
  8008cb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ce:	39 c2                	cmp    %eax,%edx
  8008d0:	74 08                	je     8008da <strnlen+0x1f>
  8008d2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008d6:	75 f3                	jne    8008cb <strnlen+0x10>
  8008d8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	53                   	push   %ebx
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e6:	89 c2                	mov    %eax,%edx
  8008e8:	83 c2 01             	add    $0x1,%edx
  8008eb:	83 c1 01             	add    $0x1,%ecx
  8008ee:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f5:	84 db                	test   %bl,%bl
  8008f7:	75 ef                	jne    8008e8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f9:	5b                   	pop    %ebx
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	53                   	push   %ebx
  800900:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800903:	53                   	push   %ebx
  800904:	e8 9a ff ff ff       	call   8008a3 <strlen>
  800909:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80090c:	ff 75 0c             	pushl  0xc(%ebp)
  80090f:	01 d8                	add    %ebx,%eax
  800911:	50                   	push   %eax
  800912:	e8 c5 ff ff ff       	call   8008dc <strcpy>
	return dst;
}
  800917:	89 d8                	mov    %ebx,%eax
  800919:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 75 08             	mov    0x8(%ebp),%esi
  800926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800929:	89 f3                	mov    %esi,%ebx
  80092b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092e:	89 f2                	mov    %esi,%edx
  800930:	eb 0f                	jmp    800941 <strncpy+0x23>
		*dst++ = *src;
  800932:	83 c2 01             	add    $0x1,%edx
  800935:	0f b6 01             	movzbl (%ecx),%eax
  800938:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093b:	80 39 01             	cmpb   $0x1,(%ecx)
  80093e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800941:	39 da                	cmp    %ebx,%edx
  800943:	75 ed                	jne    800932 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800945:	89 f0                	mov    %esi,%eax
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 75 08             	mov    0x8(%ebp),%esi
  800953:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800956:	8b 55 10             	mov    0x10(%ebp),%edx
  800959:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095b:	85 d2                	test   %edx,%edx
  80095d:	74 21                	je     800980 <strlcpy+0x35>
  80095f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800963:	89 f2                	mov    %esi,%edx
  800965:	eb 09                	jmp    800970 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800967:	83 c2 01             	add    $0x1,%edx
  80096a:	83 c1 01             	add    $0x1,%ecx
  80096d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800970:	39 c2                	cmp    %eax,%edx
  800972:	74 09                	je     80097d <strlcpy+0x32>
  800974:	0f b6 19             	movzbl (%ecx),%ebx
  800977:	84 db                	test   %bl,%bl
  800979:	75 ec                	jne    800967 <strlcpy+0x1c>
  80097b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80097d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800980:	29 f0                	sub    %esi,%eax
}
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80098f:	eb 06                	jmp    800997 <strcmp+0x11>
		p++, q++;
  800991:	83 c1 01             	add    $0x1,%ecx
  800994:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800997:	0f b6 01             	movzbl (%ecx),%eax
  80099a:	84 c0                	test   %al,%al
  80099c:	74 04                	je     8009a2 <strcmp+0x1c>
  80099e:	3a 02                	cmp    (%edx),%al
  8009a0:	74 ef                	je     800991 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a2:	0f b6 c0             	movzbl %al,%eax
  8009a5:	0f b6 12             	movzbl (%edx),%edx
  8009a8:	29 d0                	sub    %edx,%eax
}
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	53                   	push   %ebx
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b6:	89 c3                	mov    %eax,%ebx
  8009b8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009bb:	eb 06                	jmp    8009c3 <strncmp+0x17>
		n--, p++, q++;
  8009bd:	83 c0 01             	add    $0x1,%eax
  8009c0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c3:	39 d8                	cmp    %ebx,%eax
  8009c5:	74 15                	je     8009dc <strncmp+0x30>
  8009c7:	0f b6 08             	movzbl (%eax),%ecx
  8009ca:	84 c9                	test   %cl,%cl
  8009cc:	74 04                	je     8009d2 <strncmp+0x26>
  8009ce:	3a 0a                	cmp    (%edx),%cl
  8009d0:	74 eb                	je     8009bd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d2:	0f b6 00             	movzbl (%eax),%eax
  8009d5:	0f b6 12             	movzbl (%edx),%edx
  8009d8:	29 d0                	sub    %edx,%eax
  8009da:	eb 05                	jmp    8009e1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ee:	eb 07                	jmp    8009f7 <strchr+0x13>
		if (*s == c)
  8009f0:	38 ca                	cmp    %cl,%dl
  8009f2:	74 0f                	je     800a03 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	0f b6 10             	movzbl (%eax),%edx
  8009fa:	84 d2                	test   %dl,%dl
  8009fc:	75 f2                	jne    8009f0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0f:	eb 03                	jmp    800a14 <strfind+0xf>
  800a11:	83 c0 01             	add    $0x1,%eax
  800a14:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a17:	38 ca                	cmp    %cl,%dl
  800a19:	74 04                	je     800a1f <strfind+0x1a>
  800a1b:	84 d2                	test   %dl,%dl
  800a1d:	75 f2                	jne    800a11 <strfind+0xc>
			break;
	return (char *) s;
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	57                   	push   %edi
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2d:	85 c9                	test   %ecx,%ecx
  800a2f:	74 36                	je     800a67 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a37:	75 28                	jne    800a61 <memset+0x40>
  800a39:	f6 c1 03             	test   $0x3,%cl
  800a3c:	75 23                	jne    800a61 <memset+0x40>
		c &= 0xFF;
  800a3e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a42:	89 d3                	mov    %edx,%ebx
  800a44:	c1 e3 08             	shl    $0x8,%ebx
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	c1 e6 18             	shl    $0x18,%esi
  800a4c:	89 d0                	mov    %edx,%eax
  800a4e:	c1 e0 10             	shl    $0x10,%eax
  800a51:	09 f0                	or     %esi,%eax
  800a53:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a55:	89 d8                	mov    %ebx,%eax
  800a57:	09 d0                	or     %edx,%eax
  800a59:	c1 e9 02             	shr    $0x2,%ecx
  800a5c:	fc                   	cld    
  800a5d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a5f:	eb 06                	jmp    800a67 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a64:	fc                   	cld    
  800a65:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a67:	89 f8                	mov    %edi,%eax
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7c:	39 c6                	cmp    %eax,%esi
  800a7e:	73 35                	jae    800ab5 <memmove+0x47>
  800a80:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a83:	39 d0                	cmp    %edx,%eax
  800a85:	73 2e                	jae    800ab5 <memmove+0x47>
		s += n;
		d += n;
  800a87:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8a:	89 d6                	mov    %edx,%esi
  800a8c:	09 fe                	or     %edi,%esi
  800a8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a94:	75 13                	jne    800aa9 <memmove+0x3b>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 0e                	jne    800aa9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a9b:	83 ef 04             	sub    $0x4,%edi
  800a9e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa1:	c1 e9 02             	shr    $0x2,%ecx
  800aa4:	fd                   	std    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb 09                	jmp    800ab2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa9:	83 ef 01             	sub    $0x1,%edi
  800aac:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aaf:	fd                   	std    
  800ab0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab2:	fc                   	cld    
  800ab3:	eb 1d                	jmp    800ad2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab5:	89 f2                	mov    %esi,%edx
  800ab7:	09 c2                	or     %eax,%edx
  800ab9:	f6 c2 03             	test   $0x3,%dl
  800abc:	75 0f                	jne    800acd <memmove+0x5f>
  800abe:	f6 c1 03             	test   $0x3,%cl
  800ac1:	75 0a                	jne    800acd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ac3:	c1 e9 02             	shr    $0x2,%ecx
  800ac6:	89 c7                	mov    %eax,%edi
  800ac8:	fc                   	cld    
  800ac9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acb:	eb 05                	jmp    800ad2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	fc                   	cld    
  800ad0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ad9:	ff 75 10             	pushl  0x10(%ebp)
  800adc:	ff 75 0c             	pushl  0xc(%ebp)
  800adf:	ff 75 08             	pushl  0x8(%ebp)
  800ae2:	e8 87 ff ff ff       	call   800a6e <memmove>
}
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af4:	89 c6                	mov    %eax,%esi
  800af6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	eb 1a                	jmp    800b15 <memcmp+0x2c>
		if (*s1 != *s2)
  800afb:	0f b6 08             	movzbl (%eax),%ecx
  800afe:	0f b6 1a             	movzbl (%edx),%ebx
  800b01:	38 d9                	cmp    %bl,%cl
  800b03:	74 0a                	je     800b0f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b05:	0f b6 c1             	movzbl %cl,%eax
  800b08:	0f b6 db             	movzbl %bl,%ebx
  800b0b:	29 d8                	sub    %ebx,%eax
  800b0d:	eb 0f                	jmp    800b1e <memcmp+0x35>
		s1++, s2++;
  800b0f:	83 c0 01             	add    $0x1,%eax
  800b12:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b15:	39 f0                	cmp    %esi,%eax
  800b17:	75 e2                	jne    800afb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b29:	89 c1                	mov    %eax,%ecx
  800b2b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b32:	eb 0a                	jmp    800b3e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b34:	0f b6 10             	movzbl (%eax),%edx
  800b37:	39 da                	cmp    %ebx,%edx
  800b39:	74 07                	je     800b42 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b3b:	83 c0 01             	add    $0x1,%eax
  800b3e:	39 c8                	cmp    %ecx,%eax
  800b40:	72 f2                	jb     800b34 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b42:	5b                   	pop    %ebx
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b51:	eb 03                	jmp    800b56 <strtol+0x11>
		s++;
  800b53:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b56:	0f b6 01             	movzbl (%ecx),%eax
  800b59:	3c 20                	cmp    $0x20,%al
  800b5b:	74 f6                	je     800b53 <strtol+0xe>
  800b5d:	3c 09                	cmp    $0x9,%al
  800b5f:	74 f2                	je     800b53 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b61:	3c 2b                	cmp    $0x2b,%al
  800b63:	75 0a                	jne    800b6f <strtol+0x2a>
		s++;
  800b65:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b68:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6d:	eb 11                	jmp    800b80 <strtol+0x3b>
  800b6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b74:	3c 2d                	cmp    $0x2d,%al
  800b76:	75 08                	jne    800b80 <strtol+0x3b>
		s++, neg = 1;
  800b78:	83 c1 01             	add    $0x1,%ecx
  800b7b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b80:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b86:	75 15                	jne    800b9d <strtol+0x58>
  800b88:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8b:	75 10                	jne    800b9d <strtol+0x58>
  800b8d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b91:	75 7c                	jne    800c0f <strtol+0xca>
		s += 2, base = 16;
  800b93:	83 c1 02             	add    $0x2,%ecx
  800b96:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9b:	eb 16                	jmp    800bb3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b9d:	85 db                	test   %ebx,%ebx
  800b9f:	75 12                	jne    800bb3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba9:	75 08                	jne    800bb3 <strtol+0x6e>
		s++, base = 8;
  800bab:	83 c1 01             	add    $0x1,%ecx
  800bae:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bbb:	0f b6 11             	movzbl (%ecx),%edx
  800bbe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc1:	89 f3                	mov    %esi,%ebx
  800bc3:	80 fb 09             	cmp    $0x9,%bl
  800bc6:	77 08                	ja     800bd0 <strtol+0x8b>
			dig = *s - '0';
  800bc8:	0f be d2             	movsbl %dl,%edx
  800bcb:	83 ea 30             	sub    $0x30,%edx
  800bce:	eb 22                	jmp    800bf2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bd0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd3:	89 f3                	mov    %esi,%ebx
  800bd5:	80 fb 19             	cmp    $0x19,%bl
  800bd8:	77 08                	ja     800be2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bda:	0f be d2             	movsbl %dl,%edx
  800bdd:	83 ea 57             	sub    $0x57,%edx
  800be0:	eb 10                	jmp    800bf2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800be2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be5:	89 f3                	mov    %esi,%ebx
  800be7:	80 fb 19             	cmp    $0x19,%bl
  800bea:	77 16                	ja     800c02 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bec:	0f be d2             	movsbl %dl,%edx
  800bef:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bf2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf5:	7d 0b                	jge    800c02 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bfe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c00:	eb b9                	jmp    800bbb <strtol+0x76>

	if (endptr)
  800c02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c06:	74 0d                	je     800c15 <strtol+0xd0>
		*endptr = (char *) s;
  800c08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0b:	89 0e                	mov    %ecx,(%esi)
  800c0d:	eb 06                	jmp    800c15 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0f:	85 db                	test   %ebx,%ebx
  800c11:	74 98                	je     800bab <strtol+0x66>
  800c13:	eb 9e                	jmp    800bb3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c15:	89 c2                	mov    %eax,%edx
  800c17:	f7 da                	neg    %edx
  800c19:	85 ff                	test   %edi,%edi
  800c1b:	0f 45 c2             	cmovne %edx,%eax
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	89 c3                	mov    %eax,%ebx
  800c36:	89 c7                	mov    %eax,%edi
  800c38:	89 c6                	mov    %eax,%esi
  800c3a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c51:	89 d1                	mov    %edx,%ecx
  800c53:	89 d3                	mov    %edx,%ebx
  800c55:	89 d7                	mov    %edx,%edi
  800c57:	89 d6                	mov    %edx,%esi
  800c59:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	89 cb                	mov    %ecx,%ebx
  800c78:	89 cf                	mov    %ecx,%edi
  800c7a:	89 ce                	mov    %ecx,%esi
  800c7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 17                	jle    800c99 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 03                	push   $0x3
  800c88:	68 df 26 80 00       	push   $0x8026df
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 fc 26 80 00       	push   $0x8026fc
  800c94:	e8 e5 f5 ff ff       	call   80027e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cac:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb1:	89 d1                	mov    %edx,%ecx
  800cb3:	89 d3                	mov    %edx,%ebx
  800cb5:	89 d7                	mov    %edx,%edi
  800cb7:	89 d6                	mov    %edx,%esi
  800cb9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_yield>:

void
sys_yield(void)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd0:	89 d1                	mov    %edx,%ecx
  800cd2:	89 d3                	mov    %edx,%ebx
  800cd4:	89 d7                	mov    %edx,%edi
  800cd6:	89 d6                	mov    %edx,%esi
  800cd8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	be 00 00 00 00       	mov    $0x0,%esi
  800ced:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfb:	89 f7                	mov    %esi,%edi
  800cfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 17                	jle    800d1a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 04                	push   $0x4
  800d09:	68 df 26 80 00       	push   $0x8026df
  800d0e:	6a 23                	push   $0x23
  800d10:	68 fc 26 80 00       	push   $0x8026fc
  800d15:	e8 64 f5 ff ff       	call   80027e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7e 17                	jle    800d5c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	50                   	push   %eax
  800d49:	6a 05                	push   $0x5
  800d4b:	68 df 26 80 00       	push   $0x8026df
  800d50:	6a 23                	push   $0x23
  800d52:	68 fc 26 80 00       	push   $0x8026fc
  800d57:	e8 22 f5 ff ff       	call   80027e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	b8 06 00 00 00       	mov    $0x6,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 17                	jle    800d9e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	50                   	push   %eax
  800d8b:	6a 06                	push   $0x6
  800d8d:	68 df 26 80 00       	push   $0x8026df
  800d92:	6a 23                	push   $0x23
  800d94:	68 fc 26 80 00       	push   $0x8026fc
  800d99:	e8 e0 f4 ff ff       	call   80027e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db4:	b8 08 00 00 00       	mov    $0x8,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 df                	mov    %ebx,%edi
  800dc1:	89 de                	mov    %ebx,%esi
  800dc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 17                	jle    800de0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	50                   	push   %eax
  800dcd:	6a 08                	push   $0x8
  800dcf:	68 df 26 80 00       	push   $0x8026df
  800dd4:	6a 23                	push   $0x23
  800dd6:	68 fc 26 80 00       	push   $0x8026fc
  800ddb:	e8 9e f4 ff ff       	call   80027e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df6:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	89 df                	mov    %ebx,%edi
  800e03:	89 de                	mov    %ebx,%esi
  800e05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e07:	85 c0                	test   %eax,%eax
  800e09:	7e 17                	jle    800e22 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0b:	83 ec 0c             	sub    $0xc,%esp
  800e0e:	50                   	push   %eax
  800e0f:	6a 09                	push   $0x9
  800e11:	68 df 26 80 00       	push   $0x8026df
  800e16:	6a 23                	push   $0x23
  800e18:	68 fc 26 80 00       	push   $0x8026fc
  800e1d:	e8 5c f4 ff ff       	call   80027e <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	89 df                	mov    %ebx,%edi
  800e45:	89 de                	mov    %ebx,%esi
  800e47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 17                	jle    800e64 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	50                   	push   %eax
  800e51:	6a 0a                	push   $0xa
  800e53:	68 df 26 80 00       	push   $0x8026df
  800e58:	6a 23                	push   $0x23
  800e5a:	68 fc 26 80 00       	push   $0x8026fc
  800e5f:	e8 1a f4 ff ff       	call   80027e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e72:	be 00 00 00 00       	mov    $0x0,%esi
  800e77:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e88:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	57                   	push   %edi
  800e93:	56                   	push   %esi
  800e94:	53                   	push   %ebx
  800e95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	89 cb                	mov    %ecx,%ebx
  800ea7:	89 cf                	mov    %ecx,%edi
  800ea9:	89 ce                	mov    %ecx,%esi
  800eab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 17                	jle    800ec8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	50                   	push   %eax
  800eb5:	6a 0d                	push   $0xd
  800eb7:	68 df 26 80 00       	push   $0x8026df
  800ebc:	6a 23                	push   $0x23
  800ebe:	68 fc 26 80 00       	push   $0x8026fc
  800ec3:	e8 b6 f3 ff ff       	call   80027e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 04             	sub    $0x4,%esp
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eda:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800edc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee0:	74 11                	je     800ef3 <pgfault+0x23>
  800ee2:	89 d8                	mov    %ebx,%eax
  800ee4:	c1 e8 0c             	shr    $0xc,%eax
  800ee7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eee:	f6 c4 08             	test   $0x8,%ah
  800ef1:	75 14                	jne    800f07 <pgfault+0x37>
		panic("faulting access");
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 0a 27 80 00       	push   $0x80270a
  800efb:	6a 1d                	push   $0x1d
  800efd:	68 1a 27 80 00       	push   $0x80271a
  800f02:	e8 77 f3 ff ff       	call   80027e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	6a 07                	push   $0x7
  800f0c:	68 00 f0 7f 00       	push   $0x7ff000
  800f11:	6a 00                	push   $0x0
  800f13:	e8 c7 fd ff ff       	call   800cdf <sys_page_alloc>
	if (r < 0) {
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	79 12                	jns    800f31 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800f1f:	50                   	push   %eax
  800f20:	68 25 27 80 00       	push   $0x802725
  800f25:	6a 2b                	push   $0x2b
  800f27:	68 1a 27 80 00       	push   $0x80271a
  800f2c:	e8 4d f3 ff ff       	call   80027e <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f31:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800f37:	83 ec 04             	sub    $0x4,%esp
  800f3a:	68 00 10 00 00       	push   $0x1000
  800f3f:	53                   	push   %ebx
  800f40:	68 00 f0 7f 00       	push   $0x7ff000
  800f45:	e8 8c fb ff ff       	call   800ad6 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800f4a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f51:	53                   	push   %ebx
  800f52:	6a 00                	push   $0x0
  800f54:	68 00 f0 7f 00       	push   $0x7ff000
  800f59:	6a 00                	push   $0x0
  800f5b:	e8 c2 fd ff ff       	call   800d22 <sys_page_map>
	if (r < 0) {
  800f60:	83 c4 20             	add    $0x20,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	79 12                	jns    800f79 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800f67:	50                   	push   %eax
  800f68:	68 25 27 80 00       	push   $0x802725
  800f6d:	6a 32                	push   $0x32
  800f6f:	68 1a 27 80 00       	push   $0x80271a
  800f74:	e8 05 f3 ff ff       	call   80027e <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800f79:	83 ec 08             	sub    $0x8,%esp
  800f7c:	68 00 f0 7f 00       	push   $0x7ff000
  800f81:	6a 00                	push   $0x0
  800f83:	e8 dc fd ff ff       	call   800d64 <sys_page_unmap>
	if (r < 0) {
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	79 12                	jns    800fa1 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800f8f:	50                   	push   %eax
  800f90:	68 25 27 80 00       	push   $0x802725
  800f95:	6a 36                	push   $0x36
  800f97:	68 1a 27 80 00       	push   $0x80271a
  800f9c:	e8 dd f2 ff ff       	call   80027e <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800fa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800faf:	68 d0 0e 80 00       	push   $0x800ed0
  800fb4:	e8 be 0e 00 00       	call   801e77 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb9:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbe:	cd 30                	int    $0x30
  800fc0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	79 17                	jns    800fe1 <fork+0x3b>
		panic("fork fault %e");
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	68 3e 27 80 00       	push   $0x80273e
  800fd2:	68 83 00 00 00       	push   $0x83
  800fd7:	68 1a 27 80 00       	push   $0x80271a
  800fdc:	e8 9d f2 ff ff       	call   80027e <_panic>
  800fe1:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800fe3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fe7:	75 21                	jne    80100a <fork+0x64>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe9:	e8 b3 fc ff ff       	call   800ca1 <sys_getenvid>
  800fee:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ff6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ffb:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801000:	b8 00 00 00 00       	mov    $0x0,%eax
  801005:	e9 61 01 00 00       	jmp    80116b <fork+0x1c5>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80100a:	83 ec 04             	sub    $0x4,%esp
  80100d:	6a 07                	push   $0x7
  80100f:	68 00 f0 bf ee       	push   $0xeebff000
  801014:	ff 75 e4             	pushl  -0x1c(%ebp)
  801017:	e8 c3 fc ff ff       	call   800cdf <sys_page_alloc>
  80101c:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80101f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801024:	89 d8                	mov    %ebx,%eax
  801026:	c1 e8 16             	shr    $0x16,%eax
  801029:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801030:	a8 01                	test   $0x1,%al
  801032:	0f 84 fc 00 00 00    	je     801134 <fork+0x18e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  801038:	89 d8                	mov    %ebx,%eax
  80103a:	c1 e8 0c             	shr    $0xc,%eax
  80103d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801044:	f6 c2 01             	test   $0x1,%dl
  801047:	0f 84 e7 00 00 00    	je     801134 <fork+0x18e>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80104d:	89 c6                	mov    %eax,%esi
  80104f:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  801052:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801059:	f6 c6 04             	test   $0x4,%dh
  80105c:	74 39                	je     801097 <fork+0xf1>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80105e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	25 07 0e 00 00       	and    $0xe07,%eax
  80106d:	50                   	push   %eax
  80106e:	56                   	push   %esi
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	6a 00                	push   $0x0
  801073:	e8 aa fc ff ff       	call   800d22 <sys_page_map>
		if (r < 0) {
  801078:	83 c4 20             	add    $0x20,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	0f 89 b1 00 00 00    	jns    801134 <fork+0x18e>
		    	panic("sys page map fault %e");
  801083:	83 ec 04             	sub    $0x4,%esp
  801086:	68 4c 27 80 00       	push   $0x80274c
  80108b:	6a 53                	push   $0x53
  80108d:	68 1a 27 80 00       	push   $0x80271a
  801092:	e8 e7 f1 ff ff       	call   80027e <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801097:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80109e:	f6 c2 02             	test   $0x2,%dl
  8010a1:	75 0c                	jne    8010af <fork+0x109>
  8010a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010aa:	f6 c4 08             	test   $0x8,%ah
  8010ad:	74 5b                	je     80110a <fork+0x164>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	68 05 08 00 00       	push   $0x805
  8010b7:	56                   	push   %esi
  8010b8:	57                   	push   %edi
  8010b9:	56                   	push   %esi
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 61 fc ff ff       	call   800d22 <sys_page_map>
		if (r < 0) {
  8010c1:	83 c4 20             	add    $0x20,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	79 14                	jns    8010dc <fork+0x136>
		    	panic("sys page map fault %e");
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	68 4c 27 80 00       	push   $0x80274c
  8010d0:	6a 5a                	push   $0x5a
  8010d2:	68 1a 27 80 00       	push   $0x80271a
  8010d7:	e8 a2 f1 ff ff       	call   80027e <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	68 05 08 00 00       	push   $0x805
  8010e4:	56                   	push   %esi
  8010e5:	6a 00                	push   $0x0
  8010e7:	56                   	push   %esi
  8010e8:	6a 00                	push   $0x0
  8010ea:	e8 33 fc ff ff       	call   800d22 <sys_page_map>
		if (r < 0) {
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 3e                	jns    801134 <fork+0x18e>
		    	panic("sys page map fault %e");
  8010f6:	83 ec 04             	sub    $0x4,%esp
  8010f9:	68 4c 27 80 00       	push   $0x80274c
  8010fe:	6a 5e                	push   $0x5e
  801100:	68 1a 27 80 00       	push   $0x80271a
  801105:	e8 74 f1 ff ff       	call   80027e <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	6a 05                	push   $0x5
  80110f:	56                   	push   %esi
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	6a 00                	push   $0x0
  801114:	e8 09 fc ff ff       	call   800d22 <sys_page_map>
		if (r < 0) {
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	79 14                	jns    801134 <fork+0x18e>
		    	panic("sys page map fault %e");
  801120:	83 ec 04             	sub    $0x4,%esp
  801123:	68 4c 27 80 00       	push   $0x80274c
  801128:	6a 63                	push   $0x63
  80112a:	68 1a 27 80 00       	push   $0x80271a
  80112f:	e8 4a f1 ff ff       	call   80027e <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  801134:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80113a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801140:	0f 85 de fe ff ff    	jne    801024 <fork+0x7e>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  801146:	a1 04 40 80 00       	mov    0x804004,%eax
  80114b:	8b 40 64             	mov    0x64(%eax),%eax
  80114e:	83 ec 08             	sub    $0x8,%esp
  801151:	50                   	push   %eax
  801152:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801155:	57                   	push   %edi
  801156:	e8 cf fc ff ff       	call   800e2a <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80115b:	83 c4 08             	add    $0x8,%esp
  80115e:	6a 02                	push   $0x2
  801160:	57                   	push   %edi
  801161:	e8 40 fc ff ff       	call   800da6 <sys_env_set_status>
	
	return envid;
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80116b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <sfork>:

// Challenge!
int
sfork(void)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801179:	68 62 27 80 00       	push   $0x802762
  80117e:	68 a1 00 00 00       	push   $0xa1
  801183:	68 1a 27 80 00       	push   $0x80271a
  801188:	e8 f1 f0 ff ff       	call   80027e <_panic>

0080118d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801190:	8b 45 08             	mov    0x8(%ebp),%eax
  801193:	05 00 00 00 30       	add    $0x30000000,%eax
  801198:	c1 e8 0c             	shr    $0xc,%eax
}
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ad:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	c1 ea 16             	shr    $0x16,%edx
  8011c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cb:	f6 c2 01             	test   $0x1,%dl
  8011ce:	74 11                	je     8011e1 <fd_alloc+0x2d>
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	c1 ea 0c             	shr    $0xc,%edx
  8011d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dc:	f6 c2 01             	test   $0x1,%dl
  8011df:	75 09                	jne    8011ea <fd_alloc+0x36>
			*fd_store = fd;
  8011e1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e8:	eb 17                	jmp    801201 <fd_alloc+0x4d>
  8011ea:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ef:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011f4:	75 c9                	jne    8011bf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011fc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801209:	83 f8 1f             	cmp    $0x1f,%eax
  80120c:	77 36                	ja     801244 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80120e:	c1 e0 0c             	shl    $0xc,%eax
  801211:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801216:	89 c2                	mov    %eax,%edx
  801218:	c1 ea 16             	shr    $0x16,%edx
  80121b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801222:	f6 c2 01             	test   $0x1,%dl
  801225:	74 24                	je     80124b <fd_lookup+0x48>
  801227:	89 c2                	mov    %eax,%edx
  801229:	c1 ea 0c             	shr    $0xc,%edx
  80122c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801233:	f6 c2 01             	test   $0x1,%dl
  801236:	74 1a                	je     801252 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123b:	89 02                	mov    %eax,(%edx)
	return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
  801242:	eb 13                	jmp    801257 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801244:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801249:	eb 0c                	jmp    801257 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801250:	eb 05                	jmp    801257 <fd_lookup+0x54>
  801252:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801262:	ba f8 27 80 00       	mov    $0x8027f8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801267:	eb 13                	jmp    80127c <dev_lookup+0x23>
  801269:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80126c:	39 08                	cmp    %ecx,(%eax)
  80126e:	75 0c                	jne    80127c <dev_lookup+0x23>
			*dev = devtab[i];
  801270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801273:	89 01                	mov    %eax,(%ecx)
			return 0;
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
  80127a:	eb 2e                	jmp    8012aa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80127c:	8b 02                	mov    (%edx),%eax
  80127e:	85 c0                	test   %eax,%eax
  801280:	75 e7                	jne    801269 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801282:	a1 04 40 80 00       	mov    0x804004,%eax
  801287:	8b 40 48             	mov    0x48(%eax),%eax
  80128a:	83 ec 04             	sub    $0x4,%esp
  80128d:	51                   	push   %ecx
  80128e:	50                   	push   %eax
  80128f:	68 78 27 80 00       	push   $0x802778
  801294:	e8 be f0 ff ff       	call   800357 <cprintf>
	*dev = 0;
  801299:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012aa:	c9                   	leave  
  8012ab:	c3                   	ret    

008012ac <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
  8012b1:	83 ec 10             	sub    $0x10,%esp
  8012b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	50                   	push   %eax
  8012be:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c4:	c1 e8 0c             	shr    $0xc,%eax
  8012c7:	50                   	push   %eax
  8012c8:	e8 36 ff ff ff       	call   801203 <fd_lookup>
  8012cd:	83 c4 08             	add    $0x8,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 05                	js     8012d9 <fd_close+0x2d>
	    || fd != fd2)
  8012d4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d7:	74 0c                	je     8012e5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012d9:	84 db                	test   %bl,%bl
  8012db:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e0:	0f 44 c2             	cmove  %edx,%eax
  8012e3:	eb 41                	jmp    801326 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 36                	pushl  (%esi)
  8012ee:	e8 66 ff ff ff       	call   801259 <dev_lookup>
  8012f3:	89 c3                	mov    %eax,%ebx
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	78 1a                	js     801316 <fd_close+0x6a>
		if (dev->dev_close)
  8012fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ff:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801302:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801307:	85 c0                	test   %eax,%eax
  801309:	74 0b                	je     801316 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	56                   	push   %esi
  80130f:	ff d0                	call   *%eax
  801311:	89 c3                	mov    %eax,%ebx
  801313:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	56                   	push   %esi
  80131a:	6a 00                	push   $0x0
  80131c:	e8 43 fa ff ff       	call   800d64 <sys_page_unmap>
	return r;
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	89 d8                	mov    %ebx,%eax
}
  801326:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801329:	5b                   	pop    %ebx
  80132a:	5e                   	pop    %esi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801333:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	ff 75 08             	pushl  0x8(%ebp)
  80133a:	e8 c4 fe ff ff       	call   801203 <fd_lookup>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 10                	js     801356 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	6a 01                	push   $0x1
  80134b:	ff 75 f4             	pushl  -0xc(%ebp)
  80134e:	e8 59 ff ff ff       	call   8012ac <fd_close>
  801353:	83 c4 10             	add    $0x10,%esp
}
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <close_all>:

void
close_all(void)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	53                   	push   %ebx
  80135c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80135f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801364:	83 ec 0c             	sub    $0xc,%esp
  801367:	53                   	push   %ebx
  801368:	e8 c0 ff ff ff       	call   80132d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80136d:	83 c3 01             	add    $0x1,%ebx
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	83 fb 20             	cmp    $0x20,%ebx
  801376:	75 ec                	jne    801364 <close_all+0xc>
		close(i);
}
  801378:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	57                   	push   %edi
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
  801383:	83 ec 2c             	sub    $0x2c,%esp
  801386:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801389:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 6e fe ff ff       	call   801203 <fd_lookup>
  801395:	83 c4 08             	add    $0x8,%esp
  801398:	85 c0                	test   %eax,%eax
  80139a:	0f 88 c1 00 00 00    	js     801461 <dup+0xe4>
		return r;
	close(newfdnum);
  8013a0:	83 ec 0c             	sub    $0xc,%esp
  8013a3:	56                   	push   %esi
  8013a4:	e8 84 ff ff ff       	call   80132d <close>

	newfd = INDEX2FD(newfdnum);
  8013a9:	89 f3                	mov    %esi,%ebx
  8013ab:	c1 e3 0c             	shl    $0xc,%ebx
  8013ae:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013b4:	83 c4 04             	add    $0x4,%esp
  8013b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ba:	e8 de fd ff ff       	call   80119d <fd2data>
  8013bf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c1:	89 1c 24             	mov    %ebx,(%esp)
  8013c4:	e8 d4 fd ff ff       	call   80119d <fd2data>
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013cf:	89 f8                	mov    %edi,%eax
  8013d1:	c1 e8 16             	shr    $0x16,%eax
  8013d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013db:	a8 01                	test   $0x1,%al
  8013dd:	74 37                	je     801416 <dup+0x99>
  8013df:	89 f8                	mov    %edi,%eax
  8013e1:	c1 e8 0c             	shr    $0xc,%eax
  8013e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013eb:	f6 c2 01             	test   $0x1,%dl
  8013ee:	74 26                	je     801416 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ff:	50                   	push   %eax
  801400:	ff 75 d4             	pushl  -0x2c(%ebp)
  801403:	6a 00                	push   $0x0
  801405:	57                   	push   %edi
  801406:	6a 00                	push   $0x0
  801408:	e8 15 f9 ff ff       	call   800d22 <sys_page_map>
  80140d:	89 c7                	mov    %eax,%edi
  80140f:	83 c4 20             	add    $0x20,%esp
  801412:	85 c0                	test   %eax,%eax
  801414:	78 2e                	js     801444 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801416:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801419:	89 d0                	mov    %edx,%eax
  80141b:	c1 e8 0c             	shr    $0xc,%eax
  80141e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	25 07 0e 00 00       	and    $0xe07,%eax
  80142d:	50                   	push   %eax
  80142e:	53                   	push   %ebx
  80142f:	6a 00                	push   $0x0
  801431:	52                   	push   %edx
  801432:	6a 00                	push   $0x0
  801434:	e8 e9 f8 ff ff       	call   800d22 <sys_page_map>
  801439:	89 c7                	mov    %eax,%edi
  80143b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80143e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801440:	85 ff                	test   %edi,%edi
  801442:	79 1d                	jns    801461 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	53                   	push   %ebx
  801448:	6a 00                	push   $0x0
  80144a:	e8 15 f9 ff ff       	call   800d64 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80144f:	83 c4 08             	add    $0x8,%esp
  801452:	ff 75 d4             	pushl  -0x2c(%ebp)
  801455:	6a 00                	push   $0x0
  801457:	e8 08 f9 ff ff       	call   800d64 <sys_page_unmap>
	return r;
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	89 f8                	mov    %edi,%eax
}
  801461:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5f                   	pop    %edi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	53                   	push   %ebx
  80146d:	83 ec 14             	sub    $0x14,%esp
  801470:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801473:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	53                   	push   %ebx
  801478:	e8 86 fd ff ff       	call   801203 <fd_lookup>
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	89 c2                	mov    %eax,%edx
  801482:	85 c0                	test   %eax,%eax
  801484:	78 6d                	js     8014f3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148c:	50                   	push   %eax
  80148d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801490:	ff 30                	pushl  (%eax)
  801492:	e8 c2 fd ff ff       	call   801259 <dev_lookup>
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 4c                	js     8014ea <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80149e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a1:	8b 42 08             	mov    0x8(%edx),%eax
  8014a4:	83 e0 03             	and    $0x3,%eax
  8014a7:	83 f8 01             	cmp    $0x1,%eax
  8014aa:	75 21                	jne    8014cd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b1:	8b 40 48             	mov    0x48(%eax),%eax
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	50                   	push   %eax
  8014b9:	68 bc 27 80 00       	push   $0x8027bc
  8014be:	e8 94 ee ff ff       	call   800357 <cprintf>
		return -E_INVAL;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014cb:	eb 26                	jmp    8014f3 <read+0x8a>
	}
	if (!dev->dev_read)
  8014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d0:	8b 40 08             	mov    0x8(%eax),%eax
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	74 17                	je     8014ee <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	ff 75 10             	pushl  0x10(%ebp)
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	52                   	push   %edx
  8014e1:	ff d0                	call   *%eax
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	eb 09                	jmp    8014f3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	eb 05                	jmp    8014f3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8014f3:	89 d0                	mov    %edx,%eax
  8014f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	57                   	push   %edi
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	83 ec 0c             	sub    $0xc,%esp
  801503:	8b 7d 08             	mov    0x8(%ebp),%edi
  801506:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801509:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150e:	eb 21                	jmp    801531 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	89 f0                	mov    %esi,%eax
  801515:	29 d8                	sub    %ebx,%eax
  801517:	50                   	push   %eax
  801518:	89 d8                	mov    %ebx,%eax
  80151a:	03 45 0c             	add    0xc(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	57                   	push   %edi
  80151f:	e8 45 ff ff ff       	call   801469 <read>
		if (m < 0)
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 10                	js     80153b <readn+0x41>
			return m;
		if (m == 0)
  80152b:	85 c0                	test   %eax,%eax
  80152d:	74 0a                	je     801539 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152f:	01 c3                	add    %eax,%ebx
  801531:	39 f3                	cmp    %esi,%ebx
  801533:	72 db                	jb     801510 <readn+0x16>
  801535:	89 d8                	mov    %ebx,%eax
  801537:	eb 02                	jmp    80153b <readn+0x41>
  801539:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80153b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5f                   	pop    %edi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    

00801543 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	53                   	push   %ebx
  801547:	83 ec 14             	sub    $0x14,%esp
  80154a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	53                   	push   %ebx
  801552:	e8 ac fc ff ff       	call   801203 <fd_lookup>
  801557:	83 c4 08             	add    $0x8,%esp
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 68                	js     8015c8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156a:	ff 30                	pushl  (%eax)
  80156c:	e8 e8 fc ff ff       	call   801259 <dev_lookup>
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	85 c0                	test   %eax,%eax
  801576:	78 47                	js     8015bf <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801578:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157f:	75 21                	jne    8015a2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801581:	a1 04 40 80 00       	mov    0x804004,%eax
  801586:	8b 40 48             	mov    0x48(%eax),%eax
  801589:	83 ec 04             	sub    $0x4,%esp
  80158c:	53                   	push   %ebx
  80158d:	50                   	push   %eax
  80158e:	68 d8 27 80 00       	push   $0x8027d8
  801593:	e8 bf ed ff ff       	call   800357 <cprintf>
		return -E_INVAL;
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a0:	eb 26                	jmp    8015c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a8:	85 d2                	test   %edx,%edx
  8015aa:	74 17                	je     8015c3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	ff 75 10             	pushl  0x10(%ebp)
  8015b2:	ff 75 0c             	pushl  0xc(%ebp)
  8015b5:	50                   	push   %eax
  8015b6:	ff d2                	call   *%edx
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	eb 09                	jmp    8015c8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	eb 05                	jmp    8015c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015c8:	89 d0                	mov    %edx,%eax
  8015ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	ff 75 08             	pushl  0x8(%ebp)
  8015dc:	e8 22 fc ff ff       	call   801203 <fd_lookup>
  8015e1:	83 c4 08             	add    $0x8,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 0e                	js     8015f6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 14             	sub    $0x14,%esp
  8015ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801602:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	53                   	push   %ebx
  801607:	e8 f7 fb ff ff       	call   801203 <fd_lookup>
  80160c:	83 c4 08             	add    $0x8,%esp
  80160f:	89 c2                	mov    %eax,%edx
  801611:	85 c0                	test   %eax,%eax
  801613:	78 65                	js     80167a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	ff 30                	pushl  (%eax)
  801621:	e8 33 fc ff ff       	call   801259 <dev_lookup>
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 44                	js     801671 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801630:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801634:	75 21                	jne    801657 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801636:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80163b:	8b 40 48             	mov    0x48(%eax),%eax
  80163e:	83 ec 04             	sub    $0x4,%esp
  801641:	53                   	push   %ebx
  801642:	50                   	push   %eax
  801643:	68 98 27 80 00       	push   $0x802798
  801648:	e8 0a ed ff ff       	call   800357 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801655:	eb 23                	jmp    80167a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801657:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165a:	8b 52 18             	mov    0x18(%edx),%edx
  80165d:	85 d2                	test   %edx,%edx
  80165f:	74 14                	je     801675 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	ff 75 0c             	pushl  0xc(%ebp)
  801667:	50                   	push   %eax
  801668:	ff d2                	call   *%edx
  80166a:	89 c2                	mov    %eax,%edx
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	eb 09                	jmp    80167a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801671:	89 c2                	mov    %eax,%edx
  801673:	eb 05                	jmp    80167a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801675:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80167a:	89 d0                	mov    %edx,%eax
  80167c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	53                   	push   %ebx
  801685:	83 ec 14             	sub    $0x14,%esp
  801688:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168e:	50                   	push   %eax
  80168f:	ff 75 08             	pushl  0x8(%ebp)
  801692:	e8 6c fb ff ff       	call   801203 <fd_lookup>
  801697:	83 c4 08             	add    $0x8,%esp
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 58                	js     8016f8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	ff 30                	pushl  (%eax)
  8016ac:	e8 a8 fb ff ff       	call   801259 <dev_lookup>
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 37                	js     8016ef <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016bf:	74 32                	je     8016f3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016cb:	00 00 00 
	stat->st_isdir = 0;
  8016ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d5:	00 00 00 
	stat->st_dev = dev;
  8016d8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	53                   	push   %ebx
  8016e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e5:	ff 50 14             	call   *0x14(%eax)
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	eb 09                	jmp    8016f8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	89 c2                	mov    %eax,%edx
  8016f1:	eb 05                	jmp    8016f8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016f8:	89 d0                	mov    %edx,%eax
  8016fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801704:	83 ec 08             	sub    $0x8,%esp
  801707:	6a 00                	push   $0x0
  801709:	ff 75 08             	pushl  0x8(%ebp)
  80170c:	e8 e3 01 00 00       	call   8018f4 <open>
  801711:	89 c3                	mov    %eax,%ebx
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	78 1b                	js     801735 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	ff 75 0c             	pushl  0xc(%ebp)
  801720:	50                   	push   %eax
  801721:	e8 5b ff ff ff       	call   801681 <fstat>
  801726:	89 c6                	mov    %eax,%esi
	close(fd);
  801728:	89 1c 24             	mov    %ebx,(%esp)
  80172b:	e8 fd fb ff ff       	call   80132d <close>
	return r;
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	89 f0                	mov    %esi,%eax
}
  801735:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	89 c6                	mov    %eax,%esi
  801743:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801745:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80174c:	75 12                	jne    801760 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80174e:	83 ec 0c             	sub    $0xc,%esp
  801751:	6a 01                	push   $0x1
  801753:	e8 82 08 00 00       	call   801fda <ipc_find_env>
  801758:	a3 00 40 80 00       	mov    %eax,0x804000
  80175d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801760:	6a 07                	push   $0x7
  801762:	68 00 50 80 00       	push   $0x805000
  801767:	56                   	push   %esi
  801768:	ff 35 00 40 80 00    	pushl  0x804000
  80176e:	e8 05 08 00 00       	call   801f78 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801773:	83 c4 0c             	add    $0xc,%esp
  801776:	6a 00                	push   $0x0
  801778:	53                   	push   %ebx
  801779:	6a 00                	push   $0x0
  80177b:	e8 86 07 00 00       	call   801f06 <ipc_recv>
}
  801780:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	8b 40 0c             	mov    0xc(%eax),%eax
  801793:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801798:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017aa:	e8 8d ff ff ff       	call   80173c <fsipc>
}
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017cc:	e8 6b ff ff ff       	call   80173c <fsipc>
}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 04             	sub    $0x4,%esp
  8017da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ed:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f2:	e8 45 ff ff ff       	call   80173c <fsipc>
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 2c                	js     801827 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	68 00 50 80 00       	push   $0x805000
  801803:	53                   	push   %ebx
  801804:	e8 d3 f0 ff ff       	call   8008dc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801809:	a1 80 50 80 00       	mov    0x805080,%eax
  80180e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801814:	a1 84 50 80 00       	mov    0x805084,%eax
  801819:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801835:	8b 55 08             	mov    0x8(%ebp),%edx
  801838:	8b 52 0c             	mov    0xc(%edx),%edx
  80183b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801841:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801846:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80184b:	0f 47 c2             	cmova  %edx,%eax
  80184e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801853:	50                   	push   %eax
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	68 08 50 80 00       	push   $0x805008
  80185c:	e8 0d f2 ff ff       	call   800a6e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 04 00 00 00       	mov    $0x4,%eax
  80186b:	e8 cc fe ff ff       	call   80173c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	56                   	push   %esi
  801876:	53                   	push   %ebx
  801877:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801885:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 03 00 00 00       	mov    $0x3,%eax
  801895:	e8 a2 fe ff ff       	call   80173c <fsipc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 4b                	js     8018eb <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018a0:	39 c6                	cmp    %eax,%esi
  8018a2:	73 16                	jae    8018ba <devfile_read+0x48>
  8018a4:	68 08 28 80 00       	push   $0x802808
  8018a9:	68 0f 28 80 00       	push   $0x80280f
  8018ae:	6a 7c                	push   $0x7c
  8018b0:	68 24 28 80 00       	push   $0x802824
  8018b5:	e8 c4 e9 ff ff       	call   80027e <_panic>
	assert(r <= PGSIZE);
  8018ba:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018bf:	7e 16                	jle    8018d7 <devfile_read+0x65>
  8018c1:	68 2f 28 80 00       	push   $0x80282f
  8018c6:	68 0f 28 80 00       	push   $0x80280f
  8018cb:	6a 7d                	push   $0x7d
  8018cd:	68 24 28 80 00       	push   $0x802824
  8018d2:	e8 a7 e9 ff ff       	call   80027e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d7:	83 ec 04             	sub    $0x4,%esp
  8018da:	50                   	push   %eax
  8018db:	68 00 50 80 00       	push   $0x805000
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	e8 86 f1 ff ff       	call   800a6e <memmove>
	return r;
  8018e8:	83 c4 10             	add    $0x10,%esp
}
  8018eb:	89 d8                	mov    %ebx,%eax
  8018ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f0:	5b                   	pop    %ebx
  8018f1:	5e                   	pop    %esi
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 20             	sub    $0x20,%esp
  8018fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018fe:	53                   	push   %ebx
  8018ff:	e8 9f ef ff ff       	call   8008a3 <strlen>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190c:	7f 67                	jg     801975 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190e:	83 ec 0c             	sub    $0xc,%esp
  801911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801914:	50                   	push   %eax
  801915:	e8 9a f8 ff ff       	call   8011b4 <fd_alloc>
  80191a:	83 c4 10             	add    $0x10,%esp
		return r;
  80191d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 57                	js     80197a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	53                   	push   %ebx
  801927:	68 00 50 80 00       	push   $0x805000
  80192c:	e8 ab ef ff ff       	call   8008dc <strcpy>
	fsipcbuf.open.req_omode = mode;
  801931:	8b 45 0c             	mov    0xc(%ebp),%eax
  801934:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801939:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193c:	b8 01 00 00 00       	mov    $0x1,%eax
  801941:	e8 f6 fd ff ff       	call   80173c <fsipc>
  801946:	89 c3                	mov    %eax,%ebx
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	79 14                	jns    801963 <open+0x6f>
		fd_close(fd, 0);
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	6a 00                	push   $0x0
  801954:	ff 75 f4             	pushl  -0xc(%ebp)
  801957:	e8 50 f9 ff ff       	call   8012ac <fd_close>
		return r;
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	89 da                	mov    %ebx,%edx
  801961:	eb 17                	jmp    80197a <open+0x86>
	}

	return fd2num(fd);
  801963:	83 ec 0c             	sub    $0xc,%esp
  801966:	ff 75 f4             	pushl  -0xc(%ebp)
  801969:	e8 1f f8 ff ff       	call   80118d <fd2num>
  80196e:	89 c2                	mov    %eax,%edx
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	eb 05                	jmp    80197a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801975:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80197a:	89 d0                	mov    %edx,%eax
  80197c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801987:	ba 00 00 00 00       	mov    $0x0,%edx
  80198c:	b8 08 00 00 00       	mov    $0x8,%eax
  801991:	e8 a6 fd ff ff       	call   80173c <fsipc>
}
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	56                   	push   %esi
  80199c:	53                   	push   %ebx
  80199d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	ff 75 08             	pushl  0x8(%ebp)
  8019a6:	e8 f2 f7 ff ff       	call   80119d <fd2data>
  8019ab:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ad:	83 c4 08             	add    $0x8,%esp
  8019b0:	68 3b 28 80 00       	push   $0x80283b
  8019b5:	53                   	push   %ebx
  8019b6:	e8 21 ef ff ff       	call   8008dc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019bb:	8b 46 04             	mov    0x4(%esi),%eax
  8019be:	2b 06                	sub    (%esi),%eax
  8019c0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019cd:	00 00 00 
	stat->st_dev = &devpipe;
  8019d0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019d7:	30 80 00 
	return 0;
}
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
  8019df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e2:	5b                   	pop    %ebx
  8019e3:	5e                   	pop    %esi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 0c             	sub    $0xc,%esp
  8019ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019f0:	53                   	push   %ebx
  8019f1:	6a 00                	push   $0x0
  8019f3:	e8 6c f3 ff ff       	call   800d64 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f8:	89 1c 24             	mov    %ebx,(%esp)
  8019fb:	e8 9d f7 ff ff       	call   80119d <fd2data>
  801a00:	83 c4 08             	add    $0x8,%esp
  801a03:	50                   	push   %eax
  801a04:	6a 00                	push   $0x0
  801a06:	e8 59 f3 ff ff       	call   800d64 <sys_page_unmap>
}
  801a0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	57                   	push   %edi
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 1c             	sub    $0x1c,%esp
  801a19:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a1c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a1e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a23:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a26:	83 ec 0c             	sub    $0xc,%esp
  801a29:	ff 75 e0             	pushl  -0x20(%ebp)
  801a2c:	e8 e2 05 00 00       	call   802013 <pageref>
  801a31:	89 c3                	mov    %eax,%ebx
  801a33:	89 3c 24             	mov    %edi,(%esp)
  801a36:	e8 d8 05 00 00       	call   802013 <pageref>
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	39 c3                	cmp    %eax,%ebx
  801a40:	0f 94 c1             	sete   %cl
  801a43:	0f b6 c9             	movzbl %cl,%ecx
  801a46:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a49:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a4f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a52:	39 ce                	cmp    %ecx,%esi
  801a54:	74 1b                	je     801a71 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a56:	39 c3                	cmp    %eax,%ebx
  801a58:	75 c4                	jne    801a1e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a5a:	8b 42 58             	mov    0x58(%edx),%eax
  801a5d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a60:	50                   	push   %eax
  801a61:	56                   	push   %esi
  801a62:	68 42 28 80 00       	push   $0x802842
  801a67:	e8 eb e8 ff ff       	call   800357 <cprintf>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	eb ad                	jmp    801a1e <_pipeisclosed+0xe>
	}
}
  801a71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5f                   	pop    %edi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	57                   	push   %edi
  801a80:	56                   	push   %esi
  801a81:	53                   	push   %ebx
  801a82:	83 ec 28             	sub    $0x28,%esp
  801a85:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a88:	56                   	push   %esi
  801a89:	e8 0f f7 ff ff       	call   80119d <fd2data>
  801a8e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	bf 00 00 00 00       	mov    $0x0,%edi
  801a98:	eb 4b                	jmp    801ae5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a9a:	89 da                	mov    %ebx,%edx
  801a9c:	89 f0                	mov    %esi,%eax
  801a9e:	e8 6d ff ff ff       	call   801a10 <_pipeisclosed>
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	75 48                	jne    801aef <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa7:	e8 14 f2 ff ff       	call   800cc0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aac:	8b 43 04             	mov    0x4(%ebx),%eax
  801aaf:	8b 0b                	mov    (%ebx),%ecx
  801ab1:	8d 51 20             	lea    0x20(%ecx),%edx
  801ab4:	39 d0                	cmp    %edx,%eax
  801ab6:	73 e2                	jae    801a9a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801abb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801abf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ac2:	89 c2                	mov    %eax,%edx
  801ac4:	c1 fa 1f             	sar    $0x1f,%edx
  801ac7:	89 d1                	mov    %edx,%ecx
  801ac9:	c1 e9 1b             	shr    $0x1b,%ecx
  801acc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801acf:	83 e2 1f             	and    $0x1f,%edx
  801ad2:	29 ca                	sub    %ecx,%edx
  801ad4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801adc:	83 c0 01             	add    $0x1,%eax
  801adf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae2:	83 c7 01             	add    $0x1,%edi
  801ae5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae8:	75 c2                	jne    801aac <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aea:	8b 45 10             	mov    0x10(%ebp),%eax
  801aed:	eb 05                	jmp    801af4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801af4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5f                   	pop    %edi
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	57                   	push   %edi
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 18             	sub    $0x18,%esp
  801b05:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b08:	57                   	push   %edi
  801b09:	e8 8f f6 ff ff       	call   80119d <fd2data>
  801b0e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b18:	eb 3d                	jmp    801b57 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b1a:	85 db                	test   %ebx,%ebx
  801b1c:	74 04                	je     801b22 <devpipe_read+0x26>
				return i;
  801b1e:	89 d8                	mov    %ebx,%eax
  801b20:	eb 44                	jmp    801b66 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b22:	89 f2                	mov    %esi,%edx
  801b24:	89 f8                	mov    %edi,%eax
  801b26:	e8 e5 fe ff ff       	call   801a10 <_pipeisclosed>
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	75 32                	jne    801b61 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b2f:	e8 8c f1 ff ff       	call   800cc0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b34:	8b 06                	mov    (%esi),%eax
  801b36:	3b 46 04             	cmp    0x4(%esi),%eax
  801b39:	74 df                	je     801b1a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b3b:	99                   	cltd   
  801b3c:	c1 ea 1b             	shr    $0x1b,%edx
  801b3f:	01 d0                	add    %edx,%eax
  801b41:	83 e0 1f             	and    $0x1f,%eax
  801b44:	29 d0                	sub    %edx,%eax
  801b46:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b51:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b54:	83 c3 01             	add    $0x1,%ebx
  801b57:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b5a:	75 d8                	jne    801b34 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5f:	eb 05                	jmp    801b66 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5f                   	pop    %edi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	56                   	push   %esi
  801b72:	53                   	push   %ebx
  801b73:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b79:	50                   	push   %eax
  801b7a:	e8 35 f6 ff ff       	call   8011b4 <fd_alloc>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	89 c2                	mov    %eax,%edx
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 2c 01 00 00    	js     801cb8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8c:	83 ec 04             	sub    $0x4,%esp
  801b8f:	68 07 04 00 00       	push   $0x407
  801b94:	ff 75 f4             	pushl  -0xc(%ebp)
  801b97:	6a 00                	push   $0x0
  801b99:	e8 41 f1 ff ff       	call   800cdf <sys_page_alloc>
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	89 c2                	mov    %eax,%edx
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	0f 88 0d 01 00 00    	js     801cb8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bb1:	50                   	push   %eax
  801bb2:	e8 fd f5 ff ff       	call   8011b4 <fd_alloc>
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	0f 88 e2 00 00 00    	js     801ca6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	68 07 04 00 00       	push   $0x407
  801bcc:	ff 75 f0             	pushl  -0x10(%ebp)
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 09 f1 ff ff       	call   800cdf <sys_page_alloc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	0f 88 c3 00 00 00    	js     801ca6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801be3:	83 ec 0c             	sub    $0xc,%esp
  801be6:	ff 75 f4             	pushl  -0xc(%ebp)
  801be9:	e8 af f5 ff ff       	call   80119d <fd2data>
  801bee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf0:	83 c4 0c             	add    $0xc,%esp
  801bf3:	68 07 04 00 00       	push   $0x407
  801bf8:	50                   	push   %eax
  801bf9:	6a 00                	push   $0x0
  801bfb:	e8 df f0 ff ff       	call   800cdf <sys_page_alloc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 89 00 00 00    	js     801c96 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	ff 75 f0             	pushl  -0x10(%ebp)
  801c13:	e8 85 f5 ff ff       	call   80119d <fd2data>
  801c18:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c1f:	50                   	push   %eax
  801c20:	6a 00                	push   $0x0
  801c22:	56                   	push   %esi
  801c23:	6a 00                	push   $0x0
  801c25:	e8 f8 f0 ff ff       	call   800d22 <sys_page_map>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	83 c4 20             	add    $0x20,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 55                	js     801c88 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c41:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c51:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c56:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c5d:	83 ec 0c             	sub    $0xc,%esp
  801c60:	ff 75 f4             	pushl  -0xc(%ebp)
  801c63:	e8 25 f5 ff ff       	call   80118d <fd2num>
  801c68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c6d:	83 c4 04             	add    $0x4,%esp
  801c70:	ff 75 f0             	pushl  -0x10(%ebp)
  801c73:	e8 15 f5 ff ff       	call   80118d <fd2num>
  801c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	ba 00 00 00 00       	mov    $0x0,%edx
  801c86:	eb 30                	jmp    801cb8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	56                   	push   %esi
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 d1 f0 ff ff       	call   800d64 <sys_page_unmap>
  801c93:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c96:	83 ec 08             	sub    $0x8,%esp
  801c99:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 c1 f0 ff ff       	call   800d64 <sys_page_unmap>
  801ca3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca6:	83 ec 08             	sub    $0x8,%esp
  801ca9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cac:	6a 00                	push   $0x0
  801cae:	e8 b1 f0 ff ff       	call   800d64 <sys_page_unmap>
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb8:	89 d0                	mov    %edx,%eax
  801cba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cca:	50                   	push   %eax
  801ccb:	ff 75 08             	pushl  0x8(%ebp)
  801cce:	e8 30 f5 ff ff       	call   801203 <fd_lookup>
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 18                	js     801cf2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce0:	e8 b8 f4 ff ff       	call   80119d <fd2data>
	return _pipeisclosed(fd, p);
  801ce5:	89 c2                	mov    %eax,%edx
  801ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cea:	e8 21 fd ff ff       	call   801a10 <_pipeisclosed>
  801cef:	83 c4 10             	add    $0x10,%esp
}
  801cf2:	c9                   	leave  
  801cf3:	c3                   	ret    

00801cf4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d04:	68 5a 28 80 00       	push   $0x80285a
  801d09:	ff 75 0c             	pushl  0xc(%ebp)
  801d0c:	e8 cb eb ff ff       	call   8008dc <strcpy>
	return 0;
}
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    

00801d18 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	57                   	push   %edi
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
  801d1e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d24:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d29:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2f:	eb 2d                	jmp    801d5e <devcons_write+0x46>
		m = n - tot;
  801d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d34:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d36:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d39:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d3e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d41:	83 ec 04             	sub    $0x4,%esp
  801d44:	53                   	push   %ebx
  801d45:	03 45 0c             	add    0xc(%ebp),%eax
  801d48:	50                   	push   %eax
  801d49:	57                   	push   %edi
  801d4a:	e8 1f ed ff ff       	call   800a6e <memmove>
		sys_cputs(buf, m);
  801d4f:	83 c4 08             	add    $0x8,%esp
  801d52:	53                   	push   %ebx
  801d53:	57                   	push   %edi
  801d54:	e8 ca ee ff ff       	call   800c23 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d59:	01 de                	add    %ebx,%esi
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	89 f0                	mov    %esi,%eax
  801d60:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d63:	72 cc                	jb     801d31 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5f                   	pop    %edi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	83 ec 08             	sub    $0x8,%esp
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d7c:	74 2a                	je     801da8 <devcons_read+0x3b>
  801d7e:	eb 05                	jmp    801d85 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d80:	e8 3b ef ff ff       	call   800cc0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d85:	e8 b7 ee ff ff       	call   800c41 <sys_cgetc>
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	74 f2                	je     801d80 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	78 16                	js     801da8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d92:	83 f8 04             	cmp    $0x4,%eax
  801d95:	74 0c                	je     801da3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d9a:	88 02                	mov    %al,(%edx)
	return 1;
  801d9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801da1:	eb 05                	jmp    801da8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da8:	c9                   	leave  
  801da9:	c3                   	ret    

00801daa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801db0:	8b 45 08             	mov    0x8(%ebp),%eax
  801db3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db6:	6a 01                	push   $0x1
  801db8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dbb:	50                   	push   %eax
  801dbc:	e8 62 ee ff ff       	call   800c23 <sys_cputs>
}
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <getchar>:

int
getchar(void)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dcc:	6a 01                	push   $0x1
  801dce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dd1:	50                   	push   %eax
  801dd2:	6a 00                	push   $0x0
  801dd4:	e8 90 f6 ff ff       	call   801469 <read>
	if (r < 0)
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 0f                	js     801def <getchar+0x29>
		return r;
	if (r < 1)
  801de0:	85 c0                	test   %eax,%eax
  801de2:	7e 06                	jle    801dea <getchar+0x24>
		return -E_EOF;
	return c;
  801de4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de8:	eb 05                	jmp    801def <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dea:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfa:	50                   	push   %eax
  801dfb:	ff 75 08             	pushl  0x8(%ebp)
  801dfe:	e8 00 f4 ff ff       	call   801203 <fd_lookup>
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 11                	js     801e1b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e13:	39 10                	cmp    %edx,(%eax)
  801e15:	0f 94 c0             	sete   %al
  801e18:	0f b6 c0             	movzbl %al,%eax
}
  801e1b:	c9                   	leave  
  801e1c:	c3                   	ret    

00801e1d <opencons>:

int
opencons(void)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e26:	50                   	push   %eax
  801e27:	e8 88 f3 ff ff       	call   8011b4 <fd_alloc>
  801e2c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 3e                	js     801e73 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e35:	83 ec 04             	sub    $0x4,%esp
  801e38:	68 07 04 00 00       	push   $0x407
  801e3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e40:	6a 00                	push   $0x0
  801e42:	e8 98 ee ff ff       	call   800cdf <sys_page_alloc>
  801e47:	83 c4 10             	add    $0x10,%esp
		return r;
  801e4a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 23                	js     801e73 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e50:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e59:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	50                   	push   %eax
  801e69:	e8 1f f3 ff ff       	call   80118d <fd2num>
  801e6e:	89 c2                	mov    %eax,%edx
  801e70:	83 c4 10             	add    $0x10,%esp
}
  801e73:	89 d0                	mov    %edx,%eax
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    

00801e77 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e7d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e84:	75 2a                	jne    801eb0 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801e86:	83 ec 04             	sub    $0x4,%esp
  801e89:	6a 07                	push   $0x7
  801e8b:	68 00 f0 bf ee       	push   $0xeebff000
  801e90:	6a 00                	push   $0x0
  801e92:	e8 48 ee ff ff       	call   800cdf <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	79 12                	jns    801eb0 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e9e:	50                   	push   %eax
  801e9f:	68 66 28 80 00       	push   $0x802866
  801ea4:	6a 23                	push   $0x23
  801ea6:	68 6a 28 80 00       	push   $0x80286a
  801eab:	e8 ce e3 ff ff       	call   80027e <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb3:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801eb8:	83 ec 08             	sub    $0x8,%esp
  801ebb:	68 e2 1e 80 00       	push   $0x801ee2
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 63 ef ff ff       	call   800e2a <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	79 12                	jns    801ee0 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801ece:	50                   	push   %eax
  801ecf:	68 66 28 80 00       	push   $0x802866
  801ed4:	6a 2c                	push   $0x2c
  801ed6:	68 6a 28 80 00       	push   $0x80286a
  801edb:	e8 9e e3 ff ff       	call   80027e <_panic>
	}
}
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ee2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ee3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ee8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801eea:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801eed:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801ef1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801ef6:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801efa:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801efc:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801eff:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801f00:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801f03:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801f04:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f05:	c3                   	ret    

00801f06 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	56                   	push   %esi
  801f0a:	53                   	push   %ebx
  801f0b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801f14:	85 c0                	test   %eax,%eax
  801f16:	75 12                	jne    801f2a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	68 00 00 c0 ee       	push   $0xeec00000
  801f20:	e8 6a ef ff ff       	call   800e8f <sys_ipc_recv>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	eb 0c                	jmp    801f36 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801f2a:	83 ec 0c             	sub    $0xc,%esp
  801f2d:	50                   	push   %eax
  801f2e:	e8 5c ef ff ff       	call   800e8f <sys_ipc_recv>
  801f33:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801f36:	85 f6                	test   %esi,%esi
  801f38:	0f 95 c1             	setne  %cl
  801f3b:	85 db                	test   %ebx,%ebx
  801f3d:	0f 95 c2             	setne  %dl
  801f40:	84 d1                	test   %dl,%cl
  801f42:	74 09                	je     801f4d <ipc_recv+0x47>
  801f44:	89 c2                	mov    %eax,%edx
  801f46:	c1 ea 1f             	shr    $0x1f,%edx
  801f49:	84 d2                	test   %dl,%dl
  801f4b:	75 24                	jne    801f71 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801f4d:	85 f6                	test   %esi,%esi
  801f4f:	74 0a                	je     801f5b <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801f51:	a1 04 40 80 00       	mov    0x804004,%eax
  801f56:	8b 40 74             	mov    0x74(%eax),%eax
  801f59:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801f5b:	85 db                	test   %ebx,%ebx
  801f5d:	74 0a                	je     801f69 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801f5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f64:	8b 40 78             	mov    0x78(%eax),%eax
  801f67:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f69:	a1 04 40 80 00       	mov    0x804004,%eax
  801f6e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	57                   	push   %edi
  801f7c:	56                   	push   %esi
  801f7d:	53                   	push   %ebx
  801f7e:	83 ec 0c             	sub    $0xc,%esp
  801f81:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f84:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801f8a:	85 db                	test   %ebx,%ebx
  801f8c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f91:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f94:	ff 75 14             	pushl  0x14(%ebp)
  801f97:	53                   	push   %ebx
  801f98:	56                   	push   %esi
  801f99:	57                   	push   %edi
  801f9a:	e8 cd ee ff ff       	call   800e6c <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f9f:	89 c2                	mov    %eax,%edx
  801fa1:	c1 ea 1f             	shr    $0x1f,%edx
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	84 d2                	test   %dl,%dl
  801fa9:	74 17                	je     801fc2 <ipc_send+0x4a>
  801fab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fae:	74 12                	je     801fc2 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801fb0:	50                   	push   %eax
  801fb1:	68 78 28 80 00       	push   $0x802878
  801fb6:	6a 47                	push   $0x47
  801fb8:	68 86 28 80 00       	push   $0x802886
  801fbd:	e8 bc e2 ff ff       	call   80027e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801fc2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fc5:	75 07                	jne    801fce <ipc_send+0x56>
			sys_yield();
  801fc7:	e8 f4 ec ff ff       	call   800cc0 <sys_yield>
  801fcc:	eb c6                	jmp    801f94 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	75 c2                	jne    801f94 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801fd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5e                   	pop    %esi
  801fd7:	5f                   	pop    %edi
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fe5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fe8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fee:	8b 52 50             	mov    0x50(%edx),%edx
  801ff1:	39 ca                	cmp    %ecx,%edx
  801ff3:	75 0d                	jne    802002 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ff5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ff8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ffd:	8b 40 48             	mov    0x48(%eax),%eax
  802000:	eb 0f                	jmp    802011 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802002:	83 c0 01             	add    $0x1,%eax
  802005:	3d 00 04 00 00       	cmp    $0x400,%eax
  80200a:	75 d9                	jne    801fe5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80200c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    

00802013 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802019:	89 d0                	mov    %edx,%eax
  80201b:	c1 e8 16             	shr    $0x16,%eax
  80201e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802025:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202a:	f6 c1 01             	test   $0x1,%cl
  80202d:	74 1d                	je     80204c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80202f:	c1 ea 0c             	shr    $0xc,%edx
  802032:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802039:	f6 c2 01             	test   $0x1,%dl
  80203c:	74 0e                	je     80204c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80203e:	c1 ea 0c             	shr    $0xc,%edx
  802041:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802048:	ef 
  802049:	0f b7 c0             	movzwl %ax,%eax
}
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80205b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80205f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 f6                	test   %esi,%esi
  802069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80206d:	89 ca                	mov    %ecx,%edx
  80206f:	89 f8                	mov    %edi,%eax
  802071:	75 3d                	jne    8020b0 <__udivdi3+0x60>
  802073:	39 cf                	cmp    %ecx,%edi
  802075:	0f 87 c5 00 00 00    	ja     802140 <__udivdi3+0xf0>
  80207b:	85 ff                	test   %edi,%edi
  80207d:	89 fd                	mov    %edi,%ebp
  80207f:	75 0b                	jne    80208c <__udivdi3+0x3c>
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	31 d2                	xor    %edx,%edx
  802088:	f7 f7                	div    %edi
  80208a:	89 c5                	mov    %eax,%ebp
  80208c:	89 c8                	mov    %ecx,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	f7 f5                	div    %ebp
  802092:	89 c1                	mov    %eax,%ecx
  802094:	89 d8                	mov    %ebx,%eax
  802096:	89 cf                	mov    %ecx,%edi
  802098:	f7 f5                	div    %ebp
  80209a:	89 c3                	mov    %eax,%ebx
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
  8020b0:	39 ce                	cmp    %ecx,%esi
  8020b2:	77 74                	ja     802128 <__udivdi3+0xd8>
  8020b4:	0f bd fe             	bsr    %esi,%edi
  8020b7:	83 f7 1f             	xor    $0x1f,%edi
  8020ba:	0f 84 98 00 00 00    	je     802158 <__udivdi3+0x108>
  8020c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	89 c5                	mov    %eax,%ebp
  8020c9:	29 fb                	sub    %edi,%ebx
  8020cb:	d3 e6                	shl    %cl,%esi
  8020cd:	89 d9                	mov    %ebx,%ecx
  8020cf:	d3 ed                	shr    %cl,%ebp
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e0                	shl    %cl,%eax
  8020d5:	09 ee                	or     %ebp,%esi
  8020d7:	89 d9                	mov    %ebx,%ecx
  8020d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020dd:	89 d5                	mov    %edx,%ebp
  8020df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020e3:	d3 ed                	shr    %cl,%ebp
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e2                	shl    %cl,%edx
  8020e9:	89 d9                	mov    %ebx,%ecx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	09 c2                	or     %eax,%edx
  8020ef:	89 d0                	mov    %edx,%eax
  8020f1:	89 ea                	mov    %ebp,%edx
  8020f3:	f7 f6                	div    %esi
  8020f5:	89 d5                	mov    %edx,%ebp
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	f7 64 24 0c          	mull   0xc(%esp)
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	72 10                	jb     802111 <__udivdi3+0xc1>
  802101:	8b 74 24 08          	mov    0x8(%esp),%esi
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e6                	shl    %cl,%esi
  802109:	39 c6                	cmp    %eax,%esi
  80210b:	73 07                	jae    802114 <__udivdi3+0xc4>
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	75 03                	jne    802114 <__udivdi3+0xc4>
  802111:	83 eb 01             	sub    $0x1,%ebx
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 d8                	mov    %ebx,%eax
  802118:	89 fa                	mov    %edi,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	31 ff                	xor    %edi,%edi
  80212a:	31 db                	xor    %ebx,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 d8                	mov    %ebx,%eax
  802142:	f7 f7                	div    %edi
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 c3                	mov    %eax,%ebx
  802148:	89 d8                	mov    %ebx,%eax
  80214a:	89 fa                	mov    %edi,%edx
  80214c:	83 c4 1c             	add    $0x1c,%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5f                   	pop    %edi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	39 ce                	cmp    %ecx,%esi
  80215a:	72 0c                	jb     802168 <__udivdi3+0x118>
  80215c:	31 db                	xor    %ebx,%ebx
  80215e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802162:	0f 87 34 ff ff ff    	ja     80209c <__udivdi3+0x4c>
  802168:	bb 01 00 00 00       	mov    $0x1,%ebx
  80216d:	e9 2a ff ff ff       	jmp    80209c <__udivdi3+0x4c>
  802172:	66 90                	xchg   %ax,%ax
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80218b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80218f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 d2                	test   %edx,%edx
  802199:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80219d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021a1:	89 f3                	mov    %esi,%ebx
  8021a3:	89 3c 24             	mov    %edi,(%esp)
  8021a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021aa:	75 1c                	jne    8021c8 <__umoddi3+0x48>
  8021ac:	39 f7                	cmp    %esi,%edi
  8021ae:	76 50                	jbe    802200 <__umoddi3+0x80>
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	f7 f7                	div    %edi
  8021b6:	89 d0                	mov    %edx,%eax
  8021b8:	31 d2                	xor    %edx,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	89 d0                	mov    %edx,%eax
  8021cc:	77 52                	ja     802220 <__umoddi3+0xa0>
  8021ce:	0f bd ea             	bsr    %edx,%ebp
  8021d1:	83 f5 1f             	xor    $0x1f,%ebp
  8021d4:	75 5a                	jne    802230 <__umoddi3+0xb0>
  8021d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021da:	0f 82 e0 00 00 00    	jb     8022c0 <__umoddi3+0x140>
  8021e0:	39 0c 24             	cmp    %ecx,(%esp)
  8021e3:	0f 86 d7 00 00 00    	jbe    8022c0 <__umoddi3+0x140>
  8021e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021f1:	83 c4 1c             	add    $0x1c,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	85 ff                	test   %edi,%edi
  802202:	89 fd                	mov    %edi,%ebp
  802204:	75 0b                	jne    802211 <__umoddi3+0x91>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f7                	div    %edi
  80220f:	89 c5                	mov    %eax,%ebp
  802211:	89 f0                	mov    %esi,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f5                	div    %ebp
  802217:	89 c8                	mov    %ecx,%eax
  802219:	f7 f5                	div    %ebp
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	eb 99                	jmp    8021b8 <__umoddi3+0x38>
  80221f:	90                   	nop
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	83 c4 1c             	add    $0x1c,%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	8b 34 24             	mov    (%esp),%esi
  802233:	bf 20 00 00 00       	mov    $0x20,%edi
  802238:	89 e9                	mov    %ebp,%ecx
  80223a:	29 ef                	sub    %ebp,%edi
  80223c:	d3 e0                	shl    %cl,%eax
  80223e:	89 f9                	mov    %edi,%ecx
  802240:	89 f2                	mov    %esi,%edx
  802242:	d3 ea                	shr    %cl,%edx
  802244:	89 e9                	mov    %ebp,%ecx
  802246:	09 c2                	or     %eax,%edx
  802248:	89 d8                	mov    %ebx,%eax
  80224a:	89 14 24             	mov    %edx,(%esp)
  80224d:	89 f2                	mov    %esi,%edx
  80224f:	d3 e2                	shl    %cl,%edx
  802251:	89 f9                	mov    %edi,%ecx
  802253:	89 54 24 04          	mov    %edx,0x4(%esp)
  802257:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	89 c6                	mov    %eax,%esi
  802261:	d3 e3                	shl    %cl,%ebx
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 d0                	mov    %edx,%eax
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	09 d8                	or     %ebx,%eax
  80226d:	89 d3                	mov    %edx,%ebx
  80226f:	89 f2                	mov    %esi,%edx
  802271:	f7 34 24             	divl   (%esp)
  802274:	89 d6                	mov    %edx,%esi
  802276:	d3 e3                	shl    %cl,%ebx
  802278:	f7 64 24 04          	mull   0x4(%esp)
  80227c:	39 d6                	cmp    %edx,%esi
  80227e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802282:	89 d1                	mov    %edx,%ecx
  802284:	89 c3                	mov    %eax,%ebx
  802286:	72 08                	jb     802290 <__umoddi3+0x110>
  802288:	75 11                	jne    80229b <__umoddi3+0x11b>
  80228a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80228e:	73 0b                	jae    80229b <__umoddi3+0x11b>
  802290:	2b 44 24 04          	sub    0x4(%esp),%eax
  802294:	1b 14 24             	sbb    (%esp),%edx
  802297:	89 d1                	mov    %edx,%ecx
  802299:	89 c3                	mov    %eax,%ebx
  80229b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80229f:	29 da                	sub    %ebx,%edx
  8022a1:	19 ce                	sbb    %ecx,%esi
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 f0                	mov    %esi,%eax
  8022a7:	d3 e0                	shl    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	d3 ea                	shr    %cl,%edx
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	d3 ee                	shr    %cl,%esi
  8022b1:	09 d0                	or     %edx,%eax
  8022b3:	89 f2                	mov    %esi,%edx
  8022b5:	83 c4 1c             	add    $0x1c,%esp
  8022b8:	5b                   	pop    %ebx
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    
  8022bd:	8d 76 00             	lea    0x0(%esi),%esi
  8022c0:	29 f9                	sub    %edi,%ecx
  8022c2:	19 d6                	sbb    %edx,%esi
  8022c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022cc:	e9 18 ff ff ff       	jmp    8021e9 <__umoddi3+0x69>
